using System.Collections;
using Bulkan;
using System;
using System.Collections;
using Bulkan.Utilities;
using Sedulous.Renderer.VK.Internal;
using Sedulous.Renderer.SPIRV;
using static Bulkan.VulkanNative;
using static Bulkan.Utilities.VulkanMemoryAllocator;
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
			public const bool ENABLE_LAZY_ALLOCATION = true;

			private static void insertVkDynamicStates(List<VkDynamicState> @out, List<DynamicStateFlagBit> dynamicStates) {
				for (DynamicStateFlagBit dynamicState in dynamicStates) {
					switch (dynamicState) {
					case DynamicStateFlagBit.LINE_WIDTH: @out.Add(.VK_DYNAMIC_STATE_LINE_WIDTH); break;
					case DynamicStateFlagBit.DEPTH_BIAS: @out.Add(.VK_DYNAMIC_STATE_DEPTH_BIAS); break;
					case DynamicStateFlagBit.BLEND_CONSTANTS: @out.Add(.VK_DYNAMIC_STATE_BLEND_CONSTANTS); break;
					case DynamicStateFlagBit.DEPTH_BOUNDS: @out.Add(.VK_DYNAMIC_STATE_DEPTH_BOUNDS); break;
					case DynamicStateFlagBit.STENCIL_WRITE_MASK: @out.Add(.VK_DYNAMIC_STATE_STENCIL_WRITE_MASK); break;
					case DynamicStateFlagBit.STENCIL_COMPARE_MASK:
						@out.Add(.VK_DYNAMIC_STATE_STENCIL_REFERENCE);
						@out.Add(.VK_DYNAMIC_STATE_STENCIL_COMPARE_MASK);
						break;
					default: {
						Runtime.Assert(false);
						break;
					}
					}
				}
			}


			public static void cmdFuncCCVKGetDeviceQueue(CCVKDevice device, CCVKGPUQueue gpuQueue) {
				if (gpuQueue.possibleQueueFamilyIndices.IsEmpty) {
					VkQueueFlags queueType = 0U;
					switch (gpuQueue.type) {
					case QueueType.GRAPHICS: queueType = .VK_QUEUE_GRAPHICS_BIT; break;
					case QueueType.COMPUTE: queueType = .VK_QUEUE_COMPUTE_BIT; break;
					case QueueType.TRANSFER: queueType = .VK_QUEUE_TRANSFER_BIT; break;
					}

					CCVKGPUContext context = device.gpuContext();

					uint32 queueCount = (uint32)context.queueFamilyProperties.Count;
					for (uint32 i = 0U; i < queueCount; ++i) {
						readonly ref VkQueueFamilyProperties properties = ref context.queueFamilyProperties[i];
						if (properties.queueCount > 0 && (properties.queueFlags & queueType != 0)) {
							gpuQueue.possibleQueueFamilyIndices.Add(i);
						}
					}
				}

				VulkanNative.vkGetDeviceQueue(device.gpuDevice().vkDevice, gpuQueue.possibleQueueFamilyIndices[0], 0, &gpuQueue.vkQueue);
				gpuQueue.queueFamilyIndex = gpuQueue.possibleQueueFamilyIndices[0];
			}

			public static void cmdFuncCCVKCreateQueryPool(CCVKDevice device, CCVKGPUQueryPool gpuQueryPool) {
				VkQueryPoolCreateInfo queryPoolInfo = .(){sType = .VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO};
				queryPoolInfo.sType = .VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO;
				queryPoolInfo.queryType = mapVkQueryType(gpuQueryPool.type);
				queryPoolInfo.queryCount = gpuQueryPool.maxQueryObjects;
				VK_CHECK!(VulkanNative.vkCreateQueryPool(device.gpuDevice().vkDevice, &queryPoolInfo, null, &gpuQueryPool.vkPool));
			}

			public static void cmdFuncCCVKCreateTexture(CCVKDevice device, CCVKGPUTexture gpuTexture) {
				if (gpuTexture.size == 0) return;

				gpuTexture.aspectMask = mapVkImageAspectFlags(gpuTexture.format);
				delegate void(VkImage* pVkImage, VmaAllocation* pVmaAllocation) createFn = scope[=device, =gpuTexture](pVkImage, pVmaAllocation) => {
					VkFormat vkFormat = mapVkFormat(gpuTexture.format, device.gpuDevice());
					VkFormatFeatureFlags features = mapVkFormatFeatureFlags(gpuTexture.usage);
					VkFormatProperties formatProperties = .();
					vkGetPhysicalDeviceFormatProperties(device.gpuContext().physicalDevice, vkFormat, &formatProperties);
					if (!(formatProperties.optimalTilingFeatures & features != 0)) {
						char8* formatName = GFX_FORMAT_INFOS[(uint32)gpuTexture.format].name.Ptr;
						WriteError("cmdFuncCCVKCreateTexture: The specified usage for {} is not supported on this platform", formatName);
						return;
					}

					VkImageUsageFlags usageFlags = mapVkImageUsageFlags(gpuTexture.usage, gpuTexture.flags);

					VkImageCreateInfo createInfo = .() { sType = .VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO };
					createInfo.flags = mapVkImageCreateFlags(gpuTexture.type);
					createInfo.imageType = mapVkImageType(gpuTexture.type);
					createInfo.format = vkFormat;
					createInfo.extent = .(){ width = gpuTexture.width, height = gpuTexture.height, depth = gpuTexture.depth };
					createInfo.mipLevels = gpuTexture.mipLevels;
					createInfo.arrayLayers = gpuTexture.arrayLayers;
					createInfo.samples = (VkSampleCountFlags)gpuTexture.samples;
					createInfo.tiling = .VK_IMAGE_TILING_OPTIMAL;
					createInfo.usage = usageFlags;
					createInfo.initialLayout = .VK_IMAGE_LAYOUT_UNDEFINED;

					VmaAllocationCreateInfo allocInfo = .();
					allocInfo.usage = .VMA_MEMORY_USAGE_GPU_ONLY;

					VmaAllocationInfo res;
					readonly VkImageUsageFlags lazilyAllocatedFilterFlags = .VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT |
						.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT |
						.VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT |
						.VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT;
					if (hasFlag(gpuTexture.flags, TextureFlagBit.LAZILY_ALLOCATED) &&
						(lazilyAllocatedFilterFlags & usageFlags) == usageFlags) {
						allocInfo.usage = .VMA_MEMORY_USAGE_GPU_LAZILY_ALLOCATED;
						VkResult result = vmaCreateImage(device.gpuDevice().memoryAllocator, &createInfo, &allocInfo,
							pVkImage, pVmaAllocation, &res);
						if (result != .VK_SUCCESS) {
							gpuTexture.memoryAllocated = false;
							return;
						}

						// feature not present, fallback to device memory
						allocInfo.usage = .VMA_MEMORY_USAGE_GPU_ONLY;
					}

					gpuTexture.memoryAllocated = true;
					VK_CHECK!(vmaCreateImage(device.gpuDevice().memoryAllocator, &createInfo, &allocInfo,
						pVkImage, pVmaAllocation, &res));
					};

				if (gpuTexture.swapchain != null) {
					int backBufferCount = gpuTexture.swapchain.swapchainImages.Count;
					gpuTexture.swapchainVkImages.Resize(backBufferCount);
					if (GFX_FORMAT_INFOS[(uint32)gpuTexture.format].hasDepth) {
						gpuTexture.swapchainVmaAllocations.Resize(backBufferCount);
						for (int i = 0; i < backBufferCount; ++i) {
							createFn(&gpuTexture.swapchainVkImages[i], &gpuTexture.swapchainVmaAllocations[i]);
						}
					}
					else {
						for (int i = 0; i < backBufferCount; ++i) {
							gpuTexture.swapchainVkImages[i] = gpuTexture.swapchain.swapchainImages[i];
						}
					}
					gpuTexture.memoryAllocated = false;
				}
				else if (hasFlag(gpuTexture.flags, TextureFlagBit.EXTERNAL_OES) || hasFlag(gpuTexture.flags, TextureFlagBit.EXTERNAL_NORMAL)) {
					gpuTexture.vkImage = gpuTexture.externalVKImage;
				}
				else {
					createFn(&gpuTexture.vkImage, &gpuTexture.vmaAllocation);
				}
			}

			public static void cmdFuncCCVKCreateTextureView(CCVKDevice device, CCVKGPUTextureView gpuTextureView) {
				if (gpuTextureView.gpuTexture == null) return;

				delegate void(VkImage vkImage, VkImageView* pVkImageView) createFn = scope[=device, =gpuTextureView](vkImage, pVkImageView) => {
					var format = gpuTextureView.format;
					delegate VkImageAspectFlags(CCVKGPUTextureView gpuTextureView) mapAspect = scope (gpuTextureView) => {
						var aspectMask = gpuTextureView.gpuTexture.aspectMask;
						if (gpuTextureView.gpuTexture.format == Format.DEPTH_STENCIL) {
							uint32 planeIndex = gpuTextureView.basePlane;
							uint32 planeCount = gpuTextureView.planeCount;
							aspectMask = (VkImageAspectFlags)((uint32)VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT << planeIndex);
							Runtime.Assert(planeIndex + planeCount <= 2);
							Runtime.Assert(planeCount > 0);
							while (planeCount != 0 && --planeCount != 0) {
								aspectMask |= (VkImageAspectFlags)((uint32)aspectMask << 1);
							}
						}
						return aspectMask;
						};

					VkImageViewCreateInfo createInfo = .(){ sType = .VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO };
					createInfo.image = vkImage;
					createInfo.viewType = mapVkImageViewType(gpuTextureView.type);
					createInfo.subresourceRange.aspectMask = mapAspect(gpuTextureView);
					createInfo.subresourceRange.baseMipLevel = gpuTextureView.baseLevel;
					createInfo.subresourceRange.levelCount = gpuTextureView.levelCount;
					createInfo.subresourceRange.baseArrayLayer = gpuTextureView.baseLayer;
					createInfo.subresourceRange.layerCount = gpuTextureView.layerCount;
					createInfo.format = mapVkFormat(format, device.gpuDevice());

					VK_CHECK!(vkCreateImageView(device.gpuDevice().vkDevice, &createInfo, null, pVkImageView));
					};

				if (gpuTextureView.gpuTexture.swapchain != null) {
					int backBufferCount = gpuTextureView.gpuTexture.swapchain.swapchainImages.Count;
					gpuTextureView.swapchainVkImageViews.Resize(backBufferCount);
					for (int i = 0; i < backBufferCount; ++i) {
						createFn(gpuTextureView.gpuTexture.swapchainVkImages[i], &gpuTextureView.swapchainVkImageViews[i]);
					}
				}
				else if (gpuTextureView.gpuTexture.vkImage != .Null) {
					createFn(gpuTextureView.gpuTexture.vkImage, &gpuTextureView.vkImageView);
				}
			}

			public static void cmdFuncCCVKCreateSampler(CCVKDevice device, CCVKGPUSampler gpuSampler) {
				VkSamplerCreateInfo createInfo = .(){ sType = .VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO };
				CCVKGPUContext context = device.gpuContext();
				float maxAnisotropy = context.physicalDeviceProperties.limits.maxSamplerAnisotropy;

				createInfo.magFilter = VK_FILTERS[(uint32)gpuSampler.magFilter];
				createInfo.minFilter = VK_FILTERS[(uint32)gpuSampler.minFilter];
				createInfo.mipmapMode = VK_SAMPLER_MIPMAP_MODES[(uint32)gpuSampler.mipFilter];
				createInfo.addressModeU = VK_SAMPLER_ADDRESS_MODES[(uint32)gpuSampler.addressU];
				createInfo.addressModeV = VK_SAMPLER_ADDRESS_MODES[(uint32)gpuSampler.addressV];
				createInfo.addressModeW = VK_SAMPLER_ADDRESS_MODES[(uint32)gpuSampler.addressW];
				createInfo.mipLodBias = 0.F;
				createInfo.anisotropyEnable = gpuSampler.maxAnisotropy != 0 && context.physicalDeviceFeatures.samplerAnisotropy;
				createInfo.maxAnisotropy = Math.Min(maxAnisotropy, (float)gpuSampler.maxAnisotropy);
				createInfo.compareEnable = gpuSampler.cmpFunc != ComparisonFunc.ALWAYS;
				createInfo.compareOp = VK_CMP_FUNCS[(uint32)gpuSampler.cmpFunc];
				// From UNASSIGNED-BestPractices-vkCreateSampler-lod-clamping:
				// Should use image views with baseMipLevel & levelCount in favor of this
				createInfo.minLod = 0.0f;
				createInfo.maxLod = VK_LOD_CLAMP_NONE;

				VK_CHECK!(vkCreateSampler(device.gpuDevice().vkDevice, &createInfo, null, &gpuSampler.vkSampler));
			}

			public static void cmdFuncCCVKCreateBuffer(CCVKDevice device, CCVKGPUBuffer gpuBuffer) {
				if (gpuBuffer.size == 0) {
					return;
				}

				gpuBuffer.instanceSize = 0U;

				VkBufferCreateInfo bufferInfo = .() { sType = .VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO };
				bufferInfo.size = gpuBuffer.size;
				bufferInfo.usage = mapVkBufferUsageFlagBits(gpuBuffer.usage);

				VmaAllocationCreateInfo allocInfo = .();

				if (gpuBuffer.memUsage == MemoryUsage.HOST) {
					bufferInfo.usage |= .VK_BUFFER_USAGE_TRANSFER_SRC_BIT;
					allocInfo.flags = .VMA_ALLOCATION_CREATE_MAPPED_BIT;
					allocInfo.usage = .VMA_MEMORY_USAGE_CPU_ONLY;
				}
				else if (gpuBuffer.memUsage == MemoryUsage.DEVICE) {
					bufferInfo.usage |= .VK_BUFFER_USAGE_TRANSFER_DST_BIT;
					allocInfo.usage = .VMA_MEMORY_USAGE_GPU_ONLY;
				}
				else if (gpuBuffer.memUsage == (MemoryUsage.HOST | MemoryUsage.DEVICE)) {
					gpuBuffer.instanceSize = roundUp(gpuBuffer.size, device.getCapabilities().uboOffsetAlignment);
					bufferInfo.size = gpuBuffer.instanceSize * device.gpuDevice().backBufferCount;
					allocInfo.flags = .VMA_ALLOCATION_CREATE_MAPPED_BIT;
					allocInfo.usage = .VMA_MEMORY_USAGE_CPU_TO_GPU;
					bufferInfo.usage |= .VK_BUFFER_USAGE_TRANSFER_DST_BIT | .VK_BUFFER_USAGE_TRANSFER_SRC_BIT;
				}

				VmaAllocationInfo res = .();
				VK_CHECK!(vmaCreateBuffer(device.gpuDevice().memoryAllocator, &bufferInfo, &allocInfo,
					&gpuBuffer.vkBuffer, &gpuBuffer.vmaAllocation, &res));

				gpuBuffer.mappedData = (uint8*)res.pMappedData;

				// add special access types directly from usage
				if (hasFlag(gpuBuffer.usage, BufferUsageBit.VERTEX)) gpuBuffer.renderAccessTypes.Add(.THSVS_ACCESS_VERTEX_BUFFER);
				if (hasFlag(gpuBuffer.usage, BufferUsageBit.INDEX)) gpuBuffer.renderAccessTypes.Add(.THSVS_ACCESS_INDEX_BUFFER);
				if (hasFlag(gpuBuffer.usage, BufferUsageBit.INDIRECT)) gpuBuffer.renderAccessTypes.Add(.THSVS_ACCESS_INDIRECT_BUFFER);
			}

			struct AttachmentStatistics {
				public enum SubpassUsage {
					COLOR = 0x1,
					COLOR_RESOLVE = 0x2,
					DEPTH = 0x4,
					DEPTH_RESOLVE = 0x8,
					INPUT = 0x10,
					SHADING_RATE = 0x20,
				}
				public struct SubpassRef {
					public VkImageLayout layout = .VK_IMAGE_LAYOUT_UNDEFINED;
					public SubpassUsage usage = .COLOR;

					public bool hasDepth() { return usage == SubpassUsage.DEPTH || usage == SubpassUsage.DEPTH_RESOLVE; }
				};

				public uint32 loadSubpass = VK_SUBPASS_EXTERNAL;
				public uint32 storeSubpass = VK_SUBPASS_EXTERNAL;
				public Dictionary<uint32, SubpassRef> records; // ordered

				public void clear() mut {
					loadSubpass = VK_SUBPASS_EXTERNAL;
					storeSubpass = VK_SUBPASS_EXTERNAL;
					records.Clear();
				}
			};
			//CC_ENUM_BITWISE_OPERATORS(AttachmentStatistics.SubpassUsage)

			struct SubpassDependencyManager {
				public List<VkSubpassDependency2> subpassDependencies;

				public void clear() {
					subpassDependencies.Clear();
					_hashes.Clear();
				}

				public void @append(VkSubpassDependency2 info) {
					if (_hashes.Contains(info)) return;
					subpassDependencies.Add(info);
					_hashes.Add(info);
				}

				// only the src/dst attributes differs
				/*private struct DependencyHasher {
					ccstd.hash_t operator()(const VkSubpassDependency2& info) const {
						static_assert(std.is_trivially_copyable<VkSubpassDependency2>.value && sizeof(VkSubpassDependency2) % 8 == 0, "VkSubpassDependency2 must be 8 bytes aligned and trivially copyable");
						return ccstd.hash_range(reinterpret_cast<const uint64*>(&info.srcSubpass),
							reinterpret_cast<const uint64*>(&info.dependencyFlags));
					}
				}
				private struct DependencyComparer {
					size_t operator()(const VkSubpassDependency2& lhs, const VkSubpassDependency2& rhs) const {
						auto size = static_cast<size_t>(reinterpret_cast<const uint8*>(&lhs.dependencyFlags) - reinterpret_cast<const uint8*>(&lhs.srcSubpass));
						return !memcmp(&lhs.srcSubpass, &rhs.srcSubpass, size);
					}
				}*/
				private HashSet<VkSubpassDependency2/*, DependencyHasher, DependencyComparer*/> _hashes;
			}

			static (VkImageLayout oldLayout, VkImageLayout newLayout) getInitialFinalLayout(CCVKDevice device, CCVKGeneralBarrier barrier, bool depthSetncil) {
				var gpuBarrier = barrier != null ? barrier.gpuBarrier() : (depthSetncil ? &device.gpuDevice().defaultDepthStencilBarrier : &device.gpuDevice().defaultColorBarrier);

				ThsvsImageBarrier imageBarrier = .();
				imageBarrier.prevAccessCount = (uint32)gpuBarrier.prevAccesses.size();
				imageBarrier.pPrevAccesses = gpuBarrier.prevAccesses.data();
				imageBarrier.nextAccessCount = (uint32)gpuBarrier.nextAccesses.size();
				imageBarrier.pNextAccesses = gpuBarrier.nextAccesses.data();
				imageBarrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				imageBarrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				imageBarrier.prevLayout = barrier ? getAccessLayout(barrier.getInfo().prevAccesses) : .THSVS_IMAGE_LAYOUT_OPTIMAL;
				imageBarrier.nextLayout = barrier ? getAccessLayout(barrier.getInfo().nextAccesses) : .THSVS_IMAGE_LAYOUT_OPTIMAL;

				VkPipelineStageFlags srcStages = .();
				VkPipelineStageFlags dstStages = .();
				VkImageMemoryBarrier vkImageBarrier = .(){sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER};
				thsvsGetVulkanImageMemoryBarrier(imageBarrier, &srcStages, &dstStages, &vkImageBarrier);
				return (vkImageBarrier.oldLayout, vkImageBarrier.newLayout);
			}


			public static void cmdFuncCCVKCreateRenderPass(CCVKDevice device, CCVKGPURenderPass gpuRenderPass) {
				
				List<VkSubpassDescriptionDepthStencilResolve> depthStencilResolves = scope .();
				List<VkAttachmentDescription2> attachmentDescriptions = scope .();
				List<VkAttachmentReference2> attachmentReferences = scope .();
				List<CCVKAccessInfo> beginAccessInfos = scope .();
				List<VkSubpassDescription2> subpassDescriptions = scope .();
				List<CCVKAccessInfo> endAccessInfos = scope .();
				List<AttachmentStatistics> attachmentStatistics = scope .();
				/*static*/ SubpassDependencyManager dependencyManager = .();
				List<VkFragmentShadingRateAttachmentInfoKHR> shadingRateReferences = scope .();

				readonly uint32 colorAttachmentCount = (uint32)gpuRenderPass.colorAttachments.Count;
				readonly uint32 hasDepthStencil = gpuRenderPass.depthStencilAttachment.format != Format.UNKNOWN ? 1 : 0;
				readonly uint32 hasDepthResolve = gpuRenderPass.depthStencilResolveAttachment.format != Format.UNKNOWN ? 1 : 0;
				var attachmentCount = (uint32)(colorAttachmentCount + hasDepthStencil + hasDepthResolve);
				uint32 depthIndex = colorAttachmentCount;
				uint32 stencilIndex = colorAttachmentCount + 1;

				readonly bool hasStencil = GFX_FORMAT_INFOS[(uint32)gpuRenderPass.depthStencilAttachment.format].hasStencil;

				attachmentDescriptions.Resize(attachmentCount, .(){ sType = .VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2 });
				gpuRenderPass.clearValues.Resize(attachmentCount);
				beginAccessInfos.Resize(attachmentCount);
				endAccessInfos.Resize(attachmentCount);
				shadingRateReferences.Resize(gpuRenderPass.subpasses.Count, .(){ sType = .VK_STRUCTURE_TYPE_FRAGMENT_SHADING_RATE_ATTACHMENT_INFO_KHR });

				for (int i = 0U; i < colorAttachmentCount; ++i) {
					readonly var attachment = ref gpuRenderPass.colorAttachments[i];
					var (initialLayout, finalLayout) = getInitialFinalLayout(device, (CCVKGeneralBarrier)attachment.barrier, false);

					VkFormat vkFormat = mapVkFormat(attachment.format, device.gpuDevice());
					attachmentDescriptions[i].format = vkFormat;
					attachmentDescriptions[i].samples = (VkSampleCountFlags)attachment.sampleCount;
					attachmentDescriptions[i].loadOp = mapVkLoadOp(attachment.loadOp);
					attachmentDescriptions[i].storeOp = mapVkStoreOp(attachment.storeOp);
					attachmentDescriptions[i].stencilLoadOp = .VK_ATTACHMENT_LOAD_OP_DONT_CARE;
					attachmentDescriptions[i].stencilStoreOp = .VK_ATTACHMENT_STORE_OP_DONT_CARE;
					attachmentDescriptions[i].initialLayout = attachment.loadOp == LoadOp.DISCARD ? .VK_IMAGE_LAYOUT_UNDEFINED : initialLayout;
					attachmentDescriptions[i].finalLayout = finalLayout;
				}
				if (hasDepthStencil == 1) {
					readonly ref DepthStencilAttachment attachment = ref gpuRenderPass.depthStencilAttachment;
					var (initialLayout, finalLayout) = getInitialFinalLayout(device, (CCVKGeneralBarrier*)attachment.barrier, true);

					VkFormat vkFormat = mapVkFormat(attachment.format, device.gpuDevice());
					attachmentDescriptions[depthIndex].format = vkFormat;
					attachmentDescriptions[depthIndex].samples = (VkSampleCountFlags)attachment.sampleCount;
					attachmentDescriptions[depthIndex].loadOp = mapVkLoadOp(attachment.depthLoadOp);
					attachmentDescriptions[depthIndex].storeOp = mapVkStoreOp(attachment.depthStoreOp);
					attachmentDescriptions[depthIndex].stencilLoadOp = hasStencil ? mapVkLoadOp(attachment.stencilLoadOp) : .VK_ATTACHMENT_LOAD_OP_DONT_CARE;
					attachmentDescriptions[depthIndex].stencilStoreOp = hasStencil ? mapVkStoreOp(attachment.stencilStoreOp) : .VK_ATTACHMENT_STORE_OP_DONT_CARE;
					attachmentDescriptions[depthIndex].initialLayout = attachment.depthLoadOp == LoadOp.DISCARD ? .VK_IMAGE_LAYOUT_UNDEFINED : initialLayout;
					attachmentDescriptions[depthIndex].finalLayout = finalLayout;
				}
				if (hasDepthResolve == 1) {
					readonly ref DepthStencilAttachment attachment = ref gpuRenderPass.depthStencilResolveAttachment;
					var (initialLayout, finalLayout) = getInitialFinalLayout(device, (CCVKGeneralBarrier*)attachment.barrier, true);

					VkFormat vkFormat = mapVkFormat(attachment.format, device.gpuDevice());

					attachmentDescriptions[stencilIndex].format = vkFormat;
					attachmentDescriptions[stencilIndex].samples = .VK_SAMPLE_COUNT_1_BIT;
					attachmentDescriptions[stencilIndex].loadOp = mapVkLoadOp(attachment.depthLoadOp);
					attachmentDescriptions[stencilIndex].storeOp = mapVkStoreOp(attachment.depthStoreOp);
					attachmentDescriptions[stencilIndex].stencilLoadOp = hasStencil ? mapVkLoadOp(attachment.stencilLoadOp) : .VK_ATTACHMENT_LOAD_OP_DONT_CARE;
					attachmentDescriptions[stencilIndex].stencilStoreOp = hasStencil ? mapVkStoreOp(attachment.stencilStoreOp) : .VK_ATTACHMENT_STORE_OP_DONT_CARE;
					attachmentDescriptions[stencilIndex].initialLayout = attachment.depthLoadOp == LoadOp.DISCARD ? .VK_IMAGE_LAYOUT_UNDEFINED : initialLayout;
					attachmentDescriptions[stencilIndex].finalLayout = finalLayout;
				}

				int subpassCount = gpuRenderPass.subpasses.Count;
				attachmentReferences.Clear();
				gpuRenderPass.sampleCounts.Clear();

				for (var subpassInfo in gpuRenderPass.subpasses) {
					VkSampleCountFlags sampleCount = .VK_SAMPLE_COUNT_1_BIT;

					for (uint32 input in subpassInfo.inputs) {
						bool appearsInOutput = subpassInfo.colors.Contains(input);
						VkImageLayout layout = appearsInOutput ? .VK_IMAGE_LAYOUT_GENERAL : .VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
						VkImageAspectFlags aspectFlag = .VK_IMAGE_ASPECT_COLOR_BIT;
						if (input == gpuRenderPass.colorAttachments.Count) {
							layout = .VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL;
							aspectFlag = .VK_IMAGE_ASPECT_STENCIL_BIT | .VK_IMAGE_ASPECT_DEPTH_BIT;
						}
						attachmentReferences.Add(.(){sType = .VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2, pNext = null, attachment = input, layout = layout, aspectMask = aspectFlag });
					}
					for (uint32 color in subpassInfo.colors) {
						readonly ref VkAttachmentDescription2 attachment = ref attachmentDescriptions[color];
						bool appearsInInput = subpassInfo.inputs.Contains(color);
						VkImageLayout layout = appearsInInput ? .VK_IMAGE_LAYOUT_GENERAL : .VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
						attachmentReferences.Add(.(){sType = .VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2, pNext = null, attachment = color, layout = layout, aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT });
						sampleCount = Math.Max(sampleCount, attachment.samples);
					}
					for (uint32 resolveIn in subpassInfo.resolves) {
						VkImageLayout layout = .VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
						var resolve = resolveIn == INVALID_BINDING ? VK_ATTACHMENT_UNUSED : resolveIn;
						Runtime.Assert(INVALID_BINDING == VK_ATTACHMENT_UNUSED);
						attachmentReferences.Add(.(){sType = .VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2, pNext = null, attachment = resolve, layout = layout, aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT });
					}

					if (subpassInfo.depthStencil != INVALID_BINDING) {
						readonly ref VkAttachmentDescription2 attachment = ref attachmentDescriptions[subpassInfo.depthStencil];
						sampleCount = Math.Max(sampleCount, attachment.samples);

						bool appearsInInput = subpassInfo.inputs.Contains(subpassInfo.depthStencil);
						VkImageAspectFlags aspect = hasStencil ? .VK_IMAGE_ASPECT_DEPTH_BIT | .VK_IMAGE_ASPECT_STENCIL_BIT : .VK_IMAGE_ASPECT_DEPTH_BIT;
						VkImageLayout layout = appearsInInput ? .VK_IMAGE_LAYOUT_GENERAL : .VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
						attachmentReferences.Add(.(){sType = .VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2, pNext = null, attachment = subpassInfo.depthStencil, layout = layout, aspectMask = aspect });
					}

					if (subpassInfo.depthStencilResolve != INVALID_BINDING) {
						VkImageAspectFlags aspect = hasStencil ? .VK_IMAGE_ASPECT_DEPTH_BIT | .VK_IMAGE_ASPECT_STENCIL_BIT : .VK_IMAGE_ASPECT_DEPTH_BIT;
						VkImageLayout layout = .VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
						attachmentReferences.Add(.(){sType = .VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2, pNext = null, attachment = subpassInfo.depthStencilResolve, layout = layout, aspectMask = aspect });
					}

					if (subpassInfo.shadingRate != INVALID_BINDING && subpassInfo.shadingRate < colorAttachmentCount) {
						// layout is guaranteed
						attachmentDescriptions[subpassInfo.shadingRate].initialLayout = .VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR;
						attachmentDescriptions[subpassInfo.shadingRate].finalLayout = .VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR;
						readonly ref ColorAttachment desc = ref gpuRenderPass.colorAttachments[subpassInfo.shadingRate];
						attachmentReferences.Add(.(){sType = .VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2, pNext = null, attachment = subpassInfo.shadingRate, layout = .VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR, aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT });
					}

					gpuRenderPass.sampleCounts.Add(sampleCount);
				}

				int offset = 0U;
				subpassDescriptions.Resize(subpassCount, .(){sType = .VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_2 }); // init to zeros first
				depthStencilResolves.Resize(subpassCount, .(){sType = .VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_DEPTH_STENCIL_RESOLVE });
				readonly ref VkPhysicalDeviceDepthStencilResolveProperties prop = ref device.gpuContext().physicalDeviceDepthStencilResolveProperties;
				for (uint32 i = 0U; i < gpuRenderPass.subpasses.Count; ++i) {
					readonly ref SubpassInfo subpassInfo = ref gpuRenderPass.subpasses[i];

					ref VkSubpassDescription2 desc = ref subpassDescriptions[i];
					desc.pipelineBindPoint = .VK_PIPELINE_BIND_POINT_GRAPHICS;

					if (!subpassInfo.inputs.IsEmpty) {
						desc.inputAttachmentCount = (uint32)subpassInfo.inputs.Count;
						desc.pInputAttachments = attachmentReferences.Ptr + offset;
						offset += subpassInfo.inputs.Count;
					}

					if (!subpassInfo.colors.IsEmpty) {
						desc.colorAttachmentCount = (uint32)subpassInfo.colors.Count;
						desc.pColorAttachments = attachmentReferences.Ptr + offset;
						offset += subpassInfo.colors.Count;
						if (!subpassInfo.resolves.IsEmpty) {
							desc.pResolveAttachments = attachmentReferences.Ptr + offset;
							offset += subpassInfo.resolves.Count;
						}
					}
					if (!subpassInfo.preserves.IsEmpty) {
						desc.preserveAttachmentCount = (uint32)subpassInfo.preserves.Count;
						desc.pPreserveAttachments = subpassInfo.preserves.Ptr;
					}

					if (subpassInfo.depthStencil != INVALID_BINDING) {
						desc.pDepthStencilAttachment = attachmentReferences.Ptr + offset++;
					}
					else {
						desc.pDepthStencilAttachment = null;
					}

					if (subpassInfo.depthStencilResolve != INVALID_BINDING) {
						ref VkSubpassDescriptionDepthStencilResolve resolveDesc = ref depthStencilResolves[i];

						VkResolveModeFlags depthResolveMode = VK_RESOLVE_MODES[(uint32)subpassInfo.depthResolveMode];
						VkResolveModeFlags stencilResolveMode = VK_RESOLVE_MODES[(uint32)subpassInfo.stencilResolveMode];

						if ((depthResolveMode & prop.supportedDepthResolveModes) == 0) {
							depthResolveMode = .VK_RESOLVE_MODE_SAMPLE_ZERO_BIT;
							WriteWarning("render pass depth resolve mode {} not supported, use Sample0 instead.", (uint32)subpassInfo.depthResolveMode);
						}
						if ((stencilResolveMode & prop.supportedStencilResolveModes) == 0) {
							stencilResolveMode = .VK_RESOLVE_MODE_SAMPLE_ZERO_BIT;
							WriteWarning("render pass stencil resolve mode {} not supported, use Sample0 instead.", (uint32)subpassInfo.stencilResolveMode);
						}

						if (!prop.independentResolveNone && stencilResolveMode != depthResolveMode) {
							stencilResolveMode = depthResolveMode;
						}
						else if (prop.independentResolveNone && !prop.independentResolve && stencilResolveMode != 0 &&
							depthResolveMode != 0 && stencilResolveMode != depthResolveMode) {
							stencilResolveMode = .VK_RESOLVE_MODE_NONE;
						}

						resolveDesc.depthResolveMode = depthResolveMode;
						resolveDesc.stencilResolveMode = stencilResolveMode;
						resolveDesc.pDepthStencilResolveAttachment = attachmentReferences.Ptr + offset++;
						desc.pNext = &resolveDesc;
					}

					if (subpassInfo.shadingRate != INVALID_BINDING) {
						ref VkFragmentShadingRateAttachmentInfoKHR attachment = ref shadingRateReferences[i];
						attachment.pFragmentShadingRateAttachment = attachmentReferences.Ptr + offset++;
						attachment.shadingRateAttachmentTexelSize = .(16, 16); // todo
						desc.pNext = &attachment;
					}
				}

				int dependencyCount = gpuRenderPass.dependencies.Count;
				gpuRenderPass.hasSelfDependency.Resize(subpassCount, false);
				dependencyManager.clear();

				bool manuallyDeduce = true;
				if (ENABLE_GRAPH_AUTO_BARRIER) {
					// single pass front and rear cost 2 slot.
					manuallyDeduce = dependencyCount <= 2;
				}
				else {
					manuallyDeduce = dependencyCount == 0;
				}
				if (!manuallyDeduce) {
					// offset = 0U;
					HashSet<GFXObject> subpassExternalFilter = scope .();
					for (uint32 i = 0U; i < dependencyCount; ++i) {
						readonly var dependency = ref gpuRenderPass.dependencies[i];
						VkSubpassDependency2 vkDependency = .() { sType = .VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2 };
						vkDependency.srcSubpass = dependency.srcSubpass;
						vkDependency.dstSubpass = dependency.dstSubpass;
						vkDependency.dependencyFlags = .VK_DEPENDENCY_BY_REGION_BIT;

						if (dependency.srcSubpass == dependency.dstSubpass && dependency.srcSubpass < subpassCount) {
							gpuRenderPass.hasSelfDependency[dependency.srcSubpass] = true;
						}

						delegate void(in SubpassDependency deps) addStageAccessMask = scope [&vkDependency, &dependencyManager](deps) => {
							List<ThsvsAccessType> prevAccesses = scope .();
							List<ThsvsAccessType> nextAccesses = scope .();
							getAccessTypes(deps.prevAccesses, ref prevAccesses);
							getAccessTypes(deps.nextAccesses, ref nextAccesses);

							ThsvsImageBarrier imageBarrier = .();
							imageBarrier.prevAccessCount = (uint32)prevAccesses.Count;
							imageBarrier.pPrevAccesses = prevAccesses.Ptr;
							imageBarrier.nextAccessCount = (uint32)nextAccesses.Count;
							imageBarrier.pNextAccesses = nextAccesses.Ptr;
							imageBarrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
							imageBarrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
							imageBarrier.prevLayout = getAccessLayout(deps.prevAccesses);
							imageBarrier.nextLayout = getAccessLayout(deps.nextAccesses);

							VkImageMemoryBarrier vkImageBarrier = .(){sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER};
							thsvsGetVulkanImageMemoryBarrier(imageBarrier, &vkDependency.srcStageMask, &vkDependency.dstStageMask, &vkImageBarrier);

							vkDependency.srcAccessMask = vkImageBarrier.srcAccessMask;
							vkDependency.dstAccessMask = vkImageBarrier.dstAccessMask;
							dependencyManager.append(vkDependency);
							};
						if (vkDependency.srcStageMask == 0) {
							vkDependency.srcStageMask = .VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
						}
						addStageAccessMask(dependency);
					}

				}
				else {
					// try to deduce dependencies if not specified

					// first, gather necessary statistics for each attachment
					delegate void(ref AttachmentStatistics statistics, uint32 index, VkImageLayout layout, AttachmentStatistics.SubpassUsage usage) updateLifeCycle = scope (statistics, index, layout, usage) => {
						if (statistics.records.ContainsKey(index)) {
							statistics.records[index].usage |= usage;
						}
						else {
							statistics.records[index] = .(){ layout = layout, usage = usage };
						}
						if (statistics.loadSubpass == VK_SUBPASS_EXTERNAL) statistics.loadSubpass = index;
						statistics.storeSubpass = index;
						};
					delegate void(uint32 targetAttachment, ref AttachmentStatistics statistics) calculateLifeCycle = scope [&](targetAttachment, statistics) => {
						for (uint32 j = 0U; j < (uint32)subpassCount; ++j) {
							var subpass = ref subpassDescriptions[j];
							for (int k = 0U; k < subpass.colorAttachmentCount; ++k) {
								if (subpass.pColorAttachments[k].attachment == targetAttachment) {
									updateLifeCycle(ref statistics, j, subpass.pColorAttachments[k].layout, AttachmentStatistics.SubpassUsage.COLOR);
								}
								if (subpass.pResolveAttachments != null && subpass.pResolveAttachments[k].attachment == targetAttachment) {
									updateLifeCycle(ref statistics, j, subpass.pResolveAttachments[k].layout, AttachmentStatistics.SubpassUsage.COLOR_RESOLVE);
								}
							}
							for (int k = 0U; k < subpass.inputAttachmentCount; ++k) {
								if (subpass.pInputAttachments[k].attachment == targetAttachment) {
									updateLifeCycle(ref statistics, j, subpass.pInputAttachments[k].layout, AttachmentStatistics.SubpassUsage.INPUT);
								}
							}
							var vrsDesc = (VkFragmentShadingRateAttachmentInfoKHR*)subpass.pNext;
							if (vrsDesc != null && vrsDesc.sType == .VK_STRUCTURE_TYPE_FRAGMENT_SHADING_RATE_ATTACHMENT_INFO_KHR && vrsDesc.pFragmentShadingRateAttachment.attachment == targetAttachment) {
								updateLifeCycle(ref statistics, j, vrsDesc.pFragmentShadingRateAttachment.layout, AttachmentStatistics.SubpassUsage.SHADING_RATE);
							}

							if (subpass.pDepthStencilAttachment != null && subpass.pDepthStencilAttachment.attachment == targetAttachment) {
								updateLifeCycle(ref statistics, j, subpass.pDepthStencilAttachment.layout, AttachmentStatistics.SubpassUsage.DEPTH);
							}
							if (depthStencilResolves[j].pDepthStencilResolveAttachment != null &&
								depthStencilResolves[j].pDepthStencilResolveAttachment.attachment == targetAttachment) {
								updateLifeCycle(ref statistics, j, depthStencilResolves[j].pDepthStencilResolveAttachment.layout, AttachmentStatistics.SubpassUsage.DEPTH_RESOLVE);
							}
						}
						};
					attachmentStatistics.Resize(attachmentCount);
					for (uint32 i = 0U; i < attachmentCount; ++i) {
						attachmentStatistics[i].clear();
						calculateLifeCycle(i, ref attachmentStatistics[i]);
						Runtime.Assert(attachmentStatistics[i].loadSubpass != VK_SUBPASS_EXTERNAL &&
							attachmentStatistics[i].storeSubpass != VK_SUBPASS_EXTERNAL);
					}

					// wait for resources to become available (begin accesses)
					delegate bool(ref VkSubpassDependency2 dependency, uint32 attachment, in AttachmentStatistics.SubpassRef @ref) beginDependencyCheck = scope(dependency, attachment, @ref) => {
						readonly ref VkAttachmentDescription2 desc = ref attachmentDescriptions[attachment];
						readonly ref CCVKAccessInfo info = ref beginAccessInfos[attachment];
						if (desc.initialLayout != @ref.layout || info.hasWriteAccess || desc.loadOp == .VK_ATTACHMENT_LOAD_OP_CLEAR) {
							VkPipelineStageFlags dstStage = @ref.hasDepth() ? .VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT : .VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
							VkAccessFlags dstAccessRead = @ref.hasDepth() ? .VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT : .VK_ACCESS_COLOR_ATTACHMENT_READ_BIT;
							VkAccessFlags dstAccessWrite = @ref.hasDepth() ? .VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT : .VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
							dependency.srcStageMask |= info.stageMask;
							dependency.dstStageMask |= dstStage;
							dependency.srcAccessMask |= info.hasWriteAccess ? info.accessMask : 0;
							dependency.dstAccessMask |= dstAccessRead;
							if (desc.loadOp == .VK_ATTACHMENT_LOAD_OP_CLEAR || desc.initialLayout != @ref.layout) dependency.dstAccessMask |= dstAccessWrite;
							return true;
						}
						return false;
						};
					VkSubpassDependency2 beginDependency = .(){sType = .VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2};
					uint32 lastLoadSubpass = VK_SUBPASS_EXTERNAL;
					bool beginDependencyValid = false;
					for (uint32 i = 0U; i < attachmentCount; ++i) {
						var statistics = ref attachmentStatistics[i];
						if (lastLoadSubpass != statistics.loadSubpass) {
							if (beginDependencyValid) dependencyManager.append(beginDependency);
							beginDependency = .() { sType = .VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2, pNext = null,
											   srcSubpass= VK_SUBPASS_EXTERNAL, dstSubpass=statistics.loadSubpass,
											   srcStageMask=.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, dstStageMask=.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT };
							lastLoadSubpass = statistics.loadSubpass;
							beginDependencyValid = false;
						}
						beginDependencyValid |= beginDependencyCheck(ref beginDependency, i, statistics.records[statistics.loadSubpass]);
					}
					if (beginDependencyValid) dependencyManager.append(beginDependency);

					// make rendering result visible (end accesses)
					delegate bool(ref VkSubpassDependency2 dependency, uint32 attachment, in AttachmentStatistics.SubpassRef @ref) endDependencyCheck = scope(dependency, attachment, @ref) => {
						readonly ref VkAttachmentDescription2 desc = ref attachmentDescriptions[attachment];
						readonly ref CCVKAccessInfo info = ref endAccessInfos[attachment];
						if (desc.initialLayout != @ref.layout || info.hasWriteAccess || desc.storeOp == .VK_ATTACHMENT_STORE_OP_STORE) {
							VkPipelineStageFlags srcStage = @ref.hasDepth() ? .VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT : .VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
							VkAccessFlags srcAccess = @ref.hasDepth() ? .VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT : .VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
							dependency.srcStageMask |= srcStage;
							dependency.srcAccessMask |= srcAccess;
							dependency.dstStageMask |= info.stageMask;
							dependency.dstAccessMask |= info.accessMask;
							return true;
						}
						return false;
						};
					VkSubpassDependency2 endDependency = .(){sType = .VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2};
					uint32 lastStoreSubpass = VK_SUBPASS_EXTERNAL;
					bool endDependencyValid = false;
					for (uint32 i = 0U; i < attachmentCount; ++i) {
						var statistics = ref attachmentStatistics[i];
						if (lastStoreSubpass != statistics.storeSubpass) {
							if (endDependencyValid) dependencyManager.append(endDependency);
							endDependency =  .() { sType = .VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2, pNext = null,
											 srcSubpass = statistics.storeSubpass, dstSubpass = VK_SUBPASS_EXTERNAL,
											 srcStageMask = .VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, dstStageMask= .VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT };
							lastStoreSubpass = statistics.storeSubpass;
							endDependencyValid = false;
						}
						endDependencyValid |= endDependencyCheck(ref endDependency, i, statistics.records[statistics.storeSubpass]);
					}
					if (endDependencyValid) dependencyManager.append(endDependency);

					// other transitioning dependencies
					delegate (VkPipelineStageFlags, VkAccessFlags)(AttachmentStatistics.SubpassUsage usage) mapAccessFlags = scope (usage) => {
						// there may be more kind of dependencies
						if (hasFlag(usage, AttachmentStatistics.SubpassUsage.INPUT)) {
							return (.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, .VK_ACCESS_INPUT_ATTACHMENT_READ_BIT);
						}
						return (.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, .VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
						};
					delegate VkSubpassDependency2(uint32 srcIdx, AttachmentStatistics.SubpassUsage srcUsage,
						uint32 dstIdx, AttachmentStatistics.SubpassUsage dstUsage) genDependency = scope[&](srcIdx, srcUsage,
						dstIdx, dstUsage) => {
							VkSubpassDependency2 dependency = .() { sType = .VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2, pNext = null, srcSubpass = srcIdx, dstSubpass = dstIdx };
							(dependency.srcStageMask, dependency.srcAccessMask) = mapAccessFlags(srcUsage);
							(dependency.dstStageMask, dependency.dstAccessMask) = mapAccessFlags(dstUsage);
							dependency.dependencyFlags = .VK_DEPENDENCY_BY_REGION_BIT;
							return dependency;
						};
					for (int i = 0U; i < attachmentCount; ++i) {
						var statistics = ref attachmentStatistics[i];

						AttachmentStatistics.SubpassRef* prevRef = null;
						uint32 prevIdx = 0U;
						for (var it in statistics.records) {
							if (prevRef != null && prevRef.usage != it.value.usage) {
								dependencyManager.append(genDependency(prevIdx, prevRef.usage, it.key, it.value.usage));
							}
							prevIdx = it.key;
							prevRef = &it.value;
						}
					}
				}

				VkRenderPassCreateInfo2 renderPassCreateInfo = .() { sType = .VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO_2 };
				renderPassCreateInfo.attachmentCount = (uint32)attachmentDescriptions.Count;
				renderPassCreateInfo.pAttachments = attachmentDescriptions.Ptr;
				renderPassCreateInfo.subpassCount = (uint32)subpassDescriptions.Count;
				renderPassCreateInfo.pSubpasses = subpassDescriptions.Ptr;
				renderPassCreateInfo.dependencyCount = (uint32)dependencyManager.subpassDependencies.Count;
				renderPassCreateInfo.pDependencies = dependencyManager.subpassDependencies.Ptr;

				VK_CHECK!(device.gpuDevice().createRenderPass2(device.gpuDevice().vkDevice, &renderPassCreateInfo,
					null, &gpuRenderPass.vkRenderPass));
			}

			public static void cmdFuncCCVKCreateFramebuffer(CCVKDevice device, CCVKGPUFramebuffer gpuFramebuffer) {
				int colorViewCount = gpuFramebuffer.gpuColorViews.Count;
				var gpuRenderPass = gpuFramebuffer.gpuRenderPass;
				readonly int hasDepthStencil = gpuRenderPass.depthStencilAttachment.format != Format.UNKNOWN ? 1 : 0;
				readonly int hasDepthResolve = gpuRenderPass.depthStencilResolveAttachment.format != Format.UNKNOWN ? 1 : 0;
				var attachmentCount = (uint32)(colorViewCount + hasDepthStencil + hasDepthResolve);

				List<VkImageView> attachments = scope .() {Count = attachmentCount};
				VkFramebufferCreateInfo createInfo = .() { sType = .VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO };
				createInfo.width = uint32.MaxValue;
				createInfo.height = uint32.MaxValue;

				uint32 swapchainImageIndices = 0;

				for (int i = 0U; i < colorViewCount; ++i) {
					readonly CCVKGPUTextureView texView = gpuFramebuffer.gpuColorViews[i];
					if (texView.gpuTexture.swapchain != null) {
						gpuFramebuffer.swapchain = texView.gpuTexture.swapchain;
						swapchainImageIndices |= (1 << i);
					}
					else {
						attachments[i] = gpuFramebuffer.gpuColorViews[i].vkImageView;
					}

					if (!hasFlag(texView.gpuTexture.usage, TextureUsageBit.SHADING_RATE)) {
						createInfo.width = Math.Min(createInfo.width, Math.Max(1, gpuFramebuffer.gpuColorViews[i].gpuTexture.width >> gpuFramebuffer.gpuColorViews[i].baseLevel));
						createInfo.height = Math.Min(createInfo.height, Math.Max(1, gpuFramebuffer.gpuColorViews[i].gpuTexture.height >> gpuFramebuffer.gpuColorViews[i].baseLevel));
					}
				}
				if (hasDepthStencil == 1) {
					if (gpuFramebuffer.gpuDepthStencilView.gpuTexture.swapchain != null) {
						gpuFramebuffer.swapchain = gpuFramebuffer.gpuDepthStencilView.gpuTexture.swapchain;
						swapchainImageIndices |= (1 << colorViewCount);
					}
					else {
						attachments[colorViewCount] = gpuFramebuffer.gpuDepthStencilView.vkImageView;
					}
					createInfo.width = Math.Min(createInfo.width, Math.Max(1, gpuFramebuffer.gpuDepthStencilView.gpuTexture.width >> gpuFramebuffer.gpuDepthStencilView.baseLevel));
					createInfo.height = Math.Min(createInfo.height, Math.Max(1, gpuFramebuffer.gpuDepthStencilView.gpuTexture.height >> gpuFramebuffer.gpuDepthStencilView.baseLevel));
				}
				if (hasDepthResolve == 1) {
					attachments[colorViewCount + 1] = gpuFramebuffer.gpuDepthStencilResolveView.vkImageView;
				}

				gpuFramebuffer.isOffscreen = swapchainImageIndices == 0;
				gpuFramebuffer.width = createInfo.width;
				gpuFramebuffer.height = createInfo.height;

				if (gpuFramebuffer.isOffscreen) {
					createInfo.renderPass = gpuFramebuffer.gpuRenderPass.vkRenderPass;
					createInfo.attachmentCount = (uint32)attachments.Count;
					createInfo.pAttachments = attachments.Ptr;
					createInfo.layers = 1;
					VK_CHECK!(vkCreateFramebuffer(device.gpuDevice().vkDevice, &createInfo, null, &gpuFramebuffer.vkFramebuffer));
				}
				else {
					int swapChainImageCount = gpuFramebuffer.swapchain.swapchainImages.Count;
					gpuFramebuffer.vkFrameBuffers.Resize(swapChainImageCount);
					createInfo.renderPass = gpuFramebuffer.gpuRenderPass.vkRenderPass;
					createInfo.attachmentCount = (uint32)attachments.Count;
					createInfo.pAttachments = attachments.Ptr;
					createInfo.layers = 1;
					for (int i = 0U; i < swapChainImageCount; ++i) {
						for (int j = 0U; j < colorViewCount; ++j) {
							if (swapchainImageIndices & (1 << j) != 0) {
								attachments[j] = gpuFramebuffer.gpuColorViews[j].swapchainVkImageViews[i];
							}
						}
						if (swapchainImageIndices & (1 << colorViewCount) != 0) {
							attachments[colorViewCount] = gpuFramebuffer.gpuDepthStencilView.swapchainVkImageViews[i];
						}
						VK_CHECK!(vkCreateFramebuffer(device.gpuDevice().vkDevice, &createInfo, null, &gpuFramebuffer.vkFrameBuffers[i]));
					}
				}
			}

			public static void cmdFuncCCVKCreateShader(CCVKDevice device, CCVKGPUShader gpuShader) {
				SPIRVUtils spirv = SPIRVUtils.getInstance();

				for (ref CCVKGPUShaderStage stage in ref gpuShader.gpuStages) {
					spirv.compileGLSL(stage.type, scope $"#version 450\n{stage.source}");
					if (stage.type == ShaderStageFlagBit.VERTEX) spirv.compressInputLocations(ref gpuShader.attributes);

					VkShaderModuleCreateInfo createInfo = .() { sType = .VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO };
					createInfo.codeSize = spirv.getOutputSize();
					createInfo.pCode = spirv.getOutputData();
					VK_CHECK!(vkCreateShaderModule(device.gpuDevice().vkDevice, &createInfo, null, &stage.vkShader));
				}

				WriteWarning(scope $"Shader '{gpuShader.name}' compilation succeeded.");
			}

			public static void cmdFuncCCVKCreateDescriptorSetLayout(CCVKDevice device, CCVKGPUDescriptorSetLayout gpuDescriptorSetLayout) {
				CCVKGPUDevice gpuDevice = device.gpuDevice();
				int bindingCount = gpuDescriptorSetLayout.bindings.Count;

				gpuDescriptorSetLayout.vkBindings.Resize(bindingCount);
				for (int i = 0U; i < bindingCount; ++i) {
					readonly ref DescriptorSetLayoutBinding binding = ref gpuDescriptorSetLayout.bindings[i];
					ref VkDescriptorSetLayoutBinding vkBinding = ref gpuDescriptorSetLayout.vkBindings[i];
					vkBinding.stageFlags = mapVkShaderStageFlags(binding.stageFlags);
					vkBinding.descriptorType = mapVkDescriptorType(binding.descriptorType);
					vkBinding.binding = binding.binding;
					vkBinding.descriptorCount = binding.count;
				}

				VkDescriptorSetLayoutCreateInfo setCreateInfo = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO };
				setCreateInfo.bindingCount = (uint32)bindingCount;
				setCreateInfo.pBindings = gpuDescriptorSetLayout.vkBindings.Ptr;
				VK_CHECK!(vkCreateDescriptorSetLayout(gpuDevice.vkDevice, &setCreateInfo, null, &gpuDescriptorSetLayout.vkDescriptorSetLayout));

				CCVKGPUDescriptorSetPool pool = gpuDevice.getDescriptorSetPool(gpuDescriptorSetLayout.id);
				pool.link(gpuDevice, gpuDescriptorSetLayout.maxSetsPerPool, gpuDescriptorSetLayout.vkBindings, gpuDescriptorSetLayout.vkDescriptorSetLayout);

				gpuDescriptorSetLayout.defaultDescriptorSet = pool.request();

				if (gpuDevice.useDescriptorUpdateTemplate && bindingCount > 0) {
					readonly ref List<VkDescriptorSetLayoutBinding> bindings = ref gpuDescriptorSetLayout.vkBindings;

					List<VkDescriptorUpdateTemplateEntry> entries = scope :: .() {Count = bindingCount};
					for (int j = 0U, k = 0U; j < bindingCount; ++j) {
						readonly ref VkDescriptorSetLayoutBinding binding = ref bindings[j];
						if (binding.descriptorType != .VK_DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK) {
							entries[j].dstBinding = binding.binding;
							entries[j].dstArrayElement = 0;
							entries[j].descriptorCount = binding.descriptorCount;
							entries[j].descriptorType = binding.descriptorType;
							entries[j].offset = (uint)sizeof(CCVKDescriptorInfo) * (uint)k;
							entries[j].stride = sizeof(CCVKDescriptorInfo);
							k += binding.descriptorCount;
						}
					}

					VkDescriptorUpdateTemplateCreateInfo createInfo = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_UPDATE_TEMPLATE_CREATE_INFO };
					createInfo.descriptorUpdateEntryCount = (uint32)bindingCount;
					createInfo.pDescriptorUpdateEntries = entries.Ptr;
					createInfo.templateType = .VK_DESCRIPTOR_UPDATE_TEMPLATE_TYPE_DESCRIPTOR_SET;
					createInfo.descriptorSetLayout = gpuDescriptorSetLayout.vkDescriptorSetLayout;
					if (gpuDevice.minorVersion > 0) {
						VK_CHECK!(vkCreateDescriptorUpdateTemplate(gpuDevice.vkDevice, &createInfo, null, &gpuDescriptorSetLayout.vkDescriptorUpdateTemplate));
					}
					else {
						VK_CHECK!(vkCreateDescriptorUpdateTemplateKHR(gpuDevice.vkDevice, &createInfo, null, &gpuDescriptorSetLayout.vkDescriptorUpdateTemplate));
					}
				}
			}

			public static void cmdFuncCCVKCreatePipelineLayout(CCVKDevice device, CCVKGPUPipelineLayout gpuPipelineLayout) {
				CCVKGPUDevice gpuDevice = device.gpuDevice();
				int layoutCount = gpuPipelineLayout.setLayouts.Count;

				List<VkDescriptorSetLayout> descriptorSetLayouts = scope .(){Count = layoutCount};
				for (uint32 i = 0; i < layoutCount; ++i) {
					descriptorSetLayouts[i] = gpuPipelineLayout.setLayouts[i].vkDescriptorSetLayout;
				}

				VkPipelineLayoutCreateInfo pipelineLayoutCreateInfo = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO };
				pipelineLayoutCreateInfo.setLayoutCount = (uint32)layoutCount;
				pipelineLayoutCreateInfo.pSetLayouts = descriptorSetLayouts.Ptr;
				VK_CHECK!(vkCreatePipelineLayout(gpuDevice.vkDevice, &pipelineLayoutCreateInfo, null, &gpuPipelineLayout.vkPipelineLayout));
			}

			public static void cmdFuncCCVKCreateGraphicsPipelineState(CCVKDevice device, CCVKGPUPipelineState gpuPipelineState) {
				/*static*/ List<VkPipelineShaderStageCreateInfo> stageInfos = scope .();
				/*static*/ List<VkVertexInputBindingDescription> bindingDescriptions = scope .();
				/*static*/ List<VkVertexInputAttributeDescription> attributeDescriptions = scope .();
				/*static*/ List<uint32> offsets = scope .();
				/*static*/ List<VkDynamicState> dynamicStates = scope .();
				/*static*/ List<VkPipelineColorBlendAttachmentState> blendTargets = scope .();

				VkGraphicsPipelineCreateInfo createInfo = .() { sType = .VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO };

				///////////////////// Shader Stage /////////////////////

				var stages = ref gpuPipelineState.gpuShader.gpuStages;
				readonly int stageCount = stages.Count;

				stageInfos.Resize(stageCount,.(){sType = .VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO });
				for (int i = 0U; i < stageCount; ++i) {
					stageInfos[i].stage = mapVkShaderStageFlagBits(stages[i].type);
					stageInfos[i].module = stages[i].vkShader;
					stageInfos[i].pName = "main";
				}
				createInfo.stageCount = (uint32)stageCount;
				createInfo.pStages = stageInfos.Ptr;

				///////////////////// Input State /////////////////////

				readonly ref VertexAttributeList attributes = ref gpuPipelineState.inputState.attributes;
				readonly int attributeCount = attributes.Count;
				uint32 bindingCount = 1;
				for (int i = 0U; i < attributeCount; ++i) {
					readonly ref VertexAttribute attr = ref attributes[i];
					bindingCount = Math.Max(bindingCount, attr.stream + 1);
				}

				bindingDescriptions.Resize(bindingCount);
				for (uint32 i = 0U; i < bindingCount; ++i) {
					bindingDescriptions[i].binding = i;
					bindingDescriptions[i].stride = 0;
					bindingDescriptions[i].inputRate = .VK_VERTEX_INPUT_RATE_VERTEX;
				}
				for (int i = 0U; i < attributeCount; ++i) {
					readonly ref VertexAttribute attr = ref attributes[i];
					bindingDescriptions[attr.stream].stride += GFX_FORMAT_INFOS[(uint32)attr.format].size;
					if (attr.isInstanced) {
						bindingDescriptions[attr.stream].inputRate = .VK_VERTEX_INPUT_RATE_INSTANCE;
					}
				}

				readonly ref VertexAttributeList shaderAttrs = ref gpuPipelineState.gpuShader.attributes;
				readonly int shaderAttrCount = shaderAttrs.Count;

				attributeDescriptions.Resize(shaderAttrCount);
				for (int i = 0; i < shaderAttrCount; ++i) {
					bool attributeFound = false;
					offsets.Resize(bindingCount, 0);
					for (readonly ref VertexAttribute attr in ref attributes) {
						if (shaderAttrs[i].name == attr.name) {
							attributeDescriptions[i].location = shaderAttrs[i].location;
							attributeDescriptions[i].binding = attr.stream;
							attributeDescriptions[i].format = mapVkFormat(attr.format, device.gpuDevice());
							attributeDescriptions[i].offset = offsets[attr.stream];
							attributeFound = true;
							break;
						}
						offsets[attr.stream] += GFX_FORMAT_INFOS[(uint32)attr.format].size;
					}
					if (!attributeFound) { // handle absent attribute
						attributeDescriptions[i].location = shaderAttrs[i].location;
						attributeDescriptions[i].binding = 0;
						attributeDescriptions[i].format = mapVkFormat(shaderAttrs[i].format, device.gpuDevice());
						attributeDescriptions[i].offset = 0; // reuse the first attribute as dummy data
					}
				}

				VkPipelineVertexInputStateCreateInfo vertexInput = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO };
				vertexInput.vertexBindingDescriptionCount = bindingCount;
				vertexInput.pVertexBindingDescriptions = bindingDescriptions.Ptr;
				vertexInput.vertexAttributeDescriptionCount = uint32(shaderAttrCount);
				vertexInput.pVertexAttributeDescriptions = attributeDescriptions.Ptr;
				createInfo.pVertexInputState = &vertexInput;

				///////////////////// Input Asembly State /////////////////////

				VkPipelineInputAssemblyStateCreateInfo inputAssembly = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO };
				inputAssembly.topology = VK_PRIMITIVE_MODES[(uint32)gpuPipelineState.primitive];
				createInfo.pInputAssemblyState = &inputAssembly;

				///////////////////// Dynamic State /////////////////////

				dynamicStates.AddRange(scope VkDynamicState[](.VK_DYNAMIC_STATE_VIEWPORT, .VK_DYNAMIC_STATE_SCISSOR));
				insertVkDynamicStates(dynamicStates, gpuPipelineState.dynamicStates);

				VkPipelineDynamicStateCreateInfo dynamicState = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO };
				dynamicState.dynamicStateCount = (uint32)dynamicStates.Count;
				dynamicState.pDynamicStates = dynamicStates.Ptr;
				createInfo.pDynamicState = &dynamicState;

				///////////////////// Viewport State /////////////////////

				VkPipelineViewportStateCreateInfo viewportState = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO };
				viewportState.viewportCount = 1; // dynamic by default
				viewportState.scissorCount = 1;  // dynamic by default
				createInfo.pViewportState = &viewportState;

				///////////////////// Rasterization State /////////////////////

				VkPipelineRasterizationStateCreateInfo rasterizationState = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO };

				// rasterizationState.depthClampEnable;
				rasterizationState.rasterizerDiscardEnable = gpuPipelineState.rs.isDiscard;
				rasterizationState.polygonMode = VK_POLYGON_MODES[(uint32)gpuPipelineState.rs.polygonMode];
				rasterizationState.cullMode = VK_CULL_MODES[(uint32)gpuPipelineState.rs.cullMode];
				rasterizationState.frontFace = gpuPipelineState.rs.isFrontFaceCCW == 1 ? .VK_FRONT_FACE_COUNTER_CLOCKWISE : .VK_FRONT_FACE_CLOCKWISE;
				rasterizationState.depthBiasEnable = gpuPipelineState.rs.depthBiasEnabled;
				rasterizationState.depthBiasConstantFactor = gpuPipelineState.rs.depthBias;
				rasterizationState.depthBiasClamp = gpuPipelineState.rs.depthBiasClamp;
				rasterizationState.depthBiasSlopeFactor = gpuPipelineState.rs.depthBiasSlop;
				rasterizationState.lineWidth = gpuPipelineState.rs.lineWidth;
				createInfo.pRasterizationState = &rasterizationState;

				///////////////////// Multisample State /////////////////////

				VkPipelineMultisampleStateCreateInfo multisampleState = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO };
				multisampleState.rasterizationSamples = gpuPipelineState.gpuRenderPass.sampleCounts[gpuPipelineState.subpass];
				multisampleState.alphaToCoverageEnable = gpuPipelineState.bs.isA2C;
				// multisampleState.sampleShadingEnable;
				// multisampleState.minSampleShading;
				// multisampleState.pSampleMask;
				// multisampleState.alphaToOneEnable;
				createInfo.pMultisampleState = &multisampleState;

				///////////////////// Depth Stencil State /////////////////////

				VkPipelineDepthStencilStateCreateInfo depthStencilState = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO };
				depthStencilState.depthTestEnable = gpuPipelineState.dss.depthTest;
				depthStencilState.depthWriteEnable = gpuPipelineState.dss.depthWrite;
				depthStencilState.depthCompareOp = VK_CMP_FUNCS[(uint32)gpuPipelineState.dss.depthFunc];
				depthStencilState.stencilTestEnable = gpuPipelineState.dss.stencilTestFront;

				depthStencilState.front = .(){
					failOp = VK_STENCIL_OPS[(uint32)gpuPipelineState.dss.stencilFailOpFront],
					passOp = VK_STENCIL_OPS[(uint32)gpuPipelineState.dss.stencilPassOpFront],
					depthFailOp = VK_STENCIL_OPS[(uint32)gpuPipelineState.dss.stencilZFailOpFront],
					compareOp = VK_CMP_FUNCS[(uint32)gpuPipelineState.dss.stencilFuncFront],
					compareMask = gpuPipelineState.dss.stencilReadMaskFront,
					writeMask = gpuPipelineState.dss.stencilWriteMaskFront,
					reference = gpuPipelineState.dss.stencilRefFront,
				};
				depthStencilState.back = .(){
					failOp = VK_STENCIL_OPS[(uint32)gpuPipelineState.dss.stencilFailOpBack],
					passOp = VK_STENCIL_OPS[(uint32)gpuPipelineState.dss.stencilPassOpBack],
					depthFailOp = VK_STENCIL_OPS[(uint32)gpuPipelineState.dss.stencilZFailOpBack],
					compareOp = VK_CMP_FUNCS[(uint32)gpuPipelineState.dss.stencilFuncBack],
					compareMask = gpuPipelineState.dss.stencilReadMaskBack,
					writeMask = gpuPipelineState.dss.stencilWriteMaskBack,
					reference = gpuPipelineState.dss.stencilRefBack,
				};
				// depthStencilState.depthBoundsTestEnable;
				// depthStencilState.minDepthBounds;
				// depthStencilState.maxDepthBounds;
				createInfo.pDepthStencilState = &depthStencilState;

				///////////////////// Blend State /////////////////////

				int blendTargetCount = gpuPipelineState.gpuRenderPass.subpasses[gpuPipelineState.subpass].colors.Count;
				blendTargets.Resize(blendTargetCount, .());

				for (int i = 0U; i < blendTargetCount; ++i) {
					BlendTarget target = (i >= gpuPipelineState.bs.targets.Count ? gpuPipelineState.bs.targets[0] : gpuPipelineState.bs.targets[i]);

					blendTargets[i].blendEnable = target.blend;
					blendTargets[i].srcColorBlendFactor = VK_BLEND_FACTORS[(uint32)target.blendSrc];
					blendTargets[i].dstColorBlendFactor = VK_BLEND_FACTORS[(uint32)target.blendDst];
					blendTargets[i].colorBlendOp = VK_BLEND_OPS[(uint32)target.blendEq];
					blendTargets[i].srcAlphaBlendFactor = VK_BLEND_FACTORS[(uint32)target.blendSrcAlpha];
					blendTargets[i].dstAlphaBlendFactor = VK_BLEND_FACTORS[(uint32)target.blendDstAlpha];
					blendTargets[i].alphaBlendOp = VK_BLEND_OPS[(uint32)target.blendAlphaEq];
					blendTargets[i].colorWriteMask = mapVkColorComponentFlags(target.blendColorMask);
				}
				ref Color blendColor = ref gpuPipelineState.bs.blendColor;

				VkPipelineColorBlendStateCreateInfo colorBlendState = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO };
				// colorBlendState.logicOpEnable;
				// colorBlendState.logicOp;
				colorBlendState.attachmentCount = uint32(blendTargetCount);
				colorBlendState.pAttachments = blendTargets.Ptr;
				colorBlendState.blendConstants[0] = blendColor.x;
				colorBlendState.blendConstants[1] = blendColor.y;
				colorBlendState.blendConstants[2] = blendColor.z;
				colorBlendState.blendConstants[3] = blendColor.w;
				createInfo.pColorBlendState = &colorBlendState;

				///////////////////// ShadingRate /////////////////////
				VkPipelineFragmentShadingRateStateCreateInfoKHR shadingRateInfo = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_FRAGMENT_SHADING_RATE_STATE_CREATE_INFO_KHR };
				if (device.getCapabilities().supportVariableRateShading &&
					gpuPipelineState.gpuRenderPass.hasShadingAttachment(gpuPipelineState.subpass)) {
					shadingRateInfo.fragmentSize = .(1, 1); // perDraw && perVertex shading rate not support.
					shadingRateInfo.combinerOps[0] = .VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR;
					shadingRateInfo.combinerOps[1] = .VK_FRAGMENT_SHADING_RATE_COMBINER_OP_REPLACE_KHR;
					createInfo.pNext = &shadingRateInfo;
				}

				///////////////////// References /////////////////////

				createInfo.layout = gpuPipelineState.gpuPipelineLayout.vkPipelineLayout;
				createInfo.renderPass = gpuPipelineState.gpuRenderPass.vkRenderPass;
				createInfo.subpass = gpuPipelineState.subpass;

				///////////////////// Creation /////////////////////
				var pipelineCache = device.pipelineCache();
				Runtime.Assert(pipelineCache != null);
				pipelineCache.setDirty();
				VK_CHECK!(vkCreateGraphicsPipelines(device.gpuDevice().vkDevice, pipelineCache.getHandle(),
					1, &createInfo, null, &gpuPipelineState.vkPipeline));
			}

			public static void cmdFuncCCVKCreateComputePipelineState(CCVKDevice device, CCVKGPUPipelineState gpuPipelineState) {
				VkComputePipelineCreateInfo createInfo = .() { sType = .VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO };

				///////////////////// Shader Stage /////////////////////

				readonly var stages = ref gpuPipelineState.gpuShader.gpuStages;
				VkPipelineShaderStageCreateInfo stageInfo = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO };
				stageInfo.stage = mapVkShaderStageFlagBits(stages[0].type);
				stageInfo.module = stages[0].vkShader;
				stageInfo.pName = "main";

				createInfo.stage = stageInfo;
				createInfo.layout = gpuPipelineState.gpuPipelineLayout.vkPipelineLayout;

				///////////////////// Creation /////////////////////

				var pipelineCache = device.pipelineCache();
				Runtime.Assert(pipelineCache != null);
				pipelineCache.setDirty();
				VK_CHECK!(vkCreateComputePipelines(device.gpuDevice().vkDevice, pipelineCache.getHandle(),
					1, &createInfo, null, &gpuPipelineState.vkPipeline));
			}

			public static void cmdFuncCCVKCreateGeneralBarrier(CCVKDevice* device, CCVKGPUGeneralBarrier* gpuGeneralBarrier) {
				gpuGeneralBarrier.barrier.prevAccessCount = (uint32)gpuGeneralBarrier.prevAccesses.Count;
				gpuGeneralBarrier.barrier.pPrevAccesses = gpuGeneralBarrier.prevAccesses.Ptr;
				gpuGeneralBarrier.barrier.nextAccessCount = (uint32)gpuGeneralBarrier.nextAccesses.Count;
				gpuGeneralBarrier.barrier.pNextAccesses = gpuGeneralBarrier.nextAccesses.Ptr;

				thsvsGetVulkanMemoryBarrier(gpuGeneralBarrier.barrier, &gpuGeneralBarrier.srcStageMask, &gpuGeneralBarrier.dstStageMask, &gpuGeneralBarrier.vkBarrier);
			}

			static void bufferUpload(in CCVKGPUBufferView stagingBuffer, CCVKGPUBuffer gpuBuffer, VkBufferCopy region, in CCVKGPUCommandBuffer gpuCommandBuffer) {
				var region;
if(BARRIER_DEDUCTION_LEVEL >= BARRIER_DEDUCTION_LEVEL_BASIC) {
				if (gpuBuffer.transferAccess != 0) {
					// guard against WAW hazard
					VkMemoryBarrier vkBarrier = .() { sType = .VK_STRUCTURE_TYPE_MEMORY_BARRIER };
					vkBarrier.srcAccessMask = .VK_ACCESS_TRANSFER_WRITE_BIT;
					vkBarrier.dstAccessMask = .VK_ACCESS_TRANSFER_WRITE_BIT;
					vkCmdPipelineBarrier(gpuCommandBuffer.vkCommandBuffer,
						.VK_PIPELINE_STAGE_TRANSFER_BIT,
						.VK_PIPELINE_STAGE_TRANSFER_BIT,
						0, 1, &vkBarrier, 0, null, 0, null);
				}
}
				vkCmdCopyBuffer(gpuCommandBuffer.vkCommandBuffer, stagingBuffer.gpuBuffer.vkBuffer, gpuBuffer.vkBuffer, 1, &region);
			};

			public static void cmdFuncCCVKUpdateBuffer(CCVKDevice device, CCVKGPUBuffer gpuBuffer, void* buffer, uint32 size, CCVKGPUCommandBuffer cmdBuffer = null) {
				if (gpuBuffer == null) return;

				void* dataToUpload = null;
				int sizeToUpload = 0U;

				if (hasFlag(gpuBuffer.usage, BufferUsageBit.INDIRECT)) {
					int drawInfoCount = size / sizeof(DrawInfo);
					var drawInfo = (DrawInfo*)buffer;
					if (drawInfoCount > 0) {
						if (drawInfo.indexCount > 0) {
							for (int i = 0; i < drawInfoCount; ++i) {
								gpuBuffer.indexedIndirectCmds[i].indexCount = drawInfo.indexCount;
								gpuBuffer.indexedIndirectCmds[i].instanceCount = Math.Max(drawInfo.instanceCount, 1U);
								gpuBuffer.indexedIndirectCmds[i].firstIndex = drawInfo.firstIndex;
								gpuBuffer.indexedIndirectCmds[i].vertexOffset = drawInfo.vertexOffset;
								gpuBuffer.indexedIndirectCmds[i].firstInstance = drawInfo.firstInstance;
								drawInfo++;
							}
							dataToUpload = gpuBuffer.indexedIndirectCmds.Ptr;
							sizeToUpload = drawInfoCount * sizeof(VkDrawIndexedIndirectCommand);
							gpuBuffer.isDrawIndirectByIndex = true;
						}
						else {
							for (int i = 0; i < drawInfoCount; ++i) {
								gpuBuffer.indirectCmds[i].vertexCount = drawInfo.vertexCount;
								gpuBuffer.indirectCmds[i].instanceCount = Math.Max(drawInfo.instanceCount, 1U);
								gpuBuffer.indirectCmds[i].firstVertex = drawInfo.firstVertex;
								gpuBuffer.indirectCmds[i].firstInstance = drawInfo.firstInstance;
								drawInfo++;
							}
							dataToUpload = gpuBuffer.indirectCmds.Ptr;
							sizeToUpload = drawInfoCount * sizeof(VkDrawIndirectCommand);
							gpuBuffer.isDrawIndirectByIndex = false;
						}
					}
				}
				else {
					dataToUpload = buffer;
					sizeToUpload = size;
				}

				// back buffer instances update command
				uint32 backBufferIndex = device.gpuDevice().curBackBufferIndex;
				if (gpuBuffer.instanceSize > 0) {
					device.gpuBufferHub().record(gpuBuffer, backBufferIndex, sizeToUpload, cmdBuffer == null);
					if (cmdBuffer == null) {
						uint8* dst = gpuBuffer.mappedData + backBufferIndex * gpuBuffer.instanceSize;
						Internal.MemCpy(dst, dataToUpload, sizeToUpload);
						return;
					}
				}

				// upload buffer by chunks
				uint32 chunkSize = Math.Min((uint32)sizeToUpload, CCVKGPUStagingBufferPool.CHUNK_SIZE);

				uint32 chunkOffset = 0U;
				while (sizeToUpload > 0) {
					uint32 chunkSizeToUpload = Math.Min(chunkSize, (uint32)sizeToUpload);
					sizeToUpload -= chunkSizeToUpload;

					CCVKGPUBufferView stagingBuffer = device.gpuStagingBufferPool().alloc(chunkSizeToUpload);
					Internal.MemCpy(stagingBuffer.mappedData(), (uint8*)dataToUpload + chunkOffset, chunkSizeToUpload);

					VkBufferCopy region = .(){
						srcOffset = stagingBuffer.offset,
						dstOffset = gpuBuffer.getStartOffset(backBufferIndex) + chunkOffset,
						size = chunkSizeToUpload,
					};

					chunkOffset += chunkSizeToUpload;

					if (cmdBuffer != null) {
						bufferUpload(stagingBuffer, gpuBuffer, region, cmdBuffer);
					}
					else {
						device.gpuTransportHub().checkIn(
							// capture by ref is safe here since the transport function will be executed immediately in the same thread
							scope[&stagingBuffer, &gpuBuffer, =region](gpuCommandBuffer) => {
								bufferUpload(*stagingBuffer, *gpuBuffer, region, gpuCommandBuffer);
							});
					}
				}

				gpuBuffer.transferAccess = .THSVS_ACCESS_TRANSFER_WRITE;
				device.gpuBarrierManager().checkIn(gpuBuffer);
			}

			public static void cmdFuncCCVKCopyBuffersToTexture(CCVKDevice device, uint8** buffers, CCVKGPUTexture gpuTexture, in BufferTextureCopy* regions, uint32 count, CCVKGPUCommandBuffer gpuCommandBuffer) {
				ref List<ThsvsAccessType> curTypes = ref gpuTexture.currentAccessTypes;

				ThsvsImageBarrier barrier = .();
				barrier.image = gpuTexture.vkImage;
				barrier.discardContents = false;
				barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
				barrier.subresourceRange.layerCount = VK_REMAINING_ARRAY_LAYERS;
				barrier.subresourceRange.aspectMask = gpuTexture.aspectMask;
				barrier.prevAccessCount = (uint32)curTypes.Count;
				barrier.pPrevAccesses = curTypes.Ptr;
				barrier.nextAccessCount = 1;
				barrier.pNextAccesses = getAccessType(AccessFlagBit.TRANSFER_WRITE);

				if (gpuTexture.transferAccess != .THSVS_ACCESS_TRANSFER_WRITE) {
					cmdFuncCCVKImageMemoryBarrier(gpuCommandBuffer, barrier);
				}
				else {
					// guard against WAW hazard
					VkMemoryBarrier vkBarrier = .() { sType = .VK_STRUCTURE_TYPE_MEMORY_BARRIER };
					vkBarrier.srcAccessMask = .VK_ACCESS_TRANSFER_WRITE_BIT;
					vkBarrier.dstAccessMask = .VK_ACCESS_TRANSFER_WRITE_BIT;
					vkCmdPipelineBarrier(gpuCommandBuffer.vkCommandBuffer,
						.VK_PIPELINE_STAGE_TRANSFER_BIT,
						.VK_PIPELINE_STAGE_TRANSFER_BIT,
						0, 1, &vkBarrier, 0, null, 0, null);
				}

				uint32 optimalOffsetAlignment = device.gpuContext().physicalDeviceProperties.limits.optimalBufferCopyOffsetAlignment;
				uint32 optimalRowPitchAlignment = device.gpuContext().physicalDeviceProperties.limits.optimalBufferCopyRowPitchAlignment;
				uint32 offsetAlignment = lcm(GFX_FORMAT_INFOS[(uint32)gpuTexture.format].size, optimalRowPitchAlignment);

				var blockSize = formatAlignment(gpuTexture.format);

				uint32 idx = 0;
				for (int i = 0U; i < count; ++i) {
					readonly ref BufferTextureCopy region = ref regions[i];

					Offset offset = .(){
						x = region.texOffset.x == 0 ? 0 : alignTo(region.texOffset.x, (int32)blockSize.first),
						y = region.texOffset.y == 0 ? 0 : alignTo(region.texOffset.y, (int32)blockSize.second),
						z = region.texOffset.z,
					};

					Extent extent = .(){
						width = alignTo(region.texExtent.width, (uint32)blockSize.first),
						height = alignTo(region.texExtent.height, (uint32)blockSize.second),
						depth = region.texExtent.depth,
					};

					Extent stride = .(){
						width = region.buffStride > 0 ? region.buffStride : extent.width,
						height = region.buffTexHeight > 0 ? region.buffTexHeight : extent.height,
						depth = 0, // useless
					};

					uint32 layerCount = region.texSubres.layerCount;
					uint32 baseLayer = region.texSubres.baseArrayLayer;
					uint32 mipLevel = region.texSubres.mipLevel;

					uint32 rowPitchSize = formatSize(gpuTexture.format, extent.width, 1, 1);
					rowPitchSize = alignTo(rowPitchSize, optimalRowPitchAlignment);
					// what if the optimal alignment is smaller than a block size
					uint32 rowPitch = rowPitchSize / formatSize(gpuTexture.format, 1, 1, 1) * blockSize.first;

					uint32 destRowSize = formatSize(gpuTexture.format, extent.width, 1, 1);
					uint32 destSliceSize = formatSize(gpuTexture.format, extent.width, extent.height, 1);
					uint32 buffStrideSize = formatSize(gpuTexture.format, stride.width, 1, 1);
					uint32 buffSliceSize = formatSize(gpuTexture.format, stride.width, stride.height, 1);

					// calculate the max height to upload per staging buffer chunk
					uint32 chunkHeight = extent.height;
					int chunkSize = rowPitchSize * (extent.height / blockSize.second);
					while (chunkSize > CCVKGPUStagingBufferPool.CHUNK_SIZE) {
						chunkHeight = (uint32)alignTo((chunkHeight - 1) / 2 + 1, blockSize.second);
						chunkSize = rowPitchSize * (chunkHeight / blockSize.second);
					}

					uint32 destOffset = 0;
					uint32 buffOffset = 0;

					uint32 destWidth = (region.texExtent.width + (uint32)offset.x == (gpuTexture.width >> mipLevel)) ? region.texExtent.width : extent.width;
					uint32 destHeight = (region.texExtent.height + (uint32)offset.y == (gpuTexture.height >> mipLevel)) ? region.texExtent.height : extent.height;

					int32 heightOffset = 0;
					uint32 stepHeight = 0;
					for (uint32 l = 0; l < layerCount; l++) {
						for (uint32 depth = 0; depth < extent.depth; ++depth) {
							buffOffset = region.buffOffset + depth * buffSliceSize;
							// upload in chunks
							for (uint32 h = 0U; h < extent.height; h += chunkHeight) {
								destOffset = 0;
								heightOffset = (int32)h;
								stepHeight = (uint32)Math.Min(chunkHeight, extent.height - h);

								uint32 stagingBufferSize = rowPitchSize * (stepHeight / blockSize.second);
								CCVKGPUBufferView stagingBuffer = device.gpuStagingBufferPool().alloc(stagingBufferSize, offsetAlignment);

								for (uint32 j = 0; j < stepHeight; j += blockSize.second) {
									Internal.MemCpy(stagingBuffer.mappedData() + destOffset, buffers[idx] + buffOffset, destRowSize);
									destOffset += rowPitchSize;
									buffOffset += buffStrideSize;
								}

								VkBufferImageCopy stagingRegion = .();
								stagingRegion.bufferOffset = stagingBuffer.offset;
								stagingRegion.bufferRowLength = rowPitch;
								stagingRegion.bufferImageHeight = stepHeight;
								stagingRegion.imageSubresource = .(){ aspectMask = gpuTexture.aspectMask, mipLevel = mipLevel, baseArrayLayer = l + baseLayer, layerCount = 1 };
								stagingRegion.imageOffset = .(){ x = offset.x, y = offset.y + heightOffset, z = offset.z + (int32)depth };
								stagingRegion.imageExtent = .(){ width = destWidth, height = (uint32)Math.Min(stepHeight, destHeight - (uint32)heightOffset), depth = 1 };

								vkCmdCopyBufferToImage(gpuCommandBuffer.vkCommandBuffer, stagingBuffer.gpuBuffer.vkBuffer, gpuTexture.vkImage,
									.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &stagingRegion);
							}
						}
						idx++;
					}
				}

				if (hasFlag(gpuTexture.flags, TextureFlags.GEN_MIPMAP)) {
					VkFormatProperties formatProperties = .();
					VulkanNative.vkGetPhysicalDeviceFormatProperties(device.gpuContext().physicalDevice, mapVkFormat(gpuTexture.format, device.gpuDevice()), &formatProperties);
					VkFormatFeatureFlags mipmapFeatures = .VK_FORMAT_FEATURE_BLIT_SRC_BIT | .VK_FORMAT_FEATURE_BLIT_DST_BIT | .VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT;

					if (formatProperties.optimalTilingFeatures & mipmapFeatures != 0) {
						int32 width = (int32)gpuTexture.width;
						int32 height = (int32)gpuTexture.height;

						VkImageBlit blitInfo = .();
						blitInfo.srcSubresource.aspectMask = gpuTexture.aspectMask;
						blitInfo.srcSubresource.layerCount = gpuTexture.arrayLayers;
						blitInfo.dstSubresource.aspectMask = gpuTexture.aspectMask;
						blitInfo.dstSubresource.layerCount = gpuTexture.arrayLayers;
						blitInfo.srcOffsets[1] = .(){ x = width, y = height, z=1 };
						blitInfo.dstOffsets[1] = .(){ x=Math.Max(width >> 1, 1), y=Math.Max(height >> 1, 1), z=1 };
						barrier.subresourceRange.levelCount = 1;
						barrier.prevAccessCount = 1;
						barrier.pPrevAccesses = getAccessType(AccessFlagBit.TRANSFER_WRITE);
						barrier.pNextAccesses = getAccessType(AccessFlagBit.TRANSFER_READ);

						for (uint32 i = 1U; i < gpuTexture.mipLevels; ++i) {
							barrier.subresourceRange.baseMipLevel = i - 1;
							cmdFuncCCVKImageMemoryBarrier(gpuCommandBuffer, barrier);

							blitInfo.srcSubresource.mipLevel = i - 1;
							blitInfo.dstSubresource.mipLevel = i;
							vkCmdBlitImage(gpuCommandBuffer.vkCommandBuffer, gpuTexture.vkImage, .VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
								gpuTexture.vkImage, .VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &blitInfo, .VK_FILTER_LINEAR);

							readonly int32 w = blitInfo.srcOffsets[1].x = blitInfo.dstOffsets[1].x;
							readonly int32 h = blitInfo.srcOffsets[1].y = blitInfo.dstOffsets[1].y;
							blitInfo.dstOffsets[1].x = Math.Max(w >> 1, 1);
							blitInfo.dstOffsets[1].y = Math.Max(h >> 1, 1);
						}

						barrier.subresourceRange.baseMipLevel = 0;
						barrier.subresourceRange.levelCount = gpuTexture.mipLevels - 1;
						barrier.pPrevAccesses = getAccessType(AccessFlagBit.TRANSFER_READ);
						barrier.pNextAccesses = getAccessType(AccessFlagBit.TRANSFER_WRITE);

						cmdFuncCCVKImageMemoryBarrier(gpuCommandBuffer, barrier);
					}
					else {
						char8* formatName = GFX_FORMAT_INFOS[(uint32)gpuTexture.format].name;
						WriteWarning("cmdFuncCCVKCopyBuffersToTexture: generate mipmap for {} is not supported on this platform", formatName);
					}
				}

				curTypes.Clear();
				curTypes.Add(.THSVS_ACCESS_TRANSFER_WRITE);
				gpuTexture.transferAccess = .THSVS_ACCESS_TRANSFER_WRITE;
				device.gpuBarrierManager().checkIn(gpuTexture);
			}

			public static void cmdFuncCCVKCopyTextureToBuffers(CCVKDevice device, CCVKGPUTexture srcTexture, CCVKGPUBufferView destBuffer, in BufferTextureCopy* regions, uint32 count, CCVKGPUCommandBuffer gpuCommandBuffer) {
				ref List<ThsvsAccessType> curTypes = ref srcTexture.currentAccessTypes;

				ThsvsImageBarrier barrier = .();
				barrier.image = srcTexture.vkImage;
				barrier.discardContents = false;
				barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				barrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
				barrier.subresourceRange.layerCount = VK_REMAINING_ARRAY_LAYERS;
				barrier.subresourceRange.aspectMask = srcTexture.aspectMask;
				barrier.prevAccessCount = uint32(curTypes.Count);
				barrier.pPrevAccesses = curTypes.Ptr;
				barrier.nextAccessCount = 1;
				barrier.pNextAccesses = getAccessType(AccessFlagBit.TRANSFER_READ);

				if (srcTexture.transferAccess != .THSVS_ACCESS_TRANSFER_READ) {
					cmdFuncCCVKImageMemoryBarrier(gpuCommandBuffer, barrier);
				}

				List<VkBufferImageCopy> stagingRegions = scope .() {Count = count};
				VkDeviceSize offset = 0;
				for (int i = 0U; i < count; ++i) {
					readonly ref BufferTextureCopy region = ref regions[i];
					ref VkBufferImageCopy stagingRegion = ref stagingRegions[i];
					stagingRegion.bufferOffset = destBuffer.offset + offset;
					stagingRegion.bufferRowLength = region.buffStride;
					stagingRegion.bufferImageHeight = region.buffTexHeight;
					stagingRegion.imageSubresource = .(){ aspectMask=srcTexture.aspectMask, mipLevel=region.texSubres.mipLevel, baseArrayLayer=region.texSubres.baseArrayLayer, layerCount=region.texSubres.layerCount };
					stagingRegion.imageOffset = .(){ x=region.texOffset.x, y=region.texOffset.y, z=region.texOffset.z };
					stagingRegion.imageExtent = .(){ width=region.texExtent.width, height=region.texExtent.height, depth=region.texExtent.depth };

					uint32 w = region.buffStride > 0 ? region.buffStride : region.texExtent.width;
					uint32 h = region.buffTexHeight > 0 ? region.buffTexHeight : region.texExtent.height;
					uint32 regionSize = formatSize(srcTexture.format, w, h, region.texExtent.depth);

					offset += regionSize;
				}
				vkCmdCopyImageToBuffer(gpuCommandBuffer.vkCommandBuffer, srcTexture.vkImage, .VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
					destBuffer.gpuBuffer.vkBuffer, (uint32)stagingRegions.Count, stagingRegions.Ptr);

				curTypes.Clear();
				curTypes.Add(.THSVS_ACCESS_TRANSFER_READ);
				srcTexture.transferAccess = .THSVS_ACCESS_TRANSFER_READ;
				device.gpuBarrierManager().checkIn(srcTexture);
			}

			public static void cmdFuncCCVKDestroyQueryPool(CCVKGPUDevice gpuDevice, CCVKGPUQueryPool gpuQueryPool) {
				if (gpuQueryPool.vkPool != .Null) {
					vkDestroyQueryPool(gpuDevice.vkDevice, gpuQueryPool.vkPool, null);
					gpuQueryPool.vkPool = .Null;
				}
			}

			public static void cmdFuncCCVKDestroyRenderPass(CCVKGPUDevice gpuDevice, CCVKGPURenderPass gpuRenderPass) {
				if (gpuRenderPass.vkRenderPass != .Null) {
					vkDestroyRenderPass(gpuDevice.vkDevice, gpuRenderPass.vkRenderPass, null);
					gpuRenderPass.vkRenderPass = .Null;
				}
			}

			public static void cmdFuncCCVKDestroySampler(CCVKGPUDevice gpuDevice, CCVKGPUSampler gpuSampler) {
				if (gpuSampler.vkSampler != .Null) {
					vkDestroySampler(gpuDevice.vkDevice, gpuSampler.vkSampler, null);
					gpuSampler.vkSampler = .Null;
				}
			}

			public static void cmdFuncCCVKDestroyShader(CCVKGPUDevice gpuDevice, CCVKGPUShader gpuShader) {
				for (ref CCVKGPUShaderStage stage in ref gpuShader.gpuStages) {
					vkDestroyShaderModule(gpuDevice.vkDevice, stage.vkShader, null);
					stage.vkShader = .Null;
				}
			}

			public static void cmdFuncCCVKDestroyFramebuffer(CCVKGPUDevice gpuDevice, CCVKGPUFramebuffer gpuFramebuffer){}

			public static void cmdFuncCCVKDestroyDescriptorSetLayout(CCVKGPUDevice gpuDevice, CCVKGPUDescriptorSetLayout gpuDescriptorSetLayout) {
				if (gpuDescriptorSetLayout.vkDescriptorUpdateTemplate != .Null) {
					if (gpuDevice.minorVersion > 0) {
						vkDestroyDescriptorUpdateTemplate(gpuDevice.vkDevice, gpuDescriptorSetLayout.vkDescriptorUpdateTemplate, null);
					}
					else {
						vkDestroyDescriptorUpdateTemplateKHR(gpuDevice.vkDevice, gpuDescriptorSetLayout.vkDescriptorUpdateTemplate, null);
					}
					gpuDescriptorSetLayout.vkDescriptorUpdateTemplate = .Null;
				}

				if (gpuDescriptorSetLayout.vkDescriptorSetLayout != .Null) {
					vkDestroyDescriptorSetLayout(gpuDevice.vkDevice, gpuDescriptorSetLayout.vkDescriptorSetLayout, null);
					gpuDescriptorSetLayout.vkDescriptorSetLayout = .Null;
				}
			}

			public static void cmdFuncCCVKDestroyPipelineLayout(CCVKGPUDevice gpuDevice, CCVKGPUPipelineLayout gpuPipelineLayout) {
				if (gpuPipelineLayout.vkPipelineLayout != .Null) {
					vkDestroyPipelineLayout(gpuDevice.vkDevice, gpuPipelineLayout.vkPipelineLayout, null);
					gpuPipelineLayout.vkPipelineLayout = .Null;
				}
			}

			public static void cmdFuncCCVKDestroyPipelineState(CCVKGPUDevice gpuDevice, CCVKGPUPipelineState gpuPipelineState) {
				if (gpuPipelineState.vkPipeline != .Null) {
					vkDestroyPipeline(gpuDevice.vkDevice, gpuPipelineState.vkPipeline, null);
					gpuPipelineState.vkPipeline = .Null;
				}
			}

			public static void cmdFuncCCVKImageMemoryBarrier(CCVKGPUCommandBuffer gpuCommandBuffer, in ThsvsImageBarrier imageBarrier) {
				VkPipelineStageFlags srcStageMask = .VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
				VkPipelineStageFlags dstStageMask = .VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
				VkPipelineStageFlags tempSrcStageMask = 0;
				VkPipelineStageFlags tempDstStageMask = 0;
				VkImageMemoryBarrier vkBarrier;
				thsvsGetVulkanImageMemoryBarrier(imageBarrier, &tempSrcStageMask, &tempDstStageMask, &vkBarrier);
				srcStageMask |= tempSrcStageMask;
				dstStageMask |= tempDstStageMask;
				vkCmdPipelineBarrier(gpuCommandBuffer.vkCommandBuffer, srcStageMask, dstStageMask, 0, 0, null, 0, null, 1, &vkBarrier);
			}



		}
