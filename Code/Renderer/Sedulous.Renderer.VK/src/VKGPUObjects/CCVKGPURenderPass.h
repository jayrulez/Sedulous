		namespace Sedulous.Renderer.VK.Internal;

		class CCVKGPURenderPass final : public CCVKGPUDeviceObject {
		public:
			void shutdown() {
				CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
			}

			ColorAttachmentList colorAttachments;
			DepthStencilAttachment depthStencilAttachment;
			DepthStencilAttachment depthStencilResolveAttachment;
			SubpassInfoList subpasses;
			SubpassDependencyList dependencies;

			VkRenderPass vkRenderPass;

			// helper storage
			ccstd::vector<VkClearValue> clearValues;
			ccstd::vector<VkSampleCountFlagBits> sampleCounts; // per subpass
			ccstd::vector<bool> hasSelfDependency; // per subpass

			const CCVKGPUGeneralBarrier* getBarrier(size_t index, CCVKGPUDevice* gpuDevice) {
				if (index < colorAttachments.size()) {
					return colorAttachments[index].barrier ? static_cast<CCVKGeneralBarrier*>(colorAttachments[index].barrier)->gpuBarrier() : &gpuDevice->defaultColorBarrier;
				}
				return depthStencilAttachment.barrier ? static_cast<CCVKGeneralBarrier*>(depthStencilAttachment.barrier)->gpuBarrier() : &gpuDevice->defaultDepthStencilBarrier;
			}
			bool hasShadingAttachment(uint32_t subPassId) {
				CC_ASSERT(subPassId < subpasses.size());
				return subpasses[subPassId].shadingRate != INVALID_BINDING;
			}
		};