using Win32.Graphics.Direct3D12;
using NRI.D3DCommon;
using System;
using Win32.Foundation;
using Win32;
namespace NRI.D3D12;

class TextureD3D12 : Texture
{
	private DeviceD3D12 m_Device;
	private D3D12_RESOURCE_DESC m_TextureDesc = .();
	private ComPtr<ID3D12Resource> m_Texture;
	private Format m_Format = Format.UNKNOWN;

	public this(DeviceD3D12 device)
	{
		m_Device = device;
	}

	public ~this()
	{
		m_Texture.Dispose();
	}

	public static implicit operator ID3D12Resource*(Self self) => self.m_Texture.GetInterface();

	public DeviceD3D12 GetDevice() => m_Device;

	public Result Create(TextureDesc textureDesc)
	{
		uint16 blockWidth = (uint16)GetTexelBlockWidth(textureDesc.format);

		m_TextureDesc.Dimension = GetResourceDimension(textureDesc.type);
		m_TextureDesc.Alignment = textureDesc.sampleNum > 1 ? 0 : D3D12_DEFAULT_RESOURCE_PLACEMENT_ALIGNMENT;
		m_TextureDesc.Width = Align(textureDesc.size[0], blockWidth);
		m_TextureDesc.Height = Align(textureDesc.size[1], blockWidth);
		m_TextureDesc.DepthOrArraySize = textureDesc.type == TextureType.TEXTURE_3D ? textureDesc.size[2] : textureDesc.arraySize;
		m_TextureDesc.MipLevels = textureDesc.mipNum;
		m_TextureDesc.Format = GetTypelessFormat(textureDesc.format);
		m_TextureDesc.SampleDesc.Count = textureDesc.sampleNum;
		m_TextureDesc.Layout = .D3D12_TEXTURE_LAYOUT_UNKNOWN;
		m_TextureDesc.Flags = GetTextureFlags(textureDesc.usageMask);

		m_Format = textureDesc.format;

		return Result.SUCCESS;
	}

	public Result Create(TextureD3D12Desc textureDesc)
	{
		Initialize((ID3D12Resource*)textureDesc.d3d12Resource);

		return Result.SUCCESS;
	}

	public void Initialize(ID3D12Resource* resource)
	{
		m_Texture = resource;
		m_TextureDesc = resource.GetDesc();
		m_Format = GetFormat((uint32)m_TextureDesc.Format);
	}

	public Result BindMemory(MemoryD3D12 memory, uint64 offset)
	{
		/*readonly ref*/ D3D12_HEAP_DESC heapDesc = /*ref*/ memory.GetHeapDesc();
		D3D12_CLEAR_VALUE clearValue = .() { Format = ConvertNRIFormatToDXGI(m_Format) };
		bool isRenderableSurface = m_TextureDesc.Flags & (.D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET | .D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL) != 0;

		if (memory.RequiresDedicatedAllocation())
		{
			HRESULT hr = ((ID3D12Device*)m_Device).CreateCommittedResource(
				&heapDesc.Properties,
				D3D12_HEAP_FLAGS.D3D12_HEAP_FLAG_CREATE_NOT_ZEROED,
				&m_TextureDesc,
				D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COMMON,
				isRenderableSurface ? &clearValue : null,
				ID3D12Resource.IID,
				(void**)(&m_Texture)
				);

			if (FAILED(hr))
			{
				REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device::CreateCommittedResource() failed, error code: 0x{0:X}.", hr);
				return Result.FAILURE;
			}
		}
		else
		{
			HRESULT hr = ((ID3D12Device*)m_Device).CreatePlacedResource(
				memory,
				offset,
				&m_TextureDesc,
				D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COMMON,
				isRenderableSurface ? &clearValue : null,
				ID3D12Resource.IID,
				(void**)(&m_Texture)
				);

			if (FAILED(hr))
			{
				REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device::CreatePlacedResource() failed, error code: 0x{0:X}.", hr);
				return Result.FAILURE;
			}
		}

		return Result.SUCCESS;
	}

	public readonly ref D3D12_RESOURCE_DESC GetTextureDesc() => ref m_TextureDesc;

	public uint32 GetSubresourceIndex(uint32 arrayOffset, uint32 mipOffset)
	{
		return arrayOffset * m_TextureDesc.MipLevels + mipOffset;
	}

	public uint16 GetSize(uint32 dimension, uint32 mipOffset = 0)
	{
		Runtime.Assert(dimension < 3);

		uint16 size;
		if (dimension == 0)
			size = (uint16)m_TextureDesc.Width;
		else if (dimension == 1)
			size = (uint16)m_TextureDesc.Height;
		else
			size = (uint16)m_TextureDesc.DepthOrArraySize;

		size = (uint16)Math.Max(size >> mipOffset, 1);
		size = Align(size, dimension < 2 ? (uint16)GetTexelBlockWidth(m_Format) : 1);

		return size;
	}

	public void SetDebugName(char8* name)
	{
		SET_D3D_DEBUG_OBJECT_NAME!(m_Texture, scope String(name));
	}

	public uint64 GetTextureNativeObject(uint32 physicalDeviceIndex)
	{
	    //MaybeUnused(physicalDeviceIndex);
	
	    return (uint64)(int)(void*)((ID3D12Resource*)((TextureD3D12)this));
	}

	public void GetMemoryInfo(MemoryLocation memoryLocation, ref MemoryDesc memoryDesc)
	{
		m_Device.GetMemoryInfo(memoryLocation, m_TextureDesc, ref memoryDesc);
	}
}