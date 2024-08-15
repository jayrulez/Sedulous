namespace Sedulous.RAL;

static
{
	public static uint64 Align(uint64 size, uint64 alignment)
	{
		return (size + (alignment - 1)) & ~(alignment - 1);
	}
}