using Sedulous.Renderer.VK.Internal;
using System;
using System.Collections;
using Bulkan;
/****************************************************************************
 Copyright (c) 2020-2023 Xiamen Yaji Software Co., Ltd.

 http://www.cocos.com

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
****************************************************************************/

namespace Sedulous.Renderer.VK;

class CCVKDescriptorSet : DescriptorSet
{
	public this()
	{
		_typedID = generateObjectID<decltype(this)>();
	}
	public ~this()
	{
		destroy();
	}

	public override void update()
	{
		if (_isDirty && _gpuDescriptorSet != null)
		{
			CCVKGPUDescriptorHub descriptorHub = CCVKDevice.getInstance().gpuDescriptorHub();
			CCVKGPUBarrierManager layoutMgr = CCVKDevice.getInstance().gpuBarrierManager();
			uint32 descriptorCount = (uint32)_gpuDescriptorSet.gpuDescriptors.Count;
			uint32 instanceCount = (uint32)_gpuDescriptorSet.instances.Count;

			for (int i = 0U; i < descriptorCount; i++)
			{
				ref CCVKGPUDescriptor binding = ref _gpuDescriptorSet.gpuDescriptors[i];

				if (hasFlag(DESCRIPTOR_BUFFER_TYPE, binding.type))
				{
					if (_buffers[i].ptr != null)
					{
						CCVKGPUBufferView bufferView = ((CCVKBuffer)_buffers[i].ptr).gpuBufferView();
						for (uint32 t = 0U; t < instanceCount; ++t)
						{
							ref CCVKDescriptorInfo descriptorInfo = ref _gpuDescriptorSet.instances[t].descriptorInfos[i];

							if (binding.gpuBufferView != null)
							{
								descriptorHub.disengage(_gpuDescriptorSet, binding.gpuBufferView, &descriptorInfo.buffer);
							}
							if (bufferView != null)
							{
								descriptorHub.connect(_gpuDescriptorSet, bufferView, &descriptorInfo.buffer, t);
								descriptorHub.update(bufferView, &descriptorInfo.buffer);
							}
							binding.gpuBufferView = bufferView;
						}
					}
				}
				else if (hasFlag(DESCRIPTOR_TEXTURE_TYPE, binding.type))
				{
					if (_textures[i].ptr != null)
					{
						CCVKGPUTextureView textureView = ((CCVKTexture)_textures[i].ptr).gpuTextureView();
						for (var instance in ref _gpuDescriptorSet.instances)
						{
							ref CCVKDescriptorInfo descriptorInfo = ref instance.descriptorInfos[i];
							if (binding.gpuTextureView != null)
							{
								descriptorHub.disengage(_gpuDescriptorSet, binding.gpuTextureView, &descriptorInfo.image);
							}
							if (textureView != null)
							{
								descriptorHub.connect(_gpuDescriptorSet, textureView, &descriptorInfo.image);
								descriptorHub.update(textureView, &descriptorInfo.image, _textures[i].flags);
								layoutMgr.checkIn(textureView.gpuTexture, binding.accessTypes.Ptr, (uint32)binding.accessTypes.Count);
							}
						}
						binding.gpuTextureView = textureView;
					}
					if (_samplers[i].ptr != null)
					{
						CCVKGPUSampler sampler = ((CCVKSampler)_samplers[i].ptr).gpuSampler();
						for (var instance in _gpuDescriptorSet.instances)
						{
							ref CCVKDescriptorInfo descriptorInfo = ref instance.descriptorInfos[i];
							if (binding.gpuSampler != null)
							{
								descriptorHub.disengage(binding.gpuSampler, &descriptorInfo.image);
							}
							if (sampler != null)
							{
								descriptorHub.connect(sampler, &descriptorInfo.image);
								descriptorHub.update(sampler, &descriptorInfo.image);
							}
						}
						binding.gpuSampler = sampler;
					}
				}
			}
			CCVKDevice.getInstance().gpuDescriptorSetHub().record(_gpuDescriptorSet);
			_isDirty = false;
		}
	}
	public override void forceUpdate()
	{
		_isDirty = true;
		update();
	}

	[Inline] public CCVKGPUDescriptorSet gpuDescriptorSet() { return _gpuDescriptorSet; }

	protected override void doInit(in DescriptorSetInfo info)
	{
		CCVKGPUDescriptorSetLayout gpuDescriptorSetLayout = ((CCVKDescriptorSetLayout)_layout).gpuDescriptorSetLayout();
		uint32 bindingCount = (uint32)gpuDescriptorSetLayout.bindings.Count;
		uint32 descriptorCount = gpuDescriptorSetLayout.descriptorCount;

		_gpuDescriptorSet = new CCVKGPUDescriptorSet();
		_gpuDescriptorSet.gpuDescriptors.Resize(descriptorCount, .());
		_gpuDescriptorSet.layoutID = gpuDescriptorSetLayout.id;

		for (int i = 0U, k = 0U; i < bindingCount; ++i)
		{
			readonly ref DescriptorSetLayoutBinding binding = ref gpuDescriptorSetLayout.bindings[i];
			for (uint32 j = 0; j < binding.count; ++j,++k)
			{
				ref CCVKGPUDescriptor gpuDescriptor = ref _gpuDescriptorSet.gpuDescriptors[k];
				gpuDescriptor.type = binding.descriptorType;
				switch (binding.descriptorType) {
				case DescriptorType.UNIFORM_BUFFER,
					DescriptorType.DYNAMIC_UNIFORM_BUFFER:
					if (hasFlag(binding.stageFlags, ShaderStageFlags.COMPUTE)) gpuDescriptor.accessTypes.Add(.THSVS_ACCESS_COMPUTE_SHADER_READ_UNIFORM_BUFFER);
					if (hasFlag(binding.stageFlags, ShaderStageFlags.VERTEX)) gpuDescriptor.accessTypes.Add(.THSVS_ACCESS_VERTEX_SHADER_READ_UNIFORM_BUFFER);
					if (hasFlag(binding.stageFlags, ShaderStageFlags.FRAGMENT)) gpuDescriptor.accessTypes.Add(.THSVS_ACCESS_FRAGMENT_SHADER_READ_UNIFORM_BUFFER);
					break;
				case DescriptorType.STORAGE_BUFFER,
					DescriptorType.DYNAMIC_STORAGE_BUFFER,
					DescriptorType.STORAGE_IMAGE:
					// write accesses should be handled manually
					if (hasFlag(binding.stageFlags, ShaderStageFlags.COMPUTE)) gpuDescriptor.accessTypes.Add(.THSVS_ACCESS_COMPUTE_SHADER_READ_OTHER);
					if (hasFlag(binding.stageFlags, ShaderStageFlags.VERTEX)) gpuDescriptor.accessTypes.Add(.THSVS_ACCESS_VERTEX_SHADER_READ_OTHER);
					if (hasFlag(binding.stageFlags, ShaderStageFlags.FRAGMENT)) gpuDescriptor.accessTypes.Add(.THSVS_ACCESS_FRAGMENT_SHADER_READ_OTHER);
					break;
				case DescriptorType.SAMPLER_TEXTURE,
					DescriptorType.TEXTURE:
					if (hasFlag(binding.stageFlags, ShaderStageFlags.COMPUTE)) gpuDescriptor.accessTypes.Add(.THSVS_ACCESS_COMPUTE_SHADER_READ_SAMPLED_IMAGE_OR_UNIFORM_TEXEL_BUFFER);
					if (hasFlag(binding.stageFlags, ShaderStageFlags.VERTEX)) gpuDescriptor.accessTypes.Add(.THSVS_ACCESS_VERTEX_SHADER_READ_SAMPLED_IMAGE_OR_UNIFORM_TEXEL_BUFFER);
					if (hasFlag(binding.stageFlags, ShaderStageFlags.FRAGMENT)) gpuDescriptor.accessTypes.Add(.THSVS_ACCESS_FRAGMENT_SHADER_READ_SAMPLED_IMAGE_OR_UNIFORM_TEXEL_BUFFER);
					break;
				case DescriptorType.INPUT_ATTACHMENT:
					gpuDescriptor.accessTypes.Add(.THSVS_ACCESS_FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT);
					break;
				case DescriptorType.SAMPLER:
				default:
					break;
				}
			}
		}

		CCVKGPUDevice gpuDevice = CCVKDevice.getInstance().gpuDevice();
		_gpuDescriptorSet.gpuLayout = gpuDescriptorSetLayout;
		_gpuDescriptorSet.instances.Resize(gpuDevice.backBufferCount);

		for (uint32 t = 0U; t < gpuDevice.backBufferCount; ++t)
		{
			ref CCVKGPUDescriptorSet.Instance instance = ref _gpuDescriptorSet.instances[t];
			instance.vkDescriptorSet = gpuDevice.getDescriptorSetPool(_gpuDescriptorSet.layoutID).request();
			instance.descriptorInfos.Resize(descriptorCount, .());

			for (uint32 i = 0U, k = 0U; i < bindingCount; ++i)
			{
				readonly ref DescriptorSetLayoutBinding binding = ref gpuDescriptorSetLayout.bindings[i];
				for (uint32 j = 0; j < binding.count; ++j,++k)
				{
					if (hasFlag(DESCRIPTOR_BUFFER_TYPE, binding.descriptorType))
					{
						instance.descriptorInfos[k].buffer.buffer = gpuDevice.defaultBuffer.vkBuffer;
						instance.descriptorInfos[k].buffer.offset = gpuDevice.defaultBuffer.getStartOffset(t);
						instance.descriptorInfos[k].buffer.range = gpuDevice.defaultBuffer.size;
					}
					else if (hasFlag(DESCRIPTOR_TEXTURE_TYPE, binding.descriptorType))
					{
						instance.descriptorInfos[k].image.sampler = gpuDevice.defaultSampler.vkSampler;
						instance.descriptorInfos[k].image.imageView = gpuDevice.defaultTextureView.vkImageView;
						instance.descriptorInfos[k].image.imageLayout = hasFlag(binding.descriptorType, DescriptorType.STORAGE_IMAGE)
							? .VK_IMAGE_LAYOUT_GENERAL
							: .VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
					}
				}
			}

			if (!gpuDevice.useDescriptorUpdateTemplate)
			{
				ref List<VkWriteDescriptorSet> entries = ref instance.descriptorUpdateEntries;
				entries.Resize(descriptorCount, .() { sType = .VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET });

				for (uint32 i = 0U, j = 0U; i < bindingCount; i++)
				{
					readonly ref VkDescriptorSetLayoutBinding descriptor = ref gpuDescriptorSetLayout.vkBindings[i];
					for (uint32 k = 0U; k < descriptor.descriptorCount; k++,j++)
					{
						entries[j].dstSet = instance.vkDescriptorSet;
						entries[j].dstBinding = descriptor.binding;
						entries[j].dstArrayElement = k;
						entries[j].descriptorCount = 1; // better not to assume that the descriptor infos would be contiguous
						entries[j].descriptorType = descriptor.descriptorType;
						switch (entries[j].descriptorType) {
						case .VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
							.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
							.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC,
							.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC:
							entries[j].pBufferInfo = &instance.descriptorInfos[j].buffer;
							break;
						case .VK_DESCRIPTOR_TYPE_SAMPLER,
							.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
							.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
							.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
							.VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT:
							entries[j].pImageInfo = &instance.descriptorInfos[j].image;
							break;
						case .VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER,
							.VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER:
							entries[j].pTexelBufferView = &instance.descriptorInfos[j].texelBufferView;
							break;
						default: break;
						}
					}
				}
			}
		}
	}
	protected override void doDestroy()
	{
		_gpuDescriptorSet = null;
	}

	protected CCVKGPUDescriptorSet _gpuDescriptorSet;
}
