		/**
		 * Descriptor data maintenance hub, events like buffer/texture resizing,
		 * descriptor set binding change, etc. should all request an update operation here.
		 */
		class CCVKGPUDescriptorHub final {
		public:
			explicit CCVKGPUDescriptorHub(CCVKGPUDevice* /*device*/) {
			}

			void connect(CCVKGPUDescriptorSet* set, const CCVKGPUBufferView* buffer, VkDescriptorBufferInfo* descriptor, uint32_t instanceIdx) {
				_gpuBufferViewSet[buffer].sets.insert(set);
				_gpuBufferViewSet[buffer].descriptors.push(descriptor);
				_bufferInstanceIndices[descriptor] = instanceIdx;
			}
			void connect(CCVKGPUDescriptorSet* set, const CCVKGPUTextureView* texture, VkDescriptorImageInfo* descriptor) {
				_gpuTextureViewSet[texture].sets.insert(set);
				_gpuTextureViewSet[texture].descriptors.push(descriptor);
			}
			void connect(CCVKGPUSampler* sampler, VkDescriptorImageInfo* descriptor) {
				_samplers[sampler].push(descriptor);
			}

			void update(const CCVKGPUBufferView* buffer, VkDescriptorBufferInfo* descriptor) {
				auto it = _gpuBufferViewSet.find(buffer);
				if (it == _gpuBufferViewSet.end()) return;
				auto& descriptors = it->second.descriptors;
				for (uint32_t i = 0U; i < descriptors.size(); i++) {
					if (descriptors[i] == descriptor) {
						doUpdate(buffer, descriptor);
						break;
					}
				}
			}

			void update(const CCVKGPUTextureView* texture, VkDescriptorImageInfo* descriptor) {
				auto it = _gpuTextureViewSet.find(texture);
				if (it == _gpuTextureViewSet.end()) return;
				auto& descriptors = it->second.descriptors;
				for (uint32_t i = 0U; i < descriptors.size(); i++) {
					if (descriptors[i] == descriptor) {
						doUpdate(texture, descriptor);
						break;
					}
				}
			}

			void update(const CCVKGPUTextureView* texture, VkDescriptorImageInfo* descriptor, AccessFlags flags) {
				auto it = _gpuTextureViewSet.find(texture);
				if (it == _gpuTextureViewSet.end()) return;
				auto& descriptors = it->second.descriptors;
				for (uint32_t i = 0U; i < descriptors.size(); i++) {
					if (descriptors[i] == descriptor) {
						doUpdate(texture, descriptor, flags);
						break;
					}
				}
			}

			void update(const CCVKGPUSampler* sampler, VkDescriptorImageInfo* descriptor) {
				auto it = _samplers.find(sampler);
				if (it == _samplers.end()) return;
				auto& descriptors = it->second;
				for (uint32_t i = 0U; i < descriptors.size(); ++i) {
					if (descriptors[i] == descriptor) {
						doUpdate(sampler, descriptor);
						break;
					}
				}
			}
			// for resize events
			void update(const CCVKGPUBufferView* oldView, const CCVKGPUBufferView* newView) {
				auto iter = _gpuBufferViewSet.find(oldView);
				if (iter != _gpuBufferViewSet.end()) {
					auto& sets = iter->second.sets;
					for (auto* set : sets) {
						set->update(oldView, newView);
					}
					_gpuBufferViewSet.erase(iter);
				}
			}

			void update(const CCVKGPUTextureView* oldView, const CCVKGPUTextureView* newView) {
				auto iter = _gpuTextureViewSet.find(oldView);
				if (iter != _gpuTextureViewSet.end()) {
					auto& sets = iter->second.sets;
					for (auto* set : sets) {
						set->update(oldView, newView);
					}
					_gpuTextureViewSet.erase(iter);
				}
			}

			void disengage(const CCVKGPUBufferView* buffer) {
				auto it = _gpuBufferViewSet.find(buffer);
				if (it == _gpuBufferViewSet.end()) return;
				for (uint32_t i = 0; i < it->second.descriptors.size(); ++i) {
					_bufferInstanceIndices.erase(it->second.descriptors[i]);
				}
				_gpuBufferViewSet.erase(it);
			}
			void disengage(CCVKGPUDescriptorSet* set, const CCVKGPUBufferView* buffer, VkDescriptorBufferInfo* descriptor) {
				auto it = _gpuBufferViewSet.find(buffer);
				if (it == _gpuBufferViewSet.end()) return;
				it->second.sets.erase(set);
				auto& descriptors = it->second.descriptors;
				descriptors.fastRemove(descriptors.indexOf(descriptor));
				_bufferInstanceIndices.erase(descriptor);
			}
			void disengage(const CCVKGPUTextureView* texture) {
				auto it = _gpuTextureViewSet.find(texture);
				if (it == _gpuTextureViewSet.end()) return;
				_gpuTextureViewSet.erase(it);
			}
			void disengage(CCVKGPUDescriptorSet* set, const CCVKGPUTextureView* texture, VkDescriptorImageInfo* descriptor) {
				auto it = _gpuTextureViewSet.find(texture);
				if (it == _gpuTextureViewSet.end()) return;
				it->second.sets.erase(set);
				auto& descriptors = it->second.descriptors;
				descriptors.fastRemove(descriptors.indexOf(descriptor));
			}
			void disengage(const CCVKGPUSampler* sampler) {
				auto it = _samplers.find(sampler);
				if (it == _samplers.end()) return;
				_samplers.erase(it);
			}
			void disengage(const CCVKGPUSampler* sampler, VkDescriptorImageInfo* descriptor) {
				auto it = _samplers.find(sampler);
				if (it == _samplers.end()) return;
				auto& descriptors = it->second;
				descriptors.fastRemove(descriptors.indexOf(descriptor));
			}

		private:
			void doUpdate(const CCVKGPUBufferView* buffer, VkDescriptorBufferInfo* descriptor) {
				descriptor->buffer = buffer->gpuBuffer->vkBuffer;
				descriptor->offset = buffer->getStartOffset(_bufferInstanceIndices[descriptor]);
				descriptor->range = buffer->range;
			}

			static void doUpdate(const CCVKGPUTextureView* texture, VkDescriptorImageInfo* descriptor) {
				descriptor->imageView = texture->vkImageView;
			}

			static void doUpdate(const CCVKGPUTextureView* texture, VkDescriptorImageInfo* descriptor, AccessFlags flags) {
				descriptor->imageView = texture->vkImageView;
				if (hasFlag(texture->gpuTexture->flags, TextureFlagBit::GENERAL_LAYOUT)) {
					descriptor->imageLayout = VK_IMAGE_LAYOUT_GENERAL;
				}
				else {
					bool inoutAttachment = hasAllFlags(flags, AccessFlagBit::FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT | AccessFlagBit::COLOR_ATTACHMENT_WRITE) ||
						hasAllFlags(flags, AccessFlagBit::FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT | AccessFlagBit::DEPTH_STENCIL_ATTACHMENT_WRITE);
					bool storageWrite = hasAnyFlags(flags, AccessFlagBit::VERTEX_SHADER_WRITE | AccessFlagBit::FRAGMENT_SHADER_WRITE | AccessFlagBit::COMPUTE_SHADER_WRITE);

					if (inoutAttachment || storageWrite) {
						descriptor->imageLayout = VK_IMAGE_LAYOUT_GENERAL;
					}
					else if (hasFlag(texture->gpuTexture->usage, TextureUsage::DEPTH_STENCIL_ATTACHMENT)) {
						descriptor->imageLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL;
					}
					else {
						descriptor->imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
					}
				}
			}

			static void doUpdate(const CCVKGPUSampler* sampler, VkDescriptorImageInfo* descriptor) {
				descriptor->sampler = sampler->vkSampler;
			}

			template <typename T>
			struct DescriptorInfo {
				ccstd::unordered_set<CCVKGPUDescriptorSet*> sets;
				CachedArray<T*> descriptors;
			};

			ccstd::unordered_map<const VkDescriptorBufferInfo*, uint32_t> _bufferInstanceIndices;
			ccstd::unordered_map<const CCVKGPUBufferView*, DescriptorInfo<VkDescriptorBufferInfo>> _gpuBufferViewSet;
			ccstd::unordered_map<const CCVKGPUTextureView*, DescriptorInfo<VkDescriptorImageInfo>> _gpuTextureViewSet;
			ccstd::unordered_map<const CCVKGPUSampler*, CachedArray<VkDescriptorImageInfo*>> _samplers;
		};