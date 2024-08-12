using static Sedulous.OpenGLBindings.OpenGLNative;
using static Sedulous.GAL.OpenGL.OpenGLUtil;
using Sedulous.OpenGLBindings;

namespace Sedulous.GAL.OpenGL
{
    internal class OpenGLFramebuffer : Framebuffer, OpenGLDeferredResource
    {
        private readonly OpenGLGraphicsDevice _gd;
        private uint32 _framebuffer;

        private string _name;
        private bool _nameChanged;
        private bool _disposeRequested;
        private bool _disposed;

        public override string Name { get => _name; set { _name = value; _nameChanged = true; } }

        public uint32 Framebuffer => _framebuffer;

        public bool Created { get; private set; }

        public override bool IsDisposed => _disposeRequested;

        public OpenGLFramebuffer(OpenGLGraphicsDevice gd, ref FramebufferDescription description)
            : base(description.DepthTarget, description.ColorTargets)
        {
            _gd = gd;
        }

        public void EnsureResourcesCreated()
        {
            if (!Created)
            {
                CreateGLResources();
            }
            if (_nameChanged)
            {
                _nameChanged = false;
                if (_gd.Extensions.KHR_Debug)
                {
                    SetObjectLabel(ObjectLabelIdentifier.Framebuffer, _framebuffer, _name);
                }
            }
        }

        public void CreateGLResources()
        {
            glGenFramebuffers(1, out _framebuffer);
            CheckLastError();

            glBindFramebuffer(FramebufferTarget.Framebuffer, _framebuffer);
            CheckLastError();

            uint32 colorCount = (uint32)ColorTargets.Count;

            if (colorCount > 0)
            {
                for (int32 i = 0; i < colorCount; i++)
                {
                    FramebufferAttachment colorAttachment = ColorTargets[i];
                    OpenGLTexture glTex = Util.AssertSubtype<Texture, OpenGLTexture>(colorAttachment.Target);
                    glTex.EnsureResourcesCreated();

                    _gd.TextureSamplerManager.SetTextureTransient(glTex.TextureTarget, glTex.Texture);
                    CheckLastError();

                    TextureTarget textureTarget = GetTextureTarget (glTex, colorAttachment.ArrayLayer);

                    if (glTex.ArrayLayers == 1)
                    {
                        glFramebufferTexture2D(
                            FramebufferTarget.Framebuffer,
                            GLFramebufferAttachment.ColorAttachment0 + i,
                            textureTarget,
                            glTex.Texture,
                            (int32)colorAttachment.MipLevel);
                        CheckLastError();
                    }
                    else
                    {
                        glFramebufferTextureLayer(
                            FramebufferTarget.Framebuffer,
                            GLFramebufferAttachment.ColorAttachment0 + i,
                            (uint32)glTex.Texture,
                            (int32)colorAttachment.MipLevel,
                            (int32)colorAttachment.ArrayLayer);
                        CheckLastError();
                    }
                }

                DrawBuffersEnum* bufs = stackalloc DrawBuffersEnum[(int32)colorCount];
                for (int32 i = 0; i < colorCount; i++)
                {
                    bufs[i] = DrawBuffersEnum.ColorAttachment0 + i;
                }
                glDrawBuffers(colorCount, bufs);
                CheckLastError();
            }

            uint32 depthTextureID = 0;
            TextureTarget depthTarget = TextureTarget.Texture2D;
            if (DepthTarget != null)
            {
                OpenGLTexture glDepthTex = Util.AssertSubtype<Texture, OpenGLTexture>(DepthTarget.Value.Target);
                glDepthTex.EnsureResourcesCreated();
                depthTarget = glDepthTex.TextureTarget;

                depthTextureID = glDepthTex.Texture;

                _gd.TextureSamplerManager.SetTextureTransient(depthTarget, glDepthTex.Texture);
                CheckLastError();

                depthTarget = GetTextureTarget (glDepthTex, DepthTarget.Value.ArrayLayer);

                GLFramebufferAttachment framebufferAttachment = GLFramebufferAttachment.DepthAttachment;
                if (FormatHelpers.IsStencilFormat(glDepthTex.Format))
                {
                    framebufferAttachment = GLFramebufferAttachment.DepthStencilAttachment;
                }

                if (glDepthTex.ArrayLayers == 1)
                {
                    glFramebufferTexture2D(
                        FramebufferTarget.Framebuffer,
                        framebufferAttachment,
                        depthTarget,
                        depthTextureID,
                        (int32)DepthTarget.Value.MipLevel);
                    CheckLastError();
                }
                else
                {
                    glFramebufferTextureLayer(
                        FramebufferTarget.Framebuffer,
                        framebufferAttachment,
                        glDepthTex.Texture,
                        (int32)DepthTarget.Value.MipLevel,
                        (int32)DepthTarget.Value.ArrayLayer);
                    CheckLastError();
                }

            }

            FramebufferErrorCode errorCode = glCheckFramebufferStatus(FramebufferTarget.Framebuffer);
            CheckLastError();
            if (errorCode != FramebufferErrorCode.FramebufferComplete)
            {
                Runtime.GALError("Framebuffer was not successfully created: " + errorCode);
            }

            Created = true;
        }

        public override void Dispose()
        {
            if (!_disposeRequested)
            {
                _disposeRequested = true;
                _gd.EnqueueDisposal(this);
            }
        }

        public void DestroyGLResources()
        {
            if (!_disposed)
            {
                _disposed = true;
                uint32 framebuffer = _framebuffer;
                glDeleteFramebuffers(1, ref framebuffer);
                CheckLastError();
            }
        }
    }
}
