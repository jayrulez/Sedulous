using System;
using System.Diagnostics;
using System.Threading;
using System.Collections;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

    /// <summary>
    /// Represents an abstract graphics device, capable of creating device resources and executing commands.
    /// </summary>
    public abstract class GraphicsDevice : IDisposable
    {
        private readonly Monitor _deferredDisposalLock = new .() ~ delete _;
        private readonly List<IDisposable> _disposables = new List<IDisposable>() ~ delete _;
        private Sampler _aniso4xSampler;

        internal this() { }

        /// <summary>
        /// Gets the name of the device.
        /// </summary>
        public abstract String DeviceName { get; }

        /// <summary>
        /// Gets the name of the device vendor.
        /// </summary>
        public abstract String VendorName { get; }

        /// <summary>
        /// Gets the API version of the graphics backend.
        /// </summary>
        public abstract GraphicsApiVersion ApiVersion { get; }

        /// <summary>
        /// Gets a value identifying the specific graphics API used by this instance.
        /// </summary>
        public abstract GraphicsBackend BackendType { get; }

        /// <summary>
        /// Gets a value identifying whether texture coordinates begin in the top left corner of a Texture.
        /// If true, (0, 0) refers to the top-left texel of a Texture. If false, (0, 0) refers to the bottom-left 
        /// texel of a Texture. This property is useful for determining how the output of a Framebuffer should be sampled.
        /// </summary>
        public abstract bool IsUvOriginTopLeft { get; }

        /// <summary>
        /// Gets a value indicating whether this device's depth values range from 0 to 1.
        /// If false, depth values instead range from -1 to 1.
        /// </summary>
        public abstract bool IsDepthRangeZeroToOne { get; }

        /// <summary>
        /// Gets a value indicating whether this device's clip space Y values increase from top (-1) to bottom (1).
        /// If false, clip space Y values instead increase from bottom (-1) to top (1).
        /// </summary>
        public abstract bool IsClipSpaceYInverted { get; }

        /// <summary>
        /// Gets the <see cref="ResourceFactory"/> controlled by this instance.
        /// </summary>
        public abstract ResourceFactory ResourceFactory { get; }

        /// <summary>
        /// Retrieves the main Swapchain for this device. This property is only valid if the device was created with a main
        /// Swapchain, and will return null otherwise.
        /// </summary>
        public abstract Swapchain MainSwapchain { get; }

        /// <summary>
        /// Gets a <see cref="GraphicsDeviceFeatures"/> which enumerates the optional features supported by this instance.
        /// </summary>
        public abstract GraphicsDeviceFeatures Features { get; }

        /// <summary>
        /// Gets or sets whether the main Swapchain's <see cref="SwapBuffers()"/> should be synchronized to the window system's
        /// vertical refresh rate.
        /// This is equivalent to <see cref="MainSwapchain"/>.<see cref="Swapchain.SyncToVerticalBlank"/>.
        /// This property cannot be set if this GraphicsDevice was created without a main Swapchain.
        /// </summary>
        public virtual bool SyncToVerticalBlank
        {
            get => MainSwapchain?.SyncToVerticalBlank ?? false;
            set
            {
                if (MainSwapchain == null)
                {
                    Runtime.GALError($"This GraphicsDevice was created without a main Swapchain. This property cannot be set.");
                }

                MainSwapchain.SyncToVerticalBlank = value;
            }
        }

        /// <summary>
        /// The required alignment, in bytes, for uniform buffer offsets. <see cref="DeviceBufferRange.Offset"/> must be a
        /// multiple of this value. When binding a <see cref="ResourceSet"/> to a <see cref="CommandList"/> with an overload
        /// accepting dynamic offsets, each offset must be a multiple of this value.
        /// </summary>
        public uint32 UniformBufferMinOffsetAlignment => GetUniformBufferMinOffsetAlignmentCore();

        /// <summary>
        /// The required alignment, in bytes, for structured buffer offsets. <see cref="DeviceBufferRange.Offset"/> must be a
        /// multiple of this value. When binding a <see cref="ResourceSet"/> to a <see cref="CommandList"/> with an overload
        /// accepting dynamic offsets, each offset must be a multiple of this value.
        /// </summary>
        public uint32 StructuredBufferMinOffsetAlignment => GetStructuredBufferMinOffsetAlignmentCore();

        protected abstract uint32 GetUniformBufferMinOffsetAlignmentCore();
        protected abstract uint32 GetStructuredBufferMinOffsetAlignmentCore();

        /// <summary>
        /// Submits the given <see cref="CommandList"/> for execution by this device.
        /// Commands submitted in this way may not be completed when this method returns.
        /// Use <see cref="WaitForIdle"/> to wait for all submitted commands to complete.
        /// <see cref="CommandList.End"/> must have been called on <paramref name="commandList"/> for this method to succeed.
        /// </summary>
        /// <param name="commandList">The completed <see cref="CommandList"/> to execute. <see cref="CommandList.End"/> must have
        /// been previously called on this object.</param>
        public void SubmitCommands(CommandList commandList) => SubmitCommandsCore(commandList, null);

        /// <summary>
        /// Submits the given <see cref="CommandList"/> for execution by this device.
        /// Commands submitted in this way may not be completed when this method returns.
        /// Use <see cref="WaitForIdle"/> to wait for all submitted commands to complete.
        /// <see cref="CommandList.End"/> must have been called on <paramref name="commandList"/> for this method to succeed.
        /// </summary>
        /// <param name="commandList">The completed <see cref="CommandList"/> to execute. <see cref="CommandList.End"/> must have
        /// been previously called on this object.</param>
        /// <param name="fence">A <see cref="Fence"/> which will become signaled after this submission fully completes
        /// execution.</param>
        public void SubmitCommands(CommandList commandList, Fence fence) => SubmitCommandsCore(commandList, fence);

        protected abstract void SubmitCommandsCore(
            CommandList commandList,
            Fence fence);

        /// <summary>
        /// Blocks the calling thread until the given <see cref="Fence"/> becomes signaled.
        /// </summary>
        /// <param name="fence">The <see cref="Fence"/> instance to wait on.</param>
        public void WaitForFence(Fence fence)
        {
            if (!WaitForFence(fence, uint64.MaxValue))
            {
                Runtime.GALError("The operation timed out before the Fence was signaled.");
            }
        }

        /// <summary>
        /// Blocks the calling thread until the given <see cref="Fence"/> becomes signaled, or until a time greater than the
        /// given TimeSpan has elapsed.
        /// </summary>
        /// <param name="fence">The <see cref="Fence"/> instance to wait on.</param>
        /// <param name="timeout">A TimeSpan indicating the maximum time to wait on the Fence.</param>
        /// <returns>True if the Fence was signaled. False if the timeout was reached instead.</returns>
        public bool WaitForFence(Fence fence, TimeSpan timeout)
            => WaitForFence(fence, (uint64)timeout.TotalMilliseconds * 1000000);
        /// <summary>
        /// Blocks the calling thread until the given <see cref="Fence"/> becomes signaled, or until a time greater than the
        /// given TimeSpan has elapsed.
        /// </summary>
        /// <param name="fence">The <see cref="Fence"/> instance to wait on.</param>
        /// <param name="nanosecondTimeout">A value in nanoseconds, indicating the maximum time to wait on the Fence.</param>
        /// <returns>True if the Fence was signaled. False if the timeout was reached instead.</returns>
        public abstract bool WaitForFence(Fence fence, uint64 nanosecondTimeout);

        /// <summary>
        /// Blocks the calling thread until one or all of the given <see cref="Fence"/> instances have become signaled.
        /// </summary>
        /// <param name="fences">An array of <see cref="Fence"/> objects to wait on.</param>
        /// <param name="waitAll">If true, then this method blocks until all of the given Fences become signaled.
        /// If false, then this method only waits until one of the Fences become signaled.</param>
        public void WaitForFences(Fence[] fences, bool waitAll)
        {
            if (!WaitForFences(fences, waitAll, uint64.MaxValue))
            {
                Runtime.GALError("The operation timed out before the Fence(s) were signaled.");
            }
        }

        /// <summary>
        /// Blocks the calling thread until one or all of the given <see cref="Fence"/> instances have become signaled,
        /// or until the given timeout has been reached.
        /// </summary>
        /// <param name="fences">An array of <see cref="Fence"/> objects to wait on.</param>
        /// <param name="waitAll">If true, then this method blocks until all of the given Fences become signaled.
        /// If false, then this method only waits until one of the Fences become signaled.</param>
        /// <param name="timeout">A TimeSpan indicating the maximum time to wait on the Fences.</param>
        /// <returns>True if the Fence was signaled. False if the timeout was reached instead.</returns>
        public bool WaitForFences(Fence[] fences, bool waitAll, TimeSpan timeout)
            => WaitForFences(fences, waitAll, (uint64)timeout.TotalMilliseconds * 1000000);

        /// <summary>
        /// Blocks the calling thread until one or all of the given <see cref="Fence"/> instances have become signaled,
        /// or until the given timeout has been reached.
        /// </summary>
        /// <param name="fences">An array of <see cref="Fence"/> objects to wait on.</param>
        /// <param name="waitAll">If true, then this method blocks until all of the given Fences become signaled.
        /// If false, then this method only waits until one of the Fences become signaled.</param>
        /// <param name="nanosecondTimeout">A value in nanoseconds, indicating the maximum time to wait on the Fence.  Pass uint64.MaxValue to wait indefinitely.</param>
        /// <returns>True if the Fence was signaled. False if the timeout was reached instead.</returns>
        public abstract bool WaitForFences(Fence[] fences, bool waitAll, uint64 nanosecondTimeout);

        /// <summary>
        /// Resets the given <see cref="Fence"/> to the unsignaled state.
        /// </summary>
        /// <param name="fence">The <see cref="Fence"/> instance to reset.</param>
        public abstract void ResetFence(Fence fence);

        /// <summary>
        /// Swaps the buffers of the main swapchain and presents the rendered image to the screen.
        /// This is equivalent to passing <see cref="MainSwapchain"/> to <see cref="SwapBuffers(Swapchain)"/>.
        /// This method can only be called if this GraphicsDevice was created with a main Swapchain.
        /// </summary>
        public void SwapBuffers()
        {
            if (MainSwapchain == null)
            {
                Runtime.GALError("This GraphicsDevice was created without a main Swapchain, so the requested operation cannot be performed.");
            }

            SwapBuffers(MainSwapchain);
        }

        /// <summary>
        /// Swaps the buffers of the given swapchain.
        /// </summary>
        /// <param name="swapchain">The <see cref="Swapchain"/> to swap and present.</param>
        public void SwapBuffers(Swapchain swapchain) => SwapBuffersCore(swapchain);

        protected abstract void SwapBuffersCore(Swapchain swapchain);

        /// <summary>
        /// Gets a <see cref="Framebuffer"/> object representing the render targets of the main swapchain.
        /// This is equivalent to <see cref="MainSwapchain"/>.<see cref="Swapchain.Framebuffer"/>.
        /// If this GraphicsDevice was created without a main Swapchain, then this returns null.
        /// </summary>
        public Framebuffer SwapchainFramebuffer => MainSwapchain?.Framebuffer;

        /// <summary>
        /// Notifies this instance that the main window has been resized. This causes the <see cref="SwapchainFramebuffer"/> to
        /// be appropriately resized and recreated.
        /// This is equivalent to calling <see cref="MainSwapchain"/>.<see cref="Swapchain.Resize(uint32, uint32)"/>.
        /// This method can only be called if this GraphicsDevice was created with a main Swapchain.
        /// </summary>
        /// <param name="width">The new width of the main window.</param>
        /// <param name="height">The new height of the main window.</param>
        public void ResizeMainWindow(uint32 width, uint32 height)
        {
            if (MainSwapchain == null)
            {
                Runtime.GALError("This GraphicsDevice was created without a main Swapchain, so the requested operation cannot be performed.");
            }

            MainSwapchain.Resize(width, height);
        }

        /// <summary>
        /// A blocking method that returns when all submitted <see cref="CommandList"/> objects have fully completed.
        /// </summary>
        public void WaitForIdle()
        {
            WaitForIdleCore();
            FlushDeferredDisposals();
        }

        protected abstract void WaitForIdleCore();

        /// <summary>
        /// Gets the maximum sample count supported by the given <see cref="PixelFormat"/>.
        /// </summary>
        /// <param name="format">The format to query.</param>
        /// <param name="depthFormat">Whether the format will be used in a depth texture.</param>
        /// <returns>A <see cref="TextureSampleCount"/> value representing the maximum count that a <see cref="Texture"/> of that
        /// format can be created with.</returns>
        public abstract TextureSampleCount GetSampleCountLimit(PixelFormat format, bool depthFormat);

        /// <summary>
        /// Maps a <see cref="DeviceBuffer"/> or <see cref="Texture"/> into a CPU-accessible data region. For Texture resources, this
        /// overload maps the first subresource.
        /// </summary>
        /// <param name="resource">The <see cref="DeviceBuffer"/> or <see cref="Texture"/> resource to map.</param>
        /// <param name="mode">The <see cref="MapMode"/> to use.</param>
        /// <returns>A <see cref="MappedResource"/> structure describing the mapped data region.</returns>
        public MappedResource Map(MappableResource resource, MapMode mode) => Map(resource, mode, 0);
        /// <summary>
        /// Maps a <see cref="DeviceBuffer"/> or <see cref="Texture"/> into a CPU-accessible data region.
        /// </summary>
        /// <param name="resource">The <see cref="DeviceBuffer"/> or <see cref="Texture"/> resource to map.</param>
        /// <param name="mode">The <see cref="MapMode"/> to use.</param>
        /// <param name="subresource">The subresource to map. Subresources are indexed first by mip slice, then by array layer.
        /// For <see cref="DeviceBuffer"/> resources, this parameter must be 0.</param>
        /// <returns>A <see cref="MappedResource"/> structure describing the mapped data region.</returns>
        public MappedResource Map(MappableResource resource, MapMode mode, uint32 subresource)
        {
#if VALIDATE_USAGE
            if (let buffer = resource as DeviceBuffer)
            {
                if ((buffer.Usage & BufferUsage.Dynamic) != BufferUsage.Dynamic
                    && (buffer.Usage & BufferUsage.Staging) != BufferUsage.Staging)
                {
                    Runtime.GALError("Buffers must have the Staging or Dynamic usage flag to be mapped.");
                }
                if (subresource != 0)
                {
                    Runtime.GALError("Subresource must be 0 for Buffer resources.");
                }
                if ((mode == MapMode.Read || mode == MapMode.ReadWrite) && (buffer.Usage & BufferUsage.Staging) == 0)
                {
                    Runtime.GALError(
                        scope $"{nameof(MapMode)}.{nameof(MapMode.Read)} and {nameof(MapMode)}.{nameof(MapMode.ReadWrite)} can only be used on buffers created with {nameof(BufferUsage)}.{nameof(BufferUsage.Staging)}.");
                }
            }
            else if (let tex = resource as Texture)
            {
                if ((tex.Usage & TextureUsage.Staging) == 0)
                {
                    Runtime.GALError("Texture must have the Staging usage flag to be mapped.");
                }
                if (subresource >= tex.ArrayLayers * tex.MipLevels)
                {
                    Runtime.GALError(
                        "Subresource must be less than the number of subresources in the Texture being mapped.");
                }
            }
#endif

            return MapCore(resource, mode, subresource);
        }

        /// <summary>
        /// </summary>
        /// <param name="resource"></param>
        /// <param name="mode"></param>
        /// <param name="subresource"></param>
        /// <returns></returns>
        protected abstract MappedResource MapCore(MappableResource resource, MapMode mode, uint32 subresource);

        /// <summary>
        /// Maps a <see cref="DeviceBuffer"/> or <see cref="Texture"/> into a CPU-accessible data region, and returns a structured
        /// view over that region. For Texture resources, this overload maps the first subresource.
        /// </summary>
        /// <param name="resource">The <see cref="DeviceBuffer"/> or <see cref="Texture"/> resource to map.</param>
        /// <param name="mode">The <see cref="MapMode"/> to use.</param>
        /// <typeparam name="T">The blittable value type which mapped data is viewed as.</typeparam>
        /// <returns>A <see cref="MappedResource"/> structure describing the mapped data region.</returns>
        public MappedResourceView<T> Map<T>(MappableResource resource, MapMode mode) where T : struct
            => Map<T>(resource, mode, 0);
        /// <summary>
        /// Maps a <see cref="DeviceBuffer"/> or <see cref="Texture"/> into a CPU-accessible data region, and returns a structured
        /// view over that region.
        /// </summary>
        /// <param name="resource">The <see cref="DeviceBuffer"/> or <see cref="Texture"/> resource to map.</param>
        /// <param name="mode">The <see cref="MapMode"/> to use.</param>
        /// <param name="subresource">The subresource to map. Subresources are indexed first by mip slice, then by array layer.</param>
        /// <typeparam name="T">The blittable value type which mapped data is viewed as.</typeparam>
        /// <returns>A <see cref="MappedResource"/> structure describing the mapped data region.</returns>
        public MappedResourceView<T> Map<T>(MappableResource resource, MapMode mode, uint32 subresource) where T : struct
        {
            MappedResource mappedResource = Map(resource, mode, subresource);
            return MappedResourceView<T>(mappedResource);
        }

        /// <summary>
        /// Invalidates a previously-mapped data region for the given <see cref="DeviceBuffer"/> or <see cref="Texture"/>.
        /// For <see cref="Texture"/> resources, this unmaps the first subresource.
        /// </summary>
        /// <param name="resource">The resource to unmap.</param>
        public void Unmap(MappableResource resource) => Unmap(resource, 0);
        /// <summary>
        /// Invalidates a previously-mapped data region for the given <see cref="DeviceBuffer"/> or <see cref="Texture"/>.
        /// </summary>
        /// <param name="resource">The resource to unmap.</param>
        /// <param name="subresource">The subresource to unmap. Subresources are indexed first by mip slice, then by array layer.
        /// For <see cref="DeviceBuffer"/> resources, this parameter must be 0.</param>
        public void Unmap(MappableResource resource, uint32 subresource)
        {
            UnmapCore(resource, subresource);
        }

        /// <summary>
        /// </summary>
        /// <param name="resource"></param>
        /// <param name="subresource"></param>
        protected abstract void UnmapCore(MappableResource resource, uint32 subresource);

        /// <summary>
        /// Updates a portion of a <see cref="Texture"/> resource with new data.
        /// </summary>
        /// <param name="texture">The resource to update.</param>
        /// <param name="source">A pointer to the start of the data to upload. This must point to tightly-packed pixel data for
        /// the region specified.</param>
        /// <param name="sizeInBytes">The number of bytes to upload. This value must match the total size of the texture region
        /// specified.</param>
        /// <param name="x">The minimum X value of the updated region.</param>
        /// <param name="y">The minimum Y value of the updated region.</param>
        /// <param name="z">The minimum Z value of the updated region.</param>
        /// <param name="width">The width of the updated region, in texels.</param>
        /// <param name="height">The height of the updated region, in texels.</param>
        /// <param name="depth">The depth of the updated region, in texels.</param>
        /// <param name="mipLevel">The mipmap level to update. Must be less than the total number of mipmaps contained in the
        /// <see cref="Texture"/>.</param>
        /// <param name="arrayLayer">The array layer to update. Must be less than the total array layer count contained in the
        /// <see cref="Texture"/>.</param>
        public void UpdateTexture(
            Texture texture,
            void* source,
            uint32 sizeInBytes,
            uint32 x, uint32 y, uint32 z,
            uint32 width, uint32 height, uint32 depth,
            uint32 mipLevel, uint32 arrayLayer)
        {
#if VALIDATE_USAGE
            ValidateUpdateTextureParameters(texture, sizeInBytes, x, y, z, width, height, depth, mipLevel, arrayLayer);
#endif
            UpdateTextureCore(texture, source, sizeInBytes, x, y, z, width, height, depth, mipLevel, arrayLayer);
        }

        /// <summary>
        /// Updates a portion of a <see cref="Texture"/> resource with new data contained in an array
        /// </summary>
        /// <param name="texture">The resource to update.</param>
        /// <param name="source">An array containing the data to upload. This must contain tightly-packed pixel data for the
        /// region specified.</param>
        /// <param name="x">The minimum X value of the updated region.</param>
        /// <param name="y">The minimum Y value of the updated region.</param>
        /// <param name="z">The minimum Z value of the updated region.</param>
        /// <param name="width">The width of the updated region, in texels.</param>
        /// <param name="height">The height of the updated region, in texels.</param>
        /// <param name="depth">The depth of the updated region, in texels.</param>
        /// <param name="mipLevel">The mipmap level to update. Must be less than the total number of mipmaps contained in the
        /// <see cref="Texture"/>.</param>
        /// <param name="arrayLayer">The array layer to update. Must be less than the total array layer count contained in the
        /// <see cref="Texture"/>.</param>
        public void UpdateTexture<T>(
            Texture texture,
            T[] source,
            uint32 x, uint32 y, uint32 z,
            uint32 width, uint32 height, uint32 depth,
            uint32 mipLevel, uint32 arrayLayer) where T : struct
        {
            UpdateTexture(texture, (Span<T>)source, x, y, z, width, height, depth, mipLevel, arrayLayer);
        }

        /*/// <summary>
        /// Updates a portion of a <see cref="Texture"/> resource with new data contained in an array
        /// </summary>
        /// <param name="texture">The resource to update.</param>
        /// <param name="source">A readonly span containing the data to upload. This must contain tightly-packed pixel data for the
        /// region specified.</param>
        /// <param name="x">The minimum X value of the updated region.</param>
        /// <param name="y">The minimum Y value of the updated region.</param>
        /// <param name="z">The minimum Z value of the updated region.</param>
        /// <param name="width">The width of the updated region, in texels.</param>
        /// <param name="height">The height of the updated region, in texels.</param>
        /// <param name="depth">The depth of the updated region, in texels.</param>
        /// <param name="mipLevel">The mipmap level to update. Must be less than the total number of mipmaps contained in the
        /// <see cref="Texture"/>.</param>
        /// <param name="arrayLayer">The array layer to update. Must be less than the total array layer count contained in the
        /// <see cref="Texture"/>.</param>
        public void UpdateTexture<T>(
            Texture texture,
            ReadOnlySpan<T> source,
            uint32 x, uint32 y, uint32 z,
            uint32 width, uint32 height, uint32 depth,
            uint32 mipLevel, uint32 arrayLayer) where T : struct
        {
            uint32 sizeInBytes = (uint32)(sizeof(T) * source.Length);
#if VALIDATE_USAGE
            ValidateUpdateTextureParameters(texture, sizeInBytes, x, y, z, width, height, depth, mipLevel, arrayLayer);
#endif

            fixed (void* pin = &MemoryMarshal.GetReference(source))
            {
                UpdateTextureCore(
                texture,
                (IntPtr)pin,
                sizeInBytes,
                x, y, z,
                width, height, depth,
                mipLevel, arrayLayer);
            }
        }*/

        /// <summary>
        /// Updates a portion of a <see cref="Texture"/> resource with new data contained in an array
        /// </summary>
        /// <param name="texture">The resource to update.</param>
        /// <param name="source">A readonly span containing the data to upload. This must contain tightly-packed pixel data for the
        /// region specified.</param>
        /// <param name="x">The minimum X value of the updated region.</param>
        /// <param name="y">The minimum Y value of the updated region.</param>
        /// <param name="z">The minimum Z value of the updated region.</param>
        /// <param name="width">The width of the updated region, in texels.</param>
        /// <param name="height">The height of the updated region, in texels.</param>
        /// <param name="depth">The depth of the updated region, in texels.</param>
        /// <param name="mipLevel">The mipmap level to update. Must be less than the total number of mipmaps contained in the
        /// <see cref="Texture"/>.</param>
        /// <param name="arrayLayer">The array layer to update. Must be less than the total array layer count contained in the
        /// <see cref="Texture"/>.</param>
        public void UpdateTexture<T>(
            Texture texture,
            Span<T> source,
            uint32 x, uint32 y, uint32 z,
            uint32 width, uint32 height, uint32 depth,
            uint32 mipLevel, uint32 arrayLayer) where T : struct
        {
			uint32 sizeInBytes = (uint32)(sizeof(T) * source.Length);
            UpdateTexture(texture, source.Ptr, sizeInBytes, x, y, z, width, height, depth, mipLevel, arrayLayer);
        }

        protected abstract void UpdateTextureCore(
            Texture texture,
            void* source,
            uint32 sizeInBytes,
            uint32 x, uint32 y, uint32 z,
            uint32 width, uint32 height, uint32 depth,
            uint32 mipLevel, uint32 arrayLayer);

#if !VALIDATE_USAGE
        [SkipCall]//[Conditional("VALIDATE_USAGE")]
#endif
        private static void ValidateUpdateTextureParameters(
            Texture texture,
            uint32 sizeInBytes,
            uint32 x, uint32 y, uint32 z,
            uint32 width, uint32 height, uint32 depth,
            uint32 mipLevel, uint32 arrayLayer)
        {
            if (FormatHelpers.IsCompressedFormat(texture.Format))
            {
                if (x % 4 != 0 || y % 4 != 0 || height % 4 != 0 || width % 4 != 0)
                {
                    Util.GetMipDimensions(texture, mipLevel, var mipWidth, var mipHeight, ?);
                    if (width != mipWidth && height != mipHeight)
                    {
                        Runtime.GALError($"Updates to block-compressed textures must use a region that is block-size aligned and sized.");
                    }
                }
            }
            uint32 expectedSize = FormatHelpers.GetRegionSize(width, height, depth, texture.Format);
            if (sizeInBytes < expectedSize)
            {
                Runtime.GALError(
                    scope $"The data size is less than expected for the given update region. At least {expectedSize} bytes must be provided, but only {sizeInBytes} were.");
            }

            // Compressed textures don't necessarily need to have a Texture.Width and Texture.Height that are a multiple of 4.
            // But the mipdata width and height *does* need to be a multiple of 4.
            uint32 roundedTextureWidth, roundedTextureHeight;
            if (FormatHelpers.IsCompressedFormat(texture.Format))
            {
                roundedTextureWidth = (texture.Width + 3) / 4 * 4;
                roundedTextureHeight = (texture.Height + 3) / 4 * 4;
            }
            else
            {
                roundedTextureWidth = texture.Width;
                roundedTextureHeight = texture.Height;
            }

            if (x + width > roundedTextureWidth || y + height > roundedTextureHeight || z + depth > texture.Depth)
            {
                Runtime.GALError($"The given region does not fit into the Texture.");
            }

            if (mipLevel >= texture.MipLevels)
            {
                Runtime.GALError(
                    scope $"{nameof(mipLevel)} ({mipLevel}) must be less than the Texture's mip level count ({texture.MipLevels}).");
            }

            uint32 effectiveArrayLayers = texture.ArrayLayers;
            if ((texture.Usage & TextureUsage.Cubemap) != 0)
            {
                effectiveArrayLayers *= 6;
            }
            if (arrayLayer >= effectiveArrayLayers)
            {
                Runtime.GALError(
                    scope $"{nameof(arrayLayer)} ({arrayLayer}) must be less than the Texture's effective array layer count ({effectiveArrayLayers}).");
            }
        }

        /// <summary>
        /// Updates a <see cref="DeviceBuffer"/> region with new data.
        /// This function must be used with a blittable value type <typeparamref name="T"/>.
        /// </summary>
        /// <typeparam name="T">The type of data to upload.</typeparam>
        /// <param name="buffer">The resource to update.</param>
        /// <param name="bufferOffsetInBytes">An offset, in bytes, from the beginning of the <see cref="DeviceBuffer"/> storage, at
        /// which new data will be uploaded.</param>
        /// <param name="source">The value to upload.</param>
        public void UpdateBuffer<T>(
            DeviceBuffer buffer,
            uint32 bufferOffsetInBytes,
            T source) where T : struct
        {
			var source;
            UpdateBuffer(buffer, bufferOffsetInBytes, &source, (uint32)sizeof(T));
        }

        /// <summary>
        /// Updates a <see cref="DeviceBuffer"/> region with new data.
        /// This function must be used with a blittable value type <typeparamref name="T"/>.
        /// </summary>
        /// <typeparam name="T">The type of data to upload.</typeparam>
        /// <param name="buffer">The resource to update.</param>
        /// <param name="bufferOffsetInBytes">An offset, in bytes, from the beginning of the <see cref="DeviceBuffer"/>'s storage, at
        /// which new data will be uploaded.</param>
        /// <param name="source">A reference to the single value to upload.</param>
        public void UpdateBuffer<T>(
            DeviceBuffer buffer,
            uint32 bufferOffsetInBytes,
            ref T source) where T : struct
        {
            UpdateBuffer(buffer, bufferOffsetInBytes, &source, (uint32)sizeof(T));
        }

        /// <summary>
        /// Updates a <see cref="DeviceBuffer"/> region with new data.
        /// This function must be used with a blittable value type <typeparamref name="T"/>.
        /// </summary>
        /// <typeparam name="T">The type of data to upload.</typeparam>
        /// <param name="buffer">The resource to update.</param>
        /// <param name="bufferOffsetInBytes">An offset, in bytes, from the beginning of the <see cref="DeviceBuffer"/>'s storage, at
        /// which new data will be uploaded.</param>
        /// <param name="source">A reference to the first of a series of values to upload.</param>
        /// <param name="sizeInBytes">The total size of the uploaded data, in bytes.</param>
        public void UpdateBuffer<T>(
            DeviceBuffer buffer,
            uint32 bufferOffsetInBytes,
            ref T source,
            uint32 sizeInBytes) where T : struct
        {
            UpdateBuffer(buffer, bufferOffsetInBytes, &source, sizeInBytes);
        }

        /// <summary>
        /// Updates a <see cref="DeviceBuffer"/> region with new data.
        /// This function must be used with a blittable value type <typeparamref name="T"/>.
        /// </summary>
        /// <typeparam name="T">The type of data to upload.</typeparam>
        /// <param name="buffer">The resource to update.</param>
        /// <param name="bufferOffsetInBytes">An offset, in bytes, from the beginning of the <see cref="DeviceBuffer"/>'s storage, at
        /// which new data will be uploaded.</param>
        /// <param name="source">An array containing the data to upload.</param>
        public void UpdateBuffer<T>(
            DeviceBuffer buffer,
            uint32 bufferOffsetInBytes,
            T[] source) where T : struct
        {
            UpdateBuffer(buffer, bufferOffsetInBytes, (Span<T>)source);
        }

        /*/// <summary>
        /// Updates a <see cref="DeviceBuffer"/> region with new data.
        /// This function must be used with a blittable value type <typeparamref name="T"/>.
        /// </summary>
        /// <typeparam name="T">The type of data to upload.</typeparam>
        /// <param name="buffer">The resource to update.</param>
        /// <param name="bufferOffsetInBytes">An offset, in bytes, from the beginning of the <see cref="DeviceBuffer"/>'s storage, at
        /// which new data will be uploaded.</param>
        /// <param name="source">A readonly span containing the data to upload.</param>
        public void UpdateBuffer<T>(
            DeviceBuffer buffer,
            uint32 bufferOffsetInBytes,
            ReadOnlySpan<T> source) where T : struct
        {
            fixed (void* pin = &MemoryMarshal.GetReference(source))
            {
                UpdateBuffer(buffer, bufferOffsetInBytes, (IntPtr)pin, (uint32)(sizeof(T) * source.Length));
            }
        }*/

        /// <summary>
        /// Updates a <see cref="DeviceBuffer"/> region with new data.
        /// This function must be used with a blittable value type <typeparamref name="T"/>.
        /// </summary>
        /// <typeparam name="T">The type of data to upload.</typeparam>
        /// <param name="buffer">The resource to update.</param>
        /// <param name="bufferOffsetInBytes">An offset, in bytes, from the beginning of the <see cref="DeviceBuffer"/>'s storage, at
        /// which new data will be uploaded.</param>
        /// <param name="source">A span containing the data to upload.</param>
        public void UpdateBuffer<T>(
            DeviceBuffer buffer,
            uint32 bufferOffsetInBytes,
            Span<T> source) where T : struct
        {
            UpdateBuffer(buffer, bufferOffsetInBytes, source.Ptr, (uint32)(sizeof(T) * source.Length));
        }

        /// <summary>
        /// Updates a <see cref="DeviceBuffer"/> region with new data.
        /// </summary>
        /// <param name="buffer">The resource to update.</param>
        /// <param name="bufferOffsetInBytes">An offset, in bytes, from the beginning of the <see cref="DeviceBuffer"/>'s storage, at
        /// which new data will be uploaded.</param>
        /// <param name="source">A pointer to the start of the data to upload.</param>
        /// <param name="sizeInBytes">The total size of the uploaded data, in bytes.</param>
        public void UpdateBuffer(
            DeviceBuffer buffer,
            uint32 bufferOffsetInBytes,
            void* source,
            uint32 sizeInBytes)
        {
            if (bufferOffsetInBytes + sizeInBytes > buffer.SizeInBytes)
            {
                Runtime.GALError(
                    scope $"The data size given to UpdateBuffer is too large. The given buffer can only hold {buffer.SizeInBytes} total bytes. The requested update would require {bufferOffsetInBytes + sizeInBytes} bytes.");
            }
            if (sizeInBytes == 0)
            {
                return;
            }
            UpdateBufferCore(buffer, bufferOffsetInBytes, source, sizeInBytes);
        }

        protected abstract void UpdateBufferCore(DeviceBuffer buffer, uint32 bufferOffsetInBytes, void* source, uint32 sizeInBytes);

        /// <summary>
        /// Gets whether or not the given <see cref="PixelFormat"/>, <see cref="TextureType"/>, and <see cref="TextureUsage"/>
        /// combination is supported by this instance.
        /// </summary>
        /// <param name="format">The PixelFormat to query.</param>
        /// <param name="type">The TextureType to query.</param>
        /// <param name="usage">The TextureUsage to query.</param>
        /// <returns>True if the given combination is supported; false otherwise.</returns>
        public bool GetPixelFormatSupport(
            PixelFormat format,
            TextureType type,
            TextureUsage usage)
        {
            return GetPixelFormatSupportCore(format, type, usage, ?);
        }

        /// <summary>
        /// Gets whether or not the given <see cref="PixelFormat"/>, <see cref="TextureType"/>, and <see cref="TextureUsage"/>
        /// combination is supported by this instance, and also gets the device-specific properties supported by this instance.
        /// </summary>
        /// <param name="format">The PixelFormat to query.</param>
        /// <param name="type">The TextureType to query.</param>
        /// <param name="usage">The TextureUsage to query.</param>
        /// <param name="properties">If the combination is supported, then this parameter describes the limits of a Texture
        /// created using the given combination of attributes.</param>
        /// <returns>True if the given combination is supported; false otherwise. If the combination is supported,
        /// then <paramref name="properties"/> contains the limits supported by this instance.</returns>
        public bool GetPixelFormatSupport(
            PixelFormat format,
            TextureType type,
            TextureUsage usage,
            out PixelFormatProperties properties)
        {
            return GetPixelFormatSupportCore(format, type, usage, out properties);
        }

        protected abstract bool GetPixelFormatSupportCore(
            PixelFormat format,
            TextureType type,
            TextureUsage usage,
            out PixelFormatProperties properties);

        /// <summary>
        /// Adds the given object to a deferred disposal list, which will be processed when this GraphicsDevice becomes idle.
        /// This method can be used to safely dispose a device resource which may be in use at the time this method is called,
        /// but which will no longer be in use when the device is idle.
        /// </summary>
        /// <param name="disposable">An object to dispose when this instance becomes idle.</param>
        public void DisposeWhenIdle(IDisposable disposable)
        {
            using (_deferredDisposalLock.Enter())
            {
                _disposables.Add(disposable);
            }
        }

        private void FlushDeferredDisposals()
        {
            using (_deferredDisposalLock.Enter())
            {
                for (IDisposable disposable in _disposables)
                {
                    disposable.Dispose();
                }
                _disposables.Clear();
            }
        }

        /// <summary>
        /// Performs API-specific disposal of resources controlled by this instance.
        /// </summary>
        protected abstract void PlatformDispose();

        /// <summary>
        /// Creates and caches common device resources after device creation completes.
        /// </summary>
        protected void PostDeviceCreated()
        {
            PointSampler = ResourceFactory.CreateSampler(SamplerDescription.Point);
            LinearSampler = ResourceFactory.CreateSampler(SamplerDescription.Linear);
            if (Features.SamplerAnisotropy)
            {
                _aniso4xSampler = ResourceFactory.CreateSampler(SamplerDescription.Aniso4x);
            }
        }

        /// <summary>
        /// Gets a simple point-filtered <see cref="Sampler"/> object owned by this instance.
        /// This object is created with <see cref="SamplerDescription.Point"/>.
        /// </summary>
        public Sampler PointSampler { get; private set; }

        /// <summary>
        /// Gets a simple linear-filtered <see cref="Sampler"/> object owned by this instance.
        /// This object is created with <see cref="SamplerDescription.Linear"/>.
        /// </summary>
        public Sampler LinearSampler { get; private set; }

        /// <summary>
        /// Gets a simple 4x anisotropic-filtered <see cref="Sampler"/> object owned by this instance.
        /// This object is created with <see cref="SamplerDescription.Aniso4x"/>.
        /// This property can only be used when <see cref="GraphicsDeviceFeatures.SamplerAnisotropy"/> is supported.
        /// </summary>
        public Sampler Aniso4xSampler
        {
            get
            {
                if (!Features.SamplerAnisotropy)
                {
                    Runtime.GALError(
                        "GraphicsDevice.Aniso4xSampler cannot be used unless GraphicsDeviceFeatures.SamplerAnisotropy is supported.");
                }

                Debug.Assert(_aniso4xSampler != null);
                return _aniso4xSampler;
            }
        }

        /// <summary>
        /// Frees unmanaged resources controlled by this device.
        /// All created child resources must be Disposed prior to calling this method.
        /// </summary>
        public void Dispose()
        {
            WaitForIdle();
            PointSampler.Dispose();
            LinearSampler.Dispose();
            _aniso4xSampler?.Dispose();
            PlatformDispose();
        }
    }
}
