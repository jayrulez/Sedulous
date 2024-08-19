		namespace Sedulous.Renderer.VK.Internal;

		union CCVKDescriptorInfo {
			VkDescriptorImageInfo image;
			VkDescriptorBufferInfo buffer;
			VkBufferView texelBufferView;
		};