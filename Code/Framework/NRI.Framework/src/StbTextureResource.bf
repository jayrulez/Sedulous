using NRI.Helpers;
using System;
using NRI.Framework;
using System.IO;
using StbImageBeef;
namespace NRI.Framework;

public static
{
	public static Result<void> LoadTexture(StringView path, ref StbTextureResource texture)
	{
		FileStream fs = scope FileStream();
		fs.Open(path, .Open, .Read);
		ImageResult image = ImageResult.FromStream(fs, ColorComponents.RedGreenBlueAlpha);

		Format format = .UNKNOWN;
		switch (image.Comp) {
		case .Default:
			break;
		case .Grey:
			format = .R8_UNORM;
			break;
		case .GreyAlpha:
			format = .RG8_UNORM;
			break;
		case .RedGreenBlue:
			format = .RGBA8_UNORM;
			break;
		case .RedGreenBlueAlpha:
			format = .RGBA8_UNORM;
			break;
		}

		texture.image = image;
		texture.data = image.Data;
		texture.avgColor = .();
		texture.hash = 100;
		texture.alphaMode = .OPAQUE;
		texture.format = format;
		texture.width = (.)image.Width;
		texture.height = (.)image.Height;
		texture.depth = 1;
		texture.mipNum = 1;
		texture.arraySize = 1;

		return .();
	}
}

struct StbTextureResource : IDisposable
{
	public StbImageBeef.ImageResult image = null;
	public void* data;
	public Color<float> avgColor = .();
	public uint64 hash = 0;
	public AlphaMode alphaMode = AlphaMode.OPAQUE;
	public Format format = Format.UNKNOWN;
	public uint16 width = 0;
	public uint16 height = 0;
	public uint16 depth = 0;
	public uint16 mipNum = 0;
	public uint16 arraySize = 0;

	public void Dispose() mut
	{
		if (image != null)
		{
			delete image;
			image = null;
		}
	}

	public void OverrideFormat(Format fmt) mut
		{ format = fmt; }

	public bool IsBlockCompressed()
	{
		//return detexFormatIsCompressed(texture[0]->format);
		return false;
	}

	public uint16 GetArraySize()
		{ return arraySize; }

	public uint16 GetMipNum()
		{ return mipNum; }

	public uint16 GetWidth()
		{ return width; }

	public uint16 GetHeight()
		{ return height; }

	public uint16 GetDepth()
		{ return depth; }

	public Format GetFormat()
		{ return format; }

	public void GetSubresource(ref TextureSubresourceUploadDesc subresource, uint32 mipIndex, uint32 arrayIndex = 0)
	{
		// TODO: 3D images are not supported, "subresource.slices" needs to be allocated to store pointers to all slices of the current mipmap
		Runtime.Assert(GetDepth() == 1);
		//PLATFORM_UNUSED(arrayIndex);


		/*uint32_t bpp = detexGetPixelSize(pixel_format) * 8;
		*row_pitch = (width * bpp + 7) / 8;
		*slice_pitch = *row_pitch * height;*/

		int bpp = 8 * GetTexelBlockSize(format);

		int rowPitch = (width * bpp + 7) / 8;
		int slicePitch = rowPitch * height;

		subresource.slices = image.Data;
		subresource.sliceNum = 1;
		subresource.rowPitch = (uint32)rowPitch;
		subresource.slicePitch = (uint32)slicePitch;

		/*int rowPitch, slicePitch;
		detexComputePitch(texture[mipIndex]->format, texture[mipIndex]->width, texture[mipIndex]->height, &rowPitch, &slicePitch);
		subresource.slices = texture[mipIndex]->data;
		subresource.sliceNum = 1;
		subresource.rowPitch = (uint32)rowPitch;
		subresource.slicePitch = (uint32)slicePitch;*/
	}
}