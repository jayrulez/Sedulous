		struct CCVKGPUPipelineLayout : public CCVKGPUDeviceObject {
			void shutdown() {
				cmdFuncCCVKDestroyPipelineLayout(CCVKDevice::getInstance()->gpuDevice(), this);
			}

			ccstd::vector<ConstPtr<CCVKGPUDescriptorSetLayout>> setLayouts;

			VkPipelineLayout vkPipelineLayout = VK_NULL_HANDLE;

			// helper storage
			ccstd::vector<uint32_t> dynamicOffsetOffsets;
			uint32_t dynamicOffsetCount;
		};