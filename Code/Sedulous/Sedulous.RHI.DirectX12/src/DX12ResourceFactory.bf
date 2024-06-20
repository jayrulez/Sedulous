using System;
using Sedulous.RHI;
using Sedulous.RHI.Raytracing;

namespace Sedulous.RHI.DirectX12;
using internal Sedulous.RHI.DirectX12;

/// <summary>
/// The DirectX version of the resource factory.
/// </summary>
public class DX12ResourceFactory : ResourceFactory
{
	private DX12GraphicsContext context;

	/// <inheritdoc />
	protected override GraphicsContext GraphicsContext => context;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12ResourceFactory" /> class.
	/// </summary>
	/// <param name="graphicsContext">DirectX Graphics Context.</param>
	public this(DX12GraphicsContext graphicsContext)
	{
		context = graphicsContext;
	}

	/// <inheritdoc />
	protected override CommandQueue CreateCommandQueueInternal(CommandQueueType queueType)
	{
		if (queueType == CommandQueueType.Graphics)
		{
			return context.DefaultGraphicsQueue;
		}
		return new DX12CommandQueue(context, queueType);
	}

	/// <inheritdoc />
	protected override GraphicsPipelineState CreateGraphicsPipelineInternal(ref GraphicsPipelineDescription description)
	{
		return new DX12GraphicsPipelineState(context, ref description);
	}

	/// <inheritdoc />
	protected override ComputePipelineState CreateComputePipelineInternal(ref ComputePipelineDescription description)
	{
		return new DX12ComputePipelineState(context, ref description);
	}

	/// <inheritdoc />
	protected override RaytracingPipelineState CreateRaytracingPipelineInternal(ref RaytracingPipelineDescription description)
	{
		return new DX12RaytracingPipelineState(context, ref description);
	}

	/// <inheritdoc />
	protected override Buffer CreateBufferInternal(void* data, ref BufferDescription description)
	{
		return new DX12Buffer(context, data, ref description);
	}

	/// <inheritdoc />
	protected override Texture CreateTextureInternal(DataBox[] data, ref TextureDescription description, ref SamplerStateDescription samplerState)
	{
		return new DX12Texture(context, data, ref description, ref samplerState);
	}

	/// <inheritdoc />
	protected override Shader CreateShaderInternal(ref ShaderDescription description)
	{
		return new DX12Shader(context, ref description);
	}

	/// <inheritdoc />
	protected override SamplerState CreateSamplerStateInternal(ref SamplerStateDescription description)
	{
		return new DX12SamplerState(context, ref description);
	}

	/// <inheritdoc />
	protected override FrameBuffer CreateFrameBufferInternal(FrameBufferAttachment? depthTarget, FrameBufferColorAttachmentList colorTargets, bool disposeAttachments)
	{
		return new DX12FrameBuffer(context, depthTarget, colorTargets, disposeAttachments);
	}

	/// <inheritdoc />
	protected override ResourceLayout CreateResourceLayoutInternal(ref ResourceLayoutDescription description)
	{
		return new DX12ResourceLayout(ref description);
	}

	/// <inheritdoc />
	protected override ResourceSet CreateResourceSetInternal(ref ResourceSetDescription description)
	{
		return new DX12ResourceSet(ref description);
	}

	/// <inheritdoc />
	protected override Texture GetTextureFromNativePointerInternal(void* texturePointer, ref TextureDescription textureDescription)
	{
		return DX12Texture.FromDirectXTexture(context, texturePointer, textureDescription);
	}

	/// <inheritdoc />
	public override QueryHeap CreateQueryHeap(ref QueryHeapDescription description)
	{
		return new DX12QueryHeap(context, ref description);
	}

	public override void DestroyCommandQueue(ref CommandQueue commandQueue)
	{
		if (var dx12CommandQueue = commandQueue as DX12CommandQueue)
		{
			delete dx12CommandQueue;
			commandQueue = null;
		}
	}

	public override void DestroyGraphicsPipeline(ref GraphicsPipelineState graphicsPipelineState)
	{
		if (var dx12GraphicsPipelineState = graphicsPipelineState as DX12GraphicsPipelineState)
		{
			delete dx12GraphicsPipelineState;
			graphicsPipelineState = null;
		}
	}

	public override void DestroyComputePipeline(ref ComputePipelineState computePipelineState)
	{
		if (var dx12ComputePipelineState = computePipelineState as DX12ComputePipelineState)
		{
			delete dx12ComputePipelineState;
			computePipelineState = null;
		}
	}

	public override void DestroyRaytracingPipeline(ref RaytracingPipelineState raytracingPipelineState)
	{
		if (var dx12RaytracingPipelineState = raytracingPipelineState as DX12RaytracingPipelineState)
		{
			delete dx12RaytracingPipelineState;
			raytracingPipelineState = null;
		}
	}

	public override void DestroyTexture(ref Texture texture)
	{
		if (var dx12Texture = texture as DX12Texture)
		{
			delete dx12Texture;
			texture = null;
		}
	}

	public override void DestroyBuffer(ref Buffer buffer)
	{
		if (var dx12Buffer = buffer as DX12Buffer)
		{
			delete dx12Buffer;
			buffer = null;
		}
	}

	public override void DestroyQueryHeap(ref QueryHeap queryHeap)
	{
		if (var dx12QueryHeap = queryHeap as DX12QueryHeap)
		{
			delete dx12QueryHeap;
			queryHeap = null;
		}
	}

	public override void DestroyShader(ref Shader shader)
	{
		if (var dx12Shader = shader as DX12Shader)
		{
			delete dx12Shader;
			shader = null;
		}
	}

	public override void DestroySamplerState(ref SamplerState samplerState)
	{
		if (var dx12SamplerState = samplerState as DX12SamplerState)
		{
			delete dx12SamplerState;
			samplerState = null;
		}
	}

	public override void DestroyFrameBuffer(ref FrameBuffer frameBuffer)
	{
		if (var dx12FrameBuffer = frameBuffer as DX12FrameBuffer)
		{
			delete dx12FrameBuffer;
			frameBuffer = null;
		}
	}

	public override void DestroyResourceLayout(ref ResourceLayout resourceLayout)
	{
		if (var dx12ResourceLayout = resourceLayout as DX12ResourceLayout)
		{
			delete dx12ResourceLayout;
			resourceLayout = null;
		}
	}

	public override void DestroyResourceSet(ref ResourceSet resourceSet)
	{
		if (var dx12ResourceSet = resourceSet as DX12ResourceSet)
		{
			delete dx12ResourceSet;
			resourceSet = null;
		}
	}
}
