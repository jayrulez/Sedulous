namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocDispatchIndirectEntry
    {
        public Tracked<DeviceBuffer> IndirectBuffer;
        public uint32 Offset;

        public NoAllocDispatchIndirectEntry(Tracked<DeviceBuffer> indirectBuffer, uint32 offset)
        {
            IndirectBuffer = indirectBuffer;
            Offset = offset;
        }
    }
}