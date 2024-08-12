namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocDrawIndirectEntry
    {
        public Tracked<DeviceBuffer> IndirectBuffer;
        public uint32 Offset;
        public uint32 DrawCount;
        public uint32 Stride;

        public NoAllocDrawIndirectEntry(Tracked<DeviceBuffer> indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            IndirectBuffer = indirectBuffer;
            Offset = offset;
            DrawCount = drawCount;
            Stride = stride;
        }
    }
}