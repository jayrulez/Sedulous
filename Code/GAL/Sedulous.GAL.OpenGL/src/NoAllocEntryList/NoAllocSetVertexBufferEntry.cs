namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocSetVertexBufferEntry
    {
        public readonly uint32 Index;
        public readonly Tracked<DeviceBuffer> Buffer;
        public uint32 Offset;

        public NoAllocSetVertexBufferEntry(uint32 index, Tracked<DeviceBuffer> buffer, uint32 offset)
        {
            Index = index;
            Buffer = buffer;
            Offset = offset;
        }
    }
}
