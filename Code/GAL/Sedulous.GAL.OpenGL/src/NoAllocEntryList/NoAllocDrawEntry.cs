namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocDrawEntry
    {
        public uint32 VertexCount;
        public uint32 InstanceCount;
        public uint32 VertexStart;
        public uint32 InstanceStart;

        public NoAllocDrawEntry(uint32 vertexCount, uint32 instanceCount, uint32 vertexStart, uint32 instanceStart)
        {
            VertexCount = vertexCount;
            InstanceCount = instanceCount;
            VertexStart = vertexStart;
            InstanceStart = instanceStart;
        }
    }
}