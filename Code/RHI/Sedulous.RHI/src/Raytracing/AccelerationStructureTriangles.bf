namespace Sedulous.RHI.Raytracing;

/// <summary>
/// Acceleration structure triangle geometry.
/// </summary>
public class AccelerationStructureTriangles : AccelerationStructureGeometry
{
	/// <summary>
	/// Array of vertex indices. If null, triangles are non-indexed. As with graphics, the address must be aligned to the size
	/// of IndexFormat.
	/// </summary>
	public Buffer IndexBuffer;

	/// <summary>
	/// Format of the indices in the IndexBuffer. Must be one of the following:
	/// DXGI_FORMAT_UNKNOWN - when IndexBuffer is null
	/// DXGI_FORMAT_R32_UINT
	/// DXGI_FORMAT_R16_UINT.
	/// </summary>
	public IndexFormat IndexFormat;

	/// <summary>
	/// Number of indices in the IndexBuffer. Must be 0 if IndexBuffer is null.
	/// </summary>
	public uint32 IndexCount;

	/// <summary>
	/// Index offset in bytes.
	/// </summary>
	public uint32 IndexOffset;

	/// <summary>
	/// Array of vertices including a stride. The alignment on the address and stride must be a multiple of the component size,
	/// so 4 bytes for formats with 32-bit components and 2 bytes for formats with 16-bit components. Unlike graphics, there is no
	/// constraint on the stride, other than that the bottom 32 bits of the value are all that are used – the field is UINT64 purely
	/// to make neighboring fields align cleanly/obviously everywhere. Each vertex position is expected to be at the start address
	/// of the stride range, and any excess space is ignored by acceleration structure builds. This excess space might contain other
	/// app data such as vertex attributes, which the app is responsible for manually fetching in shaders, whether it is interleaved
	/// in vertex buffers or elsewhere.
	/// The memory pointed to must be in the state D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE. Note that if an app wants to share vertex
	/// buffer inputs between graphics input assembler and raytracing acceleration structure build input, it can always put a resource
	/// into a combination of read states simultaneously,
	/// e.g., D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER | D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE.
	/// </summary>
	public Buffer VertexBuffer;

	/// <summary>
	/// Format of the vertices in VertexBuffer. Must be one of the following:
	/// DXGI_FORMAT_R32G32_FLOAT - the third component is assumed to be 0
	/// DXGI_FORMAT_R32G32B32_FLOAT
	/// DXGI_FORMAT_R16G16_FLOAT - the third component is assumed to be 0
	/// DXGI_FORMAT_R16G16B16A16_FLOAT - the A16 component is ignored; other data can be packed there, such as by setting the vertex stride to 6 bytes.
	/// DXGI_FORMAT_R16G16_SNORM - the third component is assumed to be 0
	/// DXGI_FORMAT_R16G16B16A16_SNORM - the A16 component is ignored; other data can be packed there, such as by setting the vertex stride to 6 bytes.
	/// </summary>
	public PixelFormat VertexFormat;

	/// <summary>
	/// The vertex stride.
	/// </summary>
	public uint32 VertexStride;

	/// <summary>
	/// Number of vertices in the VertexBuffer.
	/// </summary>
	public uint32 VertexCount;

	/// <summary>
	/// Vertex offset in bytes.
	/// </summary>
	public uint32 VertexOffset;
}
