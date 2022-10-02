using System;

namespace Sedulous.Foundation.Mathematics
{
    /// <summary>
    /// Represents an <see cref="ICurveSampler{TValue, TKey}"/> which performs cubic spline sampling on a curve of <see cref="Vector2"/> values.
    /// </summary>
    public class Vector2CurveCubicSplineSampler : ICurveSampler<Vector2, CubicSplineCurveKey<Vector2>>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="Vector2CurveCubicSplineSampler"/> class.
        /// </summary>
        private this() { }

        /// <inheritdoc/>
        public void CreateTemporaryValue(int elementCount, out Vector2 value) => value = default;

        /// <inheritdoc/>
        public void ReleaseTemporaryValue(in Vector2 value) { }

        /// <inheritdoc/>
        public Vector2 InterpolateKeyframes(CubicSplineCurveKey<Vector2> key1, CubicSplineCurveKey<Vector2> key2, float t, Vector2 offset, in Vector2 existing)
        {
            var t2 = t * t;
            var t3 = t2 * t;
            var key1Value = key1.Value;
            var key2Value = key2.Value;
            var tangentIn = key2.TangentIn;
            var tangentOut = key1.TangentOut;

            var polynomial1 = (2.0 * t3 - 3.0 * t2 + 1.0); // (2t^3 - 3t^2 + 1)
            var polynomial2 = (t3 - 2.0 * t2 + t);         // (t3 - 2t^2 + t)  
            var polynomial3 = (-2.0 * t3 + 3.0 * t2);      // (-2t^2 + 3t^2)
            var polynomial4 = (t3 - t2);                   // (t^3 - t^2)

            return offset + (key1Value * ((float)polynomial1) + tangentOut * (float)polynomial2 + key2Value * (float)polynomial3 + tangentIn * polynomial4);
        }

        /// <inheritdoc/>
        public Vector2 CalculateLinearExtension(CubicSplineCurveKey<Vector2> key, float position, CurvePositionType positionType, in Vector2 existing)
        {
            switch (positionType)
            {
                case CurvePositionType.BeforeCurve:
                    return key.Value - key.TangentIn * (key.Position - position);

                case CurvePositionType.AfterCurve:
                    return key.Value - key.TangentOut * (key.Position - position);

                default:
                    return key.Value;
            }
        }

        /// <inheritdoc/>
        public Vector2 CalculateCycleOffset(Vector2 first, Vector2 last, int32 cycle, in Vector2 existing) => 
            (last - first) * cycle;

        /// <summary>
        /// Gets the singleton instance of the <see cref="Vector2CurveCubicSplineSampler"/> class.
        /// </summary>
        public static Vector2CurveCubicSplineSampler Instance { get; } = new Vector2CurveCubicSplineSampler() ~ delete _;
    }
}
