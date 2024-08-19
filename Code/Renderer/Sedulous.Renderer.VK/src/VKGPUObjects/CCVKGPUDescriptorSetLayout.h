		namespace Sedulous.Renderer.VK.Internal;

		struct CCVKGPUDescriptorSetLayout : public CCVKGPUDeviceObject {
			void shutdown() {
				if (defaultDescriptorSet != VK_NULL_HANDLE) {
					CCVKDevice::getInstance()->gpuRecycleBin()->collect(id, defaultDescriptorSet);
				}

				cmdFuncCCVKDestroyDescriptorSetLayout(CCVKDevice::getInstance()->gpuDevice(), this);
			}

			DescriptorSetLayoutBindingList bindings;
			ccstd::vector<uint32_t> dynamicBindings;

			ccstd::vector<VkDescriptorSetLayoutBinding> vkBindings;
			VkDescriptorSetLayout vkDescriptorSetLayout = VK_NULL_HANDLE;
			VkDescriptorUpdateTemplate vkDescriptorUpdateTemplate = VK_NULL_HANDLE;
			VkDescriptorSet defaultDescriptorSet = VK_NULL_HANDLE;

			ccstd::vector<uint32_t> bindingIndices;
			ccstd::vector<uint32_t> descriptorIndices;
			uint32_t descriptorCount = 0U;

			uint32_t id = 0U;
			uint32_t maxSetsPerPool = 10U;
		};