using System;

namespace Sedulous.GAL
{
    /// <summary>
    /// A <see cref="Pipeline"/> component describing how values are blended into each individual color target.
    /// </summary>
    public struct BlendStateDescription : IEquatable<BlendStateDescription>, IHashable
    {
        /// <summary>
        /// A constant blend color used in <see cref="BlendFactor.BlendFactor"/> and <see cref="BlendFactor.InverseBlendFactor"/>,
        /// or otherwise ignored.
        /// </summary>
        public RgbaFloat BlendFactor;
        /// <summary>
        /// An array of <see cref="BlendAttachmentDescription"/> describing how blending is performed for each color target
        /// used in the <see cref="Pipeline"/>.
        /// </summary>
        public BlendAttachmentList AttachmentStates;
        /// <summary>
        /// Enables alpha-to-coverage, which causes a fragment's alpha value to be used when determining multi-sample coverage.
        /// </summary>
        public bool AlphaToCoverageEnabled;

        /// <summary>
        /// Constructs a new <see cref="BlendStateDescription"/>,
        /// </summary>
        /// <param name="blendFactor">The constant blend color.</param>
        /// <param name="attachmentStates">The blend attachment states.</param>
        public this(RgbaFloat blendFactor, params BlendAttachmentDescription[] attachmentStates)
        {
            BlendFactor = blendFactor;
            AttachmentStates = .(attachmentStates);
            AlphaToCoverageEnabled = false;
        }

        /// <summary>
        /// Constructs a new <see cref="BlendStateDescription"/>,
        /// </summary>
        /// <param name="blendFactor">The constant blend color.</param>
        /// <param name="alphaToCoverageEnabled">Enables alpha-to-coverage, which causes a fragment's alpha value to be
        /// used when determining multi-sample coverage.</param>
        /// <param name="attachmentStates">The blend attachment states.</param>
        public this(
            RgbaFloat blendFactor,
            bool alphaToCoverageEnabled,
            params BlendAttachmentDescription[] attachmentStates)
        {
            BlendFactor = blendFactor;
            AttachmentStates = .(attachmentStates);
            AlphaToCoverageEnabled = alphaToCoverageEnabled;
        }

        /// <summary>
        /// Describes a blend state in which a single color target is blended with <see cref="BlendAttachmentDescription.OverrideBlend"/>.
        /// </summary>
        public static readonly BlendStateDescription SingleOverrideBlend = BlendStateDescription
        {
            AttachmentStates = .(BlendAttachmentDescription.OverrideBlend)
        };

        /// <summary>
        /// Describes a blend state in which a single color target is blended with <see cref="BlendAttachmentDescription.AlphaBlend"/>.
        /// </summary>
        public static readonly BlendStateDescription SingleAlphaBlend = BlendStateDescription
        {
            AttachmentStates = .(BlendAttachmentDescription.AlphaBlend)
        };

        /// <summary>
        /// Describes a blend state in which a single color target is blended with <see cref="BlendAttachmentDescription.AdditiveBlend"/>.
        /// </summary>
        public static readonly BlendStateDescription SingleAdditiveBlend = BlendStateDescription
        {
            AttachmentStates = .(BlendAttachmentDescription.AdditiveBlend)
        };

        /// <summary>
        /// Describes a blend state in which a single color target is blended with <see cref="BlendAttachmentDescription.Disabled"/>.
        /// </summary>
        public static readonly BlendStateDescription SingleDisabled = BlendStateDescription
        {
            AttachmentStates = .(BlendAttachmentDescription.Disabled)
        };

        /// <summary>
        /// Describes an empty blend state in which no color targets are used.
        /// </summary>
        public static readonly BlendStateDescription Empty = BlendStateDescription
        {
            AttachmentStates = .()
        };

        /// <summary>
        /// Element-wise equality.
        /// </summary>
        /// <param name="other">The instance to compare to.</param>
        /// <returns>True if all elements and all array elements are equal; false otherswise.</returns>
        public bool Equals(BlendStateDescription other)
        {
            return BlendFactor.Equals(other.BlendFactor)
                && AlphaToCoverageEnabled == other.AlphaToCoverageEnabled
                && AttachmentStates == other.AttachmentStates;
        }

        /// <summary>
        /// Returns the hash code for this instance.
        /// </summary>
        /// <returns>A 32-bit signed integer that is the hash code for this instance.</returns>
        public int GetHashCode()
        {
            return HashHelper.Combine(
                BlendFactor.GetHashCode(),
                AlphaToCoverageEnabled.GetHashCode(),
                AttachmentStates.GetHashCode());
        }

        internal BlendStateDescription ShallowClone()
        {
            BlendStateDescription result = this;
            //result.AttachmentStates = Util.ShallowClone(result.AttachmentStates);
            return result;
        }
    }
}
