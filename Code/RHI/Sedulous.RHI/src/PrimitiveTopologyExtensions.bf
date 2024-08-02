using System;

namespace Sedulous.RHI;

/// <summary>
/// Primitive topology extensions.
/// </summary>
public static class PrimitiveTopologyExtensions
{
	/// <summary>
	/// Interpret the vertex data as a patch list.
	/// </summary>
	/// <param name="topology">The primitive topology.</param>
	/// <param name="points">Number of control points. Valid range 1 - 32.</param>
	/// <returns>The result primitive topology.</returns>
	public static PrimitiveTopology ControlPoints(this PrimitiveTopology topology, int32 points)
	{
		if (topology != PrimitiveTopology.Patch_List)
		{
			Runtime.InvalidOperationError("Control points method apply only to PrimitiveTopology.Patch_List");
		}
		if (points < 1 || points > 32)
		{
			Runtime.ArgumentOutOfRangeError("Control points value must be in between 1 and 32");
		}
		return (PrimitiveTopology)(33 + points - 1);
	}
	/// <summary>
	/// Convert index count to primitive count.
	/// </summary>
	/// <param name="primitiveTopology">The primitive topology.</param>
	/// <param name="elementCount">The index count.</param>
	/// <returns>The primitive count.</returns>
	public static int32 ToPrimitiveCount(this PrimitiveTopology primitiveTopology, int32 elementCount)
	{
		switch (primitiveTopology)
		{
		case PrimitiveTopology.LineList:
			return elementCount / 2;
		case PrimitiveTopology.LineListWithAdjacency:
			return elementCount / 4;
		case PrimitiveTopology.LineStrip:
			return elementCount - 1;
		case PrimitiveTopology.LineStripWithAdjacency:
			return elementCount - 3;
		case PrimitiveTopology.TriangleList:
			return elementCount / 3;
		case PrimitiveTopology.TriangleListWithAdjacency:
			return elementCount / 6;
		case PrimitiveTopology.TriangleStrip:
			return elementCount - 2;
		case PrimitiveTopology.TriangleStripWithAdjacency:
			return (elementCount - 1) / 2;
		default:
			Runtime.InvalidOperationError(scope $"Primitive topology {primitiveTopology} not supported.");
		}
	}

	/// <summary>
	/// Convert primitive count to index count.
	/// </summary>
	/// <param name="primitiveTopology">The primitive topology.</param>
	/// <param name="primitiveCount">The primitive count.</param>
	/// <returns>The index count.</returns>
	public static int32 ToIndexCount(this PrimitiveTopology primitiveTopology, int32 primitiveCount)
	{
		switch (primitiveTopology)
		{
		case PrimitiveTopology.LineList:
			return primitiveCount * 2;
		case PrimitiveTopology.LineListWithAdjacency:
			return primitiveCount * 4;
		case PrimitiveTopology.LineStrip:
			return primitiveCount + 1;
		case PrimitiveTopology.LineStripWithAdjacency:
			return primitiveCount + 3;
		case PrimitiveTopology.TriangleList:
			return primitiveCount * 3;
		case PrimitiveTopology.TriangleListWithAdjacency:
			return primitiveCount * 6;
		case PrimitiveTopology.TriangleStrip:
			return primitiveCount + 2;
		case PrimitiveTopology.TriangleStripWithAdjacency:
			return primitiveCount * 2 + 1;
		default:
			Runtime.InvalidOperationError("Primitive topology {primitiveTopology} not supported.");
		}
	}
}
