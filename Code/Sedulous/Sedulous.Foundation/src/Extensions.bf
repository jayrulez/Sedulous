namespace System;

extension Float
{
	public static bool IsPositiveInfinity(float f)
	{
		return f == float.PositiveInfinity;
	}

	public static bool IsNegativeInfinity(float f)
	{
		return f == float.NegativeInfinity;
	}
}

extension Double
{
	public static bool IsPositiveInfinity(double f)
	{
		return f == double.PositiveInfinity;
	}

	public static bool IsNegativeInfinity(double f)
	{
		return f == double.NegativeInfinity;
	}
}

extension Runtime
{
	[NoReturn]
	public static void FatalError(String msg = "Fatal error encountered", String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum, int stackOffset = 1)
	{
		String failStr = scope .()..AppendF("{} at line {} in {}", msg, line, filePath);
		Internal.FatalError(failStr, stackOffset);
	}

	[NoReturn]
	public static void ArgumentError(String message, String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
		Runtime.FatalError(message, filePath, line, 2);
	}

	[NoReturn]
	public static void InvalidOperationError(String message = "Invalid Operation", String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
		Runtime.FatalError(message, filePath, line, 2);
	}

	[NoReturn]
	public static void NotSupportedError(String message, String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
		Runtime.FatalError(message, filePath, line, 2);
	}
	
	[NoReturn]
	public static void ArgumentNullError(String message, String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
		Runtime.FatalError(message, filePath, line, 2);
	}
	
	[NoReturn]
	public static void ArgumentOutOfRangeError(String message, String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
		Runtime.FatalError(message, filePath, line, 2);
	}
	
	[NoReturn]
	public static void DivideByZeroError(String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
		Runtime.FatalError("Division by zero.", filePath, line, 2);
	}
}