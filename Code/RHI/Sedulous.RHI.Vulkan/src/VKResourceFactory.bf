using System;
using Bulkan;
using Sedulous.RHI;
using Sedulous.RHI.Raytracing;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// The Vulkan version of the resource factory.
/// </summary>
public class VKResourceFactory : ResourceFactory
{
	private VKGraphicsContext context;

	/// <inheritdoc />
	protected override GraphicsContext GraphicsContext => context;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKResourceFactory" /> class.
	/// </summary>
	/// <param name="graphicsContext">The Graphics Context.</param>
	public this(VKGraphicsContext graphicsContext)
	{
		context = graphicsContext;
	}

	/// <inheritdoc />
	protected override Sedulous.RHI.Buffer CreateBufferInternal(void* data, in BufferDescription description)
	{
		return new VKBuffer(context, data, description);
	}

	/// <inheritdoc />
	protected override CommandQueue CreateCommandQueueInternal(CommandQueueType queueType)
	{
		int32 queueFamily = -1;
		switch (queueType)
		{
		case CommandQueueType.Graphics:
			queueFamily = context.QueueIndices.GraphicsFamily;
			break;
		case CommandQueueType.Compute:
			queueFamily = context.QueueIndices.ComputeFamily;
			break;
		case CommandQueueType.Copy:
			queueFamily = context.QueueIndices.CopyFamily;
			break;
		}
		if (queueFamily >= 0)
		{
			return new VKCommandQueue(context, queueType);
		}
		if (context.ValidationLayer != null)
		{
			context.ValidationLayer.Notify("Vulkan", scope $"CommandQueue of type {queueType} is not supported.", ValidationLayer.Severity.Warning);
		}
		return null;
	}

	/// <inheritdoc />
	protected override ComputePipelineState CreateComputePipelineInternal(in ComputePipelineDescription description)
	{
		return new VKComputePipelineState(context, description);
	}

	/// <inheritdoc />
	protected override RaytracingPipelineState CreateRaytracingPipelineInternal(in RaytracingPipelineDescription description)
	{
		return new VKRaytracingPipelineState(context, description);
	}

	/// <inheritdoc />
	protected override FrameBuffer CreateFrameBufferInternal(FrameBufferAttachment? depthTarget, FrameBufferAttachmentList colorTargets, bool disposeAttachments)
	{
		return new VKFrameBuffer(context, depthTarget, colorTargets, disposeAttachments);
	}

	/// <inheritdoc />
	protected override GraphicsPipelineState CreateGraphicsPipelineInternal(in GraphicsPipelineDescription description)
	{
		return new VKGraphicsPipelineState(context, description);
	}

	/// <inheritdoc />
	protected override ResourceLayout CreateResourceLayoutInternal(in ResourceLayoutDescription description)
	{
		return new VKResourceLayout(context, description);
	}

	/// <inheritdoc />
	protected override ResourceSet CreateResourceSetInternal(in ResourceSetDescription description)
	{
		return new VKResourceSet(context, description);
	}

	/// <inheritdoc />
	protected override SamplerState CreateSamplerStateInternal(in SamplerStateDescription description)
	{
		return new VKSamplerState(context, description);
	}

	/// <inheritdoc />
	protected override Shader CreateShaderInternal(in ShaderDescription description)
	{
		return new VKShader(context, description);
	}

	/// <inheritdoc />
	protected override Texture CreateTextureInternal(DataBox[] data, in TextureDescription description, in SamplerStateDescription samplerState)
	{
		return new VKTexture(context, data, description, samplerState);
	}

	/// <inheritdoc />
	protected override Texture GetTextureFromNativePointerInternal(void* texturePointer, in TextureDescription textureDescription)
	{
		return VKTexture.FromVulkanImage(image: new VkImage((uint64)(int)texturePointer), context: context, description: textureDescription);
	}

	/// <inheritdoc />
	public override QueryHeap CreateQueryHeap(in QueryHeapDescription description)
	{
		return new VKQueryHeap(context, description);
	}
}
