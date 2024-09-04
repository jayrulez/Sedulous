using System.Collections;
using System;
/****************************************************************************
 Copyright (c) 2019-2023 Xiamen Yaji Software Co., Ltd.

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

namespace Sedulous.Renderer;

abstract class DescriptorSetLayout : GraphicsObject
{
	public this()
		: base(ObjectType.DESCRIPTOR_SET_LAYOUT)
	{
	}

	public void initialize(in DescriptorSetLayoutInfo info)
	{
		_bindings = info.bindings;
		uint32 bindingCount = (uint32)_bindings.Count;
		_descriptorCount = 0;

		if (bindingCount > 0)
		{
			uint32 maxBinding = 0;
			List<uint32> flattenedIndices = scope .() { Count = bindingCount };
			for (uint32 i = 0; i < bindingCount; i++)
			{
				readonly ref DescriptorSetLayoutBinding binding = ref _bindings[i];
				if (binding.binding > maxBinding) maxBinding = binding.binding;
				flattenedIndices[i] = _descriptorCount;
				_descriptorCount += binding.count;
			}

			_bindingIndices.Resize(maxBinding + 1, INVALID_BINDING);
			_descriptorIndices.Resize(maxBinding + 1, INVALID_BINDING);
			for (uint32 i = 0; i < bindingCount; i++)
			{
				readonly ref DescriptorSetLayoutBinding binding = ref _bindings[i];
				_bindingIndices[binding.binding] = i;
				_descriptorIndices[binding.binding] = flattenedIndices[i];
				if (DESCRIPTOR_DYNAMIC_TYPE.HasFlag(binding.descriptorType))
				{
					for (uint32 j = 0; j < binding.count; ++j)
					{
						_dynamicBindings.Add(binding.binding);
					}
				}
			}
		}

		doInit(info);
	}
	public void destroy()
	{
		doDestroy();

		_bindings.Clear();
		_descriptorCount = 0;
		_bindingIndices.Clear();
		_descriptorIndices.Clear();
	}

	[Inline] public readonly ref DescriptorSetLayoutBindingList getBindings() { return ref _bindings; }
	[Inline] public readonly ref List<uint32> getDynamicBindings() { return ref _dynamicBindings; }
	[Inline] public readonly ref List<uint32> getBindingIndices() { return ref _bindingIndices; }
	[Inline] public readonly ref List<uint32> getDescriptorIndices() { return ref _descriptorIndices; }
	[Inline] public uint32 getDescriptorCount() { return _descriptorCount; }

	protected abstract void doInit(in DescriptorSetLayoutInfo info);
	protected abstract void doDestroy();

	protected DescriptorSetLayoutBindingList _bindings;
	protected uint32 _descriptorCount = 0;
	protected List<uint32> _bindingIndices = new .() ~ delete _;
	protected List<uint32> _descriptorIndices = new .() ~ delete _;
	protected List<uint32> _dynamicBindings = new .() ~ delete _;
}
