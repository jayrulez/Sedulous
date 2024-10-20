using System;
using System.Threading;
using Sedulous.RHI;
using System.Collections;
using Win32.Graphics.Direct3D12;
using Win32;
using Win32.Foundation;

namespace Sedulous.RHI.DirectX12;

using internal Sedulous.RHI.DirectX12;
using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// This class represents a queue where command buffers wait to be executed by the GPU.
/// </summary>
public class DX12CommandQueue : CommandQueue
{
	private DX12GraphicsContext context;

	private bool disposed;

	private Queue<DX12CommandBuffer> queue;

	private DX12CommandBuffer[] executionArray ~ delete _;

	private int32 executionArraySize;

	internal ID3D12CommandQueue* CommandQueue = null;

	internal CommandQueueType QueueType;

	internal ID3D12Fence* Fence;

	internal AutoResetEvent FenceEvent;

	internal uint64 FenceValue;

	private String name = new .() ~ delete _;

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
			SetDebugName(CommandQueue, name);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12CommandQueue" /> class.
	/// </summary>
	/// <param name="graphicsContext">The graphics context instance.</param>
	/// <param name="queueType">The command queue element type.</param>
	public this(DX12GraphicsContext graphicsContext, CommandQueueType queueType)
	{
		context = graphicsContext;
		queue = new Queue<DX12CommandBuffer>();
		executionArray = new DX12CommandBuffer[64];
		executionArraySize = 0;
		QueueType = queueType;
		D3D12_COMMAND_LIST_TYPE  commandListType = queueType.ToDirectX();
		D3D12_COMMAND_QUEUE_DESC  queueDescription = D3D12_COMMAND_QUEUE_DESC ()
		{
			Flags = .D3D12_COMMAND_QUEUE_FLAG_NONE,
			Priority = 0,
			Type = commandListType,
			NodeMask = 0
		};
		HRESULT result = context.DXDevice.CreateCommandQueue(&queueDescription, ID3D12CommandQueue.IID, (void**)&CommandQueue);
		if (!SUCCEEDED(result))
		{
			context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
		}
		FenceValue = 0UL;
		FenceEvent = new AutoResetEvent(initialState: false);
		result = context.DXDevice.CreateFence(FenceValue, .D3D12_FENCE_FLAG_NONE, ID3D12Fence.IID, (void**)&Fence);
		if (!SUCCEEDED(result))
		{
			context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
		}
	}

	public ~this()
	{
		delete FenceEvent;
	}

	/// <inheritdoc />
	public override CommandBuffer CommandBuffer()
	{
		DX12CommandBuffer commandBuffer;
		if (queue.Count == 0)
		{
			commandBuffer = new DX12CommandBuffer(context, this);
		}
		else
		{
			commandBuffer = queue.PopFront();
			commandBuffer.Reset();
		}
		return commandBuffer;
	}

	/// <inheritdoc />
	public override void Submit()
	{
		if (context.BufferUploader.Count != 0 || context.TextureUploader.Count != 0)
		{
			context.SyncUpcopyQueue();
		}
		for (int32 i = 0; i < executionArraySize; i++)
		{
			DX12CommandBuffer nativeCommandBuffer = executionArray[i];
			CommandQueue.ExecuteCommandLists(1, (ID3D12CommandList**)&nativeCommandBuffer.CommandList);
			queue.Add(nativeCommandBuffer);
		}
		ClearExecutionArray();
	}

	/// <inheritdoc />
	public override void WaitIdle()
	{
		CommandQueue.Signal(Fence, FenceValue);
		if (Fence.GetCompletedValue() < FenceValue)
		{
			Fence.SetEventOnCompletion(FenceValue, FenceEvent.Handle);
			FenceEvent.WaitOne();
		}
		FenceValue++;
	}

	/// <summary>
	/// Adds a new command buffer ready to be executed.
	/// </summary>
	/// <param name="commandBuffer">The new command buffer.</param>
	internal void CommitCommandBuffer(DX12CommandBuffer commandBuffer)
	{
		if (executionArray.Count == executionArraySize)
		{
			Array.Resize(ref executionArray, executionArray.Count + 64);
		}
		executionArray[executionArraySize++] = commandBuffer;
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Clears the execution command buffer array.
	/// </summary>
	private void ClearExecutionArray()
	{
		for (int32 i = 0; i < executionArraySize; i++)
		{
			executionArray[i] = null;
		}
		executionArraySize = 0;
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
			while (queue.Count > 0)
			{
				var commandBuffer = queue.PopFront();
					commandBuffer.Dispose();
				delete commandBuffer;
			}
			delete queue;
			queue = null;

			Fence?.Release();
			CommandQueue?.Release();

			disposed = true;
		}
	}
}
