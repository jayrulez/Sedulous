using System;

namespace Sedulous.Audio.OpenAL.Bindings;

using internal Sedulous.Audio.OpenAL.Bindings;

class OpenALNative
{
	private static readonly OpenALNativeImpl impl;

	static this()
	{
		switch (Environment.OSVersion.Platform)
		{
		default:
			impl = new OpenALNativeImpl_Default();
			break;
		}
	}

	static ~this()
	{
		if (impl != null)
			delete impl;
	}
}