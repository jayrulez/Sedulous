namespace Sedulous.RHI;

/// <summary>
/// The specify graphics low level API used by the <see cref="T:Sedulous.RHI.GraphicsContext" />.
/// </summary>
enum GraphicsBackend : uint8
{
	/// <summary>
	/// DirectX 11
	/// </summary>
	DirectX11,
	/// <summary>
	/// DirectX 12
	/// </summary>
	DirectX12,
	/// <summary>
	/// OpenGL 4
	/// </summary>
	OpenGL,
	/// <summary>
	///  OpenGL ES 3.0
	/// </summary>
	OpenGLES,
	/// <summary>
	/// Metal 2.0
	/// </summary>
	Metal,
	/// <summary>
	/// Vulkan 1.1
	/// </summary>
	Vulkan,
	/// <summary>
	/// WebGL 1.0
	/// </summary>
	WebGL1,
	/// <summary>
	/// WebGL 2.0
	/// </summary>
	WebGL2,
	/// <summary>
	/// WebGPU 1.0
	/// </summary>
	WebGPU
}
