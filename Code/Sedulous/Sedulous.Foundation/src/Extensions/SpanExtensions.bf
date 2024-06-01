using Sedulous.Foundation.Utilities;
namespace System;

/*extension Span<T> where T : IHashable, class
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

extension Span<T> where T : IHashable, struct
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
}*/

extension Span<T>
{
	public bool SequenceEqual(Span<T> other) /*where T : IEquatable<T>*/
	{
		if (this.Length != other.Length)
			return false;

		for (int i = 0; i < this.Length; i++)
		{
			if (this[i] != other[i])
				return false;
		}

		return true;
	}
}