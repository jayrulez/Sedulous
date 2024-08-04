using System;
namespace Sedulous.RHI.DirectX12;

struct DxcShaderModel : IEquatable<DxcShaderModel>, IHashable, IEquatable
{
	public static readonly DxcShaderModel Model6_0 = .(6, 0);
	public static readonly DxcShaderModel Model6_1 = .(6, 1);
	public static readonly DxcShaderModel Model6_2 = .(6, 2);
	public static readonly DxcShaderModel Model6_3 = .(6, 3);
	public static readonly DxcShaderModel Model6_4 = .(6, 4);
	public static readonly DxcShaderModel Model6_5 = .(6, 5);
	public static readonly DxcShaderModel Model6_6 = .(6, 6);
	public static readonly DxcShaderModel Model6_7 = .(6, 7);


	public int32 Major { get; }
	public int32 Minor { get; }

	public this(int32 major, int32 minor)
	{
		Major = major;
		Minor = minor;
	}

	/// <inheritdoc/>
	public bool Equals(Object obj)
	{
		if (obj is DxcShaderModel)
		{
			return Equals((DxcShaderModel)obj);
		}
		return false;
	}

	public bool Equals(DxcShaderModel other)
	{
		return Major == other.Major && Minor == other.Minor;
	}

	public static bool operator ==(DxcShaderModel left, DxcShaderModel right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(DxcShaderModel left, DxcShaderModel right)
	{
		return !(left == right);
	}

	/// <inheritdoc/>
	public int GetHashCode()
	{
		{
			int hashCode = Major.GetHashCode();
			hashCode = (hashCode * 397) ^ Minor.GetHashCode();
			return hashCode;
		}
	}

	/// <inheritdoc/>
	public override void ToString(String str) => str.AppendF("Major={}, Minor={}", Major, Minor);
}