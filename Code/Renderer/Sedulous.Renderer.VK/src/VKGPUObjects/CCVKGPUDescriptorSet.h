		namespace Sedulous.Renderer.VK.Internal;

		struct CCVKGPUDescriptorSet : public CCVKGPUDeviceObject {
			void shutdown() {
				CCVKDevice* device = CCVKDevice::getInstance();
				CCVKGPUDescriptorHub* descriptorHub = CCVKDevice::getInstance()->gpuDescriptorHub();
				uint32_t instanceCount = utils::toUint(instances.size());

				for (uint32_t t = 0U; t < instanceCount; ++t) {
					CCVKGPUDescriptorSet::Instance& instance = instances[t];

					for (uint32_t i = 0U; i < gpuDescriptors.size(); i++) {
						CCVKGPUDescriptor& binding = gpuDescriptors[i];

						CCVKDescriptorInfo& descriptorInfo = instance.descriptorInfos[i];
						if (binding.gpuBufferView) {
							descriptorHub->disengage(this, binding.gpuBufferView, &descriptorInfo.buffer);
						}
						if (binding.gpuTextureView) {
							descriptorHub->disengage(this, binding.gpuTextureView, &descriptorInfo.image);
						}
						if (binding.gpuSampler) {
							descriptorHub->disengage(binding.gpuSampler, &descriptorInfo.image);
						}
					}

					if (instance.vkDescriptorSet) {
						device->gpuRecycleBin()->collect(layoutID, instance.vkDescriptorSet);
					}
				}

				CCVKDevice::getInstance()->gpuDescriptorSetHub()->erase(this);
			}

			void update(const CCVKGPUBufferView* oldView, const CCVKGPUBufferView* newView) {
				CCVKGPUDescriptorHub* descriptorHub = CCVKDevice::getInstance()->gpuDescriptorHub();
				uint32_t instanceCount = utils::toUint(instances.size());

				for (size_t i = 0U; i < gpuDescriptors.size(); i++) {
					CCVKGPUDescriptor& binding = gpuDescriptors[i];
					if (hasFlag(DESCRIPTOR_BUFFER_TYPE, binding.type) && (binding.gpuBufferView == oldView)) {
						for (uint32_t t = 0U; t < instanceCount; ++t) {
							CCVKDescriptorInfo& descriptorInfo = instances[t].descriptorInfos[i];

							if (newView != nullptr) {
								descriptorHub->connect(this, newView, &descriptorInfo.buffer, t);
								descriptorHub->update(newView, &descriptorInfo.buffer);
							}
						}
						binding.gpuBufferView = newView;
					}
				}
				CCVKDevice::getInstance()->gpuDescriptorSetHub()->record(this);
			}

			void update(const CCVKGPUTextureView* oldView, const CCVKGPUTextureView* newView) {
				CCVKGPUDescriptorHub* descriptorHub = CCVKDevice::getInstance()->gpuDescriptorHub();
				uint32_t instanceCount = utils::toUint(instances.size());

				for (size_t i = 0U; i < gpuDescriptors.size(); i++) {
					CCVKGPUDescriptor& binding = gpuDescriptors[i];
					if (hasFlag(DESCRIPTOR_TEXTURE_TYPE, binding.type) && (binding.gpuTextureView == oldView)) {
						for (uint32_t t = 0U; t < instanceCount; ++t) {
							CCVKDescriptorInfo& descriptorInfo = instances[t].descriptorInfos[i];

							if (newView != nullptr) {
								descriptorHub->connect(this, newView, &descriptorInfo.image);
								descriptorHub->update(newView, &descriptorInfo.image);
							}
						}
						binding.gpuTextureView = newView;
					}
				}
				CCVKDevice::getInstance()->gpuDescriptorSetHub()->record(this);
			}

			ccstd::vector<CCVKGPUDescriptor> gpuDescriptors;

			// references
			ConstPtr<CCVKGPUDescriptorSetLayout> gpuLayout;

			struct Instance {
				VkDescriptorSet vkDescriptorSet = VK_NULL_HANDLE;
				ccstd::vector<CCVKDescriptorInfo> descriptorInfos;
				ccstd::vector<VkWriteDescriptorSet> descriptorUpdateEntries;
			};
			ccstd::vector<Instance> instances; // per swapchain image

			uint32_t layoutID = 0U;
		};