namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocCopyTextureEntry
    {
        public readonly Tracked<Texture> Source;
        public readonly uint32 SrcX;
        public readonly uint32 SrcY;
        public readonly uint32 SrcZ;
        public readonly uint32 SrcMipLevel;
        public readonly uint32 SrcBaseArrayLayer;
        public readonly Tracked<Texture> Destination;
        public readonly uint32 DstX;
        public readonly uint32 DstY;
        public readonly uint32 DstZ;
        public readonly uint32 DstMipLevel;
        public readonly uint32 DstBaseArrayLayer;
        public readonly uint32 Width;
        public readonly uint32 Height;
        public readonly uint32 Depth;
        public readonly uint32 LayerCount;

        public NoAllocCopyTextureEntry(
            Tracked<Texture> source,
            uint32 srcX, uint32 srcY, uint32 srcZ,
            uint32 srcMipLevel,
            uint32 srcBaseArrayLayer,
            Tracked<Texture> destination,
            uint32 dstX, uint32 dstY, uint32 dstZ,
            uint32 dstMipLevel,
            uint32 dstBaseArrayLayer,
            uint32 width, uint32 height, uint32 depth,
            uint32 layerCount)
        {
            Source = source;
            SrcX = srcX;
            SrcY = srcY;
            SrcZ = srcZ;
            SrcMipLevel = srcMipLevel;
            SrcBaseArrayLayer = srcBaseArrayLayer;
            Destination = destination;
            DstX = dstX;
            DstY = dstY;
            DstZ = dstZ;
            DstMipLevel = dstMipLevel;
            DstBaseArrayLayer = dstBaseArrayLayer;
            Width = width;
            Height = height;
            Depth = depth;
            LayerCount = layerCount;
        }
    }
}