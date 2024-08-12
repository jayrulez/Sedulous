namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocSetIndexBufferEntry
    {
        public readonly Tracked<DeviceBuffer> Buffer;
        public IndexFormat Format;
        public uint32 Offset;

        public NoAllocSetIndexBufferEntry(Tracked<DeviceBuffer> ib, IndexFormat format, uint32 offset)
        {
            Buffer = ib;
            Format = format;
            Offset = offset;
        }
    }
}
