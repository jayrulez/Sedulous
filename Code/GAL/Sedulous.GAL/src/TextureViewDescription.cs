using System;

namespace Sedulous.GAL
{
    /// <summary>
    /// Describes a <see cref="TextureView"/>, for creation using a <see cref="ResourceFactory"/>.
    /// </summary>
    public struct TextureViewDescription : IEquatable<TextureViewDescription>, IHashable
    {
        /// <summary>
        /// The desired target <see cref="Texture"/>.
        /// </summary>
        public Texture Target;
        /// <summary>
        /// The base mip level visible in the view. Must be less than <see cref="Texture.MipLevels"/>.
        /// </summary>
        public uint32 BaseMipLevel;
        /// <summary>
        /// The number of mip levels visible in the view.
        /// </summary>
        public uint32 MipLevels;
        /// <summary>
        /// The base array layer visible in the view.
        /// </summary>
        public uint32 BaseArrayLayer;
        /// <summary>
        /// The number of array layers visible in the view.
        /// </summary>
        public uint32 ArrayLayers;
        /// <summary>
        /// An optional <see cref="PixelFormat"/> which specifies how the data within <see cref="Target"/> will be viewed.
        /// If this value is null, then the created TextureView will use the same <see cref="PixelFormat"/> as the target
        /// <see cref="Texture"/>. If not null, this format must be "compatible" with the target Texture's. For uncompressed
        /// formats, the overall size and number of components in this format must be equal to the underlying format. For
        /// compressed formats, it is only possible to use the same PixelFormat or its sRGB/non-sRGB counterpart.
        /// </summary>
        public PixelFormat? Format;

        /// <summary>
        /// Constructs a new TextureViewDescription.
        /// </summary>
        /// <param name="target">The desired target <see cref="Texture"/>. This <see cref="Texture"/> must have been created
        /// with the <see cref="TextureUsage.Sampled"/> usage flag.</param>
        public this(Texture target)
        {
            Target = target;
            BaseMipLevel = 0;
            MipLevels = target.MipLevels;
            BaseArrayLayer = 0;
            ArrayLayers = target.ArrayLayers;
            Format = target.Format;
        }

        /// <summary>
        /// Constructs a new TextureViewDescription.
        /// </summary>
        /// <param name="target">The desired target <see cref="Texture"/>. This <see cref="Texture"/> must have been created
        /// with the <see cref="TextureUsage.Sampled"/> usage flag.</param>
        /// <param name="format">Specifies how the data within the target Texture will be viewed.
        /// This format must be "compatible" with the target Texture's. For uncompressed formats, the overall size and number of
        /// components in this format must be equal to the underlying format. For compressed formats, it is only possible to use
        /// the same PixelFormat or its sRGB/non-sRGB counterpart.</param>
        public this(Texture target, PixelFormat format)
        {
            Target = target;
            BaseMipLevel = 0;
            MipLevels = target.MipLevels;
            BaseArrayLayer = 0;
            ArrayLayers = target.ArrayLayers;
            Format = format;
        }

        /// <summary>
        /// Constructs a new TextureViewDescription.
        /// </summary>
        /// <param name="target">The desired target <see cref="Texture"/>.</param>
        /// <param name="baseMipLevel">The base mip level visible in the view. Must be less than <see cref="Texture.MipLevels"/>.
        /// </param>
        /// <param name="mipLevels">The number of mip levels visible in the view.</param>
        /// <param name="baseArrayLayer">The base array layer visible in the view.</param>
        /// <param name="arrayLayers">The number of array layers visible in the view.</param>
        public this(Texture target, uint32 baseMipLevel, uint32 mipLevels, uint32 baseArrayLayer, uint32 arrayLayers)
        {
            Target = target;
            BaseMipLevel = baseMipLevel;
            MipLevels = mipLevels;
            BaseArrayLayer = baseArrayLayer;
            ArrayLayers = arrayLayers;
            Format = target.Format;
        }

        /// <summary>
        /// Constructs a new TextureViewDescription.
        /// </summary>
        /// <param name="target">The desired target <see cref="Texture"/>.</param>
        /// <param name="format">Specifies how the data within the target Texture will be viewed.
        /// This format must be "compatible" with the target Texture's. For uncompressed formats, the overall size and number of
        /// components in this format must be equal to the underlying format. For compressed formats, it is only possible to use
        /// the same PixelFormat or its sRGB/non-sRGB counterpart.</param>
        /// <param name="baseMipLevel">The base mip level visible in the view. Must be less than <see cref="Texture.MipLevels"/>.
        /// </param>
        /// <param name="mipLevels">The number of mip levels visible in the view.</param>
        /// <param name="baseArrayLayer">The base array layer visible in the view.</param>
        /// <param name="arrayLayers">The number of array layers visible in the view.</param>
        public this(Texture target, PixelFormat format, uint32 baseMipLevel, uint32 mipLevels, uint32 baseArrayLayer, uint32 arrayLayers)
        {
            Target = target;
            BaseMipLevel = baseMipLevel;
            MipLevels = mipLevels;
            BaseArrayLayer = baseArrayLayer;
            ArrayLayers = arrayLayers;
            Format = target.Format;
        }

        /// <summary>
        /// Element-wise equality.
        /// </summary>
        /// <param name="other">The instance to compare to.</param>
        /// <returns>True if all elements are equal; false otherswise.</returns>
        public bool Equals(TextureViewDescription other)
        {
            return Target === other.Target
                && BaseMipLevel == other.BaseMipLevel
                && MipLevels == other.MipLevels
                && BaseArrayLayer == other.BaseArrayLayer
                && ArrayLayers == other.ArrayLayers
                && Format == other.Format;
        }

        /// <summary>
        /// Returns the hash code for this instance.
        /// </summary>
        /// <returns>A 32-bit signed integer that is the hash code for this instance.</returns>
        public int GetHashCode()
        {
            return HashHelper.Combine(
                HashCode.Generate(Target),
                BaseMipLevel.GetHashCode(),
                MipLevels.GetHashCode(),
                BaseArrayLayer.GetHashCode(),
                ArrayLayers.GetHashCode(),
                Format != null ? Format.GetHashCode() : 0);
        }
    }
}
