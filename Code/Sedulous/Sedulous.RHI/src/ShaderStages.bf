using System;

namespace Sedulous.RHI;

/// <summary>
/// Specifies the usage of a resource in shaders.
/// </summary>
//[Flags]
enum ShaderStages : int16
{
	/// <summary>
	/// No stages.
	/// </summary>
	Undefined = 0,
	/// <summary>
	/// The vertex shader stage.
	/// </summary>
	Vertex = 1,
	/// <summary>
	/// The hull shader stage.
	/// </summary>
	Hull = 2,
	/// <summary>
	/// The domain shader stage.
	/// </summary>
	Domain = 4,
	/// <summary>
	/// The geometry shader stage.
	/// </summary>
	Geometry = 8,
	/// <summary>
	/// The pixel shader stage.
	/// </summary>
	Pixel = 0x10,
	/// <summary>
	/// The compute shader stage.
	/// </summary>
	Compute = 0x20,
	/// <summary>
	/// The Raytracing raygeneration shader stage.
	/// </summary>
	RayGeneration = 0x40,
	/// <summary>
	/// The Raytracing miss shader stage.
	/// </summary>
	Miss = 0x80,
	/// <summary>
	/// The Raytracing closestHit shader stage.
	/// </summary>
	ClosestHit = 0x100,
	/// <summary>
	/// The Raytracing anyHit shader stage.
	/// </summary>
	AnyHit = 0x200,
	/// <summary>
	/// The Raytracing intersection shader stage.
	/// </summary>
	Intersection = 0x400
}
