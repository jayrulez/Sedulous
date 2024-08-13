using System;
using System.Diagnostics;
using System.Text;
using Bulkan;
using System.Threading;
using System.Collections;
using static Sedulous.GAL.VK.VulkanUtil;
using static Bulkan.VulkanNative;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.VK;

	internal class Stack<T>
	{
		private Queue<T> _storage = new .() ~ delete _;

		public int Count => _storage.Count;

		public void Push(T item)
		{
			_storage.Add(item);
		}

		public T Pop()
		{
			return _storage.PopBack();
		}
	}

	public class VKGraphicsDevice : GraphicsDevice
	{
		private const uint32 VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR = 0x00000001;
		private static readonly String s_name = "GAL-VKGraphicsDevice";

		private VkInstance _instance;
		private VkPhysicalDevice _physicalDevice;
		private String _deviceName;
		private String _vendorName;
		private GraphicsApiVersion _apiVersion;
		private String _driverName;
		private String _driverInfo;
		private VKDeviceMemoryManager _memoryManager;
		private VkPhysicalDeviceProperties _physicalDeviceProperties;
		private VkPhysicalDeviceFeatures _physicalDeviceFeatures;
		private VkPhysicalDeviceMemoryProperties _physicalDeviceMemProperties;
		private VkDevice _device;
		private uint32 _graphicsQueueIndex;
		private uint32 _presentQueueIndex;
		private VkCommandPool _graphicsCommandPool;
		private readonly Monitor _graphicsCommandPoolLock = new .() ~ delete _;
		private VkQueue _graphicsQueue;
		private readonly Monitor _graphicsQueueLock = new .() ~ delete _;
		private VkDebugReportCallbackEXT _debugCallbackHandle;
		private PFN_vkDebugReportCallbackEXT _debugCallbackFunc;
		private bool _debugMarkerEnabled;
		private vkDebugMarkerSetObjectNameEXT_t _setObjectNameDelegate;
		private vkCmdDebugMarkerBeginEXT_t _markerBegin;
		private vkCmdDebugMarkerEndEXT_t _markerEnd;
		private vkCmdDebugMarkerInsertEXT_t _markerInsert;
		private Monitor _filtersLock = new .() ~ delete _;
		private readonly Dictionary<VkFormat, VkFilter> _filters = new .();
		private readonly BackendInfoVulkan _vulkanInfo;

		private const int32 SharedCommandPoolCount = 4;
		private Stack<SharedCommandPool> _sharedGraphicsCommandPools = new Stack<SharedCommandPool>();
		private VKDescriptorPoolManager _descriptorPoolManager;
		private bool _standardValidationSupported;
		private bool _khronosValidationSupported;
		private bool _standardClipYDirection;
		private vkGetBufferMemoryRequirements2_t _getBufferMemoryRequirements2;
		private vkGetImageMemoryRequirements2_t _getImageMemoryRequirements2;
		private vkGetPhysicalDeviceProperties2_t _getPhysicalDeviceProperties2;
		private vkCreateMetalSurfaceEXT_t _createMetalSurfaceEXT;

		// Staging Resources
		private const uint32 MinStagingBufferSize = 64;
		private const uint32 MaxStagingBufferSize = 512;

		private readonly Monitor _stagingResourcesLock = new .() ~ delete _;
		private readonly List<VKTexture> _availableStagingTextures = new List<VKTexture>();
		private readonly List<VKBuffer> _availableStagingBuffers = new List<VKBuffer>();

		private readonly Dictionary<VkCommandBuffer, VKTexture> _submittedStagingTextures
			= new Dictionary<VkCommandBuffer, VKTexture>();
		private readonly Dictionary<VkCommandBuffer, VKBuffer> _submittedStagingBuffers
			= new Dictionary<VkCommandBuffer, VKBuffer>();
		private readonly Dictionary<VkCommandBuffer, SharedCommandPool> _submittedSharedCommandPools
			= new Dictionary<VkCommandBuffer, SharedCommandPool>();

		public override String DeviceName => _deviceName;

		public override String VendorName => _vendorName;

		public override GraphicsApiVersion ApiVersion => _apiVersion;

		public override GraphicsBackend BackendType => GraphicsBackend.Vulkan;

		public override bool IsUvOriginTopLeft => true;

		public override bool IsDepthRangeZeroToOne => true;

		public override bool IsClipSpaceYInverted => !_standardClipYDirection;

		public override Swapchain MainSwapchain => _mainSwapchain;

		public override GraphicsDeviceFeatures Features { get; protected set; }

		public bool GetVulkanInfo(out BackendInfoVulkan info)
		{
			info = _vulkanInfo;
			return true;
		}

		public VkInstance Instance => _instance;
		public VkDevice Device => _device;
		public VkPhysicalDevice PhysicalDevice => _physicalDevice;
		public VkPhysicalDeviceMemoryProperties PhysicalDeviceMemProperties => _physicalDeviceMemProperties;
		public VkQueue GraphicsQueue => _graphicsQueue;
		public uint32 GraphicsQueueIndex => _graphicsQueueIndex;
		public uint32 PresentQueueIndex => _presentQueueIndex;
		public String DriverName => _driverName;
		public String DriverInfo => _driverInfo;
		internal VKDeviceMemoryManager MemoryManager => _memoryManager;
		internal VKDescriptorPoolManager DescriptorPoolManager => _descriptorPoolManager;
		internal vkCmdDebugMarkerBeginEXT_t MarkerBegin => _markerBegin;
		internal vkCmdDebugMarkerEndEXT_t MarkerEnd => _markerEnd;
		internal vkCmdDebugMarkerInsertEXT_t MarkerInsert => _markerInsert;
		internal vkGetBufferMemoryRequirements2_t GetBufferMemoryRequirements2 => _getBufferMemoryRequirements2;
		internal vkGetImageMemoryRequirements2_t GetImageMemoryRequirements2 => _getImageMemoryRequirements2;
		internal vkCreateMetalSurfaceEXT_t CreateMetalSurfaceEXT => _createMetalSurfaceEXT;

		private readonly Monitor _submittedFencesLock = new .() ~ delete _;
		private readonly Monitor _availableSubmissionFencesLock = new .() ~ delete _;
		private readonly Queue<VkFence> _availableSubmissionFences = new .();
		private readonly List<FenceSubmissionInfo> _submittedFences = new List<FenceSubmissionInfo>();
		private readonly VKSwapchain _mainSwapchain;

		private readonly List<String> _surfaceExtensions = new List<String>();

		public this(GraphicsDeviceOptions options, SwapchainDescription? scDesc)
			: this(options, scDesc, VulkanDeviceOptions(.(), .())) { }

		public this(GraphicsDeviceOptions options, SwapchainDescription? scDesc, VulkanDeviceOptions vkOptions)
		{
			VulkanNative.Initialize();
			VulkanNative.LoadPreInstanceFunctions();
			CreateInstance(options.Debug, vkOptions, scope (instance) =>
				{
					VulkanNative.LoadInstanceFunctions(instance);
					VulkanNative.LoadPostInstanceFunctions();
				});

			VkSurfaceKHR surface = VkSurfaceKHR.Null;
			if (scDesc != null)
			{
				surface = VKSurfaceUtil.CreateSurface(this, _instance, scDesc.Value.Source);
			}

			CreatePhysicalDevice();
			CreateLogicalDevice(surface, options.PreferStandardClipSpaceYDirection, vkOptions);

			_memoryManager = new VKDeviceMemoryManager(
				_device,
				_physicalDevice,
				_physicalDeviceProperties.limits.bufferImageGranularity,
				_getBufferMemoryRequirements2,
				_getImageMemoryRequirements2);

			Features = new GraphicsDeviceFeatures(
				computeShader: true,
				geometryShader: _physicalDeviceFeatures.geometryShader,
				tessellationShaders: _physicalDeviceFeatures.tessellationShader,
				multipleViewports: _physicalDeviceFeatures.multiViewport,
				samplerLodBias: true,
				drawBaseVertex: true,
				drawBaseInstance: true,
				drawIndirect: true,
				drawIndirectBaseInstance: _physicalDeviceFeatures.drawIndirectFirstInstance,
				fillModeWireframe: _physicalDeviceFeatures.fillModeNonSolid,
				samplerAnisotropy: _physicalDeviceFeatures.samplerAnisotropy,
				depthClipDisable: _physicalDeviceFeatures.depthClamp,
				texture1D: true,
				independentBlend: _physicalDeviceFeatures.independentBlend,
				structuredBuffer: true,
				subsetTextureView: true,
				commandListDebugMarkers: _debugMarkerEnabled,
				bufferRangeBinding: true,
				shaderFloat64: _physicalDeviceFeatures.shaderFloat64);

			ResourceFactory = new VKResourceFactory(this);

			if (scDesc != null)
			{
				SwapchainDescription desc = scDesc.Value;
				_mainSwapchain = new VKSwapchain(this, desc, surface);
			}

			CreateDescriptorPool();
			CreateGraphicsCommandPool();
			for (int i = 0; i < SharedCommandPoolCount; i++)
			{
				_sharedGraphicsCommandPools.Push(new SharedCommandPool(this, true));
			}

			_vulkanInfo = new BackendInfoVulkan(this);

			PostDeviceCreated();
		}

		public override ResourceFactory ResourceFactory { get; protected set; }

		protected override void SubmitCommandsCore(CommandList cl, Fence fence)
		{
			SubmitCommandList(cl, 0, null, 0, null, fence);
		}

		private void SubmitCommandList(
			CommandList cl,
			uint32 waitSemaphoreCount,
			VkSemaphore* waitSemaphoresPtr,
			uint32 signalSemaphoreCount,
			VkSemaphore* signalSemaphoresPtr,
			Fence fence)
		{
			VKCommandList vkCL = Util.AssertSubtype<CommandList, VKCommandList>(cl);
			VkCommandBuffer vkCB = vkCL.CommandBuffer;

			vkCL.CommandBufferSubmitted(vkCB);
			SubmitCommandBuffer(vkCL, vkCB, waitSemaphoreCount, waitSemaphoresPtr, signalSemaphoreCount, signalSemaphoresPtr, fence);
		}

		private void SubmitCommandBuffer(
			VKCommandList vkCL,
			VkCommandBuffer vkCB,
			uint32 waitSemaphoreCount,
			VkSemaphore* waitSemaphoresPtr,
			uint32 signalSemaphoreCount,
			VkSemaphore* signalSemaphoresPtr,
			Fence fence)
		{
			var vkCB;
			CheckSubmittedFences();

			bool useExtraFence = fence != null;
			VkSubmitInfo si = VkSubmitInfo() { sType = .VK_STRUCTURE_TYPE_SUBMIT_INFO };
			si.commandBufferCount = 1;
			si.pCommandBuffers = &vkCB;
			VkPipelineStageFlags waitDstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
			si.pWaitDstStageMask = &waitDstStageMask;

			si.pWaitSemaphores = waitSemaphoresPtr;
			si.waitSemaphoreCount = waitSemaphoreCount;
			si.pSignalSemaphores = signalSemaphoresPtr;
			si.signalSemaphoreCount = signalSemaphoreCount;

			VkFence vkFence = .Null;
			VkFence submissionFence = .Null;
			if (useExtraFence)
			{
				vkFence = Util.AssertSubtype<Fence, VKFence>(fence).DeviceFence;
				submissionFence = GetFreeSubmissionFence();
			}
			else
			{
				vkFence = GetFreeSubmissionFence();
				submissionFence = vkFence;
			}

			using (_graphicsQueueLock.Enter())
			{
				VkResult result = vkQueueSubmit(_graphicsQueue, 1, &si, vkFence);
				CheckResult(result);
				if (useExtraFence)
				{
					result = vkQueueSubmit(_graphicsQueue, 0, null, submissionFence);
					CheckResult(result);
				}
			}

			using (_submittedFencesLock.Enter())
			{
				_submittedFences.Add(FenceSubmissionInfo(submissionFence, vkCL, vkCB));
			}
		}

		private void CheckSubmittedFences()
		{
			using (_submittedFencesLock.Enter())
			{
				for (int32 i = 0; i < _submittedFences.Count; i++)
				{
					FenceSubmissionInfo fsi = _submittedFences[i];
					if (vkGetFenceStatus(_device, fsi.Fence) == VkResult.VK_SUCCESS)
					{
						CompleteFenceSubmission(fsi);
						_submittedFences.RemoveAt(i);
						i -= 1;
					}
					else
					{
						break; // Submissions are in order; later submissions cannot complete if this one hasn't.
					}
				}
			}
		}

		private void CompleteFenceSubmission(FenceSubmissionInfo fsi)
		{
			VkFence fence = fsi.Fence;
			VkCommandBuffer completedCB = fsi.CommandBuffer;
			fsi.CommandList?.CommandBufferCompleted(completedCB);
			VkResult resetResult = vkResetFences(_device, 1, &fence);
			CheckResult(resetResult);
			ReturnSubmissionFence(fence);
			using (_stagingResourcesLock.Enter())
			{
				if (_submittedStagingTextures.TryGetValue(completedCB, var stagingTex))
				{
					_submittedStagingTextures.Remove(completedCB);
					_availableStagingTextures.Add(stagingTex);
				}
				if (_submittedStagingBuffers.TryGetValue(completedCB, var stagingBuffer))
				{
					_submittedStagingBuffers.Remove(completedCB);
					if (stagingBuffer.SizeInBytes <= MaxStagingBufferSize)
					{
						_availableStagingBuffers.Add(stagingBuffer);
					}
					else
					{
						stagingBuffer.Dispose();
					}
				}
				if (_submittedSharedCommandPools.TryGetValue(completedCB, var sharedPool))
				{
					_submittedSharedCommandPools.Remove(completedCB);
					using (_graphicsCommandPoolLock.Enter())
					{
						if (sharedPool.IsCached)
						{
							_sharedGraphicsCommandPools.Push(sharedPool);
						}
						else
						{
							sharedPool.Destroy();
						}
					}
				}
			}
		}

		private void ReturnSubmissionFence(VkFence fence)
		{
			using (_availableSubmissionFencesLock.Enter())
			{
				_availableSubmissionFences.Add(fence);
			}
		}

		private VkFence GetFreeSubmissionFence()
		{
			using (_availableSubmissionFencesLock.Enter())
			{
				if (_availableSubmissionFences.TryPopFront() case .Ok(VkFence availableFence))
				{
					return availableFence;
				}
				else
				{
					VkFenceCreateInfo fenceCI = VkFenceCreateInfo() { sType = .VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
					VkFence newFence = .Null;
					VkResult result = vkCreateFence(_device, &fenceCI, null, &newFence);
					CheckResult(result);
					return newFence;
				}
			}
		}

		protected override void SwapBuffersCore(Swapchain swapchain)
		{
			VKSwapchain vkSC = Util.AssertSubtype<Swapchain, VKSwapchain>(swapchain);
			VkSwapchainKHR deviceSwapchain = vkSC.DeviceSwapchain;
			VkPresentInfoKHR presentInfo = VkPresentInfoKHR() { sType = .VK_STRUCTURE_TYPE_PRESENT_INFO_KHR };
			presentInfo.swapchainCount = 1;
			presentInfo.pSwapchains = &deviceSwapchain;
			uint32 imageIndex = vkSC.ImageIndex;
			presentInfo.pImageIndices = &imageIndex;

			Monitor presentLock = vkSC.PresentQueueIndex == _graphicsQueueIndex ? _graphicsQueueLock : vkSC.PresentLock;
			using (presentLock.Enter())
			{
				vkQueuePresentKHR(vkSC.PresentQueue, &presentInfo);
				if (vkSC.AcquireNextImage(_device, VkSemaphore.Null, vkSC.ImageAvailableFence))
				{
					VkFence fence = vkSC.ImageAvailableFence;
					vkWaitForFences(_device, 1, &fence, true, uint64.MaxValue);
					vkResetFences(_device, 1, &fence);
				}
			}
		}

		internal void SetResourceName(DeviceResource resource, String name)
		{
			if (_debugMarkerEnabled)
			{
				switch (resource)
				{
				case resource as VKBuffer: //case VKBuffer buffer:
					var buffer = (VKBuffer)_;
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_BUFFER_EXT, buffer.DeviceBuffer.Handle, name);
					break;
				case resource as VKCommandList: //case VKCommandList commandList:
					var commandList = (VKCommandList)_;
					SetDebugMarkerName(
						VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_BUFFER_EXT,
						(uint64)commandList.CommandBuffer.Handle,
scope $"{name}_CommandBuffer"						);
					SetDebugMarkerName(
						VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_POOL_EXT,
						commandList.CommandPool.Handle,
scope $"{name}_CommandPool"						);
					break;
				case resource as VKFramebuffer: //case VKFramebuffer framebuffer:
					var framebuffer = (VKFramebuffer)_;
					SetDebugMarkerName(
						VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_FRAMEBUFFER_EXT,
						framebuffer.CurrentFramebuffer.Handle,
						name);
					break;
				case resource as VKPipeline: //case VKPipeline pipeline:
					var pipeline = (VKPipeline)_;
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_EXT, pipeline.DevicePipeline.Handle, name);
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_LAYOUT_EXT, pipeline.PipelineLayout.Handle, name);
					break;
				case resource as VKResourceLayout: //case VKResourceLayout resourceLayout:
					var resourceLayout = (VKResourceLayout)_;
					SetDebugMarkerName(
						VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT_EXT,
						resourceLayout.DescriptorSetLayout.Handle,
						name);
					break;
				case resource as VKResourceSet: //case VKResourceSet resourceSet:
					var resourceSet = (VKResourceSet)_;
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_SET_EXT, resourceSet.DescriptorSet.Handle, name);
					break;
				case resource as VKSampler: //case VKSampler sampler:
					var sampler = (VKSampler)_;
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_SAMPLER_EXT, sampler.DeviceSampler.Handle, name);
					break;
				case resource as VKShader: //case VKShader shader:
					var shader = (VKShader)_;
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_SHADER_MODULE_EXT, shader.ShaderModule.Handle, name);
					break;
				case resource as VKTexture: //case VKTexture tex:
					var tex = (VKTexture)_;
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_EXT, tex.OptimalDeviceImage.Handle, name);
					break;
				case resource as VKTextureView: //case VKTextureView texView:
					var texView = (VKTextureView)_;
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_VIEW_EXT, texView.ImageView.Handle, name);
					break;
				case resource as VKFence: //case VKFence fence:
					var fence = (VKFence)_;
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_FENCE_EXT, fence.DeviceFence.Handle, name);
					break;
				case resource as VKSwapchain: //case VKSwapchain sc:
					var sc = (VKSwapchain)_;
					SetDebugMarkerName(VkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_SWAPCHAIN_KHR_EXT, sc.DeviceSwapchain.Handle, name);
					break;
				default:
					break;
				}
			}
		}

		private void SetDebugMarkerName(VkDebugReportObjectTypeEXT type, uint64 target, String name)
		{
			Debug.Assert(_setObjectNameDelegate != null);

			VkDebugMarkerObjectNameInfoEXT nameInfo = VkDebugMarkerObjectNameInfoEXT() { sType = .VK_STRUCTURE_TYPE_DEBUG_MARKER_OBJECT_NAME_INFO_EXT };
			nameInfo.objectType = type;
			nameInfo.object = target;

			nameInfo.pObjectName = scope String(name).CStr();
			VkResult result = _setObjectNameDelegate(_device, &nameInfo);
			CheckResult(result);
		}

		private void CreateInstance(bool debug, VulkanDeviceOptions options, delegate void(VkInstance) onInstanceCreated = null)
		{
			List<String> availableInstanceLayers = EnumerateInstanceLayers(.. new .());
			defer { DeleteContainerAndItems!(availableInstanceLayers); }

			List<String> availableInstanceExtensions = GetInstanceExtensions(.. new .());
			defer { DeleteContainerAndItems!(availableInstanceExtensions); }

			VkInstanceCreateInfo instanceCI = VkInstanceCreateInfo() { sType = .VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO };
			VkApplicationInfo applicationInfo = VkApplicationInfo() { sType = .VK_STRUCTURE_TYPE_APPLICATION_INFO };
			applicationInfo.apiVersion = VulkanNative.VK_API_VERSION_1_0;
			applicationInfo.applicationVersion = VulkanNative.VK_API_VERSION_1_0;
			applicationInfo.engineVersion = VulkanNative.VK_API_VERSION_1_0;
			applicationInfo.pApplicationName = s_name;
			applicationInfo.pEngineName = s_name;

			instanceCI.pApplicationInfo = &applicationInfo;

			List<char8*> instanceExtensions = scope .();
			List<char8*> instanceLayers = scope .();

			if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_portability_subset))
			{
				_surfaceExtensions.Add(CommonStrings.VK_KHR_portability_subset);
			}

			if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_portability_enumeration))
			{
				instanceExtensions.Add(CommonStrings.VK_KHR_portability_enumeration);
				instanceCI.flags |= .VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
			}

			if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_SURFACE_EXTENSION_NAME))
			{
				_surfaceExtensions.Add(CommonStrings.VK_KHR_SURFACE_EXTENSION_NAME);
			}

			if (OperatingSystem.IsWindows())
			{
				if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_WIN32_SURFACE_EXTENSION_NAME))
				{
					_surfaceExtensions.Add(CommonStrings.VK_KHR_WIN32_SURFACE_EXTENSION_NAME);
				}
			}
			else if (OperatingSystem.IsAndroid() || OperatingSystem.IsLinux())
			{
				if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_ANDROID_SURFACE_EXTENSION_NAME))
				{
					_surfaceExtensions.Add(CommonStrings.VK_KHR_ANDROID_SURFACE_EXTENSION_NAME);
				}
				if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_XLIB_SURFACE_EXTENSION_NAME))
				{
					_surfaceExtensions.Add(CommonStrings.VK_KHR_XLIB_SURFACE_EXTENSION_NAME);
				}
				if (availableInstanceExtensions.Contains(CommonStrings.VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME))
				{
					_surfaceExtensions.Add(CommonStrings.VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME);
				}
			}
			else if (OperatingSystem.IsMacOS())
			{
				if (availableInstanceExtensions.Contains(CommonStrings.VK_EXT_METAL_SURFACE_EXTENSION_NAME))
				{
					_surfaceExtensions.Add(CommonStrings.VK_EXT_METAL_SURFACE_EXTENSION_NAME);
				}
				else // Legacy MoltenVK extensions
				{
					if (availableInstanceExtensions.Contains(CommonStrings.VK_MVK_MACOS_SURFACE_EXTENSION_NAME))
					{
						_surfaceExtensions.Add(CommonStrings.VK_MVK_MACOS_SURFACE_EXTENSION_NAME);
					}
					if (availableInstanceExtensions.Contains(CommonStrings.VK_MVK_IOS_SURFACE_EXTENSION_NAME))
					{
						_surfaceExtensions.Add(CommonStrings.VK_MVK_IOS_SURFACE_EXTENSION_NAME);
					}
				}
			}

			for (var ext in _surfaceExtensions)
			{
				instanceExtensions.Add(ext);
			}

			bool hasDeviceProperties2 = availableInstanceExtensions.Contains(CommonStrings.VK_KHR_get_physical_device_properties2);
			if (hasDeviceProperties2)
			{
				instanceExtensions.Add(CommonStrings.VK_KHR_get_physical_device_properties2);
			}

			List<String> requestedInstanceExtensions =  scope .();
			requestedInstanceExtensions.AddRange(options.InstanceExtensions);

			for (String requiredExt in requestedInstanceExtensions)
			{
				if (!availableInstanceExtensions.Contains(requiredExt))
				{
					Runtime.GALError(scope $"The required instance extension was not available: {requiredExt}");
				}

				instanceExtensions.Add(requiredExt);
			}

			bool debugReportExtensionAvailable = false;
			if (debug)
			{
				if (availableInstanceExtensions.Contains(CommonStrings.VK_EXT_DEBUG_REPORT_EXTENSION_NAME))
				{
					debugReportExtensionAvailable = true;
					instanceExtensions.Add(CommonStrings.VK_EXT_DEBUG_REPORT_EXTENSION_NAME);
				}
				if (availableInstanceLayers.Contains(CommonStrings.StandardValidationLayerName))
				{
					_standardValidationSupported = true;
					instanceLayers.Add(CommonStrings.StandardValidationLayerName);
				}
				if (availableInstanceLayers.Contains(CommonStrings.KhronosValidationLayerName))
				{
					_khronosValidationSupported = true;
					instanceLayers.Add(CommonStrings.KhronosValidationLayerName);
				}
			}

			instanceCI.enabledExtensionCount = (uint32)instanceExtensions.Count;
			instanceCI.ppEnabledExtensionNames = instanceExtensions.Ptr;

			instanceCI.enabledLayerCount = (uint32)instanceLayers.Count;
			if (instanceLayers.Count > 0)
			{
				instanceCI.ppEnabledLayerNames = instanceLayers.Ptr;
			}

			VkResult result = vkCreateInstance(&instanceCI, null, &_instance);
			CheckResult(result);

			if (onInstanceCreated != null)
			{
				onInstanceCreated(_instance);
			}

			if (HasSurfaceExtension(CommonStrings.VK_EXT_METAL_SURFACE_EXTENSION_NAME))
			{
				_createMetalSurfaceEXT = VulkanNative.[Friend]vkCreateMetalSurfaceEXT_ptr; // GetInstanceProcAddr<vkCreateMetalSurfaceEXT_t>("vkCreateMetalSurfaceEXT");
			}

			if (debug && debugReportExtensionAvailable)
			{
				EnableDebugCallback();
			}

			if (hasDeviceProperties2)
			{
				/*_getPhysicalDeviceProperties2 = GetInstanceProcAddr<vkGetPhysicalDeviceProperties2_t>("vkGetPhysicalDeviceProperties2")
					?? GetInstanceProcAddr<vkGetPhysicalDeviceProperties2_t>("vkGetPhysicalDeviceProperties2KHR");*/
				_getPhysicalDeviceProperties2 = (vkGetPhysicalDeviceProperties2_t)(void*)VulkanNative.[Friend]vkGetPhysicalDeviceProperties2_ptr;
			}
		}

		public bool HasSurfaceExtension(String @extension)
		{
			return _surfaceExtensions.Contains(@extension);
		}

		public void EnableDebugCallback(VkDebugReportFlagsEXT flags = VkDebugReportFlagsEXT.VK_DEBUG_REPORT_WARNING_BIT_EXT | VkDebugReportFlagsEXT.VK_DEBUG_REPORT_ERROR_BIT_EXT)
		{
			Debug.WriteLine("Enabling Vulkan Debug callbacks.");
			_debugCallbackFunc = => DebugCallback;
			VkDebugReportCallbackCreateInfoEXT debugCallbackCI = VkDebugReportCallbackCreateInfoEXT() { sType = .VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT };
			debugCallbackCI.flags = flags;
			debugCallbackCI.pfnCallback = _debugCallbackFunc;
			void* createFnPtr = null;
			char8* debugExtFnName = "vkCreateDebugReportCallbackEXT";
			createFnPtr = vkGetInstanceProcAddr(_instance, debugExtFnName);
			if (createFnPtr == null)
			{
				return;
			}

			vkCreateDebugReportCallbackEXT_d createDelegate = (vkCreateDebugReportCallbackEXT_d)createFnPtr;
			VkResult result = createDelegate(_instance, &debugCallbackCI, null, out _debugCallbackHandle);
			CheckResult(result);
		}

		private static VkBool32 DebugCallback(
			uint32 flags,
			VkDebugReportObjectTypeEXT objectType,
			uint64 object,
			uint location,
			int32 messageCode,
			char8* pLayerPrefix,
			char8* pMessage,
			void* pUserData)
		{
			String message = scope .(pMessage);
			VkDebugReportFlagsEXT debugReportFlags = (VkDebugReportFlagsEXT)flags;

#if DEBUG
			if (Debug.IsDebuggerPresent)
			{
				Debug.Break();
			}
#endif

			String fullMessage = scope $"[{debugReportFlags}] ({objectType}) {message}";

			if (debugReportFlags == VkDebugReportFlagsEXT.VK_DEBUG_REPORT_ERROR_BIT_EXT)
			{
				Runtime.GALError(scope $"A Vulkan validation error was encountered: {fullMessage}");
			}

			Console.WriteLine(fullMessage);
			return 0;
		}

		private void CreatePhysicalDevice()
		{
			uint32 deviceCount = 0;
			vkEnumeratePhysicalDevices(_instance, &deviceCount, null);
			if (deviceCount == 0)
			{
				Runtime.InvalidOperationError("No physical devices exist.");
			}

			VkPhysicalDevice[] physicalDevices = scope VkPhysicalDevice[deviceCount];
			vkEnumeratePhysicalDevices(_instance, &deviceCount, physicalDevices.Ptr);
			// Just use the first one.
			_physicalDevice = physicalDevices[0];

			vkGetPhysicalDeviceProperties(_physicalDevice, &_physicalDeviceProperties);
			_deviceName = new .(&_physicalDeviceProperties.deviceName);

			_vendorName = new String(scope $"id:{_physicalDeviceProperties.vendorID:x8}");
			_apiVersion = GraphicsApiVersion.Unknown;
			_driverInfo = new String(scope $"version:{_physicalDeviceProperties.driverVersion:x8}");

			vkGetPhysicalDeviceFeatures(_physicalDevice, &_physicalDeviceFeatures);

			vkGetPhysicalDeviceMemoryProperties(_physicalDevice, &_physicalDeviceMemProperties);
		}

		public void GetDeviceExtensionProperties(List<VkExtensionProperties> props)
		{
			uint32 propertyCount = 0;
			VkResult result = vkEnumerateDeviceExtensionProperties(_physicalDevice, null, &propertyCount, null);
			CheckResult(result);
			props.Resize((int32)propertyCount);
			result = vkEnumerateDeviceExtensionProperties(_physicalDevice, null, &propertyCount, props.Ptr);
			CheckResult(result);
		}

		private void CreateLogicalDevice(VkSurfaceKHR surface, bool preferStandardClipY, VulkanDeviceOptions options)
		{
			GetQueueFamilyIndices(surface);

			HashSet<uint32> familyIndices = scope HashSet<uint32>() { _graphicsQueueIndex, _presentQueueIndex };
			VkDeviceQueueCreateInfo* queueCreateInfos = scope VkDeviceQueueCreateInfo[familyIndices.Count]*;
			uint32 queueCreateInfosCount = (uint32)familyIndices.Count;

			int32 i = 0;
			for (uint32 index in familyIndices)
			{
				VkDeviceQueueCreateInfo queueCreateInfo = VkDeviceQueueCreateInfo() { sType = .VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO };
				queueCreateInfo.queueFamilyIndex = _graphicsQueueIndex;
				queueCreateInfo.queueCount = 1;
				float priority = 1f;
				queueCreateInfo.pQueuePriorities = &priority;
				queueCreateInfos[i] = queueCreateInfo;
				i += 1;
			}

			VkPhysicalDeviceFeatures deviceFeatures = _physicalDeviceFeatures;

			List<VkExtensionProperties> properties = GetDeviceExtensionProperties(.. scope .());

			HashSet<String> requiredInstanceExtensions = scope .();
			for (var str in options.DeviceExtensions)
			{
				requiredInstanceExtensions.Add(str);
			}

			bool hasMemReqs2 = false;
			bool hasDedicatedAllocation = false;
			bool hasDriverProperties = false;
			char8*[] activeExtensions = scope .[properties.Count];
			uint32 activeExtensionCount = 0;

			for (int property = 0; property < properties.Count; property++)
			{
				String extensionName = scope:: String(&properties[property].extensionName);
				if (extensionName == "VK_EXT_debug_marker")
				{
					activeExtensions[activeExtensionCount++] = CommonStrings.VK_EXT_DEBUG_MARKER_EXTENSION_NAME;
					requiredInstanceExtensions.Remove(extensionName);
					_debugMarkerEnabled = true;
				}
				else if (extensionName == "VK_KHR_swapchain")
				{
					activeExtensions[activeExtensionCount++] = extensionName;
					requiredInstanceExtensions.Remove(extensionName);
				}
				else if (preferStandardClipY && extensionName == "VK_KHR_maintenance1")
				{
					activeExtensions[activeExtensionCount++] = extensionName;
					requiredInstanceExtensions.Remove(extensionName);
					_standardClipYDirection = true;
				}
				else if (extensionName == "VK_KHR_get_memory_requirements2")
				{
					activeExtensions[activeExtensionCount++] = extensionName;
					requiredInstanceExtensions.Remove(extensionName);
					hasMemReqs2 = true;
				}
				else if (extensionName == "VK_KHR_dedicated_allocation")
				{
					activeExtensions[activeExtensionCount++] = extensionName;
					requiredInstanceExtensions.Remove(extensionName);
					hasDedicatedAllocation = true;
				}
				else if (extensionName == "VK_KHR_driver_properties")
				{
					activeExtensions[activeExtensionCount++] = extensionName;
					requiredInstanceExtensions.Remove(extensionName);
					hasDriverProperties = true;
				}
				else if (extensionName == CommonStrings.VK_KHR_portability_subset)
				{
					activeExtensions[activeExtensionCount++] = extensionName;
					requiredInstanceExtensions.Remove(extensionName);
				}
				else if (requiredInstanceExtensions.Remove(extensionName))
				{
					activeExtensions[activeExtensionCount++] = extensionName;
				}
			}

			if (requiredInstanceExtensions.Count != 0)
			{
				String missingList = scope String()..Join(", ", requiredInstanceExtensions.GetEnumerator());
				Runtime.GALError(
scope $"The following Vulkan device extensions were not available: {missingList}"					);
			}

			VkDeviceCreateInfo deviceCreateInfo = VkDeviceCreateInfo() { sType = .VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO };
			deviceCreateInfo.queueCreateInfoCount = queueCreateInfosCount;
			deviceCreateInfo.pQueueCreateInfos = queueCreateInfos;

			deviceCreateInfo.pEnabledFeatures = &deviceFeatures;

			List<char8*> layerNames = scope .();
			if (_standardValidationSupported)
			{
				layerNames.Add(CommonStrings.StandardValidationLayerName);
			}
			if (_khronosValidationSupported)
			{
				layerNames.Add(CommonStrings.KhronosValidationLayerName);
			}
			deviceCreateInfo.enabledLayerCount = (uint32)layerNames.Count;
			deviceCreateInfo.ppEnabledLayerNames = layerNames.Ptr;

			deviceCreateInfo.enabledExtensionCount = activeExtensionCount;
			deviceCreateInfo.ppEnabledExtensionNames = activeExtensions.Ptr;

			VkResult result = vkCreateDevice(_physicalDevice, &deviceCreateInfo, null, &_device);
			CheckResult(result);

			vkGetDeviceQueue(_device, _graphicsQueueIndex, 0, &_graphicsQueue);

			if (_debugMarkerEnabled)
			{
				_setObjectNameDelegate = VulkanNative.[Friend]vkDebugMarkerSetObjectNameEXT_ptr; // Marshal.GetDelegateForFunctionPointer<vkDebugMarkerSetObjectNameEXT_t>(GetInstanceProcAddr("vkDebugMarkerSetObjectNameEXT"));
				_markerBegin = VulkanNative.[Friend]vkCmdDebugMarkerBeginEXT_ptr; //Marshal.GetDelegateForFunctionPointer<vkCmdDebugMarkerBeginEXT_t>(GetInstanceProcAddr("vkCmdDebugMarkerBeginEXT"));
				_markerEnd = VulkanNative.[Friend]vkCmdDebugMarkerEndEXT_ptr; //Marshal.GetDelegateForFunctionPointer<vkCmdDebugMarkerEndEXT_t>(GetInstanceProcAddr("vkCmdDebugMarkerEndEXT"));
				_markerInsert = VulkanNative.[Friend]vkCmdDebugMarkerInsertEXT_ptr; //Marshal.GetDelegateForFunctionPointer<vkCmdDebugMarkerInsertEXT_t>(GetInstanceProcAddr("vkCmdDebugMarkerInsertEXT"));
			}
			if (hasDedicatedAllocation && hasMemReqs2)
			{
				_getBufferMemoryRequirements2 = VulkanNative.[Friend]vkGetBufferMemoryRequirements2_ptr; // GetDeviceProcAddr<vkGetBufferMemoryRequirements2_t>("vkGetBufferMemoryRequirements2") ?? GetDeviceProcAddr<vkGetBufferMemoryRequirements2_t>("vkGetBufferMemoryRequirements2KHR");
				_getImageMemoryRequirements2 = VulkanNative.[Friend]vkGetImageMemoryRequirements2_ptr; // GetDeviceProcAddr<vkGetImageMemoryRequirements2_t>("vkGetImageMemoryRequirements2") ?? GetDeviceProcAddr<vkGetImageMemoryRequirements2_t>("vkGetImageMemoryRequirements2KHR");
			}
			if (_getPhysicalDeviceProperties2 != null && hasDriverProperties)
			{
				VkPhysicalDeviceProperties2 deviceProps = VkPhysicalDeviceProperties2() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2 };
				VkPhysicalDeviceDriverProperties driverProps = VkPhysicalDeviceDriverProperties() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRIVER_PROPERTIES };

				deviceProps.pNext = &driverProps;
				_getPhysicalDeviceProperties2(_physicalDevice, &deviceProps);

				String driverName = new String(&driverProps.driverName);

				String driverInfo = new String(&driverProps.driverInfo);

				VkConformanceVersion conforming = driverProps.conformanceVersion;
				_apiVersion = GraphicsApiVersion(conforming.major, conforming.minor, conforming.subminor, conforming.patch);
				_driverName = driverName;
				_driverInfo = driverInfo;
			}
		}

		/*private IntPtr GetInstanceProcAddr(string name)
		{
			int32 byteCount = Encoding.UTF8.GetByteCount(name);
			uint8* utf8Ptr = stackalloc uint8[byteCount + 1];

			fixed (char* namePtr = name)
			{
				Encoding.UTF8.GetBytes(namePtr, name.Length, utf8Ptr, byteCount);
			}
			utf8Ptr[byteCount] = 0;

			return vkGetInstanceProcAddr(_instance, utf8Ptr);
		}

		private T GetInstanceProcAddr<T>(string name)
		{
			IntPtr funcPtr = GetInstanceProcAddr(name);
			if (funcPtr != IntPtr.Zero)
			{
				return Marshal.GetDelegateForFunctionPointer<T>(funcPtr);
			}
			return default;
		}

		private IntPtr GetDeviceProcAddr(string name)
		{
			int32 byteCount = Encoding.UTF8.GetByteCount(name);
			uint8* utf8Ptr = stackalloc uint8[byteCount + 1];

			fixed (char* namePtr = name)
			{
				Encoding.UTF8.GetBytes(namePtr, name.Length, utf8Ptr, byteCount);
			}
			utf8Ptr[byteCount] = 0;

			return vkGetDeviceProcAddr(_device, utf8Ptr);
		}

		private T GetDeviceProcAddr<T>(string name)
		{
			IntPtr funcPtr = GetDeviceProcAddr(name);
			if (funcPtr != IntPtr.Zero)
			{
				return Marshal.GetDelegateForFunctionPointer<T>(funcPtr);
			}
			return default;
		}*/

		private void GetQueueFamilyIndices(VkSurfaceKHR surface)
		{
			uint32 queueFamilyCount = 0;
			vkGetPhysicalDeviceQueueFamilyProperties(_physicalDevice, &queueFamilyCount, null);
			VkQueueFamilyProperties[] qfp = scope VkQueueFamilyProperties[queueFamilyCount];
			vkGetPhysicalDeviceQueueFamilyProperties(_physicalDevice, &queueFamilyCount, qfp.Ptr);

			bool foundGraphics = false;
			bool foundPresent = surface == VkSurfaceKHR.Null;

			for (uint32 i = 0; i < qfp.Count; i++)
			{
				if ((qfp[i].queueFlags & VkQueueFlags.VK_QUEUE_GRAPHICS_BIT) != 0)
				{
					_graphicsQueueIndex = i;
					foundGraphics = true;
				}

				if (!foundPresent)
				{
					VkBool32 presentSupported = false;
					vkGetPhysicalDeviceSurfaceSupportKHR(_physicalDevice, i, surface, &presentSupported);
					if (presentSupported)
					{
						_presentQueueIndex = i;
						foundPresent = true;
					}
				}

				if (foundGraphics && foundPresent)
				{
					return;
				}
			}
		}

		private void CreateDescriptorPool()
		{
			_descriptorPoolManager = new VKDescriptorPoolManager(this);
		}

		private void CreateGraphicsCommandPool()
		{
			VkCommandPoolCreateInfo commandPoolCI = VkCommandPoolCreateInfo() { sType = .VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO };
			commandPoolCI.flags = VkCommandPoolCreateFlags.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
			commandPoolCI.queueFamilyIndex = _graphicsQueueIndex;
			VkResult result = vkCreateCommandPool(_device, &commandPoolCI, null, &_graphicsCommandPool);
			CheckResult(result);
		}

		protected override MappedResource MapCore(MappableResource resource, MapMode mode, uint32 subresource)
		{
			VkMemoryBlock memoryBlock = default(VkMemoryBlock);
			void* mappedPtr = null;
			uint32 sizeInBytes;
			uint32 offset = 0;
			uint32 rowPitch = 0;
			uint32 depthPitch = 0;
			if (let buffer = resource as VKBuffer)
			{
				memoryBlock = buffer.Memory;
				sizeInBytes = buffer.SizeInBytes;
			}
			else
			{
				VKTexture texture = Util.AssertSubtype<MappableResource, VKTexture>(resource);
				VkSubresourceLayout layout = texture.GetSubresourceLayout(subresource);
				memoryBlock = texture.Memory;
				sizeInBytes = (uint32)layout.size;
				offset = (uint32)layout.offset;
				rowPitch = (uint32)layout.rowPitch;
				depthPitch = (uint32)layout.depthPitch;
			}

			if (memoryBlock.DeviceMemory.Handle != 0)
			{
				if (memoryBlock.IsPersistentMapped)
				{
					mappedPtr = memoryBlock.BlockMappedPointer;
				}
				else
				{
					mappedPtr = _memoryManager.Map(memoryBlock);
				}
			}

			uint8* dataPtr = (uint8*)mappedPtr + offset;
			return MappedResource(
				resource,
				mode,
				dataPtr,
				sizeInBytes,
				subresource,
				rowPitch,
				depthPitch);
		}

		protected override void UnmapCore(MappableResource resource, uint32 subresource)
		{
			VkMemoryBlock memoryBlock = default(VkMemoryBlock);
			if (let buffer = resource as VKBuffer)
			{
				memoryBlock = buffer.Memory;
			}
			else
			{
				VKTexture tex = Util.AssertSubtype<MappableResource, VKTexture>(resource);
				memoryBlock = tex.Memory;
			}

			if (memoryBlock.DeviceMemory.Handle != 0 && !memoryBlock.IsPersistentMapped)
			{
				vkUnmapMemory(_device, memoryBlock.DeviceMemory);
			}
		}

		protected override void PlatformDispose()
		{
			Debug.Assert(_submittedFences.Count == 0);
			for (VkFence fence in _availableSubmissionFences)
			{
				vkDestroyFence(_device, fence, null);
			}

			_mainSwapchain?.Dispose();
			if (_debugCallbackFunc != null)
			{
				_debugCallbackFunc = null;
				String debugExtFnName = "vkDestroyDebugReportCallbackEXT";
				void* destroyFuncPtr = vkGetInstanceProcAddr(_instance, debugExtFnName);
				vkDestroyDebugReportCallbackEXT_d destroyDel = (vkDestroyDebugReportCallbackEXT_d)destroyFuncPtr;
				destroyDel(_instance, _debugCallbackHandle, null);
			}

			_descriptorPoolManager.DestroyAll();
			vkDestroyCommandPool(_device, _graphicsCommandPool, null);

			Debug.Assert(_submittedStagingTextures.Count == 0);
			for (VKTexture tex in _availableStagingTextures)
			{
				tex.Dispose();
			}

			Debug.Assert(_submittedStagingBuffers.Count == 0);
			for (VKBuffer buffer in _availableStagingBuffers)
			{
				buffer.Dispose();
			}

			using (_graphicsCommandPoolLock.Enter())
			{
				while (_sharedGraphicsCommandPools.Count > 0)
				{
					SharedCommandPool sharedPool = _sharedGraphicsCommandPools.Pop();
					sharedPool.Destroy();
				}
			}

			_memoryManager.Dispose();

			VkResult result = vkDeviceWaitIdle(_device);
			CheckResult(result);
			vkDestroyDevice(_device, null);
			vkDestroyInstance(_instance, null);
		}

		protected override void WaitForIdleCore()
		{
			using (_graphicsQueueLock.Enter())
			{
				vkQueueWaitIdle(_graphicsQueue);
			}

			CheckSubmittedFences();
		}

		public override TextureSampleCount GetSampleCountLimit(PixelFormat format, bool depthFormat)
		{
			VkImageUsageFlags usageFlags = VkImageUsageFlags.VK_IMAGE_USAGE_SAMPLED_BIT;
			usageFlags |= depthFormat ? VkImageUsageFlags.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT : VkImageUsageFlags.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;

			VkImageFormatProperties formatProperties = .();
			vkGetPhysicalDeviceImageFormatProperties(
				_physicalDevice,
				VKFormats.VdToVkPixelFormat(format),
				VkImageType.VK_IMAGE_TYPE_2D,
				VkImageTiling.VK_IMAGE_TILING_OPTIMAL,
				usageFlags,
				VkImageCreateFlags.None,
				&formatProperties);

			VkSampleCountFlags vkSampleCounts = formatProperties.sampleCounts;
			if ((vkSampleCounts & VkSampleCountFlags.VK_SAMPLE_COUNT_32_BIT) == VkSampleCountFlags.VK_SAMPLE_COUNT_32_BIT)
			{
				return TextureSampleCount.Count32;
			}
			else if ((vkSampleCounts & VkSampleCountFlags.VK_SAMPLE_COUNT_16_BIT) == VkSampleCountFlags.VK_SAMPLE_COUNT_16_BIT)
			{
				return TextureSampleCount.Count16;
			}
			else if ((vkSampleCounts & VkSampleCountFlags.VK_SAMPLE_COUNT_8_BIT) == VkSampleCountFlags.VK_SAMPLE_COUNT_8_BIT)
			{
				return TextureSampleCount.Count8;
			}
			else if ((vkSampleCounts & VkSampleCountFlags.VK_SAMPLE_COUNT_4_BIT) == VkSampleCountFlags.VK_SAMPLE_COUNT_4_BIT)
			{
				return TextureSampleCount.Count4;
			}
			else if ((vkSampleCounts & VkSampleCountFlags.VK_SAMPLE_COUNT_2_BIT) == VkSampleCountFlags.VK_SAMPLE_COUNT_2_BIT)
			{
				return TextureSampleCount.Count2;
			}

			return TextureSampleCount.Count1;
		}

		protected override bool GetPixelFormatSupportCore(
			PixelFormat format,
			TextureType type,
			TextureUsage usage,
			out PixelFormatProperties properties)
		{
			VkFormat vkFormat = VKFormats.VdToVkPixelFormat(format, (usage & TextureUsage.DepthStencil) != 0);
			VkImageType vkType = VKFormats.VdToVkTextureType(type);
			VkImageTiling tiling = usage == TextureUsage.Staging ? VkImageTiling.VK_IMAGE_TILING_LINEAR : VkImageTiling.VK_IMAGE_TILING_OPTIMAL;
			VkImageUsageFlags vkUsage = VKFormats.VdToVkTextureUsage(usage);

			VkImageFormatProperties vkProps = .();
			VkResult result = vkGetPhysicalDeviceImageFormatProperties(
				_physicalDevice,
				vkFormat,
				vkType,
				tiling,
				vkUsage,
				VkImageCreateFlags.None,
				&vkProps);

			if (result == VkResult.VK_ERROR_FORMAT_NOT_SUPPORTED)
			{
				properties = default(PixelFormatProperties);
				return false;
			}
			CheckResult(result);

			properties = PixelFormatProperties(
				vkProps.maxExtent.width,
				vkProps.maxExtent.height,
				vkProps.maxExtent.depth,
				vkProps.maxMipLevels,
				vkProps.maxArrayLayers,
				(uint32)vkProps.sampleCounts);
			return true;
		}

		internal VkFilter GetFormatFilter(VkFormat format)
		{
			using (_filtersLock.Enter())
			{
				if (!_filters.TryGetValue(format, var filter))
				{
					VkFormatProperties vkFormatProps = .();
					vkGetPhysicalDeviceFormatProperties(_physicalDevice, format, &vkFormatProps);
					filter = (vkFormatProps.optimalTilingFeatures & VkFormatFeatureFlags.VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) != 0
						? VkFilter.VK_FILTER_LINEAR
						: VkFilter.VK_FILTER_NEAREST;
					_filters.TryAdd(format, filter);
				}

				return filter;
			}
		}

		protected override void UpdateBufferCore(DeviceBuffer buffer, uint32 bufferOffsetInBytes, void* source, uint32 sizeInBytes)
		{
			VKBuffer vkBuffer = Util.AssertSubtype<DeviceBuffer, VKBuffer>(buffer);
			VKBuffer copySrcVkBuffer = null;
			void* mappedPtr;
			uint8* destPtr;
			bool isPersistentMapped = vkBuffer.Memory.IsPersistentMapped;
			if (isPersistentMapped)
			{
				mappedPtr = vkBuffer.Memory.BlockMappedPointer;
				destPtr = (uint8*)mappedPtr + bufferOffsetInBytes;
			}
			else
			{
				copySrcVkBuffer = GetFreeStagingBuffer(sizeInBytes);
				mappedPtr = copySrcVkBuffer.Memory.BlockMappedPointer;
				destPtr = (uint8*)mappedPtr;
			}

			Internal.MemCpy(destPtr, source, sizeInBytes);

			if (!isPersistentMapped)
			{
				SharedCommandPool pool = GetFreeCommandPool();
				VkCommandBuffer cb = pool.BeginNewCommandBuffer();

				VkBufferCopy copyRegion = VkBufferCopy()
					{
						dstOffset = bufferOffsetInBytes,
						size = sizeInBytes
					};
				vkCmdCopyBuffer(cb, copySrcVkBuffer.DeviceBuffer, vkBuffer.DeviceBuffer, 1, &copyRegion);

				pool.EndAndSubmit(cb);
				using (_stagingResourcesLock.Enter())
				{
					_submittedStagingBuffers.Add(cb, copySrcVkBuffer);
				}
			}
		}

		private SharedCommandPool GetFreeCommandPool()
		{
			SharedCommandPool sharedPool = null;
			using (_graphicsCommandPoolLock.Enter())
			{
				if (_sharedGraphicsCommandPools.Count > 0)
					sharedPool = _sharedGraphicsCommandPools.Pop();
			}

			if (sharedPool == null)
				sharedPool = new SharedCommandPool(this, false);

			return sharedPool;
		}

		private void* MapBuffer(VKBuffer buffer, uint32 numBytes)
		{
			if (buffer.Memory.IsPersistentMapped)
			{
				return buffer.Memory.BlockMappedPointer;
			}
			else
			{
				void* mappedPtr = null;
				VkResult result = vkMapMemory(Device, buffer.Memory.DeviceMemory, buffer.Memory.Offset, numBytes, 0, &mappedPtr);
				CheckResult(result);
				return mappedPtr;
			}
		}

		private void UnmapBuffer(VKBuffer buffer)
		{
			if (!buffer.Memory.IsPersistentMapped)
			{
				vkUnmapMemory(Device, buffer.Memory.DeviceMemory);
			}
		}

		protected override void UpdateTextureCore(
			Texture texture,
			void* source,
			uint32 sizeInBytes,
			uint32 x,
			uint32 y,
			uint32 z,
			uint32 width,
			uint32 height,
			uint32 depth,
			uint32 mipLevel,
			uint32 arrayLayer)
		{
			VKTexture vkTex = Util.AssertSubtype<Texture, VKTexture>(texture);
			bool isStaging = (vkTex.Usage & TextureUsage.Staging) != 0;
			if (isStaging)
			{
				VkMemoryBlock memBlock = vkTex.Memory;
				uint32 subresource = texture.CalculateSubresource(mipLevel, arrayLayer);
				VkSubresourceLayout layout = vkTex.GetSubresourceLayout(subresource);
				uint8* imageBasePtr = (uint8*)memBlock.BlockMappedPointer + layout.offset;

				uint32 srcRowPitch = FormatHelpers.GetRowPitch(width, texture.Format);
				uint32 srcDepthPitch = FormatHelpers.GetDepthPitch(srcRowPitch, height, texture.Format);
				Util.CopyTextureRegion(
					source,
					0, 0, 0,
					srcRowPitch, srcDepthPitch,
					imageBasePtr,
					x, y, z,
					(uint32)layout.rowPitch, (uint32)layout.depthPitch,
					width, height, depth,
					texture.Format);
			}
			else
			{
				VKTexture stagingTex = GetFreeStagingTexture(width, height, depth, texture.Format);
				UpdateTexture(stagingTex, source, sizeInBytes, 0, 0, 0, width, height, depth, 0, 0);
				SharedCommandPool pool = GetFreeCommandPool();
				VkCommandBuffer cb = pool.BeginNewCommandBuffer();
				VKCommandList.CopyTextureCore_VkCommandBuffer(
					cb,
					stagingTex, 0, 0, 0, 0, 0,
					texture, x, y, z, mipLevel, arrayLayer,
					width, height, depth, 1);
				using (_stagingResourcesLock.Enter())
				{
					_submittedStagingTextures.Add(cb, stagingTex);
				}
				pool.EndAndSubmit(cb);
			}
		}

		private VKTexture GetFreeStagingTexture(uint32 width, uint32 height, uint32 depth, PixelFormat format)
		{
			uint32 totalSize = FormatHelpers.GetRegionSize(width, height, depth, format);
			using (_stagingResourcesLock.Enter())
			{
				for (int32 i = 0; i < _availableStagingTextures.Count; i++)
				{
					VKTexture tex = _availableStagingTextures[i];
					if (tex.Memory.Size >= totalSize)
					{
						_availableStagingTextures.RemoveAt(i);
						tex.SetStagingDimensions(width, height, depth, format);
						return tex;
					}
				}
			}

			uint32 texWidth = Math.Max(256, width);
			uint32 texHeight = Math.Max(256, height);
			VKTexture newTex = (VKTexture)ResourceFactory.CreateTexture(TextureDescription.Texture3D(
				texWidth, texHeight, depth, 1, format, TextureUsage.Staging));
			newTex.SetStagingDimensions(width, height, depth, format);

			return newTex;
		}

		private VKBuffer GetFreeStagingBuffer(uint32 size)
		{
			using (_stagingResourcesLock.Enter())
			{
				for (int32 i = 0; i < _availableStagingBuffers.Count; i++)
				{
					VKBuffer buffer = _availableStagingBuffers[i];
					if (buffer.SizeInBytes >= size)
					{
						_availableStagingBuffers.RemoveAt(i);
						return buffer;
					}
				}
			}

			uint32 newBufferSize = Math.Max(MinStagingBufferSize, size);
			VKBuffer newBuffer = (VKBuffer)ResourceFactory.CreateBuffer(
				BufferDescription(newBufferSize, BufferUsage.Staging));
			return newBuffer;
		}

		public override void ResetFence(Fence fence)
		{
			VkFence vkFence = Util.AssertSubtype<Fence, VKFence>(fence).DeviceFence;
			vkResetFences(_device, 1, &vkFence);
		}

		public override bool WaitForFence(Fence fence, uint64 nanosecondTimeout)
		{
			VkFence vkFence = Util.AssertSubtype<Fence, VKFence>(fence).DeviceFence;
			VkResult result = vkWaitForFences(_device, 1, &vkFence, true, nanosecondTimeout);
			return result == VkResult.VK_SUCCESS;
		}

		public override bool WaitForFences(Fence[] fences, bool waitAll, uint64 nanosecondTimeout)
		{
			int fenceCount = fences.Count;
			VkFence* fencesPtr = scope VkFence[fenceCount]*;
			for (int i = 0; i < fenceCount; i++)
			{
				fencesPtr[i] = Util.AssertSubtype<Fence, VKFence>(fences[i]).DeviceFence;
			}

			VkResult result = vkWaitForFences(_device, (uint32)fenceCount, fencesPtr, waitAll, nanosecondTimeout);
			return result == VkResult.VK_SUCCESS;
		}

		private static bool CheckIsSupported()
		{
			VkInstanceCreateInfo instanceCI = VkInstanceCreateInfo() { sType = .VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO };
			VkApplicationInfo applicationInfo = VkApplicationInfo() { sType = .VK_STRUCTURE_TYPE_APPLICATION_INFO };
			applicationInfo.apiVersion = VulkanNative.VK_API_VERSION_1_0;
			applicationInfo.applicationVersion = VulkanNative.VK_API_VERSION_1_0;
			applicationInfo.engineVersion = VulkanNative.VK_API_VERSION_1_0;
			applicationInfo.pApplicationName = s_name;
			applicationInfo.pEngineName = s_name;

			instanceCI.pApplicationInfo = &applicationInfo;

			VkInstance testInstance = .Null;
			VkResult result = vkCreateInstance(&instanceCI, null, &testInstance);
			if (result != VkResult.VK_SUCCESS)
			{
				return false;
			}

			uint32 physicalDeviceCount = 0;
			result = vkEnumeratePhysicalDevices(testInstance, &physicalDeviceCount, null);
			if (result != VkResult.VK_SUCCESS || physicalDeviceCount == 0)
			{
				vkDestroyInstance(testInstance, null);
				return false;
			}

			vkDestroyInstance(testInstance, null);

			List<String> instanceExtensions = GetInstanceExtensions(.. new .());
			defer { DeleteContainerAndItems!(instanceExtensions); }
			if (!instanceExtensions.Contains(CommonStrings.VK_KHR_SURFACE_EXTENSION_NAME))
			{
				return false;
			}
			if (OperatingSystem.IsWindows())
			{
				return instanceExtensions.Contains(CommonStrings.VK_KHR_WIN32_SURFACE_EXTENSION_NAME);
			}
			else if (OperatingSystem.IsAndroid())
			{
				return instanceExtensions.Contains(CommonStrings.VK_KHR_ANDROID_SURFACE_EXTENSION_NAME);
			}
			else if (OperatingSystem.IsLinux())
			{
				return instanceExtensions.Contains(CommonStrings.VK_KHR_XLIB_SURFACE_EXTENSION_NAME);
			}
			else if (OperatingSystem.IsIOS())
			{
				return instanceExtensions.Contains(CommonStrings.VK_MVK_IOS_SURFACE_EXTENSION_NAME);
			}
			else if (OperatingSystem.IsMacOS())
			{
				return instanceExtensions.Contains(CommonStrings.VK_MVK_MACOS_SURFACE_EXTENSION_NAME);
			}

			return false;
		}

		internal void ClearColorTexture(VKTexture texture, VkClearColorValue color)
		{
			var color;
			uint32 effectiveLayers = texture.ArrayLayers;
			if ((texture.Usage & TextureUsage.Cubemap) != 0)
			{
				effectiveLayers *= 6;
			}
			VkImageSubresourceRange range = VkImageSubresourceRange()
				{
					aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
					baseMipLevel = 0,
					levelCount = texture.MipLevels,
					baseArrayLayer = 0,
					layerCount = effectiveLayers
				};
			SharedCommandPool pool = GetFreeCommandPool();
			VkCommandBuffer cb = pool.BeginNewCommandBuffer();
			texture.TransitionImageLayout(cb, 0, texture.MipLevels, 0, effectiveLayers, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);
			vkCmdClearColorImage(cb, texture.OptimalDeviceImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, &color, 1, &range);
			VkImageLayout colorLayout = texture.IsSwapchainTexture ? VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR : VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
			texture.TransitionImageLayout(cb, 0, texture.MipLevels, 0, effectiveLayers, colorLayout);
			pool.EndAndSubmit(cb);
		}

		internal void ClearDepthTexture(VKTexture texture, VkClearDepthStencilValue clearValue)
		{
			var clearValue;
			uint32 effectiveLayers = texture.ArrayLayers;
			if ((texture.Usage & TextureUsage.Cubemap) != 0)
			{
				effectiveLayers *= 6;
			}
			VkImageAspectFlags aspect = FormatHelpers.IsStencilFormat(texture.Format)
				? VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT
				: VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT;
			VkImageSubresourceRange range = VkImageSubresourceRange()
				{
					aspectMask = aspect,
					baseMipLevel = 0,
					levelCount = texture.MipLevels,
					baseArrayLayer = 0,
					layerCount = effectiveLayers
				};
			SharedCommandPool pool = GetFreeCommandPool();
			VkCommandBuffer cb = pool.BeginNewCommandBuffer();
			texture.TransitionImageLayout(cb, 0, texture.MipLevels, 0, effectiveLayers, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);
			vkCmdClearDepthStencilImage(
				cb,
				texture.OptimalDeviceImage,
				VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
				&clearValue,
				1,
				&range);
			texture.TransitionImageLayout(cb, 0, texture.MipLevels, 0, effectiveLayers, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL);
			pool.EndAndSubmit(cb);
		}

		protected override uint32 GetUniformBufferMinOffsetAlignmentCore()
			=> (uint32)_physicalDeviceProperties.limits.minUniformBufferOffsetAlignment;

		protected override uint32 GetStructuredBufferMinOffsetAlignmentCore()
			=> (uint32)_physicalDeviceProperties.limits.minStorageBufferOffsetAlignment;

		internal void TransitionImageLayout(VKTexture texture, VkImageLayout layout)
		{
			SharedCommandPool pool = GetFreeCommandPool();
			VkCommandBuffer cb = pool.BeginNewCommandBuffer();
			texture.TransitionImageLayout(cb, 0, texture.MipLevels, 0, texture.ActualArrayLayers, layout);
			pool.EndAndSubmit(cb);
		}

		private class SharedCommandPool
		{
			private readonly VKGraphicsDevice _gd;
			private readonly VkCommandPool _pool;
			private readonly VkCommandBuffer _cb;

			public bool IsCached { get; }

			public this(VKGraphicsDevice gd, bool isCached)
			{
				_gd = gd;
				IsCached = isCached;

				VkCommandPoolCreateInfo commandPoolCI = VkCommandPoolCreateInfo() { sType = .VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO };
				commandPoolCI.flags = VkCommandPoolCreateFlags.VK_COMMAND_POOL_CREATE_TRANSIENT_BIT | VkCommandPoolCreateFlags.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
				commandPoolCI.queueFamilyIndex = _gd.GraphicsQueueIndex;
				VkResult result = vkCreateCommandPool(_gd.Device, &commandPoolCI, null, &_pool);
				CheckResult(result);

				VkCommandBufferAllocateInfo allocateInfo = VkCommandBufferAllocateInfo() { sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO };
				allocateInfo.commandBufferCount = 1;
				allocateInfo.level = VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_PRIMARY;
				allocateInfo.commandPool = _pool;
				result = vkAllocateCommandBuffers(_gd.Device, &allocateInfo, &_cb);
				CheckResult(result);
			}

			public VkCommandBuffer BeginNewCommandBuffer()
			{
				VkCommandBufferBeginInfo beginInfo = VkCommandBufferBeginInfo() { sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
				beginInfo.flags = VkCommandBufferUsageFlags.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
				VkResult result = vkBeginCommandBuffer(_cb, &beginInfo);
				CheckResult(result);

				return _cb;
			}

			public void EndAndSubmit(VkCommandBuffer cb)
			{
				VkResult result = vkEndCommandBuffer(cb);
				CheckResult(result);
				_gd.SubmitCommandBuffer(null, cb, 0, null, 0, null, null);
				using (_gd._stagingResourcesLock.Enter())
				{
					_gd._submittedSharedCommandPools.Add(cb, this);
				}
			}

			internal void Destroy()
			{
				vkDestroyCommandPool(_gd.Device, _pool, null);
			}
		}

		private struct FenceSubmissionInfo
		{
			public VkFence Fence;
			public VKCommandList CommandList;
			public VkCommandBuffer CommandBuffer;
			public this(VkFence fence, VKCommandList commandList, VkCommandBuffer commandBuffer)
			{
				Fence = fence;
				CommandList = commandList;
				CommandBuffer = commandBuffer;
			}
		}
	}

	internal function VkResult vkCreateDebugReportCallbackEXT_d(
		VkInstance instance,
		VkDebugReportCallbackCreateInfoEXT* createInfo,
		void* allocatorPtr,
		out VkDebugReportCallbackEXT ret);

	internal function void vkDestroyDebugReportCallbackEXT_d(
		VkInstance instance,
		VkDebugReportCallbackEXT callback,
		VkAllocationCallbacks* pAllocator);

	internal function VkResult vkDebugMarkerSetObjectNameEXT_t(VkDevice device, VkDebugMarkerObjectNameInfoEXT* pNameInfo);
	internal function void vkCmdDebugMarkerBeginEXT_t(VkCommandBuffer commandBuffer, VkDebugMarkerMarkerInfoEXT* pMarkerInfo);
	internal function void vkCmdDebugMarkerEndEXT_t(VkCommandBuffer commandBuffer);
	internal function void vkCmdDebugMarkerInsertEXT_t(VkCommandBuffer commandBuffer, VkDebugMarkerMarkerInfoEXT* pMarkerInfo);

	internal function void vkGetBufferMemoryRequirements2_t(VkDevice device, VkBufferMemoryRequirementsInfo2* pInfo, VkMemoryRequirements2* pMemoryRequirements);
	internal function void vkGetImageMemoryRequirements2_t(VkDevice device, VkImageMemoryRequirementsInfo2* pInfo, VkMemoryRequirements2* pMemoryRequirements);

	internal function void vkGetPhysicalDeviceProperties2_t(VkPhysicalDevice physicalDevice, void* properties);

	// VK_EXT_metal_surface

	internal function VkResult vkCreateMetalSurfaceEXT_t(
		VkInstance instance,
		VkMetalSurfaceCreateInfoEXT* pCreateInfo,
		VkAllocationCallbacks* pAllocator,
		VkSurfaceKHR* pSurface);

	internal struct VkMetalSurfaceCreateInfoEXT
	{
		public const VkStructureType VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT = (VkStructureType)1000217000;

		public VkStructureType sType;
		public void* pNext;
		public uint32 flags;
		public void* pLayer;
	}

	internal struct VkPhysicalDeviceDriverProperties
	{
		public const int32 DriverNameLength = 256;
		public const int32 DriverInfoLength = 256;
		public const VkStructureType VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRIVER_PROPERTIES = (VkStructureType)1000196000;

		public VkStructureType sType;
		public void* pNext;
		public VkDriverId driverID;
		public uint8[DriverNameLength] driverName;
		public uint8[DriverInfoLength] driverInfo;
		public VkConformanceVersion conformanceVersion;

		public static VkPhysicalDeviceDriverProperties New()
		{
			return VkPhysicalDeviceDriverProperties() { sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRIVER_PROPERTIES };
		}
	}

	internal enum VkDriverId
	{
	}

	internal struct VkConformanceVersion
	{
		public uint8 major;
		public uint8 minor;
		public uint8 subminor;
		public uint8 patch;
	}
}
