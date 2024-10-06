using System;
using Sedulous.RHI.Raytracing;
using Sedulous.Foundation.Mathematics;
using System.Collections;

namespace Sedulous.RHI;

using internal Sedulous.RHI;

/// <summary>
/// A command buffer stores commands until the buffer is committed for execution by the GPU.
/// Command buffers are transient, single-use objects and do not support reuse.
/// </summary>
public abstract class CommandBuffer : IDisposable, IGetNativePointers
{
	/// <summary>
	/// Available states for a command buffer.
	/// </summary>
	public enum CommandBufferState
	{
		/// <summary>
		/// Before Begin has been called or after the reset method has been called.
		/// </summary>
		Initial,
		/// <summary>
		/// Between Begin and End, the command buffer is in a state where it can record commands.
		/// </summary>
		Recording,
		/// <summary>
		/// After End, the command buffer is in a state where it has finished recording commands and can be committed.
		/// </summary>
		Executable,
		/// <summary>
		/// After the commit, the command buffer is in a state where it is waiting to be executed by the command queue.
		/// </summary>
		Commited
	}

	/// <summary>
	/// Indicates whether in a render pass or false in other cases.
	/// </summary>
	protected bool InRenderPass;

	private GraphicsPipelineState cachedGraphicsPipeline;

	private ComputePipelineState cachedComputePipeline;

	/// <summary>
	/// Gets or sets the state of this command buffer.
	/// </summary>
	public CommandBufferState State { get; protected set; }

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debugging tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <inheritdoc />
	public virtual void GetAvailablePointerKeys(List<String> pointerKeys){}

	/// <summary>
	/// Gets the generic graphics context.
	/// </summary>
	protected abstract GraphicsContext GraphicsContext { get; }

	/// <summary>
	/// Sets the initial state for this command buffer.
	/// This function must be called before other graphics commands can be issued.
	/// </summary>
	public abstract void Begin();

	/// <summary>
	/// Completes the command buffer.
	/// </summary>
	public void End()
	{
		ClearCache();
		EndInternal();
	}

	/// <summary>
	/// Finalizes the command buffer.
	/// </summary>
	protected abstract void EndInternal();

	/// <summary>
	/// Resets the command buffer to the initial state.
	/// </summary>
	public abstract void Reset();

	/// <summary>
	/// Sets an array of vertex buffers to the input-assembler stage.
	/// </summary>
	/// <param name="buffers">The array of vertex buffers being bound.</param>
	public void SetVertexBuffers(Buffer[] buffers)
	{
		SetVertexBuffers(buffers, null);
	}

	/// <summary>
	/// Sets a buffer to the input-assembler stage.
	/// </summary>
	/// <param name="slot">The buffer slot.</param>
	/// <param name="buffer">The buffer being bound.</param>
	/// <param name="offset">Offset (in bytes) from the start of the buffer to the first vertex to use.</param>
	public void SetVertexBuffer(uint32 slot, Buffer buffer, uint32 offset)
	{
		GraphicsContext.ValidationLayer?.SetVertexBuffer(InRenderPass);
		SetVertexBufferInternal(slot, buffer, offset);
	}

	/// <summary>
	/// Sets buffers to the input-assembler stage.
	/// </summary>
	/// <param name="slot">The buffer slot.</param>
	/// <param name="buffer">The buffer being bound.</param>
	/// <param name="offset">Offset (in bytes) from the start of the buffer to the first vertex to use.</param>
	protected abstract void SetVertexBufferInternal(uint32 slot, Buffer buffer, uint32 offset);

	/// <summary>
	/// Sets an array of buffers to the input-assembler stage.
	/// </summary>
	/// <param name="buffers">The array of vertex buffers being bound.</param>
	/// <param name="offsets">Offsets (in bytes) from the start of each vertex buffer to the first vertex to use.</param>
	public void SetVertexBuffers(Buffer[] buffers, int32[] offsets)
	{
		GraphicsContext.ValidationLayer?.SetVertexBuffers(InRenderPass, buffers, offsets);
		SetVertexBuffersInternal(buffers, offsets);
	}

	/// <summary>
	/// Sets an array of buffers to the input-assembler stage.
	/// </summary>
	/// <param name="buffers">The array of vertex buffers being bound.</param>
	/// <param name="offsets">Offsets (in bytes) from the start of each vertex buffer to the first vertex to use.</param>
	protected abstract void SetVertexBuffersInternal(Buffer[] buffers, int32[] offsets);

	/// <summary>
	/// Sets an array of index buffers to the input-assembler stage.
	/// </summary>
	/// <param name="buffer">The buffer being bound.</param>
	/// <param name="format">Index data type (default UInt16).</param>
	/// <param name="offset">Offset (in bytes) from the start of the index buffer to the first index to use.</param>
	public void SetIndexBuffer(Buffer buffer, IndexFormat format = IndexFormat.UInt16, uint32 offset = 0)
	{
		GraphicsContext.ValidationLayer?.SetIndexBuffer(InRenderPass);
		SetIndexBufferInternal(buffer, format, offset);
	}

	/// <summary>
	/// Sets an array of index buffers to the input-assembler stage.
	/// </summary>
	/// <param name="buffer">The buffer being bound.</param>
	/// <param name="format">Indices data type (default UInt16).</param>
	/// <param name="offset">Offset (in bytes) from the start of the index buffer to the first index to use.</param>
	protected abstract void SetIndexBufferInternal(Buffer buffer, IndexFormat format = IndexFormat.UInt16, uint32 offset = 0);

	/// <summary>
	/// Sets a scissor rectangle in a specific slot.
	/// </summary>
	/// <param name="rectangles">The array of scissor rectangles.</param>
	public abstract void SetScissorRectangles(Rectangle[] rectangles);

	/// <summary>
	/// Sets a viewport in a specific slot.
	/// </summary>
	/// <param name="viewports">An array of viewports.</param>
	public abstract void SetViewports(Viewport[] viewports);

	/// <summary>
	/// Sets a resource barrier for a texture.
	/// </summary>
	/// <param name="buffer">The texture buffer.</param>
	public abstract void ResourceBarrierUnorderedAccessView(Buffer buffer);

	/// <summary>
	/// Sets a resource barrier for a texture.
	/// </summary>
	/// <param name="texture">The texture.</param>
	public abstract void ResourceBarrierUnorderedAccessView(Texture texture);

	/// <summary>
	/// Sets the graphics pipeline state object for this command buffer.
	/// </summary>
	/// <param name="pipeline">The graphics pipeline state description.</param>
	public void SetGraphicsPipelineState(GraphicsPipelineState pipeline)
	{
		GraphicsContext.ValidationLayer?.SetGraphicsPipelineState(InRenderPass);
		if (cachedGraphicsPipeline != pipeline)
		{
			cachedGraphicsPipeline = pipeline;
			SetGraphicsPipelineStateInternal(pipeline);
		}
	}

	/// <summary>
	/// Sets the graphics pipeline state object for this command buffer.
	/// </summary>
	/// <param name="pipeline">The graphics pipeline state description.</param>
	protected abstract void SetGraphicsPipelineStateInternal(GraphicsPipelineState pipeline);

	/// <summary>
	/// Sets the compute pipeline state object for this command buffer.
	/// </summary>
	/// <param name="pipeline">The compute pipeline state description.</param>
	public void SetComputePipelineState(ComputePipelineState pipeline)
	{
		if (cachedComputePipeline != pipeline)
		{
			cachedComputePipeline = pipeline;
			SetComputePipelineStateInternal(pipeline);
		}
	}

	/// <summary>
	/// Sets the compute pipeline state object for this command buffer.
	/// </summary>
	/// <param name="pipeline">The compute pipeline state description.</param>
	protected abstract void SetComputePipelineStateInternal(ComputePipelineState pipeline);

	/// <summary>
	/// Sets the raytracing pipeline state object for this command buffer.
	/// </summary>
	/// <param name="pipeline">The raytracing pipeline state description.</param>
	public void SetRaytracingPipelineState(RaytracingPipelineState pipeline)
	{
		SetRaytracingPipelineStateInternal(pipeline);
	}

	/// <summary>
	/// Sets the ray tracing pipeline state object for this command buffer.
	/// </summary>
	/// <param name="pipeline">The ray tracing pipeline state description.</param>
	protected abstract void SetRaytracingPipelineStateInternal(RaytracingPipelineState pipeline);

	/// <summary>
	/// Sets the active <see cref="T:Sedulous.RHI.ResourceSet" /> for the given index.
	/// </summary>
	/// <param name="resourceSet">The new <see cref="T:Sedulous.RHI.ResourceSet" />.</param>
	/// <param name="index">The resourceSet index.</param>
	/// <param name="constantBufferOffsets">Array of values specifying the constant buffer offsets.</param>
	public void SetResourceSet(ResourceSet resourceSet, uint32 index = 0, uint32[] constantBufferOffsets = null)
	{
		GraphicsContext.ValidationLayer?.SetResourceSet(InRenderPass, cachedComputePipeline != null);
		SetResourceSetInternal(resourceSet, index, constantBufferOffsets);
	}

	/// <summary>
	/// Sets the active <see cref="T:Sedulous.RHI.ResourceSet" /> for the given index.
	/// </summary>
	/// <param name="resourceSet">The new <see cref="T:Sedulous.RHI.ResourceSet" />.</param>
	/// <param name="index">The resource set index.</param>
	/// <param name="constantBufferOffsets">Array of values specifying the constant buffer offsets.</param>
	protected abstract void SetResourceSetInternal(ResourceSet resourceSet, uint32 index = 0, uint32[] constantBufferOffsets = null);

	/// <summary>
	/// Begin a render pass.
	/// </summary>
	/// <param name="description">The RenderPass description <see cref="T:Sedulous.RHI.RenderPassDescription" />.</param>
	public void BeginRenderPass(in RenderPassDescription description)
	{
		InRenderPass = true;
		BeginRenderPassInternal(description);
	}

	/// <summary>
	/// Begins a render pass.
	/// </summary>
	/// <param name="description">The render pass description <see cref="T:Sedulous.RHI.RenderPassDescription" />.</param>
	protected abstract void BeginRenderPassInternal(in RenderPassDescription description);

	/// <summary>
	/// Ends a render pass.
	/// </summary>
	public void EndRenderPass()
	{
		InRenderPass = false;
		EndRenderPassInternal();
	}

	/// <summary>
	/// Ends a render pass.
	/// </summary>
	protected abstract void EndRenderPassInternal();

	/// <summary>
	/// Fills the buffer with a data array.
	/// </summary>
	/// <typeparam name="T">The data type.</typeparam>
	/// <param name="buffer">The buffer instance.</param>
	/// <param name="data">The data array.</param>
	/// <param name="destinationOffsetInBytes">The destination offset in bytes.</param>
	public void UpdateBufferData<T>(Buffer buffer, T[] data, uint32 destinationOffsetInBytes = 0) where T : struct
	{
		UpdateBufferData(buffer, data, (data != null) ? ((uint32)data.Count) : 0, destinationOffsetInBytes);
	}

	/// <summary>
	/// Fills the buffer with a data array.
	/// </summary>
	/// <typeparam name="T">The data type.</typeparam>
	/// <param name="buffer">The buffer instance.</param>
	/// <param name="data">The data array.</param>
	/// <param name="count">The number of elements.</param>
	/// <param name="destinationOffsetInBytes">The destination offset in bytes.</param>
	public void UpdateBufferData<T>(Buffer buffer, T[] data, uint32 count, uint32 destinationOffsetInBytes = 0) where T : struct
	{
		uint32 dataSizeInBytes = count * (uint32)sizeof(T);
		UpdateBufferData(buffer, data.Ptr, dataSizeInBytes, destinationOffsetInBytes);
	}

	/// <summary>
	/// Fills the buffer with a data array.
	/// </summary>
	/// <typeparam name="T">The data type.</typeparam>
	/// <param name="buffer">The buffer instance.</param>
	/// <param name="data">The data array.</param>
	/// <param name="destinationOffsetInBytes">The destination offset in bytes.</param>
	public void UpdateBufferData<T>(Buffer buffer, ref T data, uint32 destinationOffsetInBytes = 0) where T : struct
	{
		uint32 sizeInBytes = (uint32)sizeof(T);
		UpdateBufferData(buffer, &data, sizeInBytes, destinationOffsetInBytes);
	}

	/// <summary>
	/// Fills the buffer from a pointer.
	/// </summary>
	/// <param name="buffer">Buffer instance.</param>
	/// <param name="source">The data pointer.</param>
	/// <param name="sourceSizeInBytes">The size in bytes.</param>
	/// <param name="destinationOffsetInBytes">The offset in bytes.</param>
	public void UpdateBufferData(Buffer buffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0)
	{
		if (buffer != null)
		{
			GraphicsContext.ValidationLayer?.UpdateBufferData(InRenderPass, sourceSizeInBytes);
			buffer.Touch();
			UpdateBufferDataInternal(buffer, source, sourceSizeInBytes, destinationOffsetInBytes);
		}
	}

	/// <summary>
	/// Fills the buffer from a pointer.
	/// </summary>
	/// <param name="buffer">Buffer instance.</param>
	/// <param name="source">The data pointer.</param>
	/// <param name="sourceSizeInBytes">The size in bytes.</param>
	/// <param name="destinationOffsetInBytes">The offset in bytes.</param>
	protected abstract void UpdateBufferDataInternal(Buffer buffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0);

	/// <summary>
	/// Copies this buffer to the destination buffer.
	/// </summary>
	/// <param name="origin">The origin buffer.</param>
	/// <param name="destination">The destination buffer.</param>
	/// <param name="sizeInBytes">The data size in bytes to copy.</param>
	/// <param name="sourceOffset">The source buffer offset in bytes.</param>
	/// <param name="destinationOffset">The destination buffer offset in bytes.</param>
	public void CopyBufferDataTo(Buffer origin, Buffer destination, uint32 sizeInBytes, uint32 sourceOffset = 0, uint32 destinationOffset = 0)
	{
		GraphicsContext.ValidationLayer?.CopyBufferDataTo(InRenderPass, sizeInBytes);
		destination.Touch();
		CopyBufferDataToInternal(origin, destination, sizeInBytes, sourceOffset, destinationOffset);
	}

	/// <summary>
	/// Copies this buffer to the destination buffer.
	/// </summary>
	/// <param name="origin">The origin buffer.</param>
	/// <param name="destination">The destination buffer.</param>
	/// <param name="sizeInBytes">The data size in bytes to copy.</param>
	/// <param name="sourceOffset">The source buffer offset in bytes.</param>
	/// <param name="destinationOffset">The destination buffer offset in bytes.</param>
	protected abstract void CopyBufferDataToInternal(Buffer origin, Buffer destination, uint32 sizeInBytes, uint32 sourceOffset = 0, uint32 destinationOffset = 0);

	/// <summary>
	/// Copies all subresources from this texture to another texture.
	/// </summary>
	/// <param name="source">The source <see cref="T:Sedulous.RHI.Texture"></see>.</param>
	/// <param name="destination">The destination <see cref="T:Sedulous.RHI.Texture"></see> into which data is copied.</param>
	public void CopyTextureDataTo(Texture source, Texture destination)
	{
		for (uint32 level = 0; level < source.Description.MipLevels; level++)
		{
			Helpers.GetMipDimensions(source.Description, level, var mipWidth, var mipHeight, var mipDepth);
			CopyTextureDataTo(source, 0, 0, 0, level, 0, destination, 0, 0, 0, level, 0, mipWidth, mipHeight, mipDepth, source.Description.ArraySize * source.Description.Faces);
		}
	}

	/// <summary>
	/// Copies one subresource from this texture to another texture.
	/// </summary>
	/// <param name="source">The source <see cref="T:Sedulous.RHI.Texture"></see>.</param>
	/// <param name="destination">The destination <see cref="T:Sedulous.RHI.Texture"></see> into which data is copied.</param>
	/// <param name="mipLevel">The mip level to copy.</param>
	/// <param name="arrayLayer">The array layer to copy.</param>
	public void CopyTextureDataTo(Texture source, Texture destination, uint32 mipLevel, uint32 arrayLayer)
	{
		Helpers.GetMipDimensions(source.Description, mipLevel, var mipWidth, var mipHeight, var mipDepth);
		CopyTextureDataTo(source, 0, 0, 0, mipLevel, arrayLayer, destination, 0, 0, 0, mipLevel, arrayLayer, mipWidth, mipHeight, mipDepth, 1);
	}

	/// <summary>
	/// Copies a region from this texture to another texture.
	/// </summary>
	/// <param name="source">The source <see cref="T:Sedulous.RHI.Texture"></see>.</param>
	/// <param name="sourceX">The x-coordinate of the upper left corner of the source region.</param>
	/// <param name="sourceY">The y-coordinate of the upper left corner of the source region.</param>
	/// <param name="sourceZ">The z-coordinate of the upper left corner of the source region.</param>
	/// <param name="sourceMipLevel">The mip level to copy from the source texture.</param>
	/// <param name="sourceBasedArrayLayer">The starting array layer to copy from the source texture.</param>
	/// <param name="destination">The destination <see cref="T:Sedulous.RHI.Texture"></see> into which data is copied.</param>
	/// <param name="destinationX">The x-coordinate of the upper left corner of the destination region.</param>
	/// <param name="destinationY">The y-coordinate of the upper left corner of the destination region.</param>
	/// <param name="destinationZ">The z-coordinate of the upper left corner of the destination region.</param>
	/// <param name="destinationMipLevel">The mip level to copy the data into.</param>
	/// <param name="destinationBasedArrayLayer">The starting array layer to copy data into.</param>
	/// <param name="width">The width in texels of the copy region.</param>
	/// <param name="height">The height in texels of the copy region.</param>
	/// <param name="depth">The depth in texels of the copy region.</param>
	/// <param name="layerCount">The number of array layers to copy.</param>
	public void CopyTextureDataTo(Texture source, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBasedArrayLayer, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArrayLayer, uint32 width, uint32 height, uint32 depth, uint32 layerCount)
	{
		GraphicsContext.ValidationLayer?.CopyTextureDataTo(InRenderPass);
		CopyTextureDataToInternal(source, sourceX, sourceY, sourceZ, sourceMipLevel, sourceBasedArrayLayer, destination, destinationX, destinationY, destinationZ, destinationMipLevel, destinationBasedArrayLayer, width, height, depth, layerCount);
	}

	/// <summary>
	/// Copies a region from this texture to another texture.
	/// </summary>
	/// <param name="source">The source <see cref="T:Sedulous.RHI.Texture"></see>.</param>
	/// <param name="sourceX">The x-coordinate of the upper left corner of the source region.</param>
	/// <param name="sourceY">The y-coordinate of the upper left corner of the source region.</param>
	/// <param name="sourceZ">The z-coordinate of the upper left corner of the source region.</param>
	/// <param name="sourceMipLevel">The mip level to copy from the source texture.</param>
	/// <param name="sourceBasedArrayLayer">The starting array layer to copy from the source texture.</param>
	/// <param name="destination">The destination <see cref="T:Sedulous.RHI.Texture"></see> into which data is copied.</param>
	/// <param name="destinationX">The x-coordinate of the upper left corner of the destination region.</param>
	/// <param name="destinationY">The y-coordinate of the upper left corner of the destination region.</param>
	/// <param name="destinationZ">The z-coordinate of the upper left corner of the destination region.</param>
	/// <param name="destinationMipLevel">The mip level to copy the data into.</param>
	/// <param name="destinationBasedArrayLayer">The starting array layer to copy data into.</param>
	/// <param name="width">The width in texels of the copy region.</param>
	/// <param name="height">The height in texels of the copy region.</param>
	/// <param name="depth">The depth in texels of the copy region.</param>
	/// <param name="layerCount">The number of array layers to copy.</param>
	protected abstract void CopyTextureDataToInternal(Texture source, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBasedArrayLayer, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArrayLayer, uint32 width, uint32 height, uint32 depth, uint32 layerCount);

	/// <summary>
	/// Copies all subresources from this texture to another texture with format conversion and prepares it for presentation in a swapchain.
	/// </summary>
	/// <param name="source">The source <see cref="T:Sedulous.RHI.Texture"></see>.</param>
	/// <param name="destination">The destination <see cref="T:Sedulous.RHI.Texture"></see> into which data is copied.</param>
	public void Blit(Texture source, Texture destination)
	{
		Blit(source, 0, 0, 0, 0, 0, destination, 0, 0, 0, 0, 0, source.Description.ArraySize * source.Description.Faces);
	}

	/// <summary>
	/// Copies all subresources from this texture to another texture with format conversion, preparing it to present in the swapchain.
	/// </summary>
	/// <param name="source">The source <see cref="T:Sedulous.RHI.Texture"></see>.</param>
	/// <param name="sourceX">The x-coordinate of the upper-left corner of the source region.</param>
	/// <param name="sourceY">The y-coordinate of the upper-left corner of the source region.</param>
	/// <param name="sourceZ">The z-coordinate of the upper-left corner of the source region.</param>
	/// <param name="sourceMipLevel">The mip level to copy from the source texture.</param>
	/// <param name="sourceBasedArrayLayer">The starting array layer to copy from the source texture.</param>
	/// <param name="destination">The destination <see cref="T:Sedulous.RHI.Texture"></see> into which data is copied.</param>
	/// <param name="destinationX">The x-coordinate of the upper-left corner of the destination region.</param>
	/// <param name="destinationY">The y-coordinate of the upper-left corner of the destination region.</param>
	/// <param name="destinationZ">The z-coordinate of the upper-left corner of the destination region.</param>
	/// <param name="destinationMipLevel">The mip level to copy the data into.</param>
	/// <param name="destinationBasedArrayLayer">The starting array layer to copy data into.</param>
	/// <param name="layerCount">The number of array layers to copy.</param>
	protected abstract void Blit(Texture source, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBasedArrayLayer, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArrayLayer, uint32 layerCount);

	/// <summary>
	/// Draws non-indexed, non-instanced primitives.
	/// </summary>
	/// <param name="vertexCount">The number of vertices to draw.</param>
	/// <param name="startVertexLocation">The index of the first vertex, which is usually an offset in a vertex buffer.</param>
	public abstract void Draw(uint32 vertexCount, uint32 startVertexLocation = 0);

	/// <summary>
	/// Draws non-indexed, instanced primitives.
	/// </summary>
	/// <param name="vertexCountPerInstance">Number of vertices to draw.</param>
	/// <param name="instanceCount">Number of instances to draw.</param>
	/// <param name="startVertexLocation">Index of the first vertex.</param>
	/// <param name="startInstanceLocation">A value added to each index before reading per-instance data from a vertex buffer.</param>
	public abstract void DrawInstanced(uint32 vertexCountPerInstance, uint32 instanceCount, uint32 startVertexLocation = 0, uint32 startInstanceLocation = 0);

	/// <summary>
	/// Draws instanced, GPU-generated primitives.
	/// </summary>
	/// <param name="argBuffer">A buffer containing the GPU-generated primitives.</param>
	/// <param name="offset">The offset to the start of the GPU-generated primitives.</param>
	/// <param name="drawCount">The number of draws to execute, which can be zero.</param>
	/// <param name="stride">The byte stride between successive sets of draw parameters.</param>
	public abstract void DrawInstancedIndirect(Buffer argBuffer, uint32 offset, uint32 drawCount, uint32 stride);

	/// <summary>
	/// Draws indexed, non-instanced primitives.
	/// </summary>
	/// <param name="indexCount">The number of indices to draw.</param>
	/// <param name="startIndexLocation">The location of the first index read by the GPU from the index buffer.</param>
	/// <param name="baseVertexLocation">A value added to each index before reading a vertex from the vertex buffer.</param>
	public abstract void DrawIndexed(uint32 indexCount, uint32 startIndexLocation = 0, uint32 baseVertexLocation = 0);

	/// <summary>
	/// Draws indexed, instanced primitives.
	/// </summary>
	/// <param name="indexCountPerInstance">The number of indices read from the index buffer for each instance.</param>
	/// <param name="instanceCount">The number of instances to draw.</param>
	/// <param name="startIndexLocation">The location of the first index read by the GPU from the index buffer.</param>
	/// <param name="baseVertexLocation">A value added to each index before reading a vertex from the vertex buffer.</param>
	/// <param name="startInstanceLocation">A value added to each index before reading per-instance data from a vertex buffer.</param>
	public abstract void DrawIndexedInstanced(uint32 indexCountPerInstance, uint32 instanceCount, uint32 startIndexLocation = 0, uint32 baseVertexLocation = 0, uint32 startInstanceLocation = 0);

	/// <summary>
	/// Draw indexed, instanced, GPU-generated primitives.
	/// </summary>
	/// <param name="argBuffer">A buffer containing the GPU-generated primitives.</param>
	/// <param name="offset">Offset to the start of the GPU-generated primitives.</param>
	/// <param name="drawCount">The number of draws to execute, which can be zero.</param>
	/// <param name="stride">The byte stride between successive sets of draw parameters.</param>
	public abstract void DrawIndexedInstancedIndirect(Buffer argBuffer, uint32 offset, uint32 drawCount, uint32 stride);

	/// <summary>
	/// Execute commands in a compute shader from a thread group.
	/// </summary>
	/// <param name="groupCountX">
	/// The number of groups dispatched in the x direction. groupSizeX must be
	/// less than or equal to 65535.
	/// </param>
	/// <param name="groupCountY">
	/// The number of groups dispatched in the y direction. groupSizeY must be
	/// less than or equal to 65535.
	/// </param>
	/// <param name="groupCountZ">
	/// The number of groups dispatched in the z direction. groupSizeZ must be
	/// less than or equal to 65535.
	/// </param>
	/// <remarks>
	/// You call the Dispatch method to execute commands in a compute shader. A compute
	/// shader can be run on many threads in parallel within a thread group. Index a
	/// particular thread within a thread group using a 3D vector given by (x, y, z).
	/// </remarks>
	public abstract void Dispatch(uint32 groupCountX, uint32 groupCountY, uint32 groupCountZ);

	/// <summary>
	/// Executes commands in a compute shader to solve a 1D problem.
	/// </summary>
	/// <param name="threadCountX">The size of the problem.</param>
	/// <param name="groupSizeX">The group size, 64 by default.</param>
	public void Dispatch1D(uint32 threadCountX, uint32 groupSizeX = 64)
	{
		Dispatch(MathUtil.DivideByMultiple(threadCountX, groupSizeX), 1, 1);
	}

	/// <summary>
	/// Executes commands in a compute shader to solve a 2D problem.
	/// </summary>
	/// <param name="threadCountX">The x-size of the problem.</param>
	/// <param name="threadCountY">The y-size of the problem.</param>
	/// <param name="groupSizeX">The group size x, 8 by default.</param>
	/// <param name="groupSizeY">The group size y, 8 by default.</param>
	public void Dispatch2D(uint32 threadCountX, uint32 threadCountY, uint32 groupSizeX = 8, uint32 groupSizeY = 8)
	{
		Dispatch(MathUtil.DivideByMultiple(threadCountX, groupSizeX), MathUtil.DivideByMultiple(threadCountY, groupSizeY), 1);
	}

	/// <summary>
	/// Executes commands in a compute shader to solve a 3D problem.
	/// </summary>
	/// <param name="threadCountX">The x size of the problem.</param>
	/// <param name="threadCountY">The y size of the problem.</param>
	/// <param name="threadCountZ">The z size of the problem.</param>
	/// <param name="groupSizeX">The group size in the x dimension.</param>
	/// <param name="groupSizeY">The group size in the y dimension.</param>
	/// <param name="groupSizeZ">The group size in the z dimension.</param>
	public void Dispatch3D(uint32 threadCountX, uint32 threadCountY, uint32 threadCountZ, uint32 groupSizeX, uint32 groupSizeY, uint32 groupSizeZ)
	{
		Dispatch(MathUtil.DivideByMultiple(threadCountX, groupSizeX), MathUtil.DivideByMultiple(threadCountY, groupSizeY), MathUtil.DivideByMultiple(threadCountZ, groupSizeZ));
	}

	/// <summary>
	/// Commits this command buffer to the command queue, waiting to be executed on the GPU after <see cref="M:Sedulous.RHI.CommandQueue.Submit" />.
	/// </summary>
	public abstract void Commit();

	/// <summary>
	/// Executes a command list over one or more thread groups.
	/// </summary>
	/// <param name="argBuffer">A buffer that must be loaded with data matching the argument list for <see cref="M:Sedulous.RHI.CommandBuffer.Dispatch(System.UInt32,System.UInt32,System.UInt32)" />.</param>
	/// <param name="offset">A byte-aligned offset between the start of the buffer and the arguments.</param>
	public abstract void DispatchIndirect(Buffer argBuffer, uint32 offset);

	/// <summary>
	/// Generates mipmaps for the given <see cref="T:Sedulous.RHI.Texture" />. The largest mipmap is used to generate all the lower mipmap
	/// levels contained in the Texture.
	/// </summary>
	/// <param name="texture">The <see cref="T:Sedulous.RHI.Texture" /> to generate mipmaps for. This Texture must have been created with
	/// <see cref="T:Sedulous.RHI.TextureFlags" />.<see cref="F:Sedulous.RHI.TextureFlags.GenerateMipmaps" />.</param>
	public abstract void GenerateMipmaps(Texture texture);

	/// <summary>
	/// Marks the beginning of a section of event code. This allows subsequent commands to be
	/// categorized and filtered when viewed in external debugging tools.
	/// </summary>
	/// <remarks>
	/// Call the EndDebugMarker method to mark the end of the section of event code.
	/// BeginDebugMarker has no effect if the calling application is not running under an enabled profiling tool.
	/// </remarks>
	/// <param name="label">String that contains the name of the event.</param>
	public abstract void BeginDebugMarker(String label);

	/// <summary>
	/// Marks the end of a section of event code.
	/// </summary>
	/// <remarks>
	/// EndDebugMarker has no effect if the calling application is not running under an enabled profiling tool.
	/// </remarks>
	public abstract void EndDebugMarker();

	/// <summary>
	/// Marks a single point of execution in the code. This is used by graphics debuggers to identify
	/// points of interest in a command stream.
	/// </summary>
	/// <remarks>
	/// InsertDebugMarker has no effect if the calling application is not running under an enabled profiling tool.
	/// </remarks>
	/// <param name="label">String that contains the name of the event.</param>
	public abstract void InsertDebugMarker(String label);

	/// <summary>
	/// Writes a device timestamp into a query heap.
	/// </summary>
	/// <param name="heap">Specifies the query heap.</param>
	/// <param name="index">The query index.</param>
	/// <remarks>This method works only with timestamp query heap type.</remarks>
	public abstract void WriteTimestamp(QueryHeap heap, uint32 index);

	/// <summary>
	/// Begins a GPU query.
	/// </summary>
	/// <param name="heap">Specifies the query heap containing the query.</param>
	/// <param name="index">The query index.</param>
	/// <remarks>This method works only with occlusion and binaryOcclusion query heap types.</remarks>
	public abstract void BeginQuery(QueryHeap heap, uint32 index);

	/// <summary>
	/// Ends a GPU query.
	/// </summary>
	/// <param name="heap">Specifies the query heap containing the query.</param>
	/// <param name="index">The query index.</param>
	/// <remarks>This method works only with occlusion and binaryOcclusion query heap types.</remarks>
	public abstract void EndQuery(QueryHeap heap, uint32 index);

	/// <summary>
	/// Performs a bottom level acceleration structure build on the GPU.
	/// </summary>
	/// <param name="blas">Bottom level acceleration structure description.</param>
	/// <returns>Bottom level acceleration structure.</returns>
	public abstract BottomLevelAS BuildRaytracingAccelerationStructure(BottomLevelASDescription blas);

	/// <summary>
	/// Performs a top-level acceleration structure build on the GPU.
	/// </summary>
	/// <param name="tlas">Top-level acceleration structure description.</param>
	/// <returns>Top-level Acceleration Structure.</returns>
	public abstract TopLevelAS BuildRaytracingAccelerationStructure(TopLevelASDescription tlas);

	/// <summary>
	/// Refit a top-level acceleration structure built on the GPU.
	/// </summary>
	/// <param name="tlas">Top-level acceleration structure.</param>
	/// <param name="newDescription">New top-level description.</param>
	public abstract void UpdateRaytracingAccelerationStructure(ref TopLevelAS tlas, TopLevelASDescription newDescription);

	/// <summary>
	/// Launches threads of a ray generation shader. See Initiating Raytracing for an overview. Can be called from
	/// graphics or compute command lists and bundles.
	/// </summary>
	/// <param name="description">Dispatch rays description.</param>
	public abstract void DispatchRays(DispatchRaysDescription description);

	/// <summary>
	/// Performs tasks associated with freeing, releasing, or resetting unmanaged resources defined by the application.
	/// </summary>
	public abstract void Dispose();

	/// <inheritdoc />
	public virtual bool GetNativePointer(String pointerKey, out void* nativePointer)
	{
		nativePointer = null;
		return false;
	}

	/// <summary>
	/// Clears all cached values of this command buffer.
	/// </summary>
	protected virtual void ClearCache()
	{
		cachedGraphicsPipeline = null;
		cachedComputePipeline = null;
	}
}
