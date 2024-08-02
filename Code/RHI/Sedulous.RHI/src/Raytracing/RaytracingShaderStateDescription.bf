using System;

using Sedulous.RHI;
using System.Collections;
namespace Sedulous.RHI.Raytracing;

/// <summary>
/// This class contains all the raytracing shader stages.
/// </summary>
struct RaytracingShaderStateDescription : IEquatable<RaytracingShaderStateDescription>
{
	/// <summary>
	/// ConstantBuffers bindings.
	/// Used in OpenGL 410 or minor and OpenGLES 300 or minor.
	/// </summary>
	public List<(String name, uint32 slot)> constantBuffersBindings = null;

	/// <summary>
	/// Textures bindings.
	/// Used in OpenGL 410 or minor and OpenGLES 300 or minor.
	/// </summary>
	public List<(String name, uint32 slot)> texturesBindings = null;

	/// <summary>
	/// Uniform parameters bindings.
	/// Used in WebGL1 and OpenGL ES 2.0.
	/// </summary>
	public Dictionary<String, BufferParameterBinding> bufferParametersBinding = null;

	/// <summary>
	/// Gets or sets the Raygeneration shader program.
	/// </summary>
	public Shader RayGenerationShader;

	/// <summary>
	/// Gets or sets the closestHit shader program.
	/// </summary>
	public Shader[] ClosestHitShader;

	/// <summary>
	/// Gets or sets the Miss shader program.
	/// </summary>
	public Shader[] MissShader;

	/// <summary>
	/// Gets or sets the AnyHit shader program.
	/// </summary>
	public Shader[] AnyHitShader;

	/// <summary>
	/// Gets or sets the Intersection shader program.
	/// </summary>
	public Shader[] IntersectionShader;

	/// <inheritdoc />
	public bool Equals(RaytracingShaderStateDescription other)
	{
		if (RayGenerationShader != other.RayGenerationShader
			|| !ClosestHitShader.SequenceEqual(other.ClosestHitShader)
			|| !MissShader.SequenceEqual(other.MissShader)
			|| !AnyHitShader.SequenceEqual(other.AnyHitShader)
			|| !IntersectionShader.SequenceEqual(other.IntersectionShader))
		{
			return false;
		}
		return true;
	}

	/// <inheritdoc />
	public bool Equals(Object obj)
	{
		if (obj == null)
		{
			return false;
		}
		if (obj is RaytracingShaderStateDescription)
		{
			return Equals((RaytracingShaderStateDescription)obj);
		}
		return false;
	}

	/// <inheritdoc />
	public int GetHashCode()
	{
		int hashCode = 0;
		if (RayGenerationShader != null)
		{
			hashCode = (hashCode * 397) ^ RayGenerationShader.GetHashCode();
		}
		if (ClosestHitShader != null)
		{
			hashCode = (hashCode * 397) ^ ClosestHitShader.GetHashCode();
		}
		if (MissShader != null)
		{
			hashCode = (hashCode * 397) ^ MissShader.GetHashCode();
		}
		if (AnyHitShader != null)
		{
			hashCode = (hashCode * 397) ^ AnyHitShader.GetHashCode();
		}
		if (IntersectionShader != null)
		{
			hashCode = (hashCode * 397) ^ IntersectionShader.GetHashCode();
		}
		return hashCode;
	}

	/// <summary>
	/// Gets the entrypoint name from Shader stage index.
	/// </summary>
	/// <param name="stage">Shader Stage.</param>
	/// <returns>Entry point name.</returns>
	public void GetEntryPointByStage(ShaderStages stage, List<String> entryPoints)
	{
		Shader[] shaderArray;
		switch (stage)
		{
		case ShaderStages.RayGeneration:
			entryPoints.Add(RayGenerationShader.Description.EntryPoint);
			return;

		case ShaderStages.Miss:
			shaderArray = MissShader;
			break;

		case ShaderStages.ClosestHit:
			shaderArray = ClosestHitShader;
			break;

		case ShaderStages.AnyHit:
			shaderArray = AnyHitShader;
			break;

		case ShaderStages.Intersection:
			shaderArray = IntersectionShader;
			break;

		default:
			return;
		}
		entryPoints.Resize(shaderArray.Count);
		for (int i = 0; i < shaderArray.Count; i++)
		{
			entryPoints[i] = shaderArray[i].Description.EntryPoint;
		}
	}
}