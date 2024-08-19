		namespace Sedulous.Renderer.VK.Internal;

		struct CCVKGPUInputAssembler : public CCVKGPUDeviceObject {
			void shutdown() {
				auto* hub = CCVKDevice::getInstance()->gpuIAHub();
				for (auto& vb : gpuVertexBuffers) {
					hub->disengage(this, vb);
				}
				if (gpuIndexBuffer) {
					hub->disengage(this, gpuIndexBuffer);
				}
				if (gpuIndirectBuffer) {
					hub->disengage(this, gpuIndirectBuffer);
				}
			}
			void update(const CCVKGPUBufferView* oldBuffer, const CCVKGPUBufferView* newBuffer) {
				for (uint32_t i = 0; i < gpuVertexBuffers.size(); ++i) {
					if (gpuVertexBuffers[i].get() == oldBuffer) {
						gpuVertexBuffers[i] = newBuffer;
						vertexBuffers[i] = newBuffer->gpuBuffer->vkBuffer;
					}
				}
				if (gpuIndexBuffer.get() == oldBuffer) {
					gpuIndexBuffer = newBuffer;
				}
				if (gpuIndirectBuffer.get() == oldBuffer) {
					gpuIndirectBuffer = newBuffer;
				}
			}

			AttributeList attributes;
			ccstd::vector<ConstPtr<CCVKGPUBufferView>> gpuVertexBuffers;
			ConstPtr<CCVKGPUBufferView> gpuIndexBuffer;
			ConstPtr<CCVKGPUBufferView> gpuIndirectBuffer;
			ccstd::vector<VkBuffer> vertexBuffers;
			ccstd::vector<VkDeviceSize> vertexBufferOffsets;
		};