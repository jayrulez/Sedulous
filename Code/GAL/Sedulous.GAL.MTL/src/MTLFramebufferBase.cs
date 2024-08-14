using Sedulous.MetalBindings;
using System;

namespace Sedulous.GAL.MTL
{
    internal abstract class MTLFramebufferBase : Framebuffer
    {
        public abstract MTLRenderPassDescriptor CreateRenderPassDescriptor();
        public abstract bool IsRenderable { get; }

        public override String Name { get; set; }

        public this(MTLGraphicsDevice gd, in FramebufferDescription description)
            : base(description.DepthTarget, description.ColorTargets)
        {
        }

        public this()
        {
        }
    }
}