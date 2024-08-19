		namespace Sedulous.Renderer.VK.Internal;

		class CCVKGPUBarrierManager final {
		public:
			explicit CCVKGPUBarrierManager(CCVKGPUDevice* device)
				: _device(device) {}

			void checkIn(CCVKGPUBuffer* gpuBuffer) {
				_buffersToBeChecked.insert(gpuBuffer);
			}

			void checkIn(CCVKGPUTexture* gpuTexture, const ThsvsAccessType* newTypes = nullptr, uint32_t newTypeCount = 0) {
				ccstd::vector<ThsvsAccessType>& target = gpuTexture->renderAccessTypes;
				for (uint32_t i = 0U; i < newTypeCount; ++i) {
					if (std::find(target.begin(), target.end(), newTypes[i]) == target.end()) {
						target.push_back(newTypes[i]);
					}
				}
				_texturesToBeChecked.insert(gpuTexture);
			}

			void update(CCVKGPUTransportHub* transportHub) {
				if (_buffersToBeChecked.empty() && _texturesToBeChecked.empty()) return;

				static ccstd::vector<ThsvsAccessType> prevAccesses;
				static ccstd::vector<ThsvsAccessType> nextAccesses;
				static ccstd::vector<VkImageMemoryBarrier> vkImageBarriers;
				VkPipelineStageFlags srcStageMask = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
				VkPipelineStageFlags dstStageMask = VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
				vkImageBarriers.clear();
				prevAccesses.clear();
				nextAccesses.clear();

				for (CCVKGPUBuffer* gpuBuffer : _buffersToBeChecked) {
					ccstd::vector<ThsvsAccessType>& render = gpuBuffer->renderAccessTypes;
					if (gpuBuffer->transferAccess == THSVS_ACCESS_NONE) continue;
					if (std::find(prevAccesses.begin(), prevAccesses.end(), gpuBuffer->transferAccess) == prevAccesses.end()) {
						prevAccesses.push_back(gpuBuffer->transferAccess);
					}
					nextAccesses.insert(nextAccesses.end(), render.begin(), render.end());
					gpuBuffer->transferAccess = THSVS_ACCESS_NONE;
				}

				VkMemoryBarrier vkBarrier;
				VkMemoryBarrier* pVkBarrier = nullptr;
				if (!prevAccesses.empty()) {
					ThsvsGlobalBarrier globalBarrier{};
					globalBarrier.prevAccessCount = utils::toUint(prevAccesses.size());
					globalBarrier.pPrevAccesses = prevAccesses.data();
					globalBarrier.nextAccessCount = utils::toUint(nextAccesses.size());
					globalBarrier.pNextAccesses = nextAccesses.data();
					VkPipelineStageFlags tempSrcStageMask = 0;
					VkPipelineStageFlags tempDstStageMask = 0;
					thsvsGetVulkanMemoryBarrier(globalBarrier, &tempSrcStageMask, &tempDstStageMask, &vkBarrier);
					srcStageMask |= tempSrcStageMask;
					dstStageMask |= tempDstStageMask;
					pVkBarrier = &vkBarrier;
				}

				ThsvsImageBarrier imageBarrier{};
				imageBarrier.discardContents = false;
				imageBarrier.prevLayout = THSVS_IMAGE_LAYOUT_OPTIMAL;
				imageBarrier.nextLayout = THSVS_IMAGE_LAYOUT_OPTIMAL;
				imageBarrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				imageBarrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
				imageBarrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
				imageBarrier.subresourceRange.layerCount = VK_REMAINING_ARRAY_LAYERS;
				imageBarrier.prevAccessCount = 1;

				for (CCVKGPUTexture* gpuTexture : _texturesToBeChecked) {
					ccstd::vector<ThsvsAccessType>& render = gpuTexture->renderAccessTypes;
					if (gpuTexture->transferAccess == THSVS_ACCESS_NONE || render.empty()) continue;
					ccstd::vector<ThsvsAccessType>& current = gpuTexture->currentAccessTypes;
					imageBarrier.pPrevAccesses = &gpuTexture->transferAccess;
					imageBarrier.nextAccessCount = utils::toUint(render.size());
					imageBarrier.pNextAccesses = render.data();
					imageBarrier.image = gpuTexture->vkImage;
					imageBarrier.subresourceRange.aspectMask = gpuTexture->aspectMask;

					VkPipelineStageFlags tempSrcStageMask = 0;
					VkPipelineStageFlags tempDstStageMask = 0;
					vkImageBarriers.emplace_back();
					thsvsGetVulkanImageMemoryBarrier(imageBarrier, &tempSrcStageMask, &tempDstStageMask, &(vkImageBarriers.back()));
					srcStageMask |= tempSrcStageMask;
					dstStageMask |= tempDstStageMask;

					// don't override any other access changes since this barrier always happens first
					if (current.size() == 1 && current[0] == gpuTexture->transferAccess) {
						current = render;
					}
					gpuTexture->transferAccess = THSVS_ACCESS_NONE;
				}

				if (pVkBarrier || !vkImageBarriers.empty()) {
					transportHub->checkIn([&](CCVKGPUCommandBuffer* gpuCommandBuffer) {
						vkCmdPipelineBarrier(gpuCommandBuffer->vkCommandBuffer, srcStageMask, dstStageMask, 0,
							pVkBarrier ? 1 : 0, pVkBarrier, 0, nullptr, utils::toUint(vkImageBarriers.size()), vkImageBarriers.data());
						});
				}

				_buffersToBeChecked.clear();
				_texturesToBeChecked.clear();
			}

			inline void cancel(CCVKGPUBuffer* gpuBuffer) { _buffersToBeChecked.erase(gpuBuffer); }
			inline void cancel(CCVKGPUTexture* gpuTexture) { _texturesToBeChecked.erase(gpuTexture); }

		private:
			ccstd::unordered_set<CCVKGPUBuffer*> _buffersToBeChecked;
			ccstd::unordered_set<CCVKGPUTexture*> _texturesToBeChecked;
			CCVKGPUDevice* _device = nullptr;
		};