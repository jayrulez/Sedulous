namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class DrawIndexedEntry : OpenGLCommandEntry
    {
        public uint32 IndexCount;
        public uint32 InstanceCount;
        public uint32 IndexStart;
        public int32 VertexOffset;
        public uint32 InstanceStart;

        public DrawIndexedEntry(uint32 indexCount, uint32 instanceCount, uint32 indexStart, int32 vertexOffset, uint32 instanceStart)
        {
            IndexCount = indexCount;
            InstanceCount = instanceCount;
            IndexStart = indexStart;
            VertexOffset = vertexOffset;
            InstanceStart = instanceStart;
        }

        public DrawIndexedEntry() { }

        public DrawIndexedEntry Init(uint32 indexCount, uint32 instanceCount, uint32 indexStart, int32 vertexOffset, uint32 instanceStart)
        {
            IndexCount = indexCount;
            InstanceCount = instanceCount;
            IndexStart = indexStart;
            VertexOffset = vertexOffset;
            InstanceStart = instanceStart;
            return this;
        }

        public override void ClearReferences()
        {
        }
    }
}