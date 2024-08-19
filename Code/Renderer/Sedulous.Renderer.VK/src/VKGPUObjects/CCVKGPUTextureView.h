		namespace Sedulous.Renderer.VK.Internal;

		struct CCVKGPUTextureView : public CCVKGPUDeviceObject {
			void shutdown() {
				CCVKDevice::getInstance()->gpuDescriptorHub()->disengage(this);
				CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
			}
			void init() {
				cmdFuncCCVKCreateTextureView(CCVKDevice::getInstance(), this);
			}

			IntrusivePtr<CCVKGPUTexture> gpuTexture;
			TextureType type = TextureType::TEX2D;
			Format format = Format::UNKNOWN;
			uint32_t baseLevel = 0U;
			uint32_t levelCount = 1U;
			uint32_t baseLayer = 0U;
			uint32_t layerCount = 1U;
			uint32_t basePlane = 0U;
			uint32_t planeCount = 1U;

			ccstd::vector<VkImageView> swapchainVkImageViews;

			// descriptor infos
			VkImageView vkImageView = VK_NULL_HANDLE;
		};