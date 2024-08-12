using System;

namespace Sedulous.GAL
{
    /// <summary>
    /// A <see cref="Pipeline"/> component describing the properties of the depth stencil state.
    /// </summary>
    public struct DepthStencilStateDescription : IEquatable<DepthStencilStateDescription>, IHashable
    {
        /// <summary>
        /// Controls whether depth testing is enabled.
        /// </summary>
        public bool DepthTestEnabled;
        /// <summary>
        /// Controls whether new depth values are written to the depth buffer.
        /// </summary>
        public bool DepthWriteEnabled;
        /// <summary>
        /// The <see cref="ComparisonKind"/> used when considering new depth values.
        /// </summary>
        public ComparisonKind DepthComparison;

        /// <summary>
        /// Controls whether the stencil test is enabled.
        /// </summary>
        public bool StencilTestEnabled;
        /// <summary>
        /// Controls how stencil tests are handled for pixels whose surface faces towards the camera.
        /// </summary>
        public StencilBehaviorDescription StencilFront;
        /// <summary>
        /// Controls how stencil tests are handled for pixels whose surface faces away from the camera.
        /// </summary>
        public StencilBehaviorDescription StencilBack;
        /// <summary>
        /// Controls the portion of the stencil buffer used for reading.
        /// </summary>
        public uint8 StencilReadMask;
        /// <summary>
        /// Controls the portion of the stencil buffer used for writing.
        /// </summary>
        public uint8 StencilWriteMask;
        /// <summary>
        /// The reference value to use when doing a stencil test.
        /// </summary>
        public uint32 StencilReference;

        /// <summary>
        /// Constructs a new <see cref="DepthStencilStateDescription"/>. This describes a depth-stencil state with no stencil
        /// testing enabled.
        /// </summary>
        /// <param name="depthTestEnabled">Controls whether depth testing is enabled.</param>
        /// <param name="depthWriteEnabled">Controls whether new depth values are written to the depth buffer.</param>
        /// <param name="comparisonKind">The <see cref="Sedulous.GAL.ComparisonKind"/> used when considering new depth values.</param>
        public this(bool depthTestEnabled, bool depthWriteEnabled, ComparisonKind comparisonKind)
        {
            DepthTestEnabled = depthTestEnabled;
            DepthWriteEnabled = depthWriteEnabled;
            DepthComparison = comparisonKind;

            StencilTestEnabled = false;
            StencilFront = default(StencilBehaviorDescription);
            StencilBack = default(StencilBehaviorDescription);
            StencilReadMask = 0;
            StencilWriteMask = 0;
            StencilReference = 0;
        }

        /// <summary>
        /// Constructs a new <see cref="DepthStencilStateDescription"/>. This describes a depth-stencil state with no stencil
        /// testing enabled.
        /// </summary>
        /// <param name="depthTestEnabled">Controls whether depth testing is enabled.</param>
        /// <param name="depthWriteEnabled">Controls whether new depth values are written to the depth buffer.</param>
        /// <param name="comparisonKind">The <see cref="ComparisonKind"/> used when considering new depth values.</param>
        /// <param name="stencilTestEnabled">Controls whether the stencil test is enabled.</param>
        /// <param name="stencilFront">Controls how stencil tests are handled for pixels whose surface faces towards the camera.</param>
        /// <param name="stencilBack">Controls how stencil tests are handled for pixels whose surface faces away from the camera.</param>
        /// <param name="stencilReadMask">Controls the portion of the stencil buffer used for reading.</param>
        /// <param name="stencilWriteMask">Controls the portion of the stencil buffer used for writing.</param>
        /// <param name="stencilReference">The reference value to use when doing a stencil test.</param>
        public this(
            bool depthTestEnabled,
            bool depthWriteEnabled,
            ComparisonKind comparisonKind,
            bool stencilTestEnabled,
            StencilBehaviorDescription stencilFront,
            StencilBehaviorDescription stencilBack,
            uint8 stencilReadMask,
            uint8 stencilWriteMask,
            uint32 stencilReference)
        {
            DepthTestEnabled = depthTestEnabled;
            DepthWriteEnabled = depthWriteEnabled;
            DepthComparison = comparisonKind;

            StencilTestEnabled = stencilTestEnabled;
            StencilFront = stencilFront;
            StencilBack = stencilBack;
            StencilReadMask = stencilReadMask;
            StencilWriteMask = stencilWriteMask;
            StencilReference = stencilReference;
        }

        /// <summary>
        /// Describes a depth-only depth stencil state which uses a <see cref="ComparisonKind.LessEqual"/> comparison.
        /// The stencil test is disabled.
        /// Settings:
        ///     DepthTestEnabled = true
        ///     DepthWriteEnabled = true
        ///     ComparisonKind = DepthComparisonKind.LessEqual
        /// </summary>
        public static readonly DepthStencilStateDescription DepthOnlyLessEqual = DepthStencilStateDescription
        {
            DepthTestEnabled = true,
            DepthWriteEnabled = true,
            DepthComparison = ComparisonKind.LessEqual
        };

        /// <summary>
        /// Describes a depth-only depth stencil state which uses a <see cref="ComparisonKind.LessEqual"/> comparison, and disables writing to the depth buffer.
        /// The stencil test is disabled.
        /// Settings:
        ///     DepthTestEnabled = true
        ///     DepthWriteEnabled = false
        ///     ComparisonKind = DepthComparisonKind.LessEqual
        /// </summary>
        public static readonly DepthStencilStateDescription DepthOnlyLessEqualRead = DepthStencilStateDescription
        {
            DepthTestEnabled = true,
            DepthWriteEnabled = false,
            DepthComparison = ComparisonKind.LessEqual
        };

        /// <summary>
        /// Describes a depth-only depth stencil state which uses a <see cref="ComparisonKind.GreaterEqual"/> comparison.
        /// The stencil test is disabled.
        /// Settings:
        ///     DepthTestEnabled = true
        ///     DepthWriteEnabled = true
        ///     ComparisonKind = DepthComparisonKind.GreaterEqual
        /// </summary>
        public static readonly DepthStencilStateDescription DepthOnlyGreaterEqual = DepthStencilStateDescription
        {
            DepthTestEnabled = true,
            DepthWriteEnabled = true,
            DepthComparison = ComparisonKind.GreaterEqual
        };

        /// <summary>
        /// Describes a depth-only depth stencil state which uses a <see cref="ComparisonKind.GreaterEqual"/> comparison, and
        /// disables writing to the depth buffer. The stencil test is disabled.
        /// Settings:
        ///     DepthTestEnabled = true
        ///     DepthWriteEnabled = false
        ///     ComparisonKind = DepthComparisonKind.GreaterEqual
        /// </summary>
        public static readonly DepthStencilStateDescription DepthOnlyGreaterEqualRead = DepthStencilStateDescription
        {
            DepthTestEnabled = true,
            DepthWriteEnabled = false,
            DepthComparison = ComparisonKind.GreaterEqual
        };

        /// <summary>
        /// Describes a depth-only depth stencil state in which depth testing and writing is disabled.
        /// The stencil test is disabled.
        /// Settings:
        ///     DepthTestEnabled = false
        ///     DepthWriteEnabled = false
        ///     ComparisonKind = DepthComparisonKind.LessEqual
        /// </summary>
        public static readonly DepthStencilStateDescription Disabled = DepthStencilStateDescription
        {
            DepthTestEnabled = false,
            DepthWriteEnabled = false,
            DepthComparison = ComparisonKind.LessEqual
        };

        /// <summary>
        /// Element-wise equality.
        /// </summary>
        /// <param name="other">The instance to compare to.</param>
        /// <returns>True if all elements are equal; false otherswise.</returns>
        public bool Equals(DepthStencilStateDescription other)
        {
            return DepthTestEnabled == other.DepthTestEnabled
                && DepthWriteEnabled == other.DepthWriteEnabled
                && DepthComparison == other.DepthComparison
                && StencilTestEnabled == other.StencilTestEnabled
                && StencilFront == other.StencilFront
                && StencilBack == other.StencilBack
                && StencilReadMask == other.StencilReadMask
                && StencilWriteMask == other.StencilWriteMask
                && StencilReference == other.StencilReference;
        }

        /// <summary>
        /// Returns the hash code for this instance.
        /// </summary>
        /// <returns>A 32-bit signed integer that is the hash code for this instance.</returns>
        public int GetHashCode()
        {
            return HashHelper.Combine(
                DepthTestEnabled.GetHashCode(),
                DepthWriteEnabled.GetHashCode(),
                (int32)DepthComparison,
                StencilTestEnabled.GetHashCode(),
                StencilFront.GetHashCode(),
                StencilBack.GetHashCode(),
                StencilReadMask.GetHashCode(),
                StencilWriteMask.GetHashCode(),
                StencilReference.GetHashCode());
        }
    }
}
