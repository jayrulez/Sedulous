using System;
using Sedulous.RHI.Raytracing;

namespace Sedulous.RHI;

/// <summary>
/// This Factory allow create GPU device resources.
/// </summary>
public abstract class ResourceFactory
{
	/// <summary>
	/// Gets the generic graphicsContext.
	/// </summary>
	protected abstract GraphicsContext GraphicsContext { get; }

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.CommandQueue" /> instance.
	/// </summary>
	/// <param name="queueType">The commandQueue type, <see cref="T:Sedulous.RHI.CommandQueueType" />.</param>
	/// <returns>The new commandQueue.</returns>
	public CommandQueue CreateCommandQueue(CommandQueueType queueType = CommandQueueType.Graphics)
	{
		GraphicsContext.ValidationLayer?.CreateCommandQueueValidation(queueType);
		return CreateCommandQueueInternal(queueType);
	}

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.CommandQueue" /> instance.
	/// </summary>
	/// <param name="queueType">The commandQueue type, <see cref="T:Sedulous.RHI.CommandQueueType" />.</param>
	/// <returns>The new commandQueue.</returns>
	[Inline]
	protected abstract CommandQueue CreateCommandQueueInternal(CommandQueueType queueType = CommandQueueType.Graphics);

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.GraphicsPipelineState" /> instance.
	/// </summary>
	/// <param name="description">The graphics pipelinestate description.</param>
	/// <returns>The new pipelinestate.</returns>
	public GraphicsPipelineState CreateGraphicsPipeline(in GraphicsPipelineDescription description)
	{
		GraphicsContext.ValidationLayer?.CreateGraphicsPipelineValidation(description);
		return CreateGraphicsPipelineInternal(description);
	}

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.GraphicsPipelineState" /> instance.
	/// </summary>
	/// <param name="description">The graphics pipelinestate description.</param>
	/// <returns>The new pipelinestate.</returns>
	[Inline]
	protected abstract GraphicsPipelineState CreateGraphicsPipelineInternal(in GraphicsPipelineDescription description);

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.ComputePipelineState" /> instance.
	/// </summary>
	/// <param name="description">The compute pipelinestate description.</param>
	/// <returns>The new pipelinestate.</returns>
	public ComputePipelineState CreateComputePipeline(in ComputePipelineDescription description)
	{
		GraphicsContext.ValidationLayer?.CreateComputePipelineValidation(description);
		return CreateComputePipelineInternal(description);
	}

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.ComputePipelineState" /> instance.
	/// </summary>
	/// <param name="description">The compute pipelinestate description.</param>
	/// <returns>The new pipelinestate.</returns>
	[Inline]
	protected abstract ComputePipelineState CreateComputePipelineInternal(in ComputePipelineDescription description);

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.Raytracing.RaytracingPipelineState" /> instance.
	/// </summary>
	/// <param name="description">The raytracing pipelinestate description.</param>
	/// <returns>The new pipelinestate.</returns>
	public RaytracingPipelineState CreateRaytracingPipeline(in RaytracingPipelineDescription description)
	{
		GraphicsContext.ValidationLayer?.CreateRaytracingPipelineValidation(description);
		return CreateRaytracingPipelineInternal(description);
	}

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.Raytracing.RaytracingPipelineState" /> instance.
	/// </summary>
	/// <param name="description">The raytracing pipelinestate description.</param>
	/// <returns>The new pipelinestate.</returns>
	[Inline]
	protected abstract RaytracingPipelineState CreateRaytracingPipelineInternal(in RaytracingPipelineDescription description);

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.Texture" /> instance.
	/// </summary>
	/// <param name="description">The texture description.</param>
	/// <param name="debugName">The texture name (Debug purposes).</param>
	/// <returns>The new texture.</returns>
	public Texture CreateTexture(in TextureDescription description, String debugName = null)
	{
		SamplerStateDescription samplerStatedescription = SamplerStates.LinearWrap;
		Texture texture = CreateTexture(null, description, samplerStatedescription);
		texture.Name = debugName;
		return texture;
	}

	/// <summary>
	/// Gets a <see cref="T:Sedulous.RHI.Texture" /> instance from an existing texture using the specified native pointer.
	/// </summary>
	/// <param name="texturePointer">The pointer of the texture.</param>
	/// <param name="textureDescription">The texture description of the already created texture.</param>
	/// <returns>The texture instance.</returns>
	public Texture GetTextureFromNativePointer(void* texturePointer, in TextureDescription textureDescription)
	{
		if (texturePointer == null)
		{
			GraphicsContext.ValidationLayer?.Notify("Sedulous", "Texture pointer cannot be null in GetTextureFromNativePointer()");
		}
		return GetTextureFromNativePointerInternal(texturePointer, textureDescription);
	}

	/// <summary>
	/// Gets a <see cref="T:Sedulous.RHI.Texture" /> instance from an existing texture using the specified native pointer.
	/// </summary>
	/// <param name="texturePointer">The pointer of the texture.</param>
	/// <param name="textureDescription">The texture description of the already created texture.</param>
	/// <returns>The texture instance.</returns>
	[Inline]
	protected abstract Texture GetTextureFromNativePointerInternal(void* texturePointer, in TextureDescription textureDescription);

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.Texture" /> instance.
	/// </summary>
	/// <param name="data">The texture data.</param>
	/// <param name="description">The texture description.</param>
	/// <param name="debugName">The texture name (Debug purposes).</param>
	/// <returns>The new texture1D.</returns>
	public Texture CreateTexture(DataBox[] data, in TextureDescription description, String debugName = null)
	{
		SamplerStateDescription samplerStatedescription = SamplerStates.LinearWrap;
		Texture texture = CreateTexture(data, description, samplerStatedescription);
		texture.Name = debugName;
		return texture;
	}

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.Texture" /> instance.
	/// </summary>
	/// <param name="data">The texture data.</param>
	/// <param name="description">The texture description.</param>
	/// <param name="samplerState">The sampler state description <see cref="T:Sedulous.RHI.SamplerStateDescription" /> struct.</param>
	/// <param name="debugName">The texture name (Debug pruposes).</param>
	/// <returns>The new texture.</returns>
	public Texture CreateTexture(DataBox[] data, in TextureDescription description, in SamplerStateDescription samplerState, String debugName = null)
	{
		GraphicsContext.ValidationLayer?.CreateTextureValidation(data, description, samplerState);
		Texture texture = CreateTextureInternal(data, description, samplerState);
		texture.Name = debugName;
		return texture;
	}

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.Texture" /> instance.
	/// </summary>
	/// <param name="data">The texture data.</param>
	/// <param name="description">The texture description.</param>
	/// <param name="samplerState">The sampler state description <see cref="T:Sedulous.RHI.SamplerStateDescription" /> struct.</param>
	/// <returns>The new texture.</returns>
	[Inline]
	protected abstract Texture CreateTextureInternal(DataBox[] data, in TextureDescription description, in SamplerStateDescription samplerState);

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.Buffer" /> instance.
	/// </summary>
	/// <param name="description">The index buffer description.</param>
	/// <param name="debugName">The buffer name (Debug purposes).</param>
	/// <returns>The new buffer.</returns>
	public Buffer CreateBuffer(in BufferDescription description, String debugName = null)
	{
		Buffer buffer = CreateBuffer(null, description);
		buffer.Name = debugName;
		return buffer;
	}

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.Buffer" /> instance.
	/// </summary>
	/// <typeparam name="T">The data type.</typeparam>
	/// <param name="data">The data array.</param>
	/// <param name="description">The index buffer description.</param>
	/// <param name="debugName">The buffer name (Debug purposes).</param>
	/// <returns>The new buffer.</returns>
	public Buffer CreateBuffer<T>(T[] data, in BufferDescription description, String debugName = null) where T : struct
	{
		Buffer buffer = CreateBuffer(data.Ptr, description);
		buffer.Name = debugName;
		return buffer;
	}

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.Buffer" /> instance.
	/// </summary>
	/// <typeparam name="T">The data type.</typeparam>
	/// <param name="data">The data reference.</param>
	/// <param name="description">The index buffer description.</param>
	/// <param name="debugName">The buffer name (Debug purposes).</param>
	/// <returns>The new buffer.</returns>
	public Buffer CreateBuffer<T>(ref T data, in BufferDescription description, String debugName = null) where T : struct
	{
		Buffer buffer = CreateBuffer(&data, description);
		buffer.Name = debugName;
		return buffer;
	}

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.Buffer" /> instance.
	/// </summary>
	/// <param name="data">Data pointer.</param>
	/// <param name="description">The index buffer description.</param>
	/// <param name="debugName">The buffer name (Debug purposes).</param>
	/// <returns>The new buffer.</returns>
	public Buffer CreateBuffer(void* data, in BufferDescription description, String debugName = null)
	{
		GraphicsContext.ValidationLayer?.CreateBufferValidation(data, description);
		Buffer buffer = CreateBufferInternal(data, description);
		buffer.Name = debugName;
		return buffer;
	}

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.Buffer" /> instance.
	/// </summary>
	/// <param name="data">Data pointer.</param>
	/// <param name="description">The index buffer description.</param>
	/// <returns>The new buffer.</returns>
	[Inline]
	protected abstract Buffer CreateBufferInternal(void* data, in BufferDescription description);

	/// <summary>
	/// Create a <see cref="T:Sedulous.RHI.QueryHeap" /> instance.
	/// </summary>
	/// <param name="description">The queryheap description.</param>
	/// <returns>The new queryheap.</returns>
	public abstract QueryHeap CreateQueryHeap(in QueryHeapDescription description);

	/// <summary>
	/// Create a <see cref="T:Sedulous.RHI.Shader" /> instance.
	/// </summary>
	/// <param name="description">The shader description.</param>
	/// <returns>The new shader.</returns>
	public Shader CreateShader(in ShaderDescription description)
	{
		GraphicsContext.ValidationLayer?.CreateShaderValidation(description);
		return CreateShaderInternal(description);
	}

	/// <summary>
	/// Create a <see cref="T:Sedulous.RHI.Shader" /> instance.
	/// </summary>
	/// <param name="description">The shader description.</param>
	/// <returns>The new shader.</returns>
	[Inline]
	protected abstract Shader CreateShaderInternal(in ShaderDescription description);

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.SamplerState" /> instance.
	/// </summary>
	/// <param name="description">The sampler state description.</param>
	/// <returns>The new samplerstate.</returns>
	public SamplerState CreateSamplerState(in SamplerStateDescription description)
	{
		GraphicsContext.ValidationLayer?.CreateSamplerStateValidation(description);
		return CreateSamplerStateInternal(description);
	}

	/// <summary>
	/// Creates a <see cref="T:Sedulous.RHI.SamplerState" /> instance.
	/// </summary>
	/// <param name="description">The sampler state description.</param>
	/// <returns>The new samplerstate.</returns>
	[Inline]
	protected abstract SamplerState CreateSamplerStateInternal(in SamplerStateDescription description);

	/// <summary>
	/// Create a <see cref="T:Sedulous.RHI.FrameBuffer" /> instance.
	/// </summary>
	/// <param name="width">The with of the underlying textures.</param>
	/// <param name="height">The height of the underlying textures.</param>
	/// <param name="colorTargetPixelFormat">The pixel format of the color target.</param>
	/// <param name="depthTargetPixelFormat">The pixel format of the depth target.</param>
	/// <param name="debugName">The framebuffer textures names (Debug purposes).</param>
	/// <returns>The new framebuffer.</returns>
	public FrameBuffer CreateFrameBuffer(uint32 width, uint32 height, PixelFormat colorTargetPixelFormat = PixelFormat.R8G8B8A8_UNorm, PixelFormat depthTargetPixelFormat = PixelFormat.D24_UNorm_S8_UInt, String debugName = null)
	{
		TextureDescription textureDescription = default(TextureDescription);
		textureDescription.Format = colorTargetPixelFormat;
		textureDescription.Width = width;
		textureDescription.Height = height;
		textureDescription.Depth = 1;
		textureDescription.ArraySize = 1;
		textureDescription.Faces = 1;
		textureDescription.Flags = TextureFlags.ShaderResource | TextureFlags.RenderTarget;
		textureDescription.CpuAccess = ResourceCpuAccess.None;
		textureDescription.MipLevels = 1;
		textureDescription.Type = TextureType.Texture2D;
		textureDescription.Usage = ResourceUsage.Default;
		textureDescription.SampleCount = TextureSampleCount.None;
		TextureDescription rTColorTargetDescription = textureDescription;
		String colorName = ((debugName != null) ? (scope :: $"{debugName}_Color") : null);
		Texture rTColorTarget = CreateTexture(rTColorTargetDescription, colorName);

		textureDescription = default(TextureDescription);
		textureDescription.Format = depthTargetPixelFormat;
		textureDescription.Width = width;
		textureDescription.Height = height;
		textureDescription.Depth = 1;
		textureDescription.ArraySize = 1;
		textureDescription.Faces = 1;
		textureDescription.Flags = TextureFlags.DepthStencil;
		textureDescription.CpuAccess = ResourceCpuAccess.None;
		textureDescription.MipLevels = 1;
		textureDescription.Type = TextureType.Texture2D;
		textureDescription.Usage = ResourceUsage.Default;
		textureDescription.SampleCount = TextureSampleCount.None;
		TextureDescription rTDepthTargetDescription = textureDescription;
		String depthName = ((debugName != null) ? (scope :: $"{debugName}_Depth") : null);
		Texture rTDepthTarget = CreateTexture(rTDepthTargetDescription, depthName);
		FrameBufferAttachment depthAttachment = FrameBufferAttachment(rTDepthTarget, 0, 1);
		FrameBufferAttachmentList colorsAttachment = .(FrameBufferAttachment(rTColorTarget, 0, 1));
		return CreateFrameBuffer(depthAttachment, colorsAttachment);
	}

	/// <summary>
	/// Create a <see cref="T:Sedulous.RHI.FrameBuffer" /> instance.
	/// </summary>
	/// <param name="depthTarget">The depth <see cref="T:Sedulous.RHI.FrameBufferAttachment" /> which must have been created with <see cref="F:Sedulous.RHI.TextureFlags.DepthStencil" /> flag.</param>
	/// <param name="colorTargets">The array of color <see cref="T:Sedulous.RHI.FrameBufferAttachment" /> , all of which must have been created with <see cref="F:Sedulous.RHI.TextureFlags.RenderTarget" /> flags.</param>
	/// <param name="disposeAttachments">When this framebuffer is disposed, dispose the attachment textures too.</param>
	/// <returns>The new framebuffer.</returns>
	public FrameBuffer CreateFrameBuffer(FrameBufferAttachment? depthTarget, FrameBufferAttachmentList colorTargets, bool disposeAttachments = true)
	{
		return CreateFrameBufferInternal(depthTarget, colorTargets, disposeAttachments);
	}

	/// <summary>
	/// Create a <see cref="T:Sedulous.RHI.FrameBuffer" /> instance.
	/// </summary>
	/// <param name="depthTarget">The depth <see cref="T:Sedulous.RHI.FrameBufferAttachment" /> which must have been created with <see cref="F:Sedulous.RHI.TextureFlags.DepthStencil" /> flag.</param>
	/// <param name="colorTargets">The array of color <see cref="T:Sedulous.RHI.FrameBufferAttachment" /> , all of which must have been created with <see cref="F:Sedulous.RHI.TextureFlags.RenderTarget" /> flags.</param>
	/// <param name="disposeAttachments">When this framebuffer is disposed, dispose the attachment textures too.</param>
	/// <returns>The new framebuffer.</returns>
	[Inline]
	protected abstract FrameBuffer CreateFrameBufferInternal(FrameBufferAttachment? depthTarget, FrameBufferAttachmentList colorTargets, bool disposeAttachments);

	/// <summary>
	/// Create a new <see cref="T:Sedulous.RHI.ResourceLayout" />.
	/// </summary>
	/// <param name="description">The descriptions for all elements in this new resourceLayout.</param>
	/// <returns>A new resourceLayout object.</returns>
	public ResourceLayout CreateResourceLayout(in ResourceLayoutDescription description)
	{
		GraphicsContext.ValidationLayer?.CreateResourceLayoutValidation(description);
		return CreateResourceLayoutInternal(description);
	}

	/// <summary>
	/// Create a new <see cref="T:Sedulous.RHI.ResourceLayout" />.
	/// </summary>
	/// <param name="description">The descriptions for all elements in this new resourceLayout.</param>
	/// <returns>A new resourceLayout object.</returns>
	[Inline]
	protected abstract ResourceLayout CreateResourceLayoutInternal(in ResourceLayoutDescription description);

	/// <summary>
	/// Create a new <see cref="T:Sedulous.RHI.ResourceSet" />.
	/// </summary>
	/// <param name="description">The descriptions for all elements in this new resourceSet.</param>
	/// <returns>A new resourceSet object.</returns>
	public ResourceSet CreateResourceSet(in ResourceSetDescription description)
	{
		GraphicsContext.ValidationLayer?.CreateResourceSetValidation(description);
		return CreateResourceSetInternal(description);
	}

	/// <summary>
	/// Create a new <see cref="T:Sedulous.RHI.ResourceSet" />.
	/// </summary>
	/// <param name="description">The descriptions for all elements in this new resourceSet.</param>
	/// <returns>A new resourceSet object.</returns>
	[Inline]
	protected abstract ResourceSet CreateResourceSetInternal(in ResourceSetDescription description);
}
