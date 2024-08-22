using System.Collections;
using Bulkan;
using Sedulous.Renderer.VK.Internal;
using System;
using Sedulous.Renderer.SPIRV;
using Bulkan.Utilities;
using static Bulkan.VulkanNative;
using static Bulkan.Utilities.VulkanMemoryAllocator;
using internal Sedulous.Renderer.VK;
/****************************************************************************
 Copyright (c) 2020-2023 Xiamen Yaji Software Co., Ltd.

 http://www.cocos.com

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
****************************************************************************/

namespace Sedulous.Renderer.VK;

		static
		{
			/*CC_DISABLE_WARNINGS()
	#define VMA_IMPLEMENTATION
	#include "vk_mem_alloc.h"
	#define THSVS_ERROR_CHECK_MIXED_IMAGE_LAYOUT
			// remote potential hazard because of programmable blend
			//#define THSVS_ERROR_CHECK_POTENTIAL_HAZARD
	#define THSVS_SIMPLER_VULKAN_SYNCHRONIZATION_IMPLEMENTATION
	#include "thsvs_simpler_vulkan_synchronization.h"
			CC_ENABLE_WARNINGS()*/
		}

		class CCVKDevice : Device {
		public static new CCVKDevice getInstance() {
				return (Self)CCVKDevice.instance;
			}

			~this() {
				CCVKDevice.instance = null;
			}

			/*friend class CCVKContext;
			using Device.copyBuffersToTexture;
			using Device.createBuffer;
			using Device.createBufferBarrier;
			using Device.createCommandBuffer;
			using Device.createDescriptorSet;
			using Device.createDescriptorSetLayout;
			using Device.createFramebuffer;
			using Device.createGeneralBarrier;
			using Device.createInputAssembler;
			using Device.createPipelineLayout;
			using Device.createPipelineState;
			using Device.createQueryPool;
			using Device.createQueue;
			using Device.createRenderPass;
			using Device.createSampler;
			using Device.createShader;
			using Device.createTexture;
			using Device.createTextureBarrier;*/

			public override void frameSync() {}
			public override void acquire(Swapchain* swapchains, uint32 count) {
				if (_onAcquire != null) _onAcquire.execute();

				var queue = (CCVKQueue)_queue;
				queue.gpuQueue().lastSignaledSemaphores.Clear();
				vkSwapchainIndices.Clear();
				gpuSwapchains.Clear();
				vkSwapchains.Clear();
				vkAcquireBarriers.Resize(count, acquireBarrier);
				vkPresentBarriers.Resize(count, presentBarrier);
				for (uint32 i = 0U; i < count; ++i) {
					var swapchain = (CCVKSwapchain)swapchains[i];
					if (swapchain.gpuSwapchain().lastPresentResult == .VK_NOT_READY) {
						if (!swapchain.checkSwapchainStatus()) {
							continue;
						}
					}

					/*if (_xr) {
						xr.XRSwapchain xrSwapchain = _xr.doGFXDeviceAcquire(_api);
						swapchain.gpuSwapchain().curImageIndex = xrSwapchain.swapchainImageIndex;
					}*/
					if (swapchain.gpuSwapchain().vkSwapchain != .Null) {
						vkSwapchains.Add(swapchain.gpuSwapchain().vkSwapchain);
					}
					if (swapchain.gpuSwapchain() != null) {
						gpuSwapchains.Add(swapchain.gpuSwapchain());
					}
					vkSwapchainIndices.Add(swapchain.gpuSwapchain().curImageIndex);
				}

				_gpuDescriptorSetHub.flush();
				_gpuSemaphorePool.reset();

				for (uint32 i = 0; i < vkSwapchains.Count; ++i) {
					VkSemaphore acquireSemaphore = _gpuSemaphorePool.alloc();
					VkResult res = vkAcquireNextImageKHR(_gpuDevice.vkDevice, vkSwapchains[i], ~0UL,
						acquireSemaphore, .Null, &vkSwapchainIndices[i]);
					Runtime.Assert(res == .VK_SUCCESS || res == .VK_SUBOPTIMAL_KHR);
					gpuSwapchains[i].curImageIndex = vkSwapchainIndices[i];
					queue.gpuQueue().lastSignaledSemaphores.Add(acquireSemaphore);

					vkAcquireBarriers[i].image = gpuSwapchains[i].swapchainImages[vkSwapchainIndices[i]];
					vkPresentBarriers[i].image = gpuSwapchains[i].swapchainImages[vkSwapchainIndices[i]];
				}

				if (this._options.enableBarrierDeduce) {
					_gpuTransportHub.checkIn(
						scope [&](gpuCommandBuffer) => {
							vkCmdPipelineBarrier(gpuCommandBuffer.vkCommandBuffer, .VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, .VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
								0, 0, null, 0, null, (uint32)vkSwapchains.Count, vkAcquireBarriers.Ptr);
						},
						false, false);

					_gpuTransportHub.checkIn(
						scope [&](gpuCommandBuffer) => {
							vkCmdPipelineBarrier(gpuCommandBuffer.vkCommandBuffer, .VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, .VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
								0, 0, null, 0, null, (uint32)vkSwapchains.Count, vkPresentBarriers.Ptr);
						},
						false, true);
				}
			}
			public override void present() {
				//CC_PROFILE(CCVKDevicePresent);
				bool isGFXDeviceNeedsPresent = /*_xr ? _xr.isGFXDeviceNeedsPresent(_api) :*/ true;
				var queue = (CCVKQueue)_queue;
				_numDrawCalls = queue.[Friend]_numDrawCalls;
				_numInstances = queue.[Friend]_numInstances;
				_numTriangles = queue.[Friend]_numTriangles;
				queue.[Friend]_numDrawCalls = 0;
				queue.[Friend]_numInstances = 0;
				queue.[Friend]_numTriangles = 0;

				if (!_gpuTransportHub.empty(false)) _gpuTransportHub.packageForFlight(false);
				if (!_gpuTransportHub.empty(true)) _gpuTransportHub.packageForFlight(true);

#if CC_SWAPPY_ENABLED
				// tripple buffer?
				// static vector<uint8> queueFmlIdxBuff(_gpuDevice.backBufferCount);
				// std.iota(std.begin(queueFmlIdxBuff), std.end(queueFmlIdxBuff), 0);
				SwappyVk_setQueueFamilyIndex(_gpuDevice.vkDevice, queue.gpuQueue().vkQueue, queue.gpuQueue().queueFamilyIndex);
				auto vkCCPresentFunc = SwappyVk_queuePresent;
#else
				VulkanNative.vkQueuePresentKHRFunction vkCCPresentFunc = => VulkanNative.vkQueuePresentKHR;
#endif

				if (!vkSwapchains.IsEmpty) { // don't present if not acquired
					VkPresentInfoKHR presentInfo = .(){ sType = .VK_STRUCTURE_TYPE_PRESENT_INFO_KHR };
					presentInfo.waitSemaphoreCount = (uint32)queue.gpuQueue().lastSignaledSemaphores.Count;
					presentInfo.pWaitSemaphores = queue.gpuQueue().lastSignaledSemaphores.Ptr;
					presentInfo.swapchainCount = (uint32)vkSwapchains.Count;
					presentInfo.pSwapchains = vkSwapchains.Ptr;
					presentInfo.pImageIndices = vkSwapchainIndices.Ptr;

					VkResult res = !isGFXDeviceNeedsPresent ? .VK_SUCCESS : vkCCPresentFunc(queue.gpuQueue().vkQueue, &presentInfo);
					for (var gpuSwapchain in gpuSwapchains) {
						gpuSwapchain.lastPresentResult = res;
					}
				}

				_gpuDevice.curBackBufferIndex = (_gpuDevice.curBackBufferIndex + 1) % _gpuDevice.backBufferCount;

				uint32 fenceCount = gpuFencePool().size();
				if (fenceCount != 0) {
					VK_CHECK!(vkWaitForFences(_gpuDevice.vkDevice, fenceCount,
						gpuFencePool().data(), VK_TRUE, DEFAULT_TIMEOUT));
				}

				gpuFencePool().reset();
				gpuRecycleBin().clear();
				gpuStagingBufferPool().reset();
				/*if (_xr) {
					_xr.postGFXDevicePresent(_api);
				}*/
			}

			[Inline] public bool checkExtension(char8* extensionToCheck) {
				return _extensions.FindIndex(scope [&extensionToCheck](ext) => {
					return String.Equals(ext, extensionToCheck);
				}) != -1;
			}

			[Inline] public CCVKGPUDevice gpuDevice() { return _gpuDevice; }
			[Inline] public CCVKGPUContext gpuContext() { return _gpuContext; }

			[Inline] public CCVKGPUBufferHub gpuBufferHub() { return _gpuBufferHub; }
			[Inline] public CCVKGPUTransportHub gpuTransportHub() { return _gpuTransportHub; }
			[Inline] public CCVKGPUDescriptorHub gpuDescriptorHub() { return _gpuDescriptorHub; }
			[Inline] public CCVKGPUSemaphorePool gpuSemaphorePool() { return _gpuSemaphorePool; }
			[Inline] public CCVKGPUBarrierManager gpuBarrierManager() { return _gpuBarrierManager; }
			[Inline] public CCVKGPUDescriptorSetHub gpuDescriptorSetHub() { return _gpuDescriptorSetHub; }
			[Inline] public CCVKGPUInputAssemblerHub gpuIAHub() { return _gpuIAHub; }
			[Inline] public CCVKPipelineCache pipelineCache() { return _pipelineCache; }

			public CCVKGPUFencePool gpuFencePool() { return _gpuFencePools[_gpuDevice.curBackBufferIndex]; }
			public CCVKGPURecycleBin gpuRecycleBin() { return _gpuRecycleBins[_gpuDevice.curBackBufferIndex]; }
			public CCVKGPUStagingBufferPool gpuStagingBufferPool() { return _gpuStagingBufferPools[_gpuDevice.curBackBufferIndex]; }
			public void waitAllFences() {
				List<VkFence> fences = scope .();
				fences.Clear();

				for (var fencePool in ref _gpuFencePools) {
					fences.AddRange(Span<VkFence>(fencePool.data(), fencePool.size()));
				}

				if (!fences.IsEmpty) {
					VK_CHECK!(vkWaitForFences(_gpuDevice.vkDevice, (uint32)fences.Count, fences.Ptr, VK_TRUE, DEFAULT_TIMEOUT));

					for (var fencePool in _gpuFencePools) {
						fencePool.reset();
					}
				}
			}

			public void updateBackBufferCount(uint32 backBufferCount) {
				if (backBufferCount <= _gpuDevice.backBufferCount) return;
				for (uint32 i = _gpuDevice.backBufferCount; i < backBufferCount; i++) {
					_gpuFencePools.Add(new CCVKGPUFencePool(_gpuDevice));
					_gpuRecycleBins.Add(new CCVKGPURecycleBin(_gpuDevice));
					_gpuStagingBufferPools.Add(new CCVKGPUStagingBufferPool(_gpuDevice));
				}
				_gpuBufferHub.updateBackBufferCount(backBufferCount);
				_gpuDescriptorSetHub.updateBackBufferCount(backBufferCount);
				_gpuDevice.backBufferCount = backBufferCount;
			}
			public override SampleCount getMaxSampleCount(Format format, TextureUsage usage, TextureFlags flags) {
				var vkFormat = mapVkFormat(format, gpuDevice());
				var usages = mapVkImageUsageFlags(usage, flags);

				VkImageFormatProperties imageFormatProperties = .();
				vkGetPhysicalDeviceImageFormatProperties(_gpuContext.physicalDevice, vkFormat, .VK_IMAGE_TYPE_2D,
					.VK_IMAGE_TILING_OPTIMAL, usages, 0, &imageFormatProperties);

				if (imageFormatProperties.sampleCounts & .VK_SAMPLE_COUNT_64_BIT != 0) return SampleCount.X64;
				if (imageFormatProperties.sampleCounts & .VK_SAMPLE_COUNT_32_BIT != 0) return SampleCount.X32;
				if (imageFormatProperties.sampleCounts & .VK_SAMPLE_COUNT_16_BIT != 0) return SampleCount.X16;
				if (imageFormatProperties.sampleCounts & .VK_SAMPLE_COUNT_8_BIT != 0)  return SampleCount.X8;
				if (imageFormatProperties.sampleCounts & .VK_SAMPLE_COUNT_4_BIT != 0)  return SampleCount.X4;
				if (imageFormatProperties.sampleCounts & .VK_SAMPLE_COUNT_2_BIT != 0)  return SampleCount.X2;

				return SampleCount.X1;
			}
		protected static new CCVKDevice instance;

			protected this() {
				_api = API.VULKAN;
				_deviceName = "Vulkan";

				_caps.supportQuery = true;
				_caps.clipSpaceMinZ = 0.0F;
				_caps.screenSpaceSignY = -1.0F;
				_caps.clipSpaceSignY = -1.0F;
				CCVKDevice.instance = this;
			}

			protected override bool doInit(in DeviceInfo info) {
				/*_xr = CC_GET_XR_INTERFACE();
				if (_xr) {
					_xr.preGFXDeviceInitialize(_api);
				}*/
				_gpuContext = new CCVKGPUContext();
				if (!_gpuContext.initialize()) {
					return false;
				}

				readonly ref VkPhysicalDeviceFeatures2 deviceFeatures2 = ref _gpuContext.physicalDeviceFeatures2;
				readonly ref VkPhysicalDeviceFeatures deviceFeatures = ref deviceFeatures2.features;
				// const VkPhysicalDeviceVulkan11Features &deviceVulkan11Features = _gpuContext.physicalDeviceVulkan11Features;
				// const VkPhysicalDeviceVulkan12Features &deviceVulkan12Features = _gpuContext.physicalDeviceVulkan12Features;

				///////////////////// Device Creation /////////////////////

				_gpuDevice = new CCVKGPUDevice();
				_gpuDevice.minorVersion = _gpuContext.minorVersion;

				// only enable the absolute essentials
				List<char8*> requestedLayers = scope .();
				List<char8*> requestedExtensions = scope .(){
					VK_KHR_SWAPCHAIN_EXTENSION_NAME,
				};
				requestedExtensions.Add(VK_KHR_FRAGMENT_SHADING_RATE_EXTENSION_NAME);
#if DEBUG
				requestedExtensions.Add(VK_EXT_DEBUG_MARKER_EXTENSION_NAME);
#endif
				if (_gpuDevice.minorVersion < 2) {
					requestedExtensions.Add(VK_KHR_CREATE_RENDERPASS_2_EXTENSION_NAME);
				}
				if (_gpuDevice.minorVersion < 1) {
					requestedExtensions.Add(VK_KHR_DEDICATED_ALLOCATION_EXTENSION_NAME);
					requestedExtensions.Add(VK_KHR_GET_MEMORY_REQUIREMENTS_2_EXTENSION_NAME);
					requestedExtensions.Add(VK_KHR_DESCRIPTOR_UPDATE_TEMPLATE_EXTENSION_NAME);
				}

				VkPhysicalDeviceFeatures2 requestedFeatures2 = .(){ sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2 };
				VkPhysicalDeviceVulkan11Features requestedVulkan11Features= .(){ sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES };
				VkPhysicalDeviceVulkan12Features requestedVulkan12Features= .(){ sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES };
				// features should be enabled like this:
				requestedFeatures2.features.textureCompressionASTC_LDR = deviceFeatures.textureCompressionASTC_LDR;
				requestedFeatures2.features.textureCompressionBC = deviceFeatures.textureCompressionBC;
				requestedFeatures2.features.textureCompressionETC2 = deviceFeatures.textureCompressionETC2;
				requestedFeatures2.features.samplerAnisotropy = deviceFeatures.samplerAnisotropy;
				requestedFeatures2.features.depthBounds = deviceFeatures.depthBounds;
				requestedFeatures2.features.multiDrawIndirect = deviceFeatures.multiDrawIndirect;
				// requestedFeatures2.features.se
				requestedVulkan12Features.separateDepthStencilLayouts = _gpuContext.physicalDeviceVulkan12Features.separateDepthStencilLayouts;

				VkPhysicalDeviceFragmentShadingRateFeaturesKHR shadingRateRequest = .();
				shadingRateRequest.sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_FEATURES_KHR;
				shadingRateRequest.attachmentFragmentShadingRate = _gpuContext.physicalDeviceFragmentShadingRateFeatures.attachmentFragmentShadingRate;
				shadingRateRequest.pipelineFragmentShadingRate = _gpuContext.physicalDeviceFragmentShadingRateFeatures.pipelineFragmentShadingRate;

				requestedVulkan12Features.pNext = &shadingRateRequest;

				if (_gpuContext.validationEnabled) {
					requestedLayers.Add("VK_LAYER_KHRONOS_validation");
				}

				// check extensions
				uint32 availableLayerCount = 0;
				VK_CHECK!(vkEnumerateDeviceLayerProperties(_gpuContext.physicalDevice, &availableLayerCount, null));
				_gpuDevice.layers.Resize(availableLayerCount);
				VK_CHECK!(vkEnumerateDeviceLayerProperties(_gpuContext.physicalDevice, &availableLayerCount, _gpuDevice.layers.Ptr));

				uint32 availableExtensionCount = 0;
				VK_CHECK!(vkEnumerateDeviceExtensionProperties(_gpuContext.physicalDevice, null, &availableExtensionCount, null));
				_gpuDevice.extensions.Resize(availableExtensionCount);
				VK_CHECK!(vkEnumerateDeviceExtensionProperties(_gpuContext.physicalDevice, null, &availableExtensionCount, _gpuDevice.extensions.Ptr));

/*#if CC_SWAPPY_ENABLED
				uint32 swappyRequiredExtensionCount = 0;
				SwappyVk_determineDeviceExtensions(_gpuContext.physicalDevice, availableExtensionCount,
					_gpuDevice.extensions.Ptr, &swappyRequiredExtensionCount, null);
				List<char*> swappyRequiredExtensions(swappyRequiredExtensionCount);
				List<char> swappyRequiredExtensionsData(swappyRequiredExtensionCount * (VK_MAX_EXTENSION_NAME_SIZE + 1));
				for (uint32 i = 0; i < swappyRequiredExtensionCount; i++) {
					swappyRequiredExtensions[i] = &swappyRequiredExtensionsData[i * (VK_MAX_EXTENSION_NAME_SIZE + 1)];
				}
				SwappyVk_determineDeviceExtensions(_gpuContext.physicalDevice, availableExtensionCount,
					_gpuDevice.extensions.Ptr, &swappyRequiredExtensionCount, swappyRequiredExtensions.Ptr);
				List<ccstd.string> swappyRequiredExtList(swappyRequiredExtensionCount);

				for (size_t i = 0; i < swappyRequiredExtensionCount; ++i) {
					swappyRequiredExtList[i] = swappyRequiredExtensions[i];
					requestedExtensions.Add(swappyRequiredExtList[i]);
				}
#endif*/

				// just filter out the unsupported layers & extensions
				for (char8* layer in requestedLayers) {
					if (isLayerSupported(layer, _gpuDevice.layers)) {
						_layers.Add(layer);
					}
				}
				for (char8* @extension in requestedExtensions) {
					if (isExtensionSupported(@extension, _gpuDevice.extensions)) {
						_extensions.Add(@extension);
					}
				}

				// prepare the device queues
				uint32 queueFamilyPropertiesCount = (uint32)_gpuContext.queueFamilyProperties.Count;
				List<VkDeviceQueueCreateInfo> queueCreateInfos = scope .()..Resize(queueFamilyPropertiesCount, .(){ sType = .VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO });
				List<List<float>> queuePriorities = scope .()..Resize(queueFamilyPropertiesCount);

				for (uint32 queueFamilyIndex = 0U; queueFamilyIndex < queueFamilyPropertiesCount; ++queueFamilyIndex) {
					readonly ref VkQueueFamilyProperties queueFamilyProperty = ref _gpuContext.queueFamilyProperties[queueFamilyIndex];

					queuePriorities[queueFamilyIndex].Resize(queueFamilyProperty.queueCount, 1.0F);

					ref VkDeviceQueueCreateInfo queueCreateInfo = ref queueCreateInfos[queueFamilyIndex];

					queueCreateInfo.queueFamilyIndex = queueFamilyIndex;
					queueCreateInfo.queueCount = queueFamilyProperty.queueCount;
					queueCreateInfo.pQueuePriorities = queuePriorities[queueFamilyIndex].Ptr;
				}

				VkDeviceCreateInfo deviceCreateInfo= .(){ sType = .VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO };

				deviceCreateInfo.queueCreateInfoCount = (uint32)queueCreateInfos.Count;
				deviceCreateInfo.pQueueCreateInfos = queueCreateInfos.Ptr;
				deviceCreateInfo.enabledLayerCount = (uint32)_layers.Count;
				deviceCreateInfo.ppEnabledLayerNames = _layers.Ptr;
				deviceCreateInfo.enabledExtensionCount = (uint32)_extensions.Count;
				deviceCreateInfo.ppEnabledExtensionNames = _extensions.Ptr;
				if (_gpuDevice.minorVersion < 1 && !_gpuContext.checkExtension(scope .(VulkanNative.VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME))) {
					deviceCreateInfo.pEnabledFeatures = &requestedFeatures2.features;
				}
				else {
					deviceCreateInfo.pNext = &requestedFeatures2;
					if (_gpuDevice.minorVersion >= 2) {
						requestedFeatures2.pNext = &requestedVulkan11Features;
						requestedVulkan11Features.pNext = &requestedVulkan12Features;
					}
				}

				//if (_xr) {
				//	_gpuDevice.vkDevice = _xr.createXRVulkanDevice(&deviceCreateInfo);
				//}
				//else {
					VK_CHECK!(vkCreateDevice(_gpuContext.physicalDevice, &deviceCreateInfo, null, &_gpuDevice.vkDevice));
				//}
				volkLoadDevice(_gpuDevice.vkDevice);

				SPIRVUtils.getInstance().initialize((int32)_gpuDevice.minorVersion);

				///////////////////// Gather Device Properties /////////////////////

				delegate void(VkFormat* formats, uint32 count, VkFormat* pFormat) findPreferredDepthFormat = scope [&]( formats, count, pFormat) => {
					for (uint32 i = 0; i < count; ++i) {
						VkFormat format = formats[i];
						VkFormatProperties formatProperties = .();
						vkGetPhysicalDeviceFormatProperties(_gpuContext.physicalDevice, format, &formatProperties);
						// Format must support depth stencil attachment for optimal tiling
						if (formatProperties.optimalTilingFeatures & .VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT != 0) {
							if (formatProperties.optimalTilingFeatures & .VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT != 0) {
								*pFormat = format;
								break;
							}
						}
					}
					};

				VkFormat[] depthFormatPriorityList = scope .(
					.VK_FORMAT_D32_SFLOAT,
					.VK_FORMAT_X8_D24_UNORM_PACK32,
					.VK_FORMAT_D16_UNORM,
				);
				findPreferredDepthFormat(depthFormatPriorityList.Ptr, 3, &_gpuDevice.depthFormat);

				VkFormat[] depthStencilFormatPriorityList = scope .(
					.VK_FORMAT_D24_UNORM_S8_UINT,
					.VK_FORMAT_D32_SFLOAT_S8_UINT,
					.VK_FORMAT_D16_UNORM_S8_UINT,
				);
				findPreferredDepthFormat(depthStencilFormatPriorityList.Ptr, 3, &_gpuDevice.depthStencilFormat);

				initDeviceFeature();
				initFormatFeature();

				String compressedFmts = scope .();

				if (getFormatFeatures(Format.BC1_SRGB_ALPHA) != FormatFeature.NONE) {
					compressedFmts.Append("dxt ");
				}

				if (getFormatFeatures(Format.ETC2_RGBA8) != FormatFeature.NONE) {
					compressedFmts .Append( "etc2 ");
				}

				if (getFormatFeatures(Format.ASTC_RGBA_4X4) != FormatFeature.NONE) {
					compressedFmts .Append( "astc ");
				}

				if (getFormatFeatures(Format.PVRTC_RGBA2) != FormatFeature.NONE) {
					compressedFmts .Append( "pvrtc ");
				}

				_gpuDevice.useMultiDrawIndirect = deviceFeatures.multiDrawIndirect;
				_gpuDevice.useDescriptorUpdateTemplate = _gpuDevice.minorVersion > 0 || checkExtension(VK_KHR_DESCRIPTOR_UPDATE_TEMPLATE_EXTENSION_NAME);

				//if (_gpuDevice.minorVersion > 1) {
					_gpuDevice.createRenderPass2 = => VulkanNative.vkCreateRenderPass2;
				//}
				//else if (checkExtension(VK_KHR_CREATE_RENDERPASS_2_EXTENSION_NAME)) {
				//	_gpuDevice.createRenderPass2 = VulkanNative.vkCreateRenderPass2KHR;
				//}
				//else {
				//	_gpuDevice.createRenderPass2 = VulkanNative.vkCreateRenderPass2KHRFallback;
				//}

				readonly ref VkPhysicalDeviceLimits limits = ref _gpuContext.physicalDeviceProperties.limits;
				_caps.maxVertexAttributes = limits.maxVertexInputAttributes;
				_caps.maxVertexUniformVectors = limits.maxUniformBufferRange / 16;
				_caps.maxFragmentUniformVectors = limits.maxUniformBufferRange / 16;
				_caps.maxUniformBufferBindings = limits.maxDescriptorSetUniformBuffers;
				_caps.maxUniformBlockSize = limits.maxUniformBufferRange;
				_caps.maxShaderStorageBlockSize = limits.maxStorageBufferRange;
				_caps.maxShaderStorageBufferBindings = limits.maxDescriptorSetStorageBuffers;
				_caps.maxTextureUnits = limits.maxDescriptorSetSampledImages;
				_caps.maxVertexTextureUnits = limits.maxPerStageDescriptorSampledImages;
				_caps.maxColorRenderTargets = limits.maxColorAttachments;
				_caps.maxTextureSize = limits.maxImageDimension2D;
				_caps.maxCubeMapTextureSize = limits.maxImageDimensionCube;
				_caps.maxArrayTextureLayers = limits.maxImageArrayLayers;
				_caps.max3DTextureSize = limits.maxImageDimension3D;
				_caps.uboOffsetAlignment = (uint32)limits.minUniformBufferOffsetAlignment;
				// compute shaders
				_caps.maxComputeSharedMemorySize = limits.maxComputeSharedMemorySize;
				_caps.maxComputeWorkGroupInvocations = limits.maxComputeWorkGroupInvocations;
				_caps.maxComputeWorkGroupCount = .(){x= limits.maxComputeWorkGroupCount[0], y=limits.maxComputeWorkGroupCount[1], z=limits.maxComputeWorkGroupCount[2] };
				_caps.maxComputeWorkGroupSize = .(){ x=limits.maxComputeWorkGroupSize[0], y=limits.maxComputeWorkGroupSize[1], z=limits.maxComputeWorkGroupSize[2] };
/*#if defined(VK_USE_PLATFORM_ANDROID_KHR)
				// UNASSIGNED-BestPractices-vkCreateComputePipelines-compute-work-group-size
				_caps.maxComputeWorkGroupInvocations = std.min(_caps.maxComputeWorkGroupInvocations, 64U);
#endif // defined(VK_USE_PLATFORM_ANDROID_KHR)*/
				initExtensionCapability();

				///////////////////// Resource Initialization /////////////////////

				QueueInfo queueInfo;
				queueInfo.type = QueueType.GRAPHICS;
				_queue = createQueue(queueInfo);

				QueryPoolInfo queryPoolInfo = .(){ type = QueryType.OCCLUSION, maxQueryObjects = DEFAULT_MAX_QUERY_OBJECTS, forceWait = false };
				_queryPool = createQueryPool(queryPoolInfo);

				CommandBufferInfo cmdBuffInfo;
				cmdBuffInfo.type = CommandBufferType.PRIMARY;
				cmdBuffInfo.queue = _queue;
				_cmdBuff = createCommandBuffer(cmdBuffInfo);

				VmaAllocatorCreateInfo allocatorInfo = .();
				allocatorInfo.physicalDevice = _gpuContext.physicalDevice;
				allocatorInfo.device = _gpuDevice.vkDevice;
				allocatorInfo.instance = _gpuContext.vkInstance;

				VmaVulkanFunctions vmaVulkanFunc = .();
				vmaVulkanFunc.vkAllocateMemory = VulkanNative.vkAllocateMemory;
				vmaVulkanFunc.vkBindBufferMemory = VulkanNative.vkBindBufferMemory;
				vmaVulkanFunc.vkBindImageMemory = VulkanNative.vkBindImageMemory;
				vmaVulkanFunc.vkCreateBuffer = VulkanNative.vkCreateBuffer;
				vmaVulkanFunc.vkCreateImage = VulkanNative.vkCreateImage;
				vmaVulkanFunc.vkDestroyBuffer = VulkanNative.vkDestroyBuffer;
				vmaVulkanFunc.vkDestroyImage = VulkanNative.vkDestroyImage;
				vmaVulkanFunc.vkFlushMappedMemoryRanges = VulkanNative.vkFlushMappedMemoryRanges;
				vmaVulkanFunc.vkFreeMemory = VulkanNative.vkFreeMemory;
				vmaVulkanFunc.vkGetBufferMemoryRequirements = VulkanNative.vkGetBufferMemoryRequirements;
				vmaVulkanFunc.vkGetImageMemoryRequirements = VulkanNative.vkGetImageMemoryRequirements;
				vmaVulkanFunc.vkGetPhysicalDeviceMemoryProperties = VulkanNative.vkGetPhysicalDeviceMemoryProperties;
				vmaVulkanFunc.vkGetPhysicalDeviceProperties = VulkanNative.vkGetPhysicalDeviceProperties;
				vmaVulkanFunc.vkInvalidateMappedMemoryRanges = VulkanNative.vkInvalidateMappedMemoryRanges;
				vmaVulkanFunc.vkMapMemory = VulkanNative.vkMapMemory;
				vmaVulkanFunc.vkUnmapMemory = VulkanNative.vkUnmapMemory;
				vmaVulkanFunc.vkCmdCopyBuffer = VulkanNative.vkCmdCopyBuffer;

				if (_gpuDevice.minorVersion > 0) {
					allocatorInfo.flags |= .VMA_ALLOCATOR_CREATE_KHR_DEDICATED_ALLOCATION_BIT;
					vmaVulkanFunc.vkGetBufferMemoryRequirements2KHR = VulkanNative.vkGetBufferMemoryRequirements2;
					vmaVulkanFunc.vkGetImageMemoryRequirements2KHR = VulkanNative.vkGetImageMemoryRequirements2;
					vmaVulkanFunc.vkBindBufferMemory2KHR = VulkanNative.vkBindBufferMemory2;
					vmaVulkanFunc.vkBindImageMemory2KHR = VulkanNative.vkBindImageMemory2;
				}
				else {
					if (checkExtension(VK_KHR_DEDICATED_ALLOCATION_EXTENSION_NAME) &&
						checkExtension(VK_KHR_GET_MEMORY_REQUIREMENTS_2_EXTENSION_NAME)) {
						allocatorInfo.flags |= .VMA_ALLOCATOR_CREATE_KHR_DEDICATED_ALLOCATION_BIT;
						vmaVulkanFunc.vkGetBufferMemoryRequirements2KHR = VulkanNative.vkGetBufferMemoryRequirements2KHR;
						vmaVulkanFunc.vkGetImageMemoryRequirements2KHR = VulkanNative.vkGetImageMemoryRequirements2KHR;
					}
					if (checkExtension(VK_KHR_BIND_MEMORY_2_EXTENSION_NAME)) {
						vmaVulkanFunc.vkBindBufferMemory2KHR = VulkanNative.vkBindBufferMemory2KHR;
						vmaVulkanFunc.vkBindImageMemory2KHR = VulkanNative.vkBindImageMemory2KHR;
					}
				}
				if (checkExtension(VK_EXT_MEMORY_BUDGET_EXTENSION_NAME)) {
					if (_gpuDevice.minorVersion > 0) {
						vmaVulkanFunc.vkGetPhysicalDeviceMemoryProperties2KHR = VulkanNative.vkGetPhysicalDeviceMemoryProperties2;
					}
					else if (checkExtension(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME)) {
						vmaVulkanFunc.vkGetPhysicalDeviceMemoryProperties2KHR = VulkanNative.vkGetPhysicalDeviceMemoryProperties2KHR;
					}
				}

				allocatorInfo.pVulkanFunctions = &vmaVulkanFunc;

				VK_CHECK!(VulkanMemoryAllocator.vmaCreateAllocator(&allocatorInfo, &_gpuDevice.memoryAllocator));

				uint32 backBufferCount = _gpuDevice.backBufferCount;
				for (uint32 i = 0U; i < backBufferCount; i++) {
					_gpuFencePools.Add(new CCVKGPUFencePool(_gpuDevice));
					_gpuRecycleBins.Add(new CCVKGPURecycleBin(_gpuDevice));
					_gpuStagingBufferPools.Add(new CCVKGPUStagingBufferPool(_gpuDevice));
				}

				_gpuBufferHub = new CCVKGPUBufferHub(_gpuDevice);
				_gpuIAHub = new CCVKGPUInputAssemblerHub(_gpuDevice);
				_gpuTransportHub = new CCVKGPUTransportHub(_gpuDevice, ((CCVKQueue)_queue).gpuQueue());
				_gpuDescriptorHub = new CCVKGPUDescriptorHub(_gpuDevice);
				_gpuSemaphorePool = new CCVKGPUSemaphorePool(_gpuDevice);
				_gpuBarrierManager = new CCVKGPUBarrierManager(_gpuDevice);
				_gpuDescriptorSetHub = new CCVKGPUDescriptorSetHub(_gpuDevice);

				_gpuDevice.defaultSampler = new CCVKGPUSampler();
				_gpuDevice.defaultSampler.init();

				_gpuDevice.defaultTexture = new CCVKGPUTexture();
				_gpuDevice.defaultTexture.format = Format.RGBA8;
				_gpuDevice.defaultTexture.usage = TextureUsageBit.SAMPLED | TextureUsage.STORAGE;
				_gpuDevice.defaultTexture.width = _gpuDevice.defaultTexture.height = 1U;
				_gpuDevice.defaultTexture.size = formatSize(Format.RGBA8, 1U, 1U, 1U);
				_gpuDevice.defaultTexture.init();

				_gpuDevice.defaultTextureView = new CCVKGPUTextureView();
				_gpuDevice.defaultTextureView.gpuTexture = _gpuDevice.defaultTexture;
				_gpuDevice.defaultTextureView.format = Format.RGBA8;
				_gpuDevice.defaultTextureView.init();

				ThsvsImageBarrier barrier = .();
				barrier.nextAccessCount = 1;
				barrier.pNextAccesses = getAccessType(AccessFlagBit.VERTEX_SHADER_READ_TEXTURE);
				barrier.image = _gpuDevice.defaultTexture.vkImage;
				barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.subresourceRange.aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
				barrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
				barrier.subresourceRange.layerCount = VK_REMAINING_ARRAY_LAYERS;
				gpuTransportHub().checkIn(
					scope [&barrier](gpuCommandBuffer) => {
						cmdFuncCCVKImageMemoryBarrier(gpuCommandBuffer, barrier);
					},
					true);

				_gpuDevice.defaultBuffer = new CCVKGPUBuffer();
				_gpuDevice.defaultBuffer.usage = BufferUsage.UNIFORM | BufferUsage.STORAGE;
				_gpuDevice.defaultBuffer.memUsage = MemoryUsage.HOST | MemoryUsage.DEVICE;
				_gpuDevice.defaultBuffer.size = _gpuDevice.defaultBuffer.stride = 16U;
				_gpuDevice.defaultBuffer.count = 1U;
				_gpuDevice.defaultBuffer.init();

				getAccessTypes(AccessFlagBit.COLOR_ATTACHMENT_WRITE, ref _gpuDevice.defaultColorBarrier.nextAccesses);
				cmdFuncCCVKCreateGeneralBarrier(this, _gpuDevice.defaultColorBarrier);

				getAccessTypes(AccessFlagBit.DEPTH_STENCIL_ATTACHMENT_WRITE, ref _gpuDevice.defaultDepthStencilBarrier.nextAccesses);
				cmdFuncCCVKCreateGeneralBarrier(this, _gpuDevice.defaultDepthStencilBarrier);

				_pipelineCache = new CCVKPipelineCache();
				_pipelineCache.init(_gpuDevice.vkDevice);

				///////////////////// Print Debug Info /////////////////////

				String instanceLayers = scope .();
				String instanceExtensions = scope .();
				String deviceLayers = scope .();
				String deviceExtensions = scope .();
				for (char8* layer in _gpuContext.layers) {
					instanceLayers.Append(scope $"{layer} ");
				}
				for (char8* @extension in _gpuContext.extensions) {
					instanceExtensions.Append(scope $"{@extension} ");
				}
				for (char8* layer in _layers) {
					deviceLayers.Append(scope $"{layer} ");
				}
				for (char8* @extension in _extensions) {
					deviceExtensions.Append(scope $"{@extension} ");
				}

				uint32 apiVersion = _gpuContext.physicalDeviceProperties.apiVersion;
				_renderer = new .(&_gpuContext.physicalDeviceProperties.deviceName);
				_vendor = mapVendorName(_gpuContext.physicalDeviceProperties.vendorID, .. new .());
				_version = new String()..AppendF("{}.{}.{}", VK_API_VERSION_MAJOR(apiVersion),
					VK_API_VERSION_MINOR(apiVersion), VK_API_VERSION_PATCH(apiVersion));

				WriteInfo("Vulkan device initialized.");
				WriteInfo("RENDERER: {}", _renderer);
				WriteInfo("VENDOR: {}", _vendor);
				WriteInfo("VERSION: {}", _version);
				WriteInfo("INSTANCE_LAYERS: {}", instanceLayers);
				WriteInfo("INSTANCE_EXTENSIONS: {}", instanceExtensions);
				WriteInfo("DEVICE_LAYERS: {}", deviceLayers);
				WriteInfo("DEVICE_EXTENSIONS: {}", deviceExtensions);
				WriteInfo("COMPRESSED_FORMATS: {}", compressedFmts);

				/*if (_xr) {
					cc.gfx.CCVKGPUQueue* vkQueue = ((cc.gfx.CCVKQueue)getQueue()).gpuQueue();
					_xr.setXRConfig(xr.XRConfigKey.VK_QUEUE_FAMILY_INDEX, (int)vkQueue.queueFamilyIndex);
					_xr.postGFXDeviceInitialize(_api);
				}*/
				return true;
			}
			protected override void doDestroy() {
				waitAllFences();

				SPIRVUtils.getInstance().destroy();

				if (_gpuDevice != null) {
					_gpuDevice.defaultBuffer = null;
					_gpuDevice.defaultTexture = null;
					_gpuDevice.defaultTextureView = null;
					_gpuDevice.defaultSampler = null;
				}

				CC_SAFE_DESTROY_AND_DELETE!(_queryPool);
					CC_SAFE_DESTROY_AND_DELETE!(_queue);
					CC_SAFE_DESTROY_AND_DELETE!(_cmdBuff);

					_gpuStagingBufferPools.Clear();
				_gpuFencePools.Clear();

				_gpuBufferHub = null;
				_gpuTransportHub = null;
				_gpuSemaphorePool = null;
				_gpuDescriptorHub = null;
				_gpuBarrierManager = null;
				_gpuDescriptorSetHub = null;
				_gpuIAHub = null;

				if (_gpuDevice != null) {
					uint32 backBufferCount = _gpuDevice.backBufferCount;
					for (uint32 i = 0U; i < backBufferCount; i++) {
						_gpuRecycleBins[i].clear();
					}
				}
				_gpuStagingBufferPools.Clear();
				_gpuRecycleBins.Clear();
				_gpuFencePools.Clear();

				if (_gpuDevice != null) {
					delete _pipelineCache;
					_pipelineCache = null;

					if (_gpuDevice.memoryAllocator != default) {
						VmaTotalStatistics stats = .();
						vmaCalculateStatistics(_gpuDevice.memoryAllocator, &stats);
						WriteInfo("Total device memory leaked: %d bytes.", stats.total.usedBytes);
						Runtime.Assert(_memoryStatus.bufferSize == 0);  // Buffer memory leaked.
						Runtime.Assert(_memoryStatus.textureSize == 0); // Texture memory leaked.

						vmaDestroyAllocator(_gpuDevice.memoryAllocator);
						_gpuDevice.memoryAllocator = default;
					}

					for (var it in _gpuDevice.[Friend]_commandBufferPools) {
						delete it.value;
					}
					_gpuDevice.[Friend]_commandBufferPools.Clear();
					_gpuDevice.[Friend]_descriptorSetPools.Clear();

					if (_gpuDevice.vkDevice != .Null) {
						vkDestroyDevice(_gpuDevice.vkDevice, null);
						_gpuDevice.vkDevice = .Null;
					}

					_gpuDevice = null;
				}

				_gpuContext = null;
			}
			protected override CommandBuffer createCommandBuffer(in CommandBufferInfo info, bool hasAgent) {
				return new CCVKCommandBuffer();
			}
			protected override CommandQueue createQueue() {
				return new CCVKQueue();
			}
			protected override QueryPool createQueryPool() {
				return new CCVKQueryPool();
			}
			protected override Swapchain createSwapchain() {
				/*if (_xr) {
					_xr.createXRSwapchains();
				}*/
				return new CCVKSwapchain();
			}
			protected override Buffer createBuffer() {
				return new CCVKBuffer();
			}
			protected override Texture createTexture() {
				return new CCVKTexture();
			}
			protected override Shader createShader() {
				return new CCVKShader();
			}
			protected override InputAssembler createInputAssembler() {
				return new CCVKInputAssembler();
			}
			protected override RenderPass createRenderPass() {
				return new CCVKRenderPass();
			}
			protected override Framebuffer createFramebuffer() {
				return new CCVKFramebuffer();
			}
			protected override DescriptorSet createDescriptorSet() {
				return new CCVKDescriptorSet();
			}
			protected override DescriptorSetLayout createDescriptorSetLayout() {
				return new CCVKDescriptorSetLayout();
			}
			protected override PipelineLayout createPipelineLayout() {
				return new CCVKPipelineLayout();
			}
			protected override PipelineState createPipelineState() {
				return new CCVKPipelineState();
			}

			protected override Sampler createSampler(in SamplerInfo info) {
				return new CCVKSampler(info);
			}
			protected override GeneralBarrier createGeneralBarrier(in GeneralBarrierInfo info) {
				return new CCVKGeneralBarrier(info);
			}
			protected override TextureBarrier createTextureBarrier(in TextureBarrierInfo info) {
				return new CCVKTextureBarrier(info);
			}
			protected override BufferBarrier createBufferBarrier(in BufferBarrierInfo info) {
				return new CCVKBufferBarrier(info);
			}

			public override void copyBuffersToTexture(uint8** buffers, Texture dst, in BufferTextureCopy* regions, uint32 count) {
				//CC_PROFILE(CCVKDeviceCopyBuffersToTexture);
				gpuTransportHub().checkIn(scope [&/*, &buffers, &dst, &regions, &count*/](gpuCommandBuffer) => {
					cmdFuncCCVKCopyBuffersToTexture(this, buffers, ((CCVKTexture)dst).gpuTexture(), regions, count, gpuCommandBuffer);
					});
			}
			public override void copyTextureToBuffers(Texture srcTexture, uint8** buffers, in BufferTextureCopy* regions, uint32 count) {
				//CC_PROFILE(CCVKDeviceCopyTextureToBuffers);
				uint32 totalSize = 0;
				Format format = srcTexture.getFormat();
				List<(uint32, uint32)> regionOffsetSizes = scope .()..Resize(count);
				for (int i = 0U; i < count; ++i) {
					readonly ref BufferTextureCopy region = ref regions[i];
					uint32 w = region.buffStride > 0 ? region.buffStride : region.texExtent.width;
					uint32 h = region.buffTexHeight > 0 ? region.buffTexHeight : region.texExtent.height;
					uint32 regionSize = formatSize(format, w, h, region.texExtent.depth);
					regionOffsetSizes[i] = (totalSize, regionSize);
					totalSize += regionSize;
				}

				uint32 texelSize = GFX_FORMAT_INFOS[(uint32)format].size;
				CCVKGPUBufferView stagingBuffer = gpuStagingBufferPool().alloc(totalSize, texelSize);

				// make sure the src texture is up-to-date
				waitAllFences();

				_gpuTransportHub.checkIn(
					scope[&](cmdBuffer) => {
						cmdFuncCCVKCopyTextureToBuffers(this, ((CCVKTexture)srcTexture).gpuTexture(), stagingBuffer, regions, count, cmdBuffer);
					},
					true);

				for (uint32 i = 0; i < count; ++i) {
					uint32 regionOffset = 0;
					uint32 regionSize = 0;
					(regionOffset, regionSize) = regionOffsetSizes[i];
					Internal.MemCpy(buffers[i], stagingBuffer.mappedData() + regionOffset, regionSize);
				}
			}
			public override void getQueryPoolResults(QueryPool queryPool) {
				//CC_PROFILE(CCVKDeviceGetQueryPoolResults);
				var vkQueryPool = (CCVKQueryPool)queryPool;
				var queryCount = (uint32)vkQueryPool.[Friend]_ids.Count;
				Runtime.Assert(queryCount <= vkQueryPool.getMaxQueryObjects());

				bool bWait = queryPool.getForceWait();
				uint32 width = bWait ? 1U : 2U;
				uint64 stride = sizeof(uint64) * width;
				VkQueryResultFlags flag = bWait ? .VK_QUERY_RESULT_WAIT_BIT : .VK_QUERY_RESULT_WITH_AVAILABILITY_BIT;
				List<uint64> results = scope .()..Resize(queryCount * width, 0);

				if (queryCount > 0U) {
					VkResult result = vkGetQueryPoolResults(
						gpuDevice().vkDevice,
						vkQueryPool.[Friend]_gpuQueryPool.vkPool,
						0,
						queryCount,
						(uint)queryCount * stride,
						results.Ptr,
						stride,
						.VK_QUERY_RESULT_64_BIT | flag);
					Runtime.Assert(result == .VK_SUCCESS || result == .VK_NOT_READY);
				}

				Dictionary<uint32, uint64> mapResults = scope .();
				for (uint32 queryId = 0; queryId < queryCount; queryId++) {
					uint32 offset = queryId * width;
					if (bWait || results[offset + 1] > 0) {
						uint32 id = vkQueryPool.[Friend]_ids[queryId];
						if (mapResults.ContainsKey(id)) {
							mapResults[id] += results[offset];
						}
						else {
							mapResults[id] = results[offset];
						}
					}
				}

				using(vkQueryPool.[Friend]_mutex.Enter())
				{
					vkQueryPool.[Friend]_results = mapResults;
				}
			}

			protected void initFormatFeature() {
				var formatLen = (int)Format.COUNT;
				VkFormatProperties properties = .();
				VkFormat format = .();
				VkFormatFeatureFlags formatFeature = .();
				for (uint32 i = (uint32)Format.R8; i < formatLen; ++i) {
					if ((Format)i == Format.ETC_RGB8) continue;
					format = mapVkFormat((Format)i, _gpuDevice);
					vkGetPhysicalDeviceFormatProperties(_gpuContext.physicalDevice, format, &properties);

					// render buffer support
					formatFeature = .VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT | .VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT;
					if (properties.optimalTilingFeatures & formatFeature != 0) {
						_formatFeatures[i] |= FormatFeature.RENDER_TARGET;
					}
					// texture storage support
					formatFeature = .VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT;
					if (properties.optimalTilingFeatures & formatFeature != 0) {
						_formatFeatures[i] |= FormatFeature.STORAGE_TEXTURE;
					}
					// sampled render target support
					formatFeature = .VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT;
					if (properties.optimalTilingFeatures & formatFeature != 0) {
						_formatFeatures[i] |= FormatFeature.SAMPLED_TEXTURE;
					}
					// linear filter support
					formatFeature = .VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT;
					if (properties.optimalTilingFeatures & formatFeature != 0) {
						_formatFeatures[i] |= FormatFeature.LINEAR_FILTER;
					}
					// vertex attribute support
					formatFeature = .VK_FORMAT_FEATURE_VERTEX_BUFFER_BIT;
					if (properties.bufferFeatures & formatFeature != 0) {
						_formatFeatures[i] |= FormatFeature.VERTEX_ATTRIBUTE;
					}
					// shading reate support
					formatFeature = .VK_FORMAT_FEATURE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR;
					if (properties.optimalTilingFeatures & formatFeature != 0) {
						_formatFeatures[i] |= FormatFeature.SHADING_RATE;
					}
				}
			}
			protected void initDeviceFeature() {
				_features[(uint32)Feature.ELEMENT_INDEX_UINT] = true;
				_features[(uint32)Feature.INSTANCED_ARRAYS] = true;
				_features[(uint32)Feature.MULTIPLE_RENDER_TARGETS] = true;
				_features[(uint32)Feature.BLEND_MINMAX] = true;
				_features[(uint32)Feature.COMPUTE_SHADER] = true;
				_features[(uint32)Feature.INPUT_ATTACHMENT_BENEFIT] = true;
				_features[(uint32)Feature.SUBPASS_COLOR_INPUT] = true;
				_features[(uint32)Feature.SUBPASS_DEPTH_STENCIL_INPUT] = true;
				_features[(uint32)Feature.RASTERIZATION_ORDER_NOCOHERENT] = true;
				_features[(uint32)Feature.MULTI_SAMPLE_RESOLVE_DEPTH_STENCIL] = checkExtension("VK_KHR_depth_stencil_resolve");

				_gpuContext.debugReport = _gpuContext.checkExtension(VK_EXT_DEBUG_REPORT_EXTENSION_NAME) &&
					checkExtension(VK_EXT_DEBUG_MARKER_EXTENSION_NAME) &&
					(VulkanNative.[Friend]vkCmdDebugMarkerBeginEXT_ptr != null) &&
					(VulkanNative.[Friend]vkCmdDebugMarkerInsertEXT_ptr != null) &&
					(VulkanNative.[Friend]vkCmdDebugMarkerEndEXT_ptr != null);
				_gpuContext.debugUtils = _gpuContext.checkExtension(VK_EXT_DEBUG_UTILS_EXTENSION_NAME) &&
					(VulkanNative.[Friend]vkCmdBeginDebugUtilsLabelEXT_ptr != null) &&
					(VulkanNative.[Friend]vkCmdInsertDebugUtilsLabelEXT_ptr != null) &&
					(VulkanNative.[Friend]vkCmdEndDebugUtilsLabelEXT_ptr != null);
			}
			protected void initExtensionCapability() {
				_caps.supportVariableRateShading = checkExtension(VK_KHR_FRAGMENT_SHADING_RATE_EXTENSION_NAME);
				_caps.supportVariableRateShading &= _gpuContext.physicalDeviceFragmentShadingRateFeatures.pipelineFragmentShadingRate &&
					_gpuContext.physicalDeviceFragmentShadingRateFeatures.attachmentFragmentShadingRate;
				_caps.supportVariableRateShading &= hasFlag(_formatFeatures[(uint32)Format.R8UI], FormatFeatureBit.SHADING_RATE);

				_caps.supportSubPassShading = checkExtension(VulkanNative.VK_HUAWEI_SUBPASS_SHADING_EXTENSION_NAME);
			}

			protected CCVKGPUDevice _gpuDevice;
			protected CCVKGPUContext _gpuContext;

			protected List<CCVKGPUFencePool> _gpuFencePools;
			protected List<CCVKGPURecycleBin> _gpuRecycleBins;
			protected List<CCVKGPUStagingBufferPool> _gpuStagingBufferPools;

			protected CCVKGPUBufferHub _gpuBufferHub;
			protected CCVKGPUTransportHub _gpuTransportHub;
			protected CCVKGPUDescriptorHub _gpuDescriptorHub;
			protected CCVKGPUSemaphorePool _gpuSemaphorePool;
			protected CCVKGPUBarrierManager _gpuBarrierManager;
			protected CCVKGPUDescriptorSetHub _gpuDescriptorSetHub;
			protected CCVKGPUInputAssemblerHub _gpuIAHub;
			protected CCVKPipelineCache _pipelineCache;

			protected List<char8*> _layers;
			protected List<char8*> _extensions;

			//protected IXRInterface* _xr{ null };
		}

		static
		{
			internal static List<VkSwapchainKHR> vkSwapchains = new .() ~ delete _;
			internal static List<uint32> vkSwapchainIndices = new .() ~ delete _;
			internal static List<CCVKGPUSwapchain> gpuSwapchains = new .() ~ delete _;
			internal static List<VkImageMemoryBarrier> vkAcquireBarriers = new .() ~ delete _;
			internal static List<VkImageMemoryBarrier> vkPresentBarriers = new .() ~ delete _;

			internal static VkImageMemoryBarrier acquireBarrier = .(){
				sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
				pNext = null,
				srcAccessMask = 0,
				dstAccessMask = .VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
				oldLayout = .VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
				newLayout = .VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
				srcQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
				dstQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
				image = 0, // NOLINT(modernize-use-null) platform dependent type
				subresourceRange = .(){ aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT, baseMipLevel = 0, levelCount = 1, baseArrayLayer = 0, layerCount = 1},
			};
			internal static VkImageMemoryBarrier presentBarrier = .(){
				sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
				pNext = null,
				srcAccessMask = .VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
				dstAccessMask = 0,
				oldLayout = .VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
				newLayout = .VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
				srcQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
				dstQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED,
				image = 0, // NOLINT(modernize-use-null) platform dependent type
				subresourceRange = .(){aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT, baseMipLevel = 0, levelCount = 1, baseArrayLayer = 0, layerCount = 1},
			};


			//////////////////////////// Function Fallbacks /////////////////////////////////////////

			internal static  VkResult vkCreateRenderPass2KHRFallback(
				VkDevice device,
				VkRenderPassCreateInfo2* pCreateInfo,
				VkAllocationCallbacks* pAllocator,
				VkRenderPass* pRenderPass) {
				List<VkAttachmentDescription> attachmentDescriptions = scope .();
				List<VkSubpassDescription> subpassDescriptions = scope .();
				List<VkAttachmentReference> attachmentReferences = scope .();
				List<VkSubpassDependency> subpassDependencies = scope .();
				List<int> inputs = scope .();
				List<int> colors = scope .();
				List<int> resolves = scope .();
				List<int> depths = scope .();

				attachmentDescriptions.Resize(pCreateInfo.attachmentCount);
				for (uint32 i = 0; i < pCreateInfo.attachmentCount; ++i) {
					ref VkAttachmentDescription desc = ref attachmentDescriptions[i];
					readonly ref VkAttachmentDescription2 desc2 = ref pCreateInfo.pAttachments[i];
					desc.flags = desc2.flags;
					desc.format = desc2.format;
					desc.samples = desc2.samples;
					desc.loadOp = desc2.loadOp;
					desc.storeOp = desc2.storeOp;
					desc.stencilLoadOp = desc2.stencilLoadOp;
					desc.stencilStoreOp = desc2.stencilStoreOp;
					desc.initialLayout = desc2.initialLayout;
					desc.finalLayout = desc2.finalLayout;
				}

				subpassDescriptions.Resize(pCreateInfo.subpassCount);
				attachmentReferences.Clear();
				inputs..Clear().Resize(pCreateInfo.subpassCount, int.MaxValue);
				colors..Clear().Resize(pCreateInfo.subpassCount, int.MaxValue);
				resolves..Clear().Resize(pCreateInfo.subpassCount, int.MaxValue);
				depths..Clear().Resize(pCreateInfo.subpassCount, int.MaxValue);
				for (uint32 i = 0; i < pCreateInfo.subpassCount; ++i) {
					readonly ref VkSubpassDescription2 desc2 = ref pCreateInfo.pSubpasses[i];
					if (desc2.inputAttachmentCount != 0) {
						inputs[i] = attachmentReferences.Count;
						for (uint32 j = 0; j < desc2.inputAttachmentCount; ++j) {
							attachmentReferences.Add(.(){ attachment = desc2.pInputAttachments[j].attachment, layout = desc2.pInputAttachments[j].layout });
						}
					}
					if (desc2.colorAttachmentCount != 0) {
						colors[i] = attachmentReferences.Count;
						for (uint32 j = 0; j < desc2.colorAttachmentCount; ++j) {
							attachmentReferences.Add(.(){ attachment = desc2.pColorAttachments[j].attachment, layout = desc2.pColorAttachments[j].layout });
						}
						if (desc2.pResolveAttachments != null) {
							resolves[i] = attachmentReferences.Count;
							for (uint32 j = 0; j < desc2.colorAttachmentCount; ++j) {
								attachmentReferences.Add(.(){ attachment = desc2.pResolveAttachments[j].attachment, layout = desc2.pResolveAttachments[j].layout });
							}
						}
					}
					if (desc2.pDepthStencilAttachment != null) {
						depths[i] = attachmentReferences.Count;
						attachmentReferences.Add(.(){ attachment = desc2.pDepthStencilAttachment.attachment, layout = desc2.pDepthStencilAttachment.layout });
					}
				}
				for (uint32 i = 0; i < pCreateInfo.subpassCount; ++i) {
					ref VkSubpassDescription desc = ref subpassDescriptions[i];
					ref VkSubpassDescription2 desc2 = ref pCreateInfo.pSubpasses[i];
					desc.flags = desc2.flags;
					desc.pipelineBindPoint = desc2.pipelineBindPoint;
					desc.inputAttachmentCount = desc2.inputAttachmentCount;
					desc.pInputAttachments = inputs[i] > attachmentReferences.Count ? null : &attachmentReferences[inputs[i]];
					desc.colorAttachmentCount = desc2.colorAttachmentCount;
					desc.pColorAttachments = colors[i] > attachmentReferences.Count ? null : &attachmentReferences[colors[i]];
					desc.pResolveAttachments = resolves[i] > attachmentReferences.Count ? null : &attachmentReferences[resolves[i]];
					desc.pDepthStencilAttachment = depths[i] > attachmentReferences.Count ? null : &attachmentReferences[depths[i]];
					desc.preserveAttachmentCount = desc2.preserveAttachmentCount;
					desc.pPreserveAttachments = desc2.pPreserveAttachments;
				}

				subpassDependencies.Resize(pCreateInfo.dependencyCount);
				for (uint32 i = 0; i < pCreateInfo.dependencyCount; ++i) {
					ref VkSubpassDependency desc = ref subpassDependencies[i];
					ref VkSubpassDependency2 desc2 = ref pCreateInfo.pDependencies[i];
					desc.srcSubpass = desc2.srcSubpass;
					desc.dstSubpass = desc2.dstSubpass;
					desc.srcStageMask = desc2.srcStageMask;
					desc.dstStageMask = desc2.dstStageMask;
					desc.srcAccessMask = desc2.srcAccessMask;
					desc.dstAccessMask = desc2.dstAccessMask;
					desc.dependencyFlags = desc2.dependencyFlags;
				}

				VkRenderPassCreateInfo renderPassCreateInfo = .(){ sType = .VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO };
				renderPassCreateInfo.attachmentCount = (uint32)attachmentDescriptions.Count;
				renderPassCreateInfo.pAttachments = attachmentDescriptions.Ptr;
				renderPassCreateInfo.subpassCount = (uint32)subpassDescriptions.Count;
				renderPassCreateInfo.pSubpasses = subpassDescriptions.Ptr;
				renderPassCreateInfo.dependencyCount = (uint32)subpassDependencies.Count;
				renderPassCreateInfo.pDependencies = subpassDependencies.Ptr;

				return vkCreateRenderPass(device, &renderPassCreateInfo, pAllocator, pRenderPass);
			}
		}
