namespace NRI;

interface Pipeline
{
	public void SetDebugName(char8* name);
	
	public Result WriteShaderGroupIdentifiers(uint32 baseShaderGroupIndex, uint32 shaderGroupNum, void* buffer); // TODO: add stride
}