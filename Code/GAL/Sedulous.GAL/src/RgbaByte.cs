using System;

namespace Sedulous.GAL
{
    /// <summary>
    /// A color stored in four 8-bit unsigned normalized integer values, in RGBA component order.
    /// </summary>
    public struct RgbaByte : IEquatable<RgbaByte>, IHashable
    {
        /// <summary>
        /// The red component.
        /// </summary>
        public readonly uint8 R;
        /// <summary>
        /// The green component.
        /// </summary>
        public readonly uint8 G;
        /// <summary>
        /// The blue component.
        /// </summary>
        public readonly uint8 B;
        /// <summary>
        /// The alpha component.
        /// </summary>
        public readonly uint8 A;

        /// <summary>
        /// Red (255, 0, 0, 255)
        /// </summary>
        public static readonly RgbaByte Red = RgbaByte(255, 0, 0, 255);
        /// <summary>
        /// Dark Red (153, 0, 0, 255)
        /// </summary>
        public static readonly RgbaByte DarkRed = RgbaByte(153, 0, 0, 255);
        /// <summary>
        /// Green (0, 255, 0, 255)
        /// </summary>
        public static readonly RgbaByte Green = RgbaByte(0, 255, 0, 255);
        /// <summary>
        /// Blue (0, 0, 255, 255)
        /// </summary>
        public static readonly RgbaByte Blue = RgbaByte(0, 0, 255, 255);
        /// <summary>
        /// Yellow (255, 255, 0, 255)
        /// </summary>
        public static readonly RgbaByte Yellow = RgbaByte(255, 255, 0, 255);
        /// <summary>
        /// Grey (64, 64, 64, 255)
        /// </summary>
        public static readonly RgbaByte Grey = RgbaByte(64, 64, 64, 255);
        /// <summary>
        /// Light Grey (166, 166, 166, 255)
        /// </summary>
        public static readonly RgbaByte LightGrey = RgbaByte(166, 166, 166, 255);
        /// <summary>
        /// Cyan (0, 255, 255, 255)
        /// </summary>
        public static readonly RgbaByte Cyan = RgbaByte(0, 255, 255, 255);
        /// <summary>
        /// White (255, 255, 255, 255)
        /// </summary>
        public static readonly RgbaByte White = RgbaByte(255, 255, 255, 255);
        /// <summary>
        /// Cornflower Blue (100, 149, 237, 255)
        /// </summary>
        public static readonly RgbaByte CornflowerBlue = RgbaByte(100, 149, 237, 255);
        /// <summary>
        /// Clear (0, 0, 0, 0)
        /// </summary>
        public static readonly RgbaByte Clear = RgbaByte(0, 0, 0, 0);
        /// <summary>
        /// Black (0, 0, 0, 255)
        /// </summary>
        public static readonly RgbaByte Black = RgbaByte(0, 0, 0, 255);
        /// <summary>
        /// Pink (255, 155, 191, 255)
        /// </summary>
        public static readonly RgbaByte Pink = RgbaByte(255, 155, 191, 255);
        /// <summary>
        /// Orange (255, 92, 0, 255)
        /// </summary>
        public static readonly RgbaByte Orange = RgbaByte(255, 92, 0, 255);

        /// <summary>
        /// Constructs a new RgbaByte from the given components.
        /// </summary>
        /// <param name="r">The red component.</param>
        /// <param name="g">The green component.</param>
        /// <param name="b">The blue component.</param>
        /// <param name="a">The alpha component.</param>
        public this(uint8 r, uint8 g, uint8 b, uint8 a)
        {
            R = r;
            G = g;
            B = b;
            A = a;
        }

        /// <summary>
        /// Element-wise equality.
        /// </summary>
        /// <param name="other">The instance to compare to.</param>
        /// <returns>True if all elements are equal; false otherswise.</returns>
        [Inline]
        public bool Equals(RgbaByte other)
        {
            return R == other.R && G == other.G && B == other.B && A == other.A;
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
        public static bool operator ==(RgbaByte left, RgbaByte right)
        {
            return left.Equals(right);
        }

        /// <summary>
        /// Element-wise inequality.
        /// </summary>
        /// <param name="left">The first value.</param>
        /// <param name="right">The second value.</param>
        [Inline]
        public static bool operator !=(RgbaByte left, RgbaByte right)
        {
            return !left.Equals(right);
        }
    }
}
