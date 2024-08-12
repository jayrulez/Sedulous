namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocDrawIndexedEntry
    {
        public readonly uint32 IndexCount;
        public readonly uint32 InstanceCount;
        public readonly uint32 IndexStart;
        public readonly int32 VertexOffset;
        public readonly uint32 InstanceStart;

        public NoAllocDrawIndexedEntry(uint32 indexCount, uint32 instanceCount, uint32 indexStart, int32 vertexOffset, uint32 instanceStart)
        {
            IndexCount = indexCount;
            InstanceCount = instanceCount;
            IndexStart = indexStart;
            VertexOffset = vertexOffset;
            InstanceStart = instanceStart;
        }
    }
}