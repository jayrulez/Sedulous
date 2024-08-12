namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocUpdateBufferEntry
    {
        public readonly Tracked<DeviceBuffer> Buffer;
        public readonly uint32 BufferOffsetInBytes;
        public readonly StagingBlock StagingBlock;
        public readonly uint32 StagingBlockSize;

        public NoAllocUpdateBufferEntry(Tracked<DeviceBuffer> buffer, uint32 bufferOffsetInBytes, StagingBlock stagingBlock, uint32 stagingBlockSize)
        {
            Buffer = buffer;
            BufferOffsetInBytes = bufferOffsetInBytes;
            StagingBlock = stagingBlock;
            StagingBlockSize = stagingBlockSize;
        }
    }
}