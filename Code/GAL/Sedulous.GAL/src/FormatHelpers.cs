using System;
using System.Diagnostics;

namespace Sedulous.GAL
{
	internal static class FormatHelpers
	{
		public static int32 GetElementCount(VertexElementFormat format)
		{
			switch (format)
			{
			case VertexElementFormat.Float1,
				VertexElementFormat.UInt1,
				VertexElementFormat.Int1,
				VertexElementFormat.Half1:
				return 1;
			case VertexElementFormat.Float2,
				VertexElementFormat.Byte2_Norm,
				VertexElementFormat.Byte2,
				VertexElementFormat.SByte2_Norm,
				VertexElementFormat.SByte2,
				VertexElementFormat.UShort2_Norm,
				VertexElementFormat.UShort2,
				VertexElementFormat.Short2_Norm,
				VertexElementFormat.Short2,
				VertexElementFormat.UInt2,
				VertexElementFormat.Int2,
				VertexElementFormat.Half2:
				return 2;
			case VertexElementFormat.Float3,
				VertexElementFormat.UInt3,
				VertexElementFormat.Int3:
				return 3;
			case VertexElementFormat.Float4,
				VertexElementFormat.Byte4_Norm,
				VertexElementFormat.Byte4,
				VertexElementFormat.SByte4_Norm,
				VertexElementFormat.SByte4,
				VertexElementFormat.UShort4_Norm,
				VertexElementFormat.UShort4,
				VertexElementFormat.Short4_Norm,
				VertexElementFormat.Short4,
				VertexElementFormat.UInt4,
				VertexElementFormat.Int4,
				VertexElementFormat.Half4:
				return 4;
			default:
				Runtime.IllegalValue<VertexElementFormat>();
			}
		}

		internal static uint32 GetSampleCountUInt32(TextureSampleCount sampleCount)
		{
			switch (sampleCount)
			{
			case TextureSampleCount.Count1:
				return 1;
			case TextureSampleCount.Count2:
				return 2;
			case TextureSampleCount.Count4:
				return 4;
			case TextureSampleCount.Count8:
				return 8;
			case TextureSampleCount.Count16:
				return 16;
			case TextureSampleCount.Count32:
				return 32;
			default:
				Runtime.IllegalValue<TextureSampleCount>();
			}
		}

		internal static bool IsStencilFormat(PixelFormat format)
		{
			return format == PixelFormat.D24_UNorm_S8_UInt || format == PixelFormat.D32_Float_S8_UInt;
		}

		internal static bool IsDepthStencilFormat(PixelFormat format)
		{
			return format == PixelFormat.D32_Float_S8_UInt
				|| format == PixelFormat.D24_UNorm_S8_UInt
				|| format == PixelFormat.R16_UNorm
				|| format == PixelFormat.R32_Float;
		}

		internal static bool IsCompressedFormat(PixelFormat format)
		{
			return format == PixelFormat.BC1_Rgb_UNorm
				|| format == PixelFormat.BC1_Rgb_UNorm_SRgb
				|| format == PixelFormat.BC1_Rgba_UNorm
				|| format == PixelFormat.BC1_Rgba_UNorm_SRgb
				|| format == PixelFormat.BC2_UNorm
				|| format == PixelFormat.BC2_UNorm_SRgb
				|| format == PixelFormat.BC3_UNorm
				|| format == PixelFormat.BC3_UNorm_SRgb
				|| format == PixelFormat.BC4_UNorm
				|| format == PixelFormat.BC4_SNorm
				|| format == PixelFormat.BC5_UNorm
				|| format == PixelFormat.BC5_SNorm
				|| format == PixelFormat.BC7_UNorm
				|| format == PixelFormat.BC7_UNorm_SRgb
				|| format == PixelFormat.ETC2_R8_G8_B8_UNorm
				|| format == PixelFormat.ETC2_R8_G8_B8_A1_UNorm
				|| format == PixelFormat.ETC2_R8_G8_B8_A8_UNorm;
		}

		internal static uint32 GetRowPitch(uint32 width, PixelFormat format)
		{
			switch (format)
			{
			case PixelFormat.BC1_Rgb_UNorm,
				PixelFormat.BC1_Rgb_UNorm_SRgb,
				PixelFormat.BC1_Rgba_UNorm,
				PixelFormat.BC1_Rgba_UNorm_SRgb,
				PixelFormat.BC2_UNorm,
				PixelFormat.BC2_UNorm_SRgb,
				PixelFormat.BC3_UNorm,
				PixelFormat.BC3_UNorm_SRgb,
				PixelFormat.BC4_UNorm,
				PixelFormat.BC4_SNorm,
				PixelFormat.BC5_UNorm,
				PixelFormat.BC5_SNorm,
				PixelFormat.BC7_UNorm,
				PixelFormat.BC7_UNorm_SRgb,
				PixelFormat.ETC2_R8_G8_B8_UNorm,
				PixelFormat.ETC2_R8_G8_B8_A1_UNorm,
				PixelFormat.ETC2_R8_G8_B8_A8_UNorm:
				var blocksPerRow = (width + 3) / 4;
				var blockSizeInBytes = GetBlockSizeInBytes(format);
				return blocksPerRow * blockSizeInBytes;

			default:
				return width * FormatSizeHelpers.GetSizeInBytes(format);
			}
		}

		public static uint32 GetBlockSizeInBytes(PixelFormat format)
		{
			switch (format)
			{
			case PixelFormat.BC1_Rgb_UNorm,
				PixelFormat.BC1_Rgb_UNorm_SRgb,
				PixelFormat.BC1_Rgba_UNorm,
				PixelFormat.BC1_Rgba_UNorm_SRgb,
				PixelFormat.BC4_UNorm,
				PixelFormat.BC4_SNorm,
				PixelFormat.ETC2_R8_G8_B8_UNorm,
				PixelFormat.ETC2_R8_G8_B8_A1_UNorm:
				return 8;
			case PixelFormat.BC2_UNorm,
				PixelFormat.BC2_UNorm_SRgb,
				PixelFormat.BC3_UNorm,
				PixelFormat.BC3_UNorm_SRgb,
				PixelFormat.BC5_UNorm,
				PixelFormat.BC5_SNorm,
				PixelFormat.BC7_UNorm,
				PixelFormat.BC7_UNorm_SRgb,
				PixelFormat.ETC2_R8_G8_B8_A8_UNorm:
				return 16;
			default:
				Runtime.IllegalValue<PixelFormat>();
			}
		}

		internal static bool IsFormatViewCompatible(PixelFormat viewFormat, PixelFormat realFormat)
		{
			if (IsCompressedFormat(realFormat))
			{
				return IsSrgbCounterpart(viewFormat, realFormat);
			}
			else
			{
				return GetViewFamilyFormat(viewFormat) == GetViewFamilyFormat(realFormat);
			}
		}

		private static bool IsSrgbCounterpart(PixelFormat viewFormat, PixelFormat realFormat)
		{
			Runtime.NotImplementedError();
		}

		internal static uint32 GetNumRows(uint32 height, PixelFormat format)
		{
			switch (format)
			{
			case PixelFormat.BC1_Rgb_UNorm,
				PixelFormat.BC1_Rgb_UNorm_SRgb,
				PixelFormat.BC1_Rgba_UNorm,
				PixelFormat.BC1_Rgba_UNorm_SRgb,
				PixelFormat.BC2_UNorm,
				PixelFormat.BC2_UNorm_SRgb,
				PixelFormat.BC3_UNorm,
				PixelFormat.BC3_UNorm_SRgb,
				PixelFormat.BC4_UNorm,
				PixelFormat.BC4_SNorm,
				PixelFormat.BC5_UNorm,
				PixelFormat.BC5_SNorm,
				PixelFormat.BC7_UNorm,
				PixelFormat.BC7_UNorm_SRgb,
				PixelFormat.ETC2_R8_G8_B8_UNorm,
				PixelFormat.ETC2_R8_G8_B8_A1_UNorm,
				PixelFormat.ETC2_R8_G8_B8_A8_UNorm:
				return (height + 3) / 4;

			default:
				return height;
			}
		}

		internal static uint32 GetDepthPitch(uint32 rowPitch, uint32 height, PixelFormat format)
		{
			return rowPitch * GetNumRows(height, format);
		}

		internal static uint32 GetRegionSize(uint32 width, uint32 height, uint32 depth, PixelFormat format)
		{
			var width;
			var height;
			uint32 blockSizeInBytes;
			if (IsCompressedFormat(format))
			{
				Debug.Assert((width % 4 == 0 || width < 4) && (height % 4 == 0 || height < 4));
				blockSizeInBytes = GetBlockSizeInBytes(format);
				width /= 4;
				height /= 4;
			}
			else
			{
				blockSizeInBytes = FormatSizeHelpers.GetSizeInBytes(format);
			}

			return width * height * depth * blockSizeInBytes;
		}

		internal static TextureSampleCount GetSampleCount(uint32 samples)
		{
			switch (samples)
			{
			case 1: return TextureSampleCount.Count1;
			case 2: return TextureSampleCount.Count2;
			case 4: return TextureSampleCount.Count4;
			case 8: return TextureSampleCount.Count8;
			case 16: return TextureSampleCount.Count16;
			case 32: return TextureSampleCount.Count32;
			default: Runtime.GALError(scope $"Unsupported multisample count: {samples}");
			}
		}

		internal static PixelFormat GetViewFamilyFormat(PixelFormat format)
		{
			switch (format)
			{
			case PixelFormat.R32_G32_B32_A32_Float,
				PixelFormat.R32_G32_B32_A32_UInt,
				PixelFormat.R32_G32_B32_A32_SInt:
				return PixelFormat.R32_G32_B32_A32_Float;
			case PixelFormat.R16_G16_B16_A16_Float,
				PixelFormat.R16_G16_B16_A16_UNorm,
				PixelFormat.R16_G16_B16_A16_UInt,
				PixelFormat.R16_G16_B16_A16_SNorm,
				PixelFormat.R16_G16_B16_A16_SInt:
				return PixelFormat.R16_G16_B16_A16_Float;
			case PixelFormat.R32_G32_Float,
				PixelFormat.R32_G32_UInt,
				PixelFormat.R32_G32_SInt:
				return PixelFormat.R32_G32_Float;
			case PixelFormat.R10_G10_B10_A2_UNorm,
				PixelFormat.R10_G10_B10_A2_UInt:
				return PixelFormat.R10_G10_B10_A2_UNorm;
			case PixelFormat.R8_G8_B8_A8_UNorm,
				PixelFormat.R8_G8_B8_A8_UNorm_SRgb,
				PixelFormat.R8_G8_B8_A8_UInt,
				PixelFormat.R8_G8_B8_A8_SNorm,
				PixelFormat.R8_G8_B8_A8_SInt:
				return PixelFormat.R8_G8_B8_A8_UNorm;
			case PixelFormat.R16_G16_Float,
				PixelFormat.R16_G16_UNorm,
				PixelFormat.R16_G16_UInt,
				PixelFormat.R16_G16_SNorm,
				PixelFormat.R16_G16_SInt:
				return PixelFormat.R16_G16_Float;
			case PixelFormat.R32_Float,
				PixelFormat.R32_UInt,
				PixelFormat.R32_SInt:
				return PixelFormat.R32_Float;
			case PixelFormat.R8_G8_UNorm,
				PixelFormat.R8_G8_UInt,
				PixelFormat.R8_G8_SNorm,
				PixelFormat.R8_G8_SInt:
				return PixelFormat.R8_G8_UNorm;
			case PixelFormat.R16_Float,
				PixelFormat.R16_UNorm,
				PixelFormat.R16_UInt,
				PixelFormat.R16_SNorm,
				PixelFormat.R16_SInt:
				return PixelFormat.R16_Float;
			case PixelFormat.R8_UNorm,
				PixelFormat.R8_UInt,
				PixelFormat.R8_SNorm,
				PixelFormat.R8_SInt:
				return PixelFormat.R8_UNorm;
			case PixelFormat.BC1_Rgba_UNorm,
				PixelFormat.BC1_Rgba_UNorm_SRgb,
				PixelFormat.BC1_Rgb_UNorm,
				PixelFormat.BC1_Rgb_UNorm_SRgb:
				return PixelFormat.BC1_Rgba_UNorm;
			case PixelFormat.BC2_UNorm,
				PixelFormat.BC2_UNorm_SRgb:
				return PixelFormat.BC2_UNorm;
			case PixelFormat.BC3_UNorm,
				PixelFormat.BC3_UNorm_SRgb:
				return PixelFormat.BC3_UNorm;
			case PixelFormat.BC4_UNorm,
				PixelFormat.BC4_SNorm:
				return PixelFormat.BC4_UNorm;
			case PixelFormat.BC5_UNorm,
				PixelFormat.BC5_SNorm:
				return PixelFormat.BC5_UNorm;
			case PixelFormat.B8_G8_R8_A8_UNorm,
				PixelFormat.B8_G8_R8_A8_UNorm_SRgb:
				return PixelFormat.B8_G8_R8_A8_UNorm;
			case PixelFormat.BC7_UNorm,
				PixelFormat.BC7_UNorm_SRgb:
				return PixelFormat.BC7_UNorm;
			default:
				return format;
			}
		}
	}
}
