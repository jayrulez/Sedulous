using System;
using Win32.Foundation;
using Win32.Graphics.Direct3D;
using System.Collections;
using Win32.Graphics.Direct3D.Fxc;
namespace Sedulous.GAL.D3D11.ShaderCompiler;

static class FxcCompiler
{
	public static HRESULT Compile(String shaderSource,
		ShaderMacro[] defines,
		ID3DInclude* include,
		String entryPoint,
		String sourceName,
		String profile,
		ShaderFlags flags,
		EffectFlags effectFlags,
		out ID3DBlob* blob,
		out ID3DBlob* errorBlob)
	{
		blob = null;
		errorBlob = null;

		if (String.IsNullOrEmpty(shaderSource))
		{
			Runtime.FatalError("No shader source provided.");
		}

		List<D3D_SHADER_MACRO> pDefines = scope .();

		if (defines != null)
		{
			for (var define in defines)
			{
				D3D_SHADER_MACRO pDefine = .()
					{
						Name = (.)define.Name.Ptr,
						Definition = (.)define.Definition.Ptr
					};
				pDefines.Add(pDefine);
			}
		}

		return D3DCompile(shaderSource.CStr(),
			(.)shaderSource.Length,
			(.)sourceName.CStr(),
			pDefines.Ptr,
			include,
			(.)entryPoint.CStr(),
			(.)profile.CStr(),
			(.)flags,
			(.)effectFlags,
			&blob,
			&errorBlob);
	}
}