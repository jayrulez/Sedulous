using System;
namespace Detex;

public static
{
	public const uint32 DETEX_MAX_BLOCK_SIZE = 256;
}

/* Detex library pixel formats. */

[CRepr, AllowDuplicates]
enum DETEX_PIXEL_FORMAT : uint32
{
	/* The format has 16-bit components. */
	DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT = 0x1,
	/* The format has 32-bit components. */
	DETEX_PIXEL_FORMAT_32BIT_COMPONENT_BIT = 0x2,
	/* The format has an alpha component. */
	DETEX_PIXEL_FORMAT_ALPHA_COMPONENT_BIT = 0x4,
	/* The sequential component order is RGB. */
	DETEX_PIXEL_FORMAT_RGB_COMPONENT_ORDER_BIT = 0x0,
	/* The sequential component order is BGR. */
	DETEX_PIXEL_FORMAT_BGR_COMPONENT_ORDER_BIT = 0x8,
	/* The format has one component. */
	DETEX_PIXEL_FORMAT_ONE_COMPONENT_BITS = 0x0,
	/* The format has two components. */
	DETEX_PIXEL_FORMAT_TWO_COMPONENTS_BITS = 0x10,
	/* The format has three components. */
	DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS = 0x20,
	/* The format has four components. */
	DETEX_PIXEL_FORMAT_FOUR_COMPONENTS_BITS = 0x30,
	/* The format is stored as 8-bit pixels. */
	DETEX_PIXEL_FORMAT_8BIT_PIXEL_BITS = 0x000,
	/* The format is stored as 16-bit pixels. */
	DETEX_PIXEL_FORMAT_16BIT_PIXEL_BITS = 0x100,
	/* The format is stored as 24-bit pixels. */
	DETEX_PIXEL_FORMAT_24BIT_PIXEL_BITS = 0x200,
	/* The format is stored as 32-bit pixels. */
	DETEX_PIXEL_FORMAT_32BIT_PIXEL_BITS = 0x300,
	/* The format is stored as 48-bit pixels. */
	DETEX_PIXEL_FORMAT_48BIT_PIXEL_BITS = 0x500,
	/* The format is stored as 64-bit pixels. */
	DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS = 0x700,
	/* The format is stored as 96-bit pixels. */
	DETEX_PIXEL_FORMAT_96BIT_PIXEL_BITS = 0xB00,
	/* The format is stored as 128-bit pixels. */
	DETEX_PIXEL_FORMAT_128BIT_PIXEL_BITS = 0xF00,
	/* The format has signed integer components. */
	DETEX_PIXEL_FORMAT_SIGNED_BIT = 0x1000,
	/* The format has (half-)float components. */
	DETEX_PIXEL_FORMAT_FLOAT_BIT = 0x2000,
	/* The fomat is HDR (high dynamic range). */
	DETEX_PIXEL_FORMAT_HDR_BIT = 0x4000,

	DETEX_PIXEL_FORMAT_RGBA8 = (
		DETEX_PIXEL_FORMAT_ALPHA_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_FOUR_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_32BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_BGRA8 = (
		DETEX_PIXEL_FORMAT_ALPHA_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_BGR_COMPONENT_ORDER_BIT |
		DETEX_PIXEL_FORMAT_FOUR_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_32BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_RGBX8 = (
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_32BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_BGRX8 = (
		DETEX_PIXEL_FORMAT_BGR_COMPONENT_ORDER_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_32BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_RGB8 = (
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_24BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_BGR8 = (
		DETEX_PIXEL_FORMAT_BGR_COMPONENT_ORDER_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_24BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_R8 = (
		DETEX_PIXEL_FORMAT_ONE_COMPONENT_BITS |
		DETEX_PIXEL_FORMAT_8BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_SIGNED_R8 = (
		DETEX_PIXEL_FORMAT_ONE_COMPONENT_BITS |
		DETEX_PIXEL_FORMAT_8BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_SIGNED_BIT
		),
	DETEX_PIXEL_FORMAT_RG8 = (
		DETEX_PIXEL_FORMAT_TWO_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_16BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_SIGNED_RG8 = (
		DETEX_PIXEL_FORMAT_TWO_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_16BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_SIGNED_BIT
		),
	DETEX_PIXEL_FORMAT_R16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ONE_COMPONENT_BITS |
		DETEX_PIXEL_FORMAT_16BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_SIGNED_R16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ONE_COMPONENT_BITS |
		DETEX_PIXEL_FORMAT_16BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_SIGNED_BIT
		),
	DETEX_PIXEL_FORMAT_RG16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_TWO_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_32BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_SIGNED_RG16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_TWO_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_32BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_SIGNED_BIT
		),
	DETEX_PIXEL_FORMAT_RGB16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_48BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_RGBX16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_RGBA16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ALPHA_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_FOUR_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS
		),
	DETEX_PIXEL_FORMAT_FLOAT_R16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ONE_COMPONENT_BITS |
		DETEX_PIXEL_FORMAT_16BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_R16_HDR = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ONE_COMPONENT_BITS |
		DETEX_PIXEL_FORMAT_16BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT |
		DETEX_PIXEL_FORMAT_HDR_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RG16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_TWO_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_32BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RG16_HDR = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_TWO_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_32BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT |
		DETEX_PIXEL_FORMAT_HDR_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGBX16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGBX16_HDR = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT |
		DETEX_PIXEL_FORMAT_HDR_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGBA16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ALPHA_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_FOUR_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT |
		DETEX_PIXEL_FORMAT_HDR_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGBA16_HDR = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ALPHA_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_FOUR_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGB16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_48BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGB16_HDR = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_48BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT |
		DETEX_PIXEL_FORMAT_HDR_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_BGRX16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_BGR_COMPONENT_ORDER_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_BGRX16_HDR = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_BGR_COMPONENT_ORDER_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT |
		DETEX_PIXEL_FORMAT_HDR_BIT
		),
	DETEX_PIXEL_FORMAT_SIGNED_FLOAT_RGBX16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_SIGNED_BIT |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_SIGNED_FLOAT_BGRX16 = (
		DETEX_PIXEL_FORMAT_16BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_BGR_COMPONENT_ORDER_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_SIGNED_BIT |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_R32 = (
		DETEX_PIXEL_FORMAT_32BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ONE_COMPONENT_BITS |
		DETEX_PIXEL_FORMAT_32BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_R32_HDR = (
		DETEX_PIXEL_FORMAT_32BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ONE_COMPONENT_BITS |
		DETEX_PIXEL_FORMAT_32BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT |
		DETEX_PIXEL_FORMAT_HDR_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RG32 = (
		DETEX_PIXEL_FORMAT_32BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_TWO_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RG32_HDR = (
		DETEX_PIXEL_FORMAT_32BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_TWO_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_64BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT |
		DETEX_PIXEL_FORMAT_HDR_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGB32 = (
		DETEX_PIXEL_FORMAT_32BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_96BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGB32_HDR = (
		DETEX_PIXEL_FORMAT_32BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_96BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT |
		DETEX_PIXEL_FORMAT_HDR_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGBX32 = (
		DETEX_PIXEL_FORMAT_32BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_128BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGBX32_HDR = (
		DETEX_PIXEL_FORMAT_32BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_THREE_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_128BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT |
		DETEX_PIXEL_FORMAT_HDR_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGBA32 = (
		DETEX_PIXEL_FORMAT_32BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ALPHA_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_FOUR_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_128BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT
		),
	DETEX_PIXEL_FORMAT_FLOAT_RGBA32_HDR = (
		DETEX_PIXEL_FORMAT_32BIT_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ALPHA_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_FOUR_COMPONENTS_BITS |
		DETEX_PIXEL_FORMAT_128BIT_PIXEL_BITS |
		DETEX_PIXEL_FORMAT_FLOAT_BIT |
		DETEX_PIXEL_FORMAT_HDR_BIT
		),
	DETEX_PIXEL_FORMAT_A8 = (
		DETEX_PIXEL_FORMAT_ALPHA_COMPONENT_BIT |
		DETEX_PIXEL_FORMAT_ONE_COMPONENT_BITS |
		DETEX_PIXEL_FORMAT_8BIT_PIXEL_BITS
		),
}

/* Mode mask flags. */
[CRepr]
enum DETEX_MODE_MASK : uint32
{
	DETEX_MODE_MASK_ETC_INDIVIDUAL = 0x1,
	DETEX_MODE_MASK_ETC_DIFFERENTIAL = 0x2,
	DETEX_MODE_MASK_ETC_T = 0x4,
	DETEX_MODE_MASK_ETC_H = 0x8,
	DETEX_MODE_MASK_ETC_PLANAR = 0x10,
	DETEX_MODE_MASK_ALL_MODES_ETC1 = 0x3,
	DETEX_MODE_MASK_ALL_MODES_ETC2 = 0x1F,
	DETEX_MODE_MASK_ALL_MODES_ETC2_PUNCHTHROUGH = 0X1E,
	DETEX_MODE_MASK_ALL_MODES_BPTC = 0xFF,
	DETEX_MODE_MASK_ALL_MODES_BPTC_FLOAT = 0x3FFF,
	DETEX_MODE_MASK_ALL = 0XFFFFFFFF,
}

/* Decompression function flags. */
[CRepr]
enum DETEX_DECOMPRESS_FLAGS : uint32
{
	/* Function returns false (invalid block) when the compressed block */
	/* is in a format not allowed to be generated by an encoder. */
	DETEX_DECOMPRESS_FLAG_ENCODE = 0x1,
	/* For compression formats that have opaque and non-opaque modes, */
	/* return false (invalid block) when the compressed block is encoded */
	/* using a non-opaque mode. */
	DETEX_DECOMPRESS_FLAG_OPAQUE_ONLY = 0x2,
	/* For compression formats that have opaque and non-opaque modes, */
	/* return false (invalid block) when the compressed block is encoded */
	/* using an opaque mode. */
	DETEX_DECOMPRESS_FLAG_NON_OPAQUE_ONLY = 0x4,
}

/* Set mode function flags. */
[CRepr]
enum DETEX_SET_MODE_FLAGS : uint32
{
	/* The block is opaque (alpha is always 0xFF). */
	DETEX_SET_MODE_FLAG_OPAQUE = 0x2,
	/* The block is non-opaque (alpha is not always 0xFF). */
	DETEX_SET_MODE_FLAG_NON_OPAQUE = 0x4,
	/* The block has punchthrough alpha (alpha is either 0x00 or 0xFF). */
	DETEX_SET_MODE_FLAG_PUNCHTHROUGH = 0x8,
	/* The block only consists of one or two different pixel colors. */
	DETEX_SET_MODE_FLAG_MAX_TWO_COLORS = 0x10,
}

public static class Detex
{
		/*
		 * Decompression functions for 8-bit RGB8/RGBA8 formats. The output pixel format
		 * is DETEX_PIXEL_FORMAT_RGBA8 or DETEX_PIXEL_FORMAT_RGBX8 (32-bit pixels with
		 * optional alpha component, red component in lowest-order byte. When the
		 * texture format does not have alpha, alpha is set to 0xFF.
		 */

		/* Decompress a 64-bit 4x4 pixel texture block compressed using the ETC1 */
		/* format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockETC1(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 64-bit 4x4 pixel texture block compressed using the ETC2 */
		/* format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockETC2(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 64-bit 4x4 pixel texture block compressed using the */
		/* ETC2_PUNCHTROUGH format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockETC2_PUNCHTHROUGH(uint8* bitstring,
		uint32 mode_mask, uint32 flags, uint8* pixel_buffer);
		/* Decompress a 128-bit 4x4 pixel texture block compressed using the ETC2_EAC */
		/* format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockETC2_EAC(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);


		/* Decompress a 64-bit 4x4 pixel texture block compressed using the BC1 */
		/* format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockBC1(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 64-bit 4x4 pixel texture block compressed using the BC1A */
		/* format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockBC1A(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 64-bit 4x4 pixel texture block compressed using the BC2 */
		/* format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockBC2(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 64-bit 4x4 pixel texture block compressed using the BC3 */
		/* format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockBC3(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 128-bit 4x4 pixel texture block compressed using the BPTC */
		/* (BC7) format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockBPTC(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);

		/*
		 * Decompression functions for 8-bit unsigned R and RG formats. The
		 * output format is DETEX_PIXEL_FORMAT_R8 or DETEX_PIXEL_FORMAT_RG8.
		 */

		/* Decompress a 64-bit 4x4 pixel texture block compressed using the */
		/* unsigned RGTC1 (BC4) format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockRGTC1(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 128-bit 4x4 pixel texture block compressed using the */
		/* unsigned RGTC2 (BC5) format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockRGTC2(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);

		/*
		 * Decompression functions for 16-bit unsigned/signed R and RG formats. The
		 * output format is DETEX_PIXEL_FORMAT_R16, DETEX_PIXEL_FORMAT_SIGNED_R16,
		 * DETEX_PIXEL_FORMAT_RG16, or DETEX_PIXEL_FORMAT_SIGNED_RG16.
		 */

		/* Decompress a 64-bit 4x4 pixel texture block compressed using the */
		/* signed RGTC1 (signed BC4) format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockSIGNED_RGTC1(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 128-bit 4x4 pixel texture block compressed using the */
		/* signed RGTC2 (signed BC5) format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockSIGNED_RGTC2(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 64-bit 4x4 pixel texture block compressed using the */
		/* ETC2_R11_EAC format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockEAC_R11(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 64-bit 4x4 pixel texture block compressed using the */
		/* ETC2_SIGNED_R11_EAC format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockEAC_SIGNED_R11(uint8* bitstring,
		uint32 mode_mask, uint32 flags, uint8* pixel_buffer);
		/* Decompress a 128-bit 4x4 pixel texture block compressed using the */
		/* ETC2_RG11_EAC format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockEAC_RG11(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 128-bit 4x4 pixel texture block compressed using the */
		/* ETC2_SIGNED_RG11_EAC format. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockEAC_SIGNED_RG11(uint8* bitstring,
		uint32 mode_mask, uint32 flags, uint8* pixel_buffer);

		/*
		 * Decompression functions for 16-bit half-float formats. The output format is
		 * DETEX_PIXEL_FORMAT_FLOAT_RGBX16 or DETEX_PIXEL_FORMAT_SIGNED_FLOAT_RGBX16.
		 */

		/* Decompress a 128-bit 4x4 pixel texture block compressed using the */
		/* BPTC_FLOAT (BC6H) format. The output format is */
		/* DETEX_PIXEL_FORMAT_FLOAT_RGBX16. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockBPTC_FLOAT(uint8* bitstring, uint32 mode_mask,
		uint32 flags, uint8* pixel_buffer);
		/* Decompress a 128-bit 4x4 pixel texture block compressed using the */
		/* BPTC_FLOAT (BC6H_FLOAT) format. The output format is */
		/* DETEX_PIXEL_FORMAT_SIGNED_FLOAT_RGBX16. */
	[CallingConvention(.Stdcall), CLink] public static extern bool detexDecompressBlockBPTC_SIGNED_FLOAT(uint8* bitstring,
		uint32 mode_mask, uint32 flags, uint8* pixel_buffer);


		/*
		 * Get mode functions. They return the internal compression format mode used
		 * inside the compressed block. For compressed formats that do not use a mode,
		 * there is no GetMode function.
		 */

	[CallingConvention(.Stdcall), CLink] public static extern uint32 detexGetModeBC1(uint8* bitstring);
	[CallingConvention(.Stdcall), CLink] public static extern uint32 detexGetModeETC1(uint8* bitstring);
	[CallingConvention(.Stdcall), CLink] public static extern uint32 detexGetModeETC2(uint8* bitstring);
	[CallingConvention(.Stdcall), CLink] public static extern uint32 detexGetModeETC2_PUNCHTHROUGH(uint8* bitstring);
	[CallingConvention(.Stdcall), CLink] public static extern uint32 detexGetModeETC2_EAC(uint8* bitstring);
	[CallingConvention(.Stdcall), CLink] public static extern uint32 detexGetModeBPTC(uint8* bitstring);
	[CallingConvention(.Stdcall), CLink] public static extern uint32 detexGetModeBPTC_FLOAT(uint8* bitstring);
	[CallingConvention(.Stdcall), CLink] public static extern uint32 detexGetModeBPTC_SIGNED_FLOAT(uint8* bitstring);

		/*
		 * Set mode functions. The set mode function modifies a compressed texture block
		 * so that the specified mode is set, making use of information about the block
		 * (whether it is opaque, non-opaque or punchthrough for formats with alpha,
		 * whether at most two different colors are used). For compressed formats
		 * that do not use a mode, there is no SetMode function.
		 */

	[CallingConvention(.Stdcall), CLink] public static extern void detexSetModeBC1(uint8* bitstring, uint32 mode, uint32 flags,
		uint32* colors);
	[CallingConvention(.Stdcall), CLink] public static extern void detexSetModeETC1(uint8* bitstring, uint32 mode, uint32 flags,
		uint32* colors);
	[CallingConvention(.Stdcall), CLink] public static extern void detexSetModeETC2(uint8* bitstring, uint32 mode, uint32 flags,
		uint32* colors);
	[CallingConvention(.Stdcall), CLink] public static extern void detexSetModeETC2_PUNCHTHROUGH(uint8* bitstring, uint32 mode, uint32 flags,
		uint32* colors);
	[CallingConvention(.Stdcall), CLink] public static extern void detexSetModeETC2_EAC(uint8* bitstring, uint32 mode, uint32 flags,
		uint32* colors);
	[CallingConvention(.Stdcall), CLink] public static extern void detexSetModeBPTC(uint8* bitstring, uint32 mode, uint32 flags,
		uint32* colors);
	[CallingConvention(.Stdcall), CLink] public static extern void detexSetModeBPTC_FLOAT(uint8* bitstring, uint32 mode, uint32 flags,
		uint32* colors);
}

public static
{
	[Comptime]
	public static uint32 DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(uint32 n)
	{
		return ((uint32)n << 24);
	}
}
[CRepr, AllowDuplicates]
enum DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX : uint32
{
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_UNCOMPRESSED = 0,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC1 = 1,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_DXT1 = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC1,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_S3TC = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC1,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC1A,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_DXT1A = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC1A,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC2,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_DXT3 = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC2,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC3,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_DXT5 = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC3,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_RGTC1,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC4_UNORM = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_RGTC1,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_SIGNED_RGTC1,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC4_SNORM = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_SIGNED_RGTC1,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_RGTC2,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC5_UNORM = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_RGTC2,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_SIGNED_RGTC2,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC5_SNORM = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_SIGNED_RGTC2,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BPTC_FLOAT,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC6H_UF16 = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BPTC_FLOAT,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BPTC_SIGNED_FLOAT,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC6H_SF16 = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BPTC_SIGNED_FLOAT,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BPTC,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC7 = DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BPTC,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_ETC1,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_ETC2,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_ETC2_PUNCHTHROUGH,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_ETC2_EAC,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_EAC_R11,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_EAC_SIGNED_R11,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_EAC_RG11,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_EAC_SIGNED_RG11,
	DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_ASTC_4X4,

}

[CRepr]
enum DETEX_TEXTURE_FORMAT : uint32
{
	DETEX_TEXTURE_FORMAT_PIXEL_FORMAT_MASK = 0x0000FFFF,
	DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT = 0x00800000,
	DETEX_TEXTURE_FORMAT_BC1 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS((.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC1) | (.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBX8
		),
	DETEX_TEXTURE_FORMAT_BC1A = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC1A) |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA8
		),
	DETEX_TEXTURE_FORMAT_BC2 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC2) |
		DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA8
		),
	DETEX_TEXTURE_FORMAT_BC3 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BC3) |
		DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA8
		),
	DETEX_TEXTURE_FORMAT_RGTC1 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_RGTC1) |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_R8
		),
	DETEX_TEXTURE_FORMAT_SIGNED_RGTC1 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_SIGNED_RGTC1) |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_SIGNED_R16
		),
	DETEX_TEXTURE_FORMAT_RGTC2 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_RGTC2) |
		DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RG8
		),
	DETEX_TEXTURE_FORMAT_SIGNED_RGTC2 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_SIGNED_RGTC2) |
		DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_SIGNED_RG16
		),
	DETEX_TEXTURE_FORMAT_BPTC_FLOAT = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BPTC_FLOAT) |
		DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_FLOAT_RGBX16
		),
	DETEX_TEXTURE_FORMAT_BPTC_SIGNED_FLOAT = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BPTC_SIGNED_FLOAT) |
		DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_SIGNED_FLOAT_RGBX16
		),
	DETEX_TEXTURE_FORMAT_BPTC = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_BPTC) |
		DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA8
		),
	DETEX_TEXTURE_FORMAT_ETC1 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_ETC1) |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBX8
		),
	DETEX_TEXTURE_FORMAT_ETC2 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_ETC2) |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBX8
		),
	DETEX_TEXTURE_FORMAT_ETC2_PUNCHTHROUGH = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_ETC2_PUNCHTHROUGH) |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA8
		),
	DETEX_TEXTURE_FORMAT_ETC2_EAC = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_ETC2_EAC) |
		DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA8
		),
	DETEX_TEXTURE_FORMAT_EAC_R11 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_EAC_R11) |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_R16
		),
	DETEX_TEXTURE_FORMAT_EAC_SIGNED_R11 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_EAC_SIGNED_R11) |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_SIGNED_R16
		),
	DETEX_TEXTURE_FORMAT_EAC_RG11 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_EAC_RG11) |
		DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RG16
		),
	DETEX_TEXTURE_FORMAT_EAC_SIGNED_RG11 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_EAC_SIGNED_RG11) |
		DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_SIGNED_RG16
		),
	DETEX_TEXTURE_FORMAT_ASTC_4X4 = (
		DETEX_TEXTURE_FORMAT_COMPRESSED_FORMAT_BITS(
		(.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_ASTC_4X4) |
		DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT |
		(.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA8
		),
}

[CRepr]
struct detexTexture
{
	public uint32 format;
	public uint8* data;
	public int32 width;
	public int32 height;
	public int32 width_in_blocks;
	public int32 height_in_blocks;
}

extension Detex
{
	/*
	 * General texture decompression functions (tiled or linear) with specified
	 * compression format.
	 */

	/*
	 * General block decompression function. Block is decompressed using the given
	 * compressed format, and stored in the given pixel format.
	 */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexDecompressBlock(uint8* bitstring, uint32 texture_format,
		uint32 mode_mask, uint32 flags, uint8* pixel_buffer,
		uint32 pixel_format);

	/*
	 * Decode texture function (tiled). Decode an entire compressed texture into an
	 * array of image buffer tiles (corresponding to compressed blocks), converting
	 * into the given pixel format.
	 */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexDecompressTextureTiled(detexTexture* texture, uint8* pixel_buffer,
		uint32 pixel_format);

	/*
	 * Decode texture function (linear). Decode an entire texture into a single
	 * image buffer, with pixels stored row-by-row, converting into the given pixel
	 * format.
	 */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexDecompressTextureLinear(detexTexture* texture, uint8* pixel_buffer,
		uint32 pixel_format);


	/*
	 * Miscellaneous functions.
	 */

	/*
	 * Convert pixels between different formats. The target pixel buffer must
	 * be allocated with sufficient size to the hold the result. Returns true if
	 * succesful.
	 */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexConvertPixels(uint8* source_pixel_buffer, uint32 nu_pixels,
		uint32 source_pixel_format, uint8* target_pixel_buffer,
		uint32 target_pixel_format);

	/* Convert in-place, modifying the source pixel buffer only. If any conversion step changes the */
	/* pixel size, the function will not be succesful and return false. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexConvertPixelsInPlace(uint8* source_pixel_buffer,
		uint32 nu_pixels, uint32 source_pixel_format, uint32 target_pixel_format);

	/* Return the component bitfield masks for a pixel format (pixel size must be at most 64 bits). */
	/* Return true if succesful. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexGetComponentMasks(uint32 texture_format, uint64* red_mask, uint64* green_mask,
		uint64* blue_mask, uint64* alpha_mask);

	/* Return a text description/identifier of the texture type. */
	[CallingConvention(.Stdcall), CLink] public static extern  char8* detexGetTextureFormatText(uint32 texture_format);

	/* Return a alternative text description of the texture type. Returns empty string */
	/* when there is no alternative description. */
	[CallingConvention(.Stdcall), CLink] public static extern  char8* detexGetAlternativeTextureFormatText(uint32 texture_format);

	/* Return OpenGL TexImage2D/KTX file parameters for a texture format. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexGetOpenGLParameters(uint32 texture_format, int32* gl_internal_format,
		uint32* gl_format, uint32* gl_type);

	/* Return DirectX 10 format for a texture format. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexGetDX10Parameters(uint32 texture_format, uint32* dx10_format);

	/* Return the error message for the last encountered error. */
	[CallingConvention(.Stdcall), CLink] public static extern  char8* detexGetErrorMessage();


	/*
	 * HDR-related functions.
	 */

	/* Set HDR gamma curve parameters. */
	[CallingConvention(.Stdcall), CLink] public static extern  void detexSetHDRParameters(float gamma, float range_min, float range_max);

	/* Calculate the dynamic range of a pixel buffer. Valid for float and half-float formats. */
	/* Returns true if successful. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexCalculateDynamicRange(uint8* pixel_buffer, int32 nu_pixels, uint32 pixel_format,
		float* range_min_out, float* range_max_out);


	/*
	 * Texture file loading.
	 */

	/* Load texture from KTX file with mip-maps. Returns true if successful. */
	/* nu_levels is a return parameter that returns the number of mipmap levels found. */
	/* textures_out is a return parameter for an array of detexTexture pointers that is allocated, */
	/* free with free(). textures_out[i] are allocated textures corresponding to each level, free */
	/* with free().	 */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexLoadKTXFileWithMipmaps(char8* filename, int32 max_mipmaps, detexTexture*** textures_out,
		int32* nu_levels_out);

	/* Load texture from KTX file (first mip-map only). Returns true if successful. */
	/* The texture is allocated, free with free(). */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexLoadKTXFile(char8* filename, detexTexture** texture_out);

	/* Save textures to KTX file (multiple mip-maps levels). Return true if succesful. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexSaveKTXFileWithMipmaps(detexTexture** textures, int32 nu_levels, char8* filename);

	/* Save texture to KTX file (single mip-map level). Returns true if succesful. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexSaveKTXFile(detexTexture* texture, char8* filename);

	/* Load texture from DDS file with mip-maps. Returns true if successful. */
	/* nu_levels is a return parameter that returns the number of mipmap levels found. */
	/* textures_out is a return parameter for an array of detexTexture pointers that is allocated, */
	/* free with free(). textures_out[i] are allocated textures corresponding to each level, free */
	/* with free(). */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexLoadDDSFileWithMipmaps(char8* filename, int32 max_mipmaps, detexTexture*** textures_out,
		int32* nu_levels_out);

	/* Load texture from DDS file (first mip-map only). Returns true if successful. */
	/* The texture is allocated, free with free(). */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexLoadDDSFile(char8* filename, detexTexture** texture_out);

	/* Save textures to DDS file (multiple mip-maps levels). Return true if succesful. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexSaveDDSFileWithMipmaps(detexTexture** textures, int32 nu_levels, char8* filename);

	/* Save texture to DDS file (single mip-map level). Returns true if succesful. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexSaveDDSFile(detexTexture* texture, char8* filename);

	/* Load texture from an image file using stb_image (first mip-map only). */
	/* Formats supported: JPEG, PNG, TGA, BMP, PSD, GIF, PIC, PNM. */
	/* Returns true if successful. The texture is allocated, free with free(). */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexLoadImageFile(char8* filename, detexTexture*** texture_out);

	/* Save texture to an image file (type autodetected from extension). */
	/* Formats supported: JPEG, PNG, TGA, BMP. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexSaveImageFile(detexTexture* texture, char8* filename);

	/* Load texture file (type autodetected from extension) with mipmaps. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexLoadTextureFileWithMipmaps(char8* filename, int32 max_mipmaps, detexTexture*** textures_out,
		int32* nu_levels_out);

	/* Load texture file (type autodetected from extension). */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexLoadTextureFile(char8* filename, detexTexture** texture_out);

	/* Load texture from memory (first mip-map only). */
	[CallingConvention(.Stdcall), CLink] public static extern  void detexLoadTextureFromMemory(uint32 pixel_format, uint32 width, uint32 height, uint8* data, detexTexture*** texture_out);

	/* Load texture from raw file (first mip-map only) given the format and dimensions */
	/* in texture. Returns true if successful. */
	/* The texture->data is allocated, free with free(). */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexLoadRawFile(char8* filename, detexTexture* texture);

	/* Save texture to raw file (first mip-map only) given the format and dimensions */
	/* in texture. Returns true if successful. */
	[CallingConvention(.Stdcall), CLink] public static extern  bool detexSaveRawFile(detexTexture* texture, char8* filename);

	/* Free loaded texture. */
	[CallingConvention(.Stdcall), CLink] public static extern  void detexFreeTexture(detexTexture** texture, int32 nu_levels);

	/* Computes row and slice pitch of a texture. */
	[CallingConvention(.Stdcall), CLink] public static extern void detexComputePitch(uint32 pixel_format, int32 width, int32 height, int32* row_pitch, int32* slice_pitch);
}

extension Detex
{
	/* Return pixel size in bytes for pixel format or texture format (decompressed). */
	[Inline] public static uint32 detexGetPixelSize(uint32 pixel_format)
	{
		return 1 + ((pixel_format & 0xF00) >> 8);
	}

	/* Return the total size of a compressed texture. */
	[Inline] public static uint32 detexTextureSize(uint32 width_in_blocks, uint32 height_in_blocks, uint32 pixel_format)
	{
		return width_in_blocks * height_in_blocks * detexGetCompressedBlockSize(pixel_format);
	}

	/* Return the compressed texture type index of a texture format. */
	[Inline] public static uint32 detexGetCompressedFormat(uint32 texture_format)
	{
		return texture_format >> 24;
	}

	/* Return the block size of a compressed texture format in bytes. */
	[Inline] public static uint32 detexGetCompressedBlockSize(uint32 texture_format)
	{
		return 8 + ((texture_format & (.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_128BIT_BLOCK_BIT) >> 20);
	}

	/* Return whether a texture format is compressed. */
	[Inline] public static bool detexFormatIsCompressed(uint32 texture_format)
	{
		return detexGetCompressedFormat(texture_format) != (.)DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX.DETEX_COMPRESSED_TEXTURE_FORMAT_INDEX_UNCOMPRESSED;
	}
}

