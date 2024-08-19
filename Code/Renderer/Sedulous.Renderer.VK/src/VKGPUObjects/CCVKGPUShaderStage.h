		struct CCVKGPUShaderStage {
			CCVKGPUShaderStage(ShaderStageFlagBit t, ccstd::string s)
				: type(t),
				source(std::move(s)) {
			}
			ShaderStageFlagBit type = ShaderStageFlagBit::NONE;
			ccstd::string source;
			VkShaderModule vkShader = VK_NULL_HANDLE;
		};