using System;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

    /// <summary>
    /// A device object responsible for the creation of graphics resources.
    /// </summary>
    public abstract class ResourceFactory
    {
        /// <summary></summary>
        /// <param name="features"></param>
        protected this(GraphicsDeviceFeatures features)
        {
            Features = features;
        }

        /// <summary>
        /// Gets the <see cref="GraphicsBackend"/> of this instance.
        /// </summary>
        public abstract GraphicsBackend BackendType { get; }

        /// <summary>
        /// Gets the <see cref="GraphicsDeviceFeatures"/> this instance was created with.
        /// </summary>
        public GraphicsDeviceFeatures Features { get; }
        /// <summary>
        /// Creates a new <see cref="Pipeline"/> object.
        /// </summary>
        /// <param name="description">The desired properties of the created object.</param>
        /// <returns>A new <see cref="Pipeline"/> which, when bound to a CommandList, is used to dispatch draw commands.</returns>
        public Pipeline CreateGraphicsPipeline(in GraphicsPipelineDescription description)
        {
#if VALIDATE_USAGE
            if (!description.RasterizerState.DepthClipEnabled && !Features.DepthClipDisable)
            {
                Runtime.GALError(
                    "RasterizerState.DepthClipEnabled must be true if GraphicsDeviceFeatures.DepthClipDisable is not supported.");
            }
            if (description.RasterizerState.FillMode == PolygonFillMode.Wireframe && !Features.FillModeWireframe)
            {
                Runtime.GALError(
                    "PolygonFillMode.Wireframe requires GraphicsDeviceFeatures.FillModeWireframe.");
            }
            if (!Features.IndependentBlend)
            {
                if (description.BlendState.AttachmentStates.Count > 0)
                {
                    BlendAttachmentDescription attachmentState = description.BlendState.AttachmentStates[0];
                    for (int i = 1; i < description.BlendState.AttachmentStates.Count; i++)
                    {
                        if (!attachmentState.Equals(description.BlendState.AttachmentStates[i]))
                        {
                            Runtime.GALError(
                                $"If GraphcsDeviceFeatures.IndependentBlend is false, then all members of BlendState.AttachmentStates must be equal.");
                        }
                    }
                }
            }
            for (VertexLayoutDescription layoutDesc in description.ShaderSet.VertexLayouts)
            {
                bool hasExplicitLayout = false;
                uint32 minOffset = 0;
                for (VertexElementDescription elementDesc in layoutDesc.Elements)
                {
                    if (hasExplicitLayout && elementDesc.Offset == 0)
                    {
                        Runtime.GALError(
                            $"If any vertex element has an explicit offset, then all elements must have an explicit offset.");
                    }

                    if (elementDesc.Offset != 0 && elementDesc.Offset < minOffset)
                    {
                        Runtime.GALError(
                            scope $"Vertex element \"{elementDesc.Name}\" has an explicit offset which overlaps with the previous element.");
                    }

                    minOffset = elementDesc.Offset + FormatSizeHelpers.GetSizeInBytes(elementDesc.Format);
                    hasExplicitLayout |= elementDesc.Offset != 0;
                }

                if (minOffset > layoutDesc.Stride)
                {
                    Runtime.GALError(
                        scope $"The vertex layout's stride ({layoutDesc.Stride}) is less than the full size of the vertex ({minOffset})");
                }
            }
#endif
            return CreateGraphicsPipelineCore(description);
        }

        /// <summary></summary>
        /// <param name="description"></param>
        /// <returns></returns>
        protected abstract Pipeline CreateGraphicsPipelineCore(in GraphicsPipelineDescription description);

        /// <summary>
        /// Creates a new compute <see cref="Pipeline"/> object.
        /// </summary>
        /// <param name="description">The desirede properties of the created object.</param>
        /// <returns>A new <see cref="Pipeline"/> which, when bound to a CommandList, is used to dispatch compute commands.</returns>
        public abstract Pipeline CreateComputePipeline(in ComputePipelineDescription description);

        /// <summary>
        /// Creates a new <see cref="Framebuffer"/>.
        /// </summary>
        /// <param name="description">The desired properties of the created object.</param>
        /// <returns>A new <see cref="Framebuffer"/>.</returns>
        public abstract Framebuffer CreateFramebuffer(in FramebufferDescription description);

        /// <summary>
        /// Creates a new <see cref="Texture"/>.
        /// </summary>
        /// <param name="description">The desired properties of the created object.</param>
        /// <returns>A new <see cref="Texture"/>.</returns>
		public Texture CreateTexture(in TextureDescription description)
        {
#if VALIDATE_USAGE
            if (description.Width == 0 || description.Height == 0 || description.Depth == 0)
            {
                Runtime.GALError("Width, Height, and Depth must be non-zero.");
            }
            if ((description.Format == PixelFormat.D24_UNorm_S8_UInt || description.Format == PixelFormat.D32_Float_S8_UInt)
                && (description.Usage & TextureUsage.DepthStencil) == 0)
            {
                Runtime.GALError("The givel PixelFormat can only be used in a Texture with DepthStencil usage.");
            }
            if ((description.Type == TextureType.Texture1D || description.Type == TextureType.Texture3D)
                && description.SampleCount != TextureSampleCount.Count1)
            {
                Runtime.GALError(
                    scope $"1D and 3D Textures must use {nameof(TextureSampleCount)}.{nameof(TextureSampleCount.Count1)}.");
            }
            if (description.Type == TextureType.Texture1D && !Features.Texture1D)
            {
                Runtime.GALError($"1D Textures are not supported by this device.");
            }
            if ((description.Usage & TextureUsage.Staging) != 0 && description.Usage != TextureUsage.Staging)
            {
                Runtime.GALError(scope $"{nameof(TextureUsage)}.{nameof(TextureUsage.Staging)} cannot be combined with any other flags.");
            }
            if ((description.Usage & TextureUsage.DepthStencil) != 0 && (description.Usage & TextureUsage.GenerateMipmaps) != 0)
            {
                Runtime.GALError(
                    scope $"{nameof(TextureUsage)}.{nameof(TextureUsage.DepthStencil)} and {nameof(TextureUsage)}.{nameof(TextureUsage.GenerateMipmaps)} cannot be combined.");
            }
#endif
            return CreateTextureCore(description);
        }

        /// <summary>
        /// Creates a new <see cref="Texture"/> from an existing native texture.
        /// </summary>
        /// <param name="nativeTexture">A backend-specific handle identifying an existing native texture. See remarks.</param>
        /// <param name="description">The properties of the existing Texture.</param>
        /// <returns>A new <see cref="Texture"/> wrapping the existing native texture.</returns>
        /// <remarks>
        /// The nativeTexture parameter is backend-specific, and the type of data passed in depends on which graphics API is
        /// being used.
        /// When using the Vulkan backend, nativeTexture must be a valid VkImage handle.
        /// When using the Metal backend, nativeTexture must be a valid MTLTexture pointer.
        /// When using the D3D11 backend, nativeTexture must be a valid pointer to an ID3D11Texture1D, ID3D11Texture2D, or
        /// ID3D11Texture3D.
        /// When using the OpenGL backend, nativeTexture must be a valid OpenGL texture name.
        /// The properties of the Texture will be determined from the <see cref="TextureDescription"/> passed in. These
        /// properties must match the true properties of the existing native texture.
        /// </remarks>
        public Texture CreateTexture(uint64 nativeTexture, in TextureDescription description)
            => CreateTextureCore(nativeTexture, description);

        /// <summary>
        /// Creates a new <see cref="Texture"/> from an existing native texture.
        /// </summary>
        /// <param name="nativeTexture">A backend-specific handle identifying an existing native texture. See remarks.</param>
        /// <param name="description">The properties of the existing Texture.</param>
        /// <returns>A new <see cref="Texture"/> wrapping the existing native texture.</returns>
        /// <remarks>
        /// The nativeTexture parameter is backend-specific, and the type of data passed in depends on which graphics API is
        /// being used.
        /// When using the Vulkan backend, nativeTexture must be a valid VkImage handle.
        /// When using the Metal backend, nativeTexture must be a valid MTLTexture pointer.
        /// When using the D3D11 backend, nativeTexture must be a valid pointer to an ID3D11Texture1D, ID3D11Texture2D, or
        /// ID3D11Texture3D.
        /// When using the OpenGL backend, nativeTexture must be a valid OpenGL texture name.
        /// The properties of the Texture will be determined from the <see cref="TextureDescription"/> passed in. These
        /// properties must match the true properties of the existing native texture.
        /// </remarks>
        protected abstract Texture CreateTextureCore(uint64 nativeTexture, in TextureDescription description);

        // TODO: private protected
        /// <summary>
        /// </summary>
        /// <param name="description"></param>
        /// <returns></returns>
        protected abstract Texture CreateTextureCore(in TextureDescription description);

        /// <summary>
        /// Creates a new <see cref="TextureView"/>.
        /// </summary>
        /// <param name="target">The target <see cref="Texture"/> used in the new view.</param>
        /// <returns>A new <see cref="TextureView"/>.</returns>
        public TextureView CreateTextureView(Texture target) => CreateTextureView(TextureViewDescription(target));
        
		/// <summary>
        /// Creates a new <see cref="TextureView"/>.
        /// </summary>
        /// <param name="description">The desired properties of the created object.</param>
        /// <returns>A new <see cref="TextureView"/>.</returns>
        public TextureView CreateTextureView(in TextureViewDescription description)
        {
#if VALIDATE_USAGE
            if (description.MipLevels == 0 || description.ArrayLayers == 0
                || (description.BaseMipLevel + description.MipLevels) > description.Target.MipLevels
                || (description.BaseArrayLayer + description.ArrayLayers) > description.Target.ArrayLayers)
            {
                Runtime.GALError(
                    "TextureView mip level and array layer range must be contained in the target Texture.");
            }
            if ((description.Target.Usage & TextureUsage.Sampled) == 0
                && (description.Target.Usage & TextureUsage.Storage) == 0)
            {
                Runtime.GALError(
                    "To create a TextureView, the target texture must have either Sampled or Storage usage flags.");
            }
            if (!Features.SubsetTextureView &&
                (description.BaseMipLevel != 0 || description.MipLevels != description.Target.MipLevels
                || description.BaseArrayLayer != 0 || description.ArrayLayers != description.Target.ArrayLayers))
            {
                Runtime.GALError("GraphicsDevice does not support subset TextureViews.");
            }
            if (description.Format != null && description.Format != description.Target.Format)
            {
                if (!FormatHelpers.IsFormatViewCompatible(description.Format.Value, description.Target.Format))
                {
                    Runtime.GALError(
                        scope $"Cannot create a TextureView with format {description.Format.Value} targeting a Texture with format {description.Target.Format}. A TextureView's format must have the same size and number of components as the underlying Texture's format, or the same format.");
                }
            }
#endif

            return CreateTextureViewCore(description);
        }

        // TODO: private protected
        /// <summary>
        /// </summary>
        /// <param name="description"></param>
        /// <returns></returns>
        protected abstract TextureView CreateTextureViewCore(in TextureViewDescription description);

        /// <summary>
        /// Creates a new <see cref="DeviceBuffer"/>.
        /// </summary>
        /// <param name="description">The desired properties of the created object.</param>
        /// <returns>A new <see cref="DeviceBuffer"/>.</returns>
        public DeviceBuffer CreateBuffer(in BufferDescription description)
        {
#if VALIDATE_USAGE
            BufferUsage usage = description.Usage;
            if ((usage & BufferUsage.StructuredBufferReadOnly) == BufferUsage.StructuredBufferReadOnly
                || (usage & BufferUsage.StructuredBufferReadWrite) == BufferUsage.StructuredBufferReadWrite)
            {
                if (!Features.StructuredBuffer)
                {
                    Runtime.GALError("GraphicsDevice does not support structured buffers.");
                }

                if (description.StructureByteStride == 0)
                {
                    Runtime.GALError("Structured Buffer objects must have a non-zero StructureByteStride.");
                }

                if ((usage & BufferUsage.StructuredBufferReadWrite) != 0 && usage != BufferUsage.StructuredBufferReadWrite)
                {
                    Runtime.GALError(
                        scope $"{nameof(BufferUsage)}.{nameof(BufferUsage.StructuredBufferReadWrite)} cannot be combined with any other flag.");
                }
                else if ((usage & BufferUsage.VertexBuffer) != 0
                    || (usage & BufferUsage.IndexBuffer) != 0
                    || (usage & BufferUsage.IndirectBuffer) != 0)
                {
                    Runtime.GALError(
                        scope $"Read-Only Structured Buffer objects cannot specify {nameof(BufferUsage)}.{nameof(BufferUsage.VertexBuffer)}, {nameof(BufferUsage)}.{nameof(BufferUsage.IndexBuffer)}, or {nameof(BufferUsage)}.{nameof(BufferUsage.IndirectBuffer)}.");
                }
            }
            else if (description.StructureByteStride != 0)
            {
                Runtime.GALError("Non-structured Buffers must have a StructureByteStride of zero.");
            }
            if ((usage & BufferUsage.Staging) != 0 && usage != BufferUsage.Staging)
            {
                Runtime.GALError("Buffers with Staging Usage must not specify any other Usage flags.");
            }
            if ((usage & BufferUsage.UniformBuffer) != 0 && (description.SizeInBytes % 16) != 0)
            {
                Runtime.GALError($"Uniform buffer size must be a multiple of 16 bytes.");
            }
#endif
            return CreateBufferCore(description);
        }

        // TODO: private protected
        /// <summary>
        /// </summary>
        /// <param name="description"></param>
        /// <returns></returns>
        protected abstract DeviceBuffer CreateBufferCore(in BufferDescription description);

        /// <summary>
        /// Creates a new <see cref="Sampler"/>.
        /// </summary>
        /// <param name="description">The desired properties of the created object.</param>
        /// <returns>A new <see cref="Sampler"/>.</returns>
        public Sampler CreateSampler(in SamplerDescription description)
        {
#if VALIDATE_USAGE
            if (!Features.SamplerLodBias && description.LodBias != 0)
            {
                Runtime.GALError(
                    "GraphicsDevice does not support Sampler LOD bias. SamplerDescription.LodBias must be 0.");
            }
            if (!Features.SamplerAnisotropy && description.Filter == SamplerFilter.Anisotropic)
            {
                Runtime.GALError(
                    "SamplerFilter.Anisotropic cannot be used unless GraphicsDeviceFeatures.SamplerAnisotropy is supported.");
            }
#endif

            return CreateSamplerCore(description);
        }

        /// <summary></summary>
        /// <param name="description"></param>
        /// <returns></returns>
        protected abstract Sampler CreateSamplerCore(in SamplerDescription description);

        /// <summary>
        /// Creates a new <see cref="Shader"/>.
        /// </summary>
        /// <param name="description">The desired properties of the created object.</param>
        /// <returns>A new <see cref="Shader"/>.</returns>
        public Shader CreateShader(in ShaderDescription description)
        {
#if VALIDATE_USAGE
            if (!Features.ComputeShader && description.Stage == ShaderStages.Compute)
            {
                Runtime.GALError("GraphicsDevice does not support Compute Shaders.");
            }
            if (!Features.GeometryShader && description.Stage == ShaderStages.Geometry)
            {
                Runtime.GALError("GraphicsDevice does not support Compute Shaders.");
            }
            if (!Features.TessellationShaders
                && (description.Stage == ShaderStages.TessellationControl
                    || description.Stage == ShaderStages.TessellationEvaluation))
            {
                Runtime.GALError("GraphicsDevice does not support Tessellation Shaders.");
            }
#endif
            return CreateShaderCore(description);
        }

        /// <summary></summary>
        /// <param name="description"></param>
        /// <returns></returns>
        protected abstract Shader CreateShaderCore(in ShaderDescription description);

        /// <summary>
        /// Creates a new <see cref="CommandList"/>.
        /// </summary>
        /// <returns>A new <see cref="CommandList"/>.</returns>
        public CommandList CreateCommandList() => CreateCommandList(CommandListDescription());
        
		/// <summary>
        /// Creates a new <see cref="CommandList"/>.
        /// </summary>
        /// <param name="description">The desired properties of the created object.</param>
        /// <returns>A new <see cref="CommandList"/>.</returns>
        public abstract CommandList CreateCommandList(in CommandListDescription description);

        /// <summary>
        /// Creates a new <see cref="ResourceLayout"/>.
        /// </summary>
        /// <param name="description">The desired properties of the created object.</param>
        /// <returns>A new <see cref="ResourceLayout"/>.</returns>
        public abstract ResourceLayout CreateResourceLayout(in ResourceLayoutDescription description);

        /// <summary>
        /// Creates a new <see cref="ResourceSet"/>.
        /// </summary>
        /// <param name="description">The desired properties of the created object.</param>
        /// <returns>A new <see cref="ResourceSet"/>.</returns>
        public abstract ResourceSet CreateResourceSet(in ResourceSetDescription description);

        /// <summary>
        /// Creates a new <see cref="Fence"/> in the given state.
        /// </summary>
        /// <param name="signaled">A value indicating whether the Fence should be in the signaled state when created.</param>
        /// <returns>A new <see cref="Fence"/>.</returns>
        public abstract Fence CreateFence(bool signaled);

        /// <summary>
        /// Creates a new <see cref="Swapchain"/>.
        /// </summary>
        /// <param name="description">The desired properties of the created object.</param>
        /// <returns>A new <see cref="Swapchain"/>.</returns>
        public abstract Swapchain CreateSwapchain(in SwapchainDescription description);
    }
}
