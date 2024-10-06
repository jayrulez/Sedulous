namespace Sedulous.RHI;

/// <summary>
/// Specifies how a graphics resource will be mapped into CPU address space.
/// </summary>
public enum MapMode : uint8
{
	/// <summary>
	/// A read-only resource mapping. The mapped data region is not writable and cannot be used to transfer data into the graphics resource.
	/// </summary>
	Read,
	/// <summary>
	/// A write-only resource mapping. The mapped data region is writable and will be transferred to the graphics resource
	/// when <see cref="M:Sedulous.RHI.GraphicsContext.UnmapMemory(Sedulous.RHI.GraphicsResource,System.UInt32)" /> is called.
	/// </summary>
	Write,
	/// <summary>
	/// A read-write resource mapping. The mapped data region is both readable and writeable.
	/// </summary>
	ReadWrite
}
