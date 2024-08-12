﻿namespace Sedulous.GAL
{
    /// <summary>
    /// The specific graphics API used by the <see cref="GraphicsDevice"/>.
    /// </summary>
    public enum GraphicsBackend : uint8
    {
        /// <summary>
        /// Direct3D 11.
        /// </summary>
        Direct3D11,
        /// <summary>
        /// Vulkan.
        /// </summary>
        Vulkan,
        /// <summary>
        /// OpenGL.
        /// </summary>
        OpenGL,
        /// <summary>
        /// Metal.
        /// </summary>
        Metal,
        /// <summary>
        /// OpenGL ES.
        /// </summary>
        OpenGLES,
    }
}
