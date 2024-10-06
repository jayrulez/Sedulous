using System;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI;

/// <summary>
/// Miscellaneous helper methods for graphic operations.
/// </summary>
public static class Helpers
{
	/// <summary>
	/// Aligns the size in bytes to the nearest multiple of 256.
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
	/// Aligns the size in bytes to the nearest multiple of the alignment value specified by the parameter.
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
	/// Aligns the size in bytes to the nearest multiple of the alignment value specified by the parameter.
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
	/// Ensures the array size.
	/// </summary>
	/// <typeparam name="T">The type of the array items.</typeparam>
	/// <param name="array">The array.</param>
	/// <param name="size">The size.</param>
	public static void EnsureArraySize<T>(ref T[] array, int32 size)
	{
		if (array == null)
		{
			array = new T[size];
		}
		else if (array.Count != size)
		{
			Array.Resize(ref array, size);
		}
	}

	/// <summary>
	/// Ensures the size of the array.
	/// </summary>
	/// <typeparam name="T">The type of the array items.</typeparam>
	/// <param name="array">The array.</param>
	/// <param name="size">The required size.</param>
	public static void CheckArrayCapacity<T>(ref T[] array, int32 size)
	{
		if (array == null)
		{
			array = new T[size];
		}
		else if (array.Count < size)
		{
			Array.Resize(ref array, size);
		}
	}

	/// <summary>
	/// Gets the size in bytes of a PixelFormat.
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
	/// <returns>True if the pixel format represents a compressed format. False otherwise.</returns>
	public static bool IsCompressedFormat(PixelFormat format)
	{
		if (format != PixelFormat.BC1_UNorm && format != PixelFormat.BC1_UNorm_SRgb && format != PixelFormat.BC4_UNorm && format != PixelFormat.BC4_SNorm && format != PixelFormat.ETC1_RGB8 && format != PixelFormat.BC2_UNorm && format != PixelFormat.BC2_UNorm_SRgb && format != PixelFormat.BC3_UNorm && format != PixelFormat.BC3_UNorm_SRgb && format != PixelFormat.BC5_UNorm && format != PixelFormat.BC5_SNorm && format != PixelFormat.BC6H_Uf16 && format != PixelFormat.BC6H_Sf16 && format != PixelFormat.BC7_UNorm && format != PixelFormat.BC7_UNorm_SRgb && format != PixelFormat.ETC1_RGB8 && format != PixelFormat.ETC2_RGBA && format != PixelFormat.ETC2_RGBA_SRGB && format != PixelFormat.PVRTC_2BPP_RGB && format != PixelFormat.PVRTC_2BPP_RGBA && format != PixelFormat.PVRTC_2BPP_RGB_SRGB && format != PixelFormat.PVRTC_2BPP_RGBA_SRGBA && format != PixelFormat.PVRTC_4BPP_RGB && format != PixelFormat.PVRTC_4BPP_RGBA && format != PixelFormat.PVRTC_4BPP_RGB_SRGB)
		{
			return format == PixelFormat.PVRTC_4BPP_RGBA_SRGBA;
		}
		return true;
	}

	/// <summary>
	/// Gets a value indicating whether the PixelFormat can be used as a stencil pixel format.
	/// </summary>
	/// <param name="format">The pixel format.</param>
	/// <returns>True if the format can be used as a stencil; false otherwise.</returns>
	public static bool IsStencilFormat(PixelFormat format)
	{
		if ((uint32)(format - 19) <= 1 || (uint32)(format - 44) <= 1)
		{
			return true;
		}
		return false;
	}

	/// <summary>
	/// Gets the size of a row with a specified width and format.
	/// </summary>
	/// <param name="width">The width of the row.</param>
	/// <param name="format">The PixelFormat of the row.</param>
	/// <returns>The pitch of the row.</returns>
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
	/// Gets the number of rows, depending on the height and the pixel format.
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
	/// <returns>The dimension size of the specified mip level.</returns>
	public static uint32 GetDimension(uint32 largestLevelDimension, uint32 mipLevel)
	{
		uint32 result = (uint32)((int32)largestLevelDimension >> (int32)mipLevel);
		return Math.Max(1, result);
	}

	/// <summary>
	/// Gets the subresource info of a texture.
	/// </summary>
	/// <param name="description">The texture info.</param>
	/// <param name="subResource">The subresource ID.</param>
	/// <returns>The subresource info.</returns>
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
	/// Calculates the subresource offset of a texture.
	/// </summary>
	/// <param name="description">The texture description.</param>
	/// <param name="subResource">The subresource index.</param>
	/// <returns>The subresource offset.</returns>
	public static uint64 ComputeSubResourceOffset(TextureDescription description, uint32 subResource)
	{
		GetMipLevelAndArrayLayer(description, subResource, var mipLevel, var arrayLayer);
		uint32 mipOffset = ComputeMipOffset(description, mipLevel);
		return ComputeLayerOffset(description, arrayLayer) + mipOffset;
	}

	/// <summary>
	/// Computes the MipMap offset.
	/// </summary>
	/// <param name="description">The texture description.</param>
	/// <param name="mipLevel">The mipmap level.</param>
	/// <returns>The MipMap offset.</returns>
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
	/// Computes the layer offset.
	/// </summary>
	/// <param name="description">The texture description.</param>
	/// <param name="arrayLayer">The array layer.</param>
	/// <returns>The layer offset.</returns>
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
	/// Computes the texture size in bytes from a texture description.
	/// </summary>
	/// <param name="description">The texture description.</param>
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
	/// Calculates the subresource index.
	/// </summary>
	/// <param name="description">The texture description.</param>
	/// <param name="mipLevel">The mipmap level.</param>
	/// <param name="arrayLayer">The array layer index.</param>
	/// <returns>The ID of the subresource.</returns>
	public static uint32 CalculateSubResource(TextureDescription description, uint32 mipLevel, uint32 arrayLayer)
	{
		return arrayLayer * description.MipLevels + mipLevel;
	}

	/// <summary>
	/// Gets the mip level and the array layer of a texture subresource.
	/// </summary>
	/// <param name="description">The texture description.</param>
	/// <param name="subResource">The subresource of the texture.</param>
	/// <param name="mipLevel">The mip level.</param>
	/// <param name="arrayLayer">The array layer.</param>
	public static void GetMipLevelAndArrayLayer(TextureDescription description, uint32 subResource, out uint32 mipLevel, out uint32 arrayLayer)
	{
		arrayLayer = subResource / description.MipLevels;
		mipLevel = subResource - arrayLayer * description.MipLevels;
	}

	/// <summary>
	/// Gets the mip level dimensions.
	/// </summary>
	/// <param name="description">The texture description.</param>
	/// <param name="mipLevel">The texture mip level.</param>
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
	/// Transforms the given value to conform to a specified <see cref="T:Sedulous.RHI.TextureAddressMode" />.
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
