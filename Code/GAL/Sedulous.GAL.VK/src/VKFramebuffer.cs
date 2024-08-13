using Bulkan;
using static Bulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using System;
using System.Diagnostics;
using System.Collections;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.VK;

    internal class VKFramebuffer : VKFramebufferBase
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkFramebuffer _deviceFramebuffer;
        private readonly VkRenderPass _renderPassNoClearLoad;
        private readonly VkRenderPass _renderPassNoClear;
        private readonly VkRenderPass _renderPassClear;
        private readonly List<VkImageView> _attachmentViews = new List<VkImageView>() ~ delete _;
        private bool _destroyed;
        private String _name;

        public override VkFramebuffer CurrentFramebuffer => _deviceFramebuffer;
        public override VkRenderPass RenderPassNoClear_Init => _renderPassNoClear;
        public override VkRenderPass RenderPassNoClear_Load => _renderPassNoClearLoad;
        public override VkRenderPass RenderPassClear => _renderPassClear;

        public override uint32 RenderableWidth => Width;
        public override uint32 RenderableHeight => Height;

        public override uint32 AttachmentCount { get; protected set; }

        public override bool IsDisposed => _destroyed;

        public this(VKGraphicsDevice gd, in FramebufferDescription description, bool isPresented)
            : base(description.DepthTarget, description.ColorTargets)
        {
            _gd = gd;

            VkRenderPassCreateInfo renderPassCI = VkRenderPassCreateInfo(){sType = .VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO};

            List<VkAttachmentDescription> attachments = scope .();

            uint32 colorAttachmentCount = (uint32)ColorTargets.Count;
            List<VkAttachmentReference> colorAttachmentRefs = scope .();
            for (int i = 0; i < colorAttachmentCount; i++)
            {
                VKTexture vkColorTex = Util.AssertSubtype<Texture, VKTexture>(ColorTargets[i].Target);
                VkAttachmentDescription colorAttachmentDesc = VkAttachmentDescription();
                colorAttachmentDesc.format = vkColorTex.VkFormat;
                colorAttachmentDesc.samples = vkColorTex.VkSampleCount;
                colorAttachmentDesc.loadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD;
                colorAttachmentDesc.storeOp = VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE;
                colorAttachmentDesc.stencilLoadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE;
                colorAttachmentDesc.stencilStoreOp = VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE;
                colorAttachmentDesc.initialLayout = isPresented
                    ? VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
                    : ((vkColorTex.Usage & TextureUsage.Sampled) != 0)
                        ? VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
                        : VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
                colorAttachmentDesc.finalLayout = VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
                attachments.Add(colorAttachmentDesc);

                VkAttachmentReference colorAttachmentRef = VkAttachmentReference();
                colorAttachmentRef.attachment = (uint32)i;
                colorAttachmentRef.layout = VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
                colorAttachmentRefs.Add(colorAttachmentRef);
            }

            VkAttachmentDescription depthAttachmentDesc = VkAttachmentDescription();
            VkAttachmentReference depthAttachmentRef = VkAttachmentReference();
            if (DepthTarget != null)
            {
                VKTexture vkDepthTex = Util.AssertSubtype<Texture, VKTexture>(DepthTarget.Value.Target);
                bool hasStencil = FormatHelpers.IsStencilFormat(vkDepthTex.Format);
                depthAttachmentDesc.format = vkDepthTex.VkFormat;
                depthAttachmentDesc.samples = vkDepthTex.VkSampleCount;
                depthAttachmentDesc.loadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD;
                depthAttachmentDesc.storeOp = VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE;
                depthAttachmentDesc.stencilLoadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE;
                depthAttachmentDesc.stencilStoreOp = hasStencil
                    ? VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE
                    : VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE;
                depthAttachmentDesc.initialLayout = ((vkDepthTex.Usage & TextureUsage.Sampled) != 0)
                    ? VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
                    : VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
                depthAttachmentDesc.finalLayout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;

                depthAttachmentRef.attachment = (uint32)description.ColorTargets.Count;
                depthAttachmentRef.layout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
            }

            VkSubpassDescription subpass = VkSubpassDescription();
            subpass.pipelineBindPoint = VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS;
            if (ColorTargets.Count > 0)
            {
                subpass.colorAttachmentCount = colorAttachmentCount;
                subpass.pColorAttachments = (VkAttachmentReference*)colorAttachmentRefs.Ptr;
            }

            if (DepthTarget != null)
            {
                subpass.pDepthStencilAttachment = &depthAttachmentRef;
                attachments.Add(depthAttachmentDesc);
            }

            VkSubpassDependency subpassDependency = VkSubpassDependency();
            subpassDependency.srcSubpass = VK_SUBPASS_EXTERNAL;
            subpassDependency.srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
            subpassDependency.dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
            subpassDependency.dstAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;

            renderPassCI.attachmentCount = (uint32)attachments.Count;
            renderPassCI.pAttachments = (VkAttachmentDescription*)attachments.Ptr;
            renderPassCI.subpassCount = 1;
            renderPassCI.pSubpasses = &subpass;
            renderPassCI.dependencyCount = 1;
            renderPassCI.pDependencies = &subpassDependency;

            VkResult creationResult = vkCreateRenderPass(_gd.Device, &renderPassCI, null, &_renderPassNoClear);
            CheckResult(creationResult);

            for (int i = 0; i < colorAttachmentCount; i++)
            {
                attachments[i].loadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD;
                attachments[i].initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
            }
            if (DepthTarget != null)
            {
                attachments[attachments.Count - 1].loadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD;
                attachments[attachments.Count - 1].initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
                bool hasStencil = FormatHelpers.IsStencilFormat(DepthTarget.Value.Target.Format);
                if (hasStencil)
                {
                    attachments[attachments.Count - 1].stencilLoadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD;
                }

            }
            creationResult = vkCreateRenderPass(_gd.Device, &renderPassCI, null, &_renderPassNoClearLoad);
            CheckResult(creationResult);


            // Load version

            if (DepthTarget != null)
            {
                attachments[attachments.Count - 1].loadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_CLEAR;
                attachments[attachments.Count - 1].initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
                bool hasStencil = FormatHelpers.IsStencilFormat(DepthTarget.Value.Target.Format);
                if (hasStencil)
                {
                    attachments[attachments.Count - 1].stencilLoadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_CLEAR;
                }
            }

            for (int i = 0; i < colorAttachmentCount; i++)
            {
                attachments[i].loadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_CLEAR;
                attachments[i].initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
            }

            creationResult = vkCreateRenderPass(_gd.Device, &renderPassCI, null, &_renderPassClear);
            CheckResult(creationResult);

            VkFramebufferCreateInfo fbCI = VkFramebufferCreateInfo() {sType = .VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO};
            uint32 fbAttachmentsCount = (uint32)description.ColorTargets.Count;
            if (description.DepthTarget != null)
            {
                fbAttachmentsCount += 1;
            }

            VkImageView* fbAttachments = scope VkImageView[(int32)fbAttachmentsCount]*;
            for (int i = 0; i < colorAttachmentCount; i++)
            {
                VKTexture vkColorTarget = Util.AssertSubtype<Texture, VKTexture>(description.ColorTargets[i].Target);
                VkImageViewCreateInfo imageViewCI = VkImageViewCreateInfo(){sType = .VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO};
                imageViewCI.image = vkColorTarget.OptimalDeviceImage;
                imageViewCI.format = vkColorTarget.VkFormat;
                imageViewCI.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D;
                imageViewCI.subresourceRange = VkImageSubresourceRange(){
                    aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
                    baseMipLevel = description.ColorTargets[i].MipLevel,
                    levelCount = 1,
                    baseArrayLayer = description.ColorTargets[i].ArrayLayer,
                    layerCount = 1};
                VkImageView* dest = (fbAttachments + i);
                VkResult result = vkCreateImageView(_gd.Device, &imageViewCI, null, dest);
                CheckResult(result);
                _attachmentViews.Add(*dest);
            }

            // Depth
            if (description.DepthTarget != null)
            {
                VKTexture vkDepthTarget = Util.AssertSubtype<Texture, VKTexture>(description.DepthTarget.Value.Target);
                bool hasStencil = FormatHelpers.IsStencilFormat(vkDepthTarget.Format);
                VkImageViewCreateInfo depthViewCI = VkImageViewCreateInfo(){sType = .VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO};
                depthViewCI.image = vkDepthTarget.OptimalDeviceImage;
                depthViewCI.format = vkDepthTarget.VkFormat;
                depthViewCI.viewType = description.DepthTarget.Value.Target.ArrayLayers == 1
                    ? VkImageViewType.VK_IMAGE_VIEW_TYPE_2D
                    : VkImageViewType.VK_IMAGE_VIEW_TYPE_2D_ARRAY;
                depthViewCI.subresourceRange = VkImageSubresourceRange(){
                    aspectMask = hasStencil ? VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT,
                    baseMipLevel = description.DepthTarget.Value.MipLevel,
                    levelCount = 1,
                    baseArrayLayer = description.DepthTarget.Value.ArrayLayer,
                    layerCount = 1};
                VkImageView* dest = (fbAttachments + (fbAttachmentsCount - 1));
                VkResult result = vkCreateImageView(_gd.Device, &depthViewCI, null, dest);
                CheckResult(result);
                _attachmentViews.Add(*dest);
            }

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

            Util.GetMipDimensions(
                dimTex,
                mipLevel,
                var mipWidth,
                var mipHeight,
                ?);

            fbCI.width = mipWidth;
            fbCI.height = mipHeight;

            fbCI.attachmentCount = fbAttachmentsCount;
            fbCI.pAttachments = fbAttachments;
            fbCI.layers = 1;
            fbCI.renderPass = _renderPassNoClear;

            creationResult = vkCreateFramebuffer(_gd.Device, &fbCI, null, &_deviceFramebuffer);
            CheckResult(creationResult);

            if (DepthTarget != null)
            {
                AttachmentCount += 1;
            }
            AttachmentCount += (uint32)ColorTargets.Count;
        }

        public override void TransitionToIntermediateLayout(VkCommandBuffer cb)
        {
            for (int i = 0; i < ColorTargets.Count; i++)
            {
                FramebufferAttachmentDescription ca = ColorTargets[i];
                VKTexture vkTex = Util.AssertSubtype<Texture, VKTexture>(ca.Target);
                vkTex.SetImageLayout(ca.MipLevel, ca.ArrayLayer, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
            }
            if (DepthTarget != null)
            {
                VKTexture vkTex = Util.AssertSubtype<Texture, VKTexture>(DepthTarget.Value.Target);
                vkTex.SetImageLayout(
                    DepthTarget.Value.MipLevel,
                    DepthTarget.Value.ArrayLayer,
                    VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL);
            }
        }

        public override void TransitionToFinalLayout(VkCommandBuffer cb)
        {
            for (int i = 0; i < ColorTargets.Count; i++)
            {
                FramebufferAttachmentDescription ca = ColorTargets[i];
                VKTexture vkTex = Util.AssertSubtype<Texture, VKTexture>(ca.Target);
                if ((vkTex.Usage & TextureUsage.Sampled) != 0)
                {
                    vkTex.TransitionImageLayout(
                        cb,
                        ca.MipLevel, 1,
                        ca.ArrayLayer, 1,
                        VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
                }
            }
            if (DepthTarget != null)
            {
                VKTexture vkTex = Util.AssertSubtype<Texture, VKTexture>(DepthTarget.Value.Target);
                if ((vkTex.Usage & TextureUsage.Sampled) != 0)
                {
                    vkTex.TransitionImageLayout(
                        cb,
                        DepthTarget.Value.MipLevel, 1,
                        DepthTarget.Value.ArrayLayer, 1,
                        VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
                }
            }
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

        protected override void DisposeCore()
        {
            if (!_destroyed)
            {
                vkDestroyFramebuffer(_gd.Device, _deviceFramebuffer, null);
                vkDestroyRenderPass(_gd.Device, _renderPassNoClear, null);
                vkDestroyRenderPass(_gd.Device, _renderPassNoClearLoad, null);
                vkDestroyRenderPass(_gd.Device, _renderPassClear, null);
                for (VkImageView view in _attachmentViews)
                {
                    vkDestroyImageView(_gd.Device, view, null);
                }

                _destroyed = true;
            }
        }
    }
}
