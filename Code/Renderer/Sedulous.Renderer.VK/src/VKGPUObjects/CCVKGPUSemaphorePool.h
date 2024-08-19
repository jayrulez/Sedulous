		namespace Sedulous.Renderer.VK.Internal;

		/**
		 * A simple pool for reusing semaphores.
		 */
		class CCVKGPUSemaphorePool final {
		public:
			explicit CCVKGPUSemaphorePool(CCVKGPUDevice* device)
				: _device(device) {
			}

			~CCVKGPUSemaphorePool() {
				for (VkSemaphore semaphore : _semaphores) {
					vkDestroySemaphore(_device->vkDevice, semaphore, nullptr);
				}
				_semaphores.clear();
				_count = 0;
			}

			VkSemaphore alloc() {
				if (_count < _semaphores.size()) {
					return _semaphores[_count++];
				}

				VkSemaphore semaphore = VK_NULL_HANDLE;
				VkSemaphoreCreateInfo createInfo{ VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO };
				VK_CHECK(vkCreateSemaphore(_device->vkDevice, &createInfo, nullptr, &semaphore));
				_semaphores.push_back(semaphore);
				_count++;

				return semaphore;
			}

			void reset() {
				_count = 0;
			}

			uint32_t size() const {
				return _count;
			}

		private:
			CCVKGPUDevice* _device;
			uint32_t _count = 0U;
			ccstd::vector<VkSemaphore> _semaphores;
		};