using System;
using System.Collections;
namespace Sedulous.Foundation.Collections;

struct FixedList<T, TCapacity> where TCapacity : const int
{
	private T[TCapacity] mData = .();

	private int mCurrentSize = 0;

	public T* Ptr mut => &mData;

	public int Count
	{
		get => mCurrentSize;
		set mut
		{
			Runtime.Assert(value <= TCapacity);
			mCurrentSize = value;
		}
	}

	public T this[int index]
	{
		get
		{
			Runtime.Assert(index < mCurrentSize);
			return mData[index];
		}
	}

	public ref T this[int index]
	{
		get mut { return ref mData[index]; }
		set mut
		{
			Runtime.Assert(index < mCurrentSize);
			mData[index] = value;
		}
	}

	public bool IsEmpty => mCurrentSize == 0;

	public this(T data)
	{
		Runtime.Assert(TCapacity > 0);
		mData[0] = data;
		mCurrentSize = 1;
	}

	public this(Span<T> data)
	{
		Runtime.Assert(data.Length <= TCapacity);

		for (int i = 0; i < data.Length; i++)
		{
			mData[i] = data[i];
		}
		mCurrentSize = data.Length;
	}

	/*
	public this(int length)
	{
		Runtime.Assert(length <= TCapacity);
		mCurrentSize = length;
	}
	*/

	public this()
	{
		mCurrentSize = 0;
	}

	public void Clear() mut
	{
		mData = .();
		mCurrentSize = 0;
	}

	public Enumerator GetEnumerator()
	{
		return .(this);
	}

	public struct Enumerator : IRefEnumerator<T*>, IEnumerator<T>, IResettable
	{
		private FixedList<T, TCapacity> mList;
		private int mIndex;
		private T* mCurrent;

		public this(FixedList<T, TCapacity> list)
		{
			mList = list;
			mIndex = 0;
			mCurrent = null;
		}

		public bool MoveNext() mut
		{
			if ((uint(mIndex) < uint(mList.Count)))
			{
				mCurrent = &mList[mIndex];
				mIndex++;
				return true;
			}
			return MoveNextRare();
		}

		private bool MoveNextRare() mut
		{
			mIndex = mList.Count + 1;
			mCurrent = null;
			return false;
		}

		public int Count
		{
			get
			{
				return mList.Count;
			}
		}

		public T Current
		{
			get
			{
				return *mCurrent;
			}
		}

		public ref T CurrentRef
		{
			get
			{
				return ref *mCurrent;
			}
		}

		public int Index
		{
			get
			{
				return mIndex - 1;
			}
		}

		public void Reset() mut
		{
			mIndex = 0;
			mCurrent = null;
		}

		public Result<T> GetNext() mut
		{
			if (!MoveNext())
				return .Err;
			return Current;
		}

		public Result<T*> GetNextRef() mut
		{
			if (!MoveNext())
				return .Err;
			return &CurrentRef;
		}
	}
}

extension FixedList<T, TCapacity>
	where TCapacity : const int
	where T : IEquatable<T>
{
	[Commutable]
	public static bool operator ==(Self lhs, Self rhs)
	{
		if (lhs.Count != rhs.Count)
			return false;

		for (int i = 0; i < lhs.Count; i++)
		{
			if (!lhs[i].Equals(rhs[i]))
				return false;
		}
		return true;
	}
}

extension FixedList<T, TCapacity>
	where TCapacity : const int
	where T : IHashable
{

	public int GetHashCode()
	{
		int hash = 0;

		for (int i = 0; i < Count; i++)
		{
			hash = HashCode.Mix(hash, mData[i].GetHashCode());
		}

		return hash;
	}
}