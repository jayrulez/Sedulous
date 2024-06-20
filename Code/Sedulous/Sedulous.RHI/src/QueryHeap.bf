namespace Sedulous.RHI;

/// <summary>
/// This class represent a queryheap resource.
/// </summary>
abstract class QueryHeap : GraphicsResource
{
	/// <summary>
	/// Gets the queryheap description.
	/// </summary>
	public readonly QueryHeapDescription Description;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.QueryHeap" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The queryheap description.</param>
	protected this(GraphicsContext context, ref QueryHeapDescription description)
		: base(context)
	{
		Description = description;
	}

	/// <summary>
	/// Extract data from one or more queries.
	/// </summary>
	/// <param name="startIndex">Specifies the index of the fist query to read.</param>
	/// <param name="count">Specifies the number of queries to read.</param>
	/// <param name="results">uint64 buffer with the extracted queries data.</param>
	/// <returns>Return true if all queries to read are available and false if not.</returns>
	/// <remarks>If the result is false, the results will conttains the latest available results.</remarks>
	public abstract bool ReadData(uint32 startIndex, uint32 count, uint64[] results);
}
