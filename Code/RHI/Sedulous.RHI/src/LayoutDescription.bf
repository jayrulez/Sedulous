using System;
using System.Collections;
using System.IO;

namespace Sedulous.RHI;

/// <summary>
/// A generic description of vertex inputs to the device's input assembler stage.
/// This object describes the inputs from a single vertex buffer.
/// </summary>
/// <remarks>Shaders may use inputs from multiple vertex buffers.</remarks>
public class LayoutDescription : IEquatable<LayoutDescription>
{
	/// <summary>
	/// The collection of individual vertex elements comprising a single vertex.
	/// </summary>
	public List<ElementDescription> Elements;

	/// <summary>
	/// The frequency with which the vertex function fetches attributes data.
	/// </summary>
	public VertexStepFunction StepFunction;

	/// <summary>
	/// A value controlling how often data for instances is advanced for this layout. For per-vertex elements, this value
	/// should be 0.
	/// </summary>
	public int32 StepRate;

	/// <summary>
	/// The total size of an individual vertex in bytes.
	/// </summary>
	public uint32 Stride;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.LayoutDescription" /> class.
	/// </summary>
	/// <param name="stepFunction">The frequency with which the vertex function fetches attributes data.</param>
	/// <param name="stepRate">The number of instances to draw using the same per-instance data before advancing in
	/// the buffer by one element. This value must be 0 for an element that contains per-vertex data.
	/// </param>
	public this(VertexStepFunction stepFunction = VertexStepFunction.PerVertexData, uint32 stepRate = 0)
	{
		StepFunction = stepFunction;
		StepRate = (int32)stepRate;
		Stride = 0;
		Elements = new List<ElementDescription>();
	}

	public ~this()
	{
		delete Elements;
	}

	/// <summary>
	/// Adds a new ElementDescription to layout.
	/// </summary>
	/// <param name="element">Element description.</param>
	/// <returns>My own instance.</returns>
	public LayoutDescription Add(ElementDescription element)
	{
		var element;
		if (element.Offset == -1)
		{
			element.Offset = (int32)Stride;
		}
		Elements.Add(element);
		Stride += GetFormatSizeInBytes(element.Format);
		return this;
	}

	/// <summary>
	/// Get the size in byte of a specific vertex element format.
	/// </summary>
	/// <param name="format">The vertex element formant.</param>
	/// <returns>The size in bytes.</returns>
	public static uint32 GetFormatSizeInBytes(ElementFormat format)
	{
		switch (format)
		{
		case ElementFormat.UByte,
			ElementFormat.Byte,
			ElementFormat.UByteNormalized,
			ElementFormat.ByteNormalized:
			return 1;
		case ElementFormat.UByte2,
			ElementFormat.Byte2,
			ElementFormat.UByte2Normalized,
			ElementFormat.Byte2Normalized,
			ElementFormat.UShort,
			ElementFormat.Short,
			ElementFormat.UShortNormalized,
			ElementFormat.ShortNormalized:
			return 2;
		case ElementFormat.UByte4,
			ElementFormat.Byte4,
			ElementFormat.UByte4Normalized,
			ElementFormat.Byte4Normalized,
			ElementFormat.UShort2,
			ElementFormat.Short2,
			ElementFormat.UShort2Normalized,
			ElementFormat.Short2Normalized,
			ElementFormat.Half2,
			ElementFormat.Float,
			ElementFormat.UInt,
			ElementFormat.Int:
			return 4;
		case ElementFormat.UShort4,
			ElementFormat.Short4,
			ElementFormat.UShort4Normalized,
			ElementFormat.Short4Normalized,
			ElementFormat.Half4,
			ElementFormat.Float2:
			return 8;
		case ElementFormat.Float3:
			return 12;
		case ElementFormat.Float4:
			return 16;
		default:
			Runtime.InvalidOperationError("VertexElementFormat doesn't supported.");
		}
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(LayoutDescription other)
	{
		if ((Object)other == null)
		{
			return false;
		}
		if ((Object)this == other)
		{
			return true;
		}
		if (Elements == null || other.Elements == null)
		{
			return Elements == other.Elements;
		}
		if (Elements.Count != other.Elements.Count)
		{
			return false;
		}
		for (int32 i = 0; i < Elements.Count; i++)
		{
			if (Elements[i] != other.Elements[i])
			{
				return false;
			}
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
		if (this == obj)
		{
			return true;
		}
		if (obj is LayoutDescription)
		{
			return Equals((LayoutDescription)obj);
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
		int hashCode = 19;
		for (int i = 0; i < Elements.Count; i++)
		{
			hashCode = (hashCode * 401) ^ Elements[i].GetHashCode();
		}
		return hashCode;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(LayoutDescription value1, LayoutDescription value2)
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
	public static bool operator !=(LayoutDescription value1, LayoutDescription value2)
	{
		return !value1.Equals(value2);
	}
}
