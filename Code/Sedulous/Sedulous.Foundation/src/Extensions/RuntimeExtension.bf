namespace System;

extension Runtime
{
	[NoReturn]
	public static void InvalidOperation(String msg = "Invalid operation", String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
		String failStr = scope .()..AppendF("{} at line {} in {}", msg, line, filePath);
		Internal.FatalError(failStr, 1);
	}
}