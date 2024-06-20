using System;

namespace Sedulous.RHI;

/// <summary>
/// Contains properties that describe the characteristics of a new pipeline state object.
/// </summary>
struct OutputDescription : IEquatable<OutputDescription>, IHashable
{
	/// <summary>
	/// A description of the depth attachment, or null if none exists.
	/// </summary>
	public readonly OutputAttachmentDescription? DepthAttachment;

	/// <summary>
	/// An array of attachment descriptions, one for each color attachment.
	/// </summary>
	public readonly ColorAttachmentList ColorAttachments;

	/// <summary>
	/// Gets the number of view counts.
	/// </summary>
	public readonly uint32 ArraySliceCount;

	/// <summary>
	/// The number of samples in each target attachment.
	/// </summary>
	public readonly TextureSampleCount SampleCount;

	/// <summary>
	/// Precomputed outputDescription hash. Used to speed up the comparison between output descriptions.
	/// </summary>
	public readonly int CachedHashCode;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.OutputDescription" /> struct.
	/// </summary>
	/// <param name="depth">A description of the depth attachment.</param>
	/// <param name="colors">An array of descriptions of each color attachment.</param>
	/// <param name="sampleCount">The number of samples in each target attachment.</param>
	/// <param name="arraySliceCount">The number of views rendered.</param>
	public this(OutputAttachmentDescription? depth, ColorAttachmentList colors, TextureSampleCount sampleCount, uint32 arraySliceCount)
	{
		DepthAttachment = depth;
		ColorAttachments = colors;
		SampleCount = sampleCount;
		ArraySliceCount = arraySliceCount;
		int hashCode = DepthAttachment.GetValueOrDefault().GetHashCode();
		for (int i = 0; i < ColorAttachments.Count; i++)
		{
			hashCode = (hashCode * 397) ^ ColorAttachments[i].GetHashCode();
		}
		CachedHashCode = (hashCode * 397) ^ (int)SampleCount;
		CachedHashCode = (hashCode * 397) ^ (int)ArraySliceCount;
	}

	/// <summary>
	/// Create a new instance of <see cref="T:Sedulous.RHI.OutputDescription" /> from a <see cref="T:Sedulous.RHI.FrameBuffer" />.
	/// </summary>
	/// <param name="frameBuffer">The framebuffer to extract the attachment description.</param>
	/// <returns>A new instance of OutputDescription.</returns>
	public static OutputDescription CreateFromFrameBuffer(FrameBuffer frameBuffer)
	{
		TextureSampleCount sampleCount = TextureSampleCount.None;
		OutputAttachmentDescription? depthAttachment = null;
		uint32 arraySliceCount = 1;
		if (frameBuffer.DepthStencilTarget.HasValue)
		{
			FrameBufferAttachment depthTarget = frameBuffer.DepthStencilTarget.Value;
			TextureDescription depthDescription = depthTarget.AttachmentTexture.Description;
			depthAttachment = OutputAttachmentDescription(depthDescription.Format, depthTarget.ResolvedTexture != null);
			sampleCount = depthDescription.SampleCount;
		}
		ColorAttachmentList colorsAttachments = .();
		if (!frameBuffer.ColorTargets.IsEmpty)
		{
			colorsAttachments.Count = frameBuffer.ColorTargets.Count;
			for (int i = 0; i < colorsAttachments.Count; i++)
			{
				ref FrameBufferAttachment colorTarget = ref frameBuffer.ColorTargets[i];
				TextureDescription colorDescription = colorTarget.AttachmentTexture.Description;
				colorsAttachments[i] = OutputAttachmentDescription(colorDescription.Format, colorTarget.ResolvedTexture != null);
				sampleCount = colorDescription.SampleCount;
				arraySliceCount = colorTarget.SliceCount;
			}
		}
		return OutputDescription(depthAttachment, colorsAttachments, sampleCount, arraySliceCount);
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(OutputDescription other)
	{
		return CachedHashCode == other.CachedHashCode;
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
		if (obj is OutputDescription)
		{
			return Equals((OutputDescription)obj);
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
		return CachedHashCode;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(OutputDescription value1, OutputDescription value2)
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
	public static bool operator !=(OutputDescription value1, OutputDescription value2)
	{
		return !value1.Equals(value2);
	}

	private bool ArrayEqualsEquatable<T>(T[] left, T[] right) where T : struct, IEquatable<T>
	{
		if (left == null || right == null)
		{
			return left == right;
		}
		if (left.Count != right.Count)
		{
			return false;
		}
		for (int i = 0; i < left.Count; i++)
		{
			if (!left[i].Equals(right[i]))
			{
				return false;
			}
		}
		return true;
	}
}
