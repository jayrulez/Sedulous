namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class SetGraphicsResourceSetEntry : OpenGLCommandEntry
    {
        public uint32 Slot;
        public ResourceSet ResourceSet;

        public SetGraphicsResourceSetEntry(uint32 slot, ResourceSet rs)
        {
            Slot = slot;
            ResourceSet = rs;
        }

        public SetGraphicsResourceSetEntry() { }

        public SetGraphicsResourceSetEntry Init(uint32 slot, ResourceSet rs)
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