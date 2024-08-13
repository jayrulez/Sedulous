using Bulkan;
using System;
using static Bulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL.VK;

	public class VKResourceLayout : ResourceLayout
	{
		private readonly VKGraphicsDevice _gd;
		private readonly VkDescriptorSetLayout _dsl;
		private readonly VkDescriptorType[] _descriptorTypes;
		private bool _disposed;
		private String _name;

		public VkDescriptorSetLayout DescriptorSetLayout => _dsl;
		public VkDescriptorType[] DescriptorTypes => _descriptorTypes;
		internal DescriptorResourceCounts DescriptorResourceCounts { get; }
		public new int32 DynamicBufferCount { get; }

		public override bool IsDisposed => _disposed;

		public this(VKGraphicsDevice gd, in ResourceLayoutDescription description)
			: base(description)
		{
			_gd = gd;
			VkDescriptorSetLayoutCreateInfo dslCI = VkDescriptorSetLayoutCreateInfo() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO };
			ResourceLayoutElementDescription[] elements = description.Elements;
			_descriptorTypes = new VkDescriptorType[elements.Count];
			VkDescriptorSetLayoutBinding* bindings = scope VkDescriptorSetLayoutBinding[elements.Count]*;

			uint32 uniformBufferCount = 0;
			uint32 uniformBufferDynamicCount = 0;
			uint32 sampledImageCount = 0;
			uint32 samplerCount = 0;
			uint32 storageBufferCount = 0;
			uint32 storageBufferDynamicCount = 0;
			uint32 storageImageCount = 0;

			for (uint32 i = 0; i < elements.Count; i++)
			{
				bindings[i].binding = i;
				bindings[i].descriptorCount = 1;
				VkDescriptorType descriptorType = VKFormats.VdToVkDescriptorType(elements[i].Kind, elements[i].Options);
				bindings[i].descriptorType = descriptorType;
				bindings[i].stageFlags = VKFormats.VdToVkShaderStages(elements[i].Stages);
				if ((elements[i].Options & ResourceLayoutElementOptions.DynamicBinding) != 0)
				{
					DynamicBufferCount += 1;
				}

				_descriptorTypes[i] = descriptorType;

				switch (descriptorType)
				{
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER:
					samplerCount += 1;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE:
					sampledImageCount += 1;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE:
					storageImageCount += 1;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER:
					uniformBufferCount += 1;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC:
					uniformBufferDynamicCount += 1;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER:
					storageBufferCount += 1;
					break;
				case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC:
					storageBufferDynamicCount += 1;
					break;
				default: break;
				}
			}

			DescriptorResourceCounts = DescriptorResourceCounts(
				uniformBufferCount,
				uniformBufferDynamicCount,
				sampledImageCount,
				samplerCount,
				storageBufferCount,
				storageBufferDynamicCount,
				storageImageCount);

			dslCI.bindingCount = (uint32)elements.Count;
			dslCI.pBindings = bindings;

			VkResult result = vkCreateDescriptorSetLayout(_gd.Device, &dslCI, null, &_dsl);
			CheckResult(result);
		}

		public override String Name
		{
			get => _name;
			set
			{
				_name = value;
				_gd.SetResourceName(this, value);
			}
		}

		public override void Dispose()
		{
			if (!_disposed)
			{
				_disposed = true;
				vkDestroyDescriptorSetLayout(_gd.Device, _dsl, null);
			}
		}
	}
}
