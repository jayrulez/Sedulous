using System;
namespace Sedulous.Renderer;

namespace cc
{
	namespace gfx
	{
		static{
			public const TextureUsage TEXTURE_USAGE_TRANSIENT = (TextureUsage)(
				(uint32)(TextureUsageBit.COLOR_ATTACHMENT) |
				(uint32)(TextureUsageBit.DEPTH_STENCIL_ATTACHMENT) |
				(uint32)(TextureUsageBit.INPUT_ATTACHMENT));

			public const DescriptorType DESCRIPTOR_BUFFER_TYPE = (DescriptorType)(
				(uint32)(DescriptorType.STORAGE_BUFFER) |
				(uint32)(DescriptorType.DYNAMIC_STORAGE_BUFFER) |
				(uint32)(DescriptorType.UNIFORM_BUFFER) |
				(uint32)(DescriptorType.DYNAMIC_UNIFORM_BUFFER));

			public const DescriptorType DESCRIPTOR_TEXTURE_TYPE = (DescriptorType)(
				(uint32)(DescriptorType.SAMPLER_TEXTURE) |
				(uint32)(DescriptorType.SAMPLER) |
				(uint32)(DescriptorType.TEXTURE) |
				(uint32)(DescriptorType.STORAGE_IMAGE) |
				(uint32)(DescriptorType.INPUT_ATTACHMENT));

			public const DescriptorType DESCRIPTOR_SAMPLER_TYPE = (DescriptorType)(
				(uint32)(DescriptorType.SAMPLER_TEXTURE) |
				(uint32)(DescriptorType.SAMPLER) |
				(uint32)(DescriptorType.TEXTURE) |
				(uint32)(DescriptorType.STORAGE_IMAGE) |
				(uint32)(DescriptorType.INPUT_ATTACHMENT));

			public const DescriptorType DESCRIPTOR_DYNAMIC_TYPE = (DescriptorType)(
				(uint32)(DescriptorType.DYNAMIC_STORAGE_BUFFER) |
				(uint32)(DescriptorType.DYNAMIC_UNIFORM_BUFFER));

			
			public static FormatInfo[?] GFX_FORMAT_INFOS = .(
			.("UNKNOWN", 0, 0, FormatType.NONE, false, false, false, false),
			.("A8", 1, 1, FormatType.UNORM, true, false, false, false),
			.("L8", 1, 1, FormatType.UNORM, false, false, false, false),
			.("LA8", 1, 2, FormatType.UNORM, false, false, false, false),

			.("R8", 1, 1, FormatType.UNORM, false, false, false, false),
			.("R8SN", 1, 1, FormatType.SNORM, false, false, false, false),
			.("R8UI", 1, 1, FormatType.UINT, false, false, false, false),
			.("R8I", 1, 1, FormatType.INT, false, false, false, false),
			.("R16F", 2, 1, FormatType.FLOAT, false, false, false, false),
			.("R16UI", 2, 1, FormatType.UINT, false, false, false, false),
			.("R16I", 2, 1, FormatType.INT, false, false, false, false),
			.("R32F", 4, 1, FormatType.FLOAT, false, false, false, false),
			.("R32UI", 4, 1, FormatType.UINT, false, false, false, false),
			.("R32I", 4, 1, FormatType.INT, false, false, false, false),

			.("RG8", 2, 2, FormatType.UNORM, false, false, false, false),
			.("RG8SN", 2, 2, FormatType.SNORM, false, false, false, false),
			.("RG8UI", 2, 2, FormatType.UINT, false, false, false, false),
			.("RG8I", 2, 2, FormatType.INT, false, false, false, false),
			.("RG16F", 4, 2, FormatType.FLOAT, false, false, false, false),
			.("RG16UI", 4, 2, FormatType.UINT, false, false, false, false),
			.("RG16I", 4, 2, FormatType.INT, false, false, false, false),
			.("RG32F", 8, 2, FormatType.FLOAT, false, false, false, false),
			.("RG32UI", 8, 2, FormatType.UINT, false, false, false, false),
			.("RG32I", 8, 2, FormatType.INT, false, false, false, false),

			.("RGB8", 3, 3, FormatType.UNORM, false, false, false, false),
			.("SRGB8", 3, 3, FormatType.UNORM, false, false, false, false),
			.("RGB8SN", 3, 3, FormatType.SNORM, false, false, false, false),
			.("RGB8UI", 3, 3, FormatType.UINT, false, false, false, false),
			.("RGB8I", 3, 3, FormatType.INT, false, false, false, false),
			.("RGB16F", 6, 3, FormatType.FLOAT, false, false, false, false),
			.("RGB16UI", 6, 3, FormatType.UINT, false, false, false, false),
			.("RGB16I", 6, 3, FormatType.INT, false, false, false, false),
			.("RGB32F", 12, 3, FormatType.FLOAT, false, false, false, false),
			.("RGB32UI", 12, 3, FormatType.UINT, false, false, false, false),
			.("RGB32I", 12, 3, FormatType.INT, false, false, false, false),

			.("RGBA8", 4, 4, FormatType.UNORM, true, false, false, false),
			.("BGRA8", 4, 4, FormatType.UNORM, true, false, false, false),
			.("SRGB8_A8", 4, 4, FormatType.UNORM, true, false, false, false),
			.("RGBA8SN", 4, 4, FormatType.SNORM, true, false, false, false),
			.("RGBA8UI", 4, 4, FormatType.UINT, true, false, false, false),
			.("RGBA8I", 4, 4, FormatType.INT, true, false, false, false),
			.("RGBA16F", 8, 4, FormatType.FLOAT, true, false, false, false),
			.("RGBA16UI", 8, 4, FormatType.UINT, true, false, false, false),
			.("RGBA16I", 8, 4, FormatType.INT, true, false, false, false),
			.("RGBA32F", 16, 4, FormatType.FLOAT, true, false, false, false),
			.("RGBA32UI", 16, 4, FormatType.UINT, true, false, false, false),
			.("RGBA32I", 16, 4, FormatType.INT, true, false, false, false),

			.("R5G6B5", 2, 3, FormatType.UNORM, false, false, false, false),
			.("R11G11B10F", 4, 3, FormatType.FLOAT, false, false, false, false),
			.("RGB5A1", 2, 4, FormatType.UNORM, true, false, false, false),
			.("RGBA4", 2, 4, FormatType.UNORM, true, false, false, false),
			.("RGB10A2", 2, 4, FormatType.UNORM, true, false, false, false),
			.("RGB10A2UI", 2, 4, FormatType.UINT, true, false, false, false),
			.("RGB9E5", 2, 4, FormatType.FLOAT, true, false, false, false),

			.("DEPTH", 4, 1, FormatType.FLOAT, false, true, false, false),
			.("DEPTH_STENCIL", 5, 2, FormatType.FLOAT, false, true, true, false),

			.("BC1", 1, 3, FormatType.UNORM, false, false, false, true),
			.("BC1_ALPHA", 1, 4, FormatType.UNORM, true, false, false, true),
			.("BC1_SRGB", 1, 3, FormatType.UNORM, false, false, false, true),
			.("BC1_SRGB_ALPHA", 1, 4, FormatType.UNORM, true, false, false, true),
			.("BC2", 1, 4, FormatType.UNORM, true, false, false, true),
			.("BC2_SRGB", 1, 4, FormatType.UNORM, true, false, false, true),
			.("BC3", 1, 4, FormatType.UNORM, true, false, false, true),
			.("BC3_SRGB", 1, 4, FormatType.UNORM, true, false, false, true),
			.("BC4", 1, 1, FormatType.UNORM, false, false, false, true),
			.("BC4_SNORM", 1, 1, FormatType.SNORM, false, false, false, true),
			.("BC5", 1, 2, FormatType.UNORM, false, false, false, true),
			.("BC5_SNORM", 1, 2, FormatType.SNORM, false, false, false, true),
			.("BC6H_UF16", 1, 3, FormatType.UFLOAT, false, false, false, true),
			.("BC6H_SF16", 1, 3, FormatType.FLOAT, false, false, false, true),
			.("BC7", 1, 4, FormatType.UNORM, true, false, false, true),
			.("BC7_SRGB", 1, 4, FormatType.UNORM, true, false, false, true),

			.("ETC_RGB8", 1, 3, FormatType.UNORM, false, false, false, true),
			.("ETC2_RGB8", 1, 3, FormatType.UNORM, false, false, false, true),
			.("ETC2_SRGB8", 1, 3, FormatType.UNORM, false, false, false, true),
			.("ETC2_RGB8_A1", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ETC2_SRGB8_A1", 1, 4, FormatType.UNORM, true, false, false, true),
			.("EAC_R11", 1, 1, FormatType.UNORM, false, false, false, true),
			.("EAC_R11SN", 1, 1, FormatType.SNORM, false, false, false, true),
			.("EAC_RG11", 2, 2, FormatType.UNORM, false, false, false, true),
			.("EAC_RG11SN", 2, 2, FormatType.SNORM, false, false, false, true),

			.("PVRTC_RGB2", 2, 3, FormatType.UNORM, false, false, false, true),
			.("PVRTC_RGBA2", 2, 4, FormatType.UNORM, true, false, false, true),
			.("PVRTC_RGB4", 2, 3, FormatType.UNORM, false, false, false, true),
			.("PVRTC_RGBA4", 2, 4, FormatType.UNORM, true, false, false, true),
			.("PVRTC2_2BPP", 2, 4, FormatType.UNORM, true, false, false, true),
			.("PVRTC2_4BPP", 2, 4, FormatType.UNORM, true, false, false, true),

			.("ASTC_RGBA_4X4", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_5X4", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_5X5", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_6X5", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_6X6", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_8X5", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_8X6", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_8X8", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_10X5", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_10X6", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_10X8", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_10X10", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_12X10", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_RGBA_12X12", 1, 4, FormatType.UNORM, true, false, false, true),

			.("ASTC_SRGBA_4X4", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_5X4", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_5X5", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_6X5", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_6X6", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_8X5", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_8X6", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_8X8", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_10X5", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_10X6", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_10X8", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_10X10", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_12X10", 1, 4, FormatType.UNORM, true, false, false, true),
			.("ASTC_SRGBA_12X12", 1, 4, FormatType.UNORM, true, false, false, true),
			);

			
			private static uint32 ceilDiv(uint32 x, uint32 y) { return (x - 1) / y + 1; }

			public static (uint32, uint32) formatAlignment(Format format){
			switch (format) {
			case Format.BC1,
			 Format.BC1_ALPHA,
			 Format.BC1_SRGB,
			 Format.BC1_SRGB_ALPHA,
			 Format.BC2,
			 Format.BC2_SRGB,
			 Format.BC3,
			 Format.BC3_SRGB,
			 Format.BC4,
			 Format.BC4_SNORM,
			 Format.BC6H_SF16,
			 Format.BC6H_UF16,
			 Format.BC7,
			 Format.BC7_SRGB,
			 Format.BC5,
			 Format.BC5_SNORM,
			 Format.ETC_RGB8,
			 Format.ETC2_RGB8,
			 Format.ETC2_SRGB8,
			 Format.ETC2_RGB8_A1,
			 Format.EAC_R11,
			 Format.EAC_R11SN,
			 Format.ETC2_RGBA8,
			 Format.ETC2_SRGB8_A1,
			 Format.EAC_RG11,
			 Format.EAC_RG11SN:
				return (4, 4);

			case Format.PVRTC_RGB2,
			Format.PVRTC_RGBA2,
			Format.PVRTC2_2BPP:
				return (8, 4);

			case Format.PVRTC_RGB4,
			Format.PVRTC_RGBA4,
			Format.PVRTC2_4BPP:
				return (4, 4);

			case Format.ASTC_RGBA_4X4,
			Format.ASTC_SRGBA_4X4:
				return (4, 4);
			case Format.ASTC_RGBA_5X4,
			Format.ASTC_SRGBA_5X4:
				return (5, 4);
			case Format.ASTC_RGBA_5X5,
			Format.ASTC_SRGBA_5X5:
				return (5, 5);
			case Format.ASTC_RGBA_6X5,
			Format.ASTC_SRGBA_6X5:
				return (6, 5);
			case Format.ASTC_RGBA_6X6,
			Format.ASTC_SRGBA_6X6:
				return (6, 6);
			case Format.ASTC_RGBA_8X5,
			Format.ASTC_SRGBA_8X5:
				return (8, 5);
			case Format.ASTC_RGBA_8X6,
			Format.ASTC_SRGBA_8X6:
				return (8, 6);
			case Format.ASTC_RGBA_8X8,
			Format.ASTC_SRGBA_8X8:
				return (8, 8);
			case Format.ASTC_RGBA_10X5,
			Format.ASTC_SRGBA_10X5:
				return (10, 5);
			case Format.ASTC_RGBA_10X6,
			Format.ASTC_SRGBA_10X6:
				return (10, 6);
			case Format.ASTC_RGBA_10X8,
			Format.ASTC_SRGBA_10X8:
				return (10, 8);
			case Format.ASTC_RGBA_10X10,
			Format.ASTC_SRGBA_10X10:
				return (10, 10);
			case Format.ASTC_RGBA_12X10,
			Format.ASTC_SRGBA_12X10:
				return (12, 10);
			case Format.ASTC_RGBA_12X12,
			Format.ASTC_SRGBA_12X12:
				return (12, 12);
			default:
				return (1, 1);
			}
		}

			public static uint32 formatSize(Format format, uint32 width, uint32 height, uint32 depth){
			if (!GFX_FORMAT_INFOS[(uint32)format].isCompressed) {
				return (width * height * depth * GFX_FORMAT_INFOS[(uint32)format].size);
			}
			switch (format) {
			 case Format.BC1,
			 Format.BC1_ALPHA,
			 Format.BC1_SRGB,
			 Format.BC1_SRGB_ALPHA:
				return ceilDiv(width, 4) * ceilDiv(height, 4) * 8 * depth;
			case Format.BC2,
			 Format.BC2_SRGB,
			 Format.BC3,
			 Format.BC3_SRGB,
			 Format.BC4,
			 Format.BC4_SNORM,
			 Format.BC6H_SF16,
			 Format.BC6H_UF16,
			 Format.BC7,
			 Format.BC7_SRGB:
				return ceilDiv(width, 4) * ceilDiv(height, 4) * 16 * depth;
			case Format.BC5,
			 Format.BC5_SNORM:
				return ceilDiv(width, 4) * ceilDiv(height, 4) * 32 * depth;

			case Format.ETC_RGB8,
			 Format.ETC2_RGB8,
			 Format.ETC2_SRGB8,
			 Format.ETC2_RGB8_A1,
			 Format.EAC_R11,
			 Format.EAC_R11SN:
				return ceilDiv(width, 4) * ceilDiv(height, 4) * 8 * depth;
			case Format.ETC2_RGBA8,
			 Format.ETC2_SRGB8_A1,
			 Format.EAC_RG11,
			 Format.EAC_RG11SN:
				return ceilDiv(width, 4) * ceilDiv(height, 4) * 16 * depth;

			case Format.PVRTC_RGB2,
			 Format.PVRTC_RGBA2,
			 Format.PVRTC2_2BPP:
				return ceilDiv(width, 8) * ceilDiv(height, 4) * 8 * depth;
			case Format.PVRTC_RGB4,
			 Format.PVRTC_RGBA4,
			 Format.PVRTC2_4BPP:
				return ceilDiv(width, 4) * ceilDiv(height, 4) * 8 * depth;

			case Format.ASTC_RGBA_4X4,
			 Format.ASTC_SRGBA_4X4:
				return ceilDiv(width, 4) * ceilDiv(height, 4) * 16 * depth;
			case Format.ASTC_RGBA_5X4,
			 Format.ASTC_SRGBA_5X4:
				return ceilDiv(width, 5) * ceilDiv(height, 4) * 16 * depth;
			case Format.ASTC_RGBA_5X5,
			 Format.ASTC_SRGBA_5X5:
				return ceilDiv(width, 5) * ceilDiv(height, 5) * 16 * depth;
			case Format.ASTC_RGBA_6X5,
			 Format.ASTC_SRGBA_6X5:
				return ceilDiv(width, 6) * ceilDiv(height, 5) * 16 * depth;
			case Format.ASTC_RGBA_6X6,
			 Format.ASTC_SRGBA_6X6:
				return ceilDiv(width, 6) * ceilDiv(height, 6) * 16 * depth;
			case Format.ASTC_RGBA_8X5,
			 Format.ASTC_SRGBA_8X5:
				return ceilDiv(width, 8) * ceilDiv(height, 5) * 16 * depth;
			case Format.ASTC_RGBA_8X6,
			 Format.ASTC_SRGBA_8X6:
				return ceilDiv(width, 8) * ceilDiv(height, 6) * 16 * depth;
			case Format.ASTC_RGBA_8X8,
			 Format.ASTC_SRGBA_8X8:
				return ceilDiv(width, 8) * ceilDiv(height, 8) * 16 * depth;
			case Format.ASTC_RGBA_10X5,
			 Format.ASTC_SRGBA_10X5:
				return ceilDiv(width, 10) * ceilDiv(height, 5) * 16 * depth;
			case Format.ASTC_RGBA_10X6,
			 Format.ASTC_SRGBA_10X6:
				return ceilDiv(width, 10) * ceilDiv(height, 6) * 16 * depth;
			case Format.ASTC_RGBA_10X8,
			 Format.ASTC_SRGBA_10X8:
				return ceilDiv(width, 10) * ceilDiv(height, 8) * 16 * depth;
			case Format.ASTC_RGBA_10X10,
			 Format.ASTC_SRGBA_10X10:
				return ceilDiv(width, 10) * ceilDiv(height, 10) * 16 * depth;
			case Format.ASTC_RGBA_12X10,
			 Format.ASTC_SRGBA_12X10:
				return ceilDiv(width, 12) * ceilDiv(height, 10) * 16 * depth;
			case Format.ASTC_RGBA_12X12,
			 Format.ASTC_SRGBA_12X12:
				return ceilDiv(width, 12) * ceilDiv(height, 12) * 16 * depth;
			default:
				return 0;
			}
		}

			public static uint32 formatSurfaceSize(Format format, uint32 width, uint32 height, uint32 depth, uint32 mips){
				var width;
				var height;
			uint32 size = 0;

			for (uint32 i = 0; i < mips; ++i) {
				size += formatSize(format, width, height, depth);
				width = Math.Max(width >> 1, 1);
				height = Math.Max(height >> 1, 1);
			}

			return size;
		}

			private static uint32[(uint)VariableType.COUNT] GFX_TYPE_SIZES = .(
				0,  // UNKNOWN
				4,  // BOOL
				8,  // BOOL2
				12, // BOOL3
				16, // BOOL4
				4,  // INT
				8,  // INT2
				12, // INT3
				16, // INT4
				4,  // UINT
				8,  // UINT2
				12, // UINT3
				16, // UINT4
				4,  // FLOAT
				8,  // FLOAT2
				12, // FLOAT3
				16, // FLOAT4
				16, // MAT2
				24, // MAT2X3
				32, // MAT2X4
				24, // MAT3X2
				36, // MAT3
				48, // MAT3X4
				32, // MAT4X2
				48, // MAT4X3
				64, // MAT4
				4,  // SAMPLER1D
				4,  // SAMPLER1D_ARRAY
				4,  // SAMPLER2D
				4,  // SAMPLER2D_ARRAY
				4,  // SAMPLER3D
				4,  // SAMPLER_CUBE
			);

			/**
			 * @en Get the memory size of the specified type.
			 * @zh 得到 GFX 数据类型的大小。
			 * @param type The target type.
			 */
			public static uint32 getTypeSize(VariableType type){
			if (type < VariableType.COUNT) {
				return GFX_TYPE_SIZES[int(type)];
			}
			return 0;
		}

			public static uint32 gcd(uint32 a, uint32 b){
				var a;
				var b;
			while (b != 0) {
				uint32 t = a % b;
				a = b;
				b = t;
			}
			return a;
		}

			public static uint32 lcm(uint32 a, uint32 b){
			return a * b / gcd(a, b);
		}
		}

	}
}