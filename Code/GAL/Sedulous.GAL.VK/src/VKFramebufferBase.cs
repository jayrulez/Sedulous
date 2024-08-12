using System.Collections.Generic;
using Vulkan;

namespace Sedulous.GAL.VK
{
    internal abstract class VKFramebufferBase : Framebuffer
    {
        public VKFramebufferBase(
            FramebufferAttachmentDescription? depthTexture,
            IReadOnlyList<FramebufferAttachmentDescription> colorTextures)
            : base(depthTexture, colorTextures)
        {
            RefCount = new ResourceRefCount(DisposeCore);
        }

        public VKFramebufferBase()
        {
            RefCount = new ResourceRefCount(DisposeCore);
        }

        public ResourceRefCount RefCount { get; }

        public abstract uint32 RenderableWidth { get; }
        public abstract uint32 RenderableHeight { get; }

        public override void Dispose()
        {
            RefCount.Decrement();
        }

        protected abstract void DisposeCore();

        public abstract Vulkan.VkFramebuffer CurrentFramebuffer { get; }
        public abstract VkRenderPass RenderPassNoClear_Init { get; }
        public abstract VkRenderPass RenderPassNoClear_Load { get; }
        public abstract VkRenderPass RenderPassClear { get; }
        public abstract uint32 AttachmentCount { get; }
        public abstract void TransitionToIntermediateLayout(VkCommandBuffer cb);
        public abstract void TransitionToFinalLayout(VkCommandBuffer cb);
    }
}
