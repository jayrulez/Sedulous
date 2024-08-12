namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class DrawIndexedIndirectEntry : OpenGLCommandEntry
    {
        public DeviceBuffer IndirectBuffer;
        public uint32 Offset;
        public uint32 DrawCount;
        public uint32 Stride;

        public DrawIndexedIndirectEntry() { }

        public DrawIndexedIndirectEntry(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            IndirectBuffer = indirectBuffer;
            Offset = offset;
            DrawCount = drawCount;
            Stride = stride;
        }

        public DrawIndexedIndirectEntry Init(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
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