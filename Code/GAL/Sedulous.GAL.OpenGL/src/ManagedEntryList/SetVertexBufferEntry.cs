namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class SetVertexBufferEntry : OpenGLCommandEntry
    {
        public uint32 Index;
        public DeviceBuffer Buffer;

        public SetVertexBufferEntry(uint32 index, DeviceBuffer buffer)
        {
            Index = index;
            Buffer = buffer;
        }

        public SetVertexBufferEntry() { }

        public SetVertexBufferEntry Init(uint32 index, DeviceBuffer buffer)
        {
            Index = index;
            Buffer = buffer;
            return this;
        }

        public override void ClearReferences()
        {
            Buffer = null;
        }
    }
}