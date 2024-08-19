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

namespace cc
{
	namespace gfx
	{
		class Sampler : GFXObject
		{
			public this(in SamplerInfo info)
				: base(ObjectType.SAMPLER)
			{
				_info = info;
				_hash = computeHash(info);
			}

			public static HashType computeHash(in SamplerInfo info)
			{
				uint32 hash = (uint32)(info.minFilter);
				hash |= (uint32)(info.magFilter) << 2;
				hash |= (uint32)(info.mipFilter) << 4;
				hash |= (uint32)(info.addressU) << 6;
				hash |= (uint32)(info.addressV) << 8;
				hash |= (uint32)(info.addressW) << 10;
				hash |= (uint32)(info.maxAnisotropy) << 12;
				hash |= (uint32)(info.cmpFunc) << 16;
				return (HashType)(hash);
			}
			public static SamplerInfo unpackFromHash(HashType hash)
			{
				SamplerInfo info = .();
				info.minFilter = (Filter)((hash & ((1 << 2) - 1)) >> 0);
				info.magFilter = (Filter)((hash & ((1 << 2) - 1)) >> 2);
				info.mipFilter = (Filter)((hash & ((1 << 2) - 1)) >> 4);
				info.addressU = (Address)((hash & ((1 << 2) - 1)) >> 6);
				info.addressV = (Address)((hash & ((1 << 2) - 1)) >> 8);
				info.addressW = (Address)((hash & ((1 << 2) - 1)) >> 10);
				info.maxAnisotropy = (uint32)(hash & ((1 << 4) - 1)) >> 12;
				info.cmpFunc = (ComparisonFunc)((hash & ((1 << 3) - 1)) >> 16);
				return info;
			}

			[Inline] public readonly ref SamplerInfo getInfo() { return ref _info; }
			[Inline] public readonly ref HashType getHash() { return ref _hash; }

			protected SamplerInfo _info;
			protected HashType _hash =  0;
		}
	} // namespace gfx
} // namespace cc
