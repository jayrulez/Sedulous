using System;

namespace Sedulous.Platform;

/// <summary>
/// Surface info struct.
/// </summary>
struct SurfaceInfo : IEquatable<SurfaceInfo>, IHashable
{
	public NativeSurfaceType Type = .Unspecified;
	public using private NativeSurface NativeSurface;

	public bool Equals(SurfaceInfo other)
	{
		return Type == other.Type && NativeSurface == other.NativeSurface;
	}

	public int GetHashCode()
	{
		return (((int)Type).GetHashCode() * 397) ^ HashCode.Generate(NativeSurface);
	}
}

/// <summary>
/// Supported native surface types.
/// </summary>
enum NativeSurfaceType
{
	Unspecified,
	Win32,
	UWP,
	WinUI,
	X11,
	Wayland,
	Android,
	MetalIOS,
	MetalMacOS
}

[Union]
struct NativeSurface
{
	public Win32NativeSurface Win32;
	public UWPNativeSurface UWP;
	public X11NativeSurface X11;
	public WaylandNativeSurface Wayland;
	public AndroidNativeSurface Android;
	public MetalIOSNativeSurface MetalIOS;
	public MetalMacOSNativeSurface MetalMacOS;
}

struct Win32NativeSurface
{
	public void* Hwnd;
}

struct UWPNativeSurface
{
	public void* Surface;
}

struct X11NativeSurface
{
	public void* Display;
	public uint64 Window;
}

struct WaylandNativeSurface
{
	public void* Display;
	public void* Surface;
}

struct AndroidNativeSurface
{
	public void* JNIEnv;
	public void* Surface;
}

struct MetalIOSNativeSurface
{
	public void* View;
}

struct MetalMacOSNativeSurface
{
	public void* CAMetalLayer;
}