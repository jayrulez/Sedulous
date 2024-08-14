using System;
using Sedulous.MetalBindings;

namespace Sedulous.GAL.MTL
{
	using internal Sedulous.GAL;

    internal class MTLTextureView : TextureView
    {
        private readonly bool _hasTextureView;
        private bool _disposed;

        public Sedulous.MetalBindings.MTLTexture TargetDeviceTexture { get; }

        public override String Name { get; set; }

        public override bool IsDisposed => _disposed;

        public this(in TextureViewDescription description, MTLGraphicsDevice gd)
            : base(description)
        {
            Sedulous.GAL.MTL.MTLTexture targetMTLTexture = Util.AssertSubtype<Texture, Sedulous.GAL.MTL.MTLTexture>(description.Target);
            if (BaseMipLevel != 0 || MipLevels != Target.MipLevels
                || BaseArrayLayer != 0 || ArrayLayers != Target.ArrayLayers
                || Format != Target.Format)
            {
                _hasTextureView = true;
                var effectiveArrayLayers = Target.Usage.HasFlag(TextureUsage.Cubemap) ? ArrayLayers * 6 : ArrayLayers;
                TargetDeviceTexture = targetMTLTexture.DeviceTexture.newTextureView(
                    MTLFormats.VdToMTLPixelFormat(Format, (description.Target.Usage & TextureUsage.DepthStencil) != 0),
                    targetMTLTexture.MTLTextureType,
                    NSRange(BaseMipLevel, MipLevels),
                    NSRange(BaseArrayLayer, effectiveArrayLayers));
            }
            else
            {
                TargetDeviceTexture = targetMTLTexture.DeviceTexture;
            }
        }

        public override void Dispose()
        {
            if (_hasTextureView && !_disposed)
            {
                _disposed = true;
                ObjectiveCRuntime.release(TargetDeviceTexture.NativePtr);
            }
        }
    }
}
