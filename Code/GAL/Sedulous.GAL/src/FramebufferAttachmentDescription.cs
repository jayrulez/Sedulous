using System;
using Sedulous.Foundation.Collections;

namespace Sedulous.GAL
{
	public typealias FramebufferAttachmentList = FixedList<FramebufferAttachmentDescription, const 8>;

    /// <summary>
    /// Describes a single attachment (color or depth) for a <see cref="Framebuffer"/>.
    /// </summary>
    public struct FramebufferAttachmentDescription : IEquatable<FramebufferAttachmentDescription>, IHashable
    {
        /// <summary>
        /// The target texture to render into. For color attachments, this resource must have been created with the
        /// <see cref="TextureUsage.RenderTarget"/> flag. For depth attachments, this resource must have been created with the
        /// <see cref="TextureUsage.DepthStencil"/> flag.
        /// </summary>
        public Texture Target;
        /// <summary>
        /// The array layer to render to. This value must be less than <see cref="Texture.ArrayLayers"/> in the target
        /// <see cref="Texture"/>.
        /// </summary>
        public uint32 ArrayLayer;
        /// <summary>
        /// The mip level to render to. This value must be less than <see cref="Texture.MipLevels"/> in the target
        /// <see cref="Texture"/>.
        /// </summary>
        public uint32 MipLevel;

        /// <summary>
        /// Constructs a new FramebufferAttachmentDescription.
        /// </summary>
        /// <param name="target">The target texture to render into. For color attachments, this resource must have been created
        /// with the <see cref="TextureUsage.RenderTarget"/> flag. For depth attachments, this resource must have been created
        /// with the <see cref="TextureUsage.DepthStencil"/> flag.</param>
        /// <param name="arrayLayer">The array layer to render to. This value must be less than <see cref="Texture.ArrayLayers"/>
        /// in the target <see cref="Texture"/>.</param>
        public this(Texture target, uint32 arrayLayer)
            : this(target, arrayLayer, 0)
        { }

        /// <summary>
        /// Constructs a new FramebufferAttachmentDescription.
        /// </summary>
        /// <param name="target">The target texture to render into. For color attachments, this resource must have been created
        /// with the <see cref="TextureUsage.RenderTarget"/> flag. For depth attachments, this resource must have been created
        /// with the <see cref="TextureUsage.DepthStencil"/> flag.</param>
        /// <param name="arrayLayer">The array layer to render to. This value must be less than <see cref="Texture.ArrayLayers"/>
        /// in the target <see cref="Texture"/>.</param>
        /// <param name="mipLevel">The mip level to render to. This value must be less than <see cref="Texture.MipLevels"/> in
        /// the target <see cref="Texture"/>.</param>
        public this(Texture target, uint32 arrayLayer, uint32 mipLevel)
        {
#if VALIDATE_USAGE
            uint32 effectiveArrayLayers = target.ArrayLayers;
            if ((target.Usage & TextureUsage.Cubemap) != 0)
            {
                effectiveArrayLayers *= 6;
            }

            if (arrayLayer >= effectiveArrayLayers)
            {
                Runtime.GALError(
                    scope $"{nameof(arrayLayer)} must be less than {nameof(target)}.{nameof(Texture.ArrayLayers)}.");
            }
            if (mipLevel >= target.MipLevels)
            {
                Runtime.GALError(
                    scope $"{nameof(mipLevel)} must be less than {nameof(target)}.{nameof(Texture.MipLevels)}.");
            }
#endif
            Target = target;
            ArrayLayer = arrayLayer;
            MipLevel = mipLevel;
        }

        /// <summary>
        /// Element-wise equality.
        /// </summary>
        /// <param name="other">The instance to compare to.</param>
        /// <returns>True if all elements and all array elements are equal; false otherswise.</returns>
        public bool Equals(FramebufferAttachmentDescription other)
        {
            return Target === other.Target && ArrayLayer == other.ArrayLayer && MipLevel == other.MipLevel;
        }

        /// <summary>
        /// Returns the hash code for this instance.
        /// </summary>
        /// <returns>A 32-bit signed integer that is the hash code for this instance.</returns>
        public int GetHashCode()
        {
            return HashHelper.Combine(HashCode.Generate(Target), ArrayLayer.GetHashCode(), MipLevel.GetHashCode());
        }
    }
}
