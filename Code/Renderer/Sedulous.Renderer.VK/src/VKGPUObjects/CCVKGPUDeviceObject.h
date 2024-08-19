		struct CCVKDeviceObjectDeleter {
			template <typename T>
			void operator()(T* ptr) const;
		};

		class CCVKGPUDeviceObject : public GFXDeviceObject<CCVKDeviceObjectDeleter> {
		public:
			CCVKGPUDeviceObject() = default;
			~CCVKGPUDeviceObject() = default;

			virtual void shutdown() {};
		};

		template <typename T>
		void CCVKDeviceObjectDeleter::operator()(T* ptr) const {
			auto* object = const_cast<CCVKGPUDeviceObject*>(static_cast<const CCVKGPUDeviceObject*>(ptr));
			object->shutdown();
			delete object;
		}