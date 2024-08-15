using System;
using System.Collections;
using Sedulous.Foundation.Mathematics;
using Sedulous.Foundation.Collections;
namespace Sedulous.RAL;

enum ApiType
{
	Vulkan,
	DX12,
	Metal
}

struct MemoryBudget
{
	public uint64 budget;
	public uint64 usage;
}

struct MemoryRequirements
{
	public uint64 size;
	public uint64 alignment;
	public uint32 memory_type_bits;
}

enum ResourceState : uint32
{
	kUnknown = 0,
	kCommon = 1 << 0,
	kVertexAndConstantBuffer = 1 << 1,
	kIndexBuffer = 1 << 2,
	kRenderTarget = 1 << 3,
	kUnorderedAccess = 1 << 4,
	kDepthStencilWrite = 1 << 5,
	kDepthStencilRead = 1 << 6,
	kNonPixelShaderResource = 1 << 7,
	kPixelShaderResource = 1 << 8,
	kIndirectArgument = 1 << 9,
	kCopyDest = 1 << 10,
	kCopySource = 1 << 11,
	kRaytracingAccelerationStructure = 1 << 12,
	kShadingRateSource = 1 << 13,
	kPresent = 1 << 14,
	kGenericRead = .kVertexAndConstantBuffer | .kIndexBuffer | .kCopySource |
		.kNonPixelShaderResource | .kPixelShaderResource |
		.kIndirectArgument,
	kUndefined = 1 << 15,
}

enum ViewDimension
{
	kUnknown,
	kBuffer,
	kTexture1D,
	kTexture1DArray,
	kTexture2D,
	kTexture2DArray,
	kTexture2DMS,
	kTexture2DMSArray,
	kTexture3D,
	kTextureCube,
	kTextureCubeArray,
}

enum SamplerFilter
{
	kAnisotropic,
	kMinMagMipLinear,
	kComparisonMinMagMipLinear,
}

enum SamplerTextureAddressMode { kWrap, kClamp }

enum SamplerComparisonFunc { kNever, kAlways, kLess }

struct SamplerDesc
{
	public SamplerFilter filter;
	public SamplerTextureAddressMode mode;
	public SamplerComparisonFunc func;
}

enum ViewType
{
	kUnknown,
	kConstantBuffer,
	kSampler,
	kTexture,
	kRWTexture,
	kBuffer,
	kRWBuffer,
	kStructuredBuffer,
	kRWStructuredBuffer,
	kAccelerationStructure,
	kShadingRateSource,
	kRenderTarget,
	kDepthStencil
}

enum ShaderBlobType
{
	kDXIL,
	kSPIRV,
}

enum ResourceType
{
	kUnknown,
	kBuffer,
	kTexture,
	kSampler,
	kAccelerationStructure,
}

enum TextureType
{
	k1D,
	k2D,
	k3D,
}

enum BindFlag
{
	kRenderTarget = 1 << 1,
	kDepthStencil = 1 << 2,
	kShaderResource = 1 << 3,
	kUnorderedAccess = 1 << 4,
	kConstantBuffer = 1 << 5,
	kIndexBuffer = 1 << 6,
	kVertexBuffer = 1 << 7,
	kAccelerationStructure = 1 << 8,
	kRayTracing = 1 << 9,
	kCopyDest = 1 << 10,
	kCopySource = 1 << 11,
	kShadingRateSource = 1 << 12,
	kShaderTable = 1 << 13,
	kIndirectBuffer = 1 << 14
}

enum FillMode { kWireframe, kSolid }

enum CullMode
{
	kNone,
	kFront,
	kBack,
}

struct RasterizerDesc : IEquatable<RasterizerDesc>, IHashable
{
	public FillMode fill_mode = FillMode.kSolid;
	public CullMode cull_mode = CullMode.kNone;
	public int32 depth_bias = 0;

	public bool Equals(RasterizerDesc other)
	{
		return fill_mode == other.fill_mode &&
			cull_mode == other.cull_mode &&
			depth_bias == other.depth_bias;
	}

	public static bool operator ==(RasterizerDesc left, RasterizerDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(RasterizerDesc left, RasterizerDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = (int)fill_mode;
		hash = HashCode.Mix(hash, (int)cull_mode);
		hash = HashCode.Mix(hash, (int)depth_bias);
		return hash;
	}
}

enum Blend
{
	kZero,
	kSrcAlpha,
	kInvSrcAlpha,
}

enum BlendOp
{
	kAdd,
}

public struct BlendDesc : IEquatable<BlendDesc>, IHashable
{
	public bool blend_enable = false;
	public Blend blend_src;
	public Blend blend_dest;
	public BlendOp blend_op;
	public Blend blend_src_alpha;
	public Blend blend_dest_alpha;
	public BlendOp blend_op_alpha;

	public this()
	{
		blend_enable = false;
		this.blend_src = default;
		this.blend_dest = default;
		this.blend_op = default;
		this.blend_src_alpha = default;
		this.blend_dest_alpha = default;
		this.blend_op_alpha = default;
	}

	public static bool operator ==(BlendDesc left, BlendDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(BlendDesc left, BlendDesc right)
	{
		return !(left == right);
	}

	public bool Equals(BlendDesc other)
	{
		return blend_enable == other.blend_enable &&
			blend_src == other.blend_src &&
			blend_dest == other.blend_dest &&
			blend_op == other.blend_op &&
			blend_src_alpha == other.blend_src_alpha &&
			blend_dest_alpha == other.blend_dest_alpha &&
			blend_op_alpha == other.blend_op_alpha;
	}

	public int GetHashCode()
	{
		int hash = HashCode.Mix(blend_enable ? 1 : 0, (int)blend_src);
		hash = HashCode.Mix(hash, (int)blend_dest);
		hash = HashCode.Mix(hash, (int)blend_op);
		hash = HashCode.Mix(hash, (int)blend_src_alpha);
		hash = HashCode.Mix(hash, (int)blend_dest_alpha);
		hash = HashCode.Mix(hash, (int)blend_op_alpha);
		return hash;
	}
}

enum ComparisonFunc { kNever, kLess, kEqual, kLessEqual, kGreater, kNotEqual, kGreaterEqual, kAlways }

enum StencilOp { kKeep, kZero, kReplace, kIncrSat, kDecrSat, kInvert, kIncr, kDecr }

struct StencilOpDesc : IEquatable<StencilOpDesc>, IHashable
{
	public StencilOp fail_op = StencilOp.kKeep;
	public StencilOp depth_fail_op = StencilOp.kKeep;
	public StencilOp pass_op = StencilOp.kKeep;
	public ComparisonFunc func = ComparisonFunc.kAlways;

	public bool Equals(StencilOpDesc other)
	{
		return fail_op == other.fail_op &&
			depth_fail_op == other.depth_fail_op &&
			pass_op == other.pass_op &&
			func == other.func;
	}

	public static bool operator ==(StencilOpDesc left, StencilOpDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(StencilOpDesc left, StencilOpDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = (int)fail_op;
		hash = HashCode.Mix(hash, (int)depth_fail_op);
		hash = HashCode.Mix(hash, (int)pass_op);
		hash = HashCode.Mix(hash, (int)func);
		return hash;
	}
}


struct DepthStencilDesc : IEquatable<DepthStencilDesc>, IHashable
{
	public bool depth_test_enable = true;
	public ComparisonFunc depth_func = ComparisonFunc.kLess;
	public bool depth_write_enable = true;
	public bool depth_bounds_test_enable = false;
	public bool stencil_enable = false;
	public uint8 stencil_read_mask = 0xff;
	public uint8 stencil_write_mask = 0xff;
	public StencilOpDesc front_face = .();
	public StencilOpDesc back_face = .();

	public bool Equals(DepthStencilDesc other)
	{
		return depth_test_enable == other.depth_test_enable &&
			depth_func == other.depth_func &&
			depth_write_enable == other.depth_write_enable &&
			depth_bounds_test_enable == other.depth_bounds_test_enable &&
			stencil_enable == other.stencil_enable &&
			stencil_read_mask == other.stencil_read_mask &&
			stencil_write_mask == other.stencil_write_mask &&
			front_face.Equals(other.front_face) &&
			back_face.Equals(other.back_face);
	}

	public static bool operator ==(DepthStencilDesc left, DepthStencilDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(DepthStencilDesc left, DepthStencilDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = depth_test_enable ? 1 : 0;
		hash = HashCode.Mix(hash, (int)depth_func);
		hash = HashCode.Mix(hash, depth_write_enable.GetHashCode());
		hash = HashCode.Mix(hash, depth_bounds_test_enable.GetHashCode());
		hash = HashCode.Mix(hash, stencil_enable.GetHashCode());
		hash = HashCode.Mix(hash, stencil_read_mask.GetHashCode());
		hash = HashCode.Mix(hash, stencil_write_mask.GetHashCode());
		hash = HashCode.Mix(hash, front_face.GetHashCode());
		hash = HashCode.Mix(hash, back_face.GetHashCode());
		return hash;
	}
}


enum ShaderType
{
	kUnknown,
	kVertex,
	kPixel,
	kCompute,
	kGeometry,
	kAmplification,
	kMesh,
	kLibrary,
}

struct ViewDesc : IEquatable<ViewDesc>, IHashable
{
	public ViewType view_type = ViewType.kUnknown;
	public ViewDimension dimension = ViewDimension.kUnknown;
	public uint32 base_mip_level = 0;
	public uint32 level_count = uint32(-1);
	public uint32 base_array_layer = 0;
	public uint32 layer_count = uint32(-1);
	public uint32 plane_slice = 0;
	public uint64 offset = 0;
	public uint32 structure_stride = 0;
	public uint64 buffer_size = uint64(-1);
	public Format buffer_format = Format.FORMAT_UNDEFINED;
	public bool bindless = false;

	public bool Equals(ViewDesc other)
	{
		return view_type == other.view_type &&
			dimension == other.dimension &&
			base_mip_level == other.base_mip_level &&
			level_count == other.level_count &&
			base_array_layer == other.base_array_layer &&
			layer_count == other.layer_count &&
			plane_slice == other.plane_slice &&
			offset == other.offset &&
			structure_stride == other.structure_stride &&
			buffer_size == other.buffer_size &&
			buffer_format == other.buffer_format &&
			bindless == other.bindless;
	}

	public static bool operator ==(ViewDesc left, ViewDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(ViewDesc left, ViewDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = (int)view_type;
		hash = HashCode.Mix(hash, (int)dimension);
		hash = HashCode.Mix(hash, base_mip_level.GetHashCode());
		hash = HashCode.Mix(hash, level_count.GetHashCode());
		hash = HashCode.Mix(hash, base_array_layer.GetHashCode());
		hash = HashCode.Mix(hash, layer_count.GetHashCode());
		hash = HashCode.Mix(hash, plane_slice.GetHashCode());
		hash = HashCode.Mix(hash, offset.GetHashCode());
		hash = HashCode.Mix(hash, structure_stride.GetHashCode());
		hash = HashCode.Mix(hash, buffer_size.GetHashCode());
		hash = HashCode.Mix(hash, (int)buffer_format);
		hash = HashCode.Mix(hash, bindless.GetHashCode());
		return hash;
	}
}


struct ShaderDesc
{
	public String shader_path;
	public String entrypoint;
	public ShaderType type;
	public String model;
	public Dictionary<String, String> define;

	public this()
	{
		this.shader_path = default;
		this.entrypoint = default;
		this.type = default;
		this.model = default;
		this.define = default;
	}

	public this(String shader_path, String entrypoint, ShaderType type, String model)
	{
		this.shader_path = shader_path;
		this.entrypoint = entrypoint;
		this.type = type;
		this.model = model;
		this.define = default;
	}
}

struct InputLayoutDesc : IEquatable<InputLayoutDesc>, IHashable
{
	public uint32 slot = 0;
	public String semantic_name;
	public Format format = Format.FORMAT_UNDEFINED;
	public uint32 stride = 0;

	public bool Equals(InputLayoutDesc other)
	{
		return slot == other.slot &&
			semantic_name == other.semantic_name &&
			format == other.format &&
			stride == other.stride;
	}

	public static bool operator ==(InputLayoutDesc left, InputLayoutDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(InputLayoutDesc left, InputLayoutDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = slot.GetHashCode();
		hash = HashCode.Mix(hash, semantic_name.GetHashCode());
		hash = HashCode.Mix(hash, (int)format);
		hash = HashCode.Mix(hash, stride.GetHashCode());
		return hash;
	}
}


enum RenderPassLoadOp
{
	kLoad,
	kClear,
	kDontCare,
}

enum RenderPassStoreOp
{
	kStore = 0,
	kDontCare,
}

struct RenderPassColorDesc : IEquatable<RenderPassColorDesc>, IHashable
{
	public Format format = Format.FORMAT_UNDEFINED;
	public RenderPassLoadOp load_op = RenderPassLoadOp.kLoad;
	public RenderPassStoreOp store_op = RenderPassStoreOp.kStore;

	public bool Equals(RenderPassColorDesc other)
	{
		return format == other.format &&
			load_op == other.load_op &&
			store_op == other.store_op;
	}

	public static bool operator ==(RenderPassColorDesc left, RenderPassColorDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(RenderPassColorDesc left, RenderPassColorDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = (int)format;
		hash = HashCode.Mix(hash, (int)load_op);
		hash = HashCode.Mix(hash, (int)store_op);
		return hash;
	}
}


public typealias RenderPassColorList = FixedList<RenderPassColorDesc, const 8>;

struct RenderPassDepthStencilDesc : IEquatable<RenderPassDepthStencilDesc>, IHashable
{
	public Format format = Format.FORMAT_UNDEFINED;
	public RenderPassLoadOp depth_load_op = RenderPassLoadOp.kLoad;
	public RenderPassStoreOp depth_store_op = RenderPassStoreOp.kStore;
	public RenderPassLoadOp stencil_load_op = RenderPassLoadOp.kLoad;
	public RenderPassStoreOp stencil_store_op = RenderPassStoreOp.kStore;

	public bool Equals(RenderPassDepthStencilDesc other)
	{
		return format == other.format &&
			depth_load_op == other.depth_load_op &&
			depth_store_op == other.depth_store_op &&
			stencil_load_op == other.stencil_load_op &&
			stencil_store_op == other.stencil_store_op;
	}

	public static bool operator ==(RenderPassDepthStencilDesc left, RenderPassDepthStencilDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(RenderPassDepthStencilDesc left, RenderPassDepthStencilDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = (int)format;
		hash = HashCode.Mix(hash, (int)depth_load_op);
		hash = HashCode.Mix(hash, (int)depth_store_op);
		hash = HashCode.Mix(hash, (int)stencil_load_op);
		hash = HashCode.Mix(hash, (int)stencil_store_op);
		return hash;
	}
}


struct RenderPassDesc : IEquatable<RenderPassDesc>, IHashable
{
	public RenderPassColorList colors = default;
	public RenderPassDepthStencilDesc depth_stencil = .();
	public Format shading_rate_format = Format.FORMAT_UNDEFINED;
	public uint32 sample_count = 1;

	public bool Equals(RenderPassDesc other)
	{
		return colors.Equals(other.colors) &&
			depth_stencil.Equals(other.depth_stencil) &&
			shading_rate_format == other.shading_rate_format &&
			sample_count == other.sample_count;
	}

	public static bool operator ==(RenderPassDesc left, RenderPassDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(RenderPassDesc left, RenderPassDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = colors.GetHashCode();
		hash = HashCode.Mix(hash, depth_stencil.GetHashCode());
		hash = HashCode.Mix(hash, (int)shading_rate_format);
		hash = HashCode.Mix(hash, sample_count.GetHashCode());
		return hash;
	}
}


public typealias FramebufferColorAttachmentList = FixedList<View, const 8>;

struct FramebufferDesc : IEquatable<FramebufferDesc>, IHashable
{
	public RenderPass render_pass = default;
	public uint32 width = default;
	public uint32 height = default;
	public FramebufferColorAttachmentList colors = default;
	public View depth_stencil = default;
	public View shading_rate_image = default;

	public bool Equals(FramebufferDesc other)
	{
		return render_pass == other.render_pass &&
			width == other.width &&
			height == other.height &&
			colors.Equals(other.colors) &&
			depth_stencil == other.depth_stencil &&
			shading_rate_image == other.shading_rate_image;
	}

	public static bool operator ==(FramebufferDesc left, FramebufferDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(FramebufferDesc left, FramebufferDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = HashCode.Generate(render_pass);
		hash = HashCode.Mix(hash, width.GetHashCode());
		hash = HashCode.Mix(hash, height.GetHashCode());
		hash = HashCode.Mix(hash, colors.GetHashCode());
		hash = HashCode.Mix(hash, HashCode.Generate(depth_stencil));
		hash = HashCode.Mix(hash, HashCode.Generate(shading_rate_image));
		return hash;
	}
}


struct GraphicsPipelineDesc : IEquatable<GraphicsPipelineDesc>, IHashable
{
	public ShaderProgram program;
	public BindingSetLayout layout;
	public List<InputLayoutDesc> input;
	public RenderPass render_pass;
	public DepthStencilDesc depth_stencil_desc;
	public BlendDesc blend_desc;
	public RasterizerDesc rasterizer_desc;

	public bool Equals(GraphicsPipelineDesc other)
	{
		return program == other.program &&
			layout == other.layout &&
			input.SequenceEqual(other.input) &&
			render_pass == other.render_pass &&
			depth_stencil_desc.Equals(other.depth_stencil_desc) &&
			blend_desc.Equals(other.blend_desc) &&
			rasterizer_desc.Equals(other.rasterizer_desc);
	}

	public static bool operator ==(GraphicsPipelineDesc left, GraphicsPipelineDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(GraphicsPipelineDesc left, GraphicsPipelineDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = HashCode.Generate(program);
		hash = HashCode.Mix(hash, HashCode.Generate(layout));
		for (var inputElement in input)
		{
			hash = HashCode.Mix(hash, inputElement.GetHashCode());
		}
		hash = HashCode.Mix(hash, HashCode.Generate(render_pass));
		hash = HashCode.Mix(hash, depth_stencil_desc.GetHashCode());
		hash = HashCode.Mix(hash, blend_desc.GetHashCode());
		hash = HashCode.Mix(hash, rasterizer_desc.GetHashCode());
		return hash;
	}
}


struct ComputePipelineDesc : IEquatable<ComputePipelineDesc>, IHashable
{
	public ShaderProgram program;
	public BindingSetLayout layout;

	public bool Equals(ComputePipelineDesc other)
	{
		return program == other.program &&
			layout == other.layout;
	}

	public static bool operator ==(ComputePipelineDesc left, ComputePipelineDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(ComputePipelineDesc left, ComputePipelineDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = HashCode.Generate(program);
		hash = HashCode.Mix(hash, HashCode.Generate(layout));
		return hash;
	}
}


enum RayTracingShaderGroupType
{
	kGeneral,
	kTrianglesHitGroup,
	kProceduralHitGroup,
}

struct RayTracingShaderGroup : IEquatable<RayTracingShaderGroup>, IHashable
{
	public RayTracingShaderGroupType type = RayTracingShaderGroupType.kGeneral;
	public uint64 general = 0;
	public uint64 closest_hit = 0;
	public uint64 any_hit = 0;
	public uint64 intersection = 0;

	public bool Equals(RayTracingShaderGroup other)
	{
		return type == other.type &&
			general == other.general &&
			closest_hit == other.closest_hit &&
			any_hit == other.any_hit &&
			intersection == other.intersection;
	}

	public static bool operator ==(RayTracingShaderGroup left, RayTracingShaderGroup right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(RayTracingShaderGroup left, RayTracingShaderGroup right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = (int)type;
		hash = HashCode.Mix(hash, general.GetHashCode());
		hash = HashCode.Mix(hash, closest_hit.GetHashCode());
		hash = HashCode.Mix(hash, any_hit.GetHashCode());
		hash = HashCode.Mix(hash, intersection.GetHashCode());
		return hash;
	}
}


struct RayTracingPipelineDesc : IEquatable<RayTracingPipelineDesc>, IHashable
{
	public ShaderProgram program;
	public BindingSetLayout layout;
	public List<RayTracingShaderGroup> groups;

	public bool Equals(RayTracingPipelineDesc other)
	{
		return program == other.program &&
			layout == other.layout &&
			groups.SequenceEqual(other.groups);
	}

	public static bool operator ==(RayTracingPipelineDesc left, RayTracingPipelineDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(RayTracingPipelineDesc left, RayTracingPipelineDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = HashCode.Generate(program);
		hash = HashCode.Mix(hash, HashCode.Generate(layout));
		for (var group in groups)
		{
			hash = HashCode.Mix(hash, group.GetHashCode());
		}
		return hash;
	}
}


struct RayTracingShaderTable : IEquatable<RayTracingShaderTable>, IHashable
{
	public Resource resource;
	public uint64 offset;
	public uint64 size;
	public uint64 stride;

	public bool Equals(RayTracingShaderTable other)
	{
		return resource == other.resource &&
			offset == other.offset &&
			size == other.size &&
			stride == other.stride;
	}

	public static bool operator ==(RayTracingShaderTable left, RayTracingShaderTable right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(RayTracingShaderTable left, RayTracingShaderTable right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = HashCode.Generate(resource);
		hash = HashCode.Mix(hash, offset.GetHashCode());
		hash = HashCode.Mix(hash, size.GetHashCode());
		hash = HashCode.Mix(hash, stride.GetHashCode());
		return hash;
	}
}


struct RayTracingShaderTables : IEquatable<RayTracingShaderTables>, IHashable
{
	public RayTracingShaderTable raygen;
	public RayTracingShaderTable miss;
	public RayTracingShaderTable hit;
	public RayTracingShaderTable callable;

	public bool Equals(RayTracingShaderTables other)
	{
		return raygen.Equals(other.raygen) &&
			miss.Equals(other.miss) &&
			hit.Equals(other.hit) &&
			callable.Equals(other.callable);
	}

	public static bool operator ==(RayTracingShaderTables left, RayTracingShaderTables right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(RayTracingShaderTables left, RayTracingShaderTables right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = raygen.GetHashCode();
		hash = HashCode.Mix(hash, miss.GetHashCode());
		hash = HashCode.Mix(hash, hit.GetHashCode());
		hash = HashCode.Mix(hash, callable.GetHashCode());
		return hash;
	}
}


struct BindKey : IEquatable<BindKey>, IHashable
{
	public ShaderType shader_type = ShaderType.kUnknown;
	public ViewType view_type = ViewType.kUnknown;
	public uint32 slot = 0;
	public uint32 space = 0;
	public uint32 count = 1;
	public uint32 remapped_slot = ~0;

	public uint32 GetRemappedSlot()
	{
		if (remapped_slot == ~0)
		{
			return slot;
		}
		return remapped_slot;
	}

	public bool Equals(BindKey other)
	{
		return shader_type == other.shader_type &&
			view_type == other.view_type &&
			slot == other.slot &&
			space == other.space &&
			count == other.count &&
			remapped_slot == other.remapped_slot;
	}

	public static bool operator ==(BindKey left, BindKey right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(BindKey left, BindKey right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = (int)shader_type;
		hash = HashCode.Mix(hash, (int)view_type);
		hash = HashCode.Mix(hash, slot.GetHashCode());
		hash = HashCode.Mix(hash, space.GetHashCode());
		hash = HashCode.Mix(hash, count.GetHashCode());
		hash = HashCode.Mix(hash, remapped_slot.GetHashCode());
		return hash;
	}
}


struct BindingDesc : IEquatable<BindingDesc>, IHashable
{
	public BindKey bind_key;
	public View view;

	public bool Equals(BindingDesc other)
	{
		return bind_key.Equals(other.bind_key) &&
			view == other.view;
	}

	public static bool operator ==(BindingDesc left, BindingDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(BindingDesc left, BindingDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = bind_key.GetHashCode();
		hash = HashCode.Mix(hash, HashCode.Generate(view));
		return hash;
	}
}


enum ReturnType
{
	kUnknown,
	kFloat,
	kUint,
	kInt,
	kDouble,
}

struct ResourceBindingDesc : IEquatable<ResourceBindingDesc>, IHashable
{
	public String name;
	public ViewType type;
	public uint32 slot;
	public uint32 space;
	public uint32 count;
	public ViewDimension dimension;
	public ReturnType return_type;
	public uint32 structure_stride;

	public bool Equals(ResourceBindingDesc other)
	{
		return name == other.name &&
			type == other.type &&
			slot == other.slot &&
			space == other.space &&
			count == other.count &&
			dimension == other.dimension &&
			return_type == other.return_type &&
			structure_stride == other.structure_stride;
	}

	public static bool operator ==(ResourceBindingDesc left, ResourceBindingDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(ResourceBindingDesc left, ResourceBindingDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = name.GetHashCode();
		hash = HashCode.Mix(hash, (int)type);
		hash = HashCode.Mix(hash, slot.GetHashCode());
		hash = HashCode.Mix(hash, space.GetHashCode());
		hash = HashCode.Mix(hash, count.GetHashCode());
		hash = HashCode.Mix(hash, (int)dimension);
		hash = HashCode.Mix(hash, (int)return_type);
		hash = HashCode.Mix(hash, structure_stride.GetHashCode());
		return hash;
	}
}


enum PipelineType
{
	kGraphics,
	kCompute,
	kRayTracing,
}

struct BufferDesc : IEquatable<BufferDesc>, IHashable
{
	public Resource res;
	public Format format = Format.FORMAT_UNDEFINED;
	public uint32 count = 0;
	public uint32 offset = 0;

	public bool Equals(BufferDesc other)
	{
		return res == other.res &&
			format == other.format &&
			count == other.count &&
			offset == other.offset;
	}

	public static bool operator ==(BufferDesc left, BufferDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(BufferDesc left, BufferDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = HashCode.Generate(res);
		hash = HashCode.Mix(hash, (int)format);
		hash = HashCode.Mix(hash, count.GetHashCode());
		hash = HashCode.Mix(hash, offset.GetHashCode());
		return hash;
	}
}


enum RaytracingInstanceFlags : uint32
{
	kNone = 0x0,
	kTriangleCullDisable = 0x1,
	kTriangleFrontCounterclockwise = 0x2,
	kForceOpaque = 0x4,
	kForceNonOpaque = 0x8
}

enum RaytracingGeometryFlags { kNone, kOpaque, kNoDuplicateAnyHitInvocation }

struct RaytracingGeometryDesc : IEquatable<RaytracingGeometryDesc>, IHashable
{
	public BufferDesc vertex;
	public BufferDesc index;
	public RaytracingGeometryFlags flags = RaytracingGeometryFlags.kNone;

	public bool Equals(RaytracingGeometryDesc other)
	{
		return vertex.Equals(other.vertex) &&
			index.Equals(other.index) &&
			flags == other.flags;
	}

	public static bool operator ==(RaytracingGeometryDesc left, RaytracingGeometryDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(RaytracingGeometryDesc left, RaytracingGeometryDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = vertex.GetHashCode();
		hash = HashCode.Mix(hash, index.GetHashCode());
		hash = HashCode.Mix(hash, (int)flags);
		return hash;
	}
}


enum MemoryType { kDefault, kUpload, kReadback }

struct TextureOffset : IEquatable<TextureOffset>, IHashable
{
	public int32 x;
	public int32 y;
	public int32 z;

	public bool Equals(TextureOffset other)
	{
		return x == other.x &&
			y == other.y &&
			z == other.z;
	}

	public static bool operator ==(TextureOffset left, TextureOffset right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(TextureOffset left, TextureOffset right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = x.GetHashCode();
		hash = HashCode.Mix(hash, y.GetHashCode());
		hash = HashCode.Mix(hash, z.GetHashCode());
		return hash;
	}
}


struct TextureExtent3D : IEquatable<TextureExtent3D>, IHashable
{
	public uint32 width;
	public uint32 height;
	public uint32 depth;

	public bool Equals(TextureExtent3D other)
	{
		return width == other.width &&
			height == other.height &&
			depth == other.depth;
	}

	public static bool operator ==(TextureExtent3D left, TextureExtent3D right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(TextureExtent3D left, TextureExtent3D right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = width.GetHashCode();
		hash = HashCode.Mix(hash, height.GetHashCode());
		hash = HashCode.Mix(hash, depth.GetHashCode());
		return hash;
	}
}

struct BufferToTextureCopyRegion : IEquatable<BufferToTextureCopyRegion>, IHashable
{
	public uint64 buffer_offset;
	public uint32 buffer_row_pitch;
	public uint32 texture_mip_level;
	public uint32 texture_array_layer;
	public TextureOffset texture_offset;
	public TextureExtent3D texture_extent;

	public bool Equals(BufferToTextureCopyRegion other)
	{
		return buffer_offset == other.buffer_offset &&
			buffer_row_pitch == other.buffer_row_pitch &&
			texture_mip_level == other.texture_mip_level &&
			texture_array_layer == other.texture_array_layer &&
			texture_offset.Equals(other.texture_offset) &&
			texture_extent.Equals(other.texture_extent);
	}

	public static bool operator ==(BufferToTextureCopyRegion left, BufferToTextureCopyRegion right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(BufferToTextureCopyRegion left, BufferToTextureCopyRegion right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = buffer_offset.GetHashCode();
		hash = HashCode.Mix(hash, buffer_row_pitch.GetHashCode());
		hash = HashCode.Mix(hash, texture_mip_level.GetHashCode());
		hash = HashCode.Mix(hash, texture_array_layer.GetHashCode());
		hash = HashCode.Mix(hash, texture_offset.GetHashCode());
		hash = HashCode.Mix(hash, texture_extent.GetHashCode());
		return hash;
	}
}

struct TextureCopyRegion : IEquatable<TextureCopyRegion>, IHashable
{
	public TextureExtent3D extent;
	public uint32 src_mip_level;
	public uint32 src_array_layer;
	public TextureOffset src_offset;
	public uint32 dst_mip_level;
	public uint32 dst_array_layer;
	public TextureOffset dst_offset;

	public bool Equals(TextureCopyRegion other)
	{
		return extent.Equals(other.extent) &&
			src_mip_level == other.src_mip_level &&
			src_array_layer == other.src_array_layer &&
			src_offset.Equals(other.src_offset) &&
			dst_mip_level == other.dst_mip_level &&
			dst_array_layer == other.dst_array_layer &&
			dst_offset.Equals(other.dst_offset);
	}

	public static bool operator ==(TextureCopyRegion left, TextureCopyRegion right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(TextureCopyRegion left, TextureCopyRegion right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = extent.GetHashCode();
		hash = HashCode.Mix(hash, src_mip_level.GetHashCode());
		hash = HashCode.Mix(hash, src_array_layer.GetHashCode());
		hash = HashCode.Mix(hash, src_offset.GetHashCode());
		hash = HashCode.Mix(hash, dst_mip_level.GetHashCode());
		hash = HashCode.Mix(hash, dst_array_layer.GetHashCode());
		hash = HashCode.Mix(hash, dst_offset.GetHashCode());
		return hash;
	}
}


struct BufferCopyRegion : IEquatable<BufferCopyRegion>, IHashable
{
	public uint64 src_offset;
	public uint64 dst_offset;
	public uint64 num_bytes;

	public bool Equals(BufferCopyRegion other)
	{
		return src_offset == other.src_offset &&
			dst_offset == other.dst_offset &&
			num_bytes == other.num_bytes;
	}

	public static bool operator ==(BufferCopyRegion left, BufferCopyRegion right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(BufferCopyRegion left, BufferCopyRegion right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = src_offset.GetHashCode();
		hash = HashCode.Mix(hash, dst_offset.GetHashCode());
		hash = HashCode.Mix(hash, num_bytes.GetHashCode());
		return hash;
	}
}

struct RaytracingGeometryInstance
{
	public Transform transform;
	/*public uint32 instance_id : 24;
	public uint32 instance_mask : 8;
	public uint32 instance_offset : 24;
	public RaytracingInstanceFlags flags : 8;*/
	[Bitfield<uint32>(.Public, .Bits(24), "instance_id")]
	[Bitfield<uint32>(.Public, .Bits(8), "instance_mask")]
	[Bitfield<uint32>(.Public, .Bits(24), "instance_offset")]
	[Bitfield<RaytracingInstanceFlags>(.Public, .Bits(8), "flags")]
	private uint64 instanceBits;
	public uint64 acceleration_structure_handle;
}

static
{
	[Comptime]
	private static void Asserts()
	{
		Compiler.Assert(sizeof(RaytracingGeometryInstance) == 64);
	}
}

struct ResourceBarrierDesc
{
	public Resource resource;
	public ResourceState state_before;
	public ResourceState state_after;
	public uint32 base_mip_level = 0;
	public uint32 level_count = 1;
	public uint32 base_array_layer = 0;
	public uint32 layer_count = 1;
}

enum ShadingRate : uint8
{
	k1x1 = 0,
	k1x2 = 0x1,
	k2x1 = 0x4,
	k2x2 = 0x5,
	k2x4 = 0x6,
	k4x2 = 0x9,
	k4x4 = 0xa,
}

enum ShadingRateCombiner
{
	kPassthrough = 0,
	kOverride = 1,
	kMin = 2,
	kMax = 3,
	kSum = 4,
}

struct RaytracingASPrebuildInfo
{
	public uint64 acceleration_structure_size = 0;
	public uint64 build_scratch_data_size = 0;
	public uint64 update_scratch_data_size = 0;
}

enum AccelerationStructureType
{
	kTopLevel,
	kBottomLevel,
}

enum CommandListType
{
	kGraphics,
	kCompute,
	kCopy,
}

public typealias ClearColorList = FixedList<Vector4, const 8>;

struct ClearDesc
{
	public ClearColorList colors;
	public float depth = 1.0f;
	public uint8 stencil = 0;
}

enum CopyAccelerationStructureMode
{
	kClone,
	kCompact,
}

enum BuildAccelerationStructureFlags
{
	kNone = 0,
	kAllowUpdate = 1 << 0,
	kAllowCompaction = 1 << 1,
	kPreferFastTrace = 1 << 2,
	kPreferFastBuild = 1 << 3,
	kMinimizeMemory = 1 << 4,
}

struct DrawIndirectCommand
{
	public uint32 vertex_count;
	public uint32 instance_count;
	public uint32 first_vertex;
	public uint32 first_instance;
}

struct DrawIndexedIndirectCommand
{
	public uint32 index_count;
	public uint32 instance_count;
	public uint32 first_index;
	public int32 vertex_offset;
	public uint32 first_instance;
}

struct DispatchIndirectCommand
{
	public uint32 thread_group_count_x;
	public uint32 thread_group_count_y;
	public uint32 thread_group_count_z;
}

public typealias IndirectCountType = uint32;

static
{
	public const uint64 kAccelerationStructureAlignment = 256;
}

enum QueryHeapType { kAccelerationStructureCompactedSize }


#region Shaders

enum ShaderKind
{
	kUnknown = 0,
	kPixel,
	kVertex,
	kGeometry,
	kCompute,
	kLibrary,
	kRayGeneration,
	kIntersection,
	kAnyHit,
	kClosestHit,
	kMiss,
	kCallable,
	kMesh,
	kAmplification,
}

enum VariableType
{
	kStruct,
	kFloat,
	kInt,
	kUint,
	kBool,
}

struct EntryPoint : IEquatable<EntryPoint>, IHashable
{
	public String name;
	public ShaderKind kind;
	public uint32 payload_size;
	public uint32 attribute_size;

	public bool Equals(EntryPoint other)
	{
		return name == other.name &&
			kind == other.kind &&
			payload_size == other.payload_size &&
			attribute_size == other.attribute_size;
	}

	public static bool operator ==(EntryPoint left, EntryPoint right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(EntryPoint left, EntryPoint right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = name.GetHashCode();
		hash = HashCode.Mix(hash, (int)kind);
		hash = HashCode.Mix(hash, payload_size.GetHashCode());
		hash = HashCode.Mix(hash, attribute_size.GetHashCode());
		return hash;
	}
}

struct InputParameterDesc : IEquatable<InputParameterDesc>, IHashable
{
	public uint32 location;
	public String semantic_name;
	public Format format;

	public bool Equals(InputParameterDesc other)
	{
		return location == other.location &&
			semantic_name == other.semantic_name &&
			format == other.format;
	}

	public static bool operator ==(InputParameterDesc left, InputParameterDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(InputParameterDesc left, InputParameterDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = location.GetHashCode();
		hash = HashCode.Mix(hash, semantic_name.GetHashCode());
		hash = HashCode.Mix(hash, (int)format);
		return hash;
	}
}

struct OutputParameterDesc : IEquatable<OutputParameterDesc>, IHashable
{
	public uint32 slot;

	public bool Equals(OutputParameterDesc other)
	{
		return slot == other.slot;
	}

	public static bool operator ==(OutputParameterDesc left, OutputParameterDesc right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(OutputParameterDesc left, OutputParameterDesc right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		return slot.GetHashCode();
	}
}

struct VariableLayout : IEquatable<VariableLayout>, IHashable
{
	public String name;
	public VariableType type;
	public uint32 offset;
	public uint32 size;
	public uint32 rows;
	public uint32 columns;
	public uint32 elements;
	public Span<VariableLayout> members;

	public bool Equals(VariableLayout other)
	{
		return name == other.name &&
			type == other.type &&
			offset == other.offset &&
			size == other.size &&
			rows == other.rows &&
			columns == other.columns &&
			elements == other.elements &&
			members.SequenceEqual(other.members);
	}

	public static bool operator ==(VariableLayout left, VariableLayout right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(VariableLayout left, VariableLayout right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = name.GetHashCode();
		hash = HashCode.Mix(hash, (int)type);
		hash = HashCode.Mix(hash, offset.GetHashCode());
		hash = HashCode.Mix(hash, size.GetHashCode());
		hash = HashCode.Mix(hash, rows.GetHashCode());
		hash = HashCode.Mix(hash, columns.GetHashCode());
		hash = HashCode.Mix(hash, elements.GetHashCode());
		for (var member in members)
		{
			hash = HashCode.Mix(hash, member.GetHashCode());
		}
		return hash;
	}
}

struct ShaderFeatureInfo : IEquatable<ShaderFeatureInfo>, IHashable
{
	public bool resource_descriptor_heap_indexing = false;
	public bool sampler_descriptor_heap_indexing = false;
	public uint32[3] numthreads = .();

	public bool Equals(ShaderFeatureInfo other)
	{
		return resource_descriptor_heap_indexing == other.resource_descriptor_heap_indexing &&
			sampler_descriptor_heap_indexing == other.sampler_descriptor_heap_indexing &&
			numthreads == other.numthreads;
	}

	public static bool operator ==(ShaderFeatureInfo left, ShaderFeatureInfo right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(ShaderFeatureInfo left, ShaderFeatureInfo right)
	{
		return !(left == right);
	}

	public int GetHashCode()
	{
		int hash = resource_descriptor_heap_indexing.GetHashCode();
		hash = HashCode.Mix(hash, sampler_descriptor_heap_indexing.GetHashCode());
		for (var thread in numthreads)
		{
			hash = HashCode.Mix(hash, thread.GetHashCode());
		}
		return hash;
	}
}


#endregion