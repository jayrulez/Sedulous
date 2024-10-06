namespace Sedulous.RHI;

/// <summary>
/// This class represents a query heap resource.
/// </summary>
public abstract class QueryHeap : GraphicsResource
{
	/// <summary>
	/// Gets the query heap description.
	/// </summary>
	public readonly QueryHeapDescription Description;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.QueryHeap" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The query heap description.</param>
	protected this(GraphicsContext context, in QueryHeapDescription description)
		: base(context)
	{
		Description = description;
	}

	/// <summary>
	/// Extracts data from one or more queries.
	/// </summary>
	/// <param name="startIndex">Specifies the index of the first query to read.</param>
	/// <param name="count">Specifies the number of queries to read.</param>
	/// <param name="results">ulong buffer with the extracted query data.</param>
	/// <returns>Returns true if all queries to read are available; false otherwise.</returns>
	/// <remarks>If the result is false, the results will contain the latest available results.</remarks>
	public abstract bool ReadData(uint32 startIndex, uint32 count, uint64[] results);
}
