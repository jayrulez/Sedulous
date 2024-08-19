		namespace Sedulous.Renderer.VK.Internal;

		struct CCVKGPUBufferView : public CCVKGPUDeviceObject {
			void shutdown() {
				CCVKDevice::getInstance()->gpuDescriptorHub()->disengage(this);
				CCVKDevice::getInstance()->gpuIAHub()->disengage(this);
			}
			ConstPtr<CCVKGPUBuffer> gpuBuffer;
			uint32_t offset = 0U;
			uint32_t range = 0U;

			uint8_t* mappedData() const {
				return gpuBuffer->mappedData + offset;
			}

			VkDeviceSize getStartOffset(uint32_t curBackBufferIndex) const {
				return gpuBuffer->getStartOffset(curBackBufferIndex) + offset;
			}
		};