using Bulkan;
using static Bulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using System;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.VK;

    public class VKSwapchainFramebuffer : VKFramebufferBase
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VKSwapchain _swapchain;
        private readonly VkSurfaceKHR _surface;
        private readonly PixelFormat? _depthFormat;
        private uint32 _currentImageIndex;

        private VKFramebuffer[] _scFramebuffers;
        private VkImage[] _scImages = new .[0];
        private VkFormat _scImageFormat;
        private VkExtent2D _scExtent;
        private FramebufferAttachmentList[] _scColorTextures;

        private FramebufferAttachmentDescription? _depthAttachment;
        private uint32 _desiredWidth;
        private uint32 _desiredHeight;
        private bool _destroyed;
        private String _name;
        private OutputDescription _outputDescription;

        public override VkFramebuffer CurrentFramebuffer => _scFramebuffers[(int32)_currentImageIndex].CurrentFramebuffer;

        public override VkRenderPass RenderPassNoClear_Init => _scFramebuffers[0].RenderPassNoClear_Init;
        public override VkRenderPass RenderPassNoClear_Load => _scFramebuffers[0].RenderPassNoClear_Load;
        public override VkRenderPass RenderPassClear => _scFramebuffers[0].RenderPassClear;

        public override ref FramebufferAttachmentList ColorTargets => ref _scColorTextures[(int32)_currentImageIndex];

        public override ref FramebufferAttachmentDescription? DepthTarget => ref _depthAttachment;

        public override uint32 RenderableWidth => _scExtent.width;
        public override uint32 RenderableHeight => _scExtent.height;

        public override uint32 Width => _desiredWidth;
        public override uint32 Height => _desiredHeight;

        public uint32 ImageIndex => _currentImageIndex;

        public override ref OutputDescription OutputDescription => ref _outputDescription;

        public override uint32 AttachmentCount { get; protected set; }

        public VKSwapchain Swapchain => _swapchain;

        public override bool IsDisposed => _destroyed;

        public this(
            VKGraphicsDevice gd,
            VKSwapchain swapchain,
            VkSurfaceKHR surface,
            uint32 width,
            uint32 height,
            PixelFormat? depthFormat)
            : base()
        {
            _gd = gd;
            _swapchain = swapchain;
            _surface = surface;
            _depthFormat = depthFormat;

            AttachmentCount = depthFormat.HasValue ? 2 : 1; // 1 Color + 1 Depth
        }

        internal void SetImageIndex(uint32 index)
        {
            _currentImageIndex = index;
        }

        internal void SetNewSwapchain(
            VkSwapchainKHR deviceSwapchain,
            uint32 width,
            uint32 height,
            VkSurfaceFormatKHR surfaceFormat,
            VkExtent2D swapchainExtent)
        {
            _desiredWidth = width;
            _desiredHeight = height;

            // Get the images
            uint32 scImageCount = 0;
            VkResult result = vkGetSwapchainImagesKHR(_gd.Device, deviceSwapchain, &scImageCount, null);
            CheckResult(result);
            if (_scImages.Count < scImageCount)
            {
				delete _scImages;
                _scImages = new VkImage[(int32)scImageCount];
            }
            result = vkGetSwapchainImagesKHR(_gd.Device, deviceSwapchain, &scImageCount, _scImages.Ptr);
            CheckResult(result);

            _scImageFormat = surfaceFormat.format;
            _scExtent = swapchainExtent;

            CreateDepthTexture();
            CreateFramebuffers();

            _outputDescription = /*OutputDescription*/.CreateFromFramebuffer(this);
        }

        private void DestroySwapchainFramebuffers()
        {
            if (_scFramebuffers != null)
            {
                for (int i = 0; i < _scFramebuffers.Count; i++)
                {
                    _scFramebuffers[i]?.Dispose();
                    _scFramebuffers[i] = null;
                }
                Array.Clear(_scFramebuffers, 0, _scFramebuffers.Count);
            }
        }

        private void CreateDepthTexture()
        {
            if (_depthFormat.HasValue)
            {
                _depthAttachment?.Target.Dispose();
                VKTexture depthTexture = (VKTexture)_gd.ResourceFactory.CreateTexture(TextureDescription.Texture2D(
                    Math.Max(1, _scExtent.width),
                    Math.Max(1, _scExtent.height),
                    1,
                    1,
                    _depthFormat.Value,
                    TextureUsage.DepthStencil));
                _depthAttachment = FramebufferAttachmentDescription(depthTexture, 0);
            }
        }

        private void CreateFramebuffers()
        {
            if (_scFramebuffers != null)
            {
                for (int i = 0; i < _scFramebuffers.Count; i++)
                {
                    _scFramebuffers[i]?.Dispose();
                    _scFramebuffers[i] = null;
                }
                Array.Clear(_scFramebuffers, 0, _scFramebuffers.Count);
            }

            Util.EnsureArrayMinimumSize(ref _scFramebuffers, (uint32)_scImages.Count);
            Util.EnsureArrayMinimumSize(ref _scColorTextures, (uint32)_scImages.Count);
            for (uint32 i = 0; i < _scImages.Count; i++)
            {
                VKTexture colorTex = new VKTexture(
                    _gd,
                    Math.Max(1, _scExtent.width),
                    Math.Max(1, _scExtent.height),
                    1,
                    1,
                    _scImageFormat,
                    TextureUsage.RenderTarget,
                    TextureSampleCount.Count1,
                    _scImages[i]);
                FramebufferDescription desc = FramebufferDescription(_depthAttachment?.Target, colorTex);
                VKFramebuffer fb = new VKFramebuffer(_gd, desc, true);
                _scFramebuffers[i] = fb;
                _scColorTextures[i] = .(FramebufferAttachmentDescription(colorTex, 0));
            }
        }

        public override void TransitionToIntermediateLayout(VkCommandBuffer cb)
        {
            for (int32 i = 0; i < ColorTargets.Count; i++)
            {
                FramebufferAttachmentDescription ca = ColorTargets[i];
                VKTexture vkTex = Util.AssertSubtype<Texture, VKTexture>(ca.Target);
                vkTex.SetImageLayout(0, ca.ArrayLayer, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
            }
        }

        public override void TransitionToFinalLayout(VkCommandBuffer cb)
        {
            for (int32 i = 0; i < ColorTargets.Count; i++)
            {
                FramebufferAttachmentDescription ca = ColorTargets[i];
                VKTexture vkTex = Util.AssertSubtype<Texture, VKTexture>(ca.Target);
                vkTex.TransitionImageLayout(cb, 0, 1, ca.ArrayLayer, 1, VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR);
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
                _destroyed = true;
                _depthAttachment?.Target.Dispose();
                DestroySwapchainFramebuffers();
            }
        }
    }
}
