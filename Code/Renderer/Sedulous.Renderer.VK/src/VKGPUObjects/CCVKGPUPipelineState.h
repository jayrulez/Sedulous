		namespace Sedulous.Renderer.VK.Internal;

		struct CCVKGPUPipelineState : public CCVKGPUDeviceObject {
			void shutdown() {
				CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
			}

			PipelineBindPoint bindPoint = PipelineBindPoint::GRAPHICS;
			PrimitiveMode primitive = PrimitiveMode::TRIANGLE_LIST;
			ConstPtr<CCVKGPUShader> gpuShader;
			ConstPtr<CCVKGPUPipelineLayout> gpuPipelineLayout;
			InputState inputState;
			RasterizerState rs;
			DepthStencilState dss;
			BlendState bs;
			DynamicStateList dynamicStates;
			ConstPtr<CCVKGPURenderPass> gpuRenderPass;
			uint32_t subpass = 0U;
			VkPipeline vkPipeline = VK_NULL_HANDLE;
		};