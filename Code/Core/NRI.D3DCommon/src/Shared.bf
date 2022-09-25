using System;
using Win32;
using Win32.Foundation;
using Win32.Graphics.Dxgi;
namespace NRI.D3DCommon;

public static
{
	private const FormatSupportBits COMMON_SUPPORT =
	    FormatSupportBits.TEXTURE |
	    FormatSupportBits.STORAGE_TEXTURE |
	    FormatSupportBits.BUFFER |
	    FormatSupportBits.STORAGE_BUFFER |
	    FormatSupportBits.COLOR_ATTACHMENT |
	    FormatSupportBits.VERTEX_BUFFER;

	private const FormatSupportBits COMMON_SUPPORT_WITHOUT_VERTEX =
	    FormatSupportBits.TEXTURE |
	    FormatSupportBits.STORAGE_TEXTURE |
	    FormatSupportBits.BUFFER |
	    FormatSupportBits.STORAGE_BUFFER |
	    FormatSupportBits.COLOR_ATTACHMENT;

	public const FormatSupportBits[?] D3D_FORMAT_SUPPORT_TABLE = .(
	    FormatSupportBits.UNSUPPORTED, // UNKNOWN,

	    COMMON_SUPPORT_WITHOUT_VERTEX, // R8_UNORM,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // R8_SNORM,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // R8_UINT,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // R8_SINT,

	    COMMON_SUPPORT_WITHOUT_VERTEX, // RG8_UNORM,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // RG8_SNORM,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // RG8_UINT,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // RG8_SINT,

	    COMMON_SUPPORT_WITHOUT_VERTEX, // BGRA8_UNORM,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // BGRA8_SRGB,

	    COMMON_SUPPORT_WITHOUT_VERTEX, // RGBA8_UNORM,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // RGBA8_SNORM,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // RGBA8_UINT,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // RGBA8_SINT,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // RGBA8_SRGB,

	    COMMON_SUPPORT, // R16_UNORM,
	    COMMON_SUPPORT, // R16_SNORM,
	    COMMON_SUPPORT, // R16_UINT,
	    COMMON_SUPPORT, // R16_SINT,
	    COMMON_SUPPORT, // R16_SFLOAT,

	    COMMON_SUPPORT, // RG16_UNORM,
	    COMMON_SUPPORT, // RG16_SNORM,
	    COMMON_SUPPORT, // RG16_UINT,
	    COMMON_SUPPORT, // RG16_SINT,
	    COMMON_SUPPORT, // RG16_SFLOAT,

	    COMMON_SUPPORT, // RGBA16_UNORM,
	    COMMON_SUPPORT, // RGBA16_SNORM,
	    COMMON_SUPPORT, // RGBA16_UINT,
	    COMMON_SUPPORT, // RGBA16_SINT,
	    COMMON_SUPPORT, // RGBA16_SFLOAT,

	    COMMON_SUPPORT, // R32_UINT,
	    COMMON_SUPPORT, // R32_SINT,
	    COMMON_SUPPORT, // R32_SFLOAT,

	    COMMON_SUPPORT, // RG32_UINT,
	    COMMON_SUPPORT, // RG32_SINT,
	    COMMON_SUPPORT, // RG32_SFLOAT,

	    COMMON_SUPPORT, // RGB32_UINT,
	    COMMON_SUPPORT, // RGB32_SINT,
	    COMMON_SUPPORT, // RGB32_SFLOAT,

	    COMMON_SUPPORT, // RGBA32_UINT,
	    COMMON_SUPPORT, // RGBA32_SINT,
	    COMMON_SUPPORT, // RGBA32_SFLOAT,

	    COMMON_SUPPORT_WITHOUT_VERTEX, // R10_G10_B10_A2_UNORM,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // R10_G10_B10_A2_UINT,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // R11_G11_B10_UFLOAT,
	    COMMON_SUPPORT_WITHOUT_VERTEX, // R9_G9_B9_E5_UFLOAT,

	    FormatSupportBits.TEXTURE, // BC1_RGBA_UNORM,
	    FormatSupportBits.TEXTURE, // BC1_RGBA_SRGB,
	    FormatSupportBits.TEXTURE, // BC2_RGBA_UNORM,
	    FormatSupportBits.TEXTURE, // BC2_RGBA_SRGB,
	    FormatSupportBits.TEXTURE, // BC3_RGBA_UNORM,
	    FormatSupportBits.TEXTURE, // BC3_RGBA_SRGB,
	    FormatSupportBits.TEXTURE, // BC4_R_UNORM,
	    FormatSupportBits.TEXTURE, // BC4_R_SNORM,
	    FormatSupportBits.TEXTURE, // BC5_RG_UNORM,
	    FormatSupportBits.TEXTURE, // BC5_RG_SNORM,
	    FormatSupportBits.TEXTURE, // BC6H_RGB_UFLOAT,
	    FormatSupportBits.TEXTURE, // BC6H_RGB_SFLOAT,
	    FormatSupportBits.TEXTURE, // BC7_RGBA_UNORM,
	    FormatSupportBits.TEXTURE, // BC7_RGBA_SRGB,

	    // DEPTH_STENCIL_ATTACHMENT views
	    FormatSupportBits.DEPTH_STENCIL_ATTACHMENT, // D16_UNORM,
	    FormatSupportBits.DEPTH_STENCIL_ATTACHMENT, // D24_UNORM_S8_UINT,
	    FormatSupportBits.DEPTH_STENCIL_ATTACHMENT, // D32_SFLOAT,
	    FormatSupportBits.DEPTH_STENCIL_ATTACHMENT, // D32_SFLOAT_S8_UINT_X24,

	    // Depth-stencil specific SHADER_RESOURCE views
	    FormatSupportBits.TEXTURE, // R24_UNORM_X8,
	    FormatSupportBits.TEXTURE, // X24_R8_UINT,
	    FormatSupportBits.TEXTURE, // X32_R8_UINT_X24,
	    FormatSupportBits.TEXTURE, // R32_SFLOAT_X8_X24,

	    // MAX_NUM
	);

	public static void Asserts3(){
		
		Compiler.Assert(D3D_FORMAT_SUPPORT_TABLE.Count == (uint)Format.MAX_NUM, "some format is missing");
	}

	private const Format[100] DXGI_FORMAT_TABLE = .(
	    Format.UNKNOWN,                              // DXGI_FORMAT_UNKNOWN = 0,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R32G32B32A32_TYPELESS = 1,
	    Format.RGBA32_SFLOAT,                        // DXGI_FORMAT_R32G32B32A32_FLOAT = 2,
	    Format.RGBA32_UINT,                          // DXGI_FORMAT_R32G32B32A32_UINT = 3,
	    Format.RGBA32_SINT,                          // DXGI_FORMAT_R32G32B32A32_SINT = 4,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R32G32B32_TYPELESS = 5,
	    Format.RGB32_SFLOAT,                         // DXGI_FORMAT_R32G32B32_FLOAT = 6,
	    Format.RGB32_UINT,                           // DXGI_FORMAT_R32G32B32_UINT = 7,
	    Format.RGB32_SINT,                           // DXGI_FORMAT_R32G32B32_SINT = 8,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R16G16B16A16_TYPELESS = 9,
	    Format.RGBA16_SFLOAT,                        // DXGI_FORMAT_R16G16B16A16_FLOAT = 10,
	    Format.RGBA16_UNORM,                         // DXGI_FORMAT_R16G16B16A16_UNORM = 11,
	    Format.RGBA16_UINT,                          // DXGI_FORMAT_R16G16B16A16_UINT = 12,
	    Format.RGBA16_SNORM,                         // DXGI_FORMAT_R16G16B16A16_SNORM = 13,
	    Format.RGBA16_SINT,                          // DXGI_FORMAT_R16G16B16A16_SINT = 14,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R32G32_TYPELESS = 15,
	    Format.RG32_SFLOAT,                          // DXGI_FORMAT_R32G32_FLOAT = 16,
	    Format.RG32_UINT,                            // DXGI_FORMAT_R32G32_UINT = 17,
	    Format.RGB32_SINT,                           // DXGI_FORMAT_R32G32_SINT = 18,
	    Format.UNKNOWN,                              // DXGI_FORMAT_R32G8X24_TYPELESS = 19,
	    Format.D32_SFLOAT_S8_UINT_X24,               // DXGI_FORMAT_D32_FLOAT_S8X24_UINT = 20,
	    Format.R32_SFLOAT_X8_X24,                    // DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS = 21,
	    Format.X32_R8_UINT_X24,                      // DXGI_FORMAT_X32_TYPELESS_G8X24_UINT = 22,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R10G10B10A2_TYPELESS = 23,
	    Format.R10_G10_B10_A2_UNORM,                 // DXGI_FORMAT_R10G10B10A2_UNORM = 24,
	    Format.R10_G10_B10_A2_UINT,                  // DXGI_FORMAT_R10G10B10A2_UINT = 25,
	    Format.R11_G11_B10_UFLOAT,                   // DXGI_FORMAT_R11G11B10_FLOAT = 26,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R8G8B8A8_TYPELESS = 27,
	    Format.RGBA8_UNORM,                          // DXGI_FORMAT_R8G8B8A8_UNORM = 28,
	    Format.RGBA8_SRGB,                           // DXGI_FORMAT_R8G8B8A8_UNORM_SRGB = 29,
	    Format.RGBA8_UINT,                           // DXGI_FORMAT_R8G8B8A8_UINT = 30,
	    Format.RGBA8_SNORM,                          // DXGI_FORMAT_R8G8B8A8_SNORM = 31,
	    Format.RGBA8_SINT,                           // DXGI_FORMAT_R8G8B8A8_SINT = 32,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R16G16_TYPELESS = 33,
	    Format.RG16_SFLOAT,                          // DXGI_FORMAT_R16G16_FLOAT = 34,
	    Format.RG16_UNORM,                           // DXGI_FORMAT_R16G16_UNORM = 35,
	    Format.RG16_UINT,                            // DXGI_FORMAT_R16G16_UINT = 36,
	    Format.RG16_SNORM,                           // DXGI_FORMAT_R16G16_SNORM = 37,
	    Format.RG16_SINT,                            // DXGI_FORMAT_R16G16_SINT = 38,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R32_TYPELESS = 39,
	    Format.D32_SFLOAT,                           // DXGI_FORMAT_D32_FLOAT = 40,
	    Format.R32_SFLOAT,                           // DXGI_FORMAT_R32_FLOAT = 41,
	    Format.R32_UINT,                             // DXGI_FORMAT_R32_UINT = 42,
	    Format.R32_SINT,                             // DXGI_FORMAT_R32_SINT = 43,
	    Format.UNKNOWN,                              // DXGI_FORMAT_R24G8_TYPELESS = 44,
	    Format.D24_UNORM_S8_UINT,                    // DXGI_FORMAT_D24_UNORM_S8_UINT = 45,
	    Format.R24_UNORM_X8,                         // DXGI_FORMAT_R24_UNORM_X8_TYPELESS = 46,
	    Format.X24_R8_UINT,                          // DXGI_FORMAT_X24_TYPELESS_G8_UINT = 47,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R8G8_TYPELESS = 48,
	    Format.RG8_UNORM,                            // DXGI_FORMAT_R8G8_UNORM = 49,
	    Format.RG8_UINT,                             // DXGI_FORMAT_R8G8_UINT = 50,
	    Format.RG8_SNORM,                            // DXGI_FORMAT_R8G8_SNORM = 51,
	    Format.RG8_SINT,                             // DXGI_FORMAT_R8G8_SINT = 52,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R16_TYPELESS = 53,
	    Format.R16_SFLOAT,                           // DXGI_FORMAT_R16_FLOAT = 54,
	    Format.D16_UNORM,                            // DXGI_FORMAT_D16_UNORM = 55,
	    Format.R16_UNORM,                            // DXGI_FORMAT_R16_UNORM = 56,
	    Format.R16_UINT,                             // DXGI_FORMAT_R16_UINT = 57,
	    Format.R16_SNORM,                            // DXGI_FORMAT_R16_SNORM = 58,
	    Format.R16_SINT,                             // DXGI_FORMAT_R16_SINT = 59,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R8_TYPELESS = 60,
	    Format.R8_UNORM,                             // DXGI_FORMAT_R8_UNORM = 61,
	    Format.R8_UINT,                              // DXGI_FORMAT_R8_UINT = 62,
	    Format.R8_SNORM,                             // DXGI_FORMAT_R8_SNORM = 63,
	    Format.R8_SINT,                              // DXGI_FORMAT_R8_SINT = 64,
	    Format.UNKNOWN,                              // DXGI_FORMAT_A8_UNORM = 65,
	
	    Format.UNKNOWN,                              // DXGI_FORMAT_R1_UNORM = 66,
	    Format.R9_G9_B9_E5_UFLOAT,                   // DXGI_FORMAT_R9G9B9E5_SHAREDEXP = 67,
	    Format.UNKNOWN,                              // DXGI_FORMAT_R8G8_B8G8_UNORM = 68,
	    Format.UNKNOWN,                              // DXGI_FORMAT_G8R8_G8B8_UNORM = 69,
	    Format.UNKNOWN,                              // DXGI_FORMAT_BC1_TYPELESS = 70,
	    Format.BC1_RGBA_UNORM,                       // DXGI_FORMAT_BC1_UNORM = 71,
	    Format.BC1_RGBA_SRGB,                        // DXGI_FORMAT_BC1_UNORM_SRGB = 72,
	    Format.UNKNOWN,                              // DXGI_FORMAT_BC2_TYPELESS = 73,
	    Format.BC2_RGBA_UNORM,                       // DXGI_FORMAT_BC2_UNORM = 74,
	    Format.BC2_RGBA_SRGB,                        // DXGI_FORMAT_BC2_UNORM_SRGB = 75,
	    Format.UNKNOWN,                              // DXGI_FORMAT_BC3_TYPELESS = 76,
	    Format.BC3_RGBA_UNORM,                       // DXGI_FORMAT_BC3_UNORM = 77,
	    Format.BC3_RGBA_SRGB,                        // DXGI_FORMAT_BC3_UNORM_SRGB = 78,
	    Format.UNKNOWN,                              // DXGI_FORMAT_BC4_TYPELESS = 79,
	    Format.BC4_R_UNORM,                          // DXGI_FORMAT_BC4_UNORM = 80,
	    Format.BC4_R_SNORM,                          // DXGI_FORMAT_BC4_SNORM = 81,
	    Format.UNKNOWN,                              // DXGI_FORMAT_BC5_TYPELESS = 82,
	    Format.BC5_RG_UNORM,                         // DXGI_FORMAT_BC5_UNORM = 83,
	    Format.BC5_RG_SNORM,                         // DXGI_FORMAT_BC5_SNORM = 84,
	    Format.UNKNOWN,                              // DXGI_FORMAT_B5G6R5_UNORM = 85,
	    Format.UNKNOWN,                              // DXGI_FORMAT_B5G5R5A1_UNORM = 86,
	    Format.BGRA8_UNORM,                          // DXGI_FORMAT_B8G8R8A8_UNORM = 87,
	    Format.UNKNOWN,                              // DXGI_FORMAT_B8G8R8X8_UNORM = 88,
	    Format.UNKNOWN,                              // DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM = 89,
	    Format.UNKNOWN,                              // DXGI_FORMAT_B8G8R8A8_TYPELESS = 90,
	    Format.BGRA8_SRGB,                           // DXGI_FORMAT_B8G8R8A8_UNORM_SRGB = 91,
	    Format.UNKNOWN,                              // DXGI_FORMAT_B8G8R8X8_TYPELESS = 92,
	    Format.UNKNOWN,                              // DXGI_FORMAT_B8G8R8X8_UNORM_SRGB = 93,
	    Format.UNKNOWN,                              // DXGI_FORMAT_BC6H_TYPELESS = 94,
	    Format.BC6H_RGB_UFLOAT,                      // DXGI_FORMAT_BC6H_UF16 = 95,
	    Format.BC6H_RGB_SFLOAT,                      // DXGI_FORMAT_BC6H_SF16 = 96,
	    Format.UNKNOWN,                              // DXGI_FORMAT_BC7_TYPELESS = 97,
	    Format.BC7_RGBA_UNORM,                       // DXGI_FORMAT_BC7_UNORM = 98,
	    Format.BC7_RGBA_SRGB,                        // DXGI_FORMAT_BC7_UNORM_SRGB = 99,
	);

	public static Format GetFormat(uint32 dxgiFormat)
	{
	    return DXGI_FORMAT_TABLE[dxgiFormat];
	}
	
	public static Format ConvertDXGIFormatToNRI(uint32 dxgiFormat)
	{
	    return GetFormat(dxgiFormat);
	}

	public static Result GetResultFromHRESULT(int32 result)
	{
		if (SUCCEEDED(result))
			return Result.SUCCESS;

		if (result == E_INVALIDARG || result == E_POINTER || result == E_HANDLE)
			return Result.INVALID_ARGUMENT;

		if (result == DXGI_ERROR_UNSUPPORTED)
			return Result.UNSUPPORTED;

		if (result == DXGI_ERROR_DEVICE_REMOVED || result == DXGI_ERROR_DEVICE_RESET)
			return Result.DEVICE_LOST;

		if (result == E_OUTOFMEMORY)
			return Result.OUT_OF_MEMORY;

		return Result.FAILURE;
	}

	public static mixin RETURN_ON_BAD_HRESULT(DeviceLogger logger, HRESULT hresult, StringView format)
	{
		if (FAILED(hresult))
		{
			logger.ReportMessage(.TYPE_ERROR, format);

			return GetResultFromHRESULT(hresult);
		}
	}

	public static mixin RETURN_ON_BAD_HRESULT(DeviceLogger logger, HRESULT hresult, StringView format, Object arg1)
	{
		if (FAILED(hresult))
		{
			logger.ReportMessage(.TYPE_ERROR, format, arg1);

			return GetResultFromHRESULT(hresult);
		}
	}
}