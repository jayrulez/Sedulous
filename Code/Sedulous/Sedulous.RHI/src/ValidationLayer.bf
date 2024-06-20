#define TRACE
using System;
using System.Diagnostics;
using Sedulous.RHI.Raytracing;

namespace Sedulous.RHI;

/// <summary>
/// The graphics validation layer.
/// </summary>
class ValidationLayer
{
	/// <summary>
	/// The Notify delegate function.
	/// </summary>
	/// <param name="owner">The owner of this error message.</param>
	/// <param name="message">The error message content.</param>
	/// <param name="severity">The severity associated with the message.</param>
	public delegate void NotifyAction(String owner, String message, Severity severity = Severity.Error);

	/// <summary>
	/// The supported notify methods.
	/// </summary>
	public enum NotifyMethod
	{
		/// <summary>
		/// Validation layer throws exceptions.
		/// </summary>
		Exceptions,
		/// <summary>
		/// Validation layer trace info.
		/// </summary>
		Trace,
		/// <summary>
		/// Validation layer fires events.
		/// </summary>
		Events
	}

	/// <summary>
	/// Severity enumerate.
	/// </summary>
	public enum Severity
	{
		/// <summary>
		/// Error severity.
		/// </summary>
		Error,
		/// <summary>
		/// Warning severity.
		/// </summary>
		Warning,
		/// <summary>
		/// The information severity.
		/// </summary>
		Information
	}

	/// <summary>
	/// Pointer to Notify function.
	/// </summary>
	public NotifyAction Notify;

	private bool mOwnsNotifyDelegate = false;

	/// <summary>
	/// Event that allow to obtains the error messages if NofityMethod is set to Events.
	/// </summary>
	public delegate void(Object sender, String message) Error;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ValidationLayer" /> class.
	/// </summary>
	/// <param name="method">The notify method <see cref="T:Sedulous.RHI.ValidationLayer.NotifyMethod" />, exception by default.</param>
	public this(NotifyMethod method = NotifyMethod.Exceptions)
	{
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

		mOwnsNotifyDelegate = true;
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ValidationLayer" /> class.
	/// </summary>
	/// <param name="function">The callback function called for every error detection.</param>
	public this(NotifyAction @function)
	{
		Notify = @function;
	}

	/// <summary>
	/// Creates a command queue validation layer.
	/// </summary>
	/// <param name="queueType">The queue type.</param>
	public void CreateCommandQueueValidation(CommandQueueType queueType)
	{
		if (queueType < CommandQueueType.Graphics || queueType > CommandQueueType.Copy)
		{
			NotifyInternal("Invalid queue type value, Graphics, Compute and Copy are the only valid values.");
		}
	}

	/// <summary>
	/// Creates a graphic pipeline validation.
	/// </summary>
	/// <param name="description">The graphic pipeline description.</param>
	public void CreateGraphicsPipelineValidation(ref GraphicsPipelineDescription description)
	{
		if (description.Outputs.ColorAttachments.IsEmpty && !description.Outputs.DepthAttachment.HasValue)
		{
			NotifyInternal("A GraphicsPipeline must contain an output description.");
		}
	}

	/// <summary>
	/// Creates a compute pipeline validation layer.
	/// </summary>
	/// <param name="description">The compute pipeline description.</param>
	public void CreateComputePipelineValidation(ref ComputePipelineDescription description)
	{
		if (description.shaderDescription == null)
		{
			NotifyInternal("The compute shader cannot be null in a ComputePipeline.");
		}
	}

	/// <summary>
	/// Creates a raytracing pipeline validatino layer.
	/// </summary>
	/// <param name="description">The raytracing pipeline description.</param>
	public void CreateRaytracingPipelineValidation(ref RaytracingPipelineDescription description)
	{
	}

	/// <summary>
	/// Creates a texture validation layer.
	/// </summary>
	/// <param name="data">The texture data.</param>
	/// <param name="description">The texture description.</param>
	/// <param name="samplerState">The texture sampler state.</param>
	public void CreateTextureValidation(DataBox[] data, ref TextureDescription description, ref SamplerStateDescription samplerState)
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
	/// <param name="data">The buffer data.</param>
	/// <param name="description">The buffer description.</param>
	public void CreateBufferValidation(void* data, ref BufferDescription description)
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
	/// <param name="description">The shader description.</param>
	public void CreateShaderValidation(ref ShaderDescription description)
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
	/// <param name="description">The sampler state description.</param>
	public void CreateSamplerStateValidation(ref SamplerStateDescription description)
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
	/// <param name="disposeAttachments">If the attachments should be disposed.</param>
	public void CreateFrameBufferValidation(FrameBufferAttachment? depthTarget, FrameBufferColorAttachmentList colorTargets, bool disposeAttachments)
	{
		if (colorTargets.Count == 0)
		{
			NotifyInternal("A frameBuffer must contain at least one colorTarget attachment");
		}
	}

	/// <summary>
	/// Creates the resource layout validation.
	/// </summary>
	/// <param name="description">The resource layout description.</param>
	public void CreateResourceLayoutValidation(ref ResourceLayoutDescription description)
	{
	}

	/// <summary>
	/// Creates the resource set validation.
	/// </summary>
	/// <param name="description">The resource set description.</param>
	public void CreateResourceSetValidation(ref ResourceSetDescription description)
	{
	}

	/// <summary>
	/// Updates the buffer data.
	/// </summary>
	/// <param name="inRenderPass">IF the operation is made inside a render pass.</param>
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
	/// Validation of the copy buffer operation.
	/// </summary>
	/// <param name="inRenderPass">If the operation is made inside a render pass.</param>
	/// <param name="sizeInBytes">The size in bytes of the buffer.</param>
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
	/// Validation of the copy texture data operation.
	/// </summary>
	/// <param name="inRenderPass">If the operation is made inside a render pass.</param>
	public void CopyTextureDataTo(bool inRenderPass)
	{
		if (inRenderPass)
		{
			NotifyInternal("CopyBufferDataTo operation is not allowed inside a renderPass.");
		}
	}

	/// <summary>
	/// Validation of CommandBuffer.SetGraphicsPipelineState.
	/// </summary>
	/// <param name="inRenderPass">If the operation is made inside a render pass.</param>
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
	/// <param name="inRenderPass">If the operation is made inside a render pass.</param>
	/// <param name="hasComputePipeline">Has compute pipeline binded.</param>
	internal void SetResourceSet(bool inRenderPass, bool hasComputePipeline)
	{
		if (!hasComputePipeline && !inRenderPass)
		{
			NotifyInternal("SetResourceSet operation is not allowed outside a renderPass.");
		}
	}

	/// <summary>
	/// Validation of CommandBuffer.SetVertexBuffer.
	/// </summary>
	/// <param name="inRenderPass">If the operation is made inside a render pass.</param>
	internal void SetVertexBuffer(bool inRenderPass)
	{
		if (!inRenderPass)
		{
			NotifyInternal("SetVertexBuffer operation is not allowed outside a renderPass.");
		}
	}

	/// <summary>
	/// Validation of CommandBuffer.SetVertexBuffers.
	/// </summary>
	/// <param name="inRenderPass">If the operation is made inside a render pass.</param>
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
	/// Validation of CommandBuffer.SetIndexBuffer.
	/// </summary>
	/// <param name="inRenderPass">If the operation is made inside a render pass.</param>
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
		//Trace.TraceInformation(scope $"A {owner} error was encountered: {message}");
		Console.WriteLine(scope $"A {owner} error was encountered: {message}");
	}

	private void NotifyException(String owner, String message, Severity severity)
	{
		String fullMessage = scope $"A {owner} error was encountered: {message}";
		switch (severity)
		{
		case Severity.Information:
			//Trace.TraceInformation(fullMessage);
			Console.WriteLine(fullMessage);
			break;
		case Severity.Warning:
			//Trace.TraceWarning(fullMessage);
			Console.WriteLine(fullMessage);
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
