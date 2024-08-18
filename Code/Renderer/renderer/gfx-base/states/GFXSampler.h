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

#pragma once

#include "../GFXObject.h"
#include "base/std/hash/hash.h"
#include "gfx-base/GFXDef-common.h"

namespace cc {
	namespace gfx {

		class CC_DLL Sampler : public GFXObject {
		public:
			explicit Sampler(const SamplerInfo& info)
				: GFXObject(ObjectType::SAMPLER) {
				_info = info;
				_hash = computeHash(info);
			}

			static ccstd::hash_t computeHash(const SamplerInfo& info) {
				return Hasher<SamplerInfo>()(info);
			}
			static SamplerInfo unpackFromHash(ccstd::hash_t hash) {
				SamplerInfo info;
				info.minFilter = static_cast<Filter>((hash & ((1 << 2) - 1)) >> 0);
				info.magFilter = static_cast<Filter>((hash & ((1 << 2) - 1)) >> 2);
				info.mipFilter = static_cast<Filter>((hash & ((1 << 2) - 1)) >> 4);
				info.addressU = static_cast<Address>((hash & ((1 << 2) - 1)) >> 6);
				info.addressV = static_cast<Address>((hash & ((1 << 2) - 1)) >> 8);
				info.addressW = static_cast<Address>((hash & ((1 << 2) - 1)) >> 10);
				info.maxAnisotropy = (hash & ((1 << 4) - 1)) >> 12;
				info.cmpFunc = static_cast<ComparisonFunc>((hash & ((1 << 3) - 1)) >> 16);
				return info;
			}

			inline const SamplerInfo& getInfo() const { return _info; }
			inline const ccstd::hash_t& getHash() const { return _hash; }

		protected:
			SamplerInfo _info;
			ccstd::hash_t _hash{ 0U };
		};

	} // namespace gfx
} // namespace cc
