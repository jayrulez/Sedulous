		struct CCVKGPUShader : public CCVKGPUDeviceObject {
			void shutdown() {
				cmdFuncCCVKDestroyShader(CCVKDevice::getInstance()->gpuDevice(), this);
			}

			ccstd::string name;
			AttributeList attributes;
			ccstd::vector<CCVKGPUShaderStage> gpuStages;
			bool initialized = false;
		};