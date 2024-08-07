using System;
using System.Collections;
namespace Sedulous.RHI;

/// <summary>
/// This class represent the result of a compilation process in a shader.
/// </summary>
public class CompilationResult
{
	/// <summary>
	/// The byte code before compile a shader.
	/// </summary>
	public readonly List<uint8> ByteCode { get; private set; } = new .() ~ delete _;

	/// <summary>
	/// True if the compilation was wrong.
	/// </summary>
	public bool HasErrors { get; private set; } = false;

	/// <summary>
	/// The error line number.
	/// </summary>
	public uint32 ErrorLine { get; private set; } = 0;

	/// <summary>
	/// Error message if hasErrors is true.
	/// </summary>
	public readonly String Message { get; private set; } = new .() ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.CompilationResult" /> struct.
	/// </summary>
	public this()
	{
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.CompilationResult" /> struct.
	/// </summary>
	/// <param name="bytecode">The compile byte code.</param>
	/// <param name="hasErrors">Whether the compilation was success or not.</param>
	/// <param name="errorLine">The error line number if hasError is true.</param>
	/// <param name="message">The error message if hasErrors is true.</param>
	public void Set(uint8[] bytecode, bool hasErrors, uint32 errorLine = 0, String message = null)
	{
		this.ByteCode.Clear();
		bytecode.CopyTo(this.ByteCode);

		this.HasErrors = hasErrors;
		this.ErrorLine = errorLine;
		this.Message.Clear();
		if (message != null)
		{
			this.Message.Set(message);
		}
	}
}
