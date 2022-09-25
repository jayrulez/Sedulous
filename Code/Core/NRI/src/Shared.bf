using System.Diagnostics;
using System;
namespace NRI;

public static
{
	public const uint32 PHYSICAL_DEVICE_GROUP_MAX_SIZE = 4;
	public const uint32 COMMAND_QUEUE_TYPE_NUM = (uint32)CommandQueueType.MAX_NUM;

	public static Vendor GetVendorFromID(uint32 vendorID)
	{
		switch (vendorID)
		{
		case 0x10DE: return Vendor.NVIDIA;
		case 0x1002: return Vendor.AMD;
		case 0x8086: return Vendor.INTEL;
		}

		return Vendor.UNKNOWN;
	}

	private const uint32[(uint)Format.MAX_NUM] TEXEL_BLOCK_WIDTH = .(
		0, // UNKNOWN

		1, // R8_UNORM
		1, // R8_SNORM
		1, // R8_UINT
		1, // R8_SINT

		1, // RG8_UNORM
		1, // RG8_SNORM
		1, // RG8_UINT
		1, // RG8_SINT

		1, // BGRA8_UNORM
		1, // BGRA8_SRGB

		1, // RGBA8_UNORM
		1, // RGBA8_SNORM
		1, // RGBA8_UINT
		1, // RGBA8_SINT
		1, // RGBA8_SRGB

		1, // R16_UNORM
		1, // R16_SNORM
		1, // R16_UINT
		1, // R16_SINT
		1, // R16_SFLOAT

		1, // RG16_UNORM
		1, // RG16_SNORM
		1, // RG16_UINT
		1, // RG16_SINT
		1, // RG16_SFLOAT

		1, // RGBA16_UNORM
		1, // RGBA16_SNORM
		1, // RGBA16_UINT
		1, // RGBA16_SINT
		1, // RGBA16_SFLOAT

		1, // R32_UINT
		1, // R32_SINT
		1, // R32_SFLOAT

		1, // RG32_UINT
		1, // RG32_SINT
		1, // RG32_SFLOAT

		1, // RGB32_UINT
		1, // RGB32_SINT
		1, // RGB32_SFLOAT

		1, // RGBA32_UINT
		1, // RGBA32_SINT
		1, // RGBA32_SFLOAT

		1, // R10_G10_B10_A2_UNORM
		1, // R10_G10_B10_A2_UINT
		1, // R11_G11_B10_UFLOAT
		1, // R9_G9_B9_E5_UFLOAT

		4, // BC1_RGBA_UNORM
		4, // BC1_RGBA_SRGB
		4, // BC2_RGBA_UNORM
		4, // BC2_RGBA_SRGB
		4, // BC3_RGBA_UNORM
		4, // BC3_RGBA_SRGB
		4, // BC4_R_UNORM
		4, // BC4_R_SNORM
		4, // BC5_RG_UNORM
		4, // BC5_RG_SNORM
		4, // BC6H_RGB_UFLOAT
		4, // BC6H_RGB_SFLOAT
		4, // BC7_RGBA_UNORM
		4, // BC7_RGBA_SRGB

		// DEPTH_STENCIL_ATTACHMENT views
		1, // D16_UNORM
		1, // D24_UNORM_S8_UINT
		1, // D32_SFLOAT
		1, // D32_SFLOAT_S8_UINT_X24

		// Depth-stencil specific SHADER_RESOURCE views
		0, // R24_UNORM_X8
		0, // X24_R8_UINT
		0, // X32_R8_UINT_X24
		0 // R32_SFLOAT_X8_X24
		);

	public static uint32 GetTexelBlockWidth(Format format)
	{
		return TEXEL_BLOCK_WIDTH[(uint)format];
	}

	private const uint32[(uint)Format.MAX_NUM] TEXEL_BLOCK_SIZE = .(
		1, // UNKNOWN

		1, // R8_UNORM
		1, // R8_SNORM
		1, // R8_UINT
		1, // R8_SINT

		2, // RG8_UNORM
		2, // RG8_SNORM
		2, // RG8_UINT
		2, // RG8_SINT

		4, // BGRA8_UNORM
		4, // BGRA8_SRGB

		4, // RGBA8_UNORM
		4, // RGBA8_SNORM
		4, // RGBA8_UINT
		4, // RGBA8_SINT
		4, // RGBA8_SRGB

		2, // R16_UNORM
		2, // R16_SNORM
		2, // R16_UINT
		2, // R16_SINT
		2, // R16_SFLOAT

		4, // RG16_UNORM
		4, // RG16_SNORM
		4, // RG16_UINT
		4, // RG16_SINT
		4, // RG16_SFLOAT

		8, // RGBA16_UNORM
		8, // RGBA16_SNORM
		8, // RGBA16_UINT
		8, // RGBA16_SINT
		8, // RGBA16_SFLOAT

		4, // R32_UINT
		4, // R32_SINT
		4, // R32_SFLOAT

		8, // RG32_UINT
		8, // RG32_SINT
		8, // RG32_SFLOAT

		12, // RGB32_UINT
		12, // RGB32_SINT
		12, // RGB32_SFLOAT

		16, // RGBA32_UINT
		16, // RGBA32_SINT
		16, // RGBA32_SFLOAT

		4, // R10_G10_B10_A2_UNORM
		4, // R10_G10_B10_A2_UINT
		4, // R11_G11_B10_UFLOAT
		4, // R9_G9_B9_E5_UFLOAT

		8, // BC1_RGBA_UNORM
		8, // BC1_RGBA_SRGB
		16, // BC2_RGBA_UNORM
		16, // BC2_RGBA_SRGB
		16, // BC3_RGBA_UNORM
		16, // BC3_RGBA_SRGB
		8, // BC4_R_UNORM
		8, // BC4_R_SNORM
		16, // BC5_RG_UNORM
		16, // BC5_RG_SNORM
		16, // BC6H_RGB_UFLOAT
		16, // BC6H_RGB_SFLOAT
		16, // BC7_RGBA_UNORM
		16, // BC7_RGBA_SRGB

		// DEPTH_STENCIL_ATTACHMENT views
		2, // D16_UNORM
		4, // D24_UNORM_S8_UINT
		4, // D32_SFLOAT
		8, // D32_SFLOAT_S8_UINT_X24

		// Depth-stencil specific SHADER_RESOURCE views
		0, // R24_UNORM_X8
		0, // X24_R8_UINT
		0, // X32_R8_UINT_X24
		0 // R32_SFLOAT_X8_X24
		);

	public static uint32 GetTexelBlockSize(Format format)
	{
		return TEXEL_BLOCK_SIZE[(uint)format];
	}

	public static uint32 GetPhysicalDeviceGroupMask(uint32 mask)
	{
		return mask == WHOLE_DEVICE_GROUP ? 0xff : mask;
	}

	public static void MessageCallback(void* userArg, char8* message, Message messageType)
	{
		//MaybeUnused(userArg);
		//MaybeUnused(messageType);

		Console.WriteLine(scope String(message));
		Debug.WriteLine(scope String(message));
	}

	static void AbortExecution(void* userArg)
	{
		//MaybeUnused(userArg);

//#if BF_PLATFORM_WINDOWS
//	    DebugBreak();
//#else
//	    raise(SIGTRAP);
//#endif
		System.Diagnostics.Debug.Break();
	}

	public static void CheckAndSetDefaultCallbacks(ref CallbackInterface callbackInterface)
	{
		if (callbackInterface.MessageCallback == null)
			callbackInterface.MessageCallback = => MessageCallback;

		if (callbackInterface.AbortExecution == null)
			callbackInterface.AbortExecution = => AbortExecution;
	}

	public static mixin RETURN_ON_FAILURE<T>(DeviceLogger logger, bool condition, T returnCode, StringView format)
	{
		if (!condition)
		{
			logger.ReportMessage(.TYPE_ERROR, format);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(DeviceLogger logger, bool condition, T returnCode, StringView format, var arg1)
	{
		if (!condition)
		{
			logger.ReportMessage(.TYPE_ERROR, format, arg1);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(DeviceLogger logger, bool condition, T returnCode, StringView format, var arg1, var arg2)
	{
		if (!condition)
		{
			logger.ReportMessage(.TYPE_ERROR, format, arg1, arg2);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(DeviceLogger logger, bool condition, T returnCode, StringView format, var arg1, var arg2, var arg3)
	{
		if (!condition)
		{
			logger.ReportMessage(.TYPE_ERROR, format, arg1, arg2, arg3);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(DeviceLogger logger, bool condition, T returnCode, StringView format, var arg1, var arg2, var arg3, var arg4)
	{
		if (!condition)
		{
			logger.ReportMessage(.TYPE_ERROR, format, arg1, arg2, arg3, arg4);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(DeviceLogger logger, bool condition, T returnCode, StringView format, var arg1, var arg2, var arg3, var arg4, var arg5)
	{
		if (!condition)
		{
			logger.ReportMessage(.TYPE_ERROR, format, arg1, arg2, arg3, arg4, arg5);

			return returnCode;
		}
	}

	public static mixin RETURN_ON_FAILURE<T>(DeviceLogger logger, bool condition, T returnCode, StringView format, var arg1, var arg2, var arg3, var arg4, var arg5, var arg6)
	{
		if (!condition)
		{
			logger.ReportMessage(.TYPE_ERROR, format, arg1, arg2, arg3, arg4, arg5, arg6);

			return returnCode;
		}
	}

	/*public static mixin RETURN_ON_FAILURE<T>(DeviceLogger logger, bool condition, T returnCode, StringView format, params Object[] args)
	{
		if (!condition)
		{
			logger.ReportMessage(.TYPE_ERROR, format, params args);

			return returnCode;
		}
	}*/

	public static void REPORT_INFO(DeviceLogger logger, StringView format, params Object[] args)
	{
		logger.ReportMessage(.TYPE_INFO, format, params args);
	}

	public static void REPORT_WARNING(DeviceLogger logger, StringView format, params Object[] args)
	{
		logger.ReportMessage(.TYPE_WARNING, format, params args);
	}

	public static void REPORT_ERROR(DeviceLogger logger, StringView format, params Object[] args)
	{
		logger.ReportMessage(.TYPE_ERROR, format, params args);
	}

	public static void CHECK(DeviceLogger logger, bool condition, StringView format, params Object[] args)
	{
#if DEBUG
		if (!condition)
			logger.ReportMessage(.TYPE_ERROR, format, params args);
#endif
	}
}