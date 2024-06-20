using System;
using Bulkan;
using Sedulous.RHI;
using Sedulous.RHI.Raytracing;

using internal Sedulous.RHI.Vulkan;
namespace Sedulous.RHI.Vulkan;

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
	protected override Buffer CreateBufferInternal(void* data, ref BufferDescription description)
	{
		return new VKBuffer(context, data, ref description);
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
	protected override ComputePipelineState CreateComputePipelineInternal(ref ComputePipelineDescription description)
	{
		return new VKComputePipelineState(context, ref description);
	}

	/// <inheritdoc />
	protected override RaytracingPipelineState CreateRaytracingPipelineInternal(ref RaytracingPipelineDescription description)
	{
		return new VKRaytracingPipelineState(context, ref description);
	}

	/// <inheritdoc />
	protected override FrameBuffer CreateFrameBufferInternal(FrameBufferAttachment? depthTarget, FrameBufferColorAttachmentList colorTargets, bool disposeAttachments)
	{
		return new VKFrameBuffer(context, depthTarget, colorTargets, disposeAttachments);
	}

	/// <inheritdoc />
	protected override GraphicsPipelineState CreateGraphicsPipelineInternal(ref GraphicsPipelineDescription description)
	{
		return new VKGraphicsPipelineState(context, ref description);
	}

	/// <inheritdoc />
	protected override ResourceLayout CreateResourceLayoutInternal(ref ResourceLayoutDescription description)
	{
		return new VKResourceLayout(context, ref description);
	}

	/// <inheritdoc />
	protected override ResourceSet CreateResourceSetInternal(ref ResourceSetDescription description)
	{
		return new VKResourceSet(context, ref description);
	}

	/// <inheritdoc />
	protected override SamplerState CreateSamplerStateInternal(ref SamplerStateDescription description)
	{
		return new VKSamplerState(context, ref description);
	}

	/// <inheritdoc />
	protected override Shader CreateShaderInternal(ref ShaderDescription description)
	{
		return new VKShader(context, ref description);
	}

	/// <inheritdoc />
	protected override Texture CreateTextureInternal(DataBox[] data, ref TextureDescription description, ref SamplerStateDescription samplerState)
	{
		return new VKTexture(context, data, ref description, ref samplerState);
	}

	/// <inheritdoc />
	protected override Texture GetTextureFromNativePointerInternal(void* texturePointer, ref TextureDescription textureDescription)
	{
		return VKTexture.FromVulkanImage(image: new VkImage((uint64)(int)texturePointer), context: context, description: ref textureDescription);
	}

	/// <inheritdoc />
	public override QueryHeap CreateQueryHeap(ref QueryHeapDescription description)
	{
		return new VKQueryHeap(context, ref description);
	}

	public override void DestroyCommandQueue(ref CommandQueue commandQueue)
	{
		if (var vkCommandQueue = commandQueue as VKCommandQueue)
		{
			delete vkCommandQueue;
			commandQueue = null;
		}
	}

	public override void DestroyGraphicsPipeline(ref GraphicsPipelineState graphicsPipelineState)
	{
		if (var vkGraphicsPipelineState = graphicsPipelineState as VKGraphicsPipelineState)
		{
			delete vkGraphicsPipelineState;
			graphicsPipelineState = null;
		}
	}

	public override void DestroyComputePipeline(ref ComputePipelineState computePipelineState)
	{
		if (var vkComputePipelineState = computePipelineState as VKComputePipelineState)
		{
			delete vkComputePipelineState;
			computePipelineState = null;
		}
	}

	public override void DestroyRaytracingPipeline(ref RaytracingPipelineState raytracingPipelineState)
	{
		if (var vkRaytracingPipelineState = raytracingPipelineState as VKRaytracingPipelineState)
		{
			delete vkRaytracingPipelineState;
			raytracingPipelineState = null;
		}
	}

	public override void DestroyTexture(ref Texture texture)
	{
		if (var vkTexture = texture as VKTexture)
		{
			delete vkTexture;
			texture = null;
		}
	}

	public override void DestroyBuffer(ref Buffer buffer)
	{
		if (var vkBuffer = buffer as VKBuffer)
		{
			delete vkBuffer;
			buffer = null;
		}
	}

	public override void DestroyQueryHeap(ref QueryHeap queryHeap)
	{
		if (var vkQueryHeap = queryHeap as VKQueryHeap)
		{
			delete vkQueryHeap;
			queryHeap = null;
		}
	}

	public override void DestroyShader(ref Shader shader)
	{
		if (var vkShader = shader as VKShader)
		{
			delete vkShader;
			shader = null;
		}
	}

	public override void DestroySamplerState(ref SamplerState samplerState)
	{
		if (var vkSamplerState = samplerState as VKSamplerState)
		{
			delete vkSamplerState;
			samplerState = null;
		}
	}

	public override void DestroyFrameBuffer(ref FrameBuffer frameBuffer)
	{
		if (var vkFrameBuffer = frameBuffer as VKFrameBuffer)
		{
			delete vkFrameBuffer;
			frameBuffer = null;
		}
	}

	public override void DestroyResourceLayout(ref ResourceLayout resourceLayout)
	{
		if (var vkResourceLayout = resourceLayout as VKResourceLayout)
		{
			delete vkResourceLayout;
			resourceLayout = null;
		}
	}

	public override void DestroyResourceSet(ref ResourceSet resourceSet)
	{
		if (var vkResourceSet = resourceSet as VKResourceSet)
		{
			delete vkResourceSet;
			resourceSet = null;
		}
	}
}
