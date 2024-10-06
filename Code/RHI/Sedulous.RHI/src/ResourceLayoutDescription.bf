namespace Sedulous.RHI;

/// <summary>
/// This class describes the elements within a <see cref="T:Sedulous.RHI.ResourceLayout" />.
/// </summary>
public struct ResourceLayoutDescription
{
	/// <summary>
	/// The layout elements.
	/// </summary>
	public LayoutElementDescription[] Elements;

	/// <summary>
	/// The number of dynamic constant buffers.
	/// </summary>
	public int32 DynamicConstantBufferCount;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ResourceLayoutDescription" /> struct.
	/// </summary>
	/// <param name="elements">The element descriptions.</param>
	public this(params LayoutElementDescription[] elements)
	{
		Elements = elements;
		DynamicConstantBufferCount = 0;
		for (int32 i = 0; i < elements.Count; i++)
		{
			if (elements[i].AllowDynamicOffset)
			{
				DynamicConstantBufferCount++;
			}
		}
	}
}
