namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class SetComputeResourceSetEntry : OpenGLCommandEntry
    {
        public uint32 Slot;
        public ResourceSet ResourceSet;

        public SetComputeResourceSetEntry(uint32 slot, ResourceSet rs)
        {
            Slot = slot;
            ResourceSet = rs;
        }

        public SetComputeResourceSetEntry() { }

        public SetComputeResourceSetEntry Init(uint32 slot, ResourceSet rs)
        {
            Slot = slot;
            ResourceSet = rs;
            return this;
        }

        public override void ClearReferences()
        {
            ResourceSet = null;
        }
    }
}