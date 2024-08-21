using System;
namespace Sedulous.Renderer;

static
{
	public static bool hasFlag<T>(T flags, T flagToTest)
		where T : enum
		where T : operator T & T
	{
		return flags & flagToTest != 0;
	}

	public static bool hasAnyFlags<T>(T flags, T flagsToTest)
		where T : enum
		where T : operator T & T
	{
		return flags & flagsToTest != 0;
	}

	public static bool hasAllFlags<T>(T flags, T flagsToTest)
		where T : enum
		where T : operator T & T
	{
		return flags & flagsToTest == flagsToTest;
	}

	public static T alignTo<T>(T size, T alignment) where T : var
	{
		return ((size - 1) / alignment + 1) * alignment;
	}

	public static void WriteWarning(StringView format, params Object[] args)
	{
		Console.WriteLine(scope $"Warning: {format}", params args);
		System.Diagnostics.Debug.WriteLine(scope $"Warning: {format}", params args);
	}

	public static void WriteError(StringView format, params Object[] args)
	{
		Console.WriteLine(scope $"Error: {format}", params args);
		System.Diagnostics.Debug.WriteLine(scope $"Warning: {format}", params args);
	}
}