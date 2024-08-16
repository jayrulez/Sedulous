using System.Collections;
using System;
namespace Sedulous.RAL.VK;

class MultiMap<TKey, TValue>
	: ICollection<(TKey key, TValue value)>,
	IEnumerable<(TKey key, TValue value)>
	where int : operator TKey <=> TKey
{
	private typealias Entry = (TKey key, TValue value);

	private List<Entry> mEntries = new .() ~ delete _;

	private System.Comparison<Entry> comparisonFunc = new (lhs, rhs) =>
		{
			return lhs.key <=> rhs.key;
		};

	public ~this()
	{
		delete comparisonFunc;
	}

	public void Add((TKey key, TValue value) item)
	{
		mEntries.Add(item);
		mEntries.Sort(comparisonFunc);
	}

	public void Add(TKey key, TValue value)
	{
		Add((key, value));
	}

	public void Clear()
	{
		mEntries.Clear();
	}

	public bool Contains((TKey key, TValue value) item)
	{
		return mEntries.Contains(item);
	}

	public void CopyTo(Span<(TKey key, TValue value)> span)
	{
		mEntries.CopyTo(span);
	}

	public bool Remove((TKey key, TValue value) item)
	{
		bool removed = mEntries.Remove(item);
		if (removed)
			mEntries.Sort(comparisonFunc);
		return removed;
	}

	public (TKey key, TValue value)? LowerBound(TKey key)
	{
		if (mEntries.Count == 0)
			return null;

		mEntries.Sort(comparisonFunc);

		for (int i = 0; i < mEntries.Count; i++)
		{
			if (mEntries[i].key >= key)
			{
				return mEntries[i];
			}
		}

		return null;
	}

	public Enumerator GetEnumerator()
	{
		return Enumerator(this);
	}

	public struct Enumerator : List<Entry>.Enumerator
	{
		public this(SelfOuter multimap) : base(multimap.mEntries) { }
	}
}