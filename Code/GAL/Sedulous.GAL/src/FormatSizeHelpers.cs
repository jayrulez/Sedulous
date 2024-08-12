using System.Diagnostics;
using System;

namespace Sedulous.GAL
{
	public static class FormatSizeHelpers
	{
		/// <summary>
		/// Given a pixel format, returns the number of bytes required to store
		/// a single pixel.
		/// Compressed formats may not be used with this method as the number of
		/// bytes per pixel is variable.
		/// </summary>
		/// <param name="format">An uncompressed pixel format</param>
		/// <returns>The number of bytes required to store a single pixel in the given format</returns>
		public static uint32 GetSizeInBytes(PixelFormat format)
		{
			switch (format)
			{
			case PixelFormat.R8_UNorm,
				PixelFormat.R8_SNorm,
				PixelFormat.R8_UInt,
				PixelFormat.R8_SInt:
				return 1;

			case PixelFormat.R16_UNorm,
				PixelFormat.R16_SNorm,
				PixelFormat.R16_UInt,
				PixelFormat.R16_SInt,
				PixelFormat.R16_Float,
				PixelFormat.R8_G8_UNorm,
				PixelFormat.R8_G8_SNorm,
				PixelFormat.R8_G8_UInt,
				PixelFormat.R8_G8_SInt:
				return 2;

			case PixelFormat.R32_UInt,
				PixelFormat.R32_SInt,
				PixelFormat.R32_Float,
				PixelFormat.R16_G16_UNorm,
				PixelFormat.R16_G16_SNorm,
				PixelFormat.R16_G16_UInt,
				PixelFormat.R16_G16_SInt,
				PixelFormat.R16_G16_Float,
				PixelFormat.R8_G8_B8_A8_UNorm,
				PixelFormat.R8_G8_B8_A8_UNorm_SRgb,
				PixelFormat.R8_G8_B8_A8_SNorm,
				PixelFormat.R8_G8_B8_A8_UInt,
				PixelFormat.R8_G8_B8_A8_SInt,
				PixelFormat.B8_G8_R8_A8_UNorm,
				PixelFormat.B8_G8_R8_A8_UNorm_SRgb,
				PixelFormat.R10_G10_B10_A2_UNorm,
				PixelFormat.R10_G10_B10_A2_UInt,
				PixelFormat.R11_G11_B10_Float,
				PixelFormat.D24_UNorm_S8_UInt:
				return 4;

			case PixelFormat.D32_Float_S8_UInt:
				return 5;

			case PixelFormat.R16_G16_B16_A16_UNorm,
				PixelFormat.R16_G16_B16_A16_SNorm,
				PixelFormat.R16_G16_B16_A16_UInt,
				PixelFormat.R16_G16_B16_A16_SInt,
				PixelFormat.R16_G16_B16_A16_Float,
				PixelFormat.R32_G32_UInt,
				PixelFormat.R32_G32_SInt,
				PixelFormat.R32_G32_Float:
				return 8;

			case PixelFormat.R32_G32_B32_A32_Float,
				PixelFormat.R32_G32_B32_A32_UInt,
				PixelFormat.R32_G32_B32_A32_SInt:
				return 16;

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
				Debug.WriteLine("GetSizeInBytes should not be used on a compressed format.");
				Runtime.IllegalValue<PixelFormat>();
			default: Runtime.IllegalValue<PixelFormat>();
			}
		}

		/// <summary>
		/// Given a vertex element format, returns the number of bytes required
		/// to store an element in that format.
		/// </summary>
		/// <param name="format">A vertex element format</param>
		/// <returns>The number of bytes required to store an element in the given format</returns>
		public static uint32 GetSizeInBytes(VertexElementFormat format)
		{
			switch (format)
			{
			case VertexElementFormat.Byte2_Norm,
				VertexElementFormat.Byte2,
				VertexElementFormat.SByte2_Norm,
				VertexElementFormat.SByte2,
				VertexElementFormat.Half1:
				return 2;
			case VertexElementFormat.Float1,
				VertexElementFormat.UInt1,
				VertexElementFormat.Int1,
				VertexElementFormat.Byte4_Norm,
				VertexElementFormat.Byte4,
				VertexElementFormat.SByte4_Norm,
				VertexElementFormat.SByte4,
				VertexElementFormat.UShort2_Norm,
				VertexElementFormat.UShort2,
				VertexElementFormat.Short2_Norm,
				VertexElementFormat.Short2,
				VertexElementFormat.Half2:
				return 4;
			case VertexElementFormat.Float2,
				VertexElementFormat.UInt2,
				VertexElementFormat.Int2,
				VertexElementFormat.UShort4_Norm,
				VertexElementFormat.UShort4,
				VertexElementFormat.Short4_Norm,
				VertexElementFormat.Short4,
				VertexElementFormat.Half4:
				return 8;
			case VertexElementFormat.Float3,
				VertexElementFormat.UInt3,
				VertexElementFormat.Int3:
				return 12;
			case VertexElementFormat.Float4,
				VertexElementFormat.UInt4,
				VertexElementFormat.Int4:
				return 16;
			default:
				Runtime.IllegalValue<VertexElementFormat>();
			}
		}
	}
}
