using System;

namespace Sedulous.Foundation.Mathematics
{
    /// <summary>
    /// Represents an <see cref="ICurveSampler{TValue, TKey}"/> which performs step sampling on a curve of <see cref="float"/> values.
    /// </summary>
    public class SingleCurveStepSampler : ICurveSampler<float, CurveKey<float>>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SingleCurveStepSampler"/> class.
        /// </summary>
        private this() { }

        /// <inheritdoc/>
        public void CreateTemporaryValue(int elementCount, out float value) => value = default;

        /// <inheritdoc/>
        public void ReleaseTemporaryValue(in float value) { }

        /// <inheritdoc/>
        public float InterpolateKeyframes(CurveKey<float> key1, CurveKey<float> key2, float t, float offset, in float existing) =>
            offset + (t >= 1 ? key2.Value : key1.Value);

        /// <inheritdoc/>
        public float CalculateLinearExtension(CurveKey<float> key, float position, CurvePositionType positionType, in float existing) =>
            key.Value;

        /// <inheritdoc/>
        public float CalculateCycleOffset(float first, float last, int32 cycle, in float existing) => 
            (last - first) * cycle;

        /// <summary>
        /// Gets the singleton instance of the <see cref="SingleCurveStepSampler"/> class.
        /// </summary>
        public static SingleCurveStepSampler Instance { get; } = new SingleCurveStepSampler() ~ delete _;
    }
}
