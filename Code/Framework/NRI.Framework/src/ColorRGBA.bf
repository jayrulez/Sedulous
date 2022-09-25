namespace NRI.Framework;

struct ColorRGBA
{
	public float r;
	public float g;
	public float b;
	public float a;

	public static Self operator /(Self a, float b)
	{
		var a;
		a.r /= b;
		a.g /= b;
		a.b /= b;
		a.a /= b;

		return a;
	}

	public static Self operator +(Self a, Self b)
	{
		var a;
		a.r += b.r;
		a.g += b.g;
		a.b += b.b;
		a.a += b.a;

		return a;
	}

	public static Self FromRgba(uint32 value)
	{
		float r = (uint8)(value >> 24);
		float g = (uint8)(value >> 16);
		float b = (uint8)(value >> 8);
		float a = (uint8)(value);

		return .()
			{
				r = r,
				g = g,
				b = b,
				a = a
			};
	}
}