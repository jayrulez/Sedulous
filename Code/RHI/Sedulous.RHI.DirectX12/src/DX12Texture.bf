using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;
using Win32.System.Com;
using Win32.Graphics.Dxgi;
using Win32.Graphics.Dxgi.Common;
using System.Collections;
using Win32.Foundation;
using Win32;

namespace Sedulous.RHI.DirectX12;

using internal Sedulous.RHI.DirectX12;
using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// Represent a DirectX Texture.
/// </summary>
public class DX12Texture : Texture
{
	private const uint32 TextureRowPitchAlignment = 256;

	private const uint32 TextureSubresourceAlignment = 512;

	/// <summary>
	/// The native texture pointer.
	/// </summary>
	public ID3D12Resource* NativeTexture;

	/// <summary>
	/// The native buffer pointer for staging textures.
	/// </summary>
	public ID3D12Resource* NativeBuffer;

	/// <summary>
	/// The native resource state.
	/// </summary>
	public D3D12_RESOURCE_STATES NativeResourceState;

	private DX12GraphicsContext dxContext;

	private D3D12_PLACED_SUBRESOURCE_FOOTPRINT[] placedSubresources;

	private D3D12_RESOURCE_DESC nativeDescription;

	private D3D12_CPU_DESCRIPTOR_HANDLE? shaderResourceView;

	private D3D12_CPU_DESCRIPTOR_HANDLE? unorderedAccessView;

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
			if (!String.IsNullOrEmpty(value))
			{
				name.Set(value);
				SetDebugName(NativeTexture, name);
			}
		}
	}

	/// <summary>
	/// Gets the shader resource view.
	/// </summary>
	public D3D12_CPU_DESCRIPTOR_HANDLE ShaderResourceView
	{
		get
		{
			if (!shaderResourceView.HasValue)
			{
				shaderResourceView = GetShaderResourceView(0, Description.ArraySize, 0);
			}
			return shaderResourceView.Value;
		}
	}

	/// <summary>
	/// Gets the unordered view.
	/// </summary>
	public D3D12_CPU_DESCRIPTOR_HANDLE UnorderedAccessView
	{
		get
		{
			if (!unorderedAccessView.HasValue)
			{
				unorderedAccessView = GetUnorderedAccessView(0, 0);
			}
			return unorderedAccessView.Value;
		}
	}

	/// <inheritdoc />
	public override void* NativePointer
	{
		get
		{
			if (NativeTexture != null)
			{
				return NativeTexture;
			}
			return null;
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12Texture" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="data">The data pointer.</param>
	/// <param name="description">The texture description.</param>
	/// <param name="samplerState">the sampler state description for this texture.</param>
	public this(DX12GraphicsContext context, Sedulous.RHI.DataBox[] data, in TextureDescription description, in SamplerStateDescription samplerState)
		: base(context, description)
	{
		ID3D12Device* dXDevice = context.DXDevice;
		dxContext = context;
		nativeDescription = default(D3D12_RESOURCE_DESC);
		switch (Description.Type)
		{
		case TextureType.Texture1D,
			 TextureType.Texture1DArray:
			nativeDescription = D3D12_RESOURCE_DESC.Texture1D(description.Format.ToDirectX(), description.Width, (uint16)description.ArraySize, (uint16)description.MipLevels, description.Flags.ToDirectX(), .D3D12_TEXTURE_LAYOUT_UNKNOWN, 0UL);
			break;
		case TextureType.Texture2D,
			 TextureType.Texture2DArray,
			 TextureType.TextureCube,
			 TextureType.TextureCubeArray:
		{
			DXGI_SAMPLE_DESC sampleDescription = description.SampleCount.ToDirectX();
			nativeDescription = D3D12_RESOURCE_DESC.Texture2D(description.Format.ToDirectX(), description.Width, description.Height, (uint16)(description.ArraySize * description.Faces), (uint16)description.MipLevels, (uint16)sampleDescription.Count, (uint16)sampleDescription.Quality, description.Flags.ToDirectX(), .D3D12_TEXTURE_LAYOUT_UNKNOWN, 0UL);
			break;
		}
		case TextureType.Texture3D:
			nativeDescription = D3D12_RESOURCE_DESC.Texture3D(description.Format.ToDirectX(), description.Width, description.Height, (uint16)description.Depth, (uint16)description.MipLevels, description.Flags.ToDirectX(), .D3D12_TEXTURE_LAYOUT_UNKNOWN, 0UL);
			break;
		default:
			context.ValidationLayer?.Notify("DX12", "Texture type does not exists.");
			break;
		}
		D3D12_CLEAR_VALUE* clearValue = null;
		if ((description.Flags & TextureFlags.DepthStencil) != 0)
		{
			clearValue = scope :: D3D12_CLEAR_VALUE()
			{
				Format = ComputeDepthFormatFromTextureFormat(description.Format),
				DepthStencil = .()
				{
					Depth = 1f,
					Stencil = 0
				}
			};
		}
		else if ((description.Flags & TextureFlags.RenderTarget) != 0)
		{
			clearValue = scope :: D3D12_CLEAR_VALUE()
			{
				Format = description.Format.ToDirectX(),
				Color = .(0, 0, 0, 1)
			};
		}
		D3D12_HEAP_TYPE heapType = D3D12_HEAP_TYPE.D3D12_HEAP_TYPE_DEFAULT;
		NativeResourceState = D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COMMON;
		HRESULT result = S_OK;
		uint64 totalSize = 0;
		uint64 bufferPointer;
		if (description.Usage == ResourceUsage.Staging)
		{
			heapType = D3D12_HEAP_TYPE.D3D12_HEAP_TYPE_READBACK;
			NativeResourceState = D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_DEST;
			totalSize = Helpers.ComputeTextureSize(description);
			D3D12_RESOURCE_DESC bufferDescription = D3D12_RESOURCE_DESC.Buffer(totalSize, .D3D12_RESOURCE_FLAG_NONE, 0UL);
			result = (Context as DX12GraphicsContext).DXDevice.CreateCommittedResource(scope .(heapType), .D3D12_HEAP_FLAG_NONE, &bufferDescription, NativeResourceState, null, ID3D12Resource.IID, (void**)&NativeBuffer);
			if (!SUCCEEDED(result))
			{
				Context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
			}
			if (data == null)
			{
				return;
			}
			bufferPointer = dxContext.BufferUploader.Allocate(totalSize);
			uint32 copyOffset = 0;
			for (uint32 a = 0; a < description.ArraySize; a++)
			{
				for (uint32 f = 0; f < description.Faces; f++)
				{
					uint32 levelWidth = description.Width;
					uint32 levelHeight = description.Height;
					uint32 levelDepth = description.Depth;
					for (uint32 m = 0; m < description.MipLevels; m++)
					{
						uint32 index = a * description.Faces * description.MipLevels + f * description.MipLevels + m;
						uint64 destination = bufferPointer + copyOffset;
						Sedulous.RHI.DataBox dataBox = data[index];
						Internal.MemCpy((void*)(int)destination, (void*)dataBox.DataPointer, dataBox.SlicePitch * description.Depth);
						copyOffset += dataBox.SlicePitch;
						levelWidth = Math.Max(1, levelWidth / 2);
						levelHeight = Math.Max(1, levelHeight / 2);
						levelDepth = Math.Max(1, levelDepth / 2);
					}
				}
			}
			dxContext.CopyCommandList.CopyBufferRegion(NativeBuffer, 0UL, dxContext.BufferUploader.nativeBuffer, dxContext.BufferUploader.CalculateOffset(bufferPointer), totalSize);
			return;
		}
		if (data == null)
		{
			if ((description.Flags & TextureFlags.DepthStencil) != 0)
			{
				NativeResourceState = D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_DEPTH_WRITE;
			}
			else if ((description.Flags & TextureFlags.RenderTarget) != 0)
			{
				NativeResourceState = D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_RENDER_TARGET;
			}
			else if ((description.Flags & TextureFlags.UnorderedAccess) != 0)
			{
				NativeResourceState = D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_UNORDERED_ACCESS;
			}
			result = dxContext.DXDevice.CreateCommittedResource(scope .(heapType), .D3D12_HEAP_FLAG_NONE, &nativeDescription, NativeResourceState, clearValue, ID3D12Resource.IID, (void**)& NativeTexture);
			if (!SUCCEEDED(result))
			{
				Context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
			}
			return;
		}
		result = dxContext.DXDevice.CreateCommittedResource(scope .(heapType), .D3D12_HEAP_FLAG_NONE, &nativeDescription, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_DEST, null, ID3D12Resource.IID, (void**)&NativeTexture);
		if (!SUCCEEDED(result))
		{
			Context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
		}
		placedSubresources = new .[data.Count];
		uint32[] rowCounts = new uint32[data.Count];
		uint64[] rowSizeInBytes = new uint64[data.Count];
		dxContext.DXDevice.GetCopyableFootprints(&nativeDescription, 0, (uint32)data.Count, 0UL, placedSubresources.Ptr, rowCounts.Ptr, rowSizeInBytes.Ptr, &totalSize);
		bufferPointer = context.TextureUploader.Allocate(totalSize);
		uint64 bufferPointerOffset = context.TextureUploader.CalculateOffset(bufferPointer);
		for (uint32 a = 0; a < description.ArraySize; a++)
		{
			for (uint32 f = 0; f < description.Faces; f++)
			{
				uint32 levelWidth = description.Width;
				uint32 levelHeight = description.Height;
				uint32 levelDepth = description.Depth;
				for (uint32 m = 0; m < description.MipLevels; m++)
				{
					uint32 index = a * description.Faces * description.MipLevels + f * description.MipLevels + m;
					uint32 copyOffset = (uint32)placedSubresources[index].Offset;
					uint64 copyPointer = bufferPointer + copyOffset;
					Sedulous.RHI.DataBox dataBox = data[index];
					int64 sourcePointer = (int64)(int)dataBox.DataPointer;
					uint32 rowPitch = placedSubresources[index].Footprint.RowPitch;
					uint32 rowSize = (uint32)rowSizeInBytes[index];
					if (rowPitch == rowSize)
					{
						Internal.MemCpy((void*)(int)copyPointer, (void*)(int)sourcePointer, rowSize * levelHeight * levelDepth);
					}
					else
					{
						for (uint32 row = 0; row < levelHeight; row++)
						{
							for (uint32 depth = 0; depth < levelDepth; depth++)
							{
								Internal.MemCpy((void*)(int)copyPointer, (void*)(int)sourcePointer, rowSize);
								copyPointer += (uint64)rowPitch;
								sourcePointer += rowSize;
							}
						}
					}
					placedSubresources[index].Offset += bufferPointerOffset;
					dxContext.CopyCommandList.CopyTextureRegion(scope .(NativeTexture, (int32)index), 0, 0, 0, scope .(dxContext.TextureUploader.nativeBuffer, placedSubresources[index]), null);
					levelWidth = Math.Max(1, levelWidth / 2);
					levelHeight = Math.Max(1, levelHeight / 2);
					levelDepth = Math.Max(1, levelDepth / 2);
				}
			}
		}
		ResourceTransition(dxContext.CopyCommandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COMMON);
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12Texture" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="data">Databoxes array.</param>
	/// <param name="description">Texture description.</param>
	private this(DX12GraphicsContext context, Sedulous.RHI.DataBox[] data, in TextureDescription description)
		: base(context, description)
	{
	}

	/// <summary>
	/// Fill the buffer from a pointer.
	/// </summary>
	/// <param name="commandList">The CommandList where execute commands.</param>
	/// <param name="source">The data pointer.</param>
	/// <param name="sourceSizeInBytes">The size in bytes.</param>
	/// <param name="subResource">The subresource index.</param>
	public void SetData(ID3D12GraphicsCommandList* commandList, void* source, uint32 sourceSizeInBytes, uint32 subResource = 0)
	{
		bool isStaging = Description.Usage == ResourceUsage.Staging;
		SubResourceInfo subResourceInfo = Helpers.GetSubResourceInfo(Description, subResource);
		if (sourceSizeInBytes > subResourceInfo.SizeInBytes)
		{
			Context.ValidationLayer?.Notify("DX12", scope $"The sourceSizeInBytes: {sourceSizeInBytes} is bigger than the subResource size: {subResourceInfo.SizeInBytes}");
		}
		if (isStaging)
		{
			D3D12_RANGE range2 = default(D3D12_RANGE);
			range2.Begin = uint((int64)subResourceInfo.Offset);
			range2.End = uint((int64)sourceSizeInBytes);
			D3D12_RANGE range = range2;
			void* dataPointer = null;
			NativeBuffer.Map(0, &range, &dataPointer);
			Internal.MemCpy((void*)dataPointer, (void*)source, sourceSizeInBytes);
			NativeBuffer.Unmap(0, null);
		}
		else
		{
			uint64 bufferPointer = dxContext.TextureUploader.Allocate(sourceSizeInBytes);
			Internal.MemCpy((void*)(int)bufferPointer, (void*)source, sourceSizeInBytes);
			D3D12_PLACED_SUBRESOURCE_FOOTPRINT[] placedSubresources = new D3D12_PLACED_SUBRESOURCE_FOOTPRINT[1];
			uint64 totalSize = 0;
			dxContext.DXDevice.GetCopyableFootprints(&nativeDescription, (uint32)subResource, 1, 0UL, placedSubresources.Ptr, null, null, &totalSize);
			placedSubresources[0].Offset += dxContext.TextureUploader.CalculateOffset(bufferPointer);
			D3D12_RESOURCE_STATES oldState = NativeResourceState;
			ResourceTransition(dxContext.CopyCommandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_DEST);
			dxContext.CopyCommandList.CopyTextureRegion(scope .(NativeTexture, (int32)subResource), 0, 0, 0, scope .(dxContext.TextureUploader.nativeBuffer, placedSubresources[0]), null);
			ResourceTransition(dxContext.CopyCommandList, oldState);
		}
	}

	/// <summary>
	/// Copy a pixel region from source to destination texture.
	/// </summary>
	/// <param name="commandList">The CommandList where execute commands.</param>
	/// <param name="sourceX">U coord source texture.</param>
	/// <param name="sourceY">V coord source texture.</param>
	/// <param name="sourceZ">W coord source texture.</param>
	/// <param name="sourceMipLevel">Source mip level.</param>
	/// <param name="sourceBaseArray">Source array index.</param>
	/// <param name="destination">Destination texture.</param>
	/// <param name="destinationX">U coord destination texture.</param>
	/// <param name="destinationY">V coord destination texture.</param>
	/// <param name="destinationZ">W coord destination texture.</param>
	/// <param name="destinationMipLevel">Destination mip level.</param>
	/// <param name="destinationBasedArray">Destination array index.</param>
	/// <param name="width">Destination width.</param>
	/// <param name="height">Destination height.</param>
	/// <param name="depth">Destination depth.</param>
	/// <param name="layerCount">Destination layer count.</param>
	public void CopyTo(ID3D12GraphicsCommandList* commandList, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBaseArray, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArray, uint32 width, uint32 height, uint32 depth, uint32 layerCount)
	{
		DX12Texture dxDestination = destination as DX12Texture;
		D3D12_RESOURCE_STATES srcResourceState = NativeResourceState;
		D3D12_RESOURCE_STATES dstResourceState = dxDestination.NativeResourceState;
		bool sourceStaging = Description.Usage == ResourceUsage.Staging;
		bool destinationStaging = destination.Description.Usage == ResourceUsage.Staging;
		ID3D12Resource* srcNativeResource = (sourceStaging ? NativeBuffer : NativeTexture);
		ID3D12Resource* dstNativeResource = (destinationStaging ? dxDestination.NativeBuffer : dxDestination.NativeTexture);
		D3D12_BOX* region = scope D3D12_BOX((uint32)sourceX, (uint32)sourceY, (uint32)sourceZ, (uint32)(sourceX + width), (uint32)(sourceY + height), (uint32)(sourceZ + depth));
		if (!sourceStaging && !destinationStaging)
		{
			for (uint32 i = 0; i < layerCount; i++)
			{
				int32 srcSubResource = (int32)((sourceBaseArray + i) * Description.MipLevels + sourceMipLevel);
				int32 dstSubResource = (int32)((destinationBasedArray + i) * destination.Description.MipLevels + destinationMipLevel);
				ResourceTransition(commandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_SOURCE, srcSubResource);
				dxDestination.ResourceTransition(commandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_DEST, dstSubResource);
				commandList.CopyTextureRegion(scope .(dstNativeResource, dstSubResource), (uint32)destinationX, (uint32)destinationY, (uint32)destinationZ, scope .(srcNativeResource, srcSubResource), region);
				ResourceTransition(commandList, srcResourceState, srcSubResource);
				dxDestination.ResourceTransition(commandList, dstResourceState, dstSubResource);
			}
			return;
		}
		if (sourceStaging && !destinationStaging)
		{
			uint32 firstResource = Helpers.CalculateSubResource(Description, sourceMipLevel, sourceBaseArray);
			D3D12_PLACED_SUBRESOURCE_FOOTPRINT[] placedSubresources = new D3D12_PLACED_SUBRESOURCE_FOOTPRINT[layerCount];
			uint64 totalSize = 0;
			dxContext.DXDevice.GetCopyableFootprints(&nativeDescription, (uint32)firstResource, (uint32)layerCount, 0UL, placedSubresources.Ptr, null, null, &totalSize);
			for (uint32 i = 0; i < layerCount; i++)
			{
				int32 dstSubResource = (int32)((destinationBasedArray + i) * destination.Description.MipLevels + destinationMipLevel);
				ResourceTransition(commandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_SOURCE);
				dxDestination.ResourceTransition(commandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_DEST, dstSubResource);
				commandList.CopyTextureRegion(scope .(dstNativeResource, dstSubResource), (uint32)destinationX, (uint32)destinationY, (uint32)destinationZ, scope .(srcNativeResource, placedSubresources[i]), region);
				ResourceTransition(commandList, srcResourceState);
				dxDestination.ResourceTransition(commandList, dstResourceState, dstSubResource);
			}
			return;
		}
		if (!sourceStaging && destinationStaging)
		{
			uint32 firstResource = Helpers.CalculateSubResource(Description, destinationMipLevel, destinationBasedArray);
			D3D12_PLACED_SUBRESOURCE_FOOTPRINT[] placedSubresources = new D3D12_PLACED_SUBRESOURCE_FOOTPRINT[layerCount];
			uint64 totalSize = 0;
			dxContext.DXDevice.GetCopyableFootprints(&dxDestination.nativeDescription, (uint32)firstResource, (uint32)layerCount, 0UL, placedSubresources.Ptr, null, null, &totalSize);
			for (uint32 i = 0; i < layerCount; i++)
			{
				int32 srcSubResource = (int32)((sourceBaseArray + i) * Description.MipLevels + sourceMipLevel);
				ResourceTransition(commandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_SOURCE, srcSubResource);
				dxDestination.ResourceTransition(commandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_DEST);
				commandList.CopyTextureRegion(scope .(dstNativeResource, placedSubresources[i]), (uint32)destinationX, (uint32)destinationY, (uint32)destinationZ, scope .(srcNativeResource, srcSubResource), region);
				ResourceTransition(commandList, srcResourceState, srcSubResource);
				dxDestination.ResourceTransition(commandList, dstResourceState);
			}
			return;
		}
		uint32 srcSubresource = Helpers.CalculateSubResource(Description, sourceMipLevel, sourceBaseArray);
		SubResourceInfo srcSubresourceInfo = Helpers.GetSubResourceInfo(Description, srcSubresource);
		uint32 dstSubresource = Helpers.CalculateSubResource(destination.Description, destinationMipLevel, destinationBasedArray);
		SubResourceInfo dstSubresourceInfo = Helpers.GetSubResourceInfo(destination.Description, dstSubresource);
		ResourceTransition(commandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_SOURCE);
		dxDestination.ResourceTransition(commandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_DEST);
		uint32 zLimit = Math.Max(depth, layerCount);
		if (!Helpers.IsCompressedFormat(Description.Format))
		{
			uint32 pixelSize = Helpers.GetSizeInBytes(Description.Format);
			for (uint32 zz = 0; zz < zLimit; zz++)
			{
				for (uint32 yy = 0; yy < height; yy++)
				{
					uint64 srcOffset = srcSubresourceInfo.Offset + srcSubresourceInfo.SlicePitch * (zz + sourceZ) + srcSubresourceInfo.RowPitch * (yy + sourceY) + pixelSize * sourceX;
					uint64 dstOffset = dstSubresourceInfo.Offset + dstSubresourceInfo.SlicePitch * (zz + destinationX) + dstSubresourceInfo.RowPitch * (yy + destinationY) + pixelSize * destinationZ;
					commandList.CopyBufferRegion(dxDestination.NativeBuffer, dstOffset, NativeBuffer, srcOffset, width * pixelSize);
				}
			}
			return;
		}
		uint32 denseRowSize = Helpers.GetRowPitch(width, Description.Format);
		uint32 numRows = Helpers.GetNumRows(height, Description.Format);
		uint32 compressedSrcX = sourceX / 4;
		uint32 compressedSrcY = sourceY / 4;
		uint32 compressedDstX = destinationX / 4;
		uint32 compressedDstY = destinationY / 4;
		uint32 blockSizeInBytes = Helpers.GetBlockSizeInBytes(Description.Format);
		for (uint32 zz = 0; zz < zLimit; zz++)
		{
			for (uint32 row = 0; row < numRows; row++)
			{
				uint64 srcOffset = srcSubresourceInfo.Offset + srcSubresourceInfo.SlicePitch * (zz + sourceZ) + srcSubresourceInfo.RowPitch * (row + compressedSrcY) + blockSizeInBytes * compressedSrcX;
				uint64 dstOffset = dstSubresourceInfo.Offset + dstSubresourceInfo.SlicePitch * (zz + destinationZ) + dstSubresourceInfo.RowPitch * (row + compressedDstY) + blockSizeInBytes * compressedDstX;
				commandList.CopyBufferRegion(dxDestination.NativeBuffer, dstOffset, NativeBuffer, srcOffset, denseRowSize);
			}
		}
	}

	/// <summary>
	/// Return a new Buffer with ResourceUsage set to staging.
	/// </summary>
	/// <returns>New staging Buffer.</returns>
	public DX12Texture ToStaging()
	{
		TextureDescription stagingDescription = Description;
		stagingDescription.Flags = TextureFlags.None;
		stagingDescription.CpuAccess = ResourceCpuAccess.Write | ResourceCpuAccess.Read;
		stagingDescription.Usage = ResourceUsage.Staging;
		SamplerStateDescription samplerStateDescription = default(SamplerStateDescription);
		return new DX12Texture(dxContext, null, stagingDescription, samplerStateDescription);
	}

	/// <summary>
	/// Create a new rendertargetview for this texture.
	/// </summary>
	/// <param name="firstSlice">The start slice of the view range.</param>
	/// <param name="sliceCount">The number of slices in the view range.</param>
	/// <param name="mipSlice">The mipmap level in the view range.</param>
	/// <returns>A new RenderTargetView instance.</returns>
	public D3D12_CPU_DESCRIPTOR_HANDLE GetRenderTargetView(uint32 firstSlice, uint32 sliceCount, uint32 mipSlice)
	{
		D3D12_RENDER_TARGET_VIEW_DESC renderTargetViewDescription = default(D3D12_RENDER_TARGET_VIEW_DESC);
		renderTargetViewDescription.Format = Description.Format.ToDirectX();
		D3D12_RENDER_TARGET_VIEW_DESC viewDescription = renderTargetViewDescription;
		switch (Description.Type)
		{
		case TextureType.Texture1D:
			viewDescription.ViewDimension = .D3D12_RTV_DIMENSION_TEXTURE1D;
			viewDescription.Texture1D.MipSlice = mipSlice;
			if (Description.SampleCount != 0)
			{
				Context.ValidationLayer?.Notify("DX12", "Multisample is only supported for 2D renderTarget texture.");
			}
			break;
		case TextureType.Texture1DArray:
			viewDescription.ViewDimension = .D3D12_RTV_DIMENSION_TEXTURE1DARRAY;
			viewDescription.Texture1DArray.ArraySize = Description.ArraySize;
			viewDescription.Texture1DArray.MipSlice = mipSlice;
			if (Description.SampleCount != 0)
			{
				Context.ValidationLayer?.Notify("DX12", "Multisample is only supported for 2D renderTarget texture.");
			}
			break;
		case TextureType.Texture2D:
			if (Description.SampleCount == TextureSampleCount.None)
			{
				viewDescription.ViewDimension = .D3D12_RTV_DIMENSION_TEXTURE2D;
			}
			else
			{
				viewDescription.ViewDimension = .D3D12_RTV_DIMENSION_TEXTURE2DMS;
			}
			viewDescription.Texture2D.MipSlice = mipSlice;
			break;
		case TextureType.Texture2DArray:
			if (Description.SampleCount == TextureSampleCount.None)
			{
				viewDescription.ViewDimension = .D3D12_RTV_DIMENSION_TEXTURE2DARRAY;
				viewDescription.Texture2DArray.ArraySize = sliceCount;
				viewDescription.Texture2DArray.FirstArraySlice = firstSlice;
				viewDescription.Texture2DArray.MipSlice = mipSlice;
			}
			else
			{
				viewDescription.ViewDimension = .D3D12_RTV_DIMENSION_TEXTURE2DMSARRAY;
				viewDescription.Texture2DMSArray.ArraySize = sliceCount;
				viewDescription.Texture2DMSArray.FirstArraySlice = firstSlice;
			}
			break;
		case TextureType.TextureCube,
			 TextureType.TextureCubeArray:
			viewDescription.ViewDimension = .D3D12_RTV_DIMENSION_TEXTURE2DARRAY;
			viewDescription.Texture2DArray.ArraySize = sliceCount;
			viewDescription.Texture2DArray.FirstArraySlice = firstSlice;
			viewDescription.Texture2DArray.MipSlice = mipSlice;
			if (Description.SampleCount != 0)
			{
				Context.ValidationLayer?.Notify("DX11", "Multisample is only supported for 2D renderTarget texture.");
			}
			break;
		case TextureType.Texture3D:
			viewDescription.ViewDimension = .D3D12_RTV_DIMENSION_TEXTURE3D;
			viewDescription.Texture3D.WSize = Description.Depth;
			viewDescription.Texture3D.FirstWSlice = firstSlice;
			viewDescription.Texture3D.MipSlice = mipSlice;
			if (Description.SampleCount != 0)
			{
				Context.ValidationLayer?.Notify("DX12", "Multisample is only supported for 2D renderTarget texture.");
			}
			break;
		}
		D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle = dxContext.RenderTargetViewAllocator.Allocate();
		dxContext.DXDevice.CreateRenderTargetView(NativeTexture, &viewDescription, descriptorHandle);
		return descriptorHandle;
	}

	/// <summary>
	/// Create a new  DepthStencil view for this texture.
	/// </summary>
	/// <param name="firstSlice">The start slice of the view range.</param>
	/// <param name="sliceCount">The number of slices in the view range.</param>
	/// <param name="mipSlice">The mipmap level in the view range.</param>
	/// <returns>A new DepthStencil view.</returns>
	public D3D12_CPU_DESCRIPTOR_HANDLE GetDepthStencilView(uint32 firstSlice, uint32 sliceCount, uint32 mipSlice)
	{
		D3D12_DEPTH_STENCIL_VIEW_DESC viewDescription = default(D3D12_DEPTH_STENCIL_VIEW_DESC);
		DXGI_FORMAT format = Description.Format.ToDepthStencilFormat();
		if (format == .DXGI_FORMAT_UNKNOWN)
		{
			Context.ValidationLayer?.Notify("DX12", scope $"Unsupported depth format: {Description.Format}");
		}
		viewDescription.Format = format;
		switch (Description.Type)
		{
		case TextureType.Texture1DArray:
			viewDescription.ViewDimension = .D3D12_DSV_DIMENSION_TEXTURE1DARRAY;
			viewDescription.Texture1DArray.ArraySize = 1;
			viewDescription.Texture1DArray.FirstArraySlice = firstSlice;
			viewDescription.Texture1DArray.MipSlice = mipSlice;
			if (Description.SampleCount != 0)
			{
				Context.ValidationLayer?.Notify("DX12", "Multisample is only supported for 2D renderTarget texture.");
			}
			break;
		case TextureType.Texture2D:
			if (Description.SampleCount == TextureSampleCount.None)
			{
				viewDescription.ViewDimension = .D3D12_DSV_DIMENSION_TEXTURE2D;
				viewDescription.Texture2D.MipSlice = 0;
			}
			else
			{
				viewDescription.ViewDimension = .D3D12_DSV_DIMENSION_TEXTURE2DMS;
			}
			break;
		case TextureType.Texture2DArray:
			if (Description.SampleCount == TextureSampleCount.None)
			{
				viewDescription.ViewDimension = .D3D12_DSV_DIMENSION_TEXTURE2DARRAY;
				viewDescription.Texture2DArray.ArraySize = sliceCount;
				viewDescription.Texture2DArray.FirstArraySlice = firstSlice;
				viewDescription.Texture2DArray.MipSlice = mipSlice;
			}
			else
			{
				viewDescription.ViewDimension = .D3D12_DSV_DIMENSION_TEXTURE2DMSARRAY;
				viewDescription.Texture2DMSArray.ArraySize = sliceCount;
				viewDescription.Texture2DMSArray.FirstArraySlice = firstSlice;
			}
			break;
		case TextureType.TextureCube,
			 TextureType.TextureCubeArray:
			viewDescription.ViewDimension = .D3D12_DSV_DIMENSION_TEXTURE2DARRAY;
			viewDescription.Texture2DArray.ArraySize = sliceCount;
			viewDescription.Texture2DArray.FirstArraySlice = firstSlice;
			viewDescription.Texture2DArray.MipSlice = mipSlice;
			if (Description.SampleCount != 0)
			{
				Context.ValidationLayer?.Notify("DX11", "Multisample is only supported for 2D renderTarget texture.");
			}
			break;
		case TextureType.Texture1D,
			 TextureType.Texture3D:
			Context.ValidationLayer?.Notify("DX12", "Texture type don't supported as depthTexture.");
			break;
		}
		D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle = dxContext.DepthStencilViewAllocator.Allocate();
		dxContext.DXDevice.CreateDepthStencilView(NativeTexture, &viewDescription, descriptorHandle);
		return descriptorHandle;
	}

	/// <summary>
	/// Create a new ShaderResource view for this texture.
	/// </summary>
	/// <param name="firstSlice">The start slice of the view range.</param>
	/// <param name="sliceCount">The number of slices in the view range.</param>
	/// <param name="mipSlice">The mipmap level in the view range.</param>
	/// <returns>A new ShaderResource view.</returns>
	public D3D12_CPU_DESCRIPTOR_HANDLE GetShaderResourceView(uint32 firstSlice, uint32 sliceCount, uint32 mipSlice)
	{
		D3D12_SHADER_RESOURCE_VIEW_DESC viewDescription = default(D3D12_SHADER_RESOURCE_VIEW_DESC);
		viewDescription.Shader4ComponentMapping = DX12GraphicsContext.DefaultShader4ComponentMapping;
		switch (Description.Format)
		{
		case PixelFormat.R16_Typeless:
			viewDescription.Format = .DXGI_FORMAT_R16_UNORM;
			break;
		case PixelFormat.R32_Typeless:
			viewDescription.Format = .DXGI_FORMAT_R32_FLOAT;
			break;
		case PixelFormat.R24G8_Typeless:
			viewDescription.Format = .DXGI_FORMAT_R24_UNORM_X8_TYPELESS;
			break;
		case PixelFormat.R32G8X24_Typeless:
			viewDescription.Format = .DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS;
			break;
		default:
			viewDescription.Format = Description.Format.ToDirectX();
			break;
		}
		switch (Description.Type)
		{
		case TextureType.Texture1D:
			viewDescription.ViewDimension = .D3D12_SRV_DIMENSION_TEXTURE1D;
			viewDescription.Texture1D.MipLevels = Description.MipLevels;
			viewDescription.Texture1D.MostDetailedMip = mipSlice;
			if (Description.SampleCount != 0)
			{
				Context.ValidationLayer?.Notify("DX12", "Multisample is only supported for 2D renderTarget texture.");
			}
			break;
		case TextureType.Texture1DArray:
			viewDescription.ViewDimension = .D3D12_SRV_DIMENSION_TEXTURE1DARRAY;
			viewDescription.Texture1DArray.ArraySize = sliceCount;
			viewDescription.Texture1DArray.FirstArraySlice = firstSlice;
			viewDescription.Texture1DArray.MipLevels = Description.MipLevels;
			viewDescription.Texture1DArray.MostDetailedMip = mipSlice;
			if (Description.SampleCount != 0)
			{
				Context.ValidationLayer?.Notify("DX12", "Multisample is only supported for 2D renderTarget texture.");
			}
			break;
		case TextureType.Texture2D:
			if (Description.SampleCount == TextureSampleCount.None)
			{
				viewDescription.ViewDimension = .D3D12_SRV_DIMENSION_TEXTURE2D;
			}
			else
			{
				viewDescription.ViewDimension = .D3D12_SRV_DIMENSION_TEXTURE2DMS;
			}
			viewDescription.Texture2D.MipLevels = Description.MipLevels;
			viewDescription.Texture2D.MostDetailedMip = mipSlice;
			break;
		case TextureType.Texture2DArray:
			if (Description.SampleCount == TextureSampleCount.None)
			{
				viewDescription.ViewDimension = .D3D12_SRV_DIMENSION_TEXTURE2DARRAY;
				viewDescription.Texture2DArray.ArraySize = sliceCount;
				viewDescription.Texture2DArray.FirstArraySlice = firstSlice;
				viewDescription.Texture2DArray.MipLevels = Description.MipLevels;
				viewDescription.Texture2DArray.MostDetailedMip = mipSlice;
			}
			else
			{
				viewDescription.ViewDimension = .D3D12_SRV_DIMENSION_TEXTURE2DMSARRAY;
				viewDescription.Texture2DMSArray.ArraySize = sliceCount;
				viewDescription.Texture2DMSArray.FirstArraySlice = firstSlice;
			}
			break;
		case TextureType.TextureCube:
			viewDescription.ViewDimension = .D3D12_SRV_DIMENSION_TEXTURECUBE;
			viewDescription.TextureCube.MipLevels = Description.MipLevels;
			viewDescription.TextureCube.MostDetailedMip = mipSlice;
			if (Description.SampleCount != 0)
			{
				Context.ValidationLayer?.Notify("DX12", "Multisample is only supported for 2D renderTarget texture.");
			}
			break;
		case TextureType.TextureCubeArray:
			viewDescription.ViewDimension = .D3D12_SRV_DIMENSION_TEXTURECUBEARRAY;
			viewDescription.TextureCubeArray.MipLevels = Description.MipLevels;
			viewDescription.TextureCubeArray.MostDetailedMip = mipSlice;
			viewDescription.TextureCubeArray.NumCubes = sliceCount;
			viewDescription.TextureCubeArray.First2DArrayFace = firstSlice;
			if (Description.SampleCount != 0)
			{
				Context.ValidationLayer?.Notify("DX12", "Multisample is only supported for 2D renderTarget texture.");
			}
			break;
		case TextureType.Texture3D:
			viewDescription.ViewDimension = .D3D12_SRV_DIMENSION_TEXTURE3D;
			viewDescription.Texture3D.MipLevels = Description.MipLevels;
			viewDescription.Texture3D.MostDetailedMip = mipSlice;
			if (Description.SampleCount != 0)
			{
				Context.ValidationLayer?.Notify("DX12", "Multisample is only supported for 2D renderTarget texture.");
			}
			break;
		}
		D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle = dxContext.ShaderResourceViewAllocator.Allocate();
		dxContext.DXDevice.CreateShaderResourceView(NativeTexture, &viewDescription, descriptorHandle);
		return descriptorHandle;
	}

	/// <summary>
	/// Create a new UnorderedAccessView for this texture.
	/// </summary>
	/// <param name="arraySlice">The slice in the view range.</param>
	/// <param name="mipSlice">The mipmap level in the view range.</param>
	/// <returns>A new UnorderedAccessView.</returns>
	public D3D12_CPU_DESCRIPTOR_HANDLE GetUnorderedAccessView(uint32 arraySlice, uint32 mipSlice)
	{
		D3D12_UNORDERED_ACCESS_VIEW_DESC viewDescription = default(D3D12_UNORDERED_ACCESS_VIEW_DESC);
		viewDescription.Format = Description.Format.ToDirectX();
		switch (Description.Type)
		{
		case TextureType.Texture1D:
			viewDescription.ViewDimension = .D3D12_UAV_DIMENSION_TEXTURE1D;
			viewDescription.Texture1D.MipSlice = mipSlice;
			break;
		case TextureType.Texture1DArray:
			viewDescription.ViewDimension = .D3D12_UAV_DIMENSION_TEXTURE1DARRAY;
			viewDescription.Texture1DArray.ArraySize = Description.ArraySize;
			viewDescription.Texture1DArray.FirstArraySlice = arraySlice;
			viewDescription.Texture1DArray.MipSlice = mipSlice;
			break;
		case TextureType.Texture2D:
			viewDescription.ViewDimension = .D3D12_UAV_DIMENSION_TEXTURE2D;
			viewDescription.Texture2D.MipSlice = mipSlice;
			break;
		case TextureType.Texture2DArray,
			 TextureType.TextureCube,
			 TextureType.TextureCubeArray:
			viewDescription.ViewDimension = .D3D12_UAV_DIMENSION_TEXTURE2DARRAY;
			viewDescription.Texture2DArray.ArraySize = Description.ArraySize;
			viewDescription.Texture2DArray.FirstArraySlice = arraySlice;
			viewDescription.Texture2DArray.MipSlice = mipSlice;
			break;
		case TextureType.Texture3D:
			viewDescription.ViewDimension = .D3D12_UAV_DIMENSION_TEXTURE3D;
			viewDescription.Texture3D.FirstWSlice = arraySlice;
			viewDescription.Texture3D.WSize = Description.Depth;
			viewDescription.Texture3D.MipSlice = mipSlice;
			break;
		}
		D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle = (Context as DX12GraphicsContext).ShaderResourceViewAllocator.Allocate();
		(Context as DX12GraphicsContext).DXDevice.CreateUnorderedAccessView(NativeTexture, null, &viewDescription, descriptorHandle);
		return descriptorHandle;
	}

	/// <summary>
	/// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
	/// </summary>
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Generate a DXTexture from Vortice Texture2D.
	/// </summary>
	/// <param name="context">DX context.</param>
	/// <param name="nativeTexture">VorticeTexture instance.</param>
	/// <param name="textureDescription">Overrided pixel format. This only affect to the generated TextureDescription. IT does not change the source texture format.</param>
	/// <returns>DXTexture with VorticeTexture as resource.</returns>
	public static DX12Texture FromDirectXTexture(DX12GraphicsContext context, ID3D12Resource* nativeTexture, TextureDescription? textureDescription = null)
	{
		TextureDescription description;
		if (!textureDescription.HasValue)
		{
			D3D12_RESOURCE_DESC nativeDescription = nativeTexture.GetDesc();
			TextureDescription newDescription = default(TextureDescription);
			newDescription.Width = (uint32)nativeDescription.Width;
			newDescription.Height = (uint32)nativeDescription.Height;
			newDescription.Format = nativeDescription.Format.FromDirectX();
			newDescription.MipLevels = nativeDescription.MipLevels;
			newDescription.ArraySize = nativeDescription.DepthOrArraySize;
			newDescription.Faces = 1;
			newDescription.Flags = nativeDescription.Flags.FromDirectX();
			newDescription.CpuAccess = ResourceCpuAccess.None;
			newDescription.Usage = ResourceUsage.Default;
			newDescription.SampleCount = nativeDescription.SampleDesc.FromDirectX();
			newDescription.Type = TextureType.Texture2D;
			description = newDescription;
		}
		else
		{
			description = textureDescription.Value;
		}
		return new DX12Texture(context, null, description)
		{
			NativeTexture = nativeTexture,
			dxContext = context
		};
	}

	/// <summary>
	/// Generate a DXTexture from Vortice Texture2D.
	/// </summary>
	/// <param name="context">DX context.</param>
	/// <param name="texturePointer">DirectX Texture pointer.</param>
	/// <param name="textureDescription">Overrided pixel format.</param>
	/// <returns>DXTexture with VorticeTexture as resource.</returns>
	public static DX12Texture FromDirectXTexture(DX12GraphicsContext context, void* texturePointer, TextureDescription? textureDescription = null)
	{
		ID3D12Resource* t = ((IUnknown*)texturePointer).QueryInterface<IDXGIResource>().QueryInterface<ID3D12Resource>();
		return FromDirectXTexture(context, t, textureDescription);
	}

	/// <summary>
	/// Transition this texture to another native state.
	/// </summary>
	/// <param name="commandList">The commandlist used to execute the barrier transition.</param>
	/// <param name="newResourceState">The new native state for this texture.</param>
	/// <param name="subResource">The subresource index.</param>
	public void ResourceTransition(ID3D12GraphicsCommandList* commandList, D3D12_RESOURCE_STATES newResourceState, int32 subResource = 0)
	{
		if (NativeResourceState == newResourceState)
		{
			return;
		}
		if (Description.Usage == ResourceUsage.Staging)
		{
			if (NativeResourceState != D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_GENERIC_READ)
			{
				commandList.ResourceBarrierTransition(NativeBuffer, NativeResourceState, newResourceState, subResource);
			}
		}
		else
		{
			commandList.ResourceBarrierTransition(NativeTexture, NativeResourceState, newResourceState, subResource);
		}
		NativeResourceState = newResourceState;
	}

	private DXGI_FORMAT ComputeDepthFormatFromTextureFormat(PixelFormat format)
	{
		switch (format)
		{
		case PixelFormat.R16_Typeless,
			 PixelFormat.D16_UNorm:
			return .DXGI_FORMAT_D16_UNORM;
		case PixelFormat.R32_Typeless,
			 PixelFormat.D32_Float:
			return .DXGI_FORMAT_D32_FLOAT;
		case PixelFormat.R24G8_Typeless,
			 PixelFormat.D24_UNorm_S8_UInt:
			return .DXGI_FORMAT_D24_UNORM_S8_UINT;
		case PixelFormat.R32G8X24_Typeless,
			 PixelFormat.D32_Float_S8X24_UInt:
			return .DXGI_FORMAT_D32_FLOAT_S8X24_UINT;
		default:
			return .DXGI_FORMAT_UNKNOWN;
		}
	}

	private static void ConvertDataBoxes(DataBox[] textureData, List<D3D12_SUBRESOURCE_DATA> outputData)
	{
		if (textureData == null || textureData.Count == 0)
		{
			return;
		}

		outputData.Resize(textureData.Count);
		for (int32 i = 0; i < textureData.Count; i++)
		{
			void* dataPointer = textureData[i].DataPointer;
			int32 rowPitch = (int32)textureData[i].RowPitch;
			int32 slicePitch = (int32)textureData[i].SlicePitch;
			outputData[i] = D3D12_SUBRESOURCE_DATA() { pData = dataPointer, RowPitch = rowPitch, SlicePitch = slicePitch };
		}
	}

	private void Dispose(bool disposing)
	{
		if (disposed)
		{
			return;
		}
		if (disposing)
		{
			if (shaderResourceView.HasValue)
			{
				dxContext.ShaderResourceViewAllocator.Free(shaderResourceView.Value);
			}
			if (unorderedAccessView.HasValue)
			{
				dxContext.ShaderResourceViewAllocator.Free(unorderedAccessView.Value);
			}
			NativeTexture?.Release();
		}
		disposed = true;
	}
}
