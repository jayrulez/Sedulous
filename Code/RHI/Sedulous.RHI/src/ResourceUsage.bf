namespace Sedulous.RHI;

/// <summary>
/// Identifies the expected texture use during rendering.
/// </summary>
public enum ResourceUsage : uint8
{
	/// <summary>
	/// A resource that requires read and write access by the GPU. Default value.
	/// </summary>
	Default,
	/// <summary>
	/// A resource that can only be read by the GPU. It cannot be written by the GPU, and it cannot be accessed at all by the CPU.
	/// This type of resource must be initialized when it is created since it cannot be changed after creation.
	/// </summary>
	Immutable,
	/// <summary>
	/// A resource that is accessible by both the GPU (read-only) and the CPU (write-only).
	/// A dynamic resource is a good choice for a resource that will be updated by the CPU at least once per frame.
	/// </summary>
	Dynamic,
	/// <summary>
	/// A resource that supports data transfer (copying) from the GPU to the CPU.
	/// </summary>
	Staging
}
