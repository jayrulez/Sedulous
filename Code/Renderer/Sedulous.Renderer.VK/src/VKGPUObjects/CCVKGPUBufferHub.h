		namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Manages buffer update events, across all back buffer instances.
		 */
		class CCVKGPUBufferHub final {
		public:
			explicit CCVKGPUBufferHub(CCVKGPUDevice* device)
				: _device(device) {
				_buffersToBeUpdated.resize(device->backBufferCount);
			}

			void record(CCVKGPUBuffer* gpuBuffer, uint32_t backBufferIndex, size_t size, bool canMemcpy) {
				for (uint32_t i = 0U; i < _device->backBufferCount; ++i) {
					if (i == backBufferIndex) {
						_buffersToBeUpdated[i].erase(gpuBuffer);
					}
					else {
						_buffersToBeUpdated[i][gpuBuffer] = { backBufferIndex, size, canMemcpy };
					}
				}
			}

			void erase(CCVKGPUBuffer* gpuBuffer) {
				for (uint32_t i = 0U; i < _device->backBufferCount; ++i) {
					if (_buffersToBeUpdated[i].count(gpuBuffer)) {
						_buffersToBeUpdated[i].erase(gpuBuffer);
					}
				}
			}

			void updateBackBufferCount(uint32_t backBufferCount) {
				_buffersToBeUpdated.resize(backBufferCount);
			}

			void flush(CCVKGPUTransportHub* transportHub) {
				auto& buffers = _buffersToBeUpdated[_device->curBackBufferIndex];
				if (buffers.empty()) return;

				bool needTransferCmds = false;
				for (auto& buffer : buffers) {
					if (buffer.second.canMemcpy) {
						uint8_t* src = buffer.first->mappedData + buffer.second.srcIndex * buffer.first->instanceSize;
						uint8_t* dst = buffer.first->mappedData + _device->curBackBufferIndex * buffer.first->instanceSize;
						memcpy(dst, src, buffer.second.size);
					}
					else {
						needTransferCmds = true;
					}
				}
				if (needTransferCmds) {
					transportHub->checkIn([&](const CCVKGPUCommandBuffer* gpuCommandBuffer) {
						VkBufferCopy region;
						for (auto& buffer : buffers) {
							if (buffer.second.canMemcpy) continue;
							region.srcOffset = buffer.first->getStartOffset(buffer.second.srcIndex);
							region.dstOffset = buffer.first->getStartOffset(_device->curBackBufferIndex);
							region.size = buffer.second.size;
							vkCmdCopyBuffer(gpuCommandBuffer->vkCommandBuffer, buffer.first->vkBuffer, buffer.first->vkBuffer, 1, &region);
						}
						});
				}

				buffers.clear();
			}

		private:
			struct BufferUpdate {
				uint32_t srcIndex = 0U;
				size_t size = 0U;
				bool canMemcpy = false;
			};

			ccstd::vector<ccstd::unordered_map<CCVKGPUBuffer*, BufferUpdate>> _buffersToBeUpdated;

			CCVKGPUDevice* _device = nullptr;
		};