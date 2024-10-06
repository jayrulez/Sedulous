namespace Sedulous.RHI;

/// <summary>
/// Represents the shader resource type.
/// </summary>
public enum ResourceType : uint8
{
	/// <summary>
	/// A <see cref="T:Sedulous.RHI.Buffer" /> accessed as a uniform buffer.
	/// </summary>
	ConstantBuffer,
	/// <summary>
	/// A <see cref="T:Sedulous.RHI.Buffer" /> accessed as a read-only storage buffer.
	/// </summary>
	StructuredBuffer,
	/// <summary>
	/// A <see cref="T:Sedulous.RHI.Buffer" /> accessed as a read-write storage buffer.
	/// </summary>
	StructuredBufferReadWrite,
	/// <summary>
	/// A read-only <see cref="T:Sedulous.RHI.Texture" />.
	/// </summary>
	Texture,
	/// <summary>
	/// A read-write <see cref="T:Sedulous.RHI.Texture" />.
	/// </summary>
	TextureReadWrite,
	/// <summary>
	/// A <see cref="T:Sedulous.RHI.SamplerState" />.
	/// </summary>
	Sampler,
	/// <summary>
	/// A ray tracing acceleration structure.
	/// </summary>
	AccelerationStructure
}
