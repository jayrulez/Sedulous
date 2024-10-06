using System;
using System.Collections;
using System.IO;

namespace Sedulous.RHI;

/// <summary>
/// This class contains the descriptions of vertex input layout.
/// </summary>
public class InputLayouts : IEquatable<InputLayouts>
{
	private int32[] elementsCache;

	private bool isDirty = true;

	/// <summary>
	/// The vertex input elements.
	/// </summary>
	public List<LayoutDescription> LayoutElements;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.InputLayouts" /> class.
	/// </summary>
	public this()
	{
		LayoutElements = new List<LayoutDescription>();
	}

	public ~this()
	{
		delete LayoutElements;
	}

	/// <summary>
	/// Tries to get the attribute slot by semantic and semantic index.
	/// </summary>
	/// <param name="semantic">Attribute semantic type.</param>
	/// <param name="semanticIndex">Attribute semantic index.</param>
	/// <param name="slot">Attribute slot.</param>
	/// <returns>True if the attribute is found; false otherwise.</returns>
	public bool TryGetSlot(ElementSemanticType semantic, uint32 semanticIndex, out int32 slot)
	{
		slot = 0;
		List<ElementDescription> elements = LayoutElements[0].Elements;
		for (int i = 0; i < elements.Count; i++)
		{
			ElementDescription element = elements[i];
			if (element.Semantic == semantic && element.SemanticIndex == semanticIndex)
			{
				slot = (int32)i;
				return true;
			}
		}
		return false;
	}

	/// <summary>
	/// Finds a layout element description by its usage semantic.
	/// </summary>
	/// <param name="semantic">The element semantic.</param>
	/// <param name="semanticIndex">The semantic index.</param>
	/// <param name="elementDescription">The element description.</param>
	/// <param name="vertexBufferIndex">The vertex buffer index.</param>
	/// <returns>True if the input layout contains an element with the specified semantic and index. False otherwise.</returns>
	public bool FindLayoutElementByUsage(ElementSemanticType semantic, int32 semanticIndex, out ElementDescription elementDescription, out int32 vertexBufferIndex)
	{
		for (int i = 0; i < LayoutElements.Count; i++)
		{
			LayoutDescription layoutDescription = LayoutElements[i];
			for (int j = 0; j < layoutDescription.Elements.Count; j++)
			{
				ElementDescription element = layoutDescription.Elements[j];
				if (element.Semantic == semantic && element.SemanticIndex == (uint32)semanticIndex)
				{
					elementDescription = element;
					vertexBufferIndex = (int32)i;
					return true;
				}
			}
		}
		elementDescription = default(ElementDescription);
		vertexBufferIndex = 0;
		return false;
	}

	/// <summary>
	/// Adds a new layout.
	/// </summary>
	/// <param name="layout">Layout description.</param>
	/// <returns>My own instance.</returns>
	public InputLayouts Add(LayoutDescription layout)
	{
		if (layout != null)
		{
			LayoutElements.Add(layout);
		}
		isDirty = true;
		return this;
	}

	/// <summary>
	/// Determines if the current layout is assignable to the parameter input layout.
	/// </summary>
	/// <param name="inputLayouts">The input layouts.</param>
	/// <returns>Whether the specified layout is compatible.</returns>
	public bool IsAssignable(InputLayouts inputLayouts)
	{
		UpdateCache();
		if (inputLayouts != null)
		{
			inputLayouts.UpdateCache();
			for (int i = 0; i < inputLayouts.elementsCache.Count; i++)
			{
				if (inputLayouts.elementsCache[i] > elementsCache[i])
				{
					return false;
				}
			}
		}
		return true;
	}

	/// <summary>
	/// Cleans the object.
	/// </summary>
	public void Clean()
	{
		LayoutElements.Clear();
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Used for comparison.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(InputLayouts other)
	{
		if ((Object)other == null)
		{
			return false;
		}
		if ((Object)this == other)
		{
			return true;
		}
		if (LayoutElements == null || other.LayoutElements == null)
		{
			return LayoutElements == other.LayoutElements;
		}
		if (LayoutElements.Count != other.LayoutElements.Count)
		{
			return false;
		}
		for (int i = 0; i < LayoutElements.Count; i++)
		{
			if (LayoutElements[i] != other.LayoutElements[i])
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
		if (obj.GetType() != GetType())
		{
			return false;
		}
		if (obj is InputLayouts)
		{
			return Equals((InputLayouts)obj);
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
		int hashCode = 421;
		for (int i = 0; i < LayoutElements.Count; i++)
		{
			hashCode = (hashCode * 419) ^ LayoutElements[i].GetHashCode();
		}
		return hashCode;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(InputLayouts value1, InputLayouts value2)
	{
		if ((Object)value1 == value2)
		{
			return true;
		}
		return value1?.Equals(value2) ?? false;
	}

	/// <summary>
	/// Implements the == operator.
	/// </summary>
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator !=(InputLayouts value1, InputLayouts value2)
	{
		return !(value1 == value2);
	}

	private void UpdateCache()
	{
		if (!isDirty)
		{
			return;
		}
		elementsCache = new int32[8];
		for (int i = 0; i < elementsCache.Count; i++)
		{
			elementsCache[i] = -1;
		}
		for (int i = 0; i < LayoutElements.Count; i++)
		{
			LayoutDescription layoutDescription = LayoutElements[i];
			for (int j = 0; j < layoutDescription.Elements.Count; j++)
			{
				ElementDescription element = layoutDescription.Elements[j];
				int32 semanticId = (int32)element.Semantic;
				elementsCache[semanticId] = Math.Max(elementsCache[semanticId], (int32)element.SemanticIndex);
			}
		}
		isDirty = false;
	}
}
