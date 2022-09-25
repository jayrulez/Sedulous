using System.Collections;
using System;
namespace NRI.Helpers;

struct StaticList<T, CSize> : IEnumerable<T> where CSize : const int
{
	private T[CSize] mVal;
	private int CurrentSize = 0;

	public T* Ptr
	{
		get mut
		{
			return &mVal;
		}
	}

	public int Count
	{
		[Inline]
		get
		{
			return CurrentSize;
		}
	}

	public T this[int index]
	{
		get { return mVal[index]; }
		set mut { mVal[index] = value; }
	}

	public ref T this[int index]
	{
		get mut { return ref mVal[index]; }
	}

	public ref T Back { get mut { return ref mVal[CurrentSize - 1]; } }

	/*public ref T GetValueAt(int index) mut
	{
		return ref mVal[index];
	}*/

	public const int MaxSize = CSize;

	public bool IsEmpty => CurrentSize == 0;


	public this()
	{
		mVal = .();
		CurrentSize = 0;
	}

	public this(int size) : this()
	{
		CurrentSize = size;
	}

	public this(Span<T> list) : this()
	{
		for (var item in list)
			Add(item);
	}

	public explicit static operator T[CSize](Self val)
	{
		return val.mVal;
	}

	public implicit static operator Span<T>(in Self val)
	{
#unwarn
		return .(&val.mVal, CSize);
	}

	public void Fill(T value) mut
	{
		for (int i = 0; i < MaxSize; i++)
		{
			mVal[i] = value;
		}
		CurrentSize = MaxSize;
	}

	public void Add(T value) mut
	{
		Runtime.Assert(CurrentSize < MaxSize);
		mVal[CurrentSize] = value;
		CurrentSize++;
	}

	public ref T AddAndGetRef(T value = default) mut
	{
		Runtime.Assert(CurrentSize < MaxSize);
		mVal[CurrentSize] = value;
		CurrentSize++;
		return ref Back;
	}

	public void PopBack() mut
	{
		Runtime.Assert(CurrentSize > 0);
		CurrentSize--;
	}

	public void Resize(int newSize) mut
	{
		Runtime.Assert(newSize <= MaxSize);

		if (CurrentSize > newSize)
		{
			for (int i = newSize; i < CurrentSize; i++)
			{
				//(data() + i)->~T();
				if (!typeof(T).IsValueType)
				{
					Runtime.FatalError("Should we auto delete?");
				}
			}
		}
		else
		{
			for (int i = CurrentSize; i < newSize; i++)
			{
				//new (data() + i) T();
				if (!typeof(T).IsValueType)
				{
					Runtime.FatalError("Should we auto construct?");
				}
			}
		}

		CurrentSize = newSize;
	}


	public override void ToString(String strBuffer) mut
	{
		if (typeof(T) == typeof(char8))
		{
			int len = 0;
			for (; len < CSize; len++)
			{
				if (mVal[len] == default)
					break;
			}
			strBuffer.Append((char8*)&mVal, len);
			return;
		}

		strBuffer.Append('(');
		for (int i < CSize)
		{
			if (i != 0)
				strBuffer.Append(", ");
			mVal[i].ToString(strBuffer);
		}
		strBuffer.Append(')');
	}

	public Enumerator GetEnumerator()
	{
		return .(this);
	}


	public struct Enumerator : IRefEnumerator<T*>, IEnumerator<T>, IResettable
	{
		private StaticList<T, CSize> mList;
		private int mIndex;
		private T* mCurrent;

		public this(StaticList<T, CSize> list)
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