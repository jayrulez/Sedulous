using System;
namespace Sedulous.RHI;

/// <summary>
/// This struct represent the result of a compilation process in a shader.
/// </summary>
public struct CompilationResult
{
	/// <summary>
	/// The byte code before compile a shader.
	/// </summary>
	public readonly uint8[] ByteCode;

	/// <summary>
	/// True if the compilation was wrong.
	/// </summary>
	public readonly bool HasErrors;

	/// <summary>
	/// The error line number.
	/// </summary>
	public readonly uint32 ErrorLine;

	/// <summary>
	/// Error message if hasErrors is true.
	/// </summary>
	public readonly String Message;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.CompilationResult" /> struct.
	/// </summary>
	/// <param name="bytecode">The compile byte code.</param>
	/// <param name="hasErrors">Whether the compilation was success or not.</param>
	/// <param name="errorLine">The error line number if hasError is true.</param>
	/// <param name="message">The error message if hasErrors is true.</param>
	public this(uint8[] bytecode, bool hasErrors, uint32 errorLine = 0, String message = null)
	{
		ByteCode = bytecode;
		HasErrors = hasErrors;
		ErrorLine = errorLine;
		Message = message;
	}
}
