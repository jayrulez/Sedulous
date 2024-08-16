using System.Collections;
using System;
using Sedulous.RAL.ShaderTools;
using SPIRV_Cross;
using Dxc_Beef;
using System.IO;
namespace Sedulous.RAL;

using static SPIRV_Cross.SPIRV;

using internal Sedulous.RAL;

internal struct IncludeHandler : IDxcIncludeHandler
{
	public this(IDxcLibrary* pLibrary, in String basePath)
	{
		m_pLibrary = pLibrary;
		m_BasePath = basePath;

		function [CallingConvention(.Stdcall)] HRESULT(IncludeHandler* this, ref Guid riid, void** result) queryInterface = => InternalQueryInterface;
		function [CallingConvention(.Stdcall)] uint32(IncludeHandler* this) addRef = => InternalAddRef;
		function [CallingConvention(.Stdcall)] uint32(IncludeHandler* this) release = => InternalRelease;
		function [CallingConvention(.Stdcall)] HRESULT(IncludeHandler* this, char16* pFilename, out IDxcBlob* ppIncludeSource) loadSource = => InternalLoadSource;

		mDVT = .();
		mDVT.[Friend]QueryInterface = (.)(void*)queryInterface;
		mDVT.[Friend]AddRef = (.)(void*)addRef;
		mDVT.[Friend]Release = (.)(void*)release;
		mDVT.LoadSource = (.)(void*)loadSource;

		mVT = &mDVT;
	}

	private HRESULT InternalLoadSource(char16* pFilename, out IDxcBlob* ppIncludeSource)
	{
		IDxcBlobEncoding* pSource = null;

		String path = Path.InternalCombine(.. scope .(), m_BasePath, scope String(pFilename));

		HRESULT result = m_pLibrary.CreateBlobFromFile(path, null, out pSource);

		if (result == .S_OK && pSource != null)
			ppIncludeSource = pSource;
		else
			ppIncludeSource = ?;

		return result;
	}

	public new HRESULT LoadSource(in StringView pFilename, out IDxcBlob* ppIncludeSource)
		=> InternalLoadSource(pFilename.ToScopedNativeWChar!(), out ppIncludeSource);

	private HRESULT InternalQueryInterface(ref Guid riid, void** result)
	{
		return (.)0x80004001;
	}

	private uint32 InternalAddRef()
	{
		return (.)0x80004001;
	}

	private uint32 InternalRelease()
	{
		return (.)0x80004001;
	}

	private new VTable* VT
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

extension Shader
{
	private static void GetShaderTarget(ShaderType type, in String model, String target)
	{
		switch (type) {
		case ShaderType.kPixel:
			target.Set(scope $"ps_{model}");
		case ShaderType.kVertex:
			target.Set(scope $"vs_{model}");
		case ShaderType.kGeometry:
			target.Set(scope $"gs_{model}");
		case ShaderType.kCompute:
			target.Set(scope $"cs_{model}");
		case ShaderType.kAmplification:
			target.Set(scope $"as_{model}");
		case ShaderType.kMesh:
			target.Set(scope $"ms_{model}");
		case ShaderType.kLibrary:
			target.Set(scope $"lib_{model}");
		default:
			Runtime.Assert(false);
		}
	}

	public static override void Compile(in ShaderDesc shader, ShaderBlobType blob_type, List<uint8> byteCode)
	{
		//decltype(auto) dxc_support = GetDxcSupport(blob_type);

		String shader_path = shader.shader_path;
		String shader_dir = Path.GetDirectoryPath(shader.shader_path, .. scope .());

		IDxcLibrary* library = null;
		var hresult = Dxc.CreateInstance(out library);
		if (hresult != .S_OK)
			return;

		uint32 codePage = 0;
		IDxcBlobEncoding* source = null;
		hresult = library.CreateBlobFromFile(shader_path, &codePage, out source);
		if (hresult != .S_OK)
			return;

		String target = GetShaderTarget(shader.type, shader.model, .. scope .());
		String entrypoint = shader.entrypoint;
		List<(String key, String value)> defines_store = scope .();
		List<DxcDefine> defines = scope .();
		if (shader.define != null)
		{
			for (var define in shader.define)
			{
				defines_store.Add((define.key, define.value));
				defines.Add(.()
					{
						Name  = defines_store.Back.key.ToScopedNativeWChar!::(),
						Value = defines_store.Back.value.ToScopedNativeWChar!::()
					});
			}
		}

		List<StringView> arguments = scope .();
		Queue<StringView> dynamic_arguments = scope .();
		arguments.Add("/Zi");
		arguments.Add("/Qembed_debug");
		uint32 space = 0;

		arguments.Add(scope String("-E"));
		arguments.Add(entrypoint);

		arguments.Add(scope String("-T"));
		arguments.Add(target);

		if (blob_type == ShaderBlobType.kSPIRV)
		{
			arguments.Add("-spirv");
			arguments.Add("-fspv-target-env=vulkan1.2");
			arguments.Add("-fspv-extension=KHR");
			arguments.Add("-fspv-extension=SPV_NV_mesh_shader");
			arguments.Add("-fspv-extension=SPV_EXT_descriptor_indexing");
			arguments.Add("-fspv-extension=SPV_EXT_shader_viewport_index_layer");
			arguments.Add("-fspv-extension=SPV_GOOGLE_hlsl_functionality1");
			arguments.Add("-fspv-extension=SPV_GOOGLE_user_type");
			arguments.Add("-fvk-use-dx-layout");
			arguments.Add("-fspv-reflect");
			space = (uint32)shader.type;
		}

		arguments.Add("-auto-binding-space");
		dynamic_arguments.Add(space.ToString(.. scope .()));
		arguments.Add(dynamic_arguments.Back);

		IncludeHandler include_handler = .(library, shader_dir);

		IDxcCompiler3* compiler = null;
		hresult = Dxc.CreateInstance(out compiler);
		if (hresult != .S_OK)
			return;

		DxcBuffer buffer = .()
			{
				Ptr = source.GetBufferPointer(),
				Size = source.GetBufferSize(),
				Encoding = 0
			};

		hresult = compiler.Compile(&buffer, arguments, &include_handler, ref IDxcResult.IID, var ppResult);
		if (hresult != .S_OK)
			return;

		IDxcResult* result = (.)ppResult;

		hresult = result.GetStatus(var status);

		if (hresult == .S_OK)
		{
			hresult = result.GetResult(var dxc_blob);
			if (hresult != .S_OK)
				return;

			byteCode.AddRange(Span<uint8>((uint8*)dxc_blob.GetBufferPointer(), (int)dxc_blob.GetBufferSize()));
		} else
		{
			hresult = result.GetErrorBuffer(var errors);
			if (errors != null && errors.GetBufferSize() > 0)
			{
				System.Diagnostics.Debug.WriteLine(scope String((char8*)errors.GetBufferPointer()));
			}
		}
	}

	static bool g_fail_on_error = true;

	private static mixin SPVC_CHECK_RESULT(spvc_result result)
	{
		if (result != .SPVC_SUCCESS)
		{
			Runtime.FatalError(scope $"Failed: {result}");
		}
	}

	public static void error_callback(void* userdata, char8* error)
	{
		(void)userdata;
		if (g_fail_on_error)
		{
			Console.WriteLine("Error: {0}\n", scope String(error));
			Runtime.FatalError();
		}
		else
			Console.WriteLine("Expected error hit: {0}\n", scope String(error));
	}

	public static void ParseBindings(spvc_compiler compiler, Dictionary<String, uint32> mapping)
	{
		spvc_resources resources = .Null;

		SPVC_CHECK_RESULT!(spvc_compiler_create_shader_resources(compiler, &resources));

		delegate void(spvc_resources resources, spvc_resource_type type) enumerate_resources = scope [&] (resources, type) =>
			{
				spvc_reflected_resource* list = null;
				uint count = 0;
				SPVC_CHECK_RESULT!(spvc_resources_get_resource_list_for_type(resources, type, (.)&list, &count));
				for (uint i = 0; i < count; i++)
				{
					spvc_reflected_resource resource = list[i];
					String name = new .(spvc_compiler_get_name(compiler, resource.id)); // todo:this will leak. Perhaps pass in an allocator?
					uint32 index = spvc_compiler_msl_get_automatic_resource_binding(compiler, resource.id);
					mapping[name] = index;
				}
			};
		enumerate_resources(resources, .UniformBuffer);
		enumerate_resources(resources, .StorageBuffer);
		enumerate_resources(resources, .StorageImage);
		enumerate_resources(resources, .SeparateImage);
		enumerate_resources(resources, .SeparateSamplers);
		enumerate_resources(resources, .AtomicCounter);
		enumerate_resources(resources, .AccelerationStructure);
	}

	public static bool UseArgumentBuffers()
	{
		return false;
	}

	public static override void GetMSLShader(Span<uint8> blob, Dictionary<String, uint32> mapping, String mslShader)
	{
		Runtime.Assert(blob.Length % sizeof(SpvId) == 0);

		spvc_context context = .Null;

		SPVC_CHECK_RESULT!(spvc_context_create(&context));

		function void(void* userdata, char8* error) errorCb = => error_callback;
		spvc_error_callback cb = .((int)(void*)errorCb);

		spvc_context_set_error_callback(context, cb, null);

		spvc_compiler compiler = .Null;
		spvc_parsed_ir ir = .Null;
		spvc_compiler_options options = .Null;

		SpvId* buffer = (SpvId*)blob.Ptr;
		uint64 word_count = uint64(blob.Length / sizeof(SpvId));
		SPVC_CHECK_RESULT!(spvc_context_parse_spirv(context, buffer, word_count, &ir));
		SPVC_CHECK_RESULT!(spvc_context_create_compiler(context, .Msl, ir, .Copy, &compiler));
		SPVC_CHECK_RESULT!(spvc_compiler_create_compiler_options(compiler, &options));

		SPVC_CHECK_RESULT!(spvc_compiler_options_set_uint(options, .MslVersion, make_msl_version(2, 3)));
		SPVC_CHECK_RESULT!(spvc_compiler_options_set_bool(options, .MslArgumentBuffers, UseArgumentBuffers()));
		SPVC_CHECK_RESULT!(spvc_compiler_options_set_bool(options, .MslForceActiveArgumentBufferResources, UseArgumentBuffers()));
		SPVC_CHECK_RESULT!(spvc_compiler_options_set_uint(options, .MslArgumentBuffersTier, 1));

		SPVC_CHECK_RESULT!(spvc_compiler_install_compiler_options(compiler, options));

		char8* source = null;
		SPVC_CHECK_RESULT!(spvc_compiler_compile(compiler, (.)&source));
		mslShader.Set(scope String(source));

		ParseBindings(compiler, mapping);

		spvc_context_destroy(context);
	}

	public static override void GetMSLShader(in ShaderDesc shader, Dictionary<String, uint32> mapping, String mslShader)
	{
		List<uint8> blob = Compile(shader, ShaderBlobType.kSPIRV, .. scope .());
		GetMSLShader(blob, mapping, mslShader);
	}

	public static override void CreateShaderReflection(ShaderBlobType type, void* data, uint size, out ShaderReflection shaderReflection)
	{
		if (type == .kDXIL)
		{
			shaderReflection = new DXILReflection(data, size);
		} else if (type == .kSPIRV)
		{
			shaderReflection = new SPIRVReflection();
		} else
		{
			Runtime.NotImplementedError();
		}
	}

	public static override void DestroyReflection(ref ShaderReflection shaderReflection)
	{
		if (let dxilReflection = shaderReflection.As<DXILReflection>())
		{
			delete dxilReflection;
		}

		if (let spirvReflection = shaderReflection.As<SPIRVReflection>())
		{
			delete spirvReflection;
		}
	}
}