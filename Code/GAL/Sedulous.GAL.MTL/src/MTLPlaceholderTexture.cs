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

        public override uint32 Width { get => _width; protected set {}};

        public override uint32 Height { get => _height; protected set {}};

        public override uint32 Depth { get => 1; protected set {}};

        public override uint32 MipLevels { get => 1; protected set {}};

        public override uint32 ArrayLayers { get => 1; protected set {}};

        public override TextureUsage Usage { get => TextureUsage.RenderTarget; protected set {}};

        public override TextureType Type { get => TextureType.Texture2D; protected set {}};

        public override TextureSampleCount SampleCount { get => TextureSampleCount.Count1; protected set {}};

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
