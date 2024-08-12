namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class DispatchIndirectEntry : OpenGLCommandEntry
    {
        public DeviceBuffer IndirectBuffer;
        public uint32 Offset;

        public DispatchIndirectEntry() { }

        public DispatchIndirectEntry(DeviceBuffer indirectBuffer, uint32 offset)
        {
            IndirectBuffer = indirectBuffer;
            Offset = offset;
        }

        public DispatchIndirectEntry Init(DeviceBuffer indirectBuffer, uint32 offset)
        {
            IndirectBuffer = indirectBuffer;
            Offset = offset;

            return this;
        }

        public override void ClearReferences()
        {
            IndirectBuffer = null;
        }
    }
}