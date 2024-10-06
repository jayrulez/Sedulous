using System;
using Sedulous.RHI;
using Sedulous.RHI.Raytracing;
using Sedulous.Foundation.Mathematics;
using Win32.Foundation;
using Win32.Graphics.Direct3D12;
using Win32;

namespace Sedulous.RHI.DirectX12;

using internal Sedulous.RHI.DirectX12;
using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// This class represents a set of commands.
/// </summary>
public class DX12CommandBuffer : CommandBuffer
{
	internal ID3D12CommandAllocator* CommandAlloc;

	internal ID3D12GraphicsCommandList* CommandList;

	internal DX12GraphicsContext context;

	private bool disposed;

	private DX12CommandQueue commandQueue;

	private float[4] clearColor;

	private FrameBuffer activeFrameBuffer;

	internal DX12DescriptorTableAllocator resourceDescriptorsGPU;

	internal DX12DescriptorTableAllocator samplerDescriptorsGPU;

	private ID3D12DescriptorHeap*[] descriptorHeaps;

	private DX12GraphicsPipelineState currentGraphicsPipelineState;

	private DX12ComputePipelineState currentComputePipelineState;

	private DX12RaytracingPipelineState currentRaytracingPipelineState;

	private String name = new .() ~ delete _;

	private RECT maxSccisorSize = .(0, 0, 15360, 8640);

	/// <inheritdoc />
	protected override GraphicsContext GraphicsContext => context;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			name.Set(value);
			SetDebugName(CommandList, name);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12CommandBuffer" /> class.
	/// </summary>
	/// <param name="context">Graphics context.</param>
	/// <param name="queue">The command queue for this command buffer.</param>
	public this(DX12GraphicsContext context, DX12CommandQueue queue)
	{
		this.context = context;
		commandQueue = queue;
		D3D12_COMMAND_LIST_TYPE nativeType = queue.QueueType.ToDirectX();
		HRESULT result = this.context.DXDevice.CreateCommandAllocator(nativeType, ID3D12CommandAllocator.IID, (void**)&CommandAlloc);
		if (!SUCCEEDED(result))
		{
			this.context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
		}
		ID3D12GraphicsCommandList* cmdList = null;
		result = this.context.DXDevice.CreateCommandList(0, nativeType, CommandAlloc, null,  ID3D12GraphicsCommandList.IID, (void**)&cmdList);
		if (!SUCCEEDED(result))
		{
			this.context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
		}
		ID3D12GraphicsCommandList4* cmdList4 = cmdList.QueryInterface<ID3D12GraphicsCommandList4>();
		CommandList = ((cmdList4 != null) ? cmdList4 : cmdList);
		resourceDescriptorsGPU = new DX12DescriptorTableAllocator(this.context, D3D12_DESCRIPTOR_HEAP_TYPE.D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV, 1024);
		samplerDescriptorsGPU = new DX12DescriptorTableAllocator(this.context, D3D12_DESCRIPTOR_HEAP_TYPE.D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER, 16);
		descriptorHeaps = new ID3D12DescriptorHeap*[2] ( resourceDescriptorsGPU.GPUheap, samplerDescriptorsGPU.GPUheap );
	}

	public ~this()
	{
		delete resourceDescriptorsGPU;
		delete samplerDescriptorsGPU;
		delete descriptorHeaps;
	}

	/// <inheritdoc />
	public override void Begin()
	{
		if (base.State == CommandBufferState.Recording)
		{
			context.ValidationLayer?.Notify("DX12", "Begin cannot be called again until End has been successfully called");
		}
		CommandList.SetDescriptorHeaps((uint32)descriptorHeaps.Count, descriptorHeaps.Ptr);
		if (commandQueue.QueueType == CommandQueueType.Graphics)
		{
			CommandList.SetGraphicsRootSignature(context.DefaultGraphicsSignature);
		}
		if (commandQueue.QueueType == CommandQueueType.Compute || commandQueue.QueueType == CommandQueueType.Graphics)
		{
			CommandList.SetComputeRootSignature(context.DefaultComputeSignature);
		}
		resourceDescriptorsGPU.Reset(context.DXDevice, context.NullDescriptors);
		samplerDescriptorsGPU.Reset(context.DXDevice, context.NullDescriptors);
		base.State = CommandBufferState.Recording;
	}

	/// <inheritdoc />
	protected override void EndInternal()
	{
		if (base.State == CommandBufferState.Initial)
		{
			context.ValidationLayer?.Notify("DX12", "End was called, but Begin has not yet been called. You mush call Begin successfully before you can call End.");
		}
		if (commandQueue.QueueType == CommandQueueType.Graphics)
		{
			DX12SwapChainFrameBuffer frameBuffer = activeFrameBuffer as DX12SwapChainFrameBuffer;
			if (frameBuffer != null)
			{
				DX12Texture texture = frameBuffer.BackBufferTextures[frameBuffer.CurrentBackBufferIndex];
				ResourceBarrierTransition(texture, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COMMON);
			}
		}
		CommandList.Close();
		base.State = CommandBufferState.Executable;
	}

	/// <inheritdoc />
	public override void Reset()
	{
		base.State = CommandBufferState.Initial;
		CommandAlloc.Reset();
		CommandList.Reset(CommandAlloc, null);
		currentGraphicsPipelineState = null;
		currentComputePipelineState = null;
		activeFrameBuffer = null;
	}

	/// <inheritdoc />
	public override void Commit()
	{
		if (base.State == CommandBufferState.Commited)
		{
			context.ValidationLayer?.Notify("DX12", "This commandbuffer was already committed.");
		}
		if (base.State != CommandBufferState.Executable)
		{
			context.ValidationLayer?.Notify("DX12", "You mush record some command before to execute a commandbuffer. Call begin...end methods before to commit.");
		}
		commandQueue.CommitCommandBuffer(this);
		base.State = CommandBufferState.Commited;
	}

	internal void ResourceBarrierTransition(DX12Texture texture, D3D12_RESOURCE_STATES newState)
	{
		if (texture.NativeResourceState != newState)
		{
			CommandList.ResourceBarrierTransition(texture.NativeTexture, texture.NativeResourceState, newState);
			texture.NativeResourceState = newState;
		}
	}

	internal void ResourceBarrierTransition(DX12Buffer buffer, D3D12_RESOURCE_STATES newState)
	{
		if (buffer.nativeResourceState != newState)
		{
			CommandList.ResourceBarrierTransition(buffer.NativeBuffer, buffer.nativeResourceState, newState);
			buffer.nativeResourceState = newState;
		}
	}

	/// <summary>
	/// Sets a resource barrier for a texture.
	/// </summary>
	/// <param name="buffer">The texture's buffer.</param>
	public override void ResourceBarrierUnorderedAccessView(Sedulous.RHI.Buffer buffer)
	{
		CommandList.ResourceBarrierUnorderedAccessView((buffer as DX12Buffer).NativeBuffer);
	}

	/// <summary>
	/// Sets a resource barrier for a texture.
	/// </summary>
	/// <param name="texture">The texture.</param>
	public override void ResourceBarrierUnorderedAccessView(Texture texture)
	{
		CommandList.ResourceBarrierUnorderedAccessView((texture as DX12Texture).NativeTexture);
	}

	/// <inheritdoc />
	protected override void SetGraphicsPipelineStateInternal(GraphicsPipelineState pipeline)
	{
		DX12GraphicsPipelineState newPipelineState = pipeline as DX12GraphicsPipelineState;
		newPipelineState.Apply(CommandList, currentGraphicsPipelineState);
		currentGraphicsPipelineState = newPipelineState;
		if (!currentGraphicsPipelineState.Description.RenderStates.RasterizerState.ScissorEnable)
		{
			CommandList.RSSetScissorRects(1, &maxSccisorSize);
		}
	}

	/// <inheritdoc />
	protected override void SetComputePipelineStateInternal(ComputePipelineState pipeline)
	{
		DX12ComputePipelineState newPipelineState = pipeline as DX12ComputePipelineState;
		newPipelineState.Apply(CommandList, currentComputePipelineState);
		currentComputePipelineState = newPipelineState;
	}

	/// <inheritdoc />
	protected override void SetRaytracingPipelineStateInternal(RaytracingPipelineState pipeline)
	{
		DX12RaytracingPipelineState newPipelineState = pipeline as DX12RaytracingPipelineState;
		newPipelineState.Apply(CommandList, currentRaytracingPipelineState);
		currentRaytracingPipelineState = newPipelineState;
	}

	/// <inheritdoc />
	protected override void SetResourceSetInternal(ResourceSet resourceSet, uint32 index, uint32[] offsets)
	{
		(resourceSet as DX12ResourceSet).BindResourceSet(this, index, offsets);
	}

	/// <inheritdoc />
	protected override void SetVertexBuffersInternal(Sedulous.RHI.Buffer[] vertexBuffers, int32[] offsets)
	{
		D3D12_VERTEX_BUFFER_VIEW[] vertexBufferViews = scope .[vertexBuffers.Count];
		for (int32 i = 0; i < vertexBuffers.Count; i++)
		{
			Sedulous.RHI.Buffer vertexBuffer = vertexBuffers[i];
			int32 offset = ((offsets != null) ? offsets[i] : 0);
			vertexBufferViews[i] = .()
			{
				BufferLocation = (vertexBuffer as DX12Buffer).NativeBuffer.GetGPUVirtualAddress() + (uint64)offset,
				StrideInBytes = (uint32)currentGraphicsPipelineState.VertexStrides[i],
				SizeInBytes = (vertexBuffer.Description.SizeInBytes - (uint32)offset)
			};
		}
		CommandList.IASetVertexBuffers(0, (uint32)vertexBuffers.Count, vertexBufferViews.Ptr);
	}

	/// <inheritdoc />
	protected override void SetVertexBufferInternal(uint32 slot, Sedulous.RHI.Buffer buffer, uint32 offset = 0)
	{
		D3D12_VERTEX_BUFFER_VIEW vertexBufferView = default(D3D12_VERTEX_BUFFER_VIEW);
		vertexBufferView.BufferLocation = (buffer as DX12Buffer).NativeBuffer.GetGPUVirtualAddress() + offset;
		vertexBufferView.StrideInBytes = (uint32)currentGraphicsPipelineState.VertexStrides[slot];
		vertexBufferView.SizeInBytes = (buffer.Description.SizeInBytes - offset);
		CommandList.IASetVertexBuffers(slot, 1, &vertexBufferView);
	}

	/// <inheritdoc />
	protected override void SetIndexBufferInternal(Sedulous.RHI.Buffer buffer, IndexFormat format = IndexFormat.UInt16, uint32 offset = 0)
	{
		D3D12_INDEX_BUFFER_VIEW indexBufferView = default(D3D12_INDEX_BUFFER_VIEW);
		indexBufferView.BufferLocation = (buffer as DX12Buffer).NativeBuffer.GetGPUVirtualAddress() + offset;
		indexBufferView.Format = format.ToDirectX();
		indexBufferView.SizeInBytes = (buffer.Description.SizeInBytes - offset);
		CommandList.IASetIndexBuffer(&indexBufferView);
	}

	/// <inheritdoc />
	public override void SetScissorRectangles(Rectangle[] rectangles)
	{
		DX12GraphicsPipelineState dX12GraphicsPipelineState = currentGraphicsPipelineState;
		if (dX12GraphicsPipelineState != null && !dX12GraphicsPipelineState.Description.RenderStates.RasterizerState.ScissorEnable)
		{
			return;
		}
		if (rectangles.Count == 1)
		{
			Rectangle rectangle = rectangles[0];
			CommandList.RSSetScissorRects(1, scope .(rectangle.Left, rectangle.Top, rectangle.Right, rectangle.Bottom));
			return;
		}
		RECT[] rawRectangles = scope .[rectangles.Count];
		for (int32 i = 0; i < rectangles.Count; i++)
		{
			Rectangle rectangle = rectangles[i];
			rawRectangles[i] = .(rectangle.Left, rectangle.Top, rectangle.Right, rectangle.Bottom);
		}
		CommandList.RSSetScissorRects((uint32)rawRectangles.Count, rawRectangles.Ptr);
	}

	/// <inheritdoc />
	public override void SetViewports(Sedulous.RHI.Viewport[] viewports)
	{
		if (viewports.Count == 1)
		{
			Viewport viewport = viewports[0];
			CommandList.RSSetViewports(1, scope .(viewport.X, viewport.Y, viewport.Width, viewport.Height, viewport.MinDepth, viewport.MaxDepth));
			return;
		}
		D3D12_VIEWPORT[] nativeViewports = scope .[viewports.Count];
		for (int32 i = 0; i < viewports.Count; i++)
		{
			Viewport viewport = viewports[i];
			nativeViewports[i] = .(viewport.X, viewport.Y, viewport.Width, viewport.Height, viewport.MinDepth, viewport.MaxDepth);
		}
		CommandList.RSSetViewports((uint32)nativeViewports.Count, nativeViewports.Ptr);
	}

	/// <inheritdoc />
	protected override void UpdateBufferDataInternal(Sedulous.RHI.Buffer buffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0)
	{
		(buffer as DX12Buffer).SetData(CommandList, source, sourceSizeInBytes, destinationOffsetInBytes);
	}

	/// <inheritdoc />
	protected override void CopyBufferDataToInternal(Sedulous.RHI.Buffer buffer, Sedulous.RHI.Buffer destination, uint32 sizeInBytes, uint32 sourceOffset = 0, uint32 destinationOffset = 0)
	{
		(buffer as DX12Buffer).CopyTo(CommandList, destination, sizeInBytes, sourceOffset, destinationOffset);
	}

	/// <inheritdoc />
	protected override void CopyTextureDataToInternal(Texture source, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBasedArrayLayer, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArrayLayer, uint32 width, uint32 height, uint32 depth, uint32 layerCount)
	{
		(source as DX12Texture).CopyTo(CommandList, sourceX, sourceY, sourceZ, sourceMipLevel, sourceBasedArrayLayer, destination, destinationX, destinationY, destinationZ, destinationMipLevel, destinationBasedArrayLayer, width, height, depth, layerCount);
	}

	/// <inheritdoc />
	protected override void Blit(Texture source, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBasedArrayLayer, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArrayLayer, uint32 layerCount)
	{
		(source as DX12Texture).CopyTo(CommandList, sourceX, sourceY, sourceZ, sourceMipLevel, sourceBasedArrayLayer, destination, destinationX, destinationY, destinationZ, destinationMipLevel, destinationBasedArrayLayer, source.Description.Width, source.Description.Height, source.Description.Depth, layerCount);
	}

	/// <inheritdoc />
	public override void Dispatch(uint32 threadGroupCountX, uint32 threadGroupCountY, uint32 threadGroupCountZ)
	{
		resourceDescriptorsGPU.Submit(context.DXDevice, CommandList);
		samplerDescriptorsGPU.Submit(context.DXDevice, CommandList);
		CommandList.Dispatch(threadGroupCountX, threadGroupCountY, threadGroupCountZ);
	}

	/// <inheritdoc />
	public override void DispatchIndirect(Sedulous.RHI.Buffer argBuffer, uint32 offset)
	{
		resourceDescriptorsGPU.Submit(context.DXDevice, CommandList);
		samplerDescriptorsGPU.Submit(context.DXDevice, CommandList);
		CommandList.ExecuteIndirect(context.DispatchIndirectCommandSignature, 1, (argBuffer as DX12Buffer).NativeBuffer, offset, null, 0uL);
	}

	/// <inheritdoc />
	public override void Draw(uint32 vertexCount, uint32 startVertexLocation = 0)
	{
		resourceDescriptorsGPU.Submit(context.DXDevice, CommandList);
		samplerDescriptorsGPU.Submit(context.DXDevice, CommandList);
		CommandList.DrawInstanced(vertexCount, 1, startVertexLocation, 0);
	}

	/// <inheritdoc />
	public override void DrawIndexed(uint32 indexCount, uint32 startIndexLocation = 0, uint32 baseVertexLocation = 0)
	{
		resourceDescriptorsGPU.Submit(context.DXDevice, CommandList);
		samplerDescriptorsGPU.Submit(context.DXDevice, CommandList);
		CommandList.DrawIndexedInstanced(indexCount, 1, startIndexLocation, (int32)baseVertexLocation, 0);
	}

	/// <inheritdoc />
	public override void DrawIndexedInstanced(uint32 indexCountPerInstance, uint32 instanceCount, uint32 startIndexLocation = 0, uint32 baseVertexLocation = 0, uint32 startInstanceLocation = 0)
	{
		resourceDescriptorsGPU.Submit(context.DXDevice, CommandList);
		samplerDescriptorsGPU.Submit(context.DXDevice, CommandList);
		CommandList.DrawIndexedInstanced(indexCountPerInstance, instanceCount, startIndexLocation, (int32)baseVertexLocation, startInstanceLocation);
	}

	/// <inheritdoc />
	public override void DrawIndexedInstancedIndirect(Sedulous.RHI.Buffer argBuffer, uint32 offset, uint32 drawCount, uint32 stride)
	{
		if ((argBuffer.Description.Flags & BufferFlags.IndirectBuffer) == 0)
		{
			GraphicsContext.ValidationLayer?.Notify("DX12", "DrawIndexedInstancedIndirect must be an argBuffer with IndirectBuffer flag");
		}
		resourceDescriptorsGPU.Submit(context.DXDevice, CommandList);
		samplerDescriptorsGPU.Submit(context.DXDevice, CommandList);
		CommandList.ExecuteIndirect(context.DrawIndexedInstancedIndirectCommandSignature, drawCount, (argBuffer as DX12Buffer).NativeBuffer, offset, null, 0uL);
	}

	/// <inheritdoc />
	public override void DrawInstanced(uint32 vertexCountPerInstance, uint32 instanceCount, uint32 startVertexLocation = 0, uint32 startInstanceLocation = 0)
	{
		resourceDescriptorsGPU.Submit(context.DXDevice, CommandList);
		samplerDescriptorsGPU.Submit(context.DXDevice, CommandList);
		CommandList.DrawInstanced(vertexCountPerInstance, instanceCount, startVertexLocation, startInstanceLocation);
	}

	/// <inheritdoc />
	public override void DrawInstancedIndirect(Sedulous.RHI.Buffer argBuffer, uint32 offset, uint32 drawCount, uint32 stride)
	{
		resourceDescriptorsGPU.Submit(context.DXDevice, CommandList);
		samplerDescriptorsGPU.Submit(context.DXDevice, CommandList);
		CommandList.ExecuteIndirect(context.DrawInstancedIndirectCommandSignature, drawCount, (argBuffer as DX12Buffer).NativeBuffer, offset, null, 0uL);
	}

	/// <inheritdoc />
	public override void GenerateMipmaps(Texture texture)
	{
	}

	/// <inheritdoc />
	protected override void BeginRenderPassInternal(in RenderPassDescription description)
	{
		FrameBuffer frameBuffer = description.FrameBuffer;
		Sedulous.RHI.ClearValue clearValue = description.ClearValue;
		if (frameBuffer is DX12SwapChainFrameBuffer)
		{
			DX12SwapChainFrameBuffer nativeFrameBuffer = frameBuffer as DX12SwapChainFrameBuffer;
			DX12Texture texture = nativeFrameBuffer.BackBufferTextures[nativeFrameBuffer.CurrentBackBufferIndex];
			ResourceBarrierTransition(texture, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_RENDER_TARGET);
			ResourceBarrierTransition(nativeFrameBuffer.DepthTargetTexture, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_DEPTH_WRITE);
			CommandList.OMSetRenderTargets(1, &nativeFrameBuffer.ColorTargetViews, FALSE, &nativeFrameBuffer.DepthTargetview);
			if ((clearValue.Flags & Sedulous.RHI.ClearFlags.Target) == Sedulous.RHI.ClearFlags.Target)
			{
				Vector4 colorValue = clearValue.ColorValues[0];
				clearColor = .(colorValue.X, colorValue.Y, colorValue.Z, colorValue.W);
				CommandList.ClearRenderTargetView(nativeFrameBuffer.BackBuffers[nativeFrameBuffer.CurrentBackBufferIndex], &clearColor, 0, null);
			}
			if ((clearValue.Flags & Sedulous.RHI.ClearFlags.Depth) == Sedulous.RHI.ClearFlags.Depth || (clearValue.Flags & Sedulous.RHI.ClearFlags.Stencil) == Sedulous.RHI.ClearFlags.Stencil)
			{
				D3D12_CLEAR_FLAGS flags = (D3D12_CLEAR_FLAGS)0;
				if ((clearValue.Flags & Sedulous.RHI.ClearFlags.Depth) == Sedulous.RHI.ClearFlags.Depth)
				{
					flags |= .D3D12_CLEAR_FLAG_DEPTH;
				}
				if ((clearValue.Flags & Sedulous.RHI.ClearFlags.Stencil) == Sedulous.RHI.ClearFlags.Stencil)
				{
					flags |= .D3D12_CLEAR_FLAG_STENCIL;
				}
				CommandList.ClearDepthStencilView(nativeFrameBuffer.DepthTargetview, flags, clearValue.Depth, clearValue.Stencil, 0, null);
			}
		}
		else
		{
			DX12FrameBuffer nativeFrameBuffer = frameBuffer as DX12FrameBuffer;
			ResourceBarrierTransition(nativeFrameBuffer.DepthTargetTexture, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_DEPTH_WRITE);
			CommandList.OMSetRenderTargets((uint32)nativeFrameBuffer.ColorTargetViews.Count, nativeFrameBuffer.ColorTargetViews.Ptr, 0, &nativeFrameBuffer.DepthTargetview);
			for (int32 i = 0; i < frameBuffer.ColorTargets.Count; i++)
			{
				DX12Texture texture = nativeFrameBuffer.ColorTargetTextures[i];
				ResourceBarrierTransition(texture, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_RENDER_TARGET);
				if ((clearValue.Flags & Sedulous.RHI.ClearFlags.Target) == Sedulous.RHI.ClearFlags.Target)
				{
					Vector4 colorValue = clearValue.ColorValues[i];
					clearColor = .(colorValue.X, colorValue.Y, colorValue.Z, colorValue.W);
					CommandList.ClearRenderTargetView(nativeFrameBuffer.ColorTargetViews[i], &clearColor, 0, null);
				}
			}
			if ((clearValue.Flags & Sedulous.RHI.ClearFlags.Depth) == Sedulous.RHI.ClearFlags.Depth || (clearValue.Flags & Sedulous.RHI.ClearFlags.Stencil) == Sedulous.RHI.ClearFlags.Stencil)
			{
				D3D12_CLEAR_FLAGS flags = (D3D12_CLEAR_FLAGS)0;
				if ((clearValue.Flags & Sedulous.RHI.ClearFlags.Depth) == Sedulous.RHI.ClearFlags.Depth)
				{
					flags |= .D3D12_CLEAR_FLAG_DEPTH;
				}
				if ((clearValue.Flags & Sedulous.RHI.ClearFlags.Stencil) == Sedulous.RHI.ClearFlags.Stencil)
				{
					flags |= .D3D12_CLEAR_FLAG_STENCIL;
				}
				CommandList.ClearDepthStencilView(nativeFrameBuffer.DepthTargetview, flags, clearValue.Depth, clearValue.Stencil, 0, null);
			}
		}
		activeFrameBuffer = frameBuffer;
	}

	/// <inheritdoc />
	public override void BeginDebugMarker(String label)
	{
		if (!String.IsNullOrEmpty(label))
		{
			WinPixEventRuntime.PIXBeginEvent(CommandList, WinPixEventRuntime.PIX_COLOR_DEFAULT, label);
		}
	}

	/// <inheritdoc />
	public override void EndDebugMarker()
	{
		CommandList.EndEvent();
	}

	/// <inheritdoc />
	public override void InsertDebugMarker(String label)
	{
		if (!String.IsNullOrEmpty(label))
		{
			WinPixEventRuntime.PIXSetMarker(CommandList, WinPixEventRuntime.PIX_COLOR_DEFAULT, label);
		}
	}

	/// <inheritdoc />
	public override void WriteTimestamp(QueryHeap heap, uint32 index)
	{
		DX12QueryHeap dxQueryheap = (DX12QueryHeap)heap;
		CommandList.EndQuery(dxQueryheap.nativeQueryHeap, .D3D12_QUERY_TYPE_TIMESTAMP, (uint32)index);
		uint32 dstOffset = index * 8;
		CommandList.ResolveQueryData(dxQueryheap.nativeQueryHeap, .D3D12_QUERY_TYPE_TIMESTAMP, (uint32)index, 1, dxQueryheap.readBackBuffer.NativeBuffer, dstOffset);
	}

	/// <inheritdoc />
	public override void BeginQuery(QueryHeap heap, uint32 index)
	{
		DX12QueryHeap dxQueryheap = (DX12QueryHeap)heap;
		switch (heap.Description.Type)
		{
		case QueryType.Occlusion:
			CommandList.BeginQuery(dxQueryheap.nativeQueryHeap, .D3D12_QUERY_TYPE_OCCLUSION, (uint32)index);
			break;
		case QueryType.BinaryOcclusion:
			CommandList.BeginQuery(dxQueryheap.nativeQueryHeap, .D3D12_QUERY_TYPE_BINARY_OCCLUSION, (uint32)index);
			break;
		default: break;
		}
	}

	/// <inheritdoc />
	public override void EndQuery(QueryHeap heap, uint32 index)
	{
		DX12QueryHeap dxQueryheap = (DX12QueryHeap)heap;
		uint32 dstOffset = index * 8;
		switch (heap.Description.Type)
		{
		case QueryType.Occlusion:
			CommandList.EndQuery(dxQueryheap.nativeQueryHeap, .D3D12_QUERY_TYPE_OCCLUSION, (uint32)index);
			CommandList.ResolveQueryData(dxQueryheap.nativeQueryHeap, .D3D12_QUERY_TYPE_OCCLUSION, (uint32)index, 1, dxQueryheap.readBackBuffer.NativeBuffer, dstOffset);
			break;
		case QueryType.BinaryOcclusion:
			CommandList.EndQuery(dxQueryheap.nativeQueryHeap, .D3D12_QUERY_TYPE_BINARY_OCCLUSION, (uint32)index);
			CommandList.ResolveQueryData(dxQueryheap.nativeQueryHeap, .D3D12_QUERY_TYPE_BINARY_OCCLUSION, (uint32)index, 1, dxQueryheap.readBackBuffer.NativeBuffer, dstOffset);
			break;
		default: break;
		}
	}

	/// <inheritdoc />
	public override BottomLevelAS BuildRaytracingAccelerationStructure(BottomLevelASDescription description)
	{
		DX12BottomLevelAS blas = new DX12BottomLevelAS(context, description);
		((ID3D12GraphicsCommandList4*)CommandList).BuildRaytracingAccelerationStructure(&blas.AccelerationStructureDescription, 0, null);
		D3D12_RESOURCE_BARRIER uavBarrier = D3D12_RESOURCE_BARRIER(.(blas.ResultBuffer));
		CommandList.ResourceBarrier(1, &uavBarrier);
		return blas;
	}

	/// <inheritdoc />
	public override TopLevelAS BuildRaytracingAccelerationStructure(TopLevelASDescription description)
	{
		DX12TopLevelAS tlas = new DX12TopLevelAS(context, description);
		((ID3D12GraphicsCommandList4*)CommandList).BuildRaytracingAccelerationStructure(&tlas.AccelerationStructureDescription, 0, null);
		D3D12_RESOURCE_BARRIER  uavBarrier = D3D12_RESOURCE_BARRIER (.(tlas.ResultBuffer));
		CommandList.ResourceBarrier(1, &uavBarrier);
		return tlas;
	}

	/// <inheritdoc />
	public override void UpdateRaytracingAccelerationStructure(ref TopLevelAS tlas, TopLevelASDescription newDescription)
	{
		DX12TopLevelAS nativeTopLevelAS = (DX12TopLevelAS)tlas;
		nativeTopLevelAS.UpdateAccelerationStructure(newDescription);
		((ID3D12GraphicsCommandList4*)CommandList).BuildRaytracingAccelerationStructure(&nativeTopLevelAS.AccelerationStructureDescription, 0, null);
		D3D12_RESOURCE_BARRIER  uavBarrier = D3D12_RESOURCE_BARRIER (.(nativeTopLevelAS.ResultBuffer));
		CommandList.ResourceBarrier(1, &uavBarrier);
	}

	/// <inheritdoc />
	public override void DispatchRays(Sedulous.RHI.Raytracing.DispatchRaysDescription description)
	{
		resourceDescriptorsGPU.Submit(context.DXDevice, CommandList);
		samplerDescriptorsGPU.Submit(context.DXDevice, CommandList);
		DX12ShaderTable shaderBindingTable = currentRaytracingPipelineState.shaderBindingTable;
		D3D12_DISPATCH_RAYS_DESC dispatchRaysDescription = default(D3D12_DISPATCH_RAYS_DESC);
		dispatchRaysDescription.Width = (uint32)description.Width;
		dispatchRaysDescription.Height = (uint32)description.Height;
		dispatchRaysDescription.Depth = (uint32)description.Depth;
		D3D12_DISPATCH_RAYS_DESC nativeDescription = dispatchRaysDescription;
		nativeDescription.RayGenerationShaderRecord = .()
		{
			StartAddress = shaderBindingTable.GetRayGenStartAddress(),
			SizeInBytes = shaderBindingTable.GetRayGenSize()
		};
		nativeDescription.MissShaderTable = .()
		{
			StartAddress = shaderBindingTable.GetMissStartAddress(),
			StrideInBytes = shaderBindingTable.GetMissStride(),
			SizeInBytes = shaderBindingTable.GetMissSize()
		};
		nativeDescription.HitGroupTable = .()
		{
			StartAddress = shaderBindingTable.GetHitGroupStartAddress(),
			StrideInBytes = shaderBindingTable.GetHitGroupStride(),
			SizeInBytes = shaderBindingTable.GetHitGroupSize()
		};
		((ID3D12GraphicsCommandList4*)CommandList).DispatchRays(&nativeDescription);
	}

	/// <inheritdoc />
	protected override void EndRenderPassInternal()
	{
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Releases unmanaged and optionally managed resources.
	/// </summary>
	/// <param name="disposing">
	/// <c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.
	/// </param>
	protected virtual void Dispose(bool disposing)
	{
		if (!disposed && disposing)
		{
			Reset();
			resourceDescriptorsGPU?.Dispose();
			samplerDescriptorsGPU?.Dispose();
			CommandList?.Release();
			CommandList = null;
			disposed = true;
		}
	}
}
