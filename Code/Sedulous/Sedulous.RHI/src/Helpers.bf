using System;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI;

/// <summary>
/// Miscellaneous helpers for graphic operations.
/// </summary>
public static class Helpers
{
	/// <summary>
	/// Align the size in bytes to nearest multiple of 256.
	/// </summary>
	/// <param name="sizeInBytes">The size in bytes.</param>
	/// <returns>The aligned size.</returns>
	[Inline]
	public static uint32 AlignUp(uint32 sizeInBytes)
	{
		uint32 mask = 255;
		return (sizeInBytes + mask) & ~mask;
	}

	/// <summary>
	/// Align the size in bytes to nearest multiple of alignment value specified by parameter.
	/// </summary>
	/// <param name="alignment">The alignment size.</param>
	/// <param name="sizeInBytes">The size in bytes.</param>
	/// <returns>The aligned size.</returns>
	[Inline]
	public static uint32 AlignUp(uint32 alignment, uint32 sizeInBytes)
	{
		uint32 mask = alignment - 1;
		return (sizeInBytes + mask) & ~mask;
	}

	/// <summary>
	/// Align the size in bytes to nearest multiple of alignment value specified by parameter.
	/// </summary>
	/// <param name="alignment">The alignment size.</param>
	/// <param name="sizeInBytes">The size in bytes.</param>
	/// <returns>The aligned size.</returns>
	[Inline]
	public static uint64 AlignUp(uint32 alignment, uint64 sizeInBytes)
	{
		uint64 mask = alignment - 1;
		return (sizeInBytes + mask) & ~mask;
	}
	/// <summary>
	/// Indicates if this format is in Gamma Color Scapce.
	/// </summary>
	/// <param name="format">Pixel format.</param>
	/// <returns>Is in gamma space.</returns>
	public static bool IsGammaColorSpaceFormat(this PixelFormat format)
	{
		switch (format)
		{
		case PixelFormat.R32G32B32A32_Float,
			PixelFormat.R32G32B32_Float,
			PixelFormat.R16G16B16A16_Float,
			PixelFormat.R32G32_Float,
			PixelFormat.R11G11B10_Float,
			PixelFormat.R8G8B8A8_UNorm_SRgb,
			PixelFormat.R16G16_Float,
			PixelFormat.D32_Float,
			PixelFormat.R32_Float,
			PixelFormat.R16_Float,
			PixelFormat.BC1_UNorm_SRgb,
			PixelFormat.BC2_UNorm_SRgb,
			PixelFormat.BC3_UNorm_SRgb,
			PixelFormat.B8G8R8A8_UNorm_SRgb,
			PixelFormat.B8G8R8X8_UNorm_SRgb,
			PixelFormat.BC7_UNorm_SRgb,
			PixelFormat.PVRTC_2BPP_RGB_SRGB,
			PixelFormat.PVRTC_4BPP_RGB_SRGB,
			PixelFormat.PVRTC_2BPP_RGBA_SRGBA,
			PixelFormat.PVRTC_4BPP_RGBA_SRGBA,
			PixelFormat.ETC2_RGBA_SRGB:
			return false;
		default:
			return true;
		}
	}

	/// <summary>
	/// Get Format size in bits (8 bits = uint8).
	/// </summary>
	/// <param name="format">Pixel format.</param>
	/// <returns>Size in bits.</returns>
	public static uint32 GetSizeInBits(this PixelFormat format)
	{
		switch (format)
		{
		case PixelFormat.R32G32B32A32_Typeless,
			PixelFormat.R32G32B32A32_Float,
			PixelFormat.R32G32B32A32_UInt,
			PixelFormat.R32G32B32A32_SInt:
			return 128;
		case PixelFormat.R32G32B32_Typeless,
			PixelFormat.R32G32B32_Float,
			PixelFormat.R32G32B32_UInt,
			PixelFormat.R32G32B32_SInt:
			return 96;
		case PixelFormat.R16G16B16A16_Typeless,
			PixelFormat.R16G16B16A16_Float,
			PixelFormat.R16G16B16A16_UNorm,
			PixelFormat.R16G16B16A16_UInt,
			PixelFormat.R16G16B16A16_SNorm,
			PixelFormat.R16G16B16A16_SInt,
			PixelFormat.R32G32_Typeless,
			PixelFormat.R32G32_Float,
			PixelFormat.R32G32_UInt,
			PixelFormat.R32G32_SInt,
			PixelFormat.R32G8X24_Typeless,
			PixelFormat.D32_Float_S8X24_UInt,
			PixelFormat.R32_Float_X8X24_Typeless,
			PixelFormat.X32_Typeless_G8X24_UInt:
			return 64;
		case PixelFormat.R10G10B10A2_Typeless,
			PixelFormat.R10G10B10A2_UNorm,
			PixelFormat.R10G10B10A2_UInt,
			PixelFormat.R11G11B10_Float,
			PixelFormat.R8G8B8A8_Typeless,
			PixelFormat.R8G8B8A8_UNorm,
			PixelFormat.R8G8B8A8_UNorm_SRgb,
			PixelFormat.R8G8B8A8_UInt,
			PixelFormat.R8G8B8A8_SNorm,
			PixelFormat.R8G8B8A8_SInt,
			PixelFormat.R16G16_Typeless,
			PixelFormat.R16G16_Float,
			PixelFormat.R16G16_UNorm,
			PixelFormat.R16G16_UInt,
			PixelFormat.R16G16_SNorm,
			PixelFormat.R16G16_SInt,
			PixelFormat.R32_Typeless,
			PixelFormat.D32_Float,
			PixelFormat.R32_Float,
			PixelFormat.R32_UInt,
			PixelFormat.R32_SInt,
			PixelFormat.R24G8_Typeless,
			PixelFormat.D24_UNorm_S8_UInt,
			PixelFormat.R24_UNorm_X8_Typeless,
			PixelFormat.X24_Typeless_G8_UInt,
			PixelFormat.R9G9B9E5_Sharedexp,
			PixelFormat.R8G8_B8G8_UNorm,
			PixelFormat.G8R8_G8B8_UNorm,
			PixelFormat.BC1_UNorm,
			PixelFormat.BC2_UNorm,
			PixelFormat.BC3_UNorm,
			PixelFormat.B8G8R8A8_UNorm,
			PixelFormat.B8G8R8X8_UNorm,
			PixelFormat.R10G10B10_Xr_Bias_A2_UNorm,
			PixelFormat.B8G8R8A8_Typeless,
			PixelFormat.B8G8R8A8_UNorm_SRgb,
			PixelFormat.B8G8R8X8_Typeless,
			PixelFormat.B8G8R8X8_UNorm_SRgb,
			PixelFormat.PVRTC_4BPP_RGB,
			PixelFormat.PVRTC_4BPP_RGBA,
			PixelFormat.PVRTC_4BPP_RGB_SRGB,
			PixelFormat.PVRTC_4BPP_RGBA_SRGBA:
			return 32;
		case PixelFormat.R8G8_Typeless,
			PixelFormat.R8G8_UNorm,
			PixelFormat.R8G8_UInt,
			PixelFormat.R8G8_SNorm,
			PixelFormat.R8G8_SInt,
			PixelFormat.R16_Typeless,
			PixelFormat.R16_Float,
			PixelFormat.D16_UNorm,
			PixelFormat.R16_UNorm,
			PixelFormat.R16_UInt,
			PixelFormat.R16_SNorm,
			PixelFormat.R16_SInt,
			PixelFormat.B5G6R5_UNorm,
			PixelFormat.B5G5R5A1_UNorm,
			PixelFormat.PVRTC_2BPP_RGB,
			PixelFormat.PVRTC_2BPP_RGBA,
			PixelFormat.PVRTC_2BPP_RGB_SRGB,
			PixelFormat.PVRTC_2BPP_RGBA_SRGBA,
			PixelFormat.ETC1_RGB8,
			PixelFormat.ETC2_RGBA,
			PixelFormat.ETC2_RGBA_SRGB:
			return 16;
		case PixelFormat.R8_Typeless,
			PixelFormat.R8_UNorm,
			PixelFormat.R8_UInt,
			PixelFormat.R8_SNorm,
			PixelFormat.R8_SInt,
			PixelFormat.A8_UNorm:
			return 8;
		case PixelFormat.Unknown,
			PixelFormat.R1_UNorm,
			PixelFormat.BC1_Typeless,
			PixelFormat.BC1_UNorm_SRgb,
			PixelFormat.BC2_Typeless,
			PixelFormat.BC2_UNorm_SRgb,
			PixelFormat.BC3_Typeless,
			PixelFormat.BC3_UNorm_SRgb,
			PixelFormat.BC4_Typeless,
			PixelFormat.BC4_UNorm,
			PixelFormat.BC4_SNorm,
			PixelFormat.BC5_Typeless,
			PixelFormat.BC5_UNorm,
			PixelFormat.BC5_SNorm,
			PixelFormat.BC6H_Typeless,
			PixelFormat.BC6H_Uf16,
			PixelFormat.BC6H_Sf16,
			PixelFormat.BC7_Typeless,
			PixelFormat.BC7_UNorm,
			PixelFormat.BC7_UNorm_SRgb,
			PixelFormat.AYUV,
			PixelFormat.Y410,
			PixelFormat.Y416,
			PixelFormat.NV12,
			PixelFormat.P010,
			PixelFormat.P016,
			PixelFormat.Opaque420,
			PixelFormat.YUY2,
			PixelFormat.Y210,
			PixelFormat.Y216,
			PixelFormat.NV11,
			PixelFormat.AI44,
			PixelFormat.IA44,
			PixelFormat.P8,
			PixelFormat.A8P8,
			PixelFormat.B4G4R4A4_UNorm,
			PixelFormat.P208,
			PixelFormat.V208,
			PixelFormat.V408,
			PixelFormat.R4G4B4A4:
			Runtime.FatalError();
		default:
			return 4;
		}
	}

	/// <summary>
	/// Gets the size in byte of a PixelFormat.
	/// </summary>
	/// <param name="format">The PixelFormat.</param>
	/// <returns>The size in bytes of the format.</returns>
	public static uint32 GetSizeInBytes(PixelFormat format)
	{
		switch (format)
		{
		case PixelFormat.R8_Typeless,
			PixelFormat.R8_UNorm,
			PixelFormat.R8_UInt,
			PixelFormat.R8_SNorm,
			PixelFormat.R8_SInt,
			PixelFormat.A8_UNorm:
			return 1;
		case PixelFormat.R8G8_Typeless,
			PixelFormat.R8G8_UNorm,
			PixelFormat.R8G8_UInt,
			PixelFormat.R8G8_SNorm,
			PixelFormat.R8G8_SInt,
			PixelFormat.R16_Typeless,
			PixelFormat.R16_Float,
			PixelFormat.D16_UNorm,
			PixelFormat.R16_UNorm,
			PixelFormat.R16_UInt,
			PixelFormat.R16_SNorm,
			PixelFormat.R16_SInt,
			PixelFormat.B5G6R5_UNorm,
			PixelFormat.B5G5R5A1_UNorm,
			PixelFormat.R4G4B4A4:
			return 2;
		case PixelFormat.R10G10B10A2_Typeless,
			PixelFormat.R10G10B10A2_UNorm,
			PixelFormat.R10G10B10A2_UInt,
			PixelFormat.R11G11B10_Float,
			PixelFormat.R8G8B8A8_Typeless,
			PixelFormat.R8G8B8A8_UNorm,
			PixelFormat.R8G8B8A8_UNorm_SRgb,
			PixelFormat.R8G8B8A8_UInt,
			PixelFormat.R8G8B8A8_SNorm,
			PixelFormat.R8G8B8A8_SInt,
			PixelFormat.R16G16_Typeless,
			PixelFormat.R16G16_Float,
			PixelFormat.R16G16_UNorm,
			PixelFormat.R16G16_UInt,
			PixelFormat.R16G16_SNorm,
			PixelFormat.R16G16_SInt,
			PixelFormat.R32_Typeless,
			PixelFormat.D32_Float,
			PixelFormat.R32_Float,
			PixelFormat.R32_UInt,
			PixelFormat.R32_SInt,
			PixelFormat.R24G8_Typeless,
			PixelFormat.D24_UNorm_S8_UInt,
			PixelFormat.R24_UNorm_X8_Typeless,
			PixelFormat.X24_Typeless_G8_UInt,
			PixelFormat.R9G9B9E5_Sharedexp,
			PixelFormat.R8G8_B8G8_UNorm,
			PixelFormat.G8R8_G8B8_UNorm,
			PixelFormat.B8G8R8A8_UNorm,
			PixelFormat.B8G8R8X8_UNorm,
			PixelFormat.R10G10B10_Xr_Bias_A2_UNorm,
			PixelFormat.B8G8R8A8_Typeless,
			PixelFormat.B8G8R8A8_UNorm_SRgb,
			PixelFormat.B8G8R8X8_Typeless,
			PixelFormat.B8G8R8X8_UNorm_SRgb:
			return 4;
		case PixelFormat.R16G16B16A16_Typeless,
			PixelFormat.R16G16B16A16_Float,
			PixelFormat.R16G16B16A16_UNorm,
			PixelFormat.R16G16B16A16_UInt,
			PixelFormat.R16G16B16A16_SNorm,
			PixelFormat.R16G16B16A16_SInt,
			PixelFormat.R32G32_Typeless,
			PixelFormat.R32G32_Float,
			PixelFormat.R32G32_UInt,
			PixelFormat.R32G32_SInt,
			PixelFormat.R32G8X24_Typeless,
			PixelFormat.D32_Float_S8X24_UInt,
			PixelFormat.R32_Float_X8X24_Typeless,
			PixelFormat.X32_Typeless_G8X24_UInt:
			return 8;
		case PixelFormat.R32G32B32_Typeless,
			PixelFormat.R32G32B32_Float,
			PixelFormat.R32G32B32_UInt,
			PixelFormat.R32G32B32_SInt:
			return 12;
		case PixelFormat.R32G32B32A32_Typeless,
			PixelFormat.R32G32B32A32_Float,
			PixelFormat.R32G32B32A32_UInt,
			PixelFormat.R32G32B32A32_SInt:
			return 16;
		default:
			Runtime.InvalidOperationError("Invalid pixel format.");
		}
	}

	/// <summary>
	/// Gets the size in bytes of a block.
	/// </summary>
	/// <param name="format">The pixel format.</param>
	/// <returns>The size in bytes.</returns>
	public static uint32 GetBlockSizeInBytes(PixelFormat format)
	{
		switch (format)
		{
		case PixelFormat.BC1_UNorm,
			PixelFormat.BC1_UNorm_SRgb,
			PixelFormat.BC4_UNorm,
			PixelFormat.BC4_SNorm,
			PixelFormat.PVRTC_2BPP_RGB,
			PixelFormat.PVRTC_2BPP_RGBA,
			PixelFormat.PVRTC_2BPP_RGB_SRGB,
			PixelFormat.PVRTC_2BPP_RGBA_SRGBA,
			PixelFormat.ETC1_RGB8:
			return 8;
		case PixelFormat.BC2_UNorm,
			PixelFormat.BC2_UNorm_SRgb,
			PixelFormat.BC3_UNorm,
			PixelFormat.BC3_UNorm_SRgb,
			PixelFormat.BC5_UNorm,
			PixelFormat.BC5_SNorm,
			PixelFormat.BC6H_Uf16,
			PixelFormat.BC6H_Sf16,
			PixelFormat.BC7_UNorm,
			PixelFormat.BC7_UNorm_SRgb,
			PixelFormat.PVRTC_4BPP_RGB,
			PixelFormat.PVRTC_4BPP_RGBA,
			PixelFormat.PVRTC_4BPP_RGB_SRGB,
			PixelFormat.PVRTC_4BPP_RGBA_SRGBA,
			PixelFormat.ETC2_RGBA,
			PixelFormat.ETC2_RGBA_SRGB:
			return 16;
		default:
			Runtime.InvalidOperationError("Invalid pixel format.");
		}
	}

	/// <summary>
	/// Returns a value indicating if the PixelFormat is a compressed one.
	/// </summary>
	/// <param name="format">The pixel format.</param>
	/// <returns>True if the pixel format represents a compressed one. False otherwise.</returns>
	public static bool IsCompressedFormat(PixelFormat format)
	{
		if (format != PixelFormat.BC1_UNorm
			&& format != PixelFormat.BC1_UNorm_SRgb
			&& format != PixelFormat.BC4_UNorm
			&& format != PixelFormat.BC4_SNorm
			&& format != PixelFormat.ETC1_RGB8
			&& format != PixelFormat.BC2_UNorm
			&& format != PixelFormat.BC2_UNorm_SRgb
			&& format != PixelFormat.BC3_UNorm
			&& format != PixelFormat.BC3_UNorm_SRgb
			&& format != PixelFormat.BC5_UNorm
			&& format != PixelFormat.BC5_SNorm
			&& format != PixelFormat.BC6H_Uf16
			&& format != PixelFormat.BC6H_Sf16
			&& format != PixelFormat.BC7_UNorm
			&& format != PixelFormat.BC7_UNorm_SRgb
			&& format != PixelFormat.ETC1_RGB8
			&& format != PixelFormat.ETC2_RGBA
			&& format != PixelFormat.ETC2_RGBA_SRGB
			&& format != PixelFormat.PVRTC_2BPP_RGB
			&& format != PixelFormat.PVRTC_2BPP_RGBA
			&& format != PixelFormat.PVRTC_2BPP_RGB_SRGB
			&& format != PixelFormat.PVRTC_2BPP_RGBA_SRGBA
			&& format != PixelFormat.PVRTC_4BPP_RGB
			&& format != PixelFormat.PVRTC_4BPP_RGBA
			&& format != PixelFormat.PVRTC_4BPP_RGB_SRGB)
		{
			return format == PixelFormat.PVRTC_4BPP_RGBA_SRGBA;
		}
		return true;
	}

	/// <summary>
	/// Gets a value indicating if the PixelFormat can be used as stencil pixel format.
	/// </summary>
	/// <param name="format">The pixel format.</param>
	/// <returns>True if the format can be used as stencil. False otherwise.</returns>
	public static bool IsStencilFormat(PixelFormat format)
	{
		if ((uint32)(format - 19) <= 1 || (uint32)(format - 44) <= 1)
		{
			return true;
		}
		return false;
	}

	/// <summary>
	/// Gets the size of a row with a specified size and format.
	/// </summary>
	/// <param name="width">The row size.</param>
	/// <param name="format">The row PixelFormat.</param>
	/// <returns>The row pitch.</returns>
	public static uint32 GetRowPitch(uint32 width, PixelFormat format)
	{
		if (IsCompressedFormat(format))
		{
			uint32 num = (width + 3) / 4;
			uint32 blockSizeInBytes = GetBlockSizeInBytes(format);
			return num * blockSizeInBytes;
		}
		return width * GetSizeInBytes(format);
	}

	/// <summary>
	/// Gets the number of rows, depending of the height and the pixel format.
	/// </summary>
	/// <param name="height">The height.</param>
	/// <param name="format">The pixel format.</param>
	/// <returns>The number of rows.</returns>
	public static uint32 GetNumRows(uint32 height, PixelFormat format)
	{
		if (IsCompressedFormat(format))
		{
			return (height + 3) / 4;
		}
		return height;
	}

	/// <summary>
	/// Gets the slice pitch.
	/// </summary>
	/// <param name="rowPitch">The row pitch.</param>
	/// <param name="height">The height.</param>
	/// <param name="format">The pixel format.</param>
	/// <returns>The slice pitch.</returns>
	public static uint32 GetSlicePitch(uint32 rowPitch, uint32 height, PixelFormat format)
	{
		return rowPitch * GetNumRows(height, format);
	}

	/// <summary>
	/// Gets the dimension size of a specified mip level.
	/// </summary>
	/// <param name="largestLevelDimension">The largest level dimension.</param>
	/// <param name="mipLevel">The mip level.</param>
	/// <returns>The dimension of the current mip level.</returns>
	public static uint32 GetDimension(uint32 largestLevelDimension, uint32 mipLevel)
	{
		uint32 result = (uint32)((int32)largestLevelDimension >> (int32)mipLevel);
		return Math.Max(1, result);
	}

	/// <summary>
	/// Gets the sub resource info of a Texture.
	/// </summary>
	/// <param name="description">The texture info.</param>
	/// <param name="subResource">The subResource id.</param>
	/// <returns>The SubResource Info.</returns>
	public static SubResourceInfo GetSubResourceInfo(TextureDescription description, uint32 subResource)
	{
		GetMipLevelAndArrayLayer(description, subResource, var miplevel, var arrayLayer);
		GetMipDimensions(description, miplevel, var mipWidth, var mipHeight, var mipDepth);
		uint32 rowPitch = GetRowPitch(mipWidth, description.Format);
		uint32 slicePitch = GetSlicePitch(rowPitch, mipHeight, description.Format);

		SubResourceInfo info = default(SubResourceInfo);
		info.MipWidth = mipWidth;
		info.MipHeight = mipHeight;
		info.MipDepth = mipDepth;
		info.RowPitch = rowPitch;
		info.SlicePitch = slicePitch;
		info.MipLevel = miplevel;
		info.ArrayLayer = arrayLayer;
		info.Offset = ComputeSubResourceOffset(description, subResource);
		info.SizeInBytes = slicePitch * mipDepth;
		return info;
	}

	/// <summary>
	/// Calculates the SubResource offset of a Texture.
	/// </summary>
	/// <param name="description">The Texture description.</param>
	/// <param name="subResource">The SubResource index.</param>
	/// <returns>The SubResource offset.</returns>
	public static uint64 ComputeSubResourceOffset(TextureDescription description, uint32 subResource)
	{
		GetMipLevelAndArrayLayer(description, subResource, var mipLevel, var arrayLayer);
		uint32 mipOffset = ComputeMipOffset(description, mipLevel);
		return ComputeLayerOffset(description, arrayLayer) + mipOffset;
	}

	/// <summary>
	/// Computes the MipMap offset.
	/// </summary>
	/// <param name="description">The TextureDescription.</param>
	/// <param name="mipLevel">The MipMap Level.</param>
	/// <returns>The mip offset.</returns>
	public static uint32 ComputeMipOffset(TextureDescription description, uint32 mipLevel)
	{
		uint32 blockSize = ((!IsCompressedFormat(description.Format)) ? 1 : 4);
		uint32 offset = 0;
		for (uint32 level = 0; level < mipLevel; level++)
		{
			GetMipDimensions(description, level, var mipWidth, var mipHeight, var mipDepth);
			uint32 storageWidth = Math.Max(mipWidth, blockSize);
			uint32 storageHeight = Math.Max(mipHeight, blockSize);
			offset += GetRegionSize(storageWidth, storageHeight, mipDepth, description.Format);
		}
		return offset;
	}

	/// <summary>
	/// Computes the Layer offset.
	/// </summary>
	/// <param name="description">The TextureDescription.</param>
	/// <param name="arrayLayer">The array layer.</param>
	/// <returns>The Layer offset.</returns>
	public static uint32 ComputeLayerOffset(TextureDescription description, uint32 arrayLayer)
	{
		uint32 offset = 0;
		if (arrayLayer != 0)
		{
			uint32 blockSize = ((!IsCompressedFormat(description.Format)) ? 1 : 4);
			for (uint32 level = 0; level < description.MipLevels; level++)
			{
				GetMipDimensions(description, level, var mipWidth, var mipHeight, var mipDepth);
				uint32 storageWidth = Math.Max(mipWidth, blockSize);
				uint32 storageHeight = Math.Max(mipHeight, blockSize);
				offset += GetRegionSize(storageWidth, storageHeight, mipDepth, description.Format);
			}
		}
		return offset;
	}

	/// <summary>
	/// Computes the Texture Size in bytes of a Texture Description.
	/// </summary>
	/// <param name="description">The Texture Description.</param>
	/// <returns>The size in bytes of the texture.</returns>
	public static uint32 ComputeTextureSize(TextureDescription description)
	{
		uint32 size = 0;
		for (uint32 i = 0; i < description.MipLevels; i++)
		{
			GetMipDimensions(description, i, var mipWidth, var mipHeight, var mipDepth);
			uint32 slicePitch = GetSlicePitch(GetRowPitch(mipWidth, description.Format), mipHeight, description.Format);
			size += slicePitch * mipDepth;
		}
		return size * description.ArraySize * description.Faces;
	}

	/// <summary>
	/// Gets the block size in bytes of a texture.
	/// </summary>
	/// <param name="width">The texture width.</param>
	/// <param name="height">The texture height.</param>
	/// <param name="depth">The texture depth.</param>
	/// <param name="format">The texture pixel format.</param>
	/// <returns>The size in bytes of the block region.</returns>
	public static uint32 GetRegionSize(uint32 width, uint32 height, uint32 depth, PixelFormat format)
	{
		var width;
		var height;
		uint32 blockSizeInBytes;
		if (IsCompressedFormat(format))
		{
			blockSizeInBytes = GetBlockSizeInBytes(format);
			width /= 4;
			height /= 4;
		}
		else
		{
			blockSizeInBytes = GetSizeInBytes(format);
		}
		return width * height * depth * blockSizeInBytes;
	}

	/// <summary>
	/// Calculates the sub resource index.
	/// </summary>
	/// <param name="description">The texture description.</param>
	/// <param name="mipLevel">The mipmap level.</param>
	/// <param name="arrayLayer">The array layer index.</param>
	/// <returns>The id of the sub resource.</returns>
	public static uint32 CalculateSubResource(TextureDescription description, uint32 mipLevel, uint32 arrayLayer)
	{
		return arrayLayer * description.MipLevels + mipLevel;
	}

	/// <summary>
	/// Gets the Mip Level and the Array Layer of a texture sub resource.
	/// </summary>
	/// <param name="description">The Texture Description.</param>
	/// <param name="subResource">The sub resource of the texture.</param>
	/// <param name="mipLevel">The Mip Level.</param>
	/// <param name="arrayLayer">The Array Layer.</param>
	public static void GetMipLevelAndArrayLayer(TextureDescription description, uint32 subResource, out uint32 mipLevel, out uint32 arrayLayer)
	{
		arrayLayer = subResource / description.MipLevels;
		mipLevel = subResource - arrayLayer * description.MipLevels;
	}

	/// <summary>
	/// Gets the mip level dimensions.
	/// </summary>
	/// <param name="description">The texture description.</param>
	/// <param name="mipLevel">The texture mip Level.</param>
	/// <param name="width">The texture width.</param>
	/// <param name="height">The texture height.</param>
	/// <param name="depth">The texture depth.</param>
	public static void GetMipDimensions(TextureDescription description, uint32 mipLevel, out uint32 width, out uint32 height, out uint32 depth)
	{
		if (mipLevel == 0)
		{
			width = description.Width;
			height = description.Height;
			depth = description.Depth;
		}
		else
		{
			width = GetDimension(description.Width, mipLevel);
			height = GetDimension(description.Height, mipLevel);
			depth = GetDimension(description.Depth, mipLevel);
		}
	}

	/// <summary>
	/// Gets the mip level dimensions.
	/// </summary>
	/// <param name="width">Texture Width.</param>
	/// <param name="height">Texture Height.</param>
	/// <returns>Mip levels.</returns>
	public static uint32 GetMipLevels(uint32 width, uint32 height)
	{
		uint32 w = width;
		uint32 h = height;
		uint32 mipLevel = 0;
		while (w != 0 && h != 0)
		{
			w /= 2;
			h /= 2;
			mipLevel++;
		}
		return mipLevel;
	}

	/// <summary>
	/// Transform the given value to conform to an specified <see cref="T:Sedulous.RHI.TextureAddressMode" />.
	/// </summary>
	/// <param name="value">The value to transform.</param>
	/// <param name="addressMode">The address mode.</param>
	public static void ApplyAddressMode(ref float value, TextureAddressMode addressMode)
	{
		switch (addressMode)
		{
		case TextureAddressMode.Wrap:
			value %= 1f;
			if (value < 0f)
			{
				value += 1f;
			}
			break;
		case TextureAddressMode.Mirror:
			if ((int32)value % 2 != 0)
			{
				value = 1f - value % 1f;
			}
			break;
		case TextureAddressMode.Mirror_One:
			value = MathUtil.Clamp(value, -1f, 1f);
			break;
		default:
			value = MathUtil.Clamp(value, 0f, 1f);
			break;
		}
	}
}
