using Bulkan;
using System.Collections;
using Bulkan.Utilities;
using Sedulous.Foundation.Collections;
using System;
using System.Threading;
		namespace Sedulous.Renderer.VK.Internal;

		class CCVKGPUDevice {
			public VkDevice vkDevice = .Null;
			public List<VkLayerProperties> layers = new .() ~ delete _;
			public List<VkExtensionProperties> extensions = new .() ~ delete _;
			public VmaAllocator memoryAllocator = default;
			public uint32 minorVersion = 0;

			public VkFormat depthFormat = .VK_FORMAT_UNDEFINED;
			public VkFormat depthStencilFormat = .VK_FORMAT_UNDEFINED;

			public uint32 curBackBufferIndex = 0U;
			public uint32 backBufferCount =3U;

			public bool useDescriptorUpdateTemplate = false;
			public bool useMultiDrawIndirect = false;

			public VulkanNative.vkCreateRenderPass2Function createRenderPass2 = null;

			// for default backup usages
			public CCVKGPUSampler defaultSampler;
			public CCVKGPUTexture defaultTexture;
			public CCVKGPUTextureView defaultTextureView;
			public CCVKGPUBuffer defaultBuffer;

			public CCVKGPUGeneralBarrier defaultColorBarrier;
			public CCVKGPUGeneralBarrier defaultDepthStencilBarrier;

			public HashSet<CCVKGPUSwapchain> swapchains;

			[ThreadStatic]private static uint threadID = (uint)Thread.CurrentThread.Id;

			public CCVKGPUCommandBufferPool getCommandBufferPool() {
				//static uint threadID = ;
				if (!_commandBufferPools.ContainsKey(threadID)) {
					_commandBufferPools[threadID] = new CCVKGPUCommandBufferPool(this);
				}
				return _commandBufferPools[threadID];
			}
			public CCVKGPUDescriptorSetPool getDescriptorSetPool(uint32 layoutID) {
				if (!_descriptorSetPools.ContainsKey(layoutID)) {
					_descriptorSetPools[layoutID] = new CCVKGPUDescriptorSetPool();
				}
				return _descriptorSetPools[layoutID];
			}

			// cannot use thread_local here because we need explicit control over their destruction
			private typealias CommandBufferPools = ConcurrentDictionary<uint, CCVKGPUCommandBufferPool>;
			private CommandBufferPools _commandBufferPools;

			private Dictionary<uint32, CCVKGPUDescriptorSetPool> _descriptorSetPools;
		}