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

#include "GFXObject.h"
#include "base/RefCounted.h"

namespace cc {
	namespace gfx {

		class CC_DLL RenderPass : public GFXObject, public RefCounted {
		public:
			RenderPass()
				: GFXObject(ObjectType::RENDER_PASS) {
			}
			~RenderPass() override;

			static ccstd::hash_t computeHash(const RenderPassInfo& info) {
				return Hasher<RenderPassInfo>()(info);
			}

			void initialize(const RenderPassInfo& info) {
				_colorAttachments = info.colorAttachments;
				_depthStencilAttachment = info.depthStencilAttachment;
				_depthStencilResolveAttachment = info.depthStencilResolveAttachment;
				_subpasses = info.subpasses;
				_dependencies = info.dependencies;
				_hash = computeHash();

				doInit(info);
			}
			void destroy() {
				doDestroy();

				_colorAttachments.clear();
				_subpasses.clear();
				_hash = 0U;
			}

			inline const ColorAttachmentList& getColorAttachments() const { return _colorAttachments; }
			inline const DepthStencilAttachment& getDepthStencilAttachment() const { return _depthStencilAttachment; }
			inline const DepthStencilAttachment& getDepthStencilResolveAttachment() const { return _depthStencilResolveAttachment; }
			inline const SubpassInfoList& getSubpasses() const { return _subpasses; }
			inline const SubpassDependencyList& getDependencies() const { return _dependencies; }
			inline ccstd::hash_t getHash() const { return _hash; }

		protected:
			// Based on render pass compatibility
			ccstd::hash_t computeHash() {
				ccstd::hash_t seed = static_cast<uint32_t>(_colorAttachments.size()) * 2 + 3;
				for (const ColorAttachment& ca : _colorAttachments) {
					ccstd::hash_combine(seed, ca);
				}
				ccstd::hash_combine(seed, _depthStencilAttachment);
				ccstd::hash_combine(seed, _depthStencilResolveAttachment);

				ccstd::hash_combine(seed, _subpasses);
				return seed;
			}

			virtual void doInit(const RenderPassInfo& info) = 0;
			virtual void doDestroy() = 0;

			ColorAttachmentList _colorAttachments;
			DepthStencilAttachment _depthStencilAttachment;
			DepthStencilAttachment _depthStencilResolveAttachment;
			SubpassInfoList _subpasses;
			SubpassDependencyList _dependencies;
			ccstd::hash_t _hash = 0;
		};

	} // namespace gfx
} // namespace cc
