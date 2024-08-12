namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocSetScissorRectEntry
    {
        public readonly uint32 Index;
        public readonly uint32 X;
        public readonly uint32 Y;
        public readonly uint32 Width;
        public readonly uint32 Height;

        public NoAllocSetScissorRectEntry(uint32 index, uint32 x, uint32 y, uint32 width, uint32 height)
        {
            Index = index;
            X = x;
            Y = y;
            Width = width;
            Height = height;
        }
    }
}