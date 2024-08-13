using System;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.GAL
{
    /// <summary>
    /// A color stored in four 32-bit floating-point values, in RGBA component order.
    /// </summary>
    public struct RgbaFloat : IEquatable<RgbaFloat>,IHashable
    {
        private readonly Vector4 _channels;

        /// <summary>
        /// The red component.
        /// </summary>
        public float R => _channels.X;
        /// <summary>
        /// The green component.
        /// </summary>
        public float G => _channels.Y;
        /// <summary>
        /// The blue component.
        /// </summary>
        public float B => _channels.Z;
        /// <summary>
        /// The alpha component.
        /// </summary>
        public float A => _channels.W;

        /// <summary>
        /// Constructs a new RgbaFloat from the given components.
        /// </summary>
        /// <param name="r">The red component.</param>
        /// <param name="g">The green component.</param>
        /// <param name="b">The blue component.</param>
        /// <param name="a">The alpha component.</param>
        public this(float r, float g, float b, float a)
        {
            _channels = Vector4(r, g, b, a);
        }

        /// <summary>
        /// Constructs a new RgbaFloat from the XYZW components of a vector.
        /// </summary>
        /// <param name="channels">The vector containing the color components.</param>
        public this(Vector4 channels)
        {
            _channels = channels;
        }

        /// <summary>
        /// The total size, in bytes, of an RgbaFloat value.
        /// </summary>
        public static readonly int32 SizeInBytes = 16;

        /// <summary>
        /// Red (1, 0, 0, 1)
        /// </summary>
        public static readonly RgbaFloat Red = RgbaFloat(1, 0, 0, 1);
        /// <summary>
        /// Dark Red (0.6f, 0, 0, 1)
        /// </summary>
        public static readonly RgbaFloat DarkRed = RgbaFloat(0.6f, 0, 0, 1);
        /// <summary>
        /// Green (0, 1, 0, 1)
        /// </summary>
        public static readonly RgbaFloat Green = RgbaFloat(0, 1, 0, 1);
        /// <summary>
        /// Blue (0, 0, 1, 1)
        /// </summary>
        public static readonly RgbaFloat Blue = RgbaFloat(0, 0, 1, 1);
        /// <summary>
        /// Yellow (1, 1, 0, 1)
        /// </summary>
        public static readonly RgbaFloat Yellow = RgbaFloat(1, 1, 0, 1);
        /// <summary>
        /// Grey (0.25f, 0.25f, 0.25f, 1)
        /// </summary>
        public static readonly RgbaFloat Grey = RgbaFloat(0.25f, 0.25f, 0.25f, 1);
        /// <summary>
        /// Light Grey (0.65f, 0.65f, 0.65f, 1)
        /// </summary>
        public static readonly RgbaFloat LightGrey = RgbaFloat(0.65f, 0.65f, 0.65f, 1);
        /// <summary>
        /// Cyan (0, 1, 1, 1)
        /// </summary>
        public static readonly RgbaFloat Cyan = RgbaFloat(0, 1, 1, 1);
        /// <summary>
        /// White (1, 1, 1, 1)
        /// </summary>
        public static readonly RgbaFloat White = RgbaFloat(1, 1, 1, 1);
        /// <summary>
        /// Cornflower Blue (0.3921f, 0.5843f, 0.9294f, 1)
        /// </summary>
        public static readonly RgbaFloat CornflowerBlue = RgbaFloat(0.3921f, 0.5843f, 0.9294f, 1);
        /// <summary>
        /// Clear (0, 0, 0, 0)
        /// </summary>
        public static readonly RgbaFloat Clear = RgbaFloat(0, 0, 0, 0);
        /// <summary>
        /// Black (0, 0, 0, 1)
        /// </summary>
        public static readonly RgbaFloat Black = RgbaFloat(0, 0, 0, 1);
        /// <summary>
        /// Pink (1, 0.45f, 0.75f, 1)
        /// </summary>
        public static readonly RgbaFloat Pink = RgbaFloat(1f, 0.45f, 0.75f, 1);
        /// <summary>
        /// Orange (1, 0.36f, 0, 1)
        /// </summary>
        public static readonly RgbaFloat Orange = RgbaFloat(1f, 0.36f, 0f, 1);

        /// <summary>
        /// Converts this RgbaFloat into a Vector4.
        /// </summary>
        /// <returns></returns>
        [Inline]
        public Vector4 ToVector4()
        {
            return _channels;
        }

        /// <summary>
        /// Converts this RgbaFloat into a float[4].
        /// </summary>
        /// <returns></returns>
        [Inline]
        public float[4] ToFloat4()
        {
            return .(_channels.X, _channels.Y, _channels.Z, _channels.W);
        }

        /// <summary>
        /// Element-wise equality.
        /// </summary>
        /// <param name="other">The instance to compare to.</param>
        /// <returns>True if all elements are equal; false otherswise.</returns>
        [Inline]
        public bool Equals(RgbaFloat other)
        {
            return _channels.Equals(other._channels);
        }

        /// <summary>
        /// Returns the hash code for this instance.
        /// </summary>
        /// <returns>A 32-bit signed integer that is the hash code for this instance.</returns>
        [Inline]
        public int GetHashCode()
        {
            return HashHelper.Combine(R.GetHashCode(), G.GetHashCode(), B.GetHashCode(), A.GetHashCode());
        }

        /// <summary>
        /// Returns a string representation of this color.
        /// </summary>
        /// <returns></returns>
        public override void ToString(String str)
        {
            str.AppendF("R:{0}, G:{1}, B:{2}, A:{3}", R, G, B, A);
        }

        /// <summary>
        /// Element-wise equality.
        /// </summary>
        /// <param name="left">The first value.</param>
        /// <param name="right">The second value.</param>
        [Inline]
        public static bool operator ==(RgbaFloat left, RgbaFloat right)
        {
            return left.Equals(right);
        }

        /// <summary>
        /// Element-wise inequality.
        /// </summary>
        /// <param name="left">The first value.</param>
        /// <param name="right">The second value.</param>
        [Inline]
        public static bool operator !=(RgbaFloat left, RgbaFloat right)
        {
            return !left.Equals(right);
        }
    }
}
