using System;

namespace Sedulous.RHI;

/// <summary>
/// Identifies how to bind a buffer.
/// </summary>
public enum BufferFlags
{
	/// <summary>
	/// No options.
	/// </summary>
	None = 0,
	/// <summary>
	/// Binds a buffer as a vertex buffer to the input-assembler stage.
	/// </summary>
	VertexBuffer = 1,
	/// <summary>
	/// Binds a buffer as an index buffer to the input-assembler stage.
	/// </summary>
	IndexBuffer = 2,
	/// <summary>
	/// Binds a buffer as a constant buffer to a shader stage. This flag may NOT be combined with any other bind flag.
	/// </summary>
	ConstantBuffer = 4,
	/// <summary>
	/// Binds a buffer or texture to a shader stage.
	/// </summary>
	ShaderResource = 8,
	/// <summary>
	/// Binds a buffer to be used in a raytracing stage.
	/// </summary>
	AccelerationStructure = 0x10,
	/// <summary>
	/// Binds a texture as a render target for the output-merger stage.
	/// </summary>
	RenderTarget = 0x20,
	/// <summary>
	/// Binds an unordered access resource.
	/// </summary>
	UnorderedAccess = 0x40,
	/// <summary>
	/// Enables a resource as a structured buffer.
	/// </summary>
	BufferStructured = 0x80,
	/// <summary>
	/// Indirect buffer.
	/// </summary>
	IndirectBuffer = 0x100
}
