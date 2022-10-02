using System;
using System.Collections;

namespace Sedulous.Foundation.Mathematics
{
	/// <summary>
	/// Represents a collection of curve keys.
	/// </summary>
	/// <typeparam name="TValue">The type of value which comprises the curve.</typeparam>
	/// <typeparam name="TKey">The type of keyframe which defines the shape of the curve.</typeparam>
	public sealed class CurveKeyCollection<TValue, TKey> : IEnumerable<CurveKeyRecord<TValue, TKey>>
		where TKey : CurveKey<TValue>
	{
		/// <summary>
		/// Initializes a new instance of the <see cref="CurveKeyCollection{TValue, TKey}"/> class from the specified collection of keys.
		/// </summary>
		/// <param name="keys">A collection of <typeparamref name="TKey"/> objects with which to populate the collection.</param>
		public this(Span<TKey> keys)
		{
			this.storage = new CurveKeyRecord<TValue, TKey>[keys.Length];
			for (int i = 0; i < keys.Length; i++)
			{
				this.storage[i] = CurveKeyRecord<TValue, TKey>(keys[i], null);
			}

			this.IsArrayValue = typeof(TValue).IsArray;
			if (this.IsArrayValue)
			{
				if (this.storage.Count > 0)
				{
					this.ElementCount = (this.storage[0].Key.Value as Array)?.Count ?? 0;

					for (var element in this.storage)
					{
						var elementCount = (element.Key.Value as Array)?.Count ?? 0;
						if (elementCount != this.ElementCount)
						{
							Runtime.FatalError("CurveKey Array Length Mismatch");
						}
					}
				}
				else
				{
					this.ElementCount = 0;
				}
			}
			else
			{
				this.ElementCount = 1;
			}
		}

		/// <summary>
		/// Gets an enumerator for the collection.
		/// </summary>
		/// <returns>An enumerator for the collection.</returns>
		public Span<CurveKeyRecord<TValue, TKey>>.Enumerator GetEnumerator() => storage.GetEnumerator();

		/// <inheritdoc/>
		IEnumerator<CurveKeyRecord<TValue, TKey>> IEnumerable<CurveKeyRecord<TValue, TKey>>.GetEnumerator() => GetEnumerator();

		/// <summary>
		/// Overrides the sampler associated with the specified keyframe.
		/// </summary>
		/// <param name="index">The index of the keyframe to override.</param>
		/// <param name="sampler">The override sampler to set for the specified keyframe.</param>
		public void OverrideKeySampler(int32 index, ICurveSampler<TValue, TKey> sampler)
		{
			var record = ref storage[index];
			record = CurveKeyRecord<TValue, TKey>(record.Key, sampler);
		}

		/// <summary>
		/// Gets or sets the item at the specified index within the collection.
		/// </summary>
		/// <param name="index">The index of the item to retrieve.</param>
		/// <returns>The item at the specified index within the collection.</returns>
		public CurveKeyRecord<TValue, TKey> this[int index] { get => storage[index]; }

		/// <summary>
		/// Gets the number of items in the collection.
		/// </summary>
		public int Count => storage.Count;

		/// <summary>
		/// Gets the number of elements in each value in this curve. If <typeparamref name="TValue"/> is not an array,
		/// this value will always be 1. Otherwise, this value will be the length of the arrays contained by the curve. 
		/// All of the arrays in the curve must have the same element count.
		/// </summary>
		public int ElementCount { get; }

		/// <summary>
		/// Gets a value indicating whether the curve contains an array value.
		/// </summary>
		public bool IsArrayValue { get; }

		/// <summary>
		/// Gets a value indicating whether the collection is empty.
		/// </summary>
		public bool IsEmpty => storage.Count == 0;

		/// <summary>
		/// Gets a value indicating whether the curve represented by this collection is constant.
		/// </summary>
		public bool IsConstant => storage.Count == 0 || storage.Count == 1;

		// The collection's backing storage.
		private readonly CurveKeyRecord<TValue, TKey>[] storage;
	}
}
