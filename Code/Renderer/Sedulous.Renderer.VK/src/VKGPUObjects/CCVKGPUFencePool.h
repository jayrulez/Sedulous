		/**
		 * A simple pool for reusing fences.
		 */
		class CCVKGPUFencePool final {
		public:
			explicit CCVKGPUFencePool(CCVKGPUDevice* device)
				: _device(device) {
			}

			~CCVKGPUFencePool() {
				for (VkFence fence : _fences) {
					vkDestroyFence(_device->vkDevice, fence, nullptr);
				}
				_fences.clear();
				_count = 0;
			}

			VkFence alloc() {
				if (_count < _fences.size()) {
					return _fences[_count++];
				}

				VkFence fence = VK_NULL_HANDLE;
				VkFenceCreateInfo createInfo{ VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
				VK_CHECK(vkCreateFence(_device->vkDevice, &createInfo, nullptr, &fence));
				_fences.push_back(fence);
				_count++;

				return fence;
			}

			void reset() {
				if (_count) {
					VK_CHECK(vkResetFences(_device->vkDevice, _count, _fences.data()));
					_count = 0;
				}
			}

			VkFence* data() {
				return _fences.data();
			}

			uint32_t size() const {
				return _count;
			}

		private:
			CCVKGPUDevice* _device = nullptr;
			uint32_t _count = 0U;
			ccstd::vector<VkFence> _fences;
		};