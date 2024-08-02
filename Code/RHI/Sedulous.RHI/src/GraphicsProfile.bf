namespace Sedulous.RHI;

/// <summary>
/// Identifies the set of device capabilities.
/// </summary>
public enum GraphicsProfile : uint8
{
	/// <summary>
	/// DirectX 9.1 HLSL 3.0 | OpenGL ES 2.0
	/// </summary>
	Level_9_1,
	/// <summary>
	/// DirectX 9.2 HLSL 3.0 | OpenGL ES 2.0
	/// </summary>
	Level_9_2,
	/// <summary>
	/// DirectX 9.3 HLSL 3.0 | OpenGL ES 2.0
	/// </summary>
	Level_9_3,
	/// <summary>
	/// DirectX 10 HLSL 4.0 | OpenGL ES 3.0
	/// (Default)
	/// </summary>
	Level_10_0,
	/// <summary>
	/// DirectX 10.1 HLSL 4.1 | OpenGL ES 3.0
	/// </summary>
	Level_10_1,
	/// <summary>
	/// DirectX 11 HLSL 5.0 | OpenGL ES 3.1 | OpenGL 4.0
	/// </summary>
	Level_11_0,
	/// <summary>
	/// DirectX 11 HLSL 5.0 | OpenGL ES 3.1 | OpenGL 4.0
	/// </summary>
	Level_11_1,
	/// <summary>
	/// DirectX 12 HLSL 6.0 | OpenGL 4.0
	/// </summary>
	Level_12_0,
	/// <summary>
	/// DirectX 12 HLSL 6.1 | OpenGL 4.0
	/// </summary>
	Level_12_1,
	/// <summary>
	/// DirectX12 HLSL 6.3 (Raytracing)
	/// </summary>
	Level_12_3
}
