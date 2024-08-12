namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class SetViewportEntry : OpenGLCommandEntry
    {
        public uint32 Index;
        public Viewport Viewport;

        public SetViewportEntry(uint32 index, ref Viewport viewport)
        {
            Index = index;
            Viewport = viewport;
        }

        public SetViewportEntry() { }

        public SetViewportEntry Init(uint32 index, ref Viewport viewport)
        {
            Index = index;
            Viewport = viewport;
            return this;
        }

        public override void ClearReferences()
        {
        }
    }
}