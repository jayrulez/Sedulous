using Win32.Graphics.Direct3D.Dxc;
using System;
using System.Collections;
using Win32.Foundation;
namespace Sedulous.RHI.DirectX12;

static class DxcCompiler
{
	public static bool IsInitialized { get; private set; }

	private static IDxcLibrary* DxcLibrary = null;
	private static IDxcUtils* DxcUtils = null;
	private static IDxcCompiler3* DxcCompiler = null;

	public static Result<void> Initialize()
	{
		HRESULT hr = DxcCreateInstance(CLSID_DxcLibrary, IDxcLibrary.IID, (void**)&DxcLibrary);
		if (hr != S_OK)
			return .Err;

		hr = DxcCreateInstance(CLSID_DxcLibrary, IDxcUtils.IID, (void**)&DxcUtils);
		if (hr != S_OK)
			return .Err;

		hr = DxcCreateInstance(CLSID_DxcCompiler, IDxcCompiler3.IID, (void**)&DxcCompiler);
		if (hr != S_OK)
			return .Err;

		IsInitialized = true;
		return .Ok;
	}

	public static this()
	{
		Initialize();
	}

	public static ~this()
	{
		DxcCompiler?.Release();
		DxcUtils?.Release();
		DxcLibrary?.Release();
	}

	public static IDxcResult* Compile(StringView shaderSource, Span<String> arguments, IDxcIncludeHandler* includeHandler = null)
	{
		var includeHandler;
		if (includeHandler == null)
		{
			DxcUtils.CreateDefaultIncludeHandler(&includeHandler);
			//defer:: includeHandler.Release();
		}

		DxcBuffer* buffer = scope DxcBuffer()
			{
				Ptr = shaderSource.Ptr,
				Size = (.)shaderSource.Length,
				Encoding = (.)DXC_CP.DXC_CP_UTF8
			};

		List<char16*> argList = scope .();
		for (var argument in arguments)
		{
			argList.Add(argument.ToScopedNativeWChar!::());
		}

		IDxcResult* result = null;
		DxcCompiler.Compile(buffer, argList.Ptr, (.)argList.Count, includeHandler, IDxcResult.IID, (void**)&result);
		return result;
	}

	public static IDxcResult* Compile(DxcShaderStage shaderStage, String source, String entryPoint,
		DxcCompilerOptions? compilerOptions = null,
		String fileName = null,
		DxcDefine[] defines = null,
		IDxcIncludeHandler* includeHandler = null,
		String[] additionalArguments = null)
	{
		DxcCompilerOptions options = default;

		if (compilerOptions == null)
		{
			options = .();
		} else
		{
			options = compilerOptions.Value;
		}

		String profile = GetShaderProfile(shaderStage, options.ShaderModel, .. scope .());

		var arguments = scope List<String>();
		if (!String.IsNullOrEmpty(fileName))
		{
			arguments.Add(fileName);
		}

		arguments.Add("-E");
		arguments.Add(entryPoint);

		arguments.Add("-T");
		arguments.Add(profile);

		// Defines
		if (defines != null && defines.Count > 0)
		{
			for (DxcDefine define in defines)
			{
				String defineValue = scope:: String(define.Value);
				if (String.IsNullOrEmpty(defineValue))
					defineValue = "1";

				arguments.Add("-D");
				arguments.Add(scope :: $"{define.Name}={defineValue}");
			}
		}

		if (options.EnableDebugInfo)
		{
			arguments.Add("-Zi");
		}

		if (options.EnableDebugInfoSlimFormat)
		{
			arguments.Add("-Zs");
		}

		if (options.SkipValidation)
		{
			arguments.Add("-Vd");
		}

		if (options.SkipOptimizations)
		{
			arguments.Add("-Od");
		}
		else
		{
			if (options.OptimizationLevel < 4)
			{
				arguments.Add(scope :: $"-O{options.OptimizationLevel}");
			}
			else
			{
				Runtime.FatalError("Invalid optimization level.");
			}
		}

		// HLSL matrices are translated into SPIR-V OpTypeMatrixs in a transposed manner,
		// See also https://antiagainst.github.io/post/hlsl-for-vulkan-matrices/
		if (options.PackMatrixRowMajor)
		{
			arguments.Add("-Zpr");
		}
		if (options.PackMatrixColumnMajor)
		{
			arguments.Add("-Zpc");
		}
		if (options.AvoidFlowControl)
		{
			arguments.Add("-Gfa");
		}
		if (options.PreferFlowControl)
		{
			arguments.Add("-Gfp");
		}

		if (options.EnableStrictness)
		{
			arguments.Add("-Ges");
		}

		if (options.EnableBackwardCompatibility)
		{
			arguments.Add("-Gec");
		}

		if (options.IEEEStrictness)
		{
			arguments.Add("-Gis");
		}

		if (options.WarningsAreErrors)
		{
			arguments.Add("-WX");
		}

		if (options.ResourcesMayAlias)
		{
			arguments.Add("-res_may_alias");
		}

		if (options.AllResourcesBound)
		{
			arguments.Add("-all_resources_bound");
		}

		if (options.Enable16bitTypes)
		{
			if (options.ShaderModel.Major >= 6
				&& options.ShaderModel.Minor >= 2)
			{
				arguments.Add("-enable-16bit-types");
			}
			else
			{
				Runtime.FatalError("16-bit types requires shader model 6.2 or up.");
			}
		}

		// HLSL version, default 2018.
		arguments.Add("-HV");
		arguments.Add(scope $"{options.HLSLVersion}");

		if (options.GenerateSpirv)
		{
			arguments.Add("-spirv");

			if (options.VkUseGLLayout)
				arguments.Add("-fvk-use-gl-layout");
			if (options.VkUseDXLayout)
				arguments.Add("-fvk-use-dx-layout");
			if (options.VkUseScalarLayout)
				arguments.Add("-fvk-use-scalar-layout");

			if (options.VkUseDXPositionW)
				arguments.Add("-fvk-use-dx-position-w");

			if (options.SpvFlattenResourceArrays)
				arguments.Add("-fspv-flatten-resource-arrays");
			if (options.SpvReflect)
				arguments.Add("-fspv-reflect");

			arguments.Add(scope :: $"-fspv-target-env=vulkan{options.SpvTargetEnvMajor}.{options.SpirvTargetEnvMinor}");

			if (options.VkBufferShift > 0)
			{
				arguments.Add("-fvk-b-shift");
				arguments.Add(scope :: $"{options.VkBufferShift}");
				arguments.Add(scope :: $"{options.VkBufferShiftSet}");
			}

			if (options.VkTextureShift > 0)
			{
				arguments.Add("-fvk-t-shift");
				arguments.Add(scope :: $"{options.VkTextureShift}");
				arguments.Add(scope :: $"{options.VkTextureShiftSet}");
			}

			if (options.VkSamplerShift > 0)
			{
				arguments.Add("-fvk-s-shift");
				arguments.Add(scope :: $"{options.VkSamplerShift}");
				arguments.Add(scope :: $"{options.VkSamplerShiftSet}");
			}

			if (options.VkUAVShift > 0)
			{
				arguments.Add("-fvk-u-shift");
				arguments.Add(scope :: $"{options.VkUAVShift}");
				arguments.Add(scope :: $"{options.VkUAVShiftSet}");
			}
		}
		else
		{
			if (options.StripReflectionIntoSeparateBlob)
			{
				arguments.Add("-Qstrip_reflect");
			}
		}


		if (additionalArguments != null && additionalArguments.Count > 0)
		{
			arguments.AddRange(additionalArguments);
		}

		return Compile(source, arguments, includeHandler);
	}

	public static void GetShaderProfile(DxcShaderStage shaderStage, DxcShaderModel shaderModel, String shaderProfile)
	{
		switch (shaderStage)
		{
		case DxcShaderStage.Vertex:
			shaderProfile.Append("vs");
			break;
		case DxcShaderStage.Hull:
			shaderProfile.Append("hs");
			break;
		case DxcShaderStage.Domain:
			shaderProfile.Append("ds");
			break;
		case DxcShaderStage.Geometry:
			shaderProfile.Append("gs");
			break;
		case DxcShaderStage.Pixel:
			shaderProfile.Append("ps");
			break;
		case DxcShaderStage.Compute:
			shaderProfile.Append("cs");
			break;
		case DxcShaderStage.Amplification:
			shaderProfile.Append("as");
			break;
		case DxcShaderStage.Mesh:
			shaderProfile.Append("ms");
			break;
		case DxcShaderStage.Library:
			shaderProfile.Append("lib");
			break;
		default:
			return;
		}

		shaderProfile.AppendF("_{}_{}", shaderModel.Major, shaderModel.Minor);
	}
}