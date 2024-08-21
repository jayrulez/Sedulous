using Bulkan;
using System.Collections;
using Sedulous.Foundation.Collections;
namespace Sedulous.Renderer.VK.Internal;

using Sedulous.Renderer;

		/**
		 * Descriptor data maintenance hub, events like buffer/texture resizing,
		 * descriptor set binding change, etc. should all request an update operation here.
		 */
class CCVKGPUDescriptorHub
{
	public this(CCVKGPUDevice device)
	{
	}

	public void connect(CCVKGPUDescriptorSet set, CCVKGPUBufferView buffer, VkDescriptorBufferInfo* descriptor, uint32 instanceIdx)
	{
		_gpuBufferViewSet[buffer].sets.Add(set);
		_gpuBufferViewSet[buffer].descriptors.Push(descriptor);
		_bufferInstanceIndices[descriptor] = instanceIdx;
	}
	public void connect(CCVKGPUDescriptorSet set, CCVKGPUTextureView texture, VkDescriptorImageInfo* descriptor)
	{
		_gpuTextureViewSet[texture].sets.Add(set);
		_gpuTextureViewSet[texture].descriptors.Push(descriptor);
	}
	public void connect(CCVKGPUSampler sampler, VkDescriptorImageInfo* descriptor)
	{
		_samplers[sampler].Push(descriptor);
	}

	public void update(CCVKGPUBufferView buffer, VkDescriptorBufferInfo* descriptor)
	{
		if (!_gpuBufferViewSet.ContainsKey(buffer)) return;
		var descriptors = ref _gpuBufferViewSet[buffer].descriptors;
		for (uint32 i = 0U; i < descriptors.Size(); i++)
		{
			if (descriptors[i] == descriptor)
			{
				doUpdate(buffer, descriptor);
				break;
			}
		}
	}

	public void update(CCVKGPUTextureView texture, VkDescriptorImageInfo* descriptor)
	{
		if (!_gpuTextureViewSet.ContainsKey(texture)) return;
		var descriptors = ref _gpuTextureViewSet[texture].descriptors;
		for (uint32 i = 0U; i < descriptors.Size(); i++)
		{
			if (descriptors[i] == descriptor)
			{
				doUpdate(texture, descriptor);
				break;
			}
		}
	}

	public void update(CCVKGPUTextureView texture, VkDescriptorImageInfo* descriptor, AccessFlags flags)
	{
		if (!_gpuTextureViewSet.ContainsKey(texture)) return;
		var descriptors = ref _gpuTextureViewSet[texture].descriptors;
		for (uint32 i = 0U; i < descriptors.Size(); i++)
		{
			if (descriptors[i] == descriptor)
			{
				doUpdate(texture, descriptor, flags);
				break;
			}
		}
	}

	public void update(CCVKGPUSampler sampler, VkDescriptorImageInfo* descriptor)
	{
		if (!_samplers.ContainsKey(sampler)) return;
		var descriptors = ref _samplers[sampler];
		for (uint32 i = 0U; i < descriptors.Size(); ++i)
		{
			if (descriptors[i] == descriptor)
			{
				doUpdate(sampler, descriptor);
				break;
			}
		}
	}
	// for resize events
	public void update(CCVKGPUBufferView oldView, CCVKGPUBufferView newView)
	{
		if (!_gpuBufferViewSet.ContainsKey(oldView))
		{
			var sets = ref _gpuBufferViewSet[oldView].sets;
			for (var set in sets)
			{
				set.update(oldView, newView);
			}
			_gpuBufferViewSet.Remove(oldView);
		}
	}

	public void update(CCVKGPUTextureView oldView, CCVKGPUTextureView newView)
	{
		if (!_gpuTextureViewSet.ContainsKey(oldView))
		{
			var sets = ref _gpuTextureViewSet[oldView].sets;
			for (var set in sets)
			{
				set.update(oldView, newView);
			}
			_gpuTextureViewSet.Remove(oldView);
		}
	}

	public void disengage(CCVKGPUBufferView buffer)
	{
		if (!_gpuBufferViewSet.ContainsKey(buffer)) return;
		for (uint32 i = 0; i < _gpuBufferViewSet[buffer].descriptors.Size(); ++i)
		{
			_bufferInstanceIndices.Remove(_gpuBufferViewSet[buffer].descriptors[i]);
		}
		_gpuBufferViewSet.Remove(buffer);
	}
	public void disengage(CCVKGPUDescriptorSet set, CCVKGPUBufferView buffer, VkDescriptorBufferInfo* descriptor)
	{
		//auto it = _gpuBufferViewSet.find(buffer);
		if (!_gpuBufferViewSet.ContainsKey(buffer)) return;
		var info = ref _gpuBufferViewSet[buffer];
		info.sets.Remove(set);
		var descriptors = ref info.descriptors;
		descriptors.FastRemove(descriptors.IndexOf(descriptor));
		_bufferInstanceIndices.Remove(descriptor);
	}
	public void disengage(CCVKGPUTextureView texture)
	{
		if (!_gpuTextureViewSet.ContainsKey(texture)) return;
		_gpuTextureViewSet.Remove(texture);
	}
	public void disengage(CCVKGPUDescriptorSet set, CCVKGPUTextureView texture, VkDescriptorImageInfo* descriptor)
	{
		if (!_gpuTextureViewSet.ContainsKey(texture)) return;
		var it = ref _gpuTextureViewSet[texture];
		it.sets.Remove(set);
		var descriptors = ref it.descriptors;
		descriptors.FastRemove(descriptors.IndexOf(descriptor));
	}
	public void disengage(CCVKGPUSampler sampler)
	{
		if (!_samplers.ContainsKey(sampler)) return;
		_samplers.Remove(sampler);
	}
	public void disengage(CCVKGPUSampler sampler, VkDescriptorImageInfo* descriptor)
	{
		if (!_samplers.ContainsKey(sampler)) return;
		var it = ref _samplers[sampler];
		var descriptors = ref it;
		descriptors.FastRemove(descriptors.IndexOf(descriptor));
	}

	private void doUpdate(CCVKGPUBufferView buffer, VkDescriptorBufferInfo* descriptor)
	{
		descriptor.buffer = buffer.gpuBuffer.vkBuffer;
		descriptor.offset = buffer.getStartOffset(_bufferInstanceIndices[descriptor]);
		descriptor.range = buffer.range;
	}

	private static void doUpdate(CCVKGPUTextureView texture, VkDescriptorImageInfo* descriptor)
	{
		descriptor.imageView = texture.vkImageView;
	}

	private static void doUpdate(CCVKGPUTextureView texture, VkDescriptorImageInfo* descriptor, AccessFlags flags)
	{
		descriptor.imageView = texture.vkImageView;
		if (texture.gpuTexture.flags.HasFlag(TextureFlagBit.GENERAL_LAYOUT))
		{
			descriptor.imageLayout = .VK_IMAGE_LAYOUT_GENERAL;
		}
		else
		{
			bool inoutAttachment = hasAllFlags(flags, AccessFlagBit.FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT | AccessFlagBit.COLOR_ATTACHMENT_WRITE) ||
				hasAllFlags(flags, AccessFlagBit.FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT | AccessFlagBit.DEPTH_STENCIL_ATTACHMENT_WRITE);
			bool storageWrite = hasAnyFlags(flags, AccessFlagBit.VERTEX_SHADER_WRITE | AccessFlagBit.FRAGMENT_SHADER_WRITE | AccessFlagBit.COMPUTE_SHADER_WRITE);

			if (inoutAttachment || storageWrite)
			{
				descriptor.imageLayout = .VK_IMAGE_LAYOUT_GENERAL;
			}
			else if (texture.gpuTexture.usage.HasFlag(TextureUsage.DEPTH_STENCIL_ATTACHMENT))
			{
				descriptor.imageLayout = .VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL;
			}
			else
			{
				descriptor.imageLayout = .VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
			}
		}
	}

	private static void doUpdate(CCVKGPUSampler sampler, VkDescriptorImageInfo* descriptor)
	{
		descriptor.sampler = sampler.vkSampler;
	}

	private struct DescriptorInfo<T>
	{
		public HashSet<CCVKGPUDescriptorSet> sets;
		public CachedArray<T*> descriptors;
	}

	private Dictionary<VkDescriptorBufferInfo*, uint32> _bufferInstanceIndices;
	private Dictionary<CCVKGPUBufferView, DescriptorInfo<VkDescriptorBufferInfo>> _gpuBufferViewSet;
	private Dictionary<CCVKGPUTextureView, DescriptorInfo<VkDescriptorImageInfo>> _gpuTextureViewSet;
	private Dictionary<CCVKGPUSampler, CachedArray<VkDescriptorImageInfo*>> _samplers;
}