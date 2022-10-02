using System;

namespace Sedulous.Foundation.Mathematics
{
    /// <summary>
    /// Represents an <see cref="ICurveSampler{TValue, TKey}"/> which performs linear sampling on a curve of <see cref="float"/> values.
    /// </summary>
    public class SingleCurveLinearSampler : ICurveSampler<float, CurveKey<float>>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SingleCurveLinearSampler"/> class.
        /// </summary>
        private this() { }

        /// <inheritdoc/>
        public void CreateTemporaryValue(int elementCount, out float value) => value = default;

        /// <inheritdoc/>
        public void ReleaseTemporaryValue(in float value) { }

        /// <inheritdoc/>
        public float InterpolateKeyframes(CurveKey<float> key1, CurveKey<float> key2, float t, float offset, in float existing)
        {
            var key1Value = key1.Value;
            var key2Value = key2.Value;
            return offset + (float)(key1Value + ((key2Value - key1Value) * t));
        }

        /// <inheritdoc/>
        public float CalculateLinearExtension(CurveKey<float> key, float position, CurvePositionType positionType, in float existing) =>
            key.Value;

        /// <inheritdoc/>
        public float CalculateCycleOffset(float first, float last, int32 cycle, in float existing) => 
            (last - first) * cycle;

        /// <summary>
        /// Gets the singleton instance of the <see cref="SingleCurveLinearSampler"/> class.
        /// </summary>
        public static SingleCurveLinearSampler Instance { get; } = new SingleCurveLinearSampler() ~ delete _;
    }
}
