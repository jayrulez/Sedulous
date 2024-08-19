		namespace Sedulous.Renderer.VK.Internal;

		class CCVKGPUDevice final {
		public:
			VkDevice vkDevice{ VK_NULL_HANDLE };
			ccstd::vector<VkLayerProperties> layers;
			ccstd::vector<VkExtensionProperties> extensions;
			VmaAllocator memoryAllocator{ VK_NULL_HANDLE };
			uint32_t minorVersion{ 0U };

			VkFormat depthFormat{ VK_FORMAT_UNDEFINED };
			VkFormat depthStencilFormat{ VK_FORMAT_UNDEFINED };

			uint32_t curBackBufferIndex{ 0U };
			uint32_t backBufferCount{ 3U };

			bool useDescriptorUpdateTemplate{ false };
			bool useMultiDrawIndirect{ false };

			PFN_vkCreateRenderPass2 createRenderPass2{ nullptr };

			// for default backup usages
			IntrusivePtr<CCVKGPUSampler> defaultSampler;
			IntrusivePtr<CCVKGPUTexture> defaultTexture;
			IntrusivePtr<CCVKGPUTextureView> defaultTextureView;
			IntrusivePtr<CCVKGPUBuffer> defaultBuffer;

			CCVKGPUGeneralBarrier defaultColorBarrier;
			CCVKGPUGeneralBarrier defaultDepthStencilBarrier;

			ccstd::unordered_set<CCVKGPUSwapchain*> swapchains;

			CCVKGPUCommandBufferPool* getCommandBufferPool() {
				static thread_local size_t threadID = std::hash<std::thread::id>{}(std::this_thread::get_id());
				if (!_commandBufferPools.count(threadID)) {
					_commandBufferPools[threadID] = ccnew CCVKGPUCommandBufferPool(this);
				}
				return _commandBufferPools[threadID];
			}
			CCVKGPUDescriptorSetPool* getDescriptorSetPool(uint32_t layoutID) {
				if (_descriptorSetPools.find(layoutID) == _descriptorSetPools.end()) {
					_descriptorSetPools[layoutID] = std::make_unique<CCVKGPUDescriptorSetPool>();
				}
				return _descriptorSetPools[layoutID].get();
			}

		private:
			friend class CCVKDevice;

			// cannot use thread_local here because we need explicit control over their destruction
			using CommandBufferPools = tbb::concurrent_unordered_map<size_t, CCVKGPUCommandBufferPool*, std::hash<size_t>>;
			CommandBufferPools _commandBufferPools;

			ccstd::unordered_map<uint32_t, std::unique_ptr<CCVKGPUDescriptorSetPool>> _descriptorSetPools;
		};