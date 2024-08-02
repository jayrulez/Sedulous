using System;

namespace Sedulous.RHI;

/// <summary>
/// Describes a 2D texture.
/// </summary>
struct TextureDescription : IEquatable<TextureDescription>
{
	/// <summary>
	/// Texture type <see cref="T:Sedulous.RHI.TextureType" />.
	/// </summary>
	public TextureType Type;

	/// <summary>
	/// Texture format <see cref="T:Sedulous.RHI.PixelFormat" />.
	/// </summary>
	public PixelFormat Format;

	/// <summary>
	/// Texture width (in texels).
	/// </summary>
	public uint32 Width;

	/// <summary>
	/// Texture height (in texels).
	/// </summary>
	public uint32 Height;

	/// <summary>
	/// Texture Depth (in texels).
	/// </summary>
	public uint32 Depth;

	/// <summary>
	/// Number of textures in the texture array.
	/// </summary>
	public uint32 ArraySize;

	/// <summary>
	/// Number of texture faces useful in TextureCube and TextureCubeArray.
	/// </summary>
	public uint32 Faces;

	/// <summary>
	/// The maximum number of mipmap levels in the texture.
	/// </summary>
	public uint32 MipLevels;

	/// <summary>
	/// The texture flags  <see cref="T:Sedulous.RHI.TextureFlags" />.
	/// </summary>
	public TextureFlags Flags;

	/// <summary>
	/// Value that identifies how the texture is to be read from and written to.
	/// </summary>
	public ResourceUsage Usage;

	/// <summary>
	/// The number of samples in this texture.
	/// </summary>
	public TextureSampleCount SampleCount;

	/// <summary>
	/// Flags <see cref="T:Sedulous.RHI.ResourceCpuAccess" /> to specify the type of CPU access allowed.
	/// </summary>
	public ResourceCpuAccess CpuAccess;

	private static TextureDescription DefaultValues
	{
		get
		{
			TextureDescription result = default(TextureDescription);
			result.Type = TextureType.Texture2D;
			result.Format = PixelFormat.R8G8B8A8_UNorm;
			result.Width = 1;
			result.Height = 1;
			result.Depth = 1;
			result.ArraySize = 1;
			result.Faces = 1;
			result.MipLevels = 1;
			result.Flags = TextureFlags.ShaderResource;
			result.Usage = ResourceUsage.Default;
			result.SampleCount = TextureSampleCount.None;
			result.CpuAccess = ResourceCpuAccess.None;
			return result;
		}
	}

	/// <summary>
	/// Create a Texture 1D description.
	/// </summary>
	/// <param name="width">The texture width.</param>
	/// <param name="format">The texture format.</param>
	/// <returns>The new texture 1D description.</returns>
	public static TextureDescription CreateTexture1DDescription(uint32 width, PixelFormat format = PixelFormat.R8G8B8A8_UNorm)
	{
		TextureDescription texture1DDescription = DefaultValues;
		texture1DDescription.Type = TextureType.Texture1D;
		texture1DDescription.Width = width;
		texture1DDescription.Format = format;
		return texture1DDescription;
	}

	/// <summary>
	/// Create a Texture 2D description.
	/// </summary>
	/// <param name="width">The texture width.</param>
	/// <param name="height">The texture height.</param>
	/// <param name="format">The texture format.</param>
	/// <returns>The new texture 2D description.</returns>
	public static TextureDescription CreateTexture2DDescription(uint32 width, uint32 height, PixelFormat format = PixelFormat.R8G8B8A8_UNorm)
	{
		TextureDescription texture2DDescription = DefaultValues;
		texture2DDescription.Type = TextureType.Texture2D;
		texture2DDescription.Width = width;
		texture2DDescription.Height = height;
		texture2DDescription.Format = format;
		return texture2DDescription;
	}

	/// <summary>
	/// Create a Texture 3D description.
	/// </summary>
	/// <param name="width">The texture width.</param>
	/// <param name="height">The texture height.</param>
	/// <param name="depth">The texture depth.</param>
	/// <param name="format">The texture format.</param>
	/// <returns>The new texture 3D description.</returns>
	public static TextureDescription CreateTexture3DDescription(uint32 width, uint32 height, uint32 depth, PixelFormat format = PixelFormat.R8G8B8A8_UNorm)
	{
		TextureDescription texture3DDescription = DefaultValues;
		texture3DDescription.Type = TextureType.Texture3D;
		texture3DDescription.Width = width;
		texture3DDescription.Height = height;
		texture3DDescription.Depth = depth;
		texture3DDescription.Format = format;
		return texture3DDescription;
	}

	/// <summary>
	/// Create a Texture cube description.
	/// </summary>
	/// <param name="width">The texture width.</param>
	/// <param name="height">The texture height.</param>
	/// <param name="format">The texture format.</param>
	/// <returns>The new texture cube description.</returns>
	public static TextureDescription CreateTextureCubeDescription(uint32 width, uint32 height, PixelFormat format = PixelFormat.R8G8B8A8_UNorm)
	{
		TextureDescription textureCubeDescription = DefaultValues;
		textureCubeDescription.Type = TextureType.TextureCube;
		textureCubeDescription.Width = width;
		textureCubeDescription.Height = height;
		textureCubeDescription.Format = format;
		return textureCubeDescription;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(TextureDescription other)
	{
		if (Type != other.Type
			|| Format != other.Format
			|| Width != other.Width
			|| Height != other.Height
			|| Depth != other.Depth
			|| ArraySize != other.ArraySize
			|| Faces != other.Faces
			|| MipLevels != other.MipLevels
			|| Flags != other.Flags
			|| Usage != other.Usage
			|| SampleCount != other.SampleCount
			|| CpuAccess != other.CpuAccess)
		{
			return false;
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
		if (obj is TextureDescription)
		{
			return Equals((TextureDescription)obj);
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
		return (int)(((((((((((((((((((((uint32)((int)Type * 397)
			^ (uint32)Format) * 397)
			^ Width) * 397)
			^ Height) * 397)
			^ Depth) * 397)
			^ ArraySize) * 397)
			^ Faces) * 397)
			^ MipLevels) * 397)
			^ (uint32)Flags) * 397)
			^ (uint32)Usage) * 397)
			^ (uint32)Usage) * 397)
			^ (int)CpuAccess;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(TextureDescription value1, TextureDescription value2)
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
	public static bool operator !=(TextureDescription value1, TextureDescription value2)
	{
		return !value1.Equals(value2);
	}
}
