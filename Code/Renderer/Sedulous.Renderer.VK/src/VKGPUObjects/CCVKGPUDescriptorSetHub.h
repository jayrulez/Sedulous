		namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Manages descriptor set update events, across all back buffer instances.
		 */
		class CCVKGPUDescriptorSetHub final {
		public:
			explicit CCVKGPUDescriptorSetHub(CCVKGPUDevice* device)
				: _device(device) {
				_setsToBeUpdated.resize(device->backBufferCount);
				if (device->minorVersion > 0) {
					_updateFn = vkUpdateDescriptorSetWithTemplate;
				}
				else {
					_updateFn = vkUpdateDescriptorSetWithTemplateKHR;
				}
			}

			void record(const CCVKGPUDescriptorSet* gpuDescriptorSet) {
				update(gpuDescriptorSet);
				for (uint32_t i = 0U; i < _device->backBufferCount; ++i) {
					if (i == _device->curBackBufferIndex) {
						_setsToBeUpdated[i].erase(gpuDescriptorSet);
					}
					else {
						_setsToBeUpdated[i].insert(gpuDescriptorSet);
					}
				}
			}

			void erase(CCVKGPUDescriptorSet* gpuDescriptorSet) {
				for (uint32_t i = 0U; i < _device->backBufferCount; ++i) {
					if (_setsToBeUpdated[i].count(gpuDescriptorSet)) {
						_setsToBeUpdated[i].erase(gpuDescriptorSet);
					}
				}
			}

			void flush() {
				DescriptorSetList& sets = _setsToBeUpdated[_device->curBackBufferIndex];
				for (const auto* set : sets) {
					update(set);
				}
				sets.clear();
			}

			void updateBackBufferCount(uint32_t backBufferCount) {
				_setsToBeUpdated.resize(backBufferCount);
			}

		private:
			void update(const CCVKGPUDescriptorSet* gpuDescriptorSet) {
				const CCVKGPUDescriptorSet::Instance& instance = gpuDescriptorSet->instances[_device->curBackBufferIndex];
				if (gpuDescriptorSet->gpuLayout->vkDescriptorUpdateTemplate) {
					_updateFn(_device->vkDevice, instance.vkDescriptorSet,
						gpuDescriptorSet->gpuLayout->vkDescriptorUpdateTemplate, instance.descriptorInfos.data());
				}
				else {
					const ccstd::vector<VkWriteDescriptorSet>& entries = instance.descriptorUpdateEntries;
					vkUpdateDescriptorSets(_device->vkDevice, utils::toUint(entries.size()), entries.data(), 0, nullptr);
				}
			}

			using DescriptorSetList = ccstd::unordered_set<const CCVKGPUDescriptorSet*>;

			CCVKGPUDevice* _device = nullptr;
			ccstd::vector<DescriptorSetList> _setsToBeUpdated;
			PFN_vkUpdateDescriptorSetWithTemplate _updateFn = nullptr;
		};