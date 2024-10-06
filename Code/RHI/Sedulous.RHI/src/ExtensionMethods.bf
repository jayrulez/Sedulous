using System;

namespace Sedulous.RHI;

/// <summary>
/// Extension methods.
/// </summary>
public static class ExtensionMethods
{
	/// <summary>
	/// Indicates if this format is in Gamma Color Space.
	/// </summary>
	/// <param name="format">Pixel format.</param>
	/// <returns>Indicates if it is in gamma space.</returns>
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
	/// Gets format size in bits.
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
}
