		struct CCVKGPUTexture : public CCVKGPUDeviceObject {
			void shutdown() {
				if (memoryAllocated) {
					CCVKDevice::getInstance()->getMemoryStatus().textureSize -= size;
					CC_PROFILE_MEMORY_DEC(Texture, size);
				}

				CCVKDevice::getInstance()->gpuBarrierManager()->cancel(this);
				if (!hasFlag(flags, TextureFlagBit::EXTERNAL_NORMAL)) {
					CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
				}
			}
			void init() {
				cmdFuncCCVKCreateTexture(CCVKDevice::getInstance(), this);

				if (memoryAllocated) {
					CCVKDevice::getInstance()->getMemoryStatus().textureSize += size;
					CC_PROFILE_MEMORY_INC(Texture, size);
				}
			}

			TextureType type = TextureType::TEX2D;
			Format format = Format::UNKNOWN;
			TextureUsage usage = TextureUsageBit::NONE;
			uint32_t width = 0U;
			uint32_t height = 0U;
			uint32_t depth = 1U;
			uint32_t size = 0U;
			uint32_t arrayLayers = 1U;
			uint32_t mipLevels = 1U;
			SampleCount samples = SampleCount::X1;
			TextureFlags flags = TextureFlagBit::NONE;
			VkImageAspectFlags aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;

			/*
			 * allocate and bind memory by Texture.
			 * If any of the following conditions are met, then the statement is false
			 * 1. Texture is a swapchain image.
			 * 2. Texture has flag LAZILY_ALLOCATED.
			 * 3. Memory bound manually bound.
			 * 4. Sparse Image.
			 */
			bool memoryAllocated = true;

			VkImage vkImage = VK_NULL_HANDLE;
			VmaAllocation vmaAllocation = VK_NULL_HANDLE;

			CCVKGPUSwapchain* swapchain = nullptr;
			ccstd::vector<VkImage> swapchainVkImages;
			ccstd::vector<VmaAllocation> swapchainVmaAllocations;

			ccstd::vector<ThsvsAccessType> currentAccessTypes;

			// for barrier manager
			ccstd::vector<ThsvsAccessType> renderAccessTypes; // gathered from descriptor sets
			ThsvsAccessType transferAccess = THSVS_ACCESS_NONE;

			VkImage externalVKImage = VK_NULL_HANDLE;
		};