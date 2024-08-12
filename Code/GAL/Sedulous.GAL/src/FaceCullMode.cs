﻿namespace Sedulous.GAL
{
    /// <summary>
    /// Indicates which face will be culled.
    /// </summary>
    public enum FaceCullMode : uint8
    {
        /// <summary>
        /// The back face.
        /// </summary>
        Back,
        /// <summary>
        /// The front face.
        /// </summary>
        Front,
        /// <summary>
        /// No face culling.
        /// </summary>
        None,
    }
}
