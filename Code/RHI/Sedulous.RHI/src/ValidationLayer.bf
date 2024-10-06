#define TRACE
using System;
using System.Diagnostics;
using Sedulous.RHI.Raytracing;
using Sedulous.Foundation.Logging.Abstractions;

namespace Sedulous.RHI;

/// <summary>
/// The graphics validation layer.
/// </summary>
public class ValidationLayer
{
	private readonly ILogger logger;
	private readonly bool ownsNotifyDelegate = false;

	/// <summary>
	/// The Notify delegate function.
	/// </summary>
	/// <param name="owner">The owner of the error message.</param>
	/// <param name="message">The content of the error message.</param>
	/// <param name="severity">The severity associated with the message.</param>
	public delegate void NotifyAction(String owner, String message, Severity severity = Severity.Error);

	/// <summary>
	/// The supported notification methods.
	/// </summary>
	public enum NotifyMethod
	{
		/// <summary>
		/// The validation layer throws exceptions.
		/// </summary>
		Exceptions,
		/// <summary>
		/// Validation layer trace information.
		/// </summary>
		Trace,
		/// <summary>
		/// The validation layer triggers events.
		/// </summary>
		Events
	}

	/// <summary>
	/// Severity enumeration.
	/// </summary>
	public enum Severity
	{
		/// <summary>
		/// Indicates the severity of the error.
		/// </summary>
		Error,
		/// <summary>
		/// Severity of the warning.
		/// </summary>
		Warning,
		/// <summary>
		/// The severity of the information.
		/// </summary>
		Information
	}

	/// <summary>
	/// Pointer to the Notify function.
	/// </summary>
	public NotifyAction Notify;

	/// <summary>
	/// Event that allows obtaining error messages if <see cref="T:Sedulous.RHI.ValidationLayer.NotifyMethod" /> is set to <see cref="F:Sedulous.RHI.ValidationLayer.NotifyMethod.Events" />.
	/// </summary>
	public delegate void(Object sender, String message) Error;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ValidationLayer" /> class.
	/// </summary>
	/// <param name="method">The notification method <see cref="T:Sedulous.RHI.ValidationLayer.NotifyMethod" />, exception by default.</param>
	public this(ILogger logger, NotifyMethod method = NotifyMethod.Exceptions)
	{
		logger = logger;
		ownsNotifyDelegate = true;

		switch (method)
		{
		case NotifyMethod.Exceptions:
			Notify = new => NotifyException;
			break;
		case NotifyMethod.Trace:
			Notify = new => NotifyTrace;
			break;
		case NotifyMethod.Events:
			Notify = new => NotifyEvent;
			break;
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ValidationLayer" /> class.
	/// </summary>
	/// <param name="function">The callback function called for every detected error.</param>
	public this(ILogger logger, NotifyAction @function)
	{
		logger = logger;

		Notify = @function;
	}

	public ~this()
	{
		if(ownsNotifyDelegate)
		{
			delete Notify;
		}
	}

	/// <summary>
	/// Creates a command queue validation layer.
	/// </summary>
	/// <param name="queueType">The type of queue.</param>
	public void CreateCommandQueueValidation(CommandQueueType queueType)
	{
		if (queueType < CommandQueueType.Graphics || queueType > CommandQueueType.Copy)
		{
			NotifyInternal("Invalid queue type value, Graphics, Compute and Copy are the only valid values.");
		}
	}

	/// <summary>
	/// Creates a graphics pipeline validation.
	/// </summary>
	/// <param name="description">The graphics pipeline description.</param>
	public void CreateGraphicsPipelineValidation(in GraphicsPipelineDescription description)
	{
		if (description.Outputs.ColorAttachments.IsEmpty && !description.Outputs.DepthAttachment.HasValue)
		{
			NotifyInternal("A GraphicsPipeline must contain an output description.");
		}
	}

	/// <summary>
	/// Creates a compute pipeline validation layer.
	/// </summary>
	/// <param name="description">The compute pipeline's description.</param>
	public void CreateComputePipelineValidation(in ComputePipelineDescription description)
	{
		/*if (description.shaderDescription == null)
		{
			NotifyInternal("The compute shader cannot be null in a ComputePipeline.");
		}*/
	}

	/// <summary>
	/// Creates a ray tracing pipeline validation layer.
	/// </summary>
	/// <param name="description">The ray tracing pipeline description.</param>
	public void CreateRaytracingPipelineValidation(in RaytracingPipelineDescription description)
	{
	}

	/// <summary>
	/// Creates a texture validation layer.
	/// </summary>
	/// <param name="data">The texture data.</param>
	/// <param name="description">The texture description.</param>
	/// <param name="samplerState">The texture sampler state.</param>
	public void CreateTextureValidation(DataBox[] data, in TextureDescription description, in SamplerStateDescription samplerState)
	{
		if (description.Width == 0 || description.Height == 0 || description.Depth == 0)
		{
			NotifyInternal("Width, Height, and Depth must be non-zero.");
		}
		if (description.Faces > 1 && description.Type != TextureType.TextureCube && description.Type != TextureType.TextureCubeArray)
		{
			NotifyInternal("Number of faces could be > 1 for a texture cube and texture cube array type.");
		}
		if (description.ArraySize > 1 && description.Type != TextureType.Texture1DArray && description.Type != TextureType.Texture2DArray && description.Type != TextureType.TextureCubeArray)
		{
			NotifyInternal("Array size could be > 1 for a non texture array type.");
		}
		if ((description.Format == PixelFormat.R24G8_Typeless || description.Format == PixelFormat.D24_UNorm_S8_UInt || description.Format == PixelFormat.R32G8X24_Typeless || description.Format == PixelFormat.D32_Float_S8X24_UInt) && (description.Flags & TextureFlags.DepthStencil) == 0)
		{
			NotifyInternal(" The PixelFormat can only be used in a Texture with DepthStencil flag.");
		}
		if ((description.Type == TextureType.Texture1D || description.Type == TextureType.Texture1DArray) && description.Height > 1)
		{
			NotifyInternal("Height of a Texture1D or Texture1DArray must be 1");
		}
	}

	/// <summary>
	/// Creates the buffer validation layer.
	/// </summary>
	/// <param name="data">The buffer's data.</param>
	/// <param name="description">The buffer's description.</param>
	public void CreateBufferValidation(void* data, in BufferDescription description)
	{
		if ((description.Flags & BufferFlags.BufferStructured) == BufferFlags.BufferStructured || (description.Flags & BufferFlags.UnorderedAccess) == BufferFlags.UnorderedAccess)
		{
			if (description.StructureByteStride == 0)
			{
				NotifyInternal("Structured Buffer must have a non-zero StructureByteStride value.");
			}
			if ((description.Flags & BufferFlags.VertexBuffer) != 0 || (description.Flags & BufferFlags.IndexBuffer) != 0)
			{
				NotifyInternal("Structured Buffer cannot also be a VertexBuffer or IndexBuffer.");
			}
		}
		else if (description.StructureByteStride != 0)
		{
			NotifyInternal("Non-structured Buffers must have a StructureByteStride of zero.");
		}
		if ((description.Flags & BufferFlags.ConstantBuffer) != 0 && description.SizeInBytes % 16 != 0)
		{
			NotifyInternal("ConstantBuffers size must be a multiple of 16 bytes.");
		}
	}

	/// <summary>
	/// Creates a shader validation layer.
	/// </summary>
	/// <param name="description">The shader's description.</param>
	public void CreateShaderValidation(in ShaderDescription description)
	{
		if (String.IsNullOrEmpty(description.EntryPoint))
		{
			NotifyInternal("The EntryPoint cannot be null or empty.");
		}
		if (description.ShaderBytes.Count == 0)
		{
			NotifyInternal("The shader bytes cannot be zero.");
		}
	}

	/// <summary>
	/// Creates the sampler state validation layer.
	/// </summary>
	/// <param name="description">The description of the sampler state.</param>
	public void CreateSamplerStateValidation(in SamplerStateDescription description)
	{
		if (description.MaxAnisotropy > 16)
		{
			NotifyInternal("Out of range, the maximum value for Anisotropy is 16.");
		}
	}

	/// <summary>
	/// Creates a frame buffer validation.
	/// </summary>
	/// <param name="depthTarget">The depth frame buffer.</param>
	/// <param name="colorTargets">The color frame buffers.</param>
	/// <param name="disposeAttachments">Whether the attachments should be disposed.</param>
	public void CreateFrameBufferValidation(FrameBufferAttachment? depthTarget, FrameBufferAttachment[] colorTargets, bool disposeAttachments)
	{
		if (colorTargets.Count == 0)
		{
			NotifyInternal("A frameBuffer must contain at least one colorTarget attachment");
		}
	}

	/// <summary>
	/// Creates a resource layout validation.
	/// </summary>
	/// <param name="description">The resource layout description.</param>
	public void CreateResourceLayoutValidation(in ResourceLayoutDescription description)
	{
	}

	/// <summary>
	/// Creates the resource set validation.
	/// </summary>
	/// <param name="description">The resource set description.</param>
	public void CreateResourceSetValidation(in ResourceSetDescription description)
	{
	}

	/// <summary>
	/// Updates the buffer data.
	/// </summary>
	/// <param name="inRenderPass">Indicates if the operation is made inside a render pass.</param>
	/// <param name="sourceSizeInBytes">The source buffer size in bytes.</param>
	public void UpdateBufferData(bool inRenderPass, uint32 sourceSizeInBytes)
	{
		if (inRenderPass)
		{
			NotifyInternal("UpdateBufferData operation is not allowed inside a renderPass.");
		}
		if (sourceSizeInBytes == 0)
		{
			NotifyInternal("SourceSizeInBytes must be non-zero.");
		}
	}

	/// <summary>
	/// Validates the copy buffer operation.
	/// </summary>
	/// <param name="inRenderPass">Indicates whether the operation is made inside a render pass.</param>
	/// <param name="sizeInBytes">The size of the buffer in bytes.</param>
	public void CopyBufferDataTo(bool inRenderPass, uint32 sizeInBytes)
	{
		if (inRenderPass)
		{
			NotifyInternal("CopyBufferDataTo operation is not allowed inside a renderPass.");
		}
		if (sizeInBytes == 0)
		{
			NotifyInternal("SizeInBytes must be non-zero.");
		}
	}

	/// <summary>
	/// Validates the copy texture data operation.
	/// </summary>
	/// <param name="inRenderPass">Indicates if the operation is made inside a render pass.</param>
	public void CopyTextureDataTo(bool inRenderPass)
	{
		if (inRenderPass)
		{
			NotifyInternal("CopyBufferDataTo operation is not allowed inside a renderPass.");
		}
	}

	/// <summary>
	/// Validates CommandBuffer.SetGraphicsPipelineState.
	/// </summary>
	/// <param name="inRenderPass">Indicates if the operation is performed inside a render pass.</param>
	public void SetGraphicsPipelineState(bool inRenderPass)
	{
		if (!inRenderPass)
		{
			NotifyInternal("SetGraphicsPipelineState operation is not allowed outside a renderPass.");
		}
	}

	/// <summary>
	/// Validation of CommandBuffer.SetResourceSet.
	/// </summary>
	/// <param name="inRenderPass">Indicates if the operation is made inside a render pass.</param>
	/// <param name="hasComputePipeline">Indicates if a compute pipeline is bound.</param>
	internal void SetResourceSet(bool inRenderPass, bool hasComputePipeline)
	{
		if (!hasComputePipeline && !inRenderPass)
		{
			NotifyInternal("SetResourceSet operation is not allowed outside a renderPass.");
		}
	}

	/// <summary>
	/// Validates <see cref="M:Sedulous.RHI.CommandBuffer.SetVertexBuffer(System.UInt32,Sedulous.RHI.Buffer,System.UInt32)" />.
	/// </summary>
	/// <param name="inRenderPass">Indicates if the operation is performed inside a render pass.</param>
	internal void SetVertexBuffer(bool inRenderPass)
	{
		if (!inRenderPass)
		{
			NotifyInternal("SetVertexBuffer operation is not allowed outside a renderPass.");
		}
	}

	/// <summary>
	/// Validation of <see cref="M:Sedulous.RHI.CommandBuffer.SetVertexBuffer(System.UInt32,Sedulous.RHI.Buffer,System.UInt32)" />.
	/// </summary>
	/// <param name="inRenderPass">Indicates if the operation is made inside a render pass.</param>
	/// <param name="buffers">The buffers.</param>
	/// <param name="offsets">The offsets.</param>
	internal void SetVertexBuffers(bool inRenderPass, Buffer[] buffers, int32[] offsets)
	{
		if (!inRenderPass)
		{
			NotifyInternal("SetVertexBuffers operation is not allowed outside a renderPass.");
		}
		if (buffers != null && offsets != null && buffers.Count != offsets.Count)
		{
			NotifyInternal("SetVertexBuffers: If offsets array is specified, it must match the buffers array length.");
		}
	}

	/// <summary>
	/// Validation of <see cref="M:Sedulous.RHI.CommandBuffer.SetIndexBuffer(Sedulous.RHI.Buffer,Sedulous.RHI.IndexFormat,System.UInt32)" />.
	/// </summary>
	/// <param name="inRenderPass">Specifies whether the operation is made inside a render pass.</param>
	internal void SetIndexBuffer(bool inRenderPass)
	{
		if (!inRenderPass)
		{
			NotifyInternal("SetIndexBuffer operation is not allowed outside a renderPass.");
		}
	}

	private void NotifyEvent(String owner, String message, Severity severity)
	{
		String fullMessage = scope $"A {owner} error was encountered: {message}";
		this.Error?.Invoke(severity, fullMessage);
	}

	private void NotifyTrace(String owner, String message, Severity severity)
	{
		logger.LogTrace(scope $"A {owner} error was encountered: {message}");
	}

	private void NotifyException(String owner, String message, Severity severity)
	{
		String fullMessage = scope $"A {owner} error was encountered: {message}";
		switch (severity)
		{
		case Severity.Information:
			logger.LogInformation(fullMessage);
			break;
		case Severity.Warning:
			logger.LogWarning(fullMessage);
			break;
		case Severity.Error:
			Runtime.FatalError(fullMessage);
		}
	}

	private void NotifyInternal(String message)
	{
		Notify("Sedulous", message);
	}
}
