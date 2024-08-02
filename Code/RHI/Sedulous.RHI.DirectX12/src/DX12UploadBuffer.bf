using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;

namespace Sedulous.RHI.DirectX12;

internal class DX12UploadBuffer : UploadBuffer
{
	/// <summary>
	/// The DirectX texture instance.
	/// </summary>
	public ID3D12Resource* nativeBuffer;

	public this(DX12GraphicsContext context, uint64 size, uint32 align = 512)
		: base(context, size, align)
	{
	}

	protected override void RefreshBuffer(uint64 size)
	{
		D3D12_RESOURCE_DESC pBufferDesc = D3D12_RESOURCE_DESC.Buffer(size, .D3D12_RESOURCE_FLAG_NONE, 0UL);
		((DX12GraphicsContext)context).DXDevice.CreateCommittedResource(
			scope .(.D3D12_HEAP_TYPE_UPLOAD),
			.D3D12_HEAP_FLAG_NONE, &pBufferDesc,
			D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_GENERIC_READ,
			null,
			ID3D12Resource.IID,
			(void**)&nativeBuffer);
		void* data = null;
		nativeBuffer.Map(0, null, &data);
		DataCurrent = (DataBegin = (uint64)(int)data);
		TotalSize = size;
		DataEnd = DataBegin + size;
	}

	public override void Dispose()
	{
		nativeBuffer?.Unmap(0, null);
		ID3D12Resource* iD3D12Resource = nativeBuffer;
		if (iD3D12Resource != null)
		{
			iD3D12Resource.Release();
		}
	}
}
