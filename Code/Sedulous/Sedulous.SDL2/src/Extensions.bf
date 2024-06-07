namespace System;

extension Runtime
{
	[NoReturn]
	public static void SDL2Error(String message = "SDL2 Error", String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
		Runtime.RuntimeError(message, filePath, line, 2);
	}
}