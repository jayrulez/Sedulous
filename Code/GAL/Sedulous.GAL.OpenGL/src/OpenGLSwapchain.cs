using System;

namespace Sedulous.GAL.OpenGL
{
    internal class OpenGLSwapchain : Swapchain
    {
        private readonly OpenGLGraphicsDevice _gd;
        private readonly OpenGLSwapchainFramebuffer _framebuffer;
        private readonly Action<uint32, uint32> _resizeAction;
        private bool _disposed;

        public override Framebuffer Framebuffer => _framebuffer;
        public override bool SyncToVerticalBlank { get => _gd.SyncToVerticalBlank; set => _gd.SyncToVerticalBlank = value; }
        public override string Name { get; set; } = "OpenGL Context Swapchain";
        public override bool IsDisposed => _disposed;

        public OpenGLSwapchain(
            OpenGLGraphicsDevice gd,
            OpenGLSwapchainFramebuffer framebuffer,
            Action<uint32, uint32> resizeAction)
        {
            _gd = gd;
            _framebuffer = framebuffer;
            _resizeAction = resizeAction;
        }

        public override void Resize(uint32 width, uint32 height)
        {
            _framebuffer.Resize(width, height);
            _resizeAction?.Invoke(width, height);
        }

        public override void Dispose()
        {
            _disposed = true;
        }
    }
}
