		class CCVKGPUInputAssemblerHub {
		public:
			explicit CCVKGPUInputAssemblerHub(CCVKGPUDevice* device)
				: _gpuDevice(device) {
			}

			~CCVKGPUInputAssemblerHub() = default;

			void connect(CCVKGPUInputAssembler* ia, const CCVKGPUBufferView* buffer) {
				_ias[buffer].insert(ia);
			}

			void update(CCVKGPUBufferView* oldBuffer, CCVKGPUBufferView* newBuffer) {
				auto iter = _ias.find(oldBuffer);
				if (iter != _ias.end()) {
					for (const auto& ia : iter->second) {
						ia->update(oldBuffer, newBuffer);
						_ias[newBuffer].insert(ia);
					}
					_ias.erase(iter);
				}
			}

			void disengage(const CCVKGPUBufferView* buffer) {
				auto iter = _ias.find(buffer);
				if (iter != _ias.end()) {
					_ias.erase(iter);
				}
			}

			void disengage(CCVKGPUInputAssembler* set, const CCVKGPUBufferView* buffer) {
				auto iter = _ias.find(buffer);
				if (iter != _ias.end()) {
					iter->second.erase(set);
				}
			}

		private:
			CCVKGPUDevice* _gpuDevice = nullptr;
			ccstd::unordered_map<const CCVKGPUBufferView*, ccstd::unordered_set<CCVKGPUInputAssembler*>> _ias;
		};