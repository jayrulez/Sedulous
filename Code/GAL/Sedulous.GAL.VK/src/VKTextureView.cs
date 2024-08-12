using Bulkan;
using System;
using static Sedulous.GAL.VK.VulkanUtil;
using static Bulkan.VulkanNative;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.VK;

    internal class VKTextureView : TextureView
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkImageView _imageView;
        private bool _destroyed;
        private String _name;

        public VkImageView ImageView => _imageView;

        public new VKTexture Target => (VKTexture)base.Target;

        internal ResourceRefCount RefCount { get; }

        public override bool IsDisposed => _destroyed;

        public this(VKGraphicsDevice gd, in TextureViewDescription description)
            : base(description)
        {
            _gd = gd;
            VkImageViewCreateInfo imageViewCI = VkImageViewCreateInfo.New();
            VKTexture tex = Util.AssertSubtype<Texture, VKTexture>(description.Target);
            imageViewCI.image = tex.OptimalDeviceImage;
            imageViewCI.format = VKFormats.VdToVkPixelFormat(Format, (Target.Usage & TextureUsage.DepthStencil) != 0);

            VkImageAspectFlags aspectFlags;
            if ((description.Target.Usage & TextureUsage.DepthStencil) == TextureUsage.DepthStencil)
            {
                aspectFlags = VkImageAspectFlags.Depth;
            }
            else
            {
                aspectFlags = VkImageAspectFlags.Color;
            }

            imageViewCI.subresourceRange = new VkImageSubresourceRange(
                aspectFlags,
                description.BaseMipLevel,
                description.MipLevels,
                description.BaseArrayLayer,
                description.ArrayLayers);

            if ((tex.Usage & TextureUsage.Cubemap) == TextureUsage.Cubemap)
            {
                imageViewCI.viewType = description.ArrayLayers == 1 ? VkImageViewType.ImageCube : VkImageViewType.ImageCubeArray;
                imageViewCI.subresourceRange.layerCount *= 6;
            }
            else
            {
                switch (tex.Type)
                {
                    case TextureType.Texture1D:
                        imageViewCI.viewType = description.ArrayLayers == 1
                            ? VkImageViewType.Image1D
                            : VkImageViewType.Image1DArray;
                        break;
                    case TextureType.Texture2D:
                        imageViewCI.viewType = description.ArrayLayers == 1
                            ? VkImageViewType.Image2D
                            : VkImageViewType.Image2DArray;
                        break;
                    case TextureType.Texture3D:
                        imageViewCI.viewType = VkImageViewType.Image3D;
                        break;
                }
            }

            vkCreateImageView(_gd.Device, &imageViewCI, null, &_imageView);
            RefCount = new ResourceRefCount(new => DisposeCore);
        }

        public override String Name
        {
            get => _name;
            set
            {
                _name = value;
                _gd.SetResourceName(this, value);
            }
        }

        public override void Dispose()
        {
            RefCount.Decrement();
        }

        private void DisposeCore()
        {
            if (!_destroyed)
            {
                _destroyed = true;
                vkDestroyImageView(_gd.Device, ImageView, null);
            }
        }
    }
}
