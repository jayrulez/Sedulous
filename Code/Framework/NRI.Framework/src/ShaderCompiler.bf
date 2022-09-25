using System;
using System.Collections;
using Dxc_Beef;
using System.IO;
using System.Diagnostics;
using static System.Windows.COM_IUnknown;
namespace NRI.Framework;

public static
{
	public static void GetShaderTarget(ShaderStage stage, StringView model, String target)
	{
		switch (stage) {
		case .VERTEX:
			target.AppendF("vs_{}", model);
			break;

		case .TESS_CONTROL:
			target.AppendF("hs_{}", model);
			break;

		case .TESS_EVALUATION:
			target.AppendF("ds_{}", model);
			break;

		case .GEOMETRY:
			target.AppendF("gs_{}", model);
			break;

		case .FRAGMENT:
			target.AppendF("ps_{}", model);
			break;

		case .COMPUTE:
			target.AppendF("cs_{}", model);
			break;

		case .RAYGEN:
			target.AppendF("lib_{}", model);
			break;

		case .MISS:
			target.AppendF("lib_{}", model);
			break;

		case .INTERSECTION:
			target.AppendF("lib_{}", model); //
			break;

		case .CLOSEST_HIT:
			target.AppendF("lib_{}", model);
			break;

		case .ANY_HIT:
			target.AppendF("lib_{}", model);
			break;

		case .CALLABLE:
			target.AppendF("lib_{}", model); //
			break;

		case .MESH_CONTROL:
			target.AppendF("ms_{}", model); //
			break;

		case .MESH_EVALUATION:
			target.AppendF("as_{}", model); //

			break;
		case .ALL: fallthrough;
		case .MAX_NUM: fallthrough;
		default:
			Runtime.FatalError();
		}
	}
}

enum ShaderCompilerOutputType
{
	DXIL,
	SPIRV
}

struct ShaderCompilationOptions
{
	public StringView shaderPath;
	public ShaderStage shaderStage;
	public StringView shaderModel;
	public StringView entryPoint;
	public ShaderCompilerOutputType outputType;
	public SPIRVBindingOffsets spirvBindingOffsets;
	public Dictionary<StringView, StringView> defines;
}

class ShaderCompiler
{
	public static bool IsInitialized { get; private set; }
	private static IDxcLibrary* pLibrary = null;

	private static Result<void> Initialize()
	{
		if (IsInitialized)
			return .Ok;

		HResult result = Dxc.CreateInstance(out pLibrary);
		if (result != .OK)
			return .Err;

		IsInitialized = true;
		return .Ok;
	}

	public static this()
	{
		Initialize();
	}

	public Result<void> CompileShader(ShaderCompilationOptions options, List<uint8> compiledByteCode)
	{
		String shaderDir = Path.GetDirectoryPath(options.shaderPath, .. scope .());


		IDxcCompiler3* pCompiler = null;

		var result = Dxc.CreateInstance(out pCompiler);
		if (result != .OK)
			return .Err;

		uint32 codePage = 0;
		IDxcBlobEncoding* pSource = null;
		result = pLibrary.CreateBlobFromFile(options.shaderPath, &codePage, out pSource);
		if (result != .OK)
			return .Err;

		String target = GetShaderTarget(options.shaderStage, options.shaderModel, .. scope .());

		List<StringView> arguments = scope .();

		arguments.Add("/Zi");
		arguments.Add("/Qembed_debug");


		arguments.Add("-E");
		arguments.Add(options.entryPoint);

		arguments.Add("-T");
		arguments.Add(target);

		if (options.defines != null)
		{
			for (var define in options.defines)
			{
				arguments.Add(scope :: $"-D{define.key}={define.value}");
			}
		}

		if (options.outputType == .DXIL)
		{
			arguments.Add(scope :: $"-DDXIL");
		}

		if (options.outputType == .SPIRV)
		{
			arguments.Add(scope :: $"-DSPIRV");
			arguments.Add(scope :: $"-DVULKAN");

			int VK_S_SHIFT = options.spirvBindingOffsets.samplerOffset;
			int VK_T_SHIFT = options.spirvBindingOffsets.textureOffset;
			int VK_B_SHIFT = options.spirvBindingOffsets.constantBufferOffset;
			int VK_U_SHIFT = options.spirvBindingOffsets.storageTextureAndBufferOffset;

			arguments.Add("-fvk-s-shift");
			arguments.Add(scope :: $"{VK_S_SHIFT}");
			arguments.Add("0");

			arguments.Add("-fvk-s-shift");
			arguments.Add(scope :: $"{VK_S_SHIFT}");
			arguments.Add("1");

			arguments.Add("-fvk-s-shift");
			arguments.Add(scope :: $"{VK_S_SHIFT}");
			arguments.Add("2");


			arguments.Add("-fvk-t-shift");
			arguments.Add(scope :: $"{VK_T_SHIFT}");
			arguments.Add("0");

			arguments.Add("-fvk-t-shift");
			arguments.Add(scope :: $"{VK_T_SHIFT}");
			arguments.Add("1");

			arguments.Add("-fvk-t-shift");
			arguments.Add(scope :: $"{VK_T_SHIFT}");
			arguments.Add("2");


			arguments.Add("-fvk-b-shift");
			arguments.Add(scope :: $"{VK_B_SHIFT}");
			arguments.Add("0");

			arguments.Add("-fvk-b-shift");
			arguments.Add(scope :: $"{VK_B_SHIFT}");
			arguments.Add("1");

			arguments.Add("-fvk-b-shift");
			arguments.Add(scope :: $"{VK_B_SHIFT}");
			arguments.Add("2");


			arguments.Add("-fvk-u-shift");
			arguments.Add(scope :: $"{VK_U_SHIFT}");
			arguments.Add("0");

			arguments.Add("-fvk-u-shift");
			arguments.Add(scope :: $"{VK_U_SHIFT}");
			arguments.Add("1");

			arguments.Add("-fvk-u-shift");
			arguments.Add(scope :: $"{VK_U_SHIFT}");
			arguments.Add("2");

			arguments.Add(scope :: $"-spirv");
			arguments.Add(scope :: $"-fspv-target-env=vulkan1.2");
			arguments.Add(scope :: $"-fspv-extension=SPV_EXT_descriptor_indexing");
			arguments.Add(scope :: $"-fspv-extension=KHR");
		}

		arguments.Add("-WX");
		arguments.Add("-O3");
		arguments.Add("-enable-16bit-types");

		DxcBuffer buffer = .()
			{
				Ptr = pSource.GetBufferPointer(),
				Size = pSource.GetBufferSize(),
				Encoding = 0
			};

		IncludeHandler includeHandler = .(pLibrary, shaderDir);

		result = pCompiler.Compile(&buffer, arguments, &includeHandler, ref IDxcResult.sIID, var ppResult);
		if (result != .OK)
			return .Err;

		IDxcResult* pResult = (.)ppResult;

		result = pResult.GetStatus(var status);

		if (status != .OK)
		{
			IDxcBlobEncoding* pErrors = null;
			result = pResult.GetErrorBuffer(out pErrors);
			if (pErrors != null && pErrors.GetBufferSize() > 0)
			{
				Debug.WriteLine(scope String((char8*)pErrors.GetBufferPointer()));
			}
			return .Err;
		}

		IDxcBlob* pBlob = null;

		result = pResult.GetResult(out pBlob);
		if (result != .OK)
			return .Err;

		compiledByteCode.AddRange(Span<uint8>((.)pBlob.GetBufferPointer(), pBlob.GetBufferSize()));

		return .Ok;
	}
}

struct IncludeHandler : IDxcIncludeHandler
{
	public this(IDxcLibrary* pLibrary, in String basePath)
	{
		m_pLibrary = pLibrary;
		m_BasePath = basePath;

		function [CallingConvention(.Stdcall)] HResult(IncludeHandler* this, ref Guid riid, void** result) queryInterface = => QueryInterface;
		function [CallingConvention(.Stdcall)] uint32(IncludeHandler* this) addRef = => AddRef;
		function [CallingConvention(.Stdcall)] uint32(IncludeHandler* this) release = => Release;
		function [CallingConvention(.Stdcall)] HResult(IncludeHandler* this, char16* pFilename, out IDxcBlob* ppIncludeSource) loadSource = => LoadSource;

		mDVT = .();
		mDVT.QueryInterface = (.)(void*)queryInterface;
		mDVT.AddRef = (.)(void*)addRef;
		mDVT.Release = (.)(void*)release;
		mDVT.LoadSource = (.)(void*)loadSource;

		mVT = &mDVT;
	}

	private HResult LoadSource(char16* pFilename, out IDxcBlob* ppIncludeSource)
	{
		IDxcBlobEncoding* pSource = null;

		String path = Path.InternalCombine(.. scope .(), m_BasePath, scope String(pFilename));

		HResult result = m_pLibrary.CreateBlobFromFile(path, null, out pSource);

		if (result == .OK && pSource != null)
			ppIncludeSource = pSource;
		else
			ppIncludeSource = ?;

		return result;
	}

	private HResult QueryInterface(ref Guid riid, void** result)
	{
		return (.)0x80004001;
	}

	private uint32 AddRef()
	{
		return (.)0x80004001;
	}

	private uint32 Release()
	{
		return (.)0x80004001;
	}


	public new VTable* VT
	{
		get
		{
			return (.)mVT;
		}
	}

	private IDxcIncludeHandler.VTable mDVT;
	private IDxcLibrary* m_pLibrary = null;
	private String m_BasePath = null;
}