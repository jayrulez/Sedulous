		struct CCVKGPUQueryPool : public CCVKGPUDeviceObject {
			void shutdown() {
				CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
			}

			QueryType type{ QueryType::OCCLUSION };
			uint32_t maxQueryObjects{ 0 };
			bool forceWait{ true };
			VkQueryPool vkPool{ VK_NULL_HANDLE };
		};