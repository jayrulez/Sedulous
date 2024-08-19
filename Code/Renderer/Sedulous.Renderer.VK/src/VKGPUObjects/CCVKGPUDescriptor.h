		namespace Sedulous.Renderer.VK.Internal;

		struct CCVKGPUDescriptor {
			DescriptorType type = DescriptorType::UNKNOWN;
			ccstd::vector<ThsvsAccessType> accessTypes;
			ConstPtr<CCVKGPUBufferView> gpuBufferView;
			ConstPtr<CCVKGPUTextureView> gpuTextureView;
			ConstPtr<CCVKGPUSampler> gpuSampler;
		};