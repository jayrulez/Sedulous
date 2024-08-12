namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocClearDepthTargetEntry
    {
        public readonly float Depth;
        public readonly uint8 Stencil;

        public NoAllocClearDepthTargetEntry(float depth, uint8 stencil)
        {
            Depth = depth;
            Stencil = stencil;
        }
    }
}