namespace Sedulous.NRI;

interface QueryPool
{
	public void SetDebugName(char8* name);
	
	public uint32 GetQuerySize();
}