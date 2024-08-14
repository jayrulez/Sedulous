using System;
namespace Sedulous.GAL.MTL
{
    // A fake Texture object representing swapchain Textures.
    internal class MTLPlaceholderTexture : Texture
    {
        private uint32 _width;
        private uint32 _height;
        private bool _disposed;

        public override PixelFormat Format { get; protected set; }

        public override uint32 Width => _width;

        public override uint32 Height => _height;

        public override uint32 Depth => 1;

        public override uint32 MipLevels => 1;

        public override uint32 ArrayLayers => 1;

        public override TextureUsage Usage => TextureUsage.RenderTarget;

        public override TextureType Type => TextureType.Texture2D;

        public override TextureSampleCount SampleCount => TextureSampleCount.Count1;

        public override String Name { get; set; }

        public override bool IsDisposed => _disposed;

        public this(PixelFormat format)
        {
            Format = format;
        }

        public void Resize(uint32 width, uint32 height)
        {
            _width = width;
            _height = height;
        }

        protected override void DisposeCore()
        {
            _disposed = true;
        }
    }
}
