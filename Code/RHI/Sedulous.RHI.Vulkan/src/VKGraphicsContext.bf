using System;
using System.Text;
using Bulkan;
using Sedulous.RHI;
using System.Collections;
using Sedulous.Foundation.Utilities;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// Graphics context on Vulkan.
/// </summary>
public class VKGraphicsContext : GraphicsContext
{
	/// <summary>
	/// Detected supported Vulkan properties and features.
	/// </summary>
	internal struct VKPhysicalDeviceInfo
	{
		internal VkPhysicalDeviceVulkan11Properties Propeties1;

		internal VkPhysicalDeviceVulkan12Properties Propeties2;

		internal VkPhysicalDeviceVulkan13Properties Propeties3;

		internal VkPhysicalDeviceVulkan11Features Features_1_1;

		internal VkPhysicalDeviceVulkan12Features Features_1_2;

		internal VkPhysicalDeviceVulkan13Features Features_1_3;

		internal VkPhysicalDeviceAccelerationStructureFeaturesKHR AccelerationStructureFeatures;

		internal VkPhysicalDeviceRayTracingPipelineFeaturesKHR RaytracingFeatures;
	}

	internal function VkResult vkDebugMarkerSetObjectNameEXT_t(VkDevice device, VkDebugMarkerObjectNameInfoEXT* pNameInfo);

	internal function void vkDestroyDebugUtilsMessengerEXT_d(VkInstance instance, VkDebugUtilsMessengerEXT messenger, VkAllocationCallbacks* pAllocator);

	internal function void vkDestroyDebugReportCallbackEXT_d(VkInstance instance, VkDebugReportCallbackEXT callback, VkAllocationCallbacks* pAllocator);

	internal function VkResult vkDebugMarkerSetObjectNameEXT_d(VkDevice device, VkDebugMarkerObjectNameInfoEXT* pNameInfo);

	private const String PhysicalDevicePointerKey = "PhysicalDevice";

	private const String InstancePointerKey = "Instance";

	private const String GraphicsQueuePointerKey = "GraphicsQueue";

	private const String QueueIndicesPointerKey = "QueueIndices";

	private VKCapabilities capabilities;

	internal static readonly uint32 Version_1_3 = VKHelpers.Version(1, 3, 0);

	internal static readonly uint32 Version_1_2 = VKHelpers.Version(1, 2, 0);

	internal static readonly uint32 Version_1_1 = VKHelpers.Version(1, 1, 0);

	internal static readonly uint32 Version_1_0 = VKHelpers.Version(1, 0, 0);

	/// <summary>
	/// Vulkan device object.
	/// </summary>
	public VkDevice VkDevice;

	/// <summary>
	/// Vulkan instance object.
	/// </summary>
	public VkInstance VkInstance;

	/// <summary>
	/// Vulkan physical device object.
	/// </summary>
	public VkPhysicalDevice VkPhysicalDevice;

	/// <summary>
	/// Vulkan physical device memory properties.
	/// </summary>
	public VkPhysicalDeviceMemoryProperties VkPhysicalDeviceMemoryProperties;

	/// <summary>
	/// The vulkan command buffer used to copy commands.
	/// </summary>
	public VkCommandBuffer CopyCommandBuffer;

	/// <summary>
	/// Properties and Features extracted from the current physicalDevice.
	/// </summary>
	internal VKPhysicalDeviceInfo VkPhysicalDeviceInfo;

	/// <summary>
	/// The supported queue indices.
	/// </summary>
	internal VKQueueFamilyIndices QueueIndices;

	private VkQueue vkGraphicsQueue;

	private VkCommandPool copyCommandPool;

	private VkQueue vkCopyQueue;

	private VkFence vkCopyFence;

	internal VkFence vkImageAvailableFence;

	internal VKDescriptorSetPool DescriptorPool;

	internal VKUploadBuffer BufferUploader;

	internal VKUploadBuffer TextureUploader;

	internal bool DebugUtilsEnabled;

	internal bool DebugMarkerEnabled;

	internal bool ClipSpaceYInvertedSupported;

	internal bool CopyQueueSupported;

	internal bool raytracingSupported;

	/// <summary>
	/// Whether the object is disposed.
	/// </summary>
	protected bool disposed;

	private VkDebugUtilsMessengerEXT debugUtilsCallbackHandle;

	private PFN_vkDebugUtilsMessengerCallbackEXT debugUtilsMessegerCallbackFunc;

	private VkDebugReportCallbackEXT debugReportCallbackHandle;

	private PFN_vkDebugReportCallbackEXT debugReportCallbackFunc;

	/// <summary>
	/// Set of device extensions to be enabled for this application.
	/// </summary>
	/// <remarks>
	/// Must be set before create device.
	/// </remarks>
	public readonly List<String> DeviceExtensionsToEnable = new .() ~ DeleteContainerAndItems!(_);

	/// <summary>
	/// Set of device instance extensions to be enabled for this application.
	/// </summary>
	/// <remarks>
	/// Must be set before create device.
	/// </remarks>
	public readonly List<String> InstanceExtensionsToEnable = new .() ~ DeleteContainerAndItems!(_);

	/// <inheritdoc />
	public override void* NativeDevicePointer => null;

	/// <inheritdoc />
	public override GraphicsBackend BackendType => GraphicsBackend.Vulkan;

	/// <inheritdoc />
	public override GraphicsContextCapabilities Capabilities => capabilities;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKGraphicsContext" /> class.
	/// </summary>
	public this()
		: this(Span<String>(), Span<String>())
	{
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKGraphicsContext" /> class.
	/// </summary>
	/// <param name="deviceExtensionsToEnable">Set of device extensions to be enabled for this application.</param>
	/// <param name="instanceExtensionsToEnable">Set of device instance extensions to be enabled for this application.</param>
	public this(Span<String> deviceExtensionsToEnable, Span<String> instanceExtensionsToEnable)
	{
		base.Factory = new VKResourceFactory(this);

		for (var @extension in deviceExtensionsToEnable)
		{
			DeviceExtensionsToEnable.Add(new .(@extension));
		}

		for (var @extension in instanceExtensionsToEnable)
		{
			InstanceExtensionsToEnable.Add(new .(@extension));
		}
	}

	/// <inheritdoc />
	public override void CreateDeviceInternal()
	{
		VulkanNative.Initialize();
		VulkanNative.SetLoadFunctionErrorCallBack(new (functionName) =>
			{
				Console.WriteLine(scope $"Failed to load function: '{functionName}'.");
			});
		VulkanNative.LoadPreInstanceFunctions();

		CreateInstance(scope (instance) =>
			{
				VulkanNative.LoadInstanceFunctions(instance);
				VulkanNative.LoadPostInstanceFunctions();
			});

		CreatePhysicalAndLogicalDevice();
		CreateResourcesForCopyQueue();
		CreateSemaphoresAndFences();
		capabilities = new VKCapabilities(this);
		DescriptorPool = new VKDescriptorSetPool(this);
		BufferUploader = new VKUploadBuffer(this, base.DefaultBufferUploaderSize);
		TextureUploader = new VKUploadBuffer(this, base.DefaultTextureUploaderSize);
	}

	/// <inheritdoc />
	public override SwapChain CreateSwapChain(SwapChainDescription description)
	{
		if (VkDevice == .Null)
		{
			base.ValidationLayer?.Notify("Vulkan", "You need to call CreateDevice() before to create the SwapChain");
		}
		return new VKSwapChain(this, description);
	}

	/// <inheritdoc />
	public override void ShaderCompile(String shaderSource, String entryPoint, ShaderStages stage, CompilerParameters parameters, ref CompilationResult result)
	{
	}

	/// <inheritdoc />
	public override bool GenerateTextureMipmapping(Texture texture)
	{
		return false;
	}

	/// <inheritdoc />
	public override MappedResource MapMemory(GraphicsResource resource, MapMode mode, uint32 subResource = 0)
	{
		if (resource is VKBuffer)
		{
			VKBuffer buffer = resource as VKBuffer;
			void* dataPointer = default(void*);
			VulkanNative.vkMapMemory(VkDevice, buffer.BufferMemory, 0uL, buffer.Description.SizeInBytes, VkMemoryMapFlags.None, &dataPointer);
			return MappedResource(resource, mode, dataPointer, buffer.Description.SizeInBytes);
		}
		if (resource is VKTexture)
		{
			VKTexture texture = resource as VKTexture;
			SubResourceInfo subResourceInfo = Helpers.GetSubResourceInfo(texture.Description, subResource);
			void* dataPointer = default(void*);
			if ((texture.Description.Usage & ResourceUsage.Staging) != 0)
			{
				VulkanNative.vkMapMemory(VkDevice, texture.BufferMemory, subResourceInfo.Offset, subResourceInfo.SizeInBytes, VkMemoryMapFlags.None, &dataPointer);
				return MappedResource(resource, mode, dataPointer, subResourceInfo.SizeInBytes, subResource, subResourceInfo.RowPitch, subResourceInfo.SlicePitch);
			}
			VulkanNative.vkMapMemory(VkDevice, texture.ImageMemory, subResourceInfo.Offset, subResourceInfo.SizeInBytes, VkMemoryMapFlags.None, &dataPointer);
			return MappedResource(resource, mode, dataPointer, (uint32)texture.MemoryRequirements.size, subResource, subResourceInfo.RowPitch, subResourceInfo.SlicePitch);
		}
		base.ValidationLayer?.Notify("Vulkan", "This operation is only supported to buffers and textures.");
		return default(MappedResource);
	}

	/// <inheritdoc />
	public override void UnmapMemory(GraphicsResource resource, uint32 subResource = 0)
	{
		if (resource is VKBuffer)
		{
			VKBuffer buffer = resource as VKBuffer;
			VulkanNative.vkUnmapMemory(VkDevice, buffer.BufferMemory);
		}
		else if (resource is VKTexture)
		{
			VKTexture texture = resource as VKTexture;
			if ((texture.Description.Usage & ResourceUsage.Staging) != 0)
			{
				VulkanNative.vkUnmapMemory(VkDevice, texture.BufferMemory);
			}
			else
			{
				VulkanNative.vkUnmapMemory(VkDevice, texture.ImageMemory);
			}
		}
		else
		{
			base.ValidationLayer?.Notify("Vulkan", "This operation is only supported to buffers and textures.");
		}
	}

	/// <inheritdoc />
	protected override void InternalUpdateBufferData(Sedulous.RHI.Buffer buffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0)
	{
		(buffer as VKBuffer).SetData(CopyCommandBuffer, source, sourceSizeInBytes, destinationOffsetInBytes);
	}

	/// <inheritdoc />
	public override void UpdateTextureData(Texture texture, void* source, uint32 sourceSizeInBytes, uint32 subResource)
	{
		(texture as VKTexture).SetData(CopyCommandBuffer, source, sourceSizeInBytes, subResource);
	}

	/// <inheritdoc />
	public override void SyncUpcopyQueue()
	{
		VkCommandBuffer commandBuffer = CopyCommandBuffer;
		VulkanNative.vkEndCommandBuffer(commandBuffer);
		VkSubmitInfo submitInfo = default(VkSubmitInfo);
		submitInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_SUBMIT_INFO;
		submitInfo.commandBufferCount = 1;
		submitInfo.pCommandBuffers = &commandBuffer;
		VulkanNative.vkQueueSubmit(vkCopyQueue, 1, &submitInfo, vkCopyFence);
		VkFence copyFence = vkCopyFence;
		VulkanNative.vkWaitForFences(VkDevice, 1, &copyFence, VkBool32.True, uint64.MaxValue);
		VulkanNative.vkResetFences(VkDevice, 1, &copyFence);
		VulkanNative.vkResetCommandPool(VkDevice, copyCommandPool, VkCommandPoolResetFlags.None);
		VkCommandBufferBeginInfo beginInfo = default(VkCommandBufferBeginInfo);
		beginInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
		beginInfo.flags = VkCommandBufferUsageFlags.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
		VulkanNative.vkBeginCommandBuffer(CopyCommandBuffer, &beginInfo);
		BufferUploader.Clear();
		TextureUploader.Clear();
	}

	private void CreateInstance(delegate void(VkInstance) onInstanceCreated = null)
	{
		List<String> availableInstanceLayers = VKHelpers.EnumerateInstanceLayers(.. new .());
		defer { DeleteContainerAndItems!(availableInstanceLayers); }

		List<String> availableInstanceExtensions = VKHelpers.EnumerateInstanceExtensions(.. new .());
		defer { DeleteContainerAndItems!(availableInstanceExtensions); }

		List<String> instanceExtensionEnabled = scope List<String>();
		List<String> layersToEnable = scope List<String>();
		CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_KHR_surface");
		switch (OperatingSystemHelper.GetCurrentPlatfom())
		{
		case .Windows:
			CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_KHR_win32_surface");
			break;
		case .Linux:
			CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_KHR_xlib_surface");
			break;
		case .Android:
			CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_KHR_android_surface");
			break;
		case .MacOS:
			CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_MVK_macos_surface");
			break;
		case .iOS:
			CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, "VK_MVK_ios_surface");
			break;

		default: break;
		}
		for (String extensionName in InstanceExtensionsToEnable)
		{
			CheckExtension(availableInstanceExtensions, instanceExtensionEnabled, extensionName);
		}
		if (availableInstanceExtensions.Contains("VK_KHR_get_physical_device_properties2"))
		{
			instanceExtensionEnabled.Add("VK_KHR_get_physical_device_properties2");
		}
		if (base.IsValidationLayerEnabled)
		{
			if (availableInstanceExtensions.Contains("VK_EXT_debug_utils"))
			{
				instanceExtensionEnabled.Add("VK_EXT_debug_utils");
				DebugUtilsEnabled = true;
				DebugMarkerEnabled = true;
			}
			else
			{
				instanceExtensionEnabled.Add("VK_EXT_debug_report");
			}
			switch (OperatingSystemHelper.GetCurrentPlatfom())
			{
			case .Windows:
				if (availableInstanceLayers.Contains( "VK_LAYER_KHRONOS_validation"))
				{
					layersToEnable.Add("VK_LAYER_KHRONOS_validation");
				}
				break;
			case .Android:
				if (availableInstanceLayers.Contains("VK_LAYER_KHRONOS_validation"))
				{
					layersToEnable.Add("VK_LAYER_KHRONOS_validation");
				}
				if (availableInstanceLayers.Contains("VK_LAYER_LUNARG_core_validation"))
				{
					layersToEnable.Add("VK_LAYER_LUNARG_core_validation");
				}
				if (availableInstanceLayers.Contains("VK_LAYER_LUNARG_swapchain"))
				{
					layersToEnable.Add("VK_LAYER_LUNARG_swapchain");
				}
				if (availableInstanceLayers.Contains("VK_LAYER_LUNARG_parameter_validation"))
				{
					layersToEnable.Add("VK_LAYER_LUNARG_parameter_validation");
				}
				break;

			default: break;
			}
		}
		VkApplicationInfo vkApplicationInfo = default(VkApplicationInfo);
		vkApplicationInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_APPLICATION_INFO;
		vkApplicationInfo.apiVersion = Version_1_3;
		vkApplicationInfo.applicationVersion = Version_1_0;
		vkApplicationInfo.engineVersion = Version_1_0;
		vkApplicationInfo.pEngineName = "Sedulous";
		vkApplicationInfo.pApplicationName = "Sedulous";
		VkApplicationInfo appInfo = vkApplicationInfo;

		int layersCount = layersToEnable.Count;
		char8** layersToEnableArray = scope char8*[layersCount]*;
		for (int i = 0; i < layersCount; i++)
		{
			String layer = layersToEnable[i];
			layersToEnableArray[i] = scope :: String(layer).CStr();
		}
		int extensionsCount = instanceExtensionEnabled.Count;
		char8** extensionsToEnableArray = scope char8*[extensionsCount]*;
		for (int i = 0; i < extensionsCount; i++)
		{
			String @extension = instanceExtensionEnabled[i];
			extensionsToEnableArray[i] = scope :: String(@extension).CStr();
		}
		VkInstanceCreateInfo instanceInfo = default(VkInstanceCreateInfo);
		instanceInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
		instanceInfo.pApplicationInfo = &appInfo;
		instanceInfo.enabledLayerCount = (uint32)layersToEnable.Count;
		instanceInfo.ppEnabledLayerNames = layersToEnableArray;
		instanceInfo.enabledExtensionCount = (uint32)extensionsCount;
		instanceInfo.ppEnabledExtensionNames = extensionsToEnableArray;
		VkDebugUtilsMessengerCreateInfoEXT debug_utils_create_info = default(VkDebugUtilsMessengerCreateInfoEXT);
		VkDebugReportCallbackCreateInfoEXT debug_report_create_info = default(VkDebugReportCallbackCreateInfoEXT);
		if (base.IsValidationLayerEnabled)
		{
			if (DebugUtilsEnabled)
			{
				debug_utils_create_info.sType = VkStructureType.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
				debug_utils_create_info.messageSeverity = VkDebugUtilsMessageSeverityFlagsEXT.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VkDebugUtilsMessageSeverityFlagsEXT.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;
				debug_utils_create_info.messageType = VkDebugUtilsMessageTypeFlagsEXT.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT;
				debugUtilsMessegerCallbackFunc = => DebugUtilsMessengerCallback;
				debug_utils_create_info.pfnUserCallback = debugUtilsMessegerCallbackFunc;
				debug_utils_create_info.pUserData = Internal.UnsafeCastToPtr(this);
				instanceInfo.pNext = &debug_utils_create_info;
			}
			else
			{
				debug_report_create_info.sType = VkStructureType.VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT;
				debug_report_create_info.flags = VkDebugReportFlagsEXT.VK_DEBUG_REPORT_WARNING_BIT_EXT | VkDebugReportFlagsEXT.VK_DEBUG_REPORT_ERROR_BIT_EXT;
				debugReportCallbackFunc = => DebugReportCallback;
				debug_report_create_info.pfnCallback = debugReportCallbackFunc;
				debug_report_create_info.pUserData = Internal.UnsafeCastToPtr(this);
				instanceInfo.pNext = &debug_report_create_info;
			}
		}
		VkInstance newInstance = default(VkInstance);
		VulkanNative.vkCreateInstance(&instanceInfo, null, &newInstance);
		VkInstance = newInstance;
		
		if (onInstanceCreated != null)
		{
			onInstanceCreated(newInstance);
		}

		if (base.IsValidationLayerEnabled)
		{
			if (DebugUtilsEnabled)
			{
				VkDebugUtilsMessengerEXT debugUtilsCallbackHandle = default(VkDebugUtilsMessengerEXT);
				VulkanNative.vkCreateDebugUtilsMessengerEXT(VkInstance, &debug_utils_create_info, null, &debugUtilsCallbackHandle);
				this.debugUtilsCallbackHandle = debugUtilsCallbackHandle;
			}
			else
			{
				VkDebugReportCallbackEXT debugReportCallbackHandle = default(VkDebugReportCallbackEXT);
				VulkanNative.vkCreateDebugReportCallbackEXT(VkInstance, &debug_report_create_info, null, &debugReportCallbackHandle);
				this.debugReportCallbackHandle = debugReportCallbackHandle;
			}
		}
	}

	private void CheckExtension(List<String> availableinstanceExtensions, List<String> extensionsToEnable, String @extension)
	{
		if (!availableinstanceExtensions.Contains(@extension))
		{
			base.ValidationLayer?.Notify("Vulkan", scope $"The requiered instance extensions was not available: {@extension}");
		}
		extensionsToEnable.Add(@extension);
	}

	private static VkBool32 DebugUtilsMessengerCallback(VkDebugUtilsMessageSeverityFlagsEXT messageSeverity, uint32 messageTypes, VkDebugUtilsMessengerCallbackDataEXT* pCallbackData, void* pUserData)
	{
		String message = scope .(pCallbackData.pMessage);
		int32 id = pCallbackData.messageIdNumber;
		String fullMessage = scope $"[{messageTypes}] ({id}) {message}";
		if (messageSeverity == VkDebugUtilsMessageSeverityFlagsEXT.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT)
		{
			var context = (VKGraphicsContext)Internal.UnsafeCastToObject(pUserData);
			context?.ValidationLayer?.Notify("Vulkan", fullMessage);
		}
		return false;
	}

	private static VkBool32 DebugReportCallback(uint32 flags, VkDebugReportObjectTypeEXT objectType, uint64 @object, uint location, int32 messageCode, char8* pLayerPrefix, char8* pMessage, void* pUserData)
	{
		String message = scope .(pMessage);
		String fullMessage = scope $"[{flags}] ({objectType}) {message}";
		if (flags == 8)
		{
			var context = (VKGraphicsContext)Internal.UnsafeCastToObject(pUserData);
			context?.ValidationLayer?.Notify("Vulkan", fullMessage);
		}
		return false;
	}

	private void CreatePhysicalAndLogicalDevice()
	{
		uint32 deviceCount = 0;
		VulkanNative.vkEnumeratePhysicalDevices(VkInstance, &deviceCount, null);
		if (deviceCount == 0)
		{
			base.ValidationLayer?.Notify("Vulkan", "No physical devices exist.");
		}
		VkPhysicalDevice* physicalDevices = scope VkPhysicalDevice[(int32)deviceCount]*;
		VulkanNative.vkEnumeratePhysicalDevices(VkInstance, &deviceCount, physicalDevices);
		VkPhysicalDeviceProperties2 deviceProperties2 = default(VkPhysicalDeviceProperties2);
		deviceProperties2.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2;
		if (deviceCount != 0)
		{
			VkPhysicalDevice device = .Null;
			for (uint32 i = 0; i < deviceCount; i++)
			{
				device = physicalDevices[i];
				VulkanNative.vkGetPhysicalDeviceProperties2(device, &deviceProperties2);
				if (deviceProperties2.properties.deviceType == VkPhysicalDeviceType.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU)
				{
					VkPhysicalDevice = device;
					break;
				}
			}
			if (VkPhysicalDevice == .Null)
			{
				VkPhysicalDevice = *physicalDevices;
			}
		}
		if (VkPhysicalDevice == .Null)
		{
			base.ValidationLayer?.Notify("Vulkan", "Failed to find a suitable GPU");
		}
		VkPhysicalDeviceVulkan11Properties properties_1_1 = default(VkPhysicalDeviceVulkan11Properties);
		VkPhysicalDeviceVulkan12Properties properties_1_2 = default(VkPhysicalDeviceVulkan12Properties);
		VkPhysicalDeviceVulkan13Properties properties_1_3 = default(VkPhysicalDeviceVulkan13Properties);
		deviceProperties2.pNext = &properties_1_1;
		properties_1_1.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_PROPERTIES;
		properties_1_1.pNext = &properties_1_2;
		if (deviceProperties2.properties.apiVersion >= Version_1_1)
		{
			deviceProperties2.pNext = &properties_1_1;
			if (deviceProperties2.properties.apiVersion >= Version_1_2)
			{
				properties_1_1.pNext = &properties_1_2;
				properties_1_2.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_PROPERTIES;
				if (deviceProperties2.properties.apiVersion >= Version_1_3)
				{
					properties_1_2.pNext = &properties_1_3;
					properties_1_3.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_PROPERTIES;
				}
			}
		}
		VulkanNative.vkGetPhysicalDeviceProperties2(VkPhysicalDevice, &deviceProperties2);
		VkPhysicalDeviceMemoryProperties deviceMemoryProperties = default(VkPhysicalDeviceMemoryProperties);
		VulkanNative.vkGetPhysicalDeviceMemoryProperties(VkPhysicalDevice, &deviceMemoryProperties);
		VkPhysicalDeviceMemoryProperties = deviceMemoryProperties;
		TimestampFrequency = (uint64)(1.0 / (double)deviceProperties2.properties.limits.timestampPeriod * 1000.0 * 1000.0 * 1000.0);
		QueueIndices = VKQueueFamilyIndices.FindQueueFamilies(this, VkPhysicalDevice, null);
		float priority = 1f;
		int32 queueCount = ((QueueIndices.CopyFamily <= 0) ? 1 : 2);
		VkDeviceQueueCreateInfo graphicsQueueInfo = default(VkDeviceQueueCreateInfo);
		graphicsQueueInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
		graphicsQueueInfo.queueFamilyIndex = (uint32)QueueIndices.GraphicsFamily;
		graphicsQueueInfo.queueCount = 1;
		graphicsQueueInfo.pQueuePriorities = &priority;
		VkDeviceQueueCreateInfo* queueCreateInfos = scope VkDeviceQueueCreateInfo[queueCount]*;
		*queueCreateInfos = graphicsQueueInfo;
		CopyQueueSupported = QueueIndices.CopyFamily > 0;
		if (CopyQueueSupported)
		{
			VkDeviceQueueCreateInfo copyQueueInfo = default(VkDeviceQueueCreateInfo);
			copyQueueInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
			copyQueueInfo.queueFamilyIndex = (uint32)QueueIndices.CopyFamily;
			copyQueueInfo.queueCount = 1;
			copyQueueInfo.pQueuePriorities = &priority;
			queueCreateInfos[1] = copyQueueInfo;
		}
		uint32 propertyCount = 0;
		VulkanNative.vkEnumerateDeviceExtensionProperties(VkPhysicalDevice, null, &propertyCount, null);
		VkExtensionProperties* availableDeviceProperties = scope VkExtensionProperties[(int32)propertyCount]*;
		VulkanNative.vkEnumerateDeviceExtensionProperties(VkPhysicalDevice, null, &propertyCount, availableDeviceProperties);

		List<String> extensionsToEnable = scope List<String>();
		for (int i = 0; i < propertyCount; i++)
		{
			String extensionName = scope:: .(&availableDeviceProperties[i].extensionName);
			switch (extensionName)
			{
			case "VK_KHR_swapchain",
				 "VK_EXT_shader_viewport_index_layer",
				 "VK_NV_viewport_array2":
				extensionsToEnable.Add(extensionName);
				break;
			case "VK_EXT_debug_marker":
				extensionsToEnable.Add(extensionName);
				DebugMarkerEnabled = true;
				break;
			case "VK_KHR_maintenance1":
				ClipSpaceYInvertedSupported = true;
				extensionsToEnable.Add(extensionName);
				break;
			case "VK_KHR_spirv_1_4",
				 "VK_KHR_shader_float_controls":
				extensionsToEnable.Add(extensionName);
				break;
			case "VK_KHR_acceleration_structure":
				extensionsToEnable.Add(extensionName);
				break;
			case "VK_KHR_ray_tracing_pipeline":
				raytracingSupported = true;
				extensionsToEnable.Add(extensionName);
				break;
			case "VK_KHR_deferred_host_operations":
				extensionsToEnable.Add(extensionName);
				break;
			}
		}
		extensionsToEnable.AddRange(DeviceExtensionsToEnable);
		int extensionsCount = extensionsToEnable.Count;
		char8** extensionsToEnableArray = scope char8*[extensionsCount]*;
		for (int i = 0; i < extensionsCount; i++)
		{
			String @extension = extensionsToEnable[i];
			extensionsToEnableArray[i] = scope :: String(@extension).CStr();
		}
		VkPhysicalDeviceFeatures2 deviceFeatures2 = default(VkPhysicalDeviceFeatures2);
		deviceFeatures2.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2;
		VkPhysicalDeviceVulkan11Features features_1_1 = default(VkPhysicalDeviceVulkan11Features);
		VkPhysicalDeviceVulkan12Features features_1_2 = default(VkPhysicalDeviceVulkan12Features);
		VkPhysicalDeviceVulkan13Features features_1_3 = default(VkPhysicalDeviceVulkan13Features);
		VkPhysicalDeviceAccelerationStructureFeaturesKHR accelerationStructureFeatures = default(VkPhysicalDeviceAccelerationStructureFeaturesKHR);
		VkPhysicalDeviceRayTracingPipelineFeaturesKHR raytracingFeatures = default(VkPhysicalDeviceRayTracingPipelineFeaturesKHR);
		if (deviceProperties2.properties.apiVersion >= Version_1_1)
		{
			deviceFeatures2.pNext = &features_1_1;
			features_1_1.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES;
			if (deviceProperties2.properties.apiVersion >= Version_1_2)
			{
				features_1_1.pNext = &features_1_2;
				features_1_2.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES;
				if (deviceProperties2.properties.apiVersion >= Version_1_3)
				{
					features_1_2.pNext = &features_1_3;
					features_1_3.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_FEATURES;
					if (raytracingSupported)
					{
						features_1_3.pNext = &accelerationStructureFeatures;
						accelerationStructureFeatures.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR;
						accelerationStructureFeatures.pNext = &raytracingFeatures;
						raytracingFeatures.sType = VkStructureType.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_FEATURES_KHR;
					}
				}
			}
		}
		VulkanNative.vkGetPhysicalDeviceFeatures2(VkPhysicalDevice, &deviceFeatures2);
		VkPhysicalDeviceInfo = VKPhysicalDeviceInfo()
		{
			Propeties1 = properties_1_1,
			Propeties2 = properties_1_2,
			Propeties3 = properties_1_3,
			Features_1_1 = features_1_1,
			Features_1_2 = features_1_2,
			Features_1_3 = features_1_3,
			AccelerationStructureFeatures = accelerationStructureFeatures,
			RaytracingFeatures = raytracingFeatures
		};
		VkDeviceCreateInfo createInfo = default(VkDeviceCreateInfo);
		createInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
		createInfo.enabledExtensionCount = (uint32)extensionsCount;
		createInfo.ppEnabledExtensionNames = extensionsToEnableArray;
		createInfo.queueCreateInfoCount = (uint32)queueCount;
		createInfo.pQueueCreateInfos = queueCreateInfos;
		createInfo.pEnabledFeatures = null;
		createInfo.pNext = &deviceFeatures2;
		VkDevice newDevice = default(VkDevice);
		VulkanNative.vkCreateDevice(VkPhysicalDevice, &createInfo, null, &newDevice);
		VkDevice = newDevice;
		VkQueue newQueue = default(VkQueue);
		VulkanNative.vkGetDeviceQueue(VkDevice, (uint32)QueueIndices.GraphicsFamily, 0, &newQueue);
		vkGraphicsQueue = newQueue;
	}

	private void CreateResourcesForCopyQueue()
	{
		uint32 queueFamilyIndex = (CopyQueueSupported ? ((uint32)QueueIndices.CopyFamily) : 0);
		VkQueue newQueue = default(VkQueue);
		VulkanNative.vkGetDeviceQueue(VkDevice, queueFamilyIndex, 0, &newQueue);
		vkCopyQueue = newQueue;
		VkCommandPoolCreateInfo poolInfo = default(VkCommandPoolCreateInfo);
		poolInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
		poolInfo.queueFamilyIndex = queueFamilyIndex;
		VkCommandPool newCommandPool = default(VkCommandPool);
		VulkanNative.vkCreateCommandPool(VkDevice, &poolInfo, null, &newCommandPool);
		copyCommandPool = newCommandPool;
		VkCommandBufferAllocateInfo commandBufferInfo = default(VkCommandBufferAllocateInfo);
		commandBufferInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
		commandBufferInfo.commandBufferCount = 1;
		commandBufferInfo.commandPool = copyCommandPool;
		commandBufferInfo.level = VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_PRIMARY;
		VkCommandBuffer newCommandBuffer = default(VkCommandBuffer);
		VulkanNative.vkAllocateCommandBuffers(VkDevice, &commandBufferInfo, &newCommandBuffer);
		CopyCommandBuffer = newCommandBuffer;
		VkCommandBufferBeginInfo beginInfo = default(VkCommandBufferBeginInfo);
		beginInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
		beginInfo.flags = VkCommandBufferUsageFlags.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
		VulkanNative.vkBeginCommandBuffer(CopyCommandBuffer, &beginInfo);
		VkFenceCreateInfo fenceInfo = default(VkFenceCreateInfo);
		fenceInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
		VkFence newFence = default(VkFence);
		VulkanNative.vkCreateFence(VkDevice, &fenceInfo, null, &newFence);
		vkCopyFence = newFence;
	}

	private void CreateSemaphoresAndFences()
	{
		VkFenceCreateInfo fenceInfo = default(VkFenceCreateInfo);
		fenceInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
		VkFence newFence = default(VkFence);
		VulkanNative.vkCreateFence(VkDevice, &fenceInfo, null, &newFence);
		vkImageAvailableFence = newFence;
	}

	internal void SetDebugName(VkObjectType type, uint64 target, String name)
	{
		if (DebugMarkerEnabled && !String.IsNullOrEmpty(name))
		{
			VkDebugUtilsObjectNameInfoEXT nameInfo = default(VkDebugUtilsObjectNameInfoEXT);
			nameInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_NAME_INFO_EXT;
			nameInfo.objectHandle = target;
			nameInfo.objectType = type;
			nameInfo.pObjectName = scope String(name).CStr();
			VulkanNative.vkSetDebugUtilsObjectNameEXT(VkDevice, &nameInfo);
		}
	}

	/// <inheritdoc />
	public override bool GetNativePointer(String pointerKey, out void* nativePointer)
	{
		if (!base.GetNativePointer(pointerKey, out nativePointer))
		{
			switch (pointerKey)
			{
			case "PhysicalDevice":
				nativePointer = (void*)VkPhysicalDevice.Handle;
				return true;
			case "Instance":
				nativePointer = (void*)VkInstance.Handle;
				return true;
			case "GraphicsQueue":
				nativePointer = (void*)vkGraphicsQueue.Handle;
				return true;
			case "QueueIndices":
				nativePointer = (void*)int(QueueIndices.GraphicsFamily);
				return true;
			}
		}
		return false;
	}

	/// <inheritdoc />
	protected override void Dispose(bool disposing)
	{
		if (!disposed)
		{
			if(BufferUploader != null)
			{
				BufferUploader.Dispose();
				delete BufferUploader;
			}
			if(TextureUploader != null)
			{
				TextureUploader.Dispose();
				delete TextureUploader;
			}
			VulkanNative.vkDestroyFence(VkDevice, vkCopyFence, null);
			DescriptorPool.DestroyAll();
			delete DescriptorPool;
			delete capabilities;
			VulkanNative.vkDestroyCommandPool(VkDevice, copyCommandPool, null);
			VulkanNative.vkDestroyFence(VkDevice, vkImageAvailableFence, null);
			VulkanNative.vkDestroyDevice(VkDevice, null);

			if(debugUtilsMessegerCallbackFunc != null)
			{
				debugUtilsMessegerCallbackFunc = null;
				((vkDestroyDebugUtilsMessengerEXT_d)VulkanNative.vkGetInstanceProcAddr(VkInstance, "vkDestroyDebugUtilsMessengerEXT"))(VkInstance, debugUtilsCallbackHandle, null);
			}

			if (debugReportCallbackFunc != null)
			{
				debugReportCallbackFunc = null;
				((vkDestroyDebugReportCallbackEXT_d)VulkanNative.vkGetInstanceProcAddr(VkInstance, "vkDestroyDebugReportCallbackEXT"))(VkInstance, debugReportCallbackHandle, null);
			}
			VulkanNative.vkDestroyInstance(VkInstance, null);
			disposed = true;

			delete base.Factory;
		}
	}
}
