using System;

namespace Sedulous.Foundation.Mathematics
{
    /// <summary>
    /// Contains methods for creating curves which are comprised of <see cref="float"/> values.
    /// </summary>
    public static class SingleArrayCurve
    {
        /// <summary>
        /// Creates a new curve with step sampling.
        /// </summary>
        /// <param name="preLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined 
        /// for points before the beginning of the curve.</param>
        /// <param name="postLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined
        /// for points after the end of the curve.</param>
        /// <param name="keys">A collection of <see cref="CurveKey{T}"/> objects from which to construct the curve.</param>
        public static Curve<Span<float>, CurveKey<Span<float>>> Step(CurveLoopType preLoop, CurveLoopType postLoop, Span<CurveKey<Span<float>>> keys) =>
            new Curve<Span<float>, CurveKey<Span<float>>>(preLoop, postLoop, SingleArrayCurveStepSampler.Instance, keys);

        /// <summary>
        /// Creates a new curve with linear sampling.
        /// </summary>
        /// <param name="preLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined 
        /// for points before the beginning of the curve.</param>
        /// <param name="postLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined
        /// for points after the end of the curve.</param>
        /// <param name="keys">A collection of <see cref="CurveKey{T}"/> objects from which to construct the curve.</param>
        public static Curve<Span<float>, CurveKey<Span<float>>> Linear(CurveLoopType preLoop, CurveLoopType postLoop, Span<CurveKey<Span<float>>> keys) =>
            new Curve<Span<float>, CurveKey<Span<float>>>(preLoop, postLoop, SingleArrayCurveLinearSampler.Instance, keys);

        /// <summary>
        /// Creates a new curve with cubic spline sampling.
        /// </summary>
        /// <param name="preLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined 
        /// for points before the beginning of the curve.</param>
        /// <param name="postLoop">A <see cref="CurveLoopType"/> value indicating how the curve's values are determined
        /// for points after the end of the curve.</param>
        /// <param name="keys">A collection of <see cref="CubicSplineCurveKey{T}"/> objects from which to construct the curve.</param>
        public static Curve<Span<float>, CubicSplineCurveKey<Span<float>>> CubicSpline(CurveLoopType preLoop, CurveLoopType postLoop, Span<CubicSplineCurveKey<Span<float>>> keys) =>
            new Curve<Span<float>, CubicSplineCurveKey<Span<float>>>(preLoop, postLoop, SingleArrayCurveCubicSplineSampler.Instance, keys);
    }
}
