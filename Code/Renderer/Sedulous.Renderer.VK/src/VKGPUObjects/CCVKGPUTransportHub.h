		namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Transport hub for data traveling between host and devices.
		 * Record all transfer commands until batched submission.
		 */
		 // #define ASYNC_BUFFER_UPDATE
		class CCVKGPUTransportHub final {
		public:
			CCVKGPUTransportHub(CCVKGPUDevice* device, CCVKGPUQueue* queue)
				: _device(device),
				_queue(queue) {
				_earlyCmdBuff.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
				_earlyCmdBuff.queueFamilyIndex = _queue->queueFamilyIndex;

				_lateCmdBuff.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
				_lateCmdBuff.queueFamilyIndex = _queue->queueFamilyIndex;

				VkFenceCreateInfo createInfo{ VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
				VK_CHECK(vkCreateFence(_device->vkDevice, &createInfo, nullptr, &_fence));
			}

			~CCVKGPUTransportHub() {
				if (_fence) {
					vkDestroyFence(_device->vkDevice, _fence, nullptr);
					_fence = VK_NULL_HANDLE;
				}
			}

			bool empty(bool late) const {
				const CCVKGPUCommandBuffer* cmdBuff = late ? &_lateCmdBuff : &_earlyCmdBuff;

				return !cmdBuff->vkCommandBuffer;
			}

			template <typename TFunc>
			void checkIn(const TFunc& record, bool immediateSubmission = false, bool late = false) {
				CCVKGPUCommandBufferPool* commandBufferPool = _device->getCommandBufferPool();
				CCVKGPUCommandBuffer* cmdBuff = late ? &_lateCmdBuff : &_earlyCmdBuff;

				if (!cmdBuff->vkCommandBuffer) {
					commandBufferPool->request(cmdBuff);
					VkCommandBufferBeginInfo beginInfo{ VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
					beginInfo.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
					VK_CHECK(vkBeginCommandBuffer(cmdBuff->vkCommandBuffer, &beginInfo));
				}

				record(cmdBuff);

				if (immediateSubmission) {
					VK_CHECK(vkEndCommandBuffer(cmdBuff->vkCommandBuffer));
					VkSubmitInfo submitInfo{ VK_STRUCTURE_TYPE_SUBMIT_INFO };
					submitInfo.commandBufferCount = 1;
					submitInfo.pCommandBuffers = &cmdBuff->vkCommandBuffer;
					VK_CHECK(vkQueueSubmit(_queue->vkQueue, 1, &submitInfo, _fence));
					VK_CHECK(vkWaitForFences(_device->vkDevice, 1, &_fence, VK_TRUE, DEFAULT_TIMEOUT));
					vkResetFences(_device->vkDevice, 1, &_fence);
					commandBufferPool->yield(cmdBuff);
					cmdBuff->vkCommandBuffer = VK_NULL_HANDLE;
				}
			}

			VkCommandBuffer packageForFlight(bool late) {
				CCVKGPUCommandBuffer* cmdBuff = late ? &_lateCmdBuff : &_earlyCmdBuff;

				VkCommandBuffer vkCommandBuffer = cmdBuff->vkCommandBuffer;
				if (vkCommandBuffer) {
					VK_CHECK(vkEndCommandBuffer(vkCommandBuffer));
					_device->getCommandBufferPool()->yield(cmdBuff);
				}
				return vkCommandBuffer;
			}

		private:
			CCVKGPUDevice* _device = nullptr;

			CCVKGPUQueue* _queue = nullptr;
			CCVKGPUCommandBuffer _earlyCmdBuff;
			CCVKGPUCommandBuffer _lateCmdBuff;
			VkFence _fence = VK_NULL_HANDLE;
		};