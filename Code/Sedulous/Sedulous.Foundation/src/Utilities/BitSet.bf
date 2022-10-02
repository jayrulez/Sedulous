namespace Sedulous.Foundation.Utilities;

struct BitSet<TCount> where TCount : const int
{
	public int Count => TCount;

	private uint8[TCount] mValues = .();

	public bool this[int index]
	{
		get => mValues[index] == 1;
		set mut
		{
			mValues[index] = value ? 1 : 0;
		}
	}

	public bool Any()
	{
		for (int i = 0; i < this.Count; i++)
		{
			if (this[i])
				return true;
		}
		return false;
	}

	public static Self operator &(Self lhs, Self rhs)
	{
		Self value = lhs;

		for (int i = 0; i < value.Count; i++)
		{
			if (value[i] && rhs[i])
				value[i] = true;
			else
				value[i] = false;
		}

		return value;
	}

	public void operator &=(Self rhs) mut
	{
		this = this & rhs;
	}

	public static Self operator |(Self lhs, Self rhs)
	{
		Self value = lhs;

		for (int i = 0; i < value.Count; i++)
		{
			if (rhs[i])
				value[i] = true;
		}

		return value;
	}

	public void operator |=(Self rhs) mut
	{
		this = this | rhs;
	}

	public static Self operator ^(Self lhs, Self rhs)
	{
		Self value = lhs;

		for (int i = 0; i < value.Count; i++)
		{
			if (value[i] == rhs[i])
				value[i] = false;
			else
				value[i] = true;
		}

		return value;
	}

	public void operator ^=(Self rhs) mut
	{
		this = this ^ rhs;
	}

	public static Self operator ~(Self bitSet)
	{
		Self value = bitSet;
		for (int i = 0; i < bitSet.Count; i++)
		{
			value[i] = !bitSet[i];
		}

		return value;
	}

	public static bool operator ==(Self lhs, Self rhs)
	{
		return lhs.mValues == rhs.mValues;
	}

	public static bool operator !=(Self lhs, Self rhs)
	{
		return !(lhs == rhs);
	}
}