namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class DispatchEntry : OpenGLCommandEntry
    {
        public uint32 GroupCountX;
        public uint32 GroupCountY;
        public uint32 GroupCountZ;

        public DispatchEntry() { }

        public DispatchEntry(uint32 groupCountX, uint32 groupCountY, uint32 groupCountZ)
        {
            GroupCountX = groupCountX;
            GroupCountY = groupCountY;
            GroupCountZ = groupCountZ;
        }

        public DispatchEntry Init(uint32 groupCountX, uint32 groupCountY, uint32 groupCountZ)
        {
            GroupCountX = groupCountX;
            GroupCountY = groupCountY;
            GroupCountZ = groupCountZ;

            return this;
        }

        public override void ClearReferences()
        {
        }
    }
}