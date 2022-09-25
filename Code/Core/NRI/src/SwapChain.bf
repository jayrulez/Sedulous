namespace NRI;

interface SwapChain
{
	public void SetDebugName(char8* name);

	public Texture* GetTextures(ref uint32 textureNum, ref Format format);
	public uint32 AcquireNextTexture(ref QueueSemaphore textureReadyForRender);
	public Result Present(QueueSemaphore textureReadyForPresent);
	public Result SetHdrMetadata(HdrMetadata hdrMetadata);
}