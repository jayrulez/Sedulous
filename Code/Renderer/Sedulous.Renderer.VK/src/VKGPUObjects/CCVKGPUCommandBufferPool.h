		namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Command buffer pool based on VkCommandPools, always try to reuse previous allocations first.
		 */
		class CCVKGPUCommandBufferPool final {
		public:
			explicit CCVKGPUCommandBufferPool(CCVKGPUDevice* device)
				: _device(device) {
			}

			~CCVKGPUCommandBufferPool() {
				for (auto& it : _pools) {
					CommandBufferPool& pool = it.second;
					if (pool.vkCommandPool != VK_NULL_HANDLE) {
						vkDestroyCommandPool(_device->vkDevice, pool.vkCommandPool, nullptr);
						pool.vkCommandPool = VK_NULL_HANDLE;
					}
					for (auto& item : pool.usedCommandBuffers)item.clear();
					for (auto& item : pool.commandBuffers)item.clear();
				}
				_pools.clear();
			}

			uint32_t getHash(uint32_t queueFamilyIndex) {
				return (queueFamilyIndex << 10) | _device->curBackBufferIndex;
			}
			static uint32_t getBackBufferIndex(uint32_t hash) {
				return hash & ((1 << 10) - 1);
			}

			void request(CCVKGPUCommandBuffer* gpuCommandBuffer) {
				uint32_t hash = getHash(gpuCommandBuffer->queueFamilyIndex);

				if (_device->curBackBufferIndex != _lastBackBufferIndex) {
					reset();
					_lastBackBufferIndex = _device->curBackBufferIndex;
				}

				if (!_pools.count(hash)) {
					VkCommandPoolCreateInfo createInfo{ VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO };
					createInfo.queueFamilyIndex = gpuCommandBuffer->queueFamilyIndex;
					createInfo.flags = VK_COMMAND_POOL_CREATE_TRANSIENT_BIT;
					VK_CHECK(vkCreateCommandPool(_device->vkDevice, &createInfo, nullptr, &_pools[hash].vkCommandPool));
				}
				CommandBufferPool& pool = _pools[hash];

				CachedArray<VkCommandBuffer>& availableList = pool.commandBuffers[gpuCommandBuffer->level];
				if (availableList.size()) {
					gpuCommandBuffer->vkCommandBuffer = availableList.pop();
				}
				else {
					VkCommandBufferAllocateInfo allocateInfo{ VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO };
					allocateInfo.commandPool = pool.vkCommandPool;
					allocateInfo.commandBufferCount = 1;
					allocateInfo.level = gpuCommandBuffer->level;
					VK_CHECK(vkAllocateCommandBuffers(_device->vkDevice, &allocateInfo, &gpuCommandBuffer->vkCommandBuffer));
				}
			}

			void yield(CCVKGPUCommandBuffer* gpuCommandBuffer) {
				if (gpuCommandBuffer->vkCommandBuffer) {
					uint32_t hash = getHash(gpuCommandBuffer->queueFamilyIndex);
					CC_ASSERT(_pools.count(hash)); // Wrong command pool to yield?

					CommandBufferPool& pool = _pools[hash];
					pool.usedCommandBuffers[gpuCommandBuffer->level].push(gpuCommandBuffer->vkCommandBuffer);
					gpuCommandBuffer->vkCommandBuffer = VK_NULL_HANDLE;
				}
			}

			void reset() {
				for (auto& it : _pools) {
					if (getBackBufferIndex(it.first) != _device->curBackBufferIndex) {
						continue;
					}
					CommandBufferPool& pool = it.second;

					bool needsReset = false;
					for (uint32_t i = 0U; i < 2U; ++i) {
						CachedArray<VkCommandBuffer>& usedList = pool.usedCommandBuffers[i];
						if (usedList.size()) {
							pool.commandBuffers[i].concat(usedList);
							usedList.clear();
							needsReset = true;
						}
					}
					if (needsReset) {
						VK_CHECK(vkResetCommandPool(_device->vkDevice, pool.vkCommandPool, 0));
					}
				}
			}

		private:
			struct CommandBufferPool {
				VkCommandPool vkCommandPool = VK_NULL_HANDLE;
				CachedArray<VkCommandBuffer> commandBuffers[2];
				CachedArray<VkCommandBuffer> usedCommandBuffers[2];
			};

			CCVKGPUDevice* _device = nullptr;
			uint32_t _lastBackBufferIndex = 0U;

			ccstd::unordered_map<uint32_t, CommandBufferPool> _pools;
		};