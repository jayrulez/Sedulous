		namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Recycle bin for GPU resources, clears after vkDeviceWaitIdle every frame.
		 * All the destroy events will be postponed to that time.
		 */
		class CCVKGPURecycleBin final {
		public:
			explicit CCVKGPURecycleBin(CCVKGPUDevice* device)
				: _device(device) {
				_resources.resize(16);
			}

			void collect(const CCVKGPUTexture* texture) {
				auto collectHandleFn = [this](VkImage image, VmaAllocation allocation) {
					Resource& res = emplaceBack();
					res.type = RecycledType::TEXTURE;
					res.image.vkImage = image;
					res.image.vmaAllocation = allocation;
					};
				collectHandleFn(texture->vkImage, texture->vmaAllocation);

				if (texture->swapchain != nullptr) {
					for (uint32_t i = 0; i < texture->swapchainVkImages.size() && i < texture->swapchainVmaAllocations.size(); ++i) {
						collectHandleFn(texture->swapchainVkImages[i], texture->swapchainVmaAllocations[i]);
					}
				}
			}
			void collect(const CCVKGPUTextureView* textureView) {
				auto collectHandleFn = [this](VkImageView view) {
					Resource& res = emplaceBack();
					res.type = RecycledType::TEXTURE_VIEW;
					res.vkImageView = view;
					};
				collectHandleFn(textureView->vkImageView);
				for (const auto& swapChainView : textureView->swapchainVkImageViews) {
					collectHandleFn(swapChainView);
				}
			}
			void collect(const CCVKGPUFramebuffer* frameBuffer) {
				auto collectHandleFn = [this](VkFramebuffer fbo) {
					Resource& res = emplaceBack();
					res.type = RecycledType::FRAMEBUFFER;
					res.vkFramebuffer = fbo;
					};
				collectHandleFn(frameBuffer->vkFramebuffer);
				for (const auto& fbo : frameBuffer->vkFrameBuffers) {
					collectHandleFn(fbo);
				}
			}
			void collect(const CCVKGPUDescriptorSet* set) {
				for (const auto& instance : set->instances) {
					collect(set->layoutID, instance.vkDescriptorSet);
				}
			}
			void collect(uint32_t layoutId, VkDescriptorSet set) {
				Resource& res = emplaceBack();
				res.type = RecycledType::DESCRIPTOR_SET;
				res.set.layoutId = layoutId;
				res.set.vkSet = set;
			}
			void collect(const CCVKGPUBuffer* buffer) {
				Resource& res = emplaceBack();
				res.type = RecycledType::BUFFER;
				res.buffer.vkBuffer = buffer->vkBuffer;
				res.buffer.vmaAllocation = buffer->vmaAllocation;
			}

#define DEFINE_RECYCLE_BIN_COLLECT_FN(_type, typeValue, expr)                        \
    void collect(const _type *gpuRes) { /* NOLINT(bugprone-macro-parentheses) N/A */ \
        Resource &res = emplaceBack();                                               \
        res.type = typeValue;                                                        \
        expr;                                                                        \
    }

			DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPURenderPass, RecycledType::RENDER_PASS, res.vkRenderPass = gpuRes->vkRenderPass)
				DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPUSampler, RecycledType::SAMPLER, res.vkSampler = gpuRes->vkSampler)
				DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPUQueryPool, RecycledType::QUERY_POOL, res.vkQueryPool = gpuRes->vkPool)
				DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPUPipelineState, RecycledType::PIPELINE_STATE, res.vkPipeline = gpuRes->vkPipeline)

				void clear() {
				for (uint32_t i = 0U; i < _count; ++i) {
					Resource& res = _resources[i];
					switch (res.type) {
					case RecycledType::BUFFER:
						if (res.buffer.vkBuffer != VK_NULL_HANDLE && res.buffer.vmaAllocation != VK_NULL_HANDLE) {
							vmaDestroyBuffer(_device->memoryAllocator, res.buffer.vkBuffer, res.buffer.vmaAllocation);
							res.buffer.vkBuffer = VK_NULL_HANDLE;
							res.buffer.vmaAllocation = VK_NULL_HANDLE;
						}
						break;
					case RecycledType::TEXTURE:
						if (res.image.vkImage != VK_NULL_HANDLE && res.image.vmaAllocation != VK_NULL_HANDLE) {
							vmaDestroyImage(_device->memoryAllocator, res.image.vkImage, res.image.vmaAllocation);
							res.image.vkImage = VK_NULL_HANDLE;
							res.image.vmaAllocation = VK_NULL_HANDLE;
						}
						break;
					case RecycledType::TEXTURE_VIEW:
						if (res.vkImageView != VK_NULL_HANDLE) {
							vkDestroyImageView(_device->vkDevice, res.vkImageView, nullptr);
							res.vkImageView = VK_NULL_HANDLE;
						}
						break;
					case RecycledType::FRAMEBUFFER:
						if (res.vkFramebuffer != VK_NULL_HANDLE) {
							vkDestroyFramebuffer(_device->vkDevice, res.vkFramebuffer, nullptr);
							res.vkFramebuffer = VK_NULL_HANDLE;
						}
						break;
					case RecycledType::QUERY_POOL:
						if (res.vkQueryPool != VK_NULL_HANDLE) {
							vkDestroyQueryPool(_device->vkDevice, res.vkQueryPool, nullptr);
						}
						break;
					case RecycledType::RENDER_PASS:
						if (res.vkRenderPass != VK_NULL_HANDLE) {
							vkDestroyRenderPass(_device->vkDevice, res.vkRenderPass, nullptr);
						}
						break;
					case RecycledType::SAMPLER:
						if (res.vkSampler != VK_NULL_HANDLE) {
							vkDestroySampler(_device->vkDevice, res.vkSampler, nullptr);
						}
						break;
					case RecycledType::PIPELINE_STATE:
						if (res.vkPipeline != VK_NULL_HANDLE) {
							vkDestroyPipeline(_device->vkDevice, res.vkPipeline, nullptr);
						}
						break;
					case RecycledType::DESCRIPTOR_SET:
						if (res.set.vkSet != VK_NULL_HANDLE) {
							CCVKDevice::getInstance()->gpuDevice()->getDescriptorSetPool(res.set.layoutId)->yield(res.set.vkSet);
						}
						break;
					default: break;
					}
					res.type = RecycledType::UNKNOWN;
				}
				_count = 0;
			}

		private:
			enum class RecycledType {
				UNKNOWN,
				BUFFER,
				BUFFER_VIEW,
				TEXTURE,
				TEXTURE_VIEW,
				FRAMEBUFFER,
				QUERY_POOL,
				RENDER_PASS,
				SAMPLER,
				PIPELINE_STATE,
				DESCRIPTOR_SET,
				EVENT
			};
			struct Buffer {
				VkBuffer vkBuffer;
				VmaAllocation vmaAllocation;
			};
			struct Image {
				VkImage vkImage;
				VmaAllocation vmaAllocation;
			};
			struct Set {
				uint32_t layoutId;
				VkDescriptorSet vkSet;
			};
			struct Resource {
				RecycledType type = RecycledType::UNKNOWN;
				union {
					// resizable resources, cannot take over directly
					// or descriptor sets won't work
					Buffer buffer;
					Image image;
					Set set;
					VkBufferView vkBufferView;
					VkImageView vkImageView;
					VkFramebuffer vkFramebuffer;
					VkQueryPool vkQueryPool;
					VkRenderPass vkRenderPass;
					VkSampler vkSampler;
					VkEvent vkEvent;
					VkPipeline vkPipeline;
				};
			};

			Resource& emplaceBack() {
				if (_resources.size() <= _count) {
					_resources.resize(_count * 2);
				}
				return _resources[_count++];
			}

			CCVKGPUDevice* _device = nullptr;
			ccstd::vector<Resource> _resources;
			size_t _count = 0U;
		};