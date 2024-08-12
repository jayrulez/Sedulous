namespace Sedulous.GAL.OpenGL.ManagedEntryList
{
    internal class ClearColorTargetEntry : OpenGLCommandEntry
    {
        public uint32 Index;
        public RgbaFloat ClearColor;

        public ClearColorTargetEntry(uint32 index, RgbaFloat clearColor)
        {
            Index = index;
            ClearColor = clearColor;
        }

        public ClearColorTargetEntry() { }

        public ClearColorTargetEntry Init(uint32 index, RgbaFloat clearColor)
        {
            Index = index;
            ClearColor = clearColor;
            return this;
        }

        public override void ClearReferences()
        {
        }
    }
}