using System.Collections;
using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUDescriptorSet : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		CCVKDevice device = CCVKDevice.getInstance();
		CCVKGPUDescriptorHub descriptorHub = CCVKDevice.getInstance().gpuDescriptorHub();
		uint32 instanceCount = uint32(instances.Count);

		for (uint32 t = 0U; t < instanceCount; ++t)
		{
			ref CCVKGPUDescriptorSet.Instance instance = ref instances[t];

			for (uint32 i = 0U; i < gpuDescriptors.Count; i++)
			{
				ref CCVKGPUDescriptor binding = ref gpuDescriptors[i];

				ref CCVKDescriptorInfo descriptorInfo = ref instance.descriptorInfos[i];
				if (binding.gpuBufferView != null)
				{
					descriptorHub.disengage(this, binding.gpuBufferView, &descriptorInfo.buffer);
				}
				if (binding.gpuTextureView != null)
				{
					descriptorHub.disengage(this, binding.gpuTextureView, &descriptorInfo.image);
				}
				if (binding.gpuSampler != null)
				{
					descriptorHub.disengage(binding.gpuSampler, &descriptorInfo.image);
				}
			}

			if (instance.vkDescriptorSet != .Null)
			{
				device.gpuRecycleBin().collect(layoutID, instance.vkDescriptorSet);
			}
		}

		CCVKDevice.getInstance().gpuDescriptorSetHub().erase(this);
	}

	public void update(CCVKGPUBufferView oldView, CCVKGPUBufferView newView)
	{
		CCVKGPUDescriptorHub descriptorHub = CCVKDevice.getInstance().gpuDescriptorHub();
		uint32 instanceCount = uint32(instances.Count);

		for (int i = 0U; i < gpuDescriptors.Count; i++)
		{
			ref CCVKGPUDescriptor binding = ref gpuDescriptors[i];
			if (hasFlag(DESCRIPTOR_BUFFER_TYPE, binding.type) && (binding.gpuBufferView == oldView))
			{
				for (uint32 t = 0U; t < instanceCount; ++t)
				{
					ref CCVKDescriptorInfo descriptorInfo = ref instances[t].descriptorInfos[i];

					if (newView != null)
					{
						descriptorHub.connect(this, newView, &descriptorInfo.buffer, t);
						descriptorHub.update(newView, &descriptorInfo.buffer);
					}
				}
				binding.gpuBufferView = newView;
			}
		}
		CCVKDevice.getInstance().gpuDescriptorSetHub().record(this);
	}

	public void update(CCVKGPUTextureView oldView, CCVKGPUTextureView newView)
	{
		CCVKGPUDescriptorHub descriptorHub = CCVKDevice.getInstance().gpuDescriptorHub();
		uint32 instanceCount = uint32(instances.Count);

		for (int i = 0U; i < gpuDescriptors.Count; i++)
		{
			ref CCVKGPUDescriptor binding = ref gpuDescriptors[i];
			if (hasFlag(DESCRIPTOR_TEXTURE_TYPE, binding.type) && (binding.gpuTextureView == oldView))
			{
				for (uint32 t = 0U; t < instanceCount; ++t)
				{
					ref CCVKDescriptorInfo descriptorInfo = ref instances[t].descriptorInfos[i];

					if (newView != null)
					{
						descriptorHub.connect(this, newView, &descriptorInfo.image);
						descriptorHub.update(newView, &descriptorInfo.image);
					}
				}
				binding.gpuTextureView = newView;
			}
		}
		CCVKDevice.getInstance().gpuDescriptorSetHub().record(this);
	}

	public List<CCVKGPUDescriptor> gpuDescriptors = new .() ~ delete _;

	// references
	public CCVKGPUDescriptorSetLayout gpuLayout;

	public struct Instance
	{
		public VkDescriptorSet vkDescriptorSet = .Null;
		public List<CCVKDescriptorInfo> descriptorInfos = new .();
		public List<VkWriteDescriptorSet> descriptorUpdateEntries = new .();
	}
	public List<Instance> instances = new .() ~ { for(var x in _){ delete x.descriptorInfos; delete x.descriptorUpdateEntries;} delete _;}; // per swapchain image

	public uint32 layoutID = 0U;
}