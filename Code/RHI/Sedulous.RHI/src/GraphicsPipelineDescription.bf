using System;

namespace Sedulous.RHI;

/// <summary>
/// Contains properties that describe the characteristics of a new pipeline state object.
/// </summary>
public struct GraphicsPipelineDescription : IEquatable<GraphicsPipelineDescription>
{
	/// <summary>
	/// The render state description.
	/// </summary>
	public RenderStateDescription RenderStates;

	/// <summary>
	/// The shader state description.
	/// </summary>
	public GraphicsShaderStateDescription Shaders;

	/// <summary>
	/// Describes the input vertex buffer data.
	/// </summary>
	public InputLayouts InputLayouts;

	/// <summary>
	/// Describes the resource layouts input array.
	/// </summary>
	public ResourceLayout[] ResourceLayouts;

	/// <summary>
	/// Define how vertices are interpreted and rendered by the pipeline.
	/// </summary>
	public PrimitiveTopology PrimitiveTopology;

	/// <summary>
	/// A description of the output attachments used by the <see cref="T:Sedulous.RHI.GraphicsPipelineState" />.
	/// </summary>
	public OutputDescription Outputs;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.GraphicsPipelineDescription" /> struct.
	/// </summary>
	/// <param name="primitiveTopology">Define how vertices are interpreted and rendered by the pipeline.</param>
	/// <param name="inputLayouts">Describes the input vertex buffer data.</param>
	/// <param name="resourceLayouts">The resource layouts array.</param>
	/// <param name="shaders">The shader state description.</param>
	/// <param name="renderStates">The render state description.</param>
	/// <param name="outputs">Description of the output attachments.</param>
	public this(PrimitiveTopology primitiveTopology, InputLayouts inputLayouts, ResourceLayout[] resourceLayouts, GraphicsShaderStateDescription shaders, RenderStateDescription renderStates, OutputDescription outputs)
	{
		PrimitiveTopology = primitiveTopology;
		InputLayouts = inputLayouts;
		ResourceLayouts = resourceLayouts;
		Shaders = shaders;
		RenderStates = renderStates;
		Outputs = outputs;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(GraphicsPipelineDescription other)
	{
		if (PrimitiveTopology != other.PrimitiveTopology || InputLayouts != other.InputLayouts || !ResourceLayouts.SequenceEqual(other.ResourceLayouts) || Shaders != other.Shaders || RenderStates != other.RenderStates || Outputs != other.Outputs)
		{
			return false;
		}
		return true;
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
		if (obj is GraphicsPipelineDescription)
		{
			return Equals((GraphicsPipelineDescription)obj);
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
		return ((((((((((int)PrimitiveTopology * 397) ^ InputLayouts.GetHashCode()) * 397) ^ HashCode.Generate(ResourceLayouts)) * 397) ^ Shaders.GetHashCode()) * 397) ^ RenderStates.GetHashCode()) * 397) ^ Outputs.GetHashCode();
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(GraphicsPipelineDescription value1, GraphicsPipelineDescription value2)
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
	public static bool operator !=(GraphicsPipelineDescription value1, GraphicsPipelineDescription value2)
	{
		return !value1.Equals(value2);
	}
}
