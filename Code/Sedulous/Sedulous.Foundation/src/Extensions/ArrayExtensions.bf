using Sedulous.Foundation.Utilities;
namespace System;

extension Array
{
	public static void Resize<T>(ref T[] array, int size)
	{
		T[] tmp = scope T[array.Count];
		array.CopyTo(tmp);

		delete array;
		array = new T[size];

		if (size > tmp.Count)
		{
			tmp.CopyTo(array, 0, 0, tmp.Count);
		} else
		{
			tmp.CopyTo(array, 0, 0, size);
		}
	}
}

public extension Array1<T> where T : IHashable
{
	public int GetHashCode()
	{
		int hash = 0;
		for (int i = 0; i < mLength; i++)
		{
			hash = HashHelper.CombineHash(hash, this[i].GetHashCode());
		}
		return hash;
	}
}

extension Array1<T>
{
	public bool SequenceEqual(T[] other)
	{
		if (other == null)
			return false;

		if (this.Count != other.Count)
			return false;

		for (int i = 0; i < this.Count; i++)
		{
			if (!(this[i] == other[i]))
				return false;
		}

		return true;
	}
}