using System.Collections;
using System;
/****************************************************************************
 Copyright (c) 2019-2023 Xiamen Yaji Software Co., Ltd.

 http://www.cocos.com

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
****************************************************************************/


//#define CC_USE_PIPELINE_CACHE 0

/**
 * Some general guide lines:
 * Always use explicit numeric types rather than `int`, `long`, etc. for a stable memory layout
 * Structs marked with ALIGNAS specifiers MUST guarantee not to be implicitly padded
 *
 * This file should be synced with cocos/core/gfx/base/define.ts
 * every time changes being made, by manually running:
 * node native/tools/gfx-define-generator/generate.js
 *
 * Due to Clang AST's incompleteness for now we are parsing this header manually.
 * Some caveat:
 * * native-specific structs should not be included here, put them in GFXDef.h instead
 * * no typedefs, only usings
 * * define struct members first, then other helper functions
 * * aliases can only be used as types, not values (e.g. BufferUsage.NONE is illegal)
 * * parser directives can be specified in comments right after struct member declarations:
 *   * @ts-nullable: declare the member optional
 *   * @ts-boolean: declare the member as boolean, even if the type is not `bool`
 *   * @ts-overrides `YAML declaration`: overrides any parsed results, use with caution
 * * each struct member have to be specified in a single line, including optional parser directives
 * * members with a name starts with an underscore is automatically ignored
 */

typealias HashType = int;

namespace cc {
	namespace gfx {
		typealias BufferBarrierList = List<BufferBarrier>;
		typealias TextureBarrierList = List<TextureBarrier>;
		typealias BufferDataList = List<uint8*>;
		typealias BufferSrcList = List<uint8*>;
		typealias CommandBufferList = List<CommandBuffer>;
		typealias QueryPoolList = List<QueryPool*>;
		typealias IndexList = List<uint32>;

static{
		public const uint32 MAX_ATTACHMENTS = 4;
		public const uint32 INVALID_BINDING = ~0;
		public const uint32 SUBPASS_EXTERNAL = ~0;
		public const HashType INVALID_SHADER_HASH = 0xFFFFFFFFU;

		// Although the standard is not limited, some devices do not support up to 65536 queries
		public const uint32 DEFAULT_MAX_QUERY_OBJECTS = 32767;
}
		typealias BufferList = List<Buffer>;
		typealias TextureList = List<Texture>;
		typealias SamplerList = List<Sampler>;
		typealias DescriptorSetLayoutList = List<DescriptorSetLayout>;

static {
		// make sure you have FILLED GRAPHs before enable this!
		public const bool ENABLE_GRAPH_AUTO_BARRIER = false;
}

		/**
		 * @en Graphics object type
		 * @zh 图形API对象的类型
		 */
		enum ObjectType : uint32 {
			UNKNOWN,
			SWAPCHAIN,
			BUFFER,
			TEXTURE,
			RENDER_PASS,
			FRAMEBUFFER,
			SAMPLER,
			SHADER,
			DESCRIPTOR_SET_LAYOUT,
			PIPELINE_LAYOUT,
			PIPELINE_STATE,
			DESCRIPTOR_SET,
			INPUT_ASSEMBLER,
			COMMAND_BUFFER,
			QUEUE,
			QUERY_POOL,
			GLOBAL_BARRIER,
			TEXTURE_BARRIER,
			BUFFER_BARRIER,
			COUNT,
		}
		// CC_ENUM_CONVERSION_OPERATOR(ObjectType);

		enum Status : uint32 {
			UNREADY,
			FAILED,
			SUCCESS,
		}
		// CC_ENUM_CONVERSION_OPERATOR(Status);

		enum API : uint32 {
			UNKNOWN,
			GLES2,
			GLES3,
			METAL,
			VULKAN,
			NVN,
			WEBGL,
			WEBGL2,
			WEBGPU,
		}
		// CC_ENUM_CONVERSION_OPERATOR(API);

		enum SurfaceTransform : uint32 {
			IDENTITY,
			ROTATE_90,
			ROTATE_180,
			ROTATE_270,
		}
		// CC_ENUM_CONVERSION_OPERATOR(SurfaceTransform);

		enum Feature : uint32 {
			ELEMENT_INDEX_UINT,
			INSTANCED_ARRAYS,
			MULTIPLE_RENDER_TARGETS,
			BLEND_MINMAX,
			COMPUTE_SHADER,

			INPUT_ATTACHMENT_BENEFIT, // @deprecated
			SUBPASS_COLOR_INPUT,
			SUBPASS_DEPTH_STENCIL_INPUT,
			RASTERIZATION_ORDER_NOCOHERENT,

			MULTI_SAMPLE_RESOLVE_DEPTH_STENCIL,   // resolve depth stencil
			COUNT,
		}
		// CC_ENUM_CONVERSION_OPERATOR(Feature);

		enum Format : uint32 {

			UNKNOWN,

			A8,
			L8,
			LA8,

			R8,
			R8SN,
			R8UI,
			R8I,
			R16F,
			R16UI,
			R16I,
			R32F,
			R32UI,
			R32I,

			RG8,
			RG8SN,
			RG8UI,
			RG8I,
			RG16F,
			RG16UI,
			RG16I,
			RG32F,
			RG32UI,
			RG32I,

			RGB8,
			SRGB8,
			RGB8SN,
			RGB8UI,
			RGB8I,
			RGB16F,
			RGB16UI,
			RGB16I,
			RGB32F,
			RGB32UI,
			RGB32I,

			RGBA8,
			BGRA8,
			SRGB8_A8,
			RGBA8SN,
			RGBA8UI,
			RGBA8I,
			RGBA16F,
			RGBA16UI,
			RGBA16I,
			RGBA32F,
			RGBA32UI,
			RGBA32I,

			// Special Format
			R5G6B5,
			R11G11B10F,
			RGB5A1,
			RGBA4,
			RGB10A2,
			RGB10A2UI,
			RGB9E5,

			// Depth-Stencil Format
			DEPTH,
			DEPTH_STENCIL,

			// Compressed Format

			// Block Compression Format, DDS (DirectDraw Surface)
			// DXT1: 3 channels (5:6:5), 1/8 original size, with 0 or 1 bit of alpha
			BC1,
			BC1_ALPHA,
			BC1_SRGB,
			BC1_SRGB_ALPHA,
			// DXT3: 4 channels (5:6:5), 1/4 original size, with 4 bits of alpha
			BC2,
			BC2_SRGB,
			// DXT5: 4 channels (5:6:5), 1/4 original size, with 8 bits of alpha
			BC3,
			BC3_SRGB,
			// 1 channel (8), 1/4 original size
			BC4,
			BC4_SNORM,
			// 2 channels (8:8), 1/2 original size
			BC5,
			BC5_SNORM,
			// 3 channels (16:16:16), half-floating point, 1/6 original size
			// UF16: unsigned float, 5 exponent bits + 11 mantissa bits
			// SF16: signed float, 1 signed bit + 5 exponent bits + 10 mantissa bits
			BC6H_UF16,
			BC6H_SF16,
			// 4 channels (4~7 bits per channel) with 0 to 8 bits of alpha, 1/3 original size
			BC7,
			BC7_SRGB,

			// Ericsson Texture Compression Format
			ETC_RGB8,
			ETC2_RGB8,
			ETC2_SRGB8,
			ETC2_RGB8_A1,
			ETC2_SRGB8_A1,
			ETC2_RGBA8,
			ETC2_SRGB8_A8,
			EAC_R11,
			EAC_R11SN,
			EAC_RG11,
			EAC_RG11SN,

			// PVRTC (PowerVR)
			PVRTC_RGB2,
			PVRTC_RGBA2,
			PVRTC_RGB4,
			PVRTC_RGBA4,
			PVRTC2_2BPP,
			PVRTC2_4BPP,

			// ASTC (Adaptive Scalable Texture Compression)
			ASTC_RGBA_4X4,
			ASTC_RGBA_5X4,
			ASTC_RGBA_5X5,
			ASTC_RGBA_6X5,
			ASTC_RGBA_6X6,
			ASTC_RGBA_8X5,
			ASTC_RGBA_8X6,
			ASTC_RGBA_8X8,
			ASTC_RGBA_10X5,
			ASTC_RGBA_10X6,
			ASTC_RGBA_10X8,
			ASTC_RGBA_10X10,
			ASTC_RGBA_12X10,
			ASTC_RGBA_12X12,

			// ASTC (Adaptive Scalable Texture Compression) SRGB
			ASTC_SRGBA_4X4,
			ASTC_SRGBA_5X4,
			ASTC_SRGBA_5X5,
			ASTC_SRGBA_6X5,
			ASTC_SRGBA_6X6,
			ASTC_SRGBA_8X5,
			ASTC_SRGBA_8X6,
			ASTC_SRGBA_8X8,
			ASTC_SRGBA_10X5,
			ASTC_SRGBA_10X6,
			ASTC_SRGBA_10X8,
			ASTC_SRGBA_10X10,
			ASTC_SRGBA_12X10,
			ASTC_SRGBA_12X12,

			// Total count
			COUNT,
		}
		// CC_ENUM_CONVERSION_OPERATOR(Format);

		enum FormatType : uint32 {
			NONE,
			UNORM,
			SNORM,
			UINT,
			INT,
			UFLOAT,
			FLOAT,
		}
		// CC_ENUM_CONVERSION_OPERATOR(FormatType);

		enum VariableType : uint32 {
			UNKNOWN,
			BOOL,
			BOOL2,
			BOOL3,
			BOOL4,
			INT,
			INT2,
			INT3,
			INT4,
			UINT,
			UINT2,
			UINT3,
			UINT4,
			FLOAT,
			FLOAT2,
			FLOAT3,
			FLOAT4,
			MAT2,
			MAT2X3,
			MAT2X4,
			MAT3X2,
			MAT3,
			MAT3X4,
			MAT4X2,
			MAT4X3,
			MAT4,
			// combined image samplers
			SAMPLER1D,
			SAMPLER1D_ARRAY,
			SAMPLER2D,
			SAMPLER2D_ARRAY,
			SAMPLER3D,
			SAMPLER_CUBE,
			// sampler
			SAMPLER,
			// sampled textures
			TEXTURE1D,
			TEXTURE1D_ARRAY,
			TEXTURE2D,
			TEXTURE2D_ARRAY,
			TEXTURE3D,
			TEXTURE_CUBE,
			// storage images
			IMAGE1D,
			IMAGE1D_ARRAY,
			IMAGE2D,
			IMAGE2D_ARRAY,
			IMAGE3D,
			IMAGE_CUBE,
			// input attachment
			SUBPASS_INPUT,
			COUNT,
		}
		// CC_ENUM_CONVERSION_OPERATOR(VariableType);

static {
	public static bool isCombinedImageSampler(VariableType type) { return type >= VariableType.SAMPLER1D && type <= VariableType.SAMPLER_CUBE; }
	public static bool isSampledImage(VariableType type) { return type >= VariableType.TEXTURE1D && type <= VariableType.TEXTURE_CUBE; }
	public static bool isStorageImage(VariableType type) { return type >= VariableType.IMAGE1D && type <= VariableType.IMAGE_CUBE; }
}

		enum BufferUsageBit : uint32 {
			NONE = 0,
			TRANSFER_SRC = 0x1,
			TRANSFER_DST = 0x2,
			INDEX = 0x4,
			VERTEX = 0x8,
			UNIFORM = 0x10,
			STORAGE = 0x20,
			INDIRECT = 0x40,
		}
		typealias BufferUsage = BufferUsageBit;
		// CC_ENUM_BITWISE_OPERATORS(BufferUsageBit);

		enum BufferFlagBit : uint32 {
			NONE = 0,
			ENABLE_STAGING_WRITE = 0x01,
		}
		typealias BufferFlags = BufferFlagBit;
		// CC_ENUM_BITWISE_OPERATORS(BufferFlagBit);

		enum MemoryAccessBit : uint32 {
			NONE = 0,
			READ_ONLY = 0x1,
			WRITE_ONLY = 0x2,
			READ_WRITE = READ_ONLY | WRITE_ONLY,
		}
		typealias MemoryAccess = MemoryAccessBit;
		// CC_ENUM_BITWISE_OPERATORS(MemoryAccessBit);

		enum MemoryUsageBit : uint32 {
			NONE = 0,
			DEVICE = 0x1, // for rarely-updated resources, use MemoryUsageBit.DEVICE
			HOST = 0x2,   // for frequently-updated resources, use MemoryUsageBit.DEVICE | MemoryUsageBit.HOST
		}
		typealias MemoryUsage = MemoryUsageBit;
		// CC_ENUM_BITWISE_OPERATORS(MemoryUsageBit);

		enum TextureType : uint32 {
			TEX1D,
			TEX2D,
			TEX3D,
			CUBE,
			TEX1D_ARRAY,
			TEX2D_ARRAY,
		}
		// CC_ENUM_CONVERSION_OPERATOR(TextureType);

		enum TextureUsageBit : uint32 {
			NONE = 0,
			TRANSFER_SRC = 0x1,
			TRANSFER_DST = 0x2,
			SAMPLED = 0x4,
			STORAGE = 0x8,
			COLOR_ATTACHMENT = 0x10,
			DEPTH_STENCIL_ATTACHMENT = 0x20,
			INPUT_ATTACHMENT = 0x40,
			SHADING_RATE = 0x80,
		}
		typealias TextureUsage = TextureUsageBit;
		// CC_ENUM_BITWISE_OPERATORS(TextureUsageBit);

		enum TextureFlagBit : uint32 {
			NONE = 0,
			GEN_MIPMAP = 0x1,           // Generate mipmaps using bilinear filter
			GENERAL_LAYOUT = 0x2,       // @deprecated, For inout framebuffer attachments
			EXTERNAL_OES = 0x4,         // External oes texture
			EXTERNAL_NORMAL = 0x8,      // External normal texture
			LAZILY_ALLOCATED = 0x10,    // Try lazily allocated mode.
			MUTABLE_VIEW_FORMAT = 0x40, // texture view as different format
			MUTABLE_STORAGE = 0x80,     // mutable storage for gl image
		}
		typealias TextureFlags = TextureFlagBit;
		// CC_ENUM_BITWISE_OPERATORS(TextureFlagBit);

		enum FormatFeatureBit : uint32 {
			NONE = 0,
			RENDER_TARGET = 0x1,     // Allow usages as render pass attachments
			SAMPLED_TEXTURE = 0x2,   // Allow sampled reads in shaders
			LINEAR_FILTER = 0x4,     // Allow linear filtering when sampling in shaders or blitting
			STORAGE_TEXTURE = 0x8,   // Allow storage reads & writes in shaders
			VERTEX_ATTRIBUTE = 0x10, // Allow usages as vertex input attributes
			SHADING_RATE = 0x20,     // Allow usages as shading rate
		}
		typealias FormatFeature = FormatFeatureBit;
		// CC_ENUM_BITWISE_OPERATORS(FormatFeatureBit);

		enum SampleCount : uint32 {
			X1 = 0x01,
			X2 = 0x02,
			X4 = 0x04,
			X8 = 0x08,
			X16 = 0x10,
			X32 = 0x20,
			X64 = 0x40
		}
		// CC_ENUM_CONVERSION_OPERATOR(SampleCount);

		enum VsyncMode : uint32 {
			// The application does not synchronizes with the vertical sync.
			// If application renders faster than the display refreshes, frames are wasted and tearing may be observed.
			// FPS is uncapped. Maximum power consumption. If unsupported, "ON" value will be used instead. Minimum latency.
			OFF,
			// The application is always synchronized with the vertical sync. Tearing does not happen.
			// FPS is capped to the display's refresh rate. For fast applications, battery life is improved. Always supported.
			ON,
			// The application synchronizes with the vertical sync, but only if the application rendering speed is greater than refresh rate.
			// Compared to OFF, there is no tearing. Compared to ON, the FPS will be improved for "slower" applications.
			// If unsupported, "ON" value will be used instead. Recommended for most applications. Default if supported.
			RELAXED,
			// The presentation engine will always use the latest fully rendered image.
			// Compared to OFF, no tearing will be observed.
			// Compared to ON, battery power will be worse, especially for faster applications.
			// If unsupported,  "OFF" will be attempted next.
			MAILBOX,
			// The application is capped to using half the vertical sync time.
			// FPS artificially capped to Half the display speed (usually 30fps) to maintain battery.
			// Best possible battery savings. Worst possible performance.
			// Recommended for specific applications where battery saving is critical.
			HALF,
		}
		// CC_ENUM_CONVERSION_OPERATOR(VsyncMode);

		enum Filter : uint32 {
			NONE,
			POINT,
			LINEAR,
			ANISOTROPIC,
		}
		// CC_ENUM_CONVERSION_OPERATOR(Filter);

		enum Address : uint32 {
			WRAP,
			MIRROR,
			CLAMP,
			BORDER,
		}
		// CC_ENUM_CONVERSION_OPERATOR(Address);

		enum ComparisonFunc : uint32 {
			NEVER,
			LESS,
			EQUAL,
			LESS_EQUAL,
			GREATER,
			NOT_EQUAL,
			GREATER_EQUAL,
			ALWAYS,
		}
		// CC_ENUM_CONVERSION_OPERATOR(ComparisonFunc);

		enum StencilOp : uint32 {
			ZERO,
			KEEP,
			REPLACE,
			INCR,
			DECR,
			INVERT,
			INCR_WRAP,
			DECR_WRAP,
		}
		// CC_ENUM_CONVERSION_OPERATOR(StencilOp);

		enum BlendFactor : uint32 {
			ZERO,
			ONE,
			SRC_ALPHA,
			DST_ALPHA,
			ONE_MINUS_SRC_ALPHA,
			ONE_MINUS_DST_ALPHA,
			SRC_COLOR,
			DST_COLOR,
			ONE_MINUS_SRC_COLOR,
			ONE_MINUS_DST_COLOR,
			SRC_ALPHA_SATURATE,
			CONSTANT_COLOR,
			ONE_MINUS_CONSTANT_COLOR,
			CONSTANT_ALPHA,
			ONE_MINUS_CONSTANT_ALPHA,
		}
		// CC_ENUM_CONVERSION_OPERATOR(BlendFactor);

		enum BlendOp : uint32 {
			ADD,
			SUB,
			REV_SUB,
			MIN,
			MAX,
		}
		// CC_ENUM_CONVERSION_OPERATOR(BlendOp);

		enum ColorMask : uint32 {
			NONE = 0x0,
			R = 0x1,
			G = 0x2,
			B = 0x4,
			A = 0x8,
			ALL = R | G | B | A,
		}
		// CC_ENUM_BITWISE_OPERATORS(ColorMask);

		enum ShaderStageFlagBit : uint32 {
			NONE = 0x0,
			VERTEX = 0x1,
			CONTROL = 0x2,
			EVALUATION = 0x4,
			GEOMETRY = 0x8,
			FRAGMENT = 0x10,
			COMPUTE = 0x20,
			ALL = 0x3f,
		}
		typealias ShaderStageFlags = ShaderStageFlagBit;
		// CC_ENUM_BITWISE_OPERATORS(ShaderStageFlagBit);

		enum LoadOp : uint32 {
			LOAD,    // Load the previous content from memory
			CLEAR,   // Clear the content to a fixed value
			DISCARD, // Discard the previous content
		}
		// CC_ENUM_CONVERSION_OPERATOR(LoadOp);

		enum StoreOp : uint32 {
			STORE,   // Store the pending content to memory
			DISCARD, // Discard the pending content
		}
		// CC_ENUM_CONVERSION_OPERATOR(StoreOp);

		enum AccessFlagBit : uint32 {
			NONE = 0,

			// Read accesses
			INDIRECT_BUFFER = 1 << 0,                                     // Read as an indirect buffer for drawing or dispatch
			INDEX_BUFFER = 1 << 1,                                        // Read as an index buffer for drawing
			VERTEX_BUFFER = 1 << 2,                                       // Read as a vertex buffer for drawing
			VERTEX_SHADER_READ_UNIFORM_BUFFER = 1 << 3,                   // Read as a uniform buffer in a vertex shader
			VERTEX_SHADER_READ_TEXTURE = 1 << 4,                          // Read as a sampled image/uniform texel buffer in a vertex shader
			VERTEX_SHADER_READ_OTHER = 1 << 5,                            // Read as any other resource in a vertex shader
			FRAGMENT_SHADER_READ_UNIFORM_BUFFER = 1 << 6,                 // Read as a uniform buffer in a fragment shader
			FRAGMENT_SHADER_READ_TEXTURE = 1 << 7,                        // Read as a sampled image/uniform texel buffer in a fragment shader
			FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT = 1 << 8,         // Read as an input attachment with a color format in a fragment shader
			FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT = 1 << 9, // Read as an input attachment with a depth/stencil format in a fragment shader
			FRAGMENT_SHADER_READ_OTHER = 1 << 10,                         // Read as any other resource in a fragment shader
			COLOR_ATTACHMENT_READ = 1 << 11,                              // Read by standard blending/logic operations or subpass load operations
			DEPTH_STENCIL_ATTACHMENT_READ = 1 << 12,                      // Read by depth/stencil tests or subpass load operations
			COMPUTE_SHADER_READ_UNIFORM_BUFFER = 1 << 13,                 // Read as a uniform buffer in a compute shader
			COMPUTE_SHADER_READ_TEXTURE = 1 << 14,                        // Read as a sampled image/uniform texel buffer in a compute shader
			COMPUTE_SHADER_READ_OTHER = 1 << 15,                          // Read as any other resource in a compute shader
			TRANSFER_READ = 1 << 16,                                      // Read as the source of a transfer operation
			HOST_READ = 1 << 17,                                          // Read on the host
			PRESENT = 1 << 18,                                            // Read by the presentation engine

			// Write accesses
			VERTEX_SHADER_WRITE = 1 << 19,            // Written as any resource in a vertex shader
			FRAGMENT_SHADER_WRITE = 1 << 20,          // Written as any resource in a fragment shader
			COLOR_ATTACHMENT_WRITE = 1 << 21,         // Written as a color attachment during rendering, or via a subpass store op
			DEPTH_STENCIL_ATTACHMENT_WRITE = 1 << 22, // Written as a depth/stencil attachment during rendering, or via a subpass store op
			COMPUTE_SHADER_WRITE = 1 << 23,           // Written as any resource in a compute shader
			TRANSFER_WRITE = 1 << 24,                 // Written as the destination of a transfer operation
			HOST_PREINITIALIZED = 1 << 25,            // Data pre-filled by host before device access starts
			HOST_WRITE = 1 << 26,                     // Written on the host

			SHADING_RATE = 1 << 27, // Read as a shading rate image
		}
		// CC_ENUM_BITWISE_OPERATORS(AccessFlagBit);
		typealias AccessFlags = AccessFlagBit;

		enum ResolveMode : uint32 {
			NONE,
			SAMPLE_ZERO,
			AVERAGE,
			MIN,
			MAX,
		}
		// CC_ENUM_CONVERSION_OPERATOR(ResolveMode);

		enum PipelineBindPoint : uint32 {
			GRAPHICS,
			COMPUTE,
			RAY_TRACING,
		}
		// CC_ENUM_CONVERSION_OPERATOR(PipelineBindPoint);

		enum PrimitiveMode : uint32 {
			POINT_LIST,
			LINE_LIST,
			LINE_STRIP,
			LINE_LOOP,
			LINE_LIST_ADJACENCY,
			LINE_STRIP_ADJACENCY,
			ISO_LINE_LIST,
			// raycast detectable:
			TRIANGLE_LIST,
			TRIANGLE_STRIP,
			TRIANGLE_FAN,
			TRIANGLE_LIST_ADJACENCY,
			TRIANGLE_STRIP_ADJACENCY,
			TRIANGLE_PATCH_ADJACENCY,
			QUAD_PATCH_LIST,
		}
		// CC_ENUM_CONVERSION_OPERATOR(PrimitiveMode);

		enum PolygonMode : uint32 {
			FILL,
			POINT,
			LINE,
		}
		// CC_ENUM_CONVERSION_OPERATOR(PolygonMode);

		enum ShadeModel : uint32 {
			GOURAND,
			FLAT,
		}
		// CC_ENUM_CONVERSION_OPERATOR(ShadeModel);

		enum CullMode : uint32 {
			NONE,
			FRONT,
			BACK,
		}
		// CC_ENUM_CONVERSION_OPERATOR(CullMode);

		enum DynamicStateFlagBit : uint32 {
			NONE = 0x0,
			LINE_WIDTH = 0x1,
			DEPTH_BIAS = 0x2,
			BLEND_CONSTANTS = 0x4,
			DEPTH_BOUNDS = 0x8,
			STENCIL_WRITE_MASK = 0x10,
			STENCIL_COMPARE_MASK = 0x20,
		}
		typealias DynamicStateFlags = DynamicStateFlagBit;
		// CC_ENUM_BITWISE_OPERATORS(DynamicStateFlagBit);

		typealias DynamicStateList = List<DynamicStateFlagBit>;

		enum StencilFace : uint32 {
			FRONT = 0x1,
			BACK = 0x2,
			ALL = 0x3,
		}
		// CC_ENUM_BITWISE_OPERATORS(StencilFace);

		enum DescriptorType : uint32 {
			UNKNOWN = 0,
			UNIFORM_BUFFER = 0x1,
			DYNAMIC_UNIFORM_BUFFER = 0x2,
			STORAGE_BUFFER = 0x4,
			DYNAMIC_STORAGE_BUFFER = 0x8,
			SAMPLER_TEXTURE = 0x10,
			SAMPLER = 0x20,
			TEXTURE = 0x40,
			STORAGE_IMAGE = 0x80,
			INPUT_ATTACHMENT = 0x100,
		}
		// CC_ENUM_BITWISE_OPERATORS(DescriptorType);

		enum QueueType : uint32 {
			GRAPHICS,
			COMPUTE,
			TRANSFER,
		}
		// CC_ENUM_CONVERSION_OPERATOR(QueueType);

		enum QueryType : uint32 {
			OCCLUSION,
			PIPELINE_STATISTICS,
			TIMESTAMP,
		}
		// CC_ENUM_CONVERSION_OPERATOR(QueryType);

		enum CommandBufferType : uint32 {
			PRIMARY,
			SECONDARY,
		}
		// CC_ENUM_CONVERSION_OPERATOR(CommandBufferType);

		enum ClearFlagBit : uint32 {
			NONE = 0,
			COLOR = 0x1,
			DEPTH = 0x2,
			STENCIL = 0x4,
			DEPTH_STENCIL = DEPTH | STENCIL,
			ALL = COLOR | DEPTH | STENCIL,
		}
		typealias ClearFlags = ClearFlagBit;
		// CC_ENUM_BITWISE_OPERATORS(ClearFlagBit);

		enum BarrierType : uint32 {
			FULL,
			SPLIT_BEGIN,
			SPLIT_END,
		}
		// CC_ENUM_BITWISE_OPERATORS(BarrierType);

		enum PassType : uint32 {
			RASTER,
			COMPUTE,
			COPY,
			MOVE,
			RAYTRACE,
			PRESENT,
		}
		// CC_ENUM_CONVERSION_OPERATOR(PassType);

/*
#define //EXPOSE_COPY_FN(type)      \
    type &copy(const type &rhs) { \
        *this = rhs;              \
        return *this;             \
    }
*/

		struct Size {
			public uint32 x =  0 ;
			public uint32 y =  0 ;
			public uint32 z =  0 ;

			//EXPOSE_COPY_FN(Size)
		}

		struct DeviceCaps {
			public uint32 maxVertexAttributes =  0 ;
			public uint32 maxVertexUniformVectors =  0 ;
			public uint32 maxFragmentUniformVectors =  0 ;
			public uint32 maxTextureUnits =  0 ;
			public uint32 maxImageUnits =  0 ;
			public uint32 maxVertexTextureUnits =  0 ;
			public uint32 maxColorRenderTargets =  0 ;
			public uint32 maxShaderStorageBufferBindings =  0 ;
			public uint32 maxShaderStorageBlockSize =  0 ;
			public uint32 maxUniformBufferBindings =  0 ;
			public uint32 maxUniformBlockSize =  0 ;
			public uint32 maxTextureSize =  0 ;
			public uint32 maxCubeMapTextureSize =  0 ;
			public uint32 maxArrayTextureLayers =  0 ;
			public uint32 max3DTextureSize =  0 ;
			public uint32 uboOffsetAlignment =  1 ;

			public uint32 maxComputeSharedMemorySize =  0 ;
			public uint32 maxComputeWorkGroupInvocations =  0 ;
			public Size maxComputeWorkGroupSize;
			public Size maxComputeWorkGroupCount;

			public bool supportQuery =  false ;
			public bool supportVariableRateShading =  false ;
			public bool supportSubPassShading =  false ;

			public float clipSpaceMinZ =  -1.F ;
			public float screenSpaceSignY =  1.F ;
			public float clipSpaceSignY =  1.F ;

			//EXPOSE_COPY_FN(DeviceCaps)
		}

		struct DeviceOptions {
			// whether deduce barrier in gfx internally.
			// if you wanna do the barrier thing by yourself
			// on the top of gfx layer, set it to false.
			public bool enableBarrierDeduce =  true ;
		}

		struct Offset {
			public int32 x =  0 ;
			public int32 y =  0 ;
			public int32 z =  0 ;

			//EXPOSE_COPY_FN(Offset)
		}

		struct Rect {
			public int32 x =  0 ;
			public int32 y =  0 ;
			public uint32 width =  0 ;
			public uint32 height =  0 ;

			//EXPOSE_COPY_FN(Rect)
		}

		struct Extent {
			public uint32 width =  0 ;
			public uint32 height =  0 ;
			public uint32 depth =  1 ;

			//EXPOSE_COPY_FN(Extent)
		}

		struct TextureSubresLayers {
			public uint32 mipLevel =  0 ;
			public uint32 baseArrayLayer =  0 ;
			public uint32 layerCount =  1 ;

			//EXPOSE_COPY_FN(TextureSubresLayers)
		}

		struct TextureSubresRange {
			public uint32 baseMipLevel =  0 ;
			public uint32 levelCount =  1 ;
			public uint32 baseArrayLayer =  0 ;
			public uint32 layerCount =  1 ;

			//EXPOSE_COPY_FN(TextureSubresRange)
		}

		struct TextureCopy {
			public TextureSubresLayers srcSubres;
			public Offset srcOffset;
			public TextureSubresLayers dstSubres;
			public Offset dstOffset;
			public Extent extent;

			//EXPOSE_COPY_FN(TextureCopy)
		}

		struct TextureBlit {
			public TextureSubresLayers srcSubres;
			public Offset srcOffset;
			public Extent srcExtent;
			public TextureSubresLayers dstSubres;
			public Offset dstOffset;
			public Extent dstExtent;

			//EXPOSE_COPY_FN(TextureBlit)
		}
		typealias TextureBlitList = List<TextureBlit>;

		struct BufferTextureCopy {
			public uint32 buffOffset =  0 ;
			public uint32 buffStride =  0 ;
			public uint32 buffTexHeight =  0 ;
			public Offset texOffset;
			public Extent texExtent;
			public TextureSubresLayers texSubres;

			//EXPOSE_COPY_FN(BufferTextureCopy)
		}
		typealias BufferTextureCopyList = List<BufferTextureCopy>;

		struct Viewport {
			public int32 left =  0 ;
			public int32 top =  0 ;
			public uint32 width =  0 ;
			public uint32 height =  0 ;
			public float minDepth =  0.F ;
			public float maxDepth =  1.F ;

			//EXPOSE_COPY_FN(Viewport)
		}

		struct Color {
			public float x =  0.F ;
			public float y =  0.F ;
			public float z =  0.F ;
			public float w =  0.F ;

			//EXPOSE_COPY_FN(Color)

			public int GetHashCode()
			{
				HashType seed = 0;
				seed = HashCode.Mix(seed, x.GetHashCode());
				seed = HashCode.Mix(seed, y.GetHashCode());
				seed = HashCode.Mix(seed, z.GetHashCode());
				seed = HashCode.Mix(seed, w.GetHashCode());
				return seed;
			}
		}
		typealias ColorList = List<Color>;

		struct MarkerInfo {
			public String name;
			public Color color;
		}

		struct BindingMappingInfo {
			/**
			 * For non-vulkan backends, to maintain compatibility and maximize
			 * descriptor cache-locality, descriptor-set-based binding numbers need
			 * to be mapped to backend-specific bindings based on maximum limit
			 * of available descriptor slots in each set.
			 *
			 * The GFX layer assumes the binding numbers for each descriptor type inside each set
			 * are guaranteed to be consecutive, so the mapping procedure is reduced
			 * to a simple shifting operation. This data structure specifies the
			 * capacity for each descriptor type in each set.
			 *
			 * The `setIndices` field defines the binding ordering between different sets.
			 * The last set index is treated as the 'flexible set', whose capacity is dynamically
			 * assigned based on the total available descriptor slots on the runtime device.
			 */
			public IndexList maxBlockCounts = new .();// 0 ;
			public IndexList maxSamplerTextureCounts =  new .();// 0 ;
			public IndexList maxSamplerCounts =  new .();// 0 ;
			public IndexList maxTextureCounts =  new .();// 0 ;
			public IndexList maxBufferCounts =  new .();// 0 ;
			public IndexList maxImageCounts =  new .();// 0 ;
			public IndexList maxSubpassInputCounts =  new .();// 0 ;

			public IndexList setIndices =  new .();// 0 ;

			//EXPOSE_COPY_FN(BindingMappingInfo)
		}

		struct SwapchainInfo {
			public uint32 windowId =  0 ;
			public void* windowHandle =  null; // @ts-overrides { type: 'HTMLCanvasElement' 
			public VsyncMode vsyncMode =  VsyncMode.ON ;

			public uint32 width =  0 ;
			public uint32 height =  0 ;

			//EXPOSE_COPY_FN(SwapchainInfo)
		}

		struct DeviceInfo {
			public BindingMappingInfo bindingMappingInfo;

			//EXPOSE_COPY_FN(DeviceInfo)
		}

		[Align(8)] struct BufferInfo {
			public BufferUsage usage =  BufferUsageBit.NONE ;
			public MemoryUsage memUsage =  MemoryUsageBit.NONE ;
			public uint32 size =  0 ;
			public uint32 stride =  1 ; // in bytes
			public BufferFlags flags =  BufferFlagBit.NONE ;
			public uint32 _padding =  0 ;

			//EXPOSE_COPY_FN(BufferInfo)

			public int GetHashCode()
			{
				int hash = 0;

				hash = HashCode.Mix(hash, usage.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, memUsage.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, size);
				hash = HashCode.Mix(hash, stride);
				hash = HashCode.Mix(hash, flags.Underlying.GetHashCode());

				return hash;
			}
		}

		struct BufferViewInfo {
			public Buffer buffer =  null ;
			public uint32 offset =  0 ;
			public uint32 range =  0 ;

			//EXPOSE_COPY_FN(BufferViewInfo)
		}

		struct DrawInfo {
			public uint32 vertexCount =  0 ;
			public uint32 firstVertex =  0 ;
			public uint32 indexCount =  0 ;
			public uint32 firstIndex =  0 ;
			public int32 vertexOffset =  0 ;
			public uint32 instanceCount =  0 ;
			public uint32 firstInstance =  0 ;

			//EXPOSE_COPY_FN(DrawInfo)
		}

		typealias DrawInfoList = List<DrawInfo>;

		struct DispatchInfo {
			public uint32 groupCountX =  0 ;
			public uint32 groupCountY =  0 ;
			public uint32 groupCountZ =  0 ;

			public Buffer* indirectBuffer =  null ; // @ts-nullable
			public uint32 indirectOffset =  0 ;

			//EXPOSE_COPY_FN(DispatchInfo)
		}

		typealias DispatchInfoList = List<DispatchInfo>;

		struct IndirectBuffer {
			public DrawInfoList drawInfos;

			//EXPOSE_COPY_FN(IndirectBuffer)
		}

		[Align(8)] struct TextureInfo {
			public TextureType type =  TextureType.TEX2D ;
			public TextureUsage usage =  TextureUsageBit.NONE ;
			public Format format =  Format.UNKNOWN ;
			public uint32 width =  0 ;
			public uint32 height =  0 ;
			public TextureFlags flags =  TextureFlagBit.NONE ;
			public uint32 layerCount =  1 ;
			public uint32 levelCount =  1 ;
			public SampleCount samples =  SampleCount.X1 ;
			public uint32 depth =  1 ;
			public void* externalRes =  null ; // CVPixelBuffer for Metal, EGLImage for GLES
#if BF_32_BIT
			public uint32 _padding =  0 ;
#endif

			//EXPOSE_COPY_FN(TextureInfo)

			public int GetHashCode()
			{
				int hash = 0;

				hash = HashCode.Mix(hash, type.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, usage.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, format.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, width);
				hash = HashCode.Mix(hash, height);
				hash = HashCode.Mix(hash, flags.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, layerCount);
				hash = HashCode.Mix(hash, levelCount);
				hash = HashCode.Mix(hash, samples.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, depth);
				hash = HashCode.Mix(hash, HashCode.Generate(externalRes));

				return hash;
			}
		}

		[Align(8)] struct TextureViewInfo {
			public Texture texture =  null ;
			public TextureType type =  TextureType.TEX2D ;
			public Format format =  Format.UNKNOWN ;
			public uint32 baseLevel =  0 ;
			public uint32 levelCount =  1 ;
			public uint32 baseLayer =  0 ;
			public uint32 layerCount =  1 ;
			public uint32 basePlane =  0 ;
			public uint32 planeCount =  1 ;
#if BF_32_BIT
			public uint32 _padding =  0 ;
#endif

			//EXPOSE_COPY_FN(TextureViewInfo)

			public int GetHashCode()
			{
				int hash = 0;

				hash = HashCode.Mix(hash, HashCode.Generate(texture));
				hash = HashCode.Mix(hash, type.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, format.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, baseLevel);
				hash = HashCode.Mix(hash, levelCount);
				hash = HashCode.Mix(hash, baseLayer);
				hash = HashCode.Mix(hash, layerCount);
				hash = HashCode.Mix(hash, basePlane);
				hash = HashCode.Mix(hash, planeCount);

				return hash;
			}
		}

		[Align(8)] struct SamplerInfo : IHashable {
			public Filter minFilter =  Filter.LINEAR ;
			public Filter magFilter =  Filter.LINEAR ;
			public Filter mipFilter =  Filter.NONE ;
			public Address addressU =  Address.WRAP ;
			public Address addressV =  Address.WRAP ;
			public Address addressW =  Address.WRAP ;
			public uint32 maxAnisotropy =  0 ;
			public ComparisonFunc cmpFunc =  ComparisonFunc.ALWAYS ;

			//EXPOSE_COPY_FN(SamplerInfo)

			public int GetHashCode()
			{
				// the hash may be used to reconstruct the original struct
				HashType hash = (uint32)(minFilter);
				hash |= (uint32)(magFilter) << 2;
				hash |= (uint32)(mipFilter) << 4;
				hash |= (uint32)(addressU) << 6;
				hash |= (uint32)(addressV) << 8;
				hash |= (uint32)(addressW) << 10;
				hash |= (uint32)(maxAnisotropy) << 12;
				hash |= (uint32)(cmpFunc) << 16;
				return (HashType)(hash);
			}
		}

		struct Uniform {
			public String name;
			public VariableType type =  VariableType.UNKNOWN ;
			public uint32 count =  0 ;

			//EXPOSE_COPY_FN(Uniform)
		}

		typealias UniformList = List<Uniform>;

		struct UniformBlock {
			public uint32 set =  0 ;
			public uint32 binding =  0 ;
			public String name;
			public UniformList members;
			public uint32 count =  0 ;
			public uint32 flattened =  0 ;

			//EXPOSE_COPY_FN(UniformBlock)
		}

		typealias UniformBlockList = List<UniformBlock>;

		struct UniformSamplerTexture {
			public uint32 set =  0 ;
			public uint32 binding =  0 ;
			public String name;
			public VariableType type =  VariableType.UNKNOWN ;
			public uint32 count =  0 ;
			public uint32 flattened =  0 ;

			//EXPOSE_COPY_FN(UniformSamplerTexture)
		}

		typealias UniformSamplerTextureList = List<UniformSamplerTexture>;

		struct UniformSampler {
			public uint32 set =  0 ;
			public uint32 binding =  0 ;
			public String name;
			public uint32 count =  0 ;
			public uint32 flattened =  0 ;

			//EXPOSE_COPY_FN(UniformSampler)
		}

		typealias UniformSamplerList = List<UniformSampler>;

		struct UniformTexture {
			public uint32 set =  0 ;
			public uint32 binding =  0 ;
			public String name;
			public VariableType type =  VariableType.UNKNOWN ;
			public uint32 count =  0 ;
			public uint32 flattened =  0 ;

			//EXPOSE_COPY_FN(UniformTexture)
		}

		typealias UniformTextureList = List<UniformTexture>;

		struct UniformStorageImage {
			public uint32 set =  0 ;
			public uint32 binding =  0 ;
			public String name;
			public VariableType type =  VariableType.UNKNOWN ;
			public uint32 count =  0 ;
			public MemoryAccess memoryAccess =  MemoryAccessBit.READ_WRITE ;
			public uint32 flattened =  0 ;

			//EXPOSE_COPY_FN(UniformStorageImage)
		}

		typealias UniformStorageImageList = List<UniformStorageImage>;

		struct UniformStorageBuffer {
			public uint32 set =  0 ;
			public uint32 binding =  0 ;
			public String name;
			public uint32 count =  0 ;
			public MemoryAccess memoryAccess =  MemoryAccessBit.READ_WRITE ;
			public uint32 flattened =  0 ;

			//EXPOSE_COPY_FN(UniformStorageBuffer)
		}

		typealias UniformStorageBufferList = List<UniformStorageBuffer>;

		struct UniformInputAttachment {
			public uint32 set =  0 ;
			public uint32 binding =  0 ;
			public String name;
			public uint32 count =  0 ;
			public uint32 flattened =  0 ;

			//EXPOSE_COPY_FN(UniformInputAttachment)
		}

		typealias UniformInputAttachmentList = List<UniformInputAttachment>;

		struct ShaderStage {
			public ShaderStageFlagBit stage =  ShaderStageFlagBit.NONE ;
			public String source;

			//EXPOSE_COPY_FN(ShaderStage)
		}

		typealias ShaderStageList = List<ShaderStage>;

		struct VertexAttribute {
			public String name;
			public Format format =  Format.UNKNOWN ;
			public bool isNormalized =  false ;
			public uint32 stream =  0 ;
			public bool isInstanced =  false ;
			public uint32 location =  0 ;

			//EXPOSE_COPY_FN(VertexAttribute)
		}

		typealias VertexAttributeList = List<VertexAttribute>;

static{
		public const char8* ATTR_NAME_POSITION = "a_position";
		public const char8* ATTR_NAME_NORMAL = "a_normal";
		public const char8* ATTR_NAME_TANGENT = "a_tangent";
		public const char8* ATTR_NAME_BITANGENT = "a_bitangent";
		public const char8* ATTR_NAME_WEIGHTS = "a_weights";
		public const char8* ATTR_NAME_JOINTS = "a_joints";
		public const char8* ATTR_NAME_COLOR = "a_color";
		public const char8* ATTR_NAME_COLOR1 = "a_color1";
		public const char8* ATTR_NAME_COLOR2 = "a_color2";
		public const char8* ATTR_NAME_TEX_COORD = "a_texCoord";
		public const char8* ATTR_NAME_TEX_COORD1 = "a_texCoord1";
		public const char8* ATTR_NAME_TEX_COORD2 = "a_texCoord2";
		public const char8* ATTR_NAME_TEX_COORD3 = "a_texCoord3";
		public const char8* ATTR_NAME_TEX_COORD4 = "a_texCoord4";
		public const char8* ATTR_NAME_TEX_COORD5 = "a_texCoord5";
		public const char8* ATTR_NAME_TEX_COORD6 = "a_texCoord6";
		public const char8* ATTR_NAME_TEX_COORD7 = "a_texCoord7";
		public const char8* ATTR_NAME_TEX_COORD8 = "a_texCoord8";
		public const char8* ATTR_NAME_BATCH_ID = "a_batch_id";
		public const char8* ATTR_NAME_BATCH_UV = "a_batch_uv";
}

		struct ShaderInfo {
			public String name;
			public ShaderStageList stages;
			public VertexAttributeList attributes;
			public UniformBlockList blocks;
			public UniformStorageBufferList buffers;
			public UniformSamplerTextureList samplerTextures;
			public UniformSamplerList samplers;
			public UniformTextureList textures;
			public UniformStorageImageList images;
			public UniformInputAttachmentList subpassInputs;
			public HashType hash = INVALID_SHADER_HASH;

			//EXPOSE_COPY_FN(ShaderInfo)
		}

		struct InputAssemblerInfo {
			public VertexAttributeList attributes;
			public BufferList vertexBuffers;
			public Buffer indexBuffer =  null ;    // @ts-nullable
			public Buffer indirectBuffer =  null ; // @ts-nullable

			//EXPOSE_COPY_FN(InputAssemblerInfo)
		}

		[Align(8)] struct ColorAttachment {
			public Format format =  Format.UNKNOWN ;
			public SampleCount sampleCount =  SampleCount.X1 ;
			public LoadOp loadOp =  LoadOp.CLEAR ;
			public StoreOp storeOp =  StoreOp.STORE ;
			public GeneralBarrier barrier =  null ;
#if BF_32_BIT
			public uint32 _padding =  0 ;
#endif
			//EXPOSE_COPY_FN(ColorAttachment)

			public int GetHashCode()
			{
				int hash = 0;

				hash = HashCode.Mix(hash, format.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, sampleCount.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, loadOp.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, storeOp.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, HashCode.Generate(barrier));

				return hash;
			}
		}

		typealias ColorAttachmentList = List<ColorAttachment>;

		[Align(8)] struct DepthStencilAttachment {
			public Format format =  Format.UNKNOWN ;
			public SampleCount sampleCount =  SampleCount.X1 ;
			public LoadOp depthLoadOp =  LoadOp.CLEAR ;
			public StoreOp depthStoreOp =  StoreOp.STORE ;
			public LoadOp stencilLoadOp =  LoadOp.CLEAR ;
			public StoreOp stencilStoreOp =  StoreOp.STORE ;
			public GeneralBarrier barrier =  null ;
#if BF_32_BIT
			public uint32 _padding =  0 ;
#endif
			//EXPOSE_COPY_FN(DepthStencilAttachment)

			public int GetHashCode()
			{
				int hash = 0;

				hash = HashCode.Mix(hash, format.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, sampleCount.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, depthLoadOp.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, depthStoreOp.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, stencilLoadOp.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, stencilStoreOp.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, HashCode.Generate(barrier));

				return hash;

			}
		}

		struct SubpassInfo {
			public IndexList inputs;
			public IndexList colors;
			public IndexList resolves;
			public IndexList preserves;

			public uint32 depthStencil =  INVALID_BINDING ;
			public uint32 depthStencilResolve =  INVALID_BINDING ;
			public uint32 shadingRate =  INVALID_BINDING ;
			public ResolveMode depthResolveMode =  ResolveMode.NONE ;
			public ResolveMode stencilResolveMode =  ResolveMode.NONE ;

			//EXPOSE_COPY_FN(SubpassInfo)

			public int GetHashCode()
			{
				HashType seed = 8;
				seed = HashCode.Mix(seed, HashCode.Generate(inputs));
				seed = HashCode.Mix(seed, HashCode.Generate(colors));
				seed = HashCode.Mix(seed, HashCode.Generate(resolves));
				seed = HashCode.Mix(seed, HashCode.Generate(preserves));
				seed = HashCode.Mix(seed, depthStencil);
				seed = HashCode.Mix(seed, depthStencilResolve);
				seed = HashCode.Mix(seed, depthResolveMode.Underlying.GetHashCode());
				seed = HashCode.Mix(seed, stencilResolveMode.Underlying.GetHashCode());
				return seed;
			}

			public static bool operator==(Self lhs, Self rhs) {
				return lhs.inputs == rhs.inputs &&
					lhs.colors == rhs.colors &&
					lhs.resolves == rhs.resolves &&
					lhs.preserves == rhs.preserves &&
					lhs.depthStencil == rhs.depthStencil &&
					lhs.depthStencilResolve == rhs.depthStencilResolve &&
					lhs.depthResolveMode == rhs.depthResolveMode &&
					lhs.stencilResolveMode == rhs.stencilResolveMode;
			}
		}

		typealias SubpassInfoList = List<SubpassInfo>;

		[Align(8)] struct SubpassDependency {
			public uint32 srcSubpass =  0 ;
			public uint32 dstSubpass =  0 ;
			public GeneralBarrier generalBarrier =  null ;

			public AccessFlags prevAccesses = .();
			public AccessFlags nextAccesses = .();

			//EXPOSE_COPY_FN(SubpassDependency)

			public int GetHashCode()
			{
				HashType seed = 8;
				seed = HashCode.Mix(seed, dstSubpass);
				seed = HashCode.Mix(seed, srcSubpass);
				seed = HashCode.Mix(seed, HashCode.Generate(generalBarrier));
				seed = HashCode.Mix(seed, prevAccesses.Underlying.GetHashCode());
				seed = HashCode.Mix(seed, nextAccesses.Underlying.GetHashCode());
				return seed;
			}

			public static bool operator==(Self lhs, Self rhs) {
				return lhs.srcSubpass == rhs.srcSubpass &&
					lhs.dstSubpass == rhs.dstSubpass &&
					lhs.generalBarrier == rhs.generalBarrier &&
					lhs.prevAccesses == rhs.prevAccesses &&
					lhs.nextAccesses == rhs.nextAccesses;
			}
		}

		typealias SubpassDependencyList = List<SubpassDependency>;

		struct RenderPassInfo {
			public ColorAttachmentList colorAttachments;
			public DepthStencilAttachment depthStencilAttachment;
			public DepthStencilAttachment depthStencilResolveAttachment;
			public SubpassInfoList subpasses;
			public SubpassDependencyList dependencies;

			//EXPOSE_COPY_FN(RenderPassInfo)

			public int GetHashCode()
			{
				HashType seed = 4;
				//seed = HashCode.Mix(seed, colorAttachments);
				if(colorAttachments != null)
				{
					for(int i = 0; i < colorAttachments.Count; i++)
					{
						seed = HashCode.Mix(seed, colorAttachments[i].GetHashCode());
					}
				}
				seed = HashCode.Mix(seed, depthStencilAttachment.GetHashCode());
				seed = HashCode.Mix(seed, depthStencilResolveAttachment.GetHashCode());
				//seed = HashCode.Mix(seed, subpasses);
				if(subpasses != null)
				{
					for(int i = 0; i < subpasses.Count; i++)
					{
						seed = HashCode.Mix(seed, subpasses[i].GetHashCode());
					}
				}
				//seed = HashCode.Mix(seed, dependencies);
				if(dependencies != null)
				{
					for(int i = 0; i < dependencies.Count; i++)
					{
						seed = HashCode.Mix(seed, dependencies[i].GetHashCode());
					}
				}
				return seed;
			}

			public static bool operator==(Self lhs, Self rhs)
			{
				return lhs.colorAttachments == rhs.colorAttachments &&
					lhs.depthStencilAttachment == rhs.depthStencilAttachment &&
					lhs.depthStencilResolveAttachment == rhs.depthStencilResolveAttachment &&
					lhs.subpasses == rhs.subpasses &&
					lhs.dependencies == rhs.dependencies;
			}
		}

		struct ResourceRange {
			public uint32 width =  0 ;
			public uint32 height =  0 ;
			public uint32 depthOrArraySize =  0 ;
			public uint32 firstSlice =  0 ;
			public uint32 numSlices =  0 ;
			public uint32 mipLevel =  0 ;
			public uint32 levelCount =  0 ;
			public uint32 basePlane =  0 ;
			public uint32 planeCount =  0 ;

			public int GetHashCode()
			{
				int hash = 0;

				hash = HashCode.Mix(hash,  width );
				hash = HashCode.Mix(hash,  height );
				hash = HashCode.Mix(hash,  depthOrArraySize );
				hash = HashCode.Mix(hash,  firstSlice );
				hash = HashCode.Mix(hash,  numSlices );
				hash = HashCode.Mix(hash,  mipLevel );
				hash = HashCode.Mix(hash,  levelCount );
				hash = HashCode.Mix(hash,  basePlane );
				hash = HashCode.Mix(hash,  planeCount );

				return hash;
			}
		}

		[Align(8)] struct GeneralBarrierInfo : IHashable {
			public AccessFlags prevAccesses =  AccessFlagBit.NONE ;
			public AccessFlags nextAccesses =  AccessFlagBit.NONE ;

			public BarrierType type =  BarrierType.FULL ;
			public uint32 _padding =  0 ;

			//EXPOSE_COPY_FN(GeneralBarrierInfo)

			public int GetHashCode()
			{
				int hash = 0;

				hash = HashCode.Mix(hash, prevAccesses.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, nextAccesses.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, type.Underlying.GetHashCode());

				return hash;
			}
		}
		typealias GeneralBarrierInfoList = List<GeneralBarrierInfo>;

		[Align(8)] struct TextureBarrierInfo : IHashable {
			public AccessFlags prevAccesses =  AccessFlagBit.NONE ;
			public AccessFlags nextAccesses =  AccessFlagBit.NONE ;

			public BarrierType type =  BarrierType.FULL ;

			public ResourceRange range = .();
			public uint64 discardContents =  0 ; // @ts-boolean

			public CommandQueue srcQueue =  null ; // @ts-nullable
			public CommandQueue dstQueue =  null ; // @ts-nullable

			//EXPOSE_COPY_FN(TextureBarrierInfo)

			public int GetHashCode()
			{
				int hash = 0;

				hash = HashCode.Mix(hash, prevAccesses.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, nextAccesses.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, type.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, range.GetHashCode());
				hash = HashCode.Mix(hash, discardContents.GetHashCode());
				hash = HashCode.Mix(hash, HashCode.Generate(srcQueue));
				hash = HashCode.Mix(hash, HashCode.Generate(dstQueue));

				return hash;
			}
		}
		typealias TextureBarrierInfoList = List<TextureBarrierInfo>;

		[Align(8)] struct BufferBarrierInfo : IHashable {
			public AccessFlags prevAccesses =  AccessFlagBit.NONE ;
			public AccessFlags nextAccesses =  AccessFlagBit.NONE ;

			public BarrierType type =  BarrierType.FULL ;

			public uint32 offset =  0 ;
			public uint32 size =  0 ;
			public uint32 _padding =  0 ;
			public uint64 discardContents =  0 ; // @ts-boolean

			public CommandQueue srcQueue =  null ; // @ts-nullable
			public CommandQueue dstQueue =  null ; // @ts-nullable

			//EXPOSE_COPY_FN(BufferBarrierInfo)

			public int GetHashCode()
			{
				int hash = 0;

				hash = HashCode.Mix(hash, prevAccesses.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, nextAccesses.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, type.Underlying.GetHashCode());
				hash = HashCode.Mix(hash, offset);
				hash = HashCode.Mix(hash, size);
				hash = HashCode.Mix(hash, discardContents.GetHashCode());
				hash = HashCode.Mix(hash, HashCode.Generate(srcQueue));
				hash = HashCode.Mix(hash, HashCode.Generate(dstQueue));

				return hash;
			}
		}
		typealias BufferBarrierInfoList = List<BufferBarrierInfo>;

		struct FramebufferInfo {
			public RenderPass renderPass =  null ;
			public TextureList colorTextures;
			public Texture depthStencilTexture =  null ; // @ts-nullable
			public Texture depthStencilResolveTexture =  null ; // @ts-nullable

			//EXPOSE_COPY_FN(FramebufferInfo)

			public int GetHashCode()
			{
				// render pass is mostly irrelevant
				HashType seed = (HashType)(colorTextures.Count) +
					(HashType)(depthStencilTexture != null ? 1 : 0) +
					(HashType)(depthStencilResolveTexture != null ? 1 : 0);
				if (depthStencilTexture != null) {
					seed = HashCode.Mix(seed, depthStencilTexture.getObjectID());
					seed = HashCode.Mix(seed, depthStencilTexture.getHash());
				}
				if (depthStencilResolveTexture != null) {
					seed = HashCode.Mix(seed, depthStencilResolveTexture.getObjectID());
					seed = HashCode.Mix(seed, depthStencilResolveTexture.getHash());
				}
				for (var colorTexture in colorTextures) {
					seed = HashCode.Mix(seed, colorTexture.getObjectID());
					seed = HashCode.Mix(seed, colorTexture.getHash());
				}
				seed = HashCode.Mix(seed, renderPass.getHash());
				return seed;
			}

			public static bool operator==(Self lhs, Self rhs) {
				// render pass is mostly irrelevant
				bool res = false;
				res = lhs.colorTextures == rhs.colorTextures;

				if (res) {
					res = lhs.depthStencilTexture == rhs.depthStencilTexture;
				}

				if (res) {
					res = lhs.depthStencilResolveTexture == rhs.depthStencilResolveTexture;
				}

				if (res) {
					for (int i = 0; i < lhs.colorTextures.Count; ++i) {
						res = lhs.colorTextures[i].getRaw() == rhs.colorTextures[i].getRaw() &&
							lhs.colorTextures[i].getHash() == rhs.colorTextures[i].getHash();
						if (!res) {
							break;
						}
					}
					res = lhs.renderPass.getHash() == rhs.renderPass.getHash();
					if (res) {
						res = lhs.depthStencilTexture.getRaw() == rhs.depthStencilTexture.getRaw() &&
							lhs.depthStencilTexture.getHash() == rhs.depthStencilTexture.getHash();
					}
				}
				return res;
			}
		}

		struct DescriptorSetLayoutBinding {
			public uint32 binding =  INVALID_BINDING ;
			public DescriptorType descriptorType =  DescriptorType.UNKNOWN ;
			public uint32 count =  0 ;
			public ShaderStageFlags stageFlags =  ShaderStageFlagBit.NONE ;
			public SamplerList immutableSamplers;

			//EXPOSE_COPY_FN(DescriptorSetLayoutBinding)
		}
		typealias DescriptorSetLayoutBindingList = List<DescriptorSetLayoutBinding>;

		struct DescriptorSetLayoutInfo {
			public DescriptorSetLayoutBindingList bindings;

			//EXPOSE_COPY_FN(DescriptorSetLayoutInfo)
		}

		struct DescriptorSetInfo {
			public DescriptorSetLayout layout =  null ;

			//EXPOSE_COPY_FN(DescriptorSetInfo)
		}

		struct PipelineLayoutInfo {
			public DescriptorSetLayoutList setLayouts;

			//EXPOSE_COPY_FN(PipelineLayoutInfo)
		}

		struct InputState {
			public VertexAttributeList attributes;

			//EXPOSE_COPY_FN(InputState)
		}

		// The memory layout of this structure should exactly match a plain `Uint32Array`
		struct RasterizerState {
			public uint32 isDiscard =  0 ; // @ts-boolean
			public PolygonMode polygonMode =  PolygonMode.FILL ;
			public ShadeModel shadeModel =  ShadeModel.GOURAND ;
			public CullMode cullMode =  CullMode.BACK ;
			public uint32 isFrontFaceCCW =  1 ;   // @ts-boolean
			public uint32 depthBiasEnabled =  0 ; // @ts-boolean
			public float depthBias =  0.F ;
			public float depthBiasClamp =  0.F ;
			public float depthBiasSlop =  0.F ;
			public uint32 isDepthClip =  1 ;   // @ts-boolean
			public uint32 isMultisample =  0 ; // @ts-boolean
			public float lineWidth =  1.F ;

			public void reset() mut {
				this = RasterizerState();
			}

			//EXPOSE_COPY_FN(RasterizerState)
		}

		// The memory layout of this structure should exactly match a plain `Uint32Array`
		struct DepthStencilState {
			public uint32 depthTest =  1 ;  // @ts-boolean
			public uint32 depthWrite =  1 ; // @ts-boolean
			public ComparisonFunc depthFunc =  ComparisonFunc.LESS ;
			public uint32 stencilTestFront =  0 ; // @ts-boolean
			public ComparisonFunc stencilFuncFront =  ComparisonFunc.ALWAYS ;
			public uint32 stencilReadMaskFront =  0xffffffff ;
			public uint32 stencilWriteMaskFront =  0xffffffff ;
			public StencilOp stencilFailOpFront =  StencilOp.KEEP ;
			public StencilOp stencilZFailOpFront =  StencilOp.KEEP ;
			public StencilOp stencilPassOpFront =  StencilOp.KEEP ;
			public uint32 stencilRefFront =  1 ;
			public uint32 stencilTestBack =  0 ; // @ts-boolean
			public ComparisonFunc stencilFuncBack =  ComparisonFunc.ALWAYS ;
			public uint32 stencilReadMaskBack =  0xffffffff ;
			public uint32 stencilWriteMaskBack =  0xffffffff ;
			public StencilOp stencilFailOpBack =  StencilOp.KEEP ;
			public StencilOp stencilZFailOpBack =  StencilOp.KEEP ;
			public StencilOp stencilPassOpBack =  StencilOp.KEEP ;
			public uint32 stencilRefBack =  1 ;

			public void reset() mut {
				this = DepthStencilState();
			}

			//EXPOSE_COPY_FN(DepthStencilState)
		}

		struct BlendTarget {
			public uint32 blend =  0 ; // @ts-boolean
			public BlendFactor blendSrc =  BlendFactor.ONE ;
			public BlendFactor blendDst =  BlendFactor.ZERO ;
			public BlendOp blendEq =  BlendOp.ADD ;
			public BlendFactor blendSrcAlpha =  BlendFactor.ONE ;
			public BlendFactor blendDstAlpha =  BlendFactor.ZERO ;
			public BlendOp blendAlphaEq =  BlendOp.ADD ;
			public ColorMask blendColorMask =  ColorMask.ALL ;

			public void reset() mut {
				this = BlendTarget();
			}

			//EXPOSE_COPY_FN(BlendTarget)
		}

		typealias BlendTargetList = List<BlendTarget>;

		// The memory layout of this structure should exactly match a plain `Uint32Array`
		struct BlendState {
			public uint32 isA2C =  0 ;      // @ts-boolean
			public uint32 isIndepend =  0 ; // @ts-boolean
			public Color blendColor;
			public BlendTargetList targets =  new .(1);// 1 ;

			public void setTarget(int index, in BlendTarget target) {
				if (index >= targets.Count) {
					targets.Resize(index + 1);
				}
				targets[index] = target;
			}

			public void reset() mut {
				this = BlendState();
			}

			public void destroy() {}

			//EXPOSE_COPY_FN(BlendState)
		}

		struct PipelineStateInfo {
			public Shader shader =  null ;
			public PipelineLayout pipelineLayout =  null ;
			public RenderPass renderPass =  null ;
			public InputState inputState;
			public RasterizerState rasterizerState;
			public DepthStencilState depthStencilState;
			public BlendState blendState;
			public PrimitiveMode primitive =  PrimitiveMode.TRIANGLE_LIST ;
			public DynamicStateFlags dynamicStates =  DynamicStateFlagBit.NONE ;
			public PipelineBindPoint bindPoint =  PipelineBindPoint.GRAPHICS ;
			public uint32 subpass =  0 ;

			//EXPOSE_COPY_FN(PipelineStateInfo)
		}

		struct CommandBufferInfo {
			public CommandQueue queue =  null ;
			public CommandBufferType type =  CommandBufferType.PRIMARY ;

			//EXPOSE_COPY_FN(CommandBufferInfo)
		}

		struct QueueInfo {
			public QueueType type =  QueueType.GRAPHICS ;

			//EXPOSE_COPY_FN(QueueInfo)
		}

		struct QueryPoolInfo {
			public QueryType type =  QueryType.OCCLUSION ;
			public uint32 maxQueryObjects =  DEFAULT_MAX_QUERY_OBJECTS ;
			public bool forceWait =  true ;

			//EXPOSE_COPY_FN(QueryPoolInfo)
		}

		struct FormatInfo {
			public String name;
			public uint32 size =  0 ;
			public uint32 count =  0 ;
			public FormatType type =  /*FormatType*/.NONE ;
			public bool hasAlpha =  false ;
			public bool hasDepth =  false ;
			public bool hasStencil =  false ;
			public bool isCompressed =  false ;

			public this(String name,
				uint32 size =  0,
				uint32 count =  0,
				FormatType type =  /*FormatType*/.NONE,
				bool hasAlpha =  false,
				bool hasDepth =  false,
				bool hasStencil =  false,
				bool isCompressed =  false)
			{
				this.name = name;
				this.size = size;
				this.type = type;
				this.hasAlpha = hasAlpha;
				this.hasStencil = hasStencil;
				this.isCompressed = isCompressed;
			}
		}

		struct MemoryStatus {
			public uint32 bufferSize =  0 ;
			public uint32 textureSize =  0 ;

			//EXPOSE_COPY_FN(MemoryStatus)
		}

		struct DynamicStencilStates {
			public uint32 writeMask =  0 ;
			public uint32 compareMask =  0 ;
			public uint32 reference =  0 ;

			//EXPOSE_COPY_FN(DynamicStencilStates)
		}

		struct DynamicStates {
			public Viewport viewport;
			public Rect scissor;
			public Color blendConstant;
			public float lineWidth =  1.F ;
			public float depthBiasConstant =  0.F ;
			public float depthBiasClamp =  0.F ;
			public float depthBiasSlope =  0.F ;
			public float depthMinBounds =  0.F ;
			public float depthMaxBounds =  0.F ;

			public DynamicStencilStates stencilStatesFront;
			public DynamicStencilStates stencilStatesBack;

			//EXPOSE_COPY_FN(DynamicStates)
		}

//#undef //EXPOSE_COPY_FN

	} // namespace gfx
} // namespace cc
