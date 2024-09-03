using System;
using System.Collections;
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

abstract class Device
{
	public static Device getInstance()
	{
		return Device.instance;
	}

	public ~this()
	{
		Device.instance = null;
		delete _cmdBuff;
		delete _queue;
	}

	public bool initialize(in DeviceInfo info)
	{
		_bindingMappingInfo = info.bindingMappingInfo;

#if BF_32_BIT
		static_assert(sizeof(void*) == 4, "pointer size assumption broken");
#else
		Compiler.Assert(sizeof(void*) == 8, "pointer size assumption broken");
#endif

		bool result = doInit(info);

		//CC_SAFE_ADD_REF(_cmdBuff);
		//CC_SAFE_ADD_REF(_queue);
		return result;
	}
	public void destroy()
	{
		for (var pair in _samplers)
		{
			delete pair.value;
		}
		_samplers.Clear();

		for (var pair in _generalBarriers)
		{
			delete pair.value;
		}
		_generalBarriers.Clear();

		for (var pair in _textureBarriers)
		{
			delete pair.value;
		}
		_textureBarriers.Clear();

		for (var pair in _bufferBarriers)
		{
			delete pair.value;
		}
		_bufferBarriers.Clear();

		doDestroy();
	}

	// aim to ensure waiting for work on gpu done when cpu encodes ahead of gpu certain frame(s).
	public abstract void frameSync();

	public abstract void acquire(Swapchain* swapchains, uint32 count);
	public abstract void present();

	public virtual void flushCommands(CommandBuffer* cmdBuffs, uint32 count) { }

	public virtual ref MemoryStatus getMemoryStatus() { return ref _memoryStatus; }
	public virtual uint32 getNumDrawCalls() { return _numDrawCalls; }
	public virtual uint32 getNumInstances() { return _numInstances; }
	public virtual uint32 getNumTris() { return _numTriangles; }

	[Inline] public CommandBuffer createCommandBuffer(in CommandBufferInfo info)
	{
		CommandBuffer res = createCommandBuffer(info, false);
		res.initialize(info);
		return res;
	}
	[Inline] public CommandQueue createQueue(in QueueInfo info)
	{
		CommandQueue res = createQueue();
		res.initialize(info);
		return res;
	}
	[Inline] public QueryPool createQueryPool(in QueryPoolInfo info)
	{
		QueryPool res = createQueryPool();
		res.initialize(info);
		return res;
	}
	[Inline] public Swapchain createSwapchain(in SwapchainInfo info)
	{
		Swapchain res = createSwapchain();
		res.initialize(info);
		_swapchains.Add(res);
		return res;
	}
	[Inline] public readonly ref List<Swapchain> getSwapchains() { return ref _swapchains; }
	[Inline] public Buffer createBuffer(in BufferInfo info)
	{
		Buffer res = createBuffer();
		res.initialize(info);
		return res;
	}
	[Inline] public Buffer createBuffer(in BufferViewInfo info)
	{
		Buffer res = createBuffer();
		res.initialize(info);
		return res;
	}
	[Inline] public Texture createTexture(in TextureInfo info)
	{
		Texture res = createTexture();
		res.initialize(info);
		return res;
	}
	[Inline] public Texture createTexture(in TextureViewInfo info)
	{
		Texture res = createTexture();
		res.initialize(info);
		return res;
	}
	[Inline] public Shader createShader(in ShaderInfo info)
	{
		Shader res = createShader();
		res.initialize(info);
		return res;
	}
	[Inline] public InputAssembler createInputAssembler(in InputAssemblerInfo info)
	{
		InputAssembler res = createInputAssembler();
		res.initialize(info);
		return res;
	}
	[Inline] public RenderPass createRenderPass(in RenderPassInfo info)
	{
		RenderPass res = createRenderPass();
		res.initialize(info);
		return res;
	}
	[Inline] public Framebuffer createFramebuffer(in FramebufferInfo info)
	{
		Framebuffer res = createFramebuffer();
		res.initialize(info);
		return res;
	}
	[Inline] public DescriptorSet createDescriptorSet(in DescriptorSetInfo info)
	{
		DescriptorSet res = createDescriptorSet();
		res.initialize(info);
		return res;
	}
	[Inline] public DescriptorSetLayout createDescriptorSetLayout(in DescriptorSetLayoutInfo info)
	{
		DescriptorSetLayout res = createDescriptorSetLayout();
		res.initialize(info);
		return res;
	}
	[Inline] public PipelineLayout createPipelineLayout(in PipelineLayoutInfo info)
	{
		PipelineLayout res = createPipelineLayout();
		res.initialize(info);
		return res;
	}
	[Inline] public PipelineState createPipelineState(in PipelineStateInfo info)
	{
		PipelineState res = createPipelineState();
		res.initialize(info);
		return res;
	}

	public virtual Sampler getSampler(in SamplerInfo info)
	{
		if (!_samplers.ContainsKey(info))
		{
			_samplers[info] = createSampler(info);
		}
		return _samplers[info];
	}

	public virtual GeneralBarrier getGeneralBarrier(in GeneralBarrierInfo info)
	{
		if (!_generalBarriers.ContainsKey(info))
		{
			_generalBarriers[info] = createGeneralBarrier(info);
		}
		return _generalBarriers[info];
	}

	public virtual TextureBarrier getTextureBarrier(in TextureBarrierInfo info)
	{
		if (!_textureBarriers.ContainsKey(info))
		{
			_textureBarriers[info] = createTextureBarrier(info);
		}
		return _textureBarriers[info];
	}

	public virtual BufferBarrier getBufferBarrier(in BufferBarrierInfo info)
	{
		if (!_bufferBarriers.ContainsKey(info))
		{
			_bufferBarriers[info] = createBufferBarrier(info);
		}
		return _bufferBarriers[info];
	}

	public abstract void copyBuffersToTexture(uint8** buffers, Texture dst, in BufferTextureCopy* regions, uint32 count);
	public abstract void copyTextureToBuffers(Texture src, uint8** buffers, in BufferTextureCopy* region, uint32 count);
	public abstract void getQueryPoolResults(QueryPool queryPool);

	[Inline] public void copyTextureToBuffers(Texture src, in BufferSrcList buffers, in BufferTextureCopyList regions)
	{
		copyTextureToBuffers(src, buffers.Ptr, regions.Ptr, uint32(regions.Count));
	}
	[Inline] public void copyBuffersToTexture(in BufferDataList buffers, Texture dst, in BufferTextureCopyList regions)
	{
		copyBuffersToTexture(buffers.Ptr, dst, regions.Ptr, (uint32)regions.Count);
	}
	[Inline] public void flushCommands(in List<CommandBuffer> cmdBuffs)
	{
		flushCommands(cmdBuffs.Ptr, (uint32)cmdBuffs.Count);
	}
	[Inline] public void acquire(in List<Swapchain> swapchains)
	{
		acquire(swapchains.Ptr, (uint32)swapchains.Count);
	}

	[Inline] public  CommandQueue getQueue() { return _queue; }
	[Inline] public QueryPool getQueryPool() { return _queryPool; }
	[Inline] public CommandBuffer getCommandBuffer() { return _cmdBuff; }
	[Inline] public readonly ref DeviceCaps getCapabilities() { return ref _caps; }
	[Inline] public API getGfxAPI() { return _api; }
	[Inline] public readonly ref String getDeviceName() { return ref _deviceName; }
	[Inline] public readonly ref String getRenderer() { return ref _renderer; }
	[Inline] public readonly ref String getVendor() { return ref _vendor; }
	[Inline] public bool hasFeature(Feature feature) { return _features[(uint32)feature]; }
	[Inline] public FormatFeature getFormatFeatures(Format format) { return _formatFeatures[(uint32)format]; }

	[Inline] public readonly ref BindingMappingInfo bindingMappingInfo() { return ref _bindingMappingInfo; }

	public virtual void enableAutoBarrier(bool en) { _options.enableBarrierDeduce = en; }
	public virtual SampleCount getMaxSampleCount(Format format, TextureUsage usage, TextureFlags flags)
	{
		return SampleCount.X1;
	};

	protected static Device instance = null;
	protected static bool isSupportDetachDeviceThread = true;


	protected this()
	{
		Device.instance = this;
		// Device instance is created and hold by TS. Native should hold it too
		// to make sure it exists after JavaScript virtual machine is destroyed.
		// Then will destroy the Device instance in native.
		_features.SetAll(false);
		_formatFeatures.SetAll(FormatFeature.NONE);
	}

	protected abstract bool doInit(in DeviceInfo info);
	protected abstract void doDestroy();

	protected abstract CommandBuffer createCommandBuffer(in CommandBufferInfo info, bool hasAgent);
	protected abstract CommandQueue createQueue();
	protected abstract QueryPool createQueryPool();
	protected abstract Swapchain createSwapchain();
	protected abstract Buffer createBuffer();
	protected abstract Texture createTexture();
	protected abstract Shader createShader();
	protected abstract InputAssembler createInputAssembler();
	protected abstract RenderPass createRenderPass();
	protected abstract Framebuffer createFramebuffer();
	protected abstract DescriptorSet createDescriptorSet();
	protected abstract DescriptorSetLayout createDescriptorSetLayout();
	protected abstract PipelineLayout createPipelineLayout();
	protected abstract PipelineState createPipelineState();

	protected virtual Sampler createSampler(in SamplerInfo info) { return new Sampler(info); }
	protected virtual GeneralBarrier createGeneralBarrier(in GeneralBarrierInfo info) { return new GeneralBarrier(info); }
	protected virtual TextureBarrier createTextureBarrier(in TextureBarrierInfo info) { return new TextureBarrier(info); }
	protected virtual BufferBarrier createBufferBarrier(in BufferBarrierInfo info) { return new BufferBarrier(info); }

	// For context switching between threads
	protected virtual void bindContext(bool bound) { }

	protected String _deviceName;
	protected String _renderer;
	protected String _vendor;
	protected String _version;
	protected API _api =  API.UNKNOWN;
	protected DeviceCaps _caps;
	protected BindingMappingInfo _bindingMappingInfo;
	protected DeviceOptions _options;

	protected bool _multithreadedCommandRecording =  true;

	protected bool[(int)Feature.COUNT] _features;
	protected FormatFeature[(int)Format.COUNT] _formatFeatures;

	protected CommandQueue _queue =  null;
	protected QueryPool _queryPool =  null;
	protected CommandBuffer _cmdBuff =  null;

	protected uint32 _numDrawCalls =  0;
	protected uint32 _numInstances =  0;
	protected uint32 _numTriangles =  0;
	protected MemoryStatus _memoryStatus;

	protected Dictionary<SamplerInfo, Sampler> _samplers;
	protected Dictionary<GeneralBarrierInfo, GeneralBarrier> _generalBarriers;
	protected Dictionary<TextureBarrierInfo, TextureBarrier> _textureBarriers;
	protected Dictionary<BufferBarrierInfo, BufferBarrier> _bufferBarriers;

	private List<Swapchain> _swapchains = new .() ~ delete _; // weak reference
}
