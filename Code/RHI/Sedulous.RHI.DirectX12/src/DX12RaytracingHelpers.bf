using Win32.Graphics.Direct3D12;
namespace Sedulous.RHI.DirectX12;
namespace Sedulous.RHI.DirectX12;

/// <summary>
/// Ray tracing helpers.
/// </summary>
public static class DX12RaytracingHelpers
{
	/// <summary>
	/// Default heap property.
	/// </summary>
	public static D3D12_HEAP_PROPERTIES kDefaultHeapProps = .(.D3D12_HEAP_TYPE_DEFAULT, .D3D12_CPU_PAGE_PROPERTY_UNKNOWN, .D3D12_MEMORY_POOL_UNKNOWN, 0, 0);

	/// <summary>
	/// Upload heap property.
	/// </summary>
	public static D3D12_HEAP_PROPERTIES kUploadHeapProps = .(.D3D12_HEAP_TYPE_UPLOAD, .D3D12_CPU_PAGE_PROPERTY_UNKNOWN, .D3D12_MEMORY_POOL_UNKNOWN, 0, 0);

	/// <summary>
	/// Creates the Acceleration Structure buffer.
	/// </summary>
	/// <param name="pDevice">Device.</param>
	/// <param name="size">Buffer size.</param>
	/// <param name="flags">Resource flags.</param>
	/// <param name="initState">Initial buffer state.</param>
	/// <param name="heapProps">Heap properties.</param>
	/// <returns>The buffer.</returns>
	public static ID3D12Resource* CreateBuffer(ID3D12Device5* pDevice, uint32 size, D3D12_RESOURCE_FLAGS flags, D3D12_RESOURCE_STATES initState, D3D12_HEAP_PROPERTIES heapProps)
	{
		var heapProps;
		D3D12_RESOURCE_DESC bufDesc = default(D3D12_RESOURCE_DESC);
		bufDesc.Alignment = 0UL;
		bufDesc.DepthOrArraySize = 1;
		bufDesc.Dimension = .D3D12_RESOURCE_DIMENSION_BUFFER;
		bufDesc.Flags = flags;
		bufDesc.Format = .DXGI_FORMAT_UNKNOWN;
		bufDesc.Height = 1;
		bufDesc.Layout = .D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
		bufDesc.MipLevels = 1;
		bufDesc.SampleDesc = .(1, 0);
		bufDesc.Width = size;

		ID3D12Resource* pBuffer = null;
		pDevice.CreateCommittedResource(&heapProps, .D3D12_HEAP_FLAG_NONE, &bufDesc, initState, null, ID3D12Resource.IID, (void**)&pBuffer);
		return pBuffer;
	}
}
