using System;
namespace Sedulous.RAL;

[CRepr]
struct Transform
{
	public float M11;
	public float M12;
	public float M13;
	public float M14;

	public float M21;
	public float M22;
	public float M23;
	public float M24;

	public float M31;
	public float M32;
	public float M33;
	public float M34;

	public this()
	{
		this.M11 = default;
		this.M12 = default;
		this.M13 = default;
		this.M14 = default;

		this.M21 = default;
		this.M22 = default;
		this.M23 = default;
		this.M24 = default;

		this.M31 = default;
		this.M32 = default;
		this.M33 = default;
		this.M34 = default;
	}

	public this(
		float M11, float M12, float M13, float M14,
		float M21, float M22, float M23, float M24,
		float M31, float M32, float M33, float M34)
	{
		this.M11 = M11;
		this.M12 = M12;
		this.M13 = M13;
		this.M14 = M14;

		this.M21 = M21;
		this.M22 = M22;
		this.M23 = M23;
		this.M24 = M24;

		this.M31 = M31;
		this.M32 = M32;
		this.M33 = M33;
		this.M34 = M34;
	}
}