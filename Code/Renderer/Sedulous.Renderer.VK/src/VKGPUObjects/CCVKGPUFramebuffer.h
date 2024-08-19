		struct CCVKGPUFramebuffer : public CCVKGPUDeviceObject {
			void shutdown() {
				CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
			}

			ConstPtr<CCVKGPURenderPass> gpuRenderPass;
			ccstd::vector<ConstPtr<CCVKGPUTextureView>> gpuColorViews;
			ConstPtr<CCVKGPUTextureView> gpuDepthStencilView;
			ConstPtr<CCVKGPUTextureView> gpuDepthStencilResolveView;
			VkFramebuffer vkFramebuffer = VK_NULL_HANDLE;
			std::vector<VkFramebuffer> vkFrameBuffers;
			CCVKGPUSwapchain* swapchain = nullptr;
			bool isOffscreen = true;
			uint32_t width = 0U;
			uint32_t height = 0U;
		};