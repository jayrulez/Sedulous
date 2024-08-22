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

		abstract class CommandQueue : GFXObject
		{
			public this()
				: base(ObjectType.QUEUE)
			{
			}

			public void initialize(in QueueInfo info)
			{
				_type = info.type;

				doInit(info);
			}


			public void destroy()
			{
				doDestroy();

				_type = QueueType.GRAPHICS;
			}

			public abstract void submit(CommandBuffer* cmdBuffs, uint32 count);

			[Inline] public void submit(in CommandBufferList cmdBuffs) { submit(cmdBuffs.Ptr, (uint32)cmdBuffs.Count); }

			[Inline] public QueueType getType() { return _type; }

			protected abstract void doInit(in QueueInfo info);
			protected abstract void doDestroy();

			protected QueueType _type = QueueType.GRAPHICS;
		}
