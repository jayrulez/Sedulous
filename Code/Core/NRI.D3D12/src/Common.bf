using Win32.Graphics.Direct3D12;
using Win32.Graphics.Dxgi;
using Win32.Foundation;
namespace NRI.D3D12;

typealias D3D12_RECT = RECT;
typealias D3D12_GPU_VIRTUAL_ADDRESS = uint64;

struct DeviceCreationD3D12Desc
{
	public ID3D12Device* d3d12Device;
	public ID3D12CommandQueue* d3d12GraphicsQueue;
	public ID3D12CommandQueue* d3d12ComputeQueue;
	public ID3D12CommandQueue* d3d12CopyQueue;
	public IDXGIAdapter* d3d12PhysicalAdapter;
	public CallbackInterface callbackInterface;
	public MemoryAllocatorInterface memoryAllocatorInterface;
	public bool enableNRIValidation;
	public bool enableAPIValidation;
}

struct CommandBufferD3D12Desc
{
	public ID3D12GraphicsCommandList* d3d12CommandList;
	public ID3D12CommandAllocator* d3d12CommandAllocator;
}

struct BufferD3D12Desc
{
	public ID3D12Resource* d3d12Resource;
	public uint32 structureStride;
}

struct TextureD3D12Desc
{
	public ID3D12Resource* d3d12Resource;
}

struct MemoryD3D12Desc
{
	public ID3D12Heap* d3d12Heap;
}