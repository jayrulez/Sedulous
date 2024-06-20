using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;

namespace Sedulous.RHI.DirectX12;

/// <summary>
/// This class represent a native instance of a DirectX shader.
/// </summary>
public class DX12Shader : Shader
{
	/// <summary>
	/// The DirectX 12 shader.
	/// </summary>
	public readonly D3D12_SHADER_BYTECODE NativeShader;

	private String name;

	private static bool environmentSet;

	/// <inheritdoc />
	public override void* NativePointer => null;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			name = value;
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12Shader" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The shader description.</param>
	public this(GraphicsContext context, ref ShaderDescription description)
		: base(context, ref description)
	{
		NativeShader = .()
			{
				pShaderBytecode = description.ShaderBytes.Ptr,
				BytecodeLength = (.)description.ShaderBytes.Count
			};
	}

	/// <inheritdoc />
	public override void Dispose()
	{
	}
}
