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
		abstract class PipelineState : GFXObject
		{
			public this()
				: base(ObjectType.PIPELINE_STATE)
			{
			}

			public void initialize(in PipelineStateInfo info)
			{
				_primitive = info.primitive;
				_shader = info.shader;
				_inputState = info.inputState;
				_rasterizerState = info.rasterizerState;
				_depthStencilState = info.depthStencilState;
				_bindPoint = info.bindPoint;
				_blendState = info.blendState;
				_dynamicStates = info.dynamicStates;
				_renderPass = info.renderPass;
				_subpass = info.subpass;
				_pipelineLayout = info.pipelineLayout;

				doInit(info);
			}
			public void destroy()
			{
				doDestroy();

				_shader = null;
				_renderPass = null;
				_pipelineLayout = null;
			}

			[Inline] public Shader getShader() { return _shader; }
			[Inline] public PipelineBindPoint getBindPoint() { return _bindPoint; }
			[Inline] public PrimitiveMode getPrimitive() { return _primitive; }
			[Inline] public DynamicStateFlags getDynamicStates() { return _dynamicStates; }
			[Inline] public readonly ref InputState getInputState() { return ref _inputState; }
			[Inline] public readonly ref RasterizerState getRasterizerState() { return ref _rasterizerState; }
			[Inline] public readonly ref DepthStencilState getDepthStencilState() { return ref _depthStencilState; }
			[Inline] public readonly ref BlendState getBlendState() { return ref _blendState; }
			[Inline] public readonly ref RenderPass getRenderPass() { return ref _renderPass; }
			[Inline] public readonly ref PipelineLayout getPipelineLayout() { return ref _pipelineLayout; }

			protected abstract void doInit(in PipelineStateInfo info);
			protected abstract void doDestroy();

			protected Shader _shader = null;
			protected PipelineBindPoint _bindPoint = PipelineBindPoint.GRAPHICS;
			protected PrimitiveMode _primitive = PrimitiveMode.TRIANGLE_LIST;
			protected DynamicStateFlags _dynamicStates = DynamicStateFlags.NONE;
			protected InputState _inputState;
			protected RasterizerState _rasterizerState;
			protected DepthStencilState _depthStencilState;
			protected BlendState _blendState;
			protected RenderPass _renderPass = null;
			protected uint32 _subpass = 0;
			protected PipelineLayout _pipelineLayout = null;
		}
	} // namespace gfx
} // namespace cc
