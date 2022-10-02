using System;

namespace Sedulous.Foundation.Mathematics
{
    /// <summary>
    /// Represents an <see cref="ICurveSampler{TValue, TKey}"/> which performs cubic spline sampling on a curve of arrays of <see cref="float"/> values.
    /// </summary>
    public class SingleArrayCurveCubicSplineSampler : ICurveSampler<Span<float>, CubicSplineCurveKey<Span<float>>>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SingleArrayCurveCubicSplineSampler"/> class.
        /// </summary>
        private this() { }
		
		/// <inheritdoc/>
		public void CreateTemporaryValue(int elementCount, out Span<float> value) => value = Span<float>(new float[elementCount]);

		/// <inheritdoc/>
		public void ReleaseTemporaryValue(in Span<float> value)
		{
			delete value.Ptr;
		}

        /// <inheritdoc/>
        public Span<float> InterpolateKeyframes(CubicSplineCurveKey<Span<float>> key1, CubicSplineCurveKey<Span<float>> key2, float t, Span<float> offset, in Span<float> existing)
        {
            // NOTE: Candidate for SIMD optimization in .NET 5.

            var count = key1.Value.Length;
            if (count != key2.Value.Length || count != existing.Length)
                Runtime.FatalError("Argument error: SamplerArgumentsMustHaveSameLength");

            for (var i = 0; i < count; i++)
            {
                var t2 = t * t;
                var t3 = t2 * t;
                var key1Value = ref key1.Value[i];
                var key2Value = ref key2.Value[i];
                var tangentIn = ref key2.TangentIn[i];
                var tangentOut = ref key1.TangentOut[i];

                var polynomial1 = (2.0 * t3 - 3.0 * t2 + 1.0); // (2t^3 - 3t^2 + 1)
                var polynomial2 = (t3 - 2.0 * t2 + t);         // (t3 - 2t^2 + t)  
                var polynomial3 = (-2.0 * t3 + 3.0 * t2);      // (-2t^2 + 3t^2)
                var polynomial4 = (t3 - t2);                   // (t^3 - t^2)

                existing[i] = offset[i] + (float)(key1Value * polynomial1 + tangentOut * polynomial2 + key2Value * polynomial3 + tangentIn * polynomial4);
            }

            return existing;
        }

        /// <inheritdoc/>
        public Span<float> CalculateLinearExtension(CubicSplineCurveKey<Span<float>> key, float position, CurvePositionType positionType, in Span<float> existing)
        {
            // NOTE: Candidate for SIMD optimization in .NET 5.

            var count = key.Value.Length;
            if (count != existing.Length)
                Runtime.FatalError("Argument error: SamplerArgumentsMustHaveSameLength");

            var positionDelta = (key.Position - position);
            switch (positionType)
            {
                case CurvePositionType.BeforeCurve:
                    for (var i = 0; i < count; i++)
                    {
                        existing[i] = key.Value[i] - key.TangentIn[i] * positionDelta;
                    }
                    return existing;

                case CurvePositionType.AfterCurve:
                    for (var i = 0; i < count; i++)
                    {
                        existing[i] = key.Value[i] - key.TangentOut[i] * positionDelta;
                    }
                    return existing;

                default:
                    return key.Value;
            }
        }

        /// <inheritdoc/>
        public Span<float> CalculateCycleOffset(Span<float> first, Span<float> last, int32 cycle, in Span<float> existing)
        {
            // NOTE: Candidate for SIMD optimization in .NET 5.

            var count = first.Length;
            if (count != last.Length || count != existing.Length)
                Runtime.FatalError("Argument error: SamplerArgumentsMustHaveSameLength");

            for (var i = 0; i < count; i++)
                existing[i] = (last[i] - first[i]) * cycle;

            return existing;
        }

        /// <summary>
        /// Gets the singleton instance of the <see cref="SingleArrayCurveCubicSplineSampler"/> class.
        /// </summary>
        public static SingleArrayCurveCubicSplineSampler Instance { get; } = new SingleArrayCurveCubicSplineSampler() ~ delete _;
    }
}
