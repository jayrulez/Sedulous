using Sedulous.Renderer.VK.Internal;
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

using internal Sedulous.Renderer.VK;

static
{
	internal static void initGpuShader(CCVKGPUShader gpuShader)
	{
		cmdFuncCCVKCreateShader(CCVKDevice.getInstance(), gpuShader);

		// Clear shader source after they're uploaded to GPU
		for (var stage in ref gpuShader.gpuStages)
		{
			stage.source.Clear();
			//stage.source.shrink_to_fit();
		}

		gpuShader.initialized = true;
	}
}

class CCVKShader : Shader
{
	public this()
	{
		_typedID = generateObjectID<Self>();
	}

	public ~this()
	{
		destroy();
	}

	public CCVKGPUShader gpuShader()
	{
		if (!_gpuShader.initialized)
		{
			initGpuShader(_gpuShader);
		}
		return _gpuShader;
	}

	protected  override void doInit(in ShaderInfo info)
	{
		_gpuShader = new CCVKGPUShader();
		_gpuShader.name = _name;
		_gpuShader.attributes = _attributes;
		for (ref ShaderStage stage in ref _stages)
		{
			_gpuShader.gpuStages.Add(new CCVKGPUShaderStage(stage.stage, stage.source));
		}
		for (var stage in ref _stages)
		{
			//stage.source.Clear();
			//stage.source.shrink_to_fit();
		}
	}

	protected  override void doDestroy()
	{
		for (var stage in ref _gpuShader.gpuStages)
		{
			delete stage;
		}
		_gpuShader = null;
	}

	protected CCVKGPUShader _gpuShader;
}