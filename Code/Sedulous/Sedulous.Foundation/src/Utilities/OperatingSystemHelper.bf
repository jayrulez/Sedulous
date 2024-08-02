using System;
namespace Sedulous.Foundation.Utilities;

/// <summary>
/// Helper class to determine executing OS platform.
/// </summary>
static class OperatingSystemHelper
{
	/// <summary>
	/// Checks current executing platform.
	/// </summary>
	/// <param name="platform">Platform to check.</param>
	/// <returns>True if platform check succees; false otherwise.</returns>
	public static bool IsOSPlatform(PlatformType platform)
	{
		switch (platform)
		{
		case PlatformType.Windows:
			return OperatingSystem.IsWindows();
		case PlatformType.Linux:
			return OperatingSystem.IsLinux();
		case PlatformType.Android:
			return OperatingSystem.IsAndroid();
		case PlatformType.MacOS:
			return OperatingSystem.IsMacOS();
		case PlatformType.iOS:
			return OperatingSystem.IsIOS();
		case PlatformType.Web:
			return OperatingSystem.IsBrowser();
		default:
			return false;
		}
	}

	/// <summary>
	/// Checks current executing platform is one of specified platforms.
	/// </summary>
	/// <param name="platforms">Lookup platforms.</param>
	/// <returns>True if any of the provided platforms matches; false otherwise.</returns>
	public static bool IsAnyOfOSPlatforms(Span<PlatformType> platforms)
	{
		return platforms.IndexOf(GetCurrentPlatfom()) != -1;
	}

	/// <summary>
	/// Gets current executing platform.
	/// </summary>
	/// <returns>Executing platform if found. Returns <see cref="F:Sedulous.Foundation.PlatformType.Undefined" /> if platform could not be determined.</returns>
	public static PlatformType GetCurrentPlatfom()
	{
		if (IsOSPlatform(PlatformType.Windows))
		{
			return PlatformType.Windows;
		}
		if (IsOSPlatform(PlatformType.Android))
		{
			return PlatformType.Android;
		}
		if (IsOSPlatform(PlatformType.Linux))
		{
			return PlatformType.Linux;
		}
		if (IsOSPlatform(PlatformType.iOS))
		{
			return PlatformType.iOS;
		}
		if (IsOSPlatform(PlatformType.MacOS))
		{
			return PlatformType.MacOS;
		}
		if (IsOSPlatform(PlatformType.Web))
		{
			return PlatformType.Web;
		}
		if (IsOSPlatform(PlatformType.UWP))
		{
			return PlatformType.UWP;
		}
		return PlatformType.Undefined;
	}
}