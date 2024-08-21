using System;
namespace glslang_Beef
{
	/* EShLanguage counterpart */
	[CRepr]
	enum glslang_stage_t
	{
		GLSLANG_STAGE_VERTEX,
		GLSLANG_STAGE_TESSCONTROL,
		GLSLANG_STAGE_TESSEVALUATION,
		GLSLANG_STAGE_GEOMETRY,
		GLSLANG_STAGE_FRAGMENT,
		GLSLANG_STAGE_COMPUTE,
		GLSLANG_STAGE_RAYGEN_NV,
		GLSLANG_STAGE_INTERSECT_NV,
		GLSLANG_STAGE_ANYHIT_NV,
		GLSLANG_STAGE_CLOSESTHIT_NV,
		GLSLANG_STAGE_MISS_NV,
		GLSLANG_STAGE_CALLABLE_NV,
		GLSLANG_STAGE_TASK_NV,
		GLSLANG_STAGE_MESH_NV,
		GLSLANG_STAGE_COUNT,
	} // would be better as stage, but this is ancient now

	/* EShLanguageMask counterpart */
	[CRepr]
	enum glslang_stage_mask_t
	{
		GLSLANG_STAGE_VERTEX_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_VERTEX),
		GLSLANG_STAGE_TESSCONTROL_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_TESSCONTROL),
		GLSLANG_STAGE_TESSEVALUATION_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_TESSEVALUATION),
		GLSLANG_STAGE_GEOMETRY_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_GEOMETRY),
		GLSLANG_STAGE_FRAGMENT_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_FRAGMENT),
		GLSLANG_STAGE_COMPUTE_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_COMPUTE),
		GLSLANG_STAGE_RAYGEN_NV_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_RAYGEN_NV),
		GLSLANG_STAGE_INTERSECT_NV_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_INTERSECT_NV),
		GLSLANG_STAGE_ANYHIT_NV_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_ANYHIT_NV),
		GLSLANG_STAGE_CLOSESTHIT_NV_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_CLOSESTHIT_NV),
		GLSLANG_STAGE_MISS_NV_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_MISS_NV),
		GLSLANG_STAGE_CALLABLE_NV_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_CALLABLE_NV),
		GLSLANG_STAGE_TASK_NV_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_TASK_NV),
		GLSLANG_STAGE_MESH_NV_MASK = (1 << (int32)glslang_stage_t.GLSLANG_STAGE_MESH_NV),
		GLSLANG_STAGE_MASK_COUNT,
	}

	/* EShSource counterpart */
	[CRepr]
	enum glslang_source_t
	{
		GLSLANG_SOURCE_NONE,
		GLSLANG_SOURCE_GLSL,
		GLSLANG_SOURCE_HLSL,
		GLSLANG_SOURCE_COUNT,
	}

	/* EShClient counterpart */
	[CRepr]
	enum glslang_client_t
	{
		GLSLANG_CLIENT_NONE,
		GLSLANG_CLIENT_VULKAN,
		GLSLANG_CLIENT_OPENGL,
		GLSLANG_CLIENT_COUNT,
	}

	/* EShTargetLanguage counterpart */
	[CRepr]
	enum glslang_target_language_t
	{
		GLSLANG_TARGET_NONE,
		GLSLANG_TARGET_SPV,
		GLSLANG_TARGET_COUNT,
	}

	/* SH_TARGET_ClientVersion counterpart */
	[CRepr]
	enum glslang_target_client_version_t
	{
		GLSLANG_TARGET_VULKAN_1_0 = (1 << 22),
		GLSLANG_TARGET_VULKAN_1_1 = (1 << 22) | (1 << 12),
		GLSLANG_TARGET_VULKAN_1_2 = (1 << 22) | (2 << 12),
		GLSLANG_TARGET_VULKAN_1_3 = (1 << 22) | (3 << 12),
		GLSLANG_TARGET_OPENGL_450 = 450,
		GLSLANG_TARGET_CLIENT_VERSION_COUNT = 5,
	}

	/* SH_TARGET_LanguageVersion counterpart */
	[CRepr]
	enum glslang_target_language_version_t
	{
		GLSLANG_TARGET_SPV_1_0 = (1 << 16),
		GLSLANG_TARGET_SPV_1_1 = (1 << 16) | (1 << 8),
		GLSLANG_TARGET_SPV_1_2 = (1 << 16) | (2 << 8),
		GLSLANG_TARGET_SPV_1_3 = (1 << 16) | (3 << 8),
		GLSLANG_TARGET_SPV_1_4 = (1 << 16) | (4 << 8),
		GLSLANG_TARGET_SPV_1_5 = (1 << 16) | (5 << 8),
		GLSLANG_TARGET_SPV_1_6 = (1 << 16) | (6 << 8),
		GLSLANG_TARGET_LANGUAGE_VERSION_COUNT = 7,
	}

	/* EShExecutable counterpart */
	[CRepr]
	enum glslang_executable_t
	{
		GLSLANG_EX_VERTEX_FRAGMENT, GLSLANG_EX_FRAGMENT }

	// EShOptimizationLevel counterpart
	// This enum is not used in the current C interface, but could be added at a later date.
	// GLSLANG_OPT_NONE is the current default.
	[CRepr]
	enum glslang_optimization_level_t
	{
		GLSLANG_OPT_NO_GENERATION,
		GLSLANG_OPT_NONE,
		GLSLANG_OPT_SIMPLE,
		GLSLANG_OPT_FULL,
		GLSLANG_OPT_LEVEL_COUNT,
	}

	/* EShTextureSamplerTransformMode counterpart */
	[CRepr]
	enum glslang_texture_sampler_transform_mode_t
	{
		GLSLANG_TEX_SAMP_TRANS_KEEP,
		GLSLANG_TEX_SAMP_TRANS_UPGRADE_TEXTURE_REMOVE_SAMPLER,
		GLSLANG_TEX_SAMP_TRANS_COUNT,
	}

	/* EShMessages counterpart */
	[CRepr]
	enum glslang_messages_t
	{
		GLSLANG_MSG_DEFAULT_BIT = 0,
		GLSLANG_MSG_RELAXED_ERRORS_BIT = (1 << 0),
		GLSLANG_MSG_SUPPRESS_WARNINGS_BIT = (1 << 1),
		GLSLANG_MSG_AST_BIT = (1 << 2),
		GLSLANG_MSG_SPV_RULES_BIT = (1 << 3),
		GLSLANG_MSG_VULKAN_RULES_BIT = (1 << 4),
		GLSLANG_MSG_ONLY_PREPROCESSOR_BIT = (1 << 5),
		GLSLANG_MSG_READ_HLSL_BIT = (1 << 6),
		GLSLANG_MSG_CASCADING_ERRORS_BIT = (1 << 7),
		GLSLANG_MSG_KEEP_UNCALLED_BIT = (1 << 8),
		GLSLANG_MSG_HLSL_OFFSETS_BIT = (1 << 9),
		GLSLANG_MSG_DEBUG_INFO_BIT = (1 << 10),
		GLSLANG_MSG_HLSL_ENABLE_16BIT_TYPES_BIT = (1 << 11),
		GLSLANG_MSG_HLSL_LEGALIZATION_BIT = (1 << 12),
		GLSLANG_MSG_HLSL_DX9_COMPATIBLE_BIT = (1 << 13),
		GLSLANG_MSG_BUILTIN_SYMBOL_TABLE_BIT = (1 << 14),
		GLSLANG_MSG_ENHANCED = (1 << 15),
		GLSLANG_MSG_COUNT,
	}

	/* EShReflectionOptions counterpart */
	[CRepr]
	enum glslang_reflection_options_t
	{
		GLSLANG_REFLECTION_DEFAULT_BIT = 0,
		GLSLANG_REFLECTION_STRICT_ARRAY_SUFFIX_BIT = (1 << 0),
		GLSLANG_REFLECTION_BASIC_ARRAY_SUFFIX_BIT = (1 << 1),
		GLSLANG_REFLECTION_INTERMEDIATE_IOO_BIT = (1 << 2),
		GLSLANG_REFLECTION_SEPARATE_BUFFERS_BIT = (1 << 3),
		GLSLANG_REFLECTION_ALL_BLOCK_VARIABLES_BIT = (1 << 4),
		GLSLANG_REFLECTION_UNWRAP_IO_BLOCKS_BIT = (1 << 5),
		GLSLANG_REFLECTION_ALL_IO_VARIABLES_BIT = (1 << 6),
		GLSLANG_REFLECTION_SHARED_STD140_SSBO_BIT = (1 << 7),
		GLSLANG_REFLECTION_SHARED_STD140_UBO_BIT = (1 << 8),
		GLSLANG_REFLECTION_COUNT,
	}

	/* EProfile counterpart (from Versions.h) */
	[CRepr]
	enum glslang_profile_t
	{
		GLSLANG_BAD_PROFILE = 0,
		GLSLANG_NO_PROFILE = (1 << 0),
		GLSLANG_CORE_PROFILE = (1 << 1),
		GLSLANG_COMPATIBILITY_PROFILE = (1 << 2),
		GLSLANG_ES_PROFILE = (1 << 3),
		GLSLANG_PROFILE_COUNT,
	}

	/* Shader options */
	[CRepr]
	enum glslang_shader_options_t
	{
		GLSLANG_SHADER_DEFAULT_BIT = 0,
		GLSLANG_SHADER_AUTO_MAP_BINDINGS = (1 << 0),
		GLSLANG_SHADER_AUTO_MAP_LOCATIONS = (1 << 1),
		GLSLANG_SHADER_VULKAN_RULES_RELAXED = (1 << 2),
		GLSLANG_SHADER_COUNT,
	}

	/* TResourceType counterpart */
	[CRepr]
	enum glslang_resource_type_t
	{
		GLSLANG_RESOURCE_TYPE_SAMPLER,
		GLSLANG_RESOURCE_TYPE_TEXTURE,
		GLSLANG_RESOURCE_TYPE_IMAGE,
		GLSLANG_RESOURCE_TYPE_UBO,
		GLSLANG_RESOURCE_TYPE_SSBO,
		GLSLANG_RESOURCE_TYPE_UAV,
		GLSLANG_RESOURCE_TYPE_COUNT,
	}

	[CRepr]
	typealias glslang_shader_t = void;

	[CRepr]
	typealias glslang_program_t = void;

	/* TLimits counterpart */
	[CRepr]
	struct glslang_limits_t
	{
		public bool non_inductive_for_loops;
		public bool while_loops;
		public bool do_while_loops;
		public bool general_uniform_indexing;
		public bool general_attribute_matrix_vector_indexing;
		public bool general_varying_indexing;
		public bool general_sampler_indexing;
		public bool general_variable_indexing;
		public bool general_constant_matrix_vector_indexing;
	}

	/* TBuiltInResource counterpart */
	struct glslang_resource_t
	{
		public int32 max_lights;
		public int32 max_clip_planes;
		public int32 max_texture_units;
		public int32 max_texture_coords;
		public int32 max_vertex_attribs;
		public int32 max_vertex_uniform_components;
		public int32 max_varying_floats;
		public int32 max_vertex_texture_image_units;
		public int32 max_combined_texture_image_units;
		public int32 max_texture_image_units;
		public int32 max_fragment_uniform_components;
		public int32 max_draw_buffers;
		public int32 max_vertex_uniform_vectors;
		public int32 max_varying_vectors;
		public int32 max_fragment_uniform_vectors;
		public int32 max_vertex_output_vectors;
		public int32 max_fragment_input_vectors;
		public int32 min_program_texel_offset;
		public int32 max_program_texel_offset;
		public int32 max_clip_distances;
		public int32 max_compute_work_group_count_x;
		public int32 max_compute_work_group_count_y;
		public int32 max_compute_work_group_count_z;
		public int32 max_compute_work_group_size_x;
		public int32 max_compute_work_group_size_y;
		public int32 max_compute_work_group_size_z;
		public int32 max_compute_uniform_components;
		public int32 max_compute_texture_image_units;
		public int32 max_compute_image_uniforms;
		public int32 max_compute_atomic_counters;
		public int32 max_compute_atomic_counter_buffers;
		public int32 max_varying_components;
		public int32 max_vertex_output_components;
		public int32 max_geometry_input_components;
		public int32 max_geometry_output_components;
		public int32 max_fragment_input_components;
		public int32 max_image_units;
		public int32 max_combined_image_units_and_fragment_outputs;
		public int32 max_combined_shader_output_resources;
		public int32 max_image_samples;
		public int32 max_vertex_image_uniforms;
		public int32 max_tess_control_image_uniforms;
		public int32 max_tess_evaluation_image_uniforms;
		public int32 max_geometry_image_uniforms;
		public int32 max_fragment_image_uniforms;
		public int32 max_combined_image_uniforms;
		public int32 max_geometry_texture_image_units;
		public int32 max_geometry_output_vertices;
		public int32 max_geometry_total_output_components;
		public int32 max_geometry_uniform_components;
		public int32 max_geometry_varying_components;
		public int32 max_tess_control_input_components;
		public int32 max_tess_control_output_components;
		public int32 max_tess_control_texture_image_units;
		public int32 max_tess_control_uniform_components;
		public int32 max_tess_control_total_output_components;
		public int32 max_tess_evaluation_input_components;
		public int32 max_tess_evaluation_output_components;
		public int32 max_tess_evaluation_texture_image_units;
		public int32 max_tess_evaluation_uniform_components;
		public int32 max_tess_patch_components;
		public int32 max_patch_vertices;
		public int32 max_tess_gen_level;
		public int32 max_viewports;
		public int32 max_vertex_atomic_counters;
		public int32 max_tess_control_atomic_counters;
		public int32 max_tess_evaluation_atomic_counters;
		public int32 max_geometry_atomic_counters;
		public int32 max_fragment_atomic_counters;
		public int32 max_combined_atomic_counters;
		public int32 max_atomic_counter_bindings;
		public int32 max_vertex_atomic_counter_buffers;
		public int32 max_tess_control_atomic_counter_buffers;
		public int32 max_tess_evaluation_atomic_counter_buffers;
		public int32 max_geometry_atomic_counter_buffers;
		public int32 max_fragment_atomic_counter_buffers;
		public int32 max_combined_atomic_counter_buffers;
		public int32 max_atomic_counter_buffer_size;
		public int32 max_transform_feedback_buffers;
		public int32 max_transform_feedback_interleaved_components;
		public int32 max_cull_distances;
		public int32 max_combined_clip_and_cull_distances;
		public int32 max_samples;
		public int32 max_mesh_output_vertices_nv;
		public int32 max_mesh_output_primitives_nv;
		public int32 max_mesh_work_group_size_x_nv;
		public int32 max_mesh_work_group_size_y_nv;
		public int32 max_mesh_work_group_size_z_nv;
		public int32 max_task_work_group_size_x_nv;
		public int32 max_task_work_group_size_y_nv;
		public int32 max_task_work_group_size_z_nv;
		public int32 max_mesh_view_count_nv;
		public int32 maxDualSourceDrawBuffersEXT;

		public glslang_limits_t limits;

		public static glslang_resource_t GetDefaultBuiltinResources()
		{
			return .()
				{
					max_lights = 32,
					max_clip_planes = 6,
					max_texture_units = 32,
					max_texture_coords = 32,
					max_vertex_attribs = 64,
					max_vertex_uniform_components = 4096,
					max_varying_floats = 64,
					max_vertex_texture_image_units = 32,
					max_combined_texture_image_units = 80,
					max_texture_image_units = 32,
					max_fragment_uniform_components = 4096,
					max_draw_buffers = 32,
					max_vertex_uniform_vectors = 128,
					max_varying_vectors = 8,
					max_fragment_uniform_vectors = 16,
					max_vertex_output_vectors = 16,
					max_fragment_input_vectors = 15,
					min_program_texel_offset = 8,
					max_program_texel_offset = 7,
					max_clip_distances = 8,
					max_compute_work_group_count_x = 65535,
					max_compute_work_group_count_y = 65535,
					max_compute_work_group_count_z = 65535,
					max_compute_work_group_size_x = 1024,
					max_compute_work_group_size_y = 1024,
					max_compute_work_group_size_z = 64,
					max_compute_uniform_components = 1024,
					max_compute_texture_image_units = 16,
					max_compute_image_uniforms = 8,
					max_compute_atomic_counters = 8,
					max_compute_atomic_counter_buffers = 1,
					max_varying_components = 60,
					max_vertex_output_components = 64,
					max_geometry_input_components = 64,
					max_geometry_output_components = 128,
					max_fragment_input_components = 128,
					max_image_units = 8,
					max_combined_image_units_and_fragment_outputs = 8,
					max_combined_shader_output_resources = 8,
					max_image_samples = 0,
					max_vertex_image_uniforms = 0,
					max_tess_control_image_uniforms = 0,
					max_tess_evaluation_image_uniforms = 0,
					max_geometry_image_uniforms = 0,
					max_fragment_image_uniforms = 8,
					max_combined_image_uniforms = 8,
					max_geometry_texture_image_units = 16,
					max_geometry_output_vertices = 256,
					max_geometry_total_output_components = 1024,
					max_geometry_uniform_components = 1024,
					max_geometry_varying_components = 64,
					max_tess_control_input_components = 128,
					max_tess_control_output_components = 128,
					max_tess_control_texture_image_units = 16,
					max_tess_control_uniform_components = 1024,
					max_tess_control_total_output_components = 4096,
					max_tess_evaluation_input_components = 128,
					max_tess_evaluation_output_components = 128,
					max_tess_evaluation_texture_image_units = 16,
					max_tess_evaluation_uniform_components = 1024,
					max_tess_patch_components = 120,
					max_patch_vertices = 32,
					max_tess_gen_level = 64,
					max_viewports = 16,
					max_vertex_atomic_counters = 0,
					max_tess_control_atomic_counters = 0,
					max_tess_evaluation_atomic_counters = 0,
					max_geometry_atomic_counters = 0,
					max_fragment_atomic_counters = 8,
					max_combined_atomic_counters = 8,
					max_atomic_counter_bindings = 1,
					max_vertex_atomic_counter_buffers = 0,
					max_tess_control_atomic_counter_buffers = 0,
					max_tess_evaluation_atomic_counter_buffers = 0,
					max_geometry_atomic_counter_buffers = 0,
					max_fragment_atomic_counter_buffers = 1,
					max_combined_atomic_counter_buffers = 1,
					max_atomic_counter_buffer_size = 16384,
					max_transform_feedback_buffers = 4,
					max_transform_feedback_interleaved_components = 64,
					max_cull_distances = 8,
					max_combined_clip_and_cull_distances = 8,
					max_samples = 4,
					max_mesh_output_vertices_nv = 256,
					max_mesh_output_primitives_nv = 512,
					max_mesh_work_group_size_x_nv = 32,
					max_mesh_work_group_size_y_nv = 1,
					max_mesh_work_group_size_z_nv = 1,
					max_task_work_group_size_x_nv = 32,
					max_task_work_group_size_y_nv = 1,
					max_task_work_group_size_z_nv = 1,
					max_mesh_view_count_nv = 4,
					maxDualSourceDrawBuffersEXT =  1,

					limits =  .()
						{
							non_inductive_for_loops = true,
							while_loops = true,
							do_while_loops = true,
							general_uniform_indexing = true,
							general_attribute_matrix_vector_indexing = true,
							general_varying_indexing = true,
							general_sampler_indexing = true,
							general_variable_indexing = true,
							general_constant_matrix_vector_indexing = true
						}
				};
		}
	}

	[CRepr]
	struct glslang_input_t
	{
		public glslang_source_t language;
		public glslang_stage_t stage;
		public glslang_client_t client;
		public glslang_target_client_version_t client_version;
		public glslang_target_language_t target_language;
		public glslang_target_language_version_t target_language_version;
		/** Shader source code */
		public char8* code;
		public int32 default_version;
		public glslang_profile_t default_profile;
		public int32 force_default_version_and_profile;
		public int32 forward_compatible;
		public glslang_messages_t messages;
		public glslang_resource_t* resource;
	}

	/* Inclusion result structure allocated by C include_local/include_system callbacks */
	[CRepr]
	struct glsl_include_result_t
	{
		/* Header file name or NULL if inclusion failed */
		public char8* header_name;

		/* Header contents or NULL */
		public char8* header_data;
		public int header_length;
	}

	/* Callback for local file inclusion */
	typealias glsl_include_local_func = function glsl_include_result_t*(void* ctx, char8* header_name,
		char8* includer_name, int include_depth);

	/* Callback for system file inclusion */
	typealias glsl_include_system_func = function glsl_include_result_t*(void* ctx, char8* header_name,
		char8* includer_name, int include_depth);

	/* Callback for include result destruction */
	typealias glsl_free_include_result_func = function int32(void* ctx, glsl_include_result_t* result);

	/* Collection of callbacks for GLSL preprocessor */
	[CRepr]
	struct glsl_include_callbacks_t
	{
		public glsl_include_system_func include_system;
		public glsl_include_local_func include_local;
		public glsl_free_include_result_func free_include_result;
	}

	/* SpvOptions counterpart */
	[CRepr]
	struct glslang_spv_options_t
	{
		public bool generate_debug_info;
		public bool strip_debug_info;
		public bool disable_optimizer;
		public bool optimize_size;
		public bool disassemble;
		public bool validate;
	}

	public static
	{
		[CallingConvention(.Stdcall), CLink] public static extern int32 glslang_initialize_process();
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_finalize_process();
		
		[CallingConvention(.Stdcall), CLink] public static extern glslang_resource_t* glslang_default_resource();
		[CallingConvention(.Stdcall), CLink] public static extern char8* glslang_default_resource_string();
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_decode_resource_limits(glslang_resource_t* resources, char8* config);

		[CallingConvention(.Stdcall), CLink] public static extern glslang_shader_t* glslang_shader_create(glslang_input_t* input);
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_shader_delete(glslang_shader_t* shader);
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_shader_shift_binding(glslang_shader_t* shader, glslang_resource_type_t res, uint32 @base);
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_shader_shift_binding_for_set(glslang_shader_t* shader, glslang_resource_type_t res, uint32 @base, uint32 set);
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_shader_set_options(glslang_shader_t* shader, int32 options); // glslang_shader_options_t
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_shader_set_glsl_version(glslang_shader_t* shader, int32 version);
		[CallingConvention(.Stdcall), CLink] public static extern int32 glslang_shader_preprocess(glslang_shader_t* shader, glslang_input_t* input);
		[CallingConvention(.Stdcall), CLink] public static extern int32 glslang_shader_parse(glslang_shader_t* shader, glslang_input_t* input);
		[CallingConvention(.Stdcall), CLink] public static extern char8* glslang_shader_get_preprocessed_code(glslang_shader_t* shader);
		[CallingConvention(.Stdcall), CLink] public static extern char8* glslang_shader_get_info_log(glslang_shader_t* shader);
		[CallingConvention(.Stdcall), CLink] public static extern char8* glslang_shader_get_info_debug_log(glslang_shader_t* shader);

		[CallingConvention(.Stdcall), CLink] public static extern glslang_program_t* glslang_program_create();
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_program_delete(glslang_program_t* program);
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_program_add_shader(glslang_program_t* program, glslang_shader_t* shader);
		[CallingConvention(.Stdcall), CLink] public static extern int32 glslang_program_link(glslang_program_t* program, int32 messages); // glslang_messages_t
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_program_add_source_text(glslang_program_t* program, glslang_stage_t stage, char8* text, int len);
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_program_set_source_file(glslang_program_t* program, glslang_stage_t stage, char8* file);
		[CallingConvention(.Stdcall), CLink] public static extern int32 glslang_program_map_io(glslang_program_t* program);
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_program_SPIRV_generate(glslang_program_t* program, glslang_stage_t stage);
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_program_SPIRV_generate_with_options(glslang_program_t* program, glslang_stage_t stage, glslang_spv_options_t* spv_options);
		[CallingConvention(.Stdcall), CLink] public static extern int glslang_program_SPIRV_get_size(glslang_program_t* program);
		[CallingConvention(.Stdcall), CLink] public static extern void glslang_program_SPIRV_get(glslang_program_t* program, uint32* @out);
		[CallingConvention(.Stdcall), CLink] public static extern uint32* glslang_program_SPIRV_get_ptr(glslang_program_t* program);
		[CallingConvention(.Stdcall), CLink] public static extern char8* glslang_program_SPIRV_get_messages(glslang_program_t* program);
		[CallingConvention(.Stdcall), CLink] public static extern char8* glslang_program_get_info_log(glslang_program_t* program);
		[CallingConvention(.Stdcall), CLink] public static extern char8* glslang_program_get_info_debug_log(glslang_program_t* program);
	}
}