namespace Sedulous.RHI;

/// <summary>
/// Vertex element format.
/// </summary>
public enum ElementFormat
{
	/// <summary>
	/// An unsigned 8-bit value.
	/// </summary>
	UByte,
	/// <summary>
	/// Two 8-bit unsigned values.
	/// </summary>
	UByte2,
	/// <summary>
	/// Three unsigned 8-bit values.
	/// </summary>
	UByte3,
	/// <summary>
	/// Four unsigned 8-bit values.
	/// </summary>
	UByte4,
	/// <summary>
	/// A signed 8-bit value.
	/// </summary>
	Byte,
	/// <summary>
	/// Two signed 8-bit values.
	/// </summary>
	Byte2,
	/// <summary>
	/// Three 8-bit signed values.
	/// </summary>
	Byte3,
	/// <summary>
	/// Four 8-bit signed values.
	/// </summary>
	Byte4,
	/// <summary>
	/// An unsigned normalized 8-bit value.
	/// </summary>
	UByteNormalized,
	/// <summary>
	/// Two unsigned, normalized 8-bit values.
	/// </summary>
	UByte2Normalized,
	/// <summary>
	/// Three unsigned, normalized 8-bit values.
	/// </summary>
	UByte3Normalized,
	/// <summary>
	/// Four unsigned, normalized 8-bit values.
	/// </summary>
	UByte4Normalized,
	/// <summary>
	/// A single signed normalized 8-bit value.
	/// </summary>
	ByteNormalized,
	/// <summary>
	/// Two signed 8-bit normalized values.
	/// </summary>
	Byte2Normalized,
	/// <summary>
	/// Three signed, normalized 8-bit values.
	/// </summary>
	Byte3Normalized,
	/// <summary>
	/// Four signed normalized 8-bit values.
	/// </summary>
	Byte4Normalized,
	/// <summary>
	/// A single unsigned 16-bit value.
	/// </summary>
	UShort,
	/// <summary>
	/// Two unsigned 16-bit values.
	/// </summary>
	UShort2,
	/// <summary>
	/// Three unsigned 16-bit values.
	/// </summary>
	UShort3,
	/// <summary>
	/// Four unsigned 16-bit values.
	/// </summary>
	UShort4,
	/// <summary>
	/// A signed 16-bit value.
	/// </summary>
	Short,
	/// <summary>
	/// Two signed 16-bit values.
	/// </summary>
	Short2,
	/// <summary>
	/// Three 16-bit signed values.
	/// </summary>
	Short3,
	/// <summary>
	/// Four 16-bit signed values.
	/// </summary>
	Short4,
	/// <summary>
	/// A single unsigned normalized 16-bit value.
	/// </summary>
	UShortNormalized,
	/// <summary>
	/// Two unsigned, normalized 16-bit values.
	/// </summary>
	UShort2Normalized,
	/// <summary>
	/// Three unsigned, normalized 16-bit values.
	/// </summary>
	UShort3Normalized,
	/// <summary>
	/// Four 16-bit unsigned normalized values.
	/// </summary>
	UShort4Normalized,
	/// <summary>
	/// A single signed normalized 16-bit value.
	/// </summary>
	ShortNormalized,
	/// <summary>
	/// Two signed, normalized 16-bit values.
	/// </summary>
	Short2Normalized,
	/// <summary>
	/// Three signed, normalized 16-bit values.
	/// </summary>
	Short3Normalized,
	/// <summary>
	/// Four 16-bit signed normalized values.
	/// </summary>
	Short4Normalized,
	/// <summary>
	/// A half-precision floating-point value.
	/// </summary>
	Half,
	/// <summary>
	/// Two half-precision floating-point values.
	/// </summary>
	Half2,
	/// <summary>
	/// Three half-precision floating-point values.
	/// </summary>
	Half3,
	/// <summary>
	/// Four half-precision floating-point values.
	/// </summary>
	Half4,
	/// <summary>
	/// A single-component, 32-bit floating-point format that uses 32 bits for the red channel.
	/// </summary>
	Float,
	/// <summary>
	/// A two-component, 64-bit floating-point format that allocates 32 bits to the red channel and 32 bits to the green channel.
	/// </summary>
	Float2,
	/// <summary>
	/// A three-component, 96-bit floating-point format that supports 32 bits per color channel.
	/// </summary>
	Float3,
	/// <summary>
	/// A four-component, 128-bit floating-point format that supports 32 bits per channel, including alpha.
	/// </summary>
	Float4,
	/// <summary>
	/// One unsigned 32-bit integer value.
	/// </summary>
	UInt,
	/// <summary>
	/// Two unsigned 32-bit integer values.
	/// </summary>
	UInt2,
	/// <summary>
	/// Three unsigned 32-bit integer values.
	/// </summary>
	UInt3,
	/// <summary>
	/// Four unsigned 32-bit integer values.
	/// </summary>
	UInt4,
	/// <summary>
	/// A signed 32-bit integer value.
	/// </summary>
	Int,
	/// <summary>
	/// Two signed 32-bit integer values.
	/// </summary>
	Int2,
	/// <summary>
	/// Three signed 32-bit integer values.
	/// </summary>
	Int3,
	/// <summary>
	/// Four signed 32-bit integer values.
	/// </summary>
	Int4
}
