using System;
using System.Diagnostics;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

    /// <summary>
    /// A device resource used to control which color and depth textures are rendered to.
    /// See <see cref="FramebufferDescription"/>.
    /// </summary>
    public abstract class Framebuffer : DeviceResource, IDisposable
    {
        /// <summary>
        /// Gets the depth attachment associated with this instance. May be null if no depth texture is used.
        /// </summary>
        public virtual ref FramebufferAttachmentDescription? DepthTarget { get; }

        /// <summary>
        /// Gets the collection of color attachments associated with this instance. May be empty.
        /// </summary>
        public virtual ref FramebufferAttachmentList ColorTargets { get; }

        /// <summary>
        /// Gets an <see cref="Sedulous.GAL.OutputDescription"/> which describes the number and formats of the depth and color targets
        /// in this instance.
        /// </summary>
        public virtual ref OutputDescription OutputDescription { get; }

        /// <summary>
        /// Gets the width of the <see cref="Framebuffer"/>.
        /// </summary>
        public virtual ref uint32 Width { get; }

        /// <summary>
        /// Gets the height of the <see cref="Framebuffer"/>.
        /// </summary>
        public virtual ref uint32 Height { get; }

        internal this() { }

        internal this(
            FramebufferAttachmentDescription? depthTargetDesc,
            FramebufferAttachmentList colorTargetDescs)
        {
            if (depthTargetDesc != null)
            {
                FramebufferAttachmentDescription depthAttachment = depthTargetDesc.Value;
                DepthTarget = FramebufferAttachmentDescription(
                    depthAttachment.Target,
                    depthAttachment.ArrayLayer,
                    depthAttachment.MipLevel);
            }
            FramebufferAttachmentList colorTargets = .() { Count = colorTargetDescs.Count };
            for (int i = 0; i < colorTargets.Count; i++)
            {
                colorTargets[i] = FramebufferAttachmentDescription(
                    colorTargetDescs[i].Target,
                    colorTargetDescs[i].ArrayLayer,
                    colorTargetDescs[i].MipLevel);
            }

            ColorTargets = colorTargets;

            Texture dimTex;
            uint32 mipLevel;
            if (ColorTargets.Count > 0)
            {
                dimTex = ColorTargets[0].Target;
                mipLevel = ColorTargets[0].MipLevel;
            }
            else
            {
                Debug.Assert(DepthTarget != null);
                dimTex = DepthTarget.Value.Target;
                mipLevel = DepthTarget.Value.MipLevel;
            }

            Util.GetMipDimensions(dimTex, mipLevel, var mipWidth, var mipHeight, ?);
            Width = mipWidth;
            Height = mipHeight;


            OutputDescription = /*OutputDescription*/.CreateFromFramebuffer(this);
        }

        /// <summary>
        /// A string identifying this instance. Can be used to differentiate between objects in graphics debuggers and other
        /// tools.
        /// </summary>
        public abstract String Name { get; set; }

        /// <summary>
        /// A bool indicating whether this instance has been disposed.
        /// </summary>
        public abstract bool IsDisposed { get; }

        /// <summary>
        /// Frees unmanaged device resources controlled by this instance.
        /// </summary>
        public abstract void Dispose();
    }
}
