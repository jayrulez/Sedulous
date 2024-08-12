namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocClearColorTargetEntry
    {
        public readonly uint32 Index;
        public readonly RgbaFloat ClearColor;

        public NoAllocClearColorTargetEntry(uint32 index, RgbaFloat clearColor)
        {
            Index = index;
            ClearColor = clearColor;
        }
    }
}