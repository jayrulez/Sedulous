namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class DrawIndirectEntry : OpenGLCommandEntry
    {
        public DeviceBuffer IndirectBuffer;
        public uint32 Offset;
        public uint32 DrawCount;
        public uint32 Stride;

        public DrawIndirectEntry() { }

        public DrawIndirectEntry(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            IndirectBuffer = indirectBuffer;
            Offset = offset;
            DrawCount = drawCount;
            Stride = stride;
        }

        public DrawIndirectEntry Init(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            IndirectBuffer = indirectBuffer;
            Offset = offset;
            DrawCount = drawCount;
            Stride = stride;

            return this;
        }

        public override void ClearReferences()
        {
            IndirectBuffer = null;
        }
    }
}