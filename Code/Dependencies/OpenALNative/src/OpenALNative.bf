using System;

namespace OpenALNative;

using internal OpenALNative;

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