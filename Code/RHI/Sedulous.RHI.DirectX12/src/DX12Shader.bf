using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;
using Win32.Graphics.Direct3D.Dxc;
using Sedulous.Foundation.Utilities;

namespace Sedulous.RHI.DirectX12;

using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// This class represent a native instance of a DirectX shader.
/// </summary>
public class DX12Shader : Shader
{
	/// <summary>
	/// The DirectX 12 shader.
	/// </summary>
	public readonly D3D12_SHADER_BYTECODE NativeShader;

	private String name = new .() ~ delete _;

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
			name.Set(value);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12Shader" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The shader description.</param>
	public this(GraphicsContext context, in ShaderDescription description)
		: base(context, description)
	{
		NativeShader = .()
		{
			pShaderBytecode = description.ShaderBytes.Ptr,
			BytecodeLength = (.)description.ShaderBytes.Count
		};
	}

	/// <summary>
	/// Converts the shader source into byte code.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="shaderSource">The shader source text.</param>
	/// <param name="entryPoint">The entry point function name.</param>
	/// <param name="stage">The shader stage, <see cref="T:Sedulous.RHI.ShaderStages" />.</param>
	/// <param name="parameters">The compiler parameters.</param>
	/// <returns>The shader byte codes.</returns>
	public static void ShaderCompile(GraphicsContext context, String shaderSource, String entryPoint, ShaderStages stage, CompilerParameters parameters, ref CompilationResult result)
	{
		DxcShaderModel shaderModel = parameters.Profile.ToDirectX();
		DxcCompilerOptions compilerOptions = .()
		{
			PackMatrixRowMajor = true,
			ShaderModel = shaderModel
		};
		switch (parameters.CompilationMode)
		{
		case CompilationMode.Debug:
			compilerOptions.EnableDebugInfo = true;
			compilerOptions.SkipOptimizations = true;
			break;
		case CompilationMode.Release:
			compilerOptions.OptimizationLevel = 3;
			break;
		default: break;
		}
		DxcShaderStage dxgShaderStage = stage.ToDirectXStage();
		String directXEntryPoint = ((dxgShaderStage == DxcShaderStage.Library) ? String.Empty : entryPoint);
		IDxcResult* compilationResult = DxcCompiler.Compile(dxgShaderStage, shaderSource, directXEntryPoint, compilerOptions);
		uint32 line = 0;
		String message = String.Empty;
		int32 status = 0;
		compilationResult.GetStatus(&status);
		bool hasErrors = status != 0;
		if (hasErrors)
		{
			IDxcBlobUtf8* output = null;
			compilationResult.GetOutput(.DXC_OUT_ERRORS, IDxcBlobUtf8.IID, (void**)&output, null);
			message = scope :: .((char8*)output.GetStringPointer(), (.)output.GetStringLength());
			context.ValidationLayer.Notify("DX12", message);
			ProcessError(message, out line, out message);
		}
		IDxcBlob* resultBlob = null;
		compilationResult.GetResult(&resultBlob);
		uint32 length = (uint32)(int64)resultBlob.GetBufferSize();
		void* sourcePointer = resultBlob.GetBufferPointer();
		uint8[] byteCode = scope uint8[length];
		void* destinationPointer = byteCode.Ptr;
		Internal.MemCpy(destinationPointer, sourcePointer, length);
		result.Set(byteCode, hasErrors, line, message);
	}

	/// <inheritdoc />
	public override void Dispose()
	{
	}

	private static void ProcessError(in String error, out uint32 line, out String message)
	{
		line = 0;
		message = null;
		/*MatchCollection collection = new Regex("\\((\\d+),\\d+-?\\d+?\\): (.*)", RegexOptions.IgnoreCase | RegexOptions.Multiline).Matches(error);
		line = 0;
		message = String.Empty;
		for (int32 m = 0; m < collection.Count; m++)
		{
			String s_Line = collection[m].Groups[1].Value;
			String s_Message = collection[m].Groups[2].Value;
			line = ((!String.IsNullOrEmpty(s_Line)) ? uint32.Parse(s_Line) : 0);
			message = s_Message;
		}*/
	}
}
