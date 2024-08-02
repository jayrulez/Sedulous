using System;

namespace Sedulous.RHI;

/// <summary>
/// Describes a rasterizer state.
/// </summary>
public struct RasterizerStateDescription : IEquatable<RasterizerStateDescription>
{
	/// <summary>
	/// Determines the fill mode to use when rendering.
	/// </summary>
	public FillMode FillMode;

	/// <summary>
	/// Indicates triangles facing the specified direction are not drawn.
	/// </summary>
	public CullMode CullMode;

	/// <summary>
	/// Determines if a triangle is front- or back-facing. If this parameter is TRUE, a triangle will be considered front-facing
	/// if its vertices are counter-clockwise on the render target and considered back-facing if they are clockwise.
	/// If this parameter is FALSE, the opposite is true.
	/// </summary>
	public bool FrontCounterClockwise;

	/// <summary>
	/// Depth value added to a given pixel. For info about depth bias.
	/// </summary>
	public int32 DepthBias;

	/// <summary>
	/// Maximum depth bias of a pixel.
	/// </summary>
	public float DepthBiasClamp;

	/// <summary>
	/// Scalar on a given pixel's slope.
	/// </summary>
	public float SlopeScaledDepthBias;

	/// <summary>
	/// Enable clipping based on distance.
	/// </summary>
	public bool DepthClipEnable;

	/// <summary>
	/// Enable scissor-rectangle culling. All pixels outside an active scissor rectangle are culled.
	/// </summary>
	public bool ScissorEnable;

	/// <summary>
	/// Specifies whether to enable line antialiasing; only applies if doing line drawing and MultisampleEnable is FALSE.
	/// </summary>
	public bool AntialiasedLineEnable;

	/// <summary>
	/// Gets default values for RasterizerStateDescription.
	/// </summary>
	public static RasterizerStateDescription Default
	{
		get
		{
			RasterizerStateDescription defaultInstance = default(RasterizerStateDescription);
			defaultInstance.SetDefault();
			return defaultInstance;
		}
	}

	/// <summary>
	/// Default rasterizerstatedescription values.
	/// </summary>
	public void SetDefault() mut
	{
		FillMode = /*FillMode*/.Solid;
		CullMode = /*CullMode*/.Back;
		FrontCounterClockwise = false;
		DepthBias = 0;
		SlopeScaledDepthBias = 0f;
		DepthBiasClamp = 0f;
		DepthClipEnable = true;
		ScissorEnable = false;
		AntialiasedLineEnable = false;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(RasterizerStateDescription other)
	{
		if (FillMode == other.FillMode && CullMode == other.CullMode && FrontCounterClockwise == other.FrontCounterClockwise && DepthBias == other.DepthBias && DepthBiasClamp.Equals(other.DepthBiasClamp) && SlopeScaledDepthBias.Equals(other.SlopeScaledDepthBias) && DepthClipEnable == other.DepthClipEnable && ScissorEnable == other.ScissorEnable)
		{
			return AntialiasedLineEnable == other.AntialiasedLineEnable;
		}
		return false;
	}

	/// <summary>
	/// Determines whether the specified <see cref="T:System.Object" /> is equal to this instance.
	/// </summary>
	/// <param name="obj">The <see cref="T:System.Object" /> to compare with this instance.</param>
	/// <returns>
	///   <c>true</c> if the specified <see cref="T:System.Object" /> is equal to this instance; otherwise, <c>false</c>.
	/// </returns>
	public bool Equals(Object obj)
	{
		if (obj == null)
		{
			return false;
		}
		if (obj is RasterizerStateDescription)
		{
			return Equals((RasterizerStateDescription)obj);
		}
		return false;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public int GetHashCode()
	{
		CullMode cullMode;
		switch (CullMode)
		{
		case /*CullMode*/.Front:
			cullMode = (FrontCounterClockwise ? /*CullMode*/.Back : /*CullMode*/.Front);
			break;
		case /*CullMode*/.Back:
			cullMode = (FrontCounterClockwise ? /*CullMode*/.Front : /*CullMode*/.Back);
			break;
		case /*CullMode*/.None:
			cullMode = CullMode;
			break;
		default:
			cullMode = CullMode;
			break;
		}
		return (int32)(((((((((((((uint32)((int32)FillMode * 397) ^ (uint32)cullMode) * 397) ^ (uint32)DepthBias) * 397) ^ (uint32)DepthBiasClamp.GetHashCode()) * 397) ^ (uint32)SlopeScaledDepthBias.GetHashCode()) * 397) ^ (uint32)DepthClipEnable.GetHashCode()) * 397) ^ (uint32)ScissorEnable.GetHashCode()) * 397) ^ AntialiasedLineEnable.GetHashCode();
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(RasterizerStateDescription value1, RasterizerStateDescription value2)
	{
		return value1.Equals(value2);
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator !=(RasterizerStateDescription value1, RasterizerStateDescription value2)
	{
		return !value1.Equals(value2);
	}
}
