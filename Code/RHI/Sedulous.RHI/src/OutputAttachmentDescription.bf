using System;
using Sedulous.Foundation.Collections;

namespace Sedulous.RHI;

typealias ColorAttachmentList = FixedList<OutputAttachmentDescription, const Constants.MaxColorAttachments>;

/// <summary>
/// Contains properties that describe the characteristics of a new pipeline state object.
/// </summary>
struct OutputAttachmentDescription : IEquatable<OutputAttachmentDescription>, IHashable
{
	/// <summary>
	/// The pixel format.
	/// </summary>
	public PixelFormat Format;

	/// <summary>
	/// Indicates if the <see cref="T:Sedulous.RHI.Texture" /> with MSAA attachment need to be resolved.
	/// </summary>
	public bool ResolveMSAA;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.OutputAttachmentDescription" /> struct.
	/// </summary>
	/// <param name="format">The format of the <see cref="T:Sedulous.RHI.Texture" /> attachment.</param>
	/// <param name="resolveMSAA">Indicates if the <see cref="T:Sedulous.RHI.Texture" /> with MSAA attachment need to be resolved.</param>
	public this(PixelFormat format, bool resolveMSAA = false)
	{
		Format = format;
		ResolveMSAA = resolveMSAA;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(OutputAttachmentDescription other)
	{
		if (Format != other.Format)
		{
			return ResolveMSAA == other.ResolveMSAA;
		}
		return true;
	}

	/// <summary>
	/// Determines whether the specified <see cref="T:System.Object" /> is equal to this instance.
	/// </summary>
	/// <param name="obj">The <see cref="T:System.Object" /> to compare with this instance.</param>
	/// <returns>
	///   <c>true</c> if the specified <see cref="T:System.Object" /> is equal to this instance; otherwise, <c>false</c>.
	/// </returns>
	public bool Equals(Object obj)
	{
		if (obj == null)
		{
			return false;
		}
		if (obj is OutputAttachmentDescription)
		{
			return Equals((OutputAttachmentDescription)obj);
		}
		return false;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public int GetHashCode()
	{
		return (int)Format * (ResolveMSAA ? 1 : (-1));
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(OutputAttachmentDescription value1, OutputAttachmentDescription value2)
	{
		return value1.Equals(value2);
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator !=(OutputAttachmentDescription value1, OutputAttachmentDescription value2)
	{
		return !value1.Equals(value2);
	}
}
