namespace Sedulous.GPU;

using System;

abstract class Buffer { }
abstract class Program { }
abstract class Texture { }
abstract class Query { }
abstract class BindGroup { }

typealias BufferHandle = Buffer;
typealias ProgramHandle = Program;
typealias TextureHandle = Texture;
typealias QueryHandle = Query;
typealias BindGroupHandle = BindGroup;

static
{
	public const BufferHandle INVALID_BUFFER = null;
	public const ProgramHandle INVALID_PROGRAM = null;
	public const TextureHandle INVALID_TEXTURE = null;
	public const QueryHandle INVALID_QUERY = null;
	public const BindGroupHandle INVALID_BIND_GROUP = null;
}

enum InitFlags : uint32
{
	NONE = 0,
	DEBUG_OUTPUT = 1 << 0,
	VSYNC = 1 << 1
}

enum FramebufferFlags : uint32
{
	NONE = 0,
	SRGB = 1 << 0,
	READONLY_DEPTH_STENCIL = 1 << 1
}

enum StateFlags : uint64
{
	NONE = 0,
	WIREFRAME = 1 << 0,
	DEPTH_FN_GREATER = 1 << 1,
	DEPTH_FN_EQUAL = 1 << 2,
	DEPTH_FUNCTION = DEPTH_FN_GREATER | DEPTH_FN_EQUAL,
	CULL_FRONT = 1 << 3,
	CULL_BACK = 1 << 4,
	SCISSOR_TEST = 1 << 5,
	DEPTH_WRITE = 1 << 6,

	/* 16 bits reserved for blending*/
	/* 40 bits reserver for stencil*/
}

enum QueryType : uint32
{
	TIMESTAMP,
	STATS
}

enum MemoryBarrierType : uint32
{
	SSBO = 1 << 0,
	COMMAND = 1 << 1
}

enum PrimitiveType : uint8
{
	TRIANGLES,
	TRIANGLE_STRIP,
	LINES,
	POINTS,

	NONE
}

enum ShaderType : uint32
{
	VERTEX,
	FRAGMENT,
	GEOMETRY,
	COMPUTE
}


enum ClearFlags : uint32
{
	COLOR = 1 << 0,
	DEPTH = 1 << 1,
	STENCIL = 1 << 2,

	ALL = COLOR | DEPTH | STENCIL,
}


enum StencilFuncs : uint8
{
	DISABLE,
	ALWAYS,
	EQUAL,
	NOT_EQUAL,
}

enum StencilOps : uint8
{
	KEEP,
	ZERO,
	REPLACE,
	INCR,
	INCR_WRAP,
	DECR,
	DECR_WRAP,
	INVERT
}


enum BlendFactors : uint8
{
	ZERO,
	ONE,
	SRC_COLOR,
	ONE_MINUS_SRC_COLOR,
	SRC_ALPHA,
	ONE_MINUS_SRC_ALPHA,
	DST_COLOR,
	ONE_MINUS_DST_COLOR,
	DST_ALPHA,
	ONE_MINUS_DST_ALPHA,
	SRC1_COLOR,
	ONE_MINUS_SRC1_COLOR,
	SRC1_ALPHA,
	ONE_MINUS_SRC1_ALPHA,
}


enum AttributeType : uint8
{
	U8,
	FLOAT,
	I16,
	I8
}


// keep order, this is serialized
enum TextureFormat : uint32
{
	R8,
	RG8,
	D32,
	D24S8,
	RGBA8,
	RGBA16,
	RGBA16F,
	RGBA32F,
	BGRA8,
	R16F,
	R16,
	R32F,
	RG32F,
	SRGB,
	SRGBA,
	BC1,
	BC2,
	BC3,
	BC4,
	BC5,
	R11G11B10F,
	RGB32F,
	RG16,
	RG16F
}

enum BindShaderBufferFlags : uint32
{
	NONE = 0,
	OUTPUT = 1 << 0,
}

enum TextureFlags : uint32
{
	NONE = 0,
	POINT_FILTER = 1 << 0,
	CLAMP_U = 1 << 1,
	CLAMP_V = 1 << 2,
	CLAMP_W = 1 << 3,
	ANISOTROPIC_FILTER = 1 << 4,
	NO_MIPS = 1 << 5,
	SRGB = 1 << 6,
	READBACK = 1 << 7,
	IS_3D = 1 << 8,
	IS_CUBE = 1 << 9,
	COMPUTE_WRITE = 1 << 10,
	RENDER_TARGET = 1 << 11,
}

enum BufferFlags : uint32
{
	NONE = 0,
	IMMUTABLE = 1 << 0,
	UNIFORM_BUFFER = 1 << 1,
	SHADER_BUFFER = 1 << 2,
	COMPUTE_WRITE = 1 << 3,
	MAPPABLE = 1 << 4,
}

enum DataType : uint32
{
	U16,
	uint32
}

[Packed(1)]
struct VertexAttribute : IHashable
{
	public enum Flags
	{
		NORMALIZED = 1 << 0,
		AS_INT = 1 << 1,
		INSTANCED = 1 << 2
	};
	public uint8 components_count;
	public uint8 byte_offset;
	public AttributeType type;
	public uint8 flags;

	public int GetHashCode()
	{
		int hash = 0;

		hash = CombineHash(hash, components_count);
		hash = CombineHash(hash, byte_offset);
		hash = CombineHash(hash, (int)type);
		hash = CombineHash(hash, flags);

		return hash;
	}
}

static
{
	public static int CombineHash(int first, int second)
	{
		return (first * 397) ^ second;
	}
}

struct VertexDecl
{
	public const uint32 MAX_ATTRIBUTES = 16;

	public this(PrimitiveType pt)
	{
		primitive_type = pt;
		hash = (uint32)Hash(attributes, attributes_count) ^ (uint8)(primitive_type);
	}

	void addAttribute(uint8 byte_offset, uint8 components_num, AttributeType type, uint8 flags) mut
	{
		if (attributes_count >= attributes.Count)
		{
			Runtime.Assert(false);
			return;
		}

		ref VertexAttribute attr = ref attributes[attributes_count];
		attr.components_count = components_num;
		attr.flags = flags;
		attr.type = type;
		attr.byte_offset = byte_offset;
		++attributes_count;
		hash = (uint32)Hash(attributes, attributes_count) ^ (uint8)(primitive_type);
	}

	uint32 getStride()
	{
		uint32 stride = 0;
		for (uint32 i = 0; i < attributes_count; ++i)
		{
			stride += (uint32)(attributes[i].components_count * getSize(attributes[i].type));
		}
		return stride;
	}

	void computeHash()  mut
	{
		hash = (uint32)Hash(attributes, attributes_count) ^ (uint8)(primitive_type);
	}

	void setPrimitiveType(PrimitiveType type) mut
	{
		primitive_type = type;
		hash = (uint32)Hash(attributes, attributes_count) ^ (uint8)(primitive_type);
	}

	int32 getSize(AttributeType type)
	{
		switch (type) {
		case AttributeType.FLOAT: return 4;
		case AttributeType.I8: return 1;
		case AttributeType.U8: return 1;
		case AttributeType.I16: return 2;
		}
#unwarn
		Runtime.Assert(false);
		return 0;
	}

	uint32 getBytesPerPixel(TextureFormat format)
	{
		switch (format) {
		case TextureFormat.R8:
			return 1;

		case TextureFormat.R16F,TextureFormat.R16:
			return 2;
		case TextureFormat.SRGB:
			return 3;
		case TextureFormat.R11G11B10F,TextureFormat.R32F,TextureFormat.SRGBA,TextureFormat.RGBA8:
			return 4;
		case TextureFormat.RGBA16,TextureFormat.RGBA16F:
			return 8;
		case TextureFormat.RGBA32F:
			return 16;
		default:
			Runtime.Assert(false);
			return 0;
		}
	}

	private static int Hash(VertexAttribute[MAX_ATTRIBUTES] attributes, int32 count)
	{
		int hash = 0;
		for (int i = 0; i < count; i++)
		{
			hash = CombineHash(hash, attributes[i].GetHashCode());
		}
		return hash;
	}

	uint8 attributes_count = 0;
	uint32 hash;
	VertexAttribute[MAX_ATTRIBUTES] attributes = .();
	PrimitiveType primitive_type = PrimitiveType.NONE;
}


struct TextureDesc
{
	TextureFormat format;
	uint32 width;
	uint32 height;
	uint32 depth;
	uint32 mips;
	bool is_cubemap;
}


struct MemoryStats
{
	uint64 total_available_mem;
	uint64 current_available_mem;
	uint64 dedicated_vidmem;
	uint64 render_target_mem;
	uint64 buffer_mem;
	uint64 texture_mem;
}

struct BindGroupEntryDesc
{
	enum Type
	{
		UNIFORM_BUFFER,
		TEXTURE
	};
	Type type;
	[Union, CRepr]
	public struct Resource
	{
		BufferHandle buffer;
		TextureHandle texture;
	}
	public using private Resource resource;
	uint32 bind_point;
	uint32 offset;
	uint32 size;
}

abstract class Gpu
{
	public abstract bool init(void* window_handle, InitFlags flags);
	public abstract void shutdown();
	public abstract bool getMemoryStats(ref MemoryStats stats);
	public abstract uint32 swapBuffers();
	public abstract void waitFrame(uint32 frame);
	public abstract bool frameFinished(uint32 frame);
	public abstract bool isOriginBottomLeft();
	public abstract int getSize(AttributeType type);
	public abstract uint32 getSize(TextureFormat format, uint32 w, uint32 h);
	public abstract uint32 getBytesPerPixel(TextureFormat format);

	public abstract TextureHandle allocTextureHandle();
	public abstract BufferHandle allocBufferHandle();
	public abstract ProgramHandle allocProgramHandle();
	public abstract BindGroupHandle allocBindGroupHandle();

	public abstract QueryHandle createQuery(QueryType type);

	public abstract void createProgram(ProgramHandle prog, StateFlags state, in VertexDecl decl, char8** srcs, ShaderType* types, uint32 num, char8** prefixes, uint32 prefixes_count, char8* name);
	public abstract void createBuffer(BufferHandle handle, BufferFlags flags, uint size, void* data);
	public abstract void createTexture(TextureHandle handle, uint32 w, uint32 h, uint32 depth, TextureFormat format, TextureFlags flags, char8* debug_name);
	public abstract void createTextureView(TextureHandle view, TextureHandle texture, uint32 layer);
	public abstract void createBindGroup(BindGroupHandle group, Span<BindGroupEntryDesc> descs);

	public abstract void destroy(ref TextureHandle texture);
	public abstract void destroy(ref BufferHandle buffer);
	public abstract void destroy(ref ProgramHandle program);
	public abstract void destroy(ref BindGroupHandle group);
	public abstract void destroy(ref QueryHandle query);

	public abstract void setCurrentWindow(void* window_handle);
	public abstract void setFramebuffer(TextureHandle attachments, uint32 num, TextureHandle ds, FramebufferFlags flags);
	public abstract void setFramebufferCube(TextureHandle cube, uint32 face, uint32 mip);
	public abstract void viewport(uint32 x, uint32 y, uint32 w, uint32 h);
	public abstract void scissor(uint32 x, uint32 y, uint32 w, uint32 h);
	public abstract void clear(ClearFlags flags, float* color, float depth);

	public abstract void useProgram(ProgramHandle program);

	public abstract void bind(BindGroupHandle group);
	public abstract void bindIndexBuffer(BufferHandle buffer);
	public abstract void bindVertexBuffer(uint32 binding_idx, BufferHandle buffer, uint32 buffer_offset, uint32 stride);
	public abstract void bindTextures(TextureHandle* handles, uint32 offset, uint32 count);
	public abstract void bindUniformBuffer(uint32 ub_index, BufferHandle buffer, uint offset, uint size);
	public abstract void bindIndirectBuffer(BufferHandle buffer);
	public abstract void bindShaderBuffer(BufferHandle buffer, uint32 binding_idx, BindShaderBufferFlags flags);
	public abstract void bindImageTexture(TextureHandle texture, uint32 unit);

	public abstract void drawArrays(uint32 offset, uint32 count);
	public abstract void drawIndirect(DataType index_type, uint32 indirect_buffer_offset);
	public abstract void drawIndexed(uint32 offset, uint32 count, DataType type);
	public abstract void drawArraysInstanced(uint32 indices_count, uint32 instances_count);
	public abstract void drawIndexedInstanced(uint32 indices_count, uint32 instances_count, DataType index_type);
	public abstract void dispatch(uint32 num_groups_x, uint32 num_groups_y, uint32 num_groups_z);

	public abstract void memoryBarrier(MemoryBarrierType type, BufferHandle handle);

	public abstract void copy(TextureHandle dst, TextureHandle src, uint32 dst_x, uint32 dst_y);
	public abstract void copy(BufferHandle dst, BufferHandle src, uint32 dst_offset, uint32 src_offset, uint32 size);

	public abstract void readTexture(TextureHandle texture, uint32 mip, Span<uint8> buf);
	public abstract void generateMipmaps(TextureHandle texture);
	public abstract void setDebugName(TextureHandle texture, char8* debug_name);

	public abstract void update(TextureHandle texture, uint32 mip, uint32 x, uint32 y, uint32 z, uint32 w, uint32 h, TextureFormat format, void* buf, uint32 size);
	public abstract void update(BufferHandle buffer, void* data, uint size);

	public abstract void* map(BufferHandle buffer, uint size);
	public abstract void unmap(BufferHandle buffer);
	public abstract void queryTimestamp(QueryHandle query);

	public abstract void beginQuery(QueryHandle query);
	public abstract void endQuery(QueryHandle query);
	public abstract uint64 getQueryResult(QueryHandle query);
	public abstract uint64 getQueryFrequency();
	public abstract bool isQueryReady(QueryHandle query);

	public abstract void pushDebugGroup(char8* msg);
	public abstract void popDebugGroup();
}

static
{
	[Inline] public static StateFlags getBlendStateBits(BlendFactors src_rgb, BlendFactors dst_rgb, BlendFactors src_a, BlendFactors dst_a)
	{
		return (StateFlags)((((uint64)src_rgb & 15) << 7) | (((uint64)dst_rgb & 15) << 11) | (((uint64)src_a & 15) << 15) | (((uint64)dst_a & 15) << 19));
	}

	[Inline] public static StateFlags getStencilStateBits(uint8 write_mask, StencilFuncs func, uint8 @ref, uint8 mask, StencilOps sfail, StencilOps dpfail, StencilOps dppass)
	{
		return (StateFlags)(((uint64)write_mask << 23) | ((uint64)func << 31) | ((uint64)@ref << 35) | ((uint64)mask << 43) | ((uint64)sfail << 51) | ((uint64)dpfail << 55) | ((uint64)dppass << 59));
	}
}