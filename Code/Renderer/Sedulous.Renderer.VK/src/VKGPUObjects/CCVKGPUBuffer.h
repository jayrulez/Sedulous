		struct CCVKGPUBuffer : public CCVKGPUDeviceObject {
			void shutdown() {
				CCVKDevice::getInstance()->gpuBarrierManager()->cancel(this);
				CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
				CCVKDevice::getInstance()->gpuBufferHub()->erase(this);

				CCVKDevice::getInstance()->getMemoryStatus().bufferSize -= size;
				CC_PROFILE_MEMORY_DEC(Buffer, size);
			}
			void init() {
				if (hasFlag(usage, BufferUsageBit::INDIRECT)) {
					const size_t drawInfoCount = size / sizeof(DrawInfo);
					indexedIndirectCmds.resize(drawInfoCount);
					indirectCmds.resize(drawInfoCount);
				}

				cmdFuncCCVKCreateBuffer(CCVKDevice::getInstance(), this);
				CCVKDevice::getInstance()->getMemoryStatus().bufferSize += size;
				CC_PROFILE_MEMORY_INC(Buffer, size);
			}

			BufferUsage usage = BufferUsage::NONE;
			MemoryUsage memUsage = MemoryUsage::NONE;
			uint32_t stride = 0U;
			uint32_t count = 0U;
			void* buffer = nullptr;

			bool isDrawIndirectByIndex = false;
			ccstd::vector<VkDrawIndirectCommand> indirectCmds;
			ccstd::vector<VkDrawIndexedIndirectCommand> indexedIndirectCmds;

			uint8_t* mappedData = nullptr;
			VmaAllocation vmaAllocation = VK_NULL_HANDLE;

			// descriptor infos
			VkBuffer vkBuffer = VK_NULL_HANDLE;
			VkDeviceSize size = 0U;

			VkDeviceSize instanceSize = 0U; // per-back-buffer instance
			ccstd::vector<ThsvsAccessType> currentAccessTypes;

			// for barrier manager
			ccstd::vector<ThsvsAccessType> renderAccessTypes; // gathered from descriptor sets
			ThsvsAccessType transferAccess = THSVS_ACCESS_NONE;

			VkDeviceSize getStartOffset(uint32_t curBackBufferIndex) const {
				return instanceSize * curBackBufferIndex;
			}
		};