using System;

namespace OpenALNative;

using internal OpenALNative;

[StaticInitPriority(99)]
class OpenALNativeImpl_Default : OpenALNativeImpl
{
	private static bool sInvokeErrorCallback = true;

	private static readonly NativeLibrary lib;

	static this()
	{
		switch (Environment.OSVersion.Platform)
		{
		case .Unix:
			NativeLibrary.Load("libopenal.so", out lib);
			break;
		case .MacOSX:
			NativeLibrary.Load("libopenal.dylib", out lib);
			break;
		default:
			//NativeLibrary.Load("OpenAL32.dll", out lib);
			NativeLibrary.Load("soft_oal.dll", out lib);
			break;
		}
	}

	static ~this()
	{
		if (lib != null)
			delete lib;
	}

	public this()
	{
	}
}