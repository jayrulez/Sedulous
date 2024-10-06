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
	/// <param name="graphicsContext">DirectX graphics context.</param>
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
	protected override GraphicsPipelineState CreateGraphicsPipelineInternal(in GraphicsPipelineDescription description)
	{
		return new DX12GraphicsPipelineState(context, description);
	}

	/// <inheritdoc />
	protected override ComputePipelineState CreateComputePipelineInternal(in ComputePipelineDescription description)
	{
		return new DX12ComputePipelineState(context, description);
	}

	/// <inheritdoc />
	protected override RaytracingPipelineState CreateRaytracingPipelineInternal(in RaytracingPipelineDescription description)
	{
		return new DX12RaytracingPipelineState(context, description);
	}

	/// <inheritdoc />
	protected override Sedulous.RHI.Buffer CreateBufferInternal(void* data, in BufferDescription description)
	{
		return new DX12Buffer(context, data, description);
	}

	/// <inheritdoc />
	protected override Texture CreateTextureInternal(DataBox[] data, in TextureDescription description, in SamplerStateDescription samplerState)
	{
		return new DX12Texture(context, data, description, samplerState);
	}

	/// <inheritdoc />
	protected override Shader CreateShaderInternal(in ShaderDescription description)
	{
		return new DX12Shader(context, description);
	}

	/// <inheritdoc />
	protected override SamplerState CreateSamplerStateInternal(in SamplerStateDescription description)
	{
		return new DX12SamplerState(context, description);
	}

	/// <inheritdoc />
	protected override FrameBuffer CreateFrameBufferInternal(FrameBufferAttachment? depthTarget, FrameBufferAttachmentList colorTargets, bool disposeAttachments)
	{
		return new DX12FrameBuffer(context, depthTarget, colorTargets, disposeAttachments);
	}

	/// <inheritdoc />
	protected override ResourceLayout CreateResourceLayoutInternal(in ResourceLayoutDescription description)
	{
		return new DX12ResourceLayout(description);
	}

	/// <inheritdoc />
	protected override ResourceSet CreateResourceSetInternal(in ResourceSetDescription description)
	{
		return new DX12ResourceSet(description);
	}

	/// <inheritdoc />
	protected override Texture GetTextureFromNativePointerInternal(void* texturePointer, in TextureDescription textureDescription)
	{
		return DX12Texture.FromDirectXTexture(context, texturePointer, textureDescription);
	}

	/// <inheritdoc />
	public override QueryHeap CreateQueryHeap(in QueryHeapDescription description)
	{
		return new DX12QueryHeap(context, description);
	}
}
