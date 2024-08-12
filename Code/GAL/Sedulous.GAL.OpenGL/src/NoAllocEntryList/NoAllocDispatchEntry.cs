namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocDispatchEntry
    {
        public uint32 GroupCountX;
        public uint32 GroupCountY;
        public uint32 GroupCountZ;

        public NoAllocDispatchEntry(uint32 groupCountX, uint32 groupCountY, uint32 groupCountZ)
        {
            GroupCountX = groupCountX;
            GroupCountY = groupCountY;
            GroupCountZ = groupCountZ;
        }
    }
}