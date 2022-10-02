using System;

namespace Sedulous.Foundation.Mathematics
{
    /// <summary>
    /// Contains methods for creating curves which are comprised of <see cref="float"/> values.
    /// </summary>
    public static class SingleCurve
    {
        /// <summary>
        /// Creates a new curve with step sampling.
        /// </summary>
        /// <param name="preLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined 
        /// for points before the beginning of the curve.</param>
        /// <param name="postLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined
        /// for points after the end of the curve.</param>
        /// <param name="keys">A collection of <see cref="CurveKey{float}"/> objects from which to construct the curve.</param>
        public static Curve<float, CurveKey<float>> Step(CurveLoopType preLoop, CurveLoopType postLoop, Span<CurveKey<float>> keys) =>
            new Curve<float, CurveKey<float>>(preLoop, postLoop, SingleCurveStepSampler.Instance, keys);

        /// <summary>
        /// Creates a new curve with linear sampling.
        /// </summary>
        /// <param name="preLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined 
        /// for points before the beginning of the curve.</param>
        /// <param name="postLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined
        /// for points after the end of the curve.</param>
        /// <param name="keys">A collection of <see cref="CurveKey{float}"/> objects from which to construct the curve.</param>
        public static Curve<float, CurveKey<float>> Linear(CurveLoopType preLoop, CurveLoopType postLoop, Span<CurveKey<float>> keys) =>
            new Curve<float, CurveKey<float>>(preLoop, postLoop, SingleCurveLinearSampler.Instance, keys);

        /// <summary>
        /// Creates a new curve with cubic spline sampling.
        /// </summary>
        /// <param name="preLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined 
        /// for points before the beginning of the curve.</param>
        /// <param name="postLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined
        /// for points after the end of the curve.</param>
        /// <param name="keys">A collection of <see cref="CubicSplineCurveKey{float}"/> objects from which to construct the curve.</param>
        public static Curve<float, CubicSplineCurveKey<float>> CubicSpline(CurveLoopType preLoop, CurveLoopType postLoop, Span<CubicSplineCurveKey<float>> keys) =>
            new Curve<float, CubicSplineCurveKey<float>>(preLoop, postLoop, SingleCurveCubicSplineSampler.Instance, keys);
    }
}
