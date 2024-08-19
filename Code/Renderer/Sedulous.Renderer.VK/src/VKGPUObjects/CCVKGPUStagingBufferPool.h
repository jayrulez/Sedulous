		namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Staging buffer pool, based on multiple fix-sized VkBuffer blocks.
		 */
		class CCVKGPUStagingBufferPool final {
		public:
			static constexpr VkDeviceSize CHUNK_SIZE = 16 * 1024 * 1024; // 16M per block by default

			explicit CCVKGPUStagingBufferPool(CCVKGPUDevice* device)

				: _device(device) {
			}

			~CCVKGPUStagingBufferPool() {
				_pool.clear();
			}

			IntrusivePtr<CCVKGPUBufferView> alloc(uint32_t size) { return alloc(size, 1U); }

			IntrusivePtr<CCVKGPUBufferView> alloc(uint32_t size, uint32_t alignment) {
				CC_ASSERT_LE(size, CHUNK_SIZE);

				size_t bufferCount = _pool.size();
				Buffer* buffer = nullptr;
				VkDeviceSize offset = 0U;
				for (size_t idx = 0U; idx < bufferCount; idx++) {
					Buffer* cur = &_pool[idx];
					offset = roundUp(cur->curOffset, alignment);
					if (size + offset <= CHUNK_SIZE) {
						buffer = cur;
						break;
					}
				}
				if (!buffer) {
					_pool.resize(bufferCount + 1);
					buffer = &_pool.back();
					buffer->gpuBuffer = new CCVKGPUBuffer();
					buffer->gpuBuffer->size = CHUNK_SIZE;
					buffer->gpuBuffer->usage = BufferUsage::TRANSFER_SRC | BufferUsage::TRANSFER_DST;
					buffer->gpuBuffer->memUsage = MemoryUsage::HOST;
					buffer->gpuBuffer->init();
					offset = 0U;
				}
				auto* bufferView = new CCVKGPUBufferView;
				bufferView->gpuBuffer = buffer->gpuBuffer;
				bufferView->offset = offset;
				buffer->curOffset = offset + size;
				return bufferView;
			}

			void reset() {
				for (Buffer& buffer : _pool) {
					buffer.curOffset = 0U;
				}
			}

		private:
			struct Buffer {
				IntrusivePtr<CCVKGPUBuffer> gpuBuffer;
				VkDeviceSize curOffset = 0U;
			};

			CCVKGPUDevice* _device = nullptr;
			ccstd::vector<Buffer> _pool;
		};