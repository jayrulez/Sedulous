using System;

namespace Sedulous.Foundation.Mathematics
{
    /// <summary>
    /// Represents a key point in a curve which uses linear sampling.
    /// </summary>
    /// <typeparam name="TValue">The type of value which comprises the curve.</typeparam>
    public class CurveKey<TValue>
    {
		public static int operator<=>(Self lhs, Self rhs) => lhs.CompareTo(rhs);

        /// <summary>
        /// Initializes a new instance of the <see cref="CurveKey{TValue}"/> class.
        /// </summary>
        /// <param name="position">The key's position on the curve.</param>
        /// <param name="value">The key's value.</param>
        public this(float position, TValue value)
        {
            this.Position = position;
            this.Value = value;
        }

        /// <summary>
        /// Compares this instance to the specified <see cref="CurveKey{TValue}"/> and returns an integer that indicates whether the position
        /// of this instance is less than, equal to, or greater than the value of the specified key.
        /// </summary>
        /// <param name="other">The key to compare to this instance.</param>
        /// <returns>A value that indicates the relative order of the objects being compared.</returns>
        /// <remarks>If the keys have the same position, this method returns zero.  If this key comes before <paramref name="other"/>,
        /// then this method returns -1.  Otherwise, this method returns 1.</remarks>
        public int CompareTo(CurveKey<TValue> other)
        {
            Contract.Require(other, nameof(other));

            if (this.Position == other.Position) return 0;
            if (this.Position <  other.Position) return -1;

            return 1;
        }

        /// <summary>
        /// Gets the key's position on the curve.
        /// </summary>
        public float Position { get; protected set; }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        public TValue Value { get; protected set; }
    }
}
