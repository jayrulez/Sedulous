using System;
using System.Diagnostics;

namespace Sedulous.GAL
{
    /// <summary>
    /// Describes a set of output attachments and their formats.
    /// </summary>
    public struct OutputDescription : IEquatable<OutputDescription>, IHashable
    {
        /// <summary>
        /// A description of the depth attachment, or null if none exists.
        /// </summary>
        public OutputAttachmentDescription? DepthAttachment;
        /// <summary>
        /// An array of attachment descriptions, one for each color attachment. May be empty.
        /// </summary>
        public OutputAttachmentList ColorAttachments;
        /// <summary>
        /// The number of samples in each target attachment.
        /// </summary>
        public TextureSampleCount SampleCount;

        /// <summary>
        /// Constructs a new <see cref="OutputDescription"/>.
        /// </summary>
        /// <param name="depthAttachment">A description of the depth attachment.</param>
        /// <param name="colorAttachments">An array of descriptions of each color attachment.</param>
        public this(OutputAttachmentDescription? depthAttachment, params OutputAttachmentDescription[] colorAttachments)
        {
            DepthAttachment = depthAttachment;
            ColorAttachments = .(colorAttachments);
            SampleCount = TextureSampleCount.Count1;
        }

        /// <summary>
        /// Constructs a new <see cref="OutputDescription"/>.
        /// </summary>
        /// <param name="depthAttachment">A description of the depth attachment.</param>
        /// <param name="colorAttachments">An array of descriptions of each color attachment.</param>
        /// <param name="sampleCount">The number of samples in each target attachment.</param>
        public this(
            OutputAttachmentDescription? depthAttachment,
            OutputAttachmentList colorAttachments,
            TextureSampleCount sampleCount)
        {
            DepthAttachment = depthAttachment;
            ColorAttachments = colorAttachments;
            SampleCount = sampleCount;
        }

        internal static OutputDescription CreateFromFramebuffer(Framebuffer fb)
        {
            TextureSampleCount sampleCount = 0;
            OutputAttachmentDescription? depthAttachment = null;
            if (fb.DepthTarget != null)
            {
                depthAttachment = OutputAttachmentDescription(fb.DepthTarget.Value.Target.Format);
                sampleCount = fb.DepthTarget.Value.Target.SampleCount;
            }
            OutputAttachmentList colorAttachments = .() { Count = fb.ColorTargets.Count };
            for (int i = 0; i < colorAttachments.Count; i++)
            {
                colorAttachments[i] = OutputAttachmentDescription(fb.ColorTargets[i].Target.Format);
                sampleCount = fb.ColorTargets[i].Target.SampleCount;
            }

            return OutputDescription(depthAttachment, colorAttachments, sampleCount);
        }

        /// <summary>
        /// Element-wise equality.
        /// </summary>
        /// <param name="other">The instance to compare to.</param>
        /// <returns>True if all elements and all array elements are equal; false otherswise.</returns>
        public bool Equals(OutputDescription other)
        {
            return DepthAttachment.GetValueOrDefault().Equals(other.DepthAttachment.GetValueOrDefault())
                && ColorAttachments == other.ColorAttachments
                && SampleCount == other.SampleCount;
        }

        /// <summary>
        /// Returns the hash code for this instance.
        /// </summary>
        /// <returns>A 32-bit signed integer that is the hash code for this instance.</returns>
        public int GetHashCode()
        {
            return HashHelper.Combine(
                DepthAttachment.GetHashCode(),
                ColorAttachments.GetHashCode(),
                (int)SampleCount);
        }
    }
}
