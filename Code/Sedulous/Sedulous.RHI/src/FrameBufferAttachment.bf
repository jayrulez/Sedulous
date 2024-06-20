using System;
using Sedulous.Foundation.Collections;

namespace Sedulous.RHI;

typealias FrameBufferColorAttachmentList = FixedList<FrameBufferAttachment, const Constants.MaxColorAttachments>;

/// <summary>
/// Contains properties that describe a framebuffer texture attachment description.
/// </summary>
struct FrameBufferAttachment : IEquatable<FrameBufferAttachment>, IHashable
{
	/// <summary>
	/// The number of slices to attach.
	/// </summary>
	public uint32 SliceCount;

	/// <summary>
	/// The selected MipLevel.
	/// </summary>
	public uint32 MipSlice;

	/// <summary>
	/// The attachment texture. This is the texture used by the framebuffer as attachment.
	/// </summary>
	/// <remarks>
	/// If this texture has MSAA enabled, you could set the ResolvedTexture field with a non MSAA texture. After the EndRenderPass, this texture will be resolved into this.
	/// </remarks>
	public Texture AttachmentTexture;

	/// <summary>
	/// The selected array slice.
	/// </summary>
	public uint32 AttachedFirstSlice;

	/// <summary>
	/// The resolved texture. If the source texture has MSAA enabled, in the EndRenderPass this texture is resolved into this texture.
	/// </summary>
	public Texture ResolvedTexture;

	/// <summary>
	/// The selected array slice.
	/// </summary>
	public uint32 ResolvedFirstSlice;

	/// <summary>
	/// Gets the texture used as a shader resource.
	/// </summary>
	public Texture Texture => ResolvedTexture ?? AttachmentTexture;

	/// <summary>
	/// Gets the selected array slice of the texture used as a shader resource.
	/// </summary>
	public uint32 FirstSlice
	{
		get
		{
			if (ResolvedTexture == null)
			{
				return AttachedFirstSlice;
			}
			return ResolvedFirstSlice;
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.FrameBufferAttachment" /> struct.
	/// </summary>
	/// <param name="attachedTexture">The attachment texture.</param>
	/// <param name="arrayIndex">The array index to compute the specify slide inside the texture.</param>
	/// <param name="faceIndex">The face index to compute the specify slide inside the texture.</param>
	/// <param name="sliceCount">The slice count.</param>
	/// <param name="mipLevel">The selected mipLevel.</param>
	public this(Texture attachedTexture, uint32 arrayIndex, uint32 faceIndex, uint32 sliceCount, uint32 mipLevel)
		: this(attachedTexture, arrayIndex * attachedTexture.Description.Faces + faceIndex, null, 0, sliceCount, mipLevel)
	{
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.FrameBufferAttachment" /> struct.
	/// </summary>
	/// <param name="attachedTexture">The attachment texture.</param>
	/// <param name="firstSlice">the first slice.</param>
	/// <param name="sliceCount">The slice count.</param>
	/// <param name="mipLevel">The selected mipLevel.</param>
	public this(Texture attachedTexture, uint32 firstSlice, uint32 sliceCount, uint32 mipLevel = 0)
		: this(attachedTexture, firstSlice, null, 0, sliceCount, mipLevel)
	{
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.FrameBufferAttachment" /> struct.
	/// </summary>
	/// <param name="attachedTexture">The attachment texture.</param>
	/// <param name="resolvedTexture">The resolved texture.</param>
	public this(Texture attachedTexture, Texture resolvedTexture)
		: this(attachedTexture, 0, resolvedTexture, 0, 1, 0)
	{
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.FrameBufferAttachment" /> struct.
	/// </summary>
	/// <param name="attachedTexture">The attachment texture.</param>
	/// <param name="attachedFirstSlice">the first slice.</param>
	/// <param name="resolvedTexture">The resolved texture.</param>
	/// <param name="resolvedFirstSlice">the first slice on the resolved texture.</param>
	/// <param name="sliceCount">The slice count on the resolved texture.</param>
	/// <param name="mipLevel">The selected mipLevel on the resolved texture.</param>
	public this(Texture attachedTexture, uint32 attachedFirstSlice, Texture resolvedTexture, uint32 resolvedFirstSlice, uint32 sliceCount, uint32 mipLevel)
	{
		if (resolvedTexture != null)
		{
			if (resolvedTexture.Description.SampleCount != 0)
			{
				Runtime.ArgumentError("The resolved texture must have SampleCount == None");
			}
			if (attachedTexture.Description.SampleCount == TextureSampleCount.None)
			{
				Runtime.ArgumentError("Framebuffer attachment texture must have SampleCount != None if there are a resolvedTexture");
			}
		}
		AttachmentTexture = attachedTexture;
		AttachedFirstSlice = attachedFirstSlice;
		ResolvedTexture = resolvedTexture;
		ResolvedFirstSlice = resolvedFirstSlice;
		SliceCount = sliceCount;
		MipSlice = mipLevel;
	}

	/// <summary>
	/// Determines whether the specified parameter is equal to this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// <c>true</c> if the specified <see cref="T:System.Object" /> is equal to this instance; otherwise, <c>false</c>.
	/// </returns>
	public bool Equals(FrameBufferAttachment other)
	{
		if (AttachmentTexture == other.AttachmentTexture
			&& AttachedFirstSlice == other.AttachedFirstSlice
			&& SliceCount == other.SliceCount
			&& MipSlice == other.MipSlice
			&& ResolvedTexture == other.ResolvedTexture)
		{
			return ResolvedFirstSlice == other.ResolvedFirstSlice;
		}
		return false;
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
		if (obj is FrameBufferAttachment)
		{
			return Equals((FrameBufferAttachment)obj);
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
		int hashCode = AttachmentTexture.GetHashCode();
		hashCode = (hashCode * 397) ^ (int)AttachedFirstSlice;
		hashCode = (hashCode * 397) ^ (int)SliceCount;
		hashCode = (hashCode * 397) ^ (int)MipSlice;
		if (ResolvedTexture != null)
		{
			hashCode = (hashCode * 397) ^ ResolvedTexture.GetHashCode();
			hashCode = (hashCode * 397) ^ (int)ResolvedFirstSlice;
		}
		return hashCode;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(FrameBufferAttachment value1, FrameBufferAttachment value2)
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
	public static bool operator !=(FrameBufferAttachment value1, FrameBufferAttachment value2)
	{
		return !value1.Equals(value2);
	}
}
