using System;

namespace Sedulous.Foundation.Mathematics
{
	/// <summary>
	/// Represents an <see cref="ICurveSampler{TValue, TKey}"/> which performs linear sampling on a curve of arrays of <see cref="float"/> values.
	/// </summary>
	public class SingleArrayCurveLinearSampler : ICurveSampler<Span<float>, CurveKey<Span<float>>>
	{
		/// <summary>
		/// Initializes a new instance of the <see cref="SingleArrayCurveLinearSampler"/> class.
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
		public Span<float> InterpolateKeyframes(CurveKey<Span<float>> key1, CurveKey<Span<float>> key2, float t, Span<float> offset, in Span<float> existing)
		{
			// NOTE: Candidate for SIMD optimization in .NET 5.

			var key1Value = key1.Value;
			var key2Value = key2.Value;

			var count = key1Value.Length;
			if (count != key2Value.Length || count != existing.Length)
				Runtime.FatalError("Argument error: SamplerArgumentsMustHaveSameLength");

			for (var i = 0; i < count; i++)
			{
				var key1Element = ref key1Value[i];
				var key2Element = ref key2Value[i];
				existing[i] = offset[i] + (float)(key1Element + ((key2Element - key1Element) * t));
			}

			return existing;
		}

		/// <inheritdoc/>
		public Span<float> CalculateLinearExtension(CurveKey<Span<float>> key, float position, CurvePositionType positionType, in Span<float> existing)
		{
			if (key.Value.Length != existing.Length)
				Runtime.FatalError("Argument error: SamplerArgumentsMustHaveSameLength");

			key.Value.CopyTo(existing);
			return existing;
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
		/// Gets the singleton instance of the <see cref="SingleArrayCurveLinearSampler"/> class.
		/// </summary>
		public static SingleArrayCurveLinearSampler Instance { get; } = new SingleArrayCurveLinearSampler() ~ delete _;
	}
}
