namespace System;

extension Runtime
{
	[NoReturn]
	public static void GALError(String msg = "Fatal error encountered", String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
#if !BF_RUNTIME_REDUCED
		String failStr = scope .()..Append(msg, " at line ");
		line.ToString(failStr);
		failStr.Append(" in ", filePath);
		Internal.FatalError(failStr, 1);
#else
		Internal.FatalError("Fatal error", 1);
#endif
	}
	
	[NoReturn]
	public static void IllegalValue<T>(String msg = "Fatal error encountered", String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
#if !BF_RUNTIME_REDUCED
		String failStr = scope .()..Append(msg, " at line ");
		line.ToString(failStr);
		failStr.Append(" in ", filePath);
		Internal.FatalError(failStr, 1);
#else
		Internal.FatalError("Fatal error", 1);
#endif
	}
	
	[NoReturn]
	public static void IndexOutOfRangeError(String msg = "Fatal error encountered", String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
#if !BF_RUNTIME_REDUCED
		String failStr = scope .()..Append(msg, " at line ");
		line.ToString(failStr);
		failStr.Append(" in ", filePath);
		Internal.FatalError(failStr, 1);
#else
		Internal.FatalError("Fatal error", 1);
#endif
	}
	
	[NoReturn]
	public static void ArgumentNullError(String msg = "Fatal error encountered", String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
#if !BF_RUNTIME_REDUCED
		String failStr = scope .()..Append(msg, " at line ");
		line.ToString(failStr);
		failStr.Append(" in ", filePath);
		Internal.FatalError(failStr, 1);
#else
		Internal.FatalError("Fatal error", 1);
#endif
	}
	

	[NoReturn]
	public static void NotSupported(String msg = "Fatal error encountered", String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
#if !BF_RUNTIME_REDUCED
		String failStr = scope .()..Append(msg, " at line ");
		line.ToString(failStr);
		failStr.Append(" in ", filePath);
		Internal.FatalError(failStr, 1);
#else
		Internal.FatalError("Fatal error", 1);
#endif
	}
	
}