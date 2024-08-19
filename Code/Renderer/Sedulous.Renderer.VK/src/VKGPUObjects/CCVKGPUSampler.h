		struct CCVKGPUSampler : public CCVKGPUDeviceObject {
			void shutdown() {
				CCVKDevice::getInstance()->gpuDescriptorHub()->disengage(this);
				CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
			}
			void init() {
				cmdFuncCCVKCreateSampler(CCVKDevice::getInstance(), this);
			}

			Filter minFilter = Filter::LINEAR;
			Filter magFilter = Filter::LINEAR;
			Filter mipFilter = Filter::NONE;
			Address addressU = Address::WRAP;
			Address addressV = Address::WRAP;
			Address addressW = Address::WRAP;
			uint32_t maxAnisotropy = 0U;
			ComparisonFunc cmpFunc = ComparisonFunc::NEVER;

			// descriptor infos
			VkSampler vkSampler;
		};