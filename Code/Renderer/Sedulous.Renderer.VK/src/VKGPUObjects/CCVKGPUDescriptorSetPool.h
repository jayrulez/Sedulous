		/**
		 * Unlimited descriptor set pool, based on multiple fix-sized VkDescriptorPools.
		 */
		class CCVKGPUDescriptorSetPool final {
		public:
			~CCVKGPUDescriptorSetPool() {
				for (auto& pool : _pools) {
					vkDestroyDescriptorPool(_device->vkDevice, pool, nullptr);
				}
			}

			void link(CCVKGPUDevice* device, uint32_t maxSetsPerPool, const ccstd::vector<VkDescriptorSetLayoutBinding>& bindings, VkDescriptorSetLayout setLayout) {
				_device = device;
				_maxSetsPerPool = maxSetsPerPool;
				_setLayouts.insert(_setLayouts.cbegin(), _maxSetsPerPool, setLayout);

				ccstd::unordered_map<VkDescriptorType, uint32_t> typeMap;
				for (const auto& vkBinding : bindings) {
					typeMap[vkBinding.descriptorType] += maxSetsPerPool * vkBinding.descriptorCount;
				}

				// minimal reserve for empty set layouts
				if (bindings.empty()) {
					typeMap[VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER] = 1;
				}

				_poolSizes.clear();
				for (auto& it : typeMap) {
					_poolSizes.push_back({ it.first, it.second });
				}
			}

			VkDescriptorSet request() {
				if (_freeList.empty()) {
					requestPool();
				}
				return pop();
			}

			void requestPool() {
				VkDescriptorPoolCreateInfo createInfo{ VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO };
				createInfo.maxSets = _maxSetsPerPool;
				createInfo.poolSizeCount = utils::toUint(_poolSizes.size());
				createInfo.pPoolSizes = _poolSizes.data();

				VkDescriptorPool descriptorPool = VK_NULL_HANDLE;
				VK_CHECK(vkCreateDescriptorPool(_device->vkDevice, &createInfo, nullptr, &descriptorPool));
				_pools.push_back(descriptorPool);

				std::vector<VkDescriptorSet> sets(_maxSetsPerPool, VK_NULL_HANDLE);
				VkDescriptorSetAllocateInfo info{ VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO };
				info.pSetLayouts = _setLayouts.data();
				info.descriptorSetCount = _maxSetsPerPool;
				info.descriptorPool = descriptorPool;
				VK_CHECK(vkAllocateDescriptorSets(_device->vkDevice, &info, sets.data()));

				_freeList.insert(_freeList.end(), sets.begin(), sets.end());
			}

			void yield(VkDescriptorSet set) {
				_freeList.emplace_back(set);
			}

		private:
			VkDescriptorSet pop() {
				VkDescriptorSet output = VK_NULL_HANDLE;
				if (!_freeList.empty()) {
					output = _freeList.back();
					_freeList.pop_back();
					return output;
				}
				return VK_NULL_HANDLE;
			}

			CCVKGPUDevice* _device = nullptr;

			ccstd::vector<VkDescriptorPool> _pools;
			ccstd::vector<VkDescriptorSet> _freeList;

			ccstd::vector<VkDescriptorPoolSize> _poolSizes;
			ccstd::vector<VkDescriptorSetLayout> _setLayouts;
			uint32_t _maxSetsPerPool = 0U;
		};