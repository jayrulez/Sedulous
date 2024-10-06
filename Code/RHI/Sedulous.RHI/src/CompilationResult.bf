using System;
using System.Collections;
namespace Sedulous.RHI;

/// <summary>
/// This struct represents the result of a compilation process in a shader.
/// </summary>
public class CompilationResult
{
	/// <summary>
	/// The byte code before compiling a shader.
	/// </summary>
	public readonly List<uint8> ByteCode { get; private set; } = new .() ~ delete _;

	/// <summary>
	/// True if the compilation was incorrect.
	/// </summary>
	public bool HasErrors { get; private set; } = false;

	/// <summary>
	/// The line number of the error.
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
	/// <param name="bytecode">The compiled byte code.</param>
	/// <param name="hasErrors">Indicates whether the compilation was successful or not.</param>
	/// <param name="errorLine">The error line number if hasErrors is true.</param>
	/// <param name="message">The error message if hasErrors is true.</param>
	public void Set(uint8[] bytecode, bool hasErrors, uint32 errorLine = 0, String message = null)
	{
		this.ByteCode.Clear();
		this.ByteCode.Count = bytecode.Count;
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
