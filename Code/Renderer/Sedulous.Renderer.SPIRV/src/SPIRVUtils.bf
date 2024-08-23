using System;
using glslang_Beef;
using System.Collections;
using SPIRV_Cross;
namespace Sedulous.Renderer.SPIRV;

using internal Sedulous.Renderer.SPIRV;
using static SPIRV_Cross.SPIRV;


static
{
	const uint32 GLSLANG_VERSION_MAJOR = 0; // todo
	const uint32 GLSLANG_VERSION_MINOR = 0; // todo
	const uint32 GLSLANG_VERSION_PATCH = 0; // todo

	internal static bool CC_GLSLANG_VERSION_GREATOR_OR_EQUAL_TO(int major, int minor, int patch)
	{
		return (((major) < GLSLANG_VERSION_MAJOR) || ((major) == GLSLANG_VERSION_MAJOR &&
			(((minor) < GLSLANG_VERSION_MINOR) || ((minor) == GLSLANG_VERSION_MINOR &&
			((patch) <= GLSLANG_VERSION_PATCH)))));
	}

	internal static glslang_stage_t getShaderStage(ShaderStageFlagBit type)
	{
		switch (type) {
		case ShaderStageFlagBit.VERTEX: return .GLSLANG_STAGE_VERTEX;
		case ShaderStageFlagBit.CONTROL: return .GLSLANG_STAGE_TESSCONTROL;
		case ShaderStageFlagBit.EVALUATION: return .GLSLANG_STAGE_TESSEVALUATION;
		case ShaderStageFlagBit.GEOMETRY: return .GLSLANG_STAGE_GEOMETRY;
		case ShaderStageFlagBit.FRAGMENT: return .GLSLANG_STAGE_FRAGMENT;
		case ShaderStageFlagBit.COMPUTE: return .GLSLANG_STAGE_COMPUTE;
		default:
			{
				Runtime.Assert(false);
				return .GLSLANG_STAGE_VERTEX;
			}
		}
	}

	internal static glslang_target_client_version_t getClientVersion(int vulkanMinorVersion)
	{
		switch (vulkanMinorVersion) {
		case 0: return .GLSLANG_TARGET_VULKAN_1_0;
		case 1: return .GLSLANG_TARGET_VULKAN_1_1;
		case 2: return .GLSLANG_TARGET_VULKAN_1_2;
		case 3:
			if (CC_GLSLANG_VERSION_GREATOR_OR_EQUAL_TO(11, 10, 0))
			{
				return .GLSLANG_TARGET_VULKAN_1_3;
			} else
			{
				return .GLSLANG_TARGET_VULKAN_1_2;
			}
		default:
			{
				Runtime.Assert(false);
				return .GLSLANG_TARGET_VULKAN_1_0;
			}
		}
	}

	internal static glslang_target_language_version_t getTargetVersion(int vulkanMinorVersion)
	{
		switch (vulkanMinorVersion) {
		case 0: return .GLSLANG_TARGET_SPV_1_0;
		case 1: return .GLSLANG_TARGET_SPV_1_3;
		case 2: return .GLSLANG_TARGET_SPV_1_5;
		case 3:
			if (CC_GLSLANG_VERSION_GREATOR_OR_EQUAL_TO(11, 10, 0))
			{
				return .GLSLANG_TARGET_SPV_1_6;
			} else
			{
				return .GLSLANG_TARGET_SPV_1_5;
			}
		default:
			{
				Runtime.Assert(false);
				return .GLSLANG_TARGET_SPV_1_0;
			}
		}
	}
}

// https://www.khronos.org/registry/spir-v/specs/1.0/SPIRV.pdf
struct Id
{
	public uint32 opcode = 0;
	public uint32 typeId = 0;
	public uint32 storageClass = 0;
	public uint32* pLocation = null;
}

class SPIRVUtils
{
	public static SPIRVUtils getInstance() { return instance; }

	public void initialize(int32 vulkanMinorVersion)
	{
		glslang_initialize_process();

		_clientInputSemanticsVersion = 100 + vulkanMinorVersion * 10;
		_clientVersion = getClientVersion(vulkanMinorVersion);
		_targetVersion = getTargetVersion(vulkanMinorVersion);
	}

	public void destroy()
	{
		glslang_finalize_process();
		_output.Clear();
	}

	public void compileGLSL(ShaderStageFlagBit type, String source)
	{
		glslang_stage_t stage = getShaderStage(type);
		char8* string = source.CStr();

		glslang_resource_t* resources = scope glslang_resource_t();
		glslang_input_t input = .()
			{
				language = .GLSLANG_SOURCE_GLSL,
				stage = stage,
				client = .GLSLANG_CLIENT_VULKAN,
				client_version = _clientVersion,
				target_language = .GLSLANG_TARGET_SPV,
				target_language_version = _targetVersion,
				code = string,
				default_version = _clientInputSemanticsVersion,
				default_profile = .GLSLANG_NO_PROFILE,
				force_default_version_and_profile = 0,
				forward_compatible = 0,
				messages = .GLSLANG_MSG_DEFAULT_BIT,
				messages = .GLSLANG_MSG_SPV_RULES_BIT | .GLSLANG_MSG_VULKAN_RULES_BIT,
				resource = resources
			};
		_shader = glslang_shader_create(&input);

		if (glslang_shader_preprocess(_shader, &input) == 0)
		{
			String infoLog = scope .(glslang_shader_get_info_log(_shader));
			String debugLog = scope .(glslang_shader_get_info_debug_log(_shader));
			WriteError("GLSL Parsing Failed:\n{}\n{}", infoLog, debugLog);
		}

		if (glslang_shader_parse(_shader, &input) == 0)
		{
			String infoLog = scope .(glslang_shader_get_info_log(_shader));
			String debugLog = scope .(glslang_shader_get_info_debug_log(_shader));
			WriteError("GLSL Parsing Failed:\n{}\n{}", infoLog, debugLog);
		}

		_program = glslang_program_create();
		glslang_program_add_shader(_program, _shader);



		if (glslang_program_link(_program, (int32)input.messages) == 0)
		{
			String infoLog = scope .(glslang_program_get_info_log(_program));
			String debugLog = scope .(glslang_program_get_info_debug_log(_program));
			WriteError("GLSL Linking Failed:\n{}\n{}", infoLog, debugLog);
		}

		_output.Clear();

		glslang_spv_options_t spvOptions = .()
			{
			};

		spvOptions.disable_optimizer = false; // Do not disable optimizer in debug mode. It will cause the shader to fail to compile.
		spvOptions.optimize_size = true;
#if DEBUG 
		// spvOptions.validate = true;
#else
		spvOptions.stripDebugInfo = true;
#endif
		glslang_program_SPIRV_generate_with_options(_program, input.stage, &spvOptions);
		//glslang_program_SPIRV_generate(_program, stage);
		int size = glslang_program_SPIRV_get_size(_program);
		_output.Resize(size);
		glslang_program_SPIRV_get(_program, _output.Ptr);
	}
	public void compressInputLocations(ref VertexAttributeList attributes)
	{
		List<Id> ids = scope .();
		List<uint32> activeLocations = scope .();
		List<uint32> newLocations = scope .();

		uint32* code = _output.Ptr;
		uint32 codeSize = (uint32)_output.Count;

		Runtime.Assert(code[0] == SpvMagicNumber);

		uint32 idBound = code[3];
		ids.Resize(idBound, .());

		uint32* insn = code + 5;
		while (insn != code + codeSize)
		{
			var opcode = (uint16)insn[0];
			var wordCount = (uint16)(insn[0] >> 16);

			switch ((SpvOp)opcode) {
			case .SpvOpDecorate:
				{
					Runtime.Assert(wordCount >= 3);

					uint32 id = insn[1];
					Runtime.Assert(id < idBound);

					switch ((SpvDecoration)insn[2]) {
					case .SpvDecorationLocation:
						Runtime.Assert(wordCount == 4);
						ids[id].pLocation = &insn[3];
						break;

					default: break;
					}
				} break;
			case .SpvOpVariable:
				{
					Runtime.Assert(wordCount >= 4);

					uint32 id = insn[2];
					Runtime.Assert(id < idBound);

					Runtime.Assert(ids[id].opcode == 0);
					ids[id].opcode = opcode;
					ids[id].typeId = insn[1];
					ids[id].storageClass = insn[3];
				} break;

			default: break;
			}

			Runtime.Assert(insn + wordCount <= code + codeSize);
			insn += wordCount;
		}
		

		//_program.buildReflection();
		activeLocations.Clear();
		uint32 activeCount = 0;
		{
			const bool g_fail_on_error = true;
			void error_callback(void* userdata, char8* error)
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

			spvc_context context = .Null;
			Runtime.Assert(spvc_context_create(&context) == 0);
			defer spvc_context_destroy(context);

			function void(void* userdata, char8* error) errorCb = => error_callback;
			spvc_error_callback cb = .((int)(void*)errorCb);

			spvc_context_set_error_callback(context, cb, null);

			spvc_compiler compiler = .Null;
			spvc_parsed_ir ir = .Null;
			spvc_compiler_options options = .Null;

			SpvId* buffer = (SpvId*)_output.Ptr;
			uint64 word_count = uint64(_output.Count /*/ sizeof(SpvId)*/);
			Runtime.Assert(spvc_context_parse_spirv(context, buffer, word_count, &ir) == 0);

			Runtime.Assert(spvc_context_create_compiler(context, .Glsl, ir, .Copy, &compiler) == 0);

			Runtime.Assert(spvc_compiler_create_compiler_options(compiler, &options) == 0);

			Runtime.Assert(spvc_compiler_install_compiler_options(compiler, options) == 0);

			char8* source = null;
			Runtime.Assert(spvc_compiler_compile(compiler, (.)&source) == 0);

			{
				spvc_resources resources = .Null;

				Runtime.Assert(spvc_compiler_create_shader_resources(compiler, &resources) == 0);

				delegate void(spvc_resources resources, spvc_resource_type type, ref uint32 numPipeInput) enumerate_resources = scope [&] (@resources, type, numPipeInput) =>
				{
					spvc_reflected_resource* list = null;
					uint count = 0;
					Runtime.Assert(spvc_resources_get_resource_list_for_type(@resources, type, (.)&list, &count) == 0);
					if(type == .StageInput)
					{
						numPipeInput = (uint32)count;
					}
					/*for (uint i = 0; i < count; i++)
					{
						//spvc_reflected_resource resource = list[i];
						// todo
					}*/
				};

				//enumerate_resources(resources, .UniformBuffer);
				//enumerate_resources(resources, .StorageBuffer);
				enumerate_resources(resources, .StageInput, ref activeCount);
				//enumerate_resources(resources, .StageOutput);
				//enumerate_resources(resources, .SubpassInput);
				//enumerate_resources(resources, .StorageImage);
				//enumerate_resources(resources, .SampledImage);
				//enumerate_resources(resources, .AtomicCounter);
				//enumerate_resources(resources, .PushConstant);
				//enumerate_resources(resources, .SeparateImage);
				//enumerate_resources(resources, .SeparateSamplers);
				//enumerate_resources(resources, .AccelerationStructure);
				//enumerate_resources(resources, .RayQuery);
				//enumerate_resources(resources, .ShaderRecordBuffer);

				
				for (int i = 0; i < activeCount; ++i)
				{
					spvc_reflected_resource* list = null;
					uint count = 0;
					Runtime.Assert(spvc_resources_get_resource_list_for_type(resources, .StageInput, (.)&list, &count) == 0);

					spvc_reflected_resource resource = list[i];
					uint32 location = spvc_compiler_get_decoration(compiler, resource.id, .SpvDecorationLocation);

					activeLocations.Add(location);
				}
			}
		}

		/*activeLocations.Clear();
		uint32 activeCount = _program.getNumPipeInputs();
		for (int i = 0; i < activeCount; ++i)
		{
			activeLocations.Add(_program.getPipeInput(i).getType().getQualifier().layoutLocation);
		}*/

		uint32 location = 0;
		uint32 unusedLocation = activeCount;
		newLocations.Resize(attributes.Count, uint32.MaxValue);

		for (var id in ref ids)
		{
			if (id.opcode == (uint16)SpvOp.SpvOpVariable && id.storageClass == (uint32)SpvStorageClass.SpvStorageClassInput && id.pLocation != null)
			{
				uint32 oldLocation = *id.pLocation;

				// update locations in SPIRV
				if (activeLocations.Contains(*id.pLocation))
				{
					*id.pLocation = location++;
				} else
				{
					*id.pLocation = unusedLocation++;
				}

				// save record
				bool found = false;
				for (int i = 0; i < attributes.Count; ++i)
				{
					if (attributes[i].location == oldLocation)
					{
						newLocations[i] = *id.pLocation;
						found = true;
						break;
					}
				}

				// Missing attribute declarations?
				Runtime.Assert(found);
			}
		}

		// update gfx references
		for (int i = 0; i < attributes.Count; ++i)
		{
			attributes[i].location = newLocations[i];
		}
		attributes.RemoveAll(scope (item) =>
			{
				return item.location == uint32.MaxValue;
			});
	}

	[Inline] public uint32* getOutputData()
	{
		glslang_shader_delete(_shader);
		_shader = null;
		glslang_program_delete(_program);
		_program = null;
		return _output.Ptr;
	}

	[Inline] public uint32 getOutputSize()
	{
		return (uint32)_output.Count * sizeof(uint32);
	}

	private int32 _clientInputSemanticsVersion = 0;
	private glslang_target_client_version_t _clientVersion = glslang_target_client_version_t.GLSLANG_TARGET_VULKAN_1_0;
	private glslang_target_language_version_t _targetVersion = glslang_target_language_version_t.GLSLANG_TARGET_SPV_1_0;

	private glslang_shader_t* _shader = null;
	private glslang_program_t* _program = null;
	private List<uint32> _output = new .() ~ delete _;

	private static SPIRVUtils instance;
}