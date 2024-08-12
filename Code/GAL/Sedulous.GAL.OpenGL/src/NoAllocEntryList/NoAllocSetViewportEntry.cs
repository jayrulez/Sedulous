namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocSetViewportEntry
    {
        public readonly uint32 Index;
        public Viewport Viewport;

        public NoAllocSetViewportEntry(uint32 index, ref Viewport viewport)
        {
            Index = index;
            Viewport = viewport;
        }
    }
}