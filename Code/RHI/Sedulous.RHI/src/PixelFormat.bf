namespace Sedulous.RHI;

/// <summary>
/// The pixel format type.
/// </summary>
public enum PixelFormat
{
	/// <summary>
	///     The format is unknown.
	/// </summary>
	Unknown,
	/// <summary>
	///     A four-component, 128-bit typeless format that supports 32 bits per channel, including
	///     alpha.
	/// </summary>
	R32G32B32A32_Typeless,
	/// <summary>
	///     A four-component, 128-bit floating-point format that supports 32 bits per channel,
	///     including alpha.
	/// </summary>
	R32G32B32A32_Float,
	/// <summary>
	///    A four-component, 128-bit unsigned-integer format that supports 32 bits per channel,
	///     including alpha.
	/// </summary>
	R32G32B32A32_UInt,
	/// <summary>
	///     A four-component, 128-bit signed integer format that supports 32 bits per channel,
	///     including alpha.
	/// </summary>
	R32G32B32A32_SInt,
	/// <summary>
	///     A three-component, 96-bit typeless format that supports 32 bits per color channel.
	/// </summary>
	R32G32B32_Typeless,
	/// <summary>
	///     A three-component, 96-bit floating-point format that supports 32 bits per color
	///     channel.
	/// </summary>
	R32G32B32_Float,
	/// <summary>
	///     A three-component, 96-bit unsigned-integer format that supports 32 bits per color
	///     channel.
	/// </summary>
	R32G32B32_UInt,
	/// <summary>
	///     A three-component, 96-bit signed-integer format that supports 32 bits per color.
	///     channel.
	/// </summary>
	R32G32B32_SInt,
	/// <summary>
	///     A four-component, 64-bit typeless format that supports 16 bits per channel, including
	///     alpha.
	/// </summary>
	R16G16B16A16_Typeless,
	/// <summary>
	///     A four-component, 64-bit floating-point format that supports 16 bits per channel,
	///     including alpha.
	/// </summary>
	R16G16B16A16_Float,
	/// <summary>
	///     A four-component, 64-bit unsigned normalized integer format that supports 16
	///     bits per channel, including alpha.
	/// </summary>
	R16G16B16A16_UNorm,
	/// <summary>
	///     A four-component, 64-bit unsigned-integer format that supports 16 bits per channel,
	///     including alpha.
	/// </summary>
	R16G16B16A16_UInt,
	/// <summary>
	///     A four-component, 64-bit signed normalized integer format that supports 16 bits
	///     per channel, including alpha.
	/// </summary>
	R16G16B16A16_SNorm,
	/// <summary>
	///     A four-component, 64-bit signed-integer format that supports 16 bits per channel,
	///     including alpha.
	/// </summary>
	R16G16B16A16_SInt,
	/// <summary>
	///     A 64-bit, two-component typeless format that supports 32 bits for the red channel
	///     and 32 bits for the green channel.
	/// </summary>
	R32G32_Typeless,
	/// <summary>
	///     A two-component, 64-bit floating-point format that supports 32 bits for the red
	///     channel and 32 bits for the green channel.
	/// </summary>
	R32G32_Float,
	/// <summary>
	///     A two-component, 64-bit unsigned-integer format that supports 32 bits for the
	///     red channel and 32 bits for the green channel.
	/// </summary>
	R32G32_UInt,
	/// <summary>
	///     A two-component, 64-bit signed-integer format that supports 32 bits for the red
	///     channel and 32 bits for the green channel.
	/// </summary>
	R32G32_SInt,
	/// <summary>
	///     A two-component, 64-bit typeless format that supports 32 bits for the red channel,
	///     8 bits for the green channel, and 24 bits that are unused.
	/// </summary>
	R32G8X24_Typeless,
	/// <summary>
	///     A 32-bit floating-point component and two unsigned integer components (with
	///     an additional 32 bits). This format supports 32-bit depth, 8-bit stencil, and
	///     24 bits that are unused.
	/// </summary>
	D32_Float_S8X24_UInt,
	/// <summary>
	///     A 32-bit floating-point component and two typeless components (with an additional
	///     32 bits). This format supports a 32-bit red channel, 8 bits unused, and 24
	///     bits unused.
	/// </summary>
	R32_Float_X8X24_Typeless,
	/// <summary>
	///     A 32-bit typeless component, and two unsigned-integer components (with an additional
	///     32 bits). This format has 32 bits unused, 8 bits for the green channel, and 24 bits
	///     that are unused.
	/// </summary>
	X32_Typeless_G8X24_UInt,
	/// <summary>
	///     A four-component, 32-bit typeless format that supports 10 bits for each color
	///     and 2 bits for alpha.
	/// </summary>
	R10G10B10A2_Typeless,
	/// <summary>
	///     A four-component, 32-bit unsigned normalized integer format that supports 10
	///     bits for each color and 2 bits for alpha.
	/// </summary>
	R10G10B10A2_UNorm,
	/// <summary>
	///     A four-component, 32-bit unsigned-integer format that supports 10 bits for each
	///     color and 2 bits for alpha.
	/// </summary>
	R10G10B10A2_UInt,
	/// <summary>
	///     Three partial-precision floating-point numbers encoded into a single 32-bit value
	///     (a variant of s10e5, which is a sign bit, 10-bit mantissa, and 5-bit biased (15)
	///     exponent). There are no sign bits, and there is a 5-bit biased (15) exponent
	///     for each channel, a 6-bit mantissa for R and G, and a 5-bit mantissa for B, as
	///     shown in the following illustration.
	/// </summary>
	R11G11B10_Float,
	/// <summary>
	///     A four-component, 32-bit typeless format that supports 8 bits per channel, including
	///     alpha.
	/// </summary>
	R8G8B8A8_Typeless,
	/// <summary>
	///     A four-component, 32-bit unsigned normalized integer format that supports 8 bits
	///     per channel, including alpha.
	/// </summary>
	R8G8B8A8_UNorm,
	/// <summary>
	///     A four-component, 32-bit unsigned normalized integer sRGB format that supports
	///     8 bits per channel, including alpha.
	/// </summary>
	R8G8B8A8_UNorm_SRgb,
	/// <summary>
	///     A four-component, 32-bit unsigned integer format that supports 8 bits per channel,
	///     including alpha.
	/// </summary>
	R8G8B8A8_UInt,
	/// <summary>
	///     A four-component, 32-bit signed normalized integer format that supports 8 bits
	///     per channel, including alpha.
	/// </summary>
	R8G8B8A8_SNorm,
	/// <summary>
	///     A four-component, 32-bit signed-integer format that supports 8 bits per channel,
	///     including alpha.
	/// </summary>
	R8G8B8A8_SInt,
	/// <summary>
	///     A two-component, 32-bit typeless format that supports 16 bits for the red channel
	///     and 16 bits for the green channel.
	/// </summary>
	R16G16_Typeless,
	/// <summary>
	///     A two-component, 32-bit floating-point format that supports 16 bits for the red
	///     channel and 16 bits for the green channel.
	/// </summary>
	R16G16_Float,
	/// <summary>
	///     A two-component, 32-bit unsigned normalized integer format that supports 16 bits
	///     each for the green and red channels.
	/// </summary>
	R16G16_UNorm,
	/// <summary>
	///     A two-component, 32-bit unsigned-integer format that supports 16 bits for the
	///     red channel and 16 bits for the green channel.
	/// </summary>
	R16G16_UInt,
	/// <summary>
	///     A two-component, 32-bit signed normalized integer format that supports 16 bits
	///     for the red channel and 16 bits for the green channel.
	/// </summary>
	R16G16_SNorm,
	/// <summary>
	///     A two-component, 32-bit signed-integer format that supports 16 bits for the red
	///     channel and 16 bits for the green channel.
	/// </summary>
	R16G16_SInt,
	/// <summary>
	///     A single-component, 32-bit typeless format that supports 32 bits for the red
	///     channel.
	/// </summary>
	R32_Typeless,
	/// <summary>
	///     A single-component, 32-bit floating-point format that supports 32 bits for depth.
	/// </summary>
	D32_Float,
	/// <summary>
	///     A single-component, 32-bit floating-point format that allocates 32 bits for the
	///     red channel.
	/// </summary>
	R32_Float,
	/// <summary>
	///     A single-component, 32-bit unsigned integer format that supports 32 bits for
	///     the red channel.
	/// </summary>
	R32_UInt,
	/// <summary>
	///     A single-component, 32-bit signed-integer format that supports 32 bits for the
	///     red channel.
	/// </summary>
	R32_SInt,
	/// <summary>
	///     A two-component, 32-bit typeless format that supports 24 bits for the red channel
	///     and 8 bits for the green channel.
	/// </summary>
	R24G8_Typeless,
	/// <summary>
	///     A 32-bit z-buffer format that supports 24 bits for depth and 8 bits for the stencil.
	/// </summary>
	D24_UNorm_S8_UInt,
	/// <summary>
	///     A 32-bit format that contains a 24-bit, single-component, unsigned-normalized
	///     integer, with an additional typeless 8 bits. This format has a 24-bit red channel
	///     and 8 bits unused.
	/// </summary>
	R24_UNorm_X8_Typeless,
	/// <summary>
	///     A 32-bit format that contains a 24-bit, single-component, typeless format with
	///     an additional 8-bit unsigned integer component. This format has 24 bits unused
	///     and 8 bits for the green channel.
	/// </summary>
	X24_Typeless_G8_UInt,
	/// <summary>
	///     A two-component, 16-bit typeless format that supports 8 bits for the red channel
	///     and 8 bits for the green channel.
	/// </summary>
	R8G8_Typeless,
	/// <summary>
	///     A two-component, 16-bit unsigned normalized integer format that supports 8 bits
	///     for the red channel and 8 bits for the green channel.
	/// </summary>
	R8G8_UNorm,
	/// <summary>
	///     A two-component, 16-bit unsigned integer format that supports 8 bits for the
	///     red channel and 8 bits for the green channel.
	/// </summary>
	R8G8_UInt,
	/// <summary>
	///     A two-component, 16-bit signed normalized integer format that supports 8 bits
	///     for the red channel and 8 bits for the green channel.
	/// </summary>
	R8G8_SNorm,
	/// <summary>
	///     A two-component, 16-bit signed-integer format that supports 8 bits for the red
	///     channel and 8 bits for the green channel.
	/// </summary>
	R8G8_SInt,
	/// <summary>
	///     A single-component, 16-bit typeless format that supports 16 bits for the red
	///     channel.
	/// </summary>
	R16_Typeless,
	/// <summary>
	///     A single-component, 16-bit floating-point format that supports 16 bits for the
	///     red channel.
	/// </summary>
	R16_Float,
	/// <summary>
	///     A single-component, 16-bit unsigned normalized integer format that supports 16
	///     bits for depth.
	/// </summary>
	D16_UNorm,
	/// <summary>
	///     A single-component, 16-bit unsigned normalized integer format that supports 16
	///     bits for the red channel.
	/// </summary>
	R16_UNorm,
	/// <summary>
	///     A single-component, 16-bit unsigned-integer format that supports 16 bits for
	///     the red channel.
	/// </summary>
	R16_UInt,
	/// <summary>
	///     A single-component, 16-bit signed normalized integer format that supports 16
	///     bits for the red channel.
	/// </summary>
	R16_SNorm,
	/// <summary>
	///     A single-component, 16-bit signed-integer format that supports 16 bits for the
	///     red channel.
	/// </summary>
	R16_SInt,
	/// <summary>
	///     A single-component, 8-bit typeless format that supports 8 bits for the red channel.
	/// </summary>
	R8_Typeless,
	/// <summary>
	///     A single-component, 8-bit unsigned normalized integer format that supports 8
	///     bits for the red channel.
	/// </summary>
	R8_UNorm,
	/// <summary>
	///     A single-component, 8-bit unsigned-integer format that supports 8 bits for the
	///     red channel.
	/// </summary>
	R8_UInt,
	/// <summary>
	///     A single-component, 8-bit signed normalized integer format that supports 8 bits
	///     for the red channel.
	/// </summary>
	R8_SNorm,
	/// <summary>
	///     A single-component, 8-bit signed integer format that supports 8 bits for the
	///     red channel.
	/// </summary>
	R8_SInt,
	/// <summary>
	///     A single-component, 8-bit unsigned normalized integer format for alpha only.
	/// </summary>
	A8_UNorm,
	/// <summary>
	///     A single-component, 1-bit unsigned-normalized integer format that supports one
	///     bit for the red channel.
	/// </summary>
	R1_UNorm,
	/// <summary>
	///     Three partial-precision floating-point numbers encoded into a single 32-bit value,
	///     all sharing the same 5-bit exponent (variant of s10e5, which is a sign bit, 10-bit
	///     mantissa, and 5-bit biased (15) exponent). There is no sign bit, and there is
	///     a shared 5-bit biased (15) exponent and a 9-bit mantissa for each channel, as
	///     shown in the following illustration.
	/// </summary>
	R9G9B9E5_Sharedexp,
	/// <summary>
	///     A four-component, 32-bit unsigned-normalized-integer format. This packed RGB
	///     format is analogous to the UYVY format. Each 32-bit block describes a pair of
	///     pixels: (R8, G8, B8) and (R8, G8, B8) where the R8/B8 values are repeated, and
	///     the G8 values are unique to each pixel. The width must be even.
	/// </summary>
	R8G8_B8G8_UNorm,
	/// <summary>
	///     A four-component, 32-bit unsigned-normalized-integer format. This packed RGB
	///     format is analogous to the YUY2 format. Each 32-bit block describes a pair of
	///     pixels: (R8, G8, B8) and (R8, G8, B8) where the R8/B8 values are repeated, and
	///     the G8 values are unique to each pixel. The width must be even.
	/// </summary>
	G8R8_G8B8_UNorm,
	/// <summary>
	/// DXT1 typeless
	/// Four-component typeless block-compression format. For information about block-compression
	/// formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC1_Typeless,
	/// <summary>
	///  DXT1
	///     Four-component block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC1_UNorm,
	/// <summary>
	///     Four-component block-compression format for sRGB data. For more information about
	///     block-compression formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC1_UNorm_SRgb,
	/// <summary>
	///     Four-component typeless block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC2_Typeless,
	/// <summary>
	///     Four-component block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC2_UNorm,
	/// <summary>
	///     Four-component block-compression format for sRGB data. For more information about
	///     block-compression formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC2_UNorm_SRgb,
	/// <summary>
	///     Four-component typeless block compression format. For information about block compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC3_Typeless,
	/// <summary>
	/// DXT 5
	///     Four-component block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC3_UNorm,
	/// <summary>
	///     Four-component block-compression format for sRGB data. For information about
	///     block-compression formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC3_UNorm_SRgb,
	/// <summary>
	///     One-component typeless block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC4_Typeless,
	/// <summary>
	///     One-component block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC4_UNorm,
	/// <summary>
	///     One-component block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC4_SNorm,
	/// <summary>
	///     Two-component typeless block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC5_Typeless,
	/// <summary>
	///     Two-component block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC5_UNorm,
	/// <summary>
	///     Two-component block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC5_SNorm,
	/// <summary>
	///     A three-component, 16-bit unsigned-normalized-integer format that supports 5
	///     bits for blue, 6 bits for green, and 5 bits for red. Direct3D 10 through Direct3D
	///     11: This value is defined for DXGI. However, Direct3D 10, 10.1, or 11 devices
	///     do not support this format. Direct3D 11.1: This value is not supported until
	///     Windows 8.
	/// </summary>
	B5G6R5_UNorm,
	/// <summary>
	///     A four-component, 16-bit unsigned-normalized-integer format that supports 5 bits
	///     for each color channel and a 1-bit alpha. Direct3D 10 through Direct3D 11: This
	///     value is defined for DXGI. However, Direct3D 10, 10.1, or 11 devices do not support
	///     this format. Direct3D 11.1: This value is not supported until Windows 8.
	/// </summary>
	B5G5R5A1_UNorm,
	/// <summary>
	///     A four-component, 32-bit unsigned normalized integer format that supports 8 bits
	///     for each color channel and an 8-bit alpha.
	/// </summary>
	B8G8R8A8_UNorm,
	/// <summary>
	///     A four-component, 32-bit unsigned normalized integer format that supports 8 bits
	///     for each color channel and 8 bits unused.
	/// </summary>
	B8G8R8X8_UNorm,
	/// <summary>
	///     A four-component, 32-bit 2.8-biased fixed-point format that supports 10 bits
	///     for each color channel and a 2-bit alpha.
	/// </summary>
	R10G10B10_Xr_Bias_A2_UNorm,
	/// <summary>
	///     A four-component, 32-bit typeless format that supports 8 bits for each channel,
	///     including alpha.
	/// </summary>
	B8G8R8A8_Typeless,
	/// <summary>
	///     A four-component, 32-bit unsigned-normalized standard RGB format that supports
	///     8 bits for each channel including alpha.
	/// </summary>
	B8G8R8A8_UNorm_SRgb,
	/// <summary>
	///     A four-component, 32-bit typeless format that supports 8 bits for each color
	///     channel, with 8 bits unused.
	/// </summary>
	B8G8R8X8_Typeless,
	/// <summary>
	///     A four-component, 32-bit unsigned-normalized standard RGB format that supports
	///     8 bits for each color channel, with 8 bits unused.
	/// </summary>
	B8G8R8X8_UNorm_SRgb,
	/// <summary>
	///     A typeless block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC6H_Typeless,
	/// <summary>
	///     A block-compression format. For information about block-compression formats,
	///     see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC6H_Uf16,
	/// <summary>
	///     A block-compression format. For information about block-compression formats,
	///     see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC6H_Sf16,
	/// <summary>
	///     A typeless block-compression format. For information about block-compression
	///     formats, see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC7_Typeless,
	/// <summary>
	///     A block-compression format. For information about block-compression formats,
	///     see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC7_UNorm,
	/// <summary>
	///     A block-compression format. For information about block-compression formats,
	///     see Texture Block Compression in Direct3D 11.
	/// </summary>
	BC7_UNorm_SRgb,
	/// <summary>
	///     Most common YUV 4:4:4 video resource format. Valid view formats for this video
	///     resource format are R8G8B8A8_UNorm and R8G8B8A8_UInt.
	///     For UAVs, an additional valid view format is R32_UInt. By
	///     using R32_UInt for UAVs, you can both read and write, as opposed
	///     to just write for R8G8B8A8_UNorm and R8G8B8A8_UInt.
	///     Supported view types are SRV, RTV, and UAV. One view provides a straightforward
	///     mapping of the entire surface. The mapping to the view channel is V-&gt;R8, U-&gt;G8,
	///     Y-&gt;B8, and A-&gt;A8. For more info about YUV formats for video rendering, see Recommended
	///     8-Bit YUV Formats for Video Rendering. Direct3D 11.1: This value is not supported
	///     until Windows 8.
	/// </summary>
	AYUV,
	/// <summary>
	///     10-bit per channel packed YUV 4:4:4 video resource format. Valid view formats
	///     for this video resource format are R10G10B10A2_UNorm and
	///     R10G10B10A2_UInt. For UAVs, an additional valid view format
	///     is R32_UInt. By using R32_UInt for UAVs,
	///     you can both read and write as opposed to just writing for R10G10B10A2_UNorm
	///     and R10G10B10A2_UInt. Supported view types are SRV and UAV.
	///     One view provides a straightforward mapping of the entire surface. The mapping
	///     to the view channels is U-&gt;R10, Y-&gt;G10, V-&gt;B10, and A-&gt;A2. For more info about
	///     YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video
	///     Rendering. Direct3D 11.1: This value is not supported until Windows 8.
	/// </summary>
	Y410,
	/// <summary>
	///     16-bit per channel packed YUV 4:4:4 video resource format. Valid view formats
	///     for this video resource format are R16G16B16A16_UNorm and
	///     R16G16B16A16_UInt. Supported view types are SRV and UAV.
	///     One view provides a straightforward mapping of the entire surface. The mapping
	///     to the view channel is U-&gt;R16, Y-&gt;G16, V-&gt;B16, and A-&gt;A16. For more info about
	///     YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video
	///     Rendering. Direct3D 11.1: This value is not supported until Windows 8.
	/// </summary>
	Y416,
	/// <summary>
	///     Most common YUV 4:2:0 video resource format. Valid luminance data view formats
	///     for this video resource format are R8_UNorm and R8_UInt.
	///     Valid chrominance data view formats (width and height are each 1/2 of luminance
	///     view) for this video resource format are R8G8_UNorm and R8G8_UInt.
	///     Supported view types are SRV, RTV, and UAV. For luminance data view, the mapping
	///     to the view channel is Y-&gt;R8. For chrominance data view, the mapping to the view
	///     channel is U-&gt;R8 and V-&gt;G8. For more info about YUV formats for video rendering,
	///     see Recommended 8-Bit YUV Formats for Video Rendering. Width and height must
	///     be even. Direct3D 11 staging resources and initData parameters for this format
	///     use (rowPitch * (height + (height / 2))) bytes. The first (SysMemPitch * height)
	///     bytes are the Y plane, the remaining (SysMemPitch * (height / 2)) bytes are the
	///     UV plane. Direct3D 11.1: This value is not supported until Windows 8.
	/// </summary>
	NV12,
	/// <summary>
	///     10-bit per channel planar YUV 4:2:0 video resource format. Valid luminance data
	///     view formats for this video resource format are R16_UNorm
	///     and R16_UInt. The runtime does not enforce whether the lowest
	///     6 bits are 0 (given that this video resource format is a 10-bit format that uses
	///     16 bits). If required, application shader code would have to enforce this manually.
	///     From the runtime's point of view, P010 is no different than
	///     P016. Valid chrominance data view formats (width and height
	///     are each 1/2 of luminance view) for this video resource format are R16G16_UNorm
	///     and R16G16_UInt. For UAVs, an additional valid chrominance
	///     data view format is R32_UInt. By using R32_UInt
	///     for UAVs, you can both read and write as opposed to just writing for R16G16_UNorm
	///     and R16G16_UInt. Supported view types are SRV, RTV, and UAV.
	///     For luminance data view, the mapping to the view channel is Y-&gt;R16. For chrominance
	///     data view, the mapping to the view channel is U-&gt;R16 and V-&gt;G16. For more info
	///     about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for
	///     Video Rendering. Width and height must be even. Direct3D 11 staging resources
	///     and initData parameters for this format use (rowPitch * (height + (height / 2)))
	///     bytes. The first (SysMemPitch * height) bytes are the Y plane; the remaining
	///     (SysMemPitch * (height / 2)) bytes are the UV plane. Direct3D 11.1: This value
	///     is not supported until Windows 8.
	/// </summary>
	P010,
	/// <summary>
	///     16-bit per channel planar YUV 4:2:0 video resource format. Valid luminance data
	///     view formats for this video resource format are R16_UNorm
	///     and R16_UInt. Valid chrominance data view formats (width
	///     and height are each 1/2 of luminance view) for this video resource format are
	///     R16G16_UNorm and R16G16_UInt. For UAVs,
	///     an additional valid chrominance data view format is R32_UInt.
	///     By using R32_UInt for UAVs, you can both read and write as
	///     opposed to just write for R16G16_UNorm and R16G16_UInt.
	///     Supported view types are SRV, RTV, and UAV. For luminance data view, the mapping
	///     to the view channel is Y-&gt;R16. For chrominance data view, the mapping to the
	///     view channel is U-&gt;R16 and V-&gt;G16. For more information about YUV formats for video
	///     rendering, see Recommended 8-Bit YUV Formats for Video Rendering. Width and height
	///     must be even. Direct3D 11 staging resources and initData parameters for this
	///     format use (rowPitch * (height + (height / 2))) bytes. The first (SysMemPitch
	///     * height) bytes are the Y plane, the remaining (SysMemPitch * (height / 2)) bytes
	///     are the UV plane. Direct3D 11.1: This value is not supported until Windows 8.
	/// </summary>
	P016,
	/// <summary>
	///     8-bit per channel planar YUV 4:2:0 video resource format. This format is subsampled
	///     where each pixel has its own Y value, but each 2x2 pixel block shares a single
	///     U and V value. The runtime requires that the width and height of all resources
	///     created with this format be multiples of 2. The runtime also requires
	///     that the left, right, top, and bottom members of any RECT
	///     used for this format be multiples of 2. This format differs from NV12
	///     in that the layout of the data within the resource is completely opaque to applications.
	///     Applications cannot use the CPU to map the resource and then access the data
	///     within the resource. You cannot use shaders with this format. Because of this
	///     behavior, legacy hardware that supports a non-NV12 4:2:0 layout (for example,
	///     YV12, and so on) can be used. Also, new hardware that has a 4:2:0 implementation
	///     better than NV12 can be used when the application does not need the data to be
	///     in a standard layout. For more info about YUV formats for video rendering, see
	///     Recommended 8-Bit YUV Formats for Video Rendering. Width and height must be even.
	///     Direct3D 11 staging resources and initData parameters for this format use (rowPitch
	///     * (height + (height / 2))) bytes. Direct3D 11.1: This value is not supported
	///     until Windows 8.
	/// </summary>
	Opaque420,
	/// <summary>
	///     Most common YUV 4:2:2 video resource format. Valid view formats for this video
	///     resource format are R8G8B8A8_UNorm and R8G8B8A8_UInt.
	///     For UAVs, an additional valid view format is R32_UInt. By
	///     using R32_UInt for UAVs, you can both read and write as opposed
	///     to just writing for R8G8B8A8_UNorm and R8G8B8A8_UInt.
	///     Supported view types are SRV and UAV. One view provides a straightforward mapping
	///     of the entire surface. The mapping to the view channel is Y0-&gt;R8, U0-&gt;G8, Y1-&gt;B8,
	///     and V0-&gt;A8. A unique valid view format for this video resource format is R8G8_B8G8_UNorm.
	///     With this view format, the width of the view appears to be twice what the R8G8B8A8_UNorm
	///     or R8G8B8A8_UInt view would be when hardware reconstructs
	///     RGBA automatically on read and before filtering. This Direct3D hardware behavior
	///     is legacy and is likely not useful anymore. With this view format, the mapping
	///     to the view channel is Y0-&gt;R8, U0-&gt; G8[0], Y1-&gt;B8, and V0-&gt; G8[1]. For more info
	///     about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for
	///     Video Rendering. Width must be even. Direct3D 11.1: This value is not supported
	///     until Windows 8.
	/// </summary>
	YUY2,
	/// <summary>
	///     10-bit per channel packed YUV 4:2:2 video resource format. Valid view formats
	///     for this video resource format are R16G16B16A16_UNorm and
	///     R16G16B16A16_UInt. The runtime does not enforce whether the
	///     lowest 6 bits are 0 (given that this video resource format is a 10-bit format
	///     that uses 16 bits). If required, application shader code would have to enforce
	///     this manually. From the runtime's point of view, Y210 is
	///     no different from Y216. Supported view types are SRV and
	///     UAV. One view provides a straightforward mapping of the entire surface. The mapping
	///     to the view channel is Y0-&gt;R16, U-&gt;G16, Y1-&gt;B16, and V-&gt;A16. For more info about
	///     YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video
	///     Rendering. Width must be even. Direct3D 11.1: This value is not supported until
	///     Windows 8.
	/// </summary>
	Y210,
	/// <summary>
	///     16-bit per channel packed YUV 4:2:2 video resource format. Valid view formats
	///     for this video resource format are R16G16B16A16_UNorm and
	///     R16G16B16A16_UInt. Supported view types are SRV and UAV.
	///     One view provides a straightforward mapping of the entire surface. The mapping
	///     to the view channel is Y0-&gt;R16, U-&gt;G16, Y1-&gt;B16, and V-&gt;A16. For more info about
	///     YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video
	///     Rendering. Width must be even. Direct3D 11.1: This value is not supported until
	///     Windows 8.
	/// </summary>
	Y216,
	/// <summary>
	///     Most common planar YUV 4:1:1 video resource format. Valid luminance data view
	///     formats for this video resource format are R8_UNorm and R8_UInt.
	///     Valid chrominance data view formats (width and height are each 1/4 of luminance
	///     view) for this video resource format are R8G8_UNorm and R8G8_UInt.
	///     Supported view types are SRV, RTV, and UAV. For luminance data view, the mapping
	///     to the view channel is Y-&gt;R8. For chrominance data view, the mapping to the view
	///     channel is U-&gt;R8 and V-&gt;G8. For more info about YUV formats for video rendering,
	///     see Recommended 8-Bit YUV Formats for Video Rendering. Width must be a multiple
	///     of 4. Direct3D11 staging resources and initData parameters for this format use
	///     (rowPitch * height * 2) bytes. The first (SysMemPitch * height) bytes are the
	///     Y plane, the next ((SysMemPitch / 2) * height) bytes are the UV plane, and the
	///     remainder is padding. Direct3D 11.1: This value is not supported until Windows 8.
	/// </summary>
	NV11,
	/// <summary>
	///     4-bit palletized YUV format that is commonly used for DVD subpictures. For more
	///     information about YUV formats for video rendering, see Recommended 8-Bit YUV Formats
	///     for Video Rendering. Direct3D 11.1: This value is not supported until Windows 8.
	/// </summary>
	AI44,
	/// <summary>
	///     4-bit palletized YUV format that is commonly used for DVD subpicture. For more
	///     information about YUV formats for video rendering, see Recommended 8-Bit YUV Formats
	///     for Video Rendering. Direct3D 11.1: This value is not supported until Windows 8.
	/// </summary>
	IA44,
	/// <summary>
	///     8-bit palletized format used for palletized RGB data when the processor
	///     processes ISDB-T data and for palletized YUV data when the processor processes
	///     BluRay data. For more info about YUV formats for video rendering, see Recommended
	///     8-Bit YUV Formats for Video Rendering. Direct3D 11.1: This value is not supported
	///     until Windows 8.
	/// </summary>
	P8,
	/// <summary>
	///     8-bit palettized format with 8 bits of alpha that is used for palettized YUV
	///     data when the processor processes Blu-ray data. For more information about YUV formats
	///     for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering. Direct3D
	///     11.1: This value is not supported until Windows 8.
	/// </summary>
	A8P8,
	/// <summary>
	///     A four-component, 16-bit unsigned-normalized integer format that supports 4 bits
	///     for each channel including alpha. Direct3D 11.1: This value is not supported
	///     until Windows 8.
	/// </summary>
	B4G4R4A4_UNorm,
	/// <summary>
	///     Forces this enumeration to compile to 32 bits in size. Without this value, some
	///     compilers would allow this enumeration to compile to a size other than 32 bits.
	///     This value is not used.
	/// </summary>
	P208,
	/// <summary>
	///     No documentation available.
	/// </summary>
	V208,
	/// <summary>
	///     No documentation available.
	/// </summary>
	V408,
	/// <summary>
	/// 16-bit RGBA color.
	/// </summary>
	R4G4B4A4,
	/// <summary>
	/// PVRTC 2bpp RGB.
	/// </summary>
	PVRTC_2BPP_RGB,
	/// <summary>
	/// PVRTC 4bpp RGB.
	/// </summary>
	PVRTC_4BPP_RGB,
	/// <summary>
	/// PVRTC 2bpp RGBA.
	/// </summary>
	PVRTC_2BPP_RGBA,
	/// <summary>
	/// PVRTC 4bpp RGBA.
	/// </summary>
	PVRTC_4BPP_RGBA,
	/// <summary>
	/// PVRTC 2bpp sRGB.
	/// </summary>
	PVRTC_2BPP_RGB_SRGB,
	/// <summary>
	/// PVRTC 4bpp sRGB.
	/// </summary>
	PVRTC_4BPP_RGB_SRGB,
	/// <summary>
	/// PVRTC 2bpp sRGBa.
	/// </summary>
	PVRTC_2BPP_RGBA_SRGBA,
	/// <summary>
	/// PVRTC 4bpp sRGBA.
	/// </summary>
	PVRTC_4BPP_RGBA_SRGBA,
	/// <summary>
	/// ETC1.
	/// </summary>
	ETC1_RGB8,
	/// <summary>
	/// ETC2.
	/// </summary>
	ETC2_RGBA,
	/// <summary>
	/// ETC2 sRGB.
	/// </summary>
	ETC2_RGBA_SRGB
}
