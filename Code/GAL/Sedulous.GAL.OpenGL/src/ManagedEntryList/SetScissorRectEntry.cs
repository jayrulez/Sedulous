namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class SetScissorRectEntry : OpenGLCommandEntry
    {
        public uint32 Index;
        public uint32 X;
        public uint32 Y;
        public uint32 Width;
        public uint32 Height;

        public SetScissorRectEntry(uint32 index, uint32 x, uint32 y, uint32 width, uint32 height)
        {
            Index = index;
            X = x;
            Y = y;
            Width = width;
            Height = height;
        }

        public SetScissorRectEntry() { }

        public SetScissorRectEntry Init(uint32 index, uint32 x, uint32 y, uint32 width, uint32 height)
        {
            Index = index;
            X = x;
            Y = y;
            Width = width;
            Height = height;
            return this;
        }

        public override void ClearReferences()
        {
        }
    }
}