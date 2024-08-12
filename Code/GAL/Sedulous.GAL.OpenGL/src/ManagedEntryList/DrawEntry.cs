namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class DrawEntry : OpenGLCommandEntry
    {
        public uint32 VertexCount;
        public uint32 InstanceCount;
        public uint32 VertexStart;
        public uint32 InstanceStart;

        public DrawEntry() { }

        public DrawEntry(uint32 vertexCount, uint32 instanceCount, uint32 vertexStart, uint32 instanceStart)
        {
            VertexCount = vertexCount;
            InstanceCount = instanceCount;
            VertexStart = vertexStart;
            InstanceStart = instanceStart;
        }

        public DrawEntry Init(uint32 vertexCount, uint32 instanceCount, uint32 vertexStart, uint32 instanceStart)
        {
            VertexCount = vertexCount;
            InstanceCount = instanceCount;
            VertexStart = vertexStart;
            InstanceStart = instanceStart;

            return this;
        }

        public override void ClearReferences()
        {
        }
    }
}