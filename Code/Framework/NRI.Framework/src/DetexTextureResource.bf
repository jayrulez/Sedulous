using Detex;
using System;
using NRI.Helpers;
using System.Collections;
using System.Diagnostics;
namespace NRI.Framework;

public static{
	public static uint64 ComputeHash(void* key, uint32 len)
	{
		var len;
		/*readonly*/ uint8* p = (uint8*)key;
		uint64 result = 14695981039346656037uL;
		while (len-- > 0)
			result = (result ^ (*p++)) * 1099511628211uL;

		return result;
	}

	struct FormatMapping : this(uint32 detexFormat, Format nriFormat);

	private const FormatMapping[?] formatTable = .( // Uncompressed formats.
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGB8, Format.UNKNOWN),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA8, Format.RGBA8_UNORM),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_R8, Format.R8_UNORM),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_SIGNED_R8, Format.R8_SNORM),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RG8, Format.RG8_UNORM),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_SIGNED_RG8, Format.RG8_SNORM),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_R16, Format.R16_UNORM),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_SIGNED_R16, Format.R16_SNORM),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RG16, Format.RG16_UNORM),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_SIGNED_RG16, Format.RG16_SNORM),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGB16, Format.UNKNOWN),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA16, Format.RGBA16_UNORM),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_FLOAT_R16, Format.R16_SFLOAT),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_FLOAT_RG16, Format.RG16_SFLOAT),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_FLOAT_RGB16, Format.UNKNOWN),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_FLOAT_RGBA16, Format.RGBA16_SFLOAT),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_FLOAT_R32, Format.R32_SFLOAT),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_FLOAT_RG32, Format.RG32_SFLOAT),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_FLOAT_RGB32, Format.RGB32_SFLOAT),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_FLOAT_RGBA32, Format.RGBA32_SFLOAT),
		.((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_A8, Format.UNKNOWN), // Compressed formats.
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_BC1, Format.BC1_RGBA_UNORM),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_BC1A, Format.UNKNOWN),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_BC2, Format.BC2_RGBA_UNORM),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_BC3, Format.BC3_RGBA_UNORM),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_RGTC1, Format.BC4_R_UNORM),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_SIGNED_RGTC1, Format.BC4_R_SNORM),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_RGTC2, Format.BC5_RG_UNORM),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_SIGNED_RGTC2, Format.BC5_RG_SNORM),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_BPTC_FLOAT, Format.BC6H_RGB_UFLOAT),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_BPTC_SIGNED_FLOAT, Format.BC6H_RGB_SFLOAT),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_BPTC, Format.BC7_RGBA_UNORM),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_ETC1, Format.UNKNOWN),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_ETC2, Format.UNKNOWN),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_ETC2_PUNCHTHROUGH, Format.UNKNOWN),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_ETC2_EAC, Format.UNKNOWN),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_EAC_R11, Format.UNKNOWN),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_EAC_SIGNED_R11, Format.UNKNOWN),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_EAC_RG11, Format.UNKNOWN),
		.((.)DETEX_TEXTURE_FORMAT.DETEX_TEXTURE_FORMAT_EAC_SIGNED_RG11, Format.UNKNOWN)
		);

	public static Format GetFormatNRI(uint32 detexFormat)
	{
		for (var entry in ref formatTable)
		{
			if (entry.detexFormat == detexFormat)
				return entry.nriFormat;
		}

		return Format.UNKNOWN;
	}

	public static Result<void> LoadTexture(StringView path, DetexTextureResource texture, bool computeAvgColorAndAlphaMode = false)
	{
		detexTexture** dTexture = null;
		int32 mipNum = 0;

		if (!Detex.detexLoadTextureFileWithMipmaps(path.ToScopeCStr!(), 32, &dTexture, &mipNum))
		{
			Debug.WriteLine("ERROR: Can't load texture '{}'", path);

			return .Err;
		}

		texture.texture = dTexture;
		texture.name.Set(path);
		texture.hash = ComputeHash(path.ToScopeCStr!(), (uint32)path.Length);
		texture.format = GetFormatNRI(dTexture[0].format);
		texture.width = (uint16)dTexture[0].width;
		texture.height = (uint16)dTexture[0].height;
		texture.mipNum = (uint16)mipNum;

		// TODO: detex doesn't support cubemaps and 3D textures
		texture.arraySize = 1;
		texture.depth = 1;

		texture.alphaMode = AlphaMode.OPAQUE;
		if (computeAvgColorAndAlphaMode)
		{
			// Alpha mode
			if (texture.format == NRI.Format.BC1_RGBA_UNORM || texture.format == NRI.Format.BC1_RGBA_SRGB)
			{
				bool hasTransparency = false;
				for (int i = mipNum - 1; i >= 0 && !hasTransparency; i--)
				{
					readonly uint size = Detex.detexTextureSize((.)dTexture[i].width_in_blocks, (.)dTexture[i].height_in_blocks, dTexture[i].format);
					/*readonly*/ uint8* bc1 = dTexture[i].data;

					for (uint j = 0; j < size && !hasTransparency; j += 8)
					{
						readonly uint16* c = (uint16*)bc1;
						if (c[0] <= c[1])
						{
							readonly uint32 bits = *(uint32*)(bc1 + 4);
							for (uint32 k = 0; k < 32 && !hasTransparency; k += 2)
								hasTransparency = ((bits >> k) & 0x3) == 0x3;
						}
						bc1 += 8;
					}
				}

				if (hasTransparency)
					texture.alphaMode = AlphaMode.PREMULTIPLIED;
			}

			// Decompress last mip
			List<uint8> image = scope .();
			detexTexture* lastMip = dTexture[mipNum - 1];
			uint8* rgba8 = lastMip.data;
			if (lastMip.format != (.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA8)
			{
				image.Resize(lastMip.width * lastMip.height * (.)Detex.detexGetPixelSize((.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA8));
				// Converts to RGBA8 if the texture is not compressed
				Detex.detexDecompressTextureLinear(lastMip, image.Ptr, (.)DETEX_PIXEL_FORMAT.DETEX_PIXEL_FORMAT_RGBA8);
				rgba8 = image.Ptr;
			}

			// Average color
			ColorRGBA avgColor = .();
			readonly int pixelNum = lastMip.width * lastMip.height;
			for (int i = 0; i < pixelNum; i++)
				avgColor = avgColor + ColorRGBA.FromRgba(*(uint32*)(rgba8 + i * 4));

			avgColor = (avgColor / (float)pixelNum);
			texture.avgColor = avgColor;

			if (texture.alphaMode != AlphaMode.PREMULTIPLIED && avgColor.r < 254.5f / 255.0f)
				texture.alphaMode = avgColor.r == 0.0f ? AlphaMode.OFF : AlphaMode.TRANSPARENT;

			// Useful to find a texture which is TRANSPARENT but needs to be OPAQUE or PREMULTIPLIED
			/*if (texture.alphaMode == AlphaMode.TRANSPARENT || texture.alphaMode == AlphaMode.OFF)
			{
				char s[1024];
				sprintf(s, "%s: %s\n", texture.alphaMode == AlphaMode.OFF ? "OFF" : "TRANSPARENT", path.c_str());
				OutputDebugStringA(s);
			}*/
		}

		return .Ok;
	}

}

class DetexTextureResource
{
	public detexTexture** texture = null;
	public String name = new .() ~ delete _;
	public ColorRGBA avgColor = .();
	public uint64 hash = 0;
	public AlphaMode alphaMode = AlphaMode.OPAQUE;
	public Format format = Format.UNKNOWN;
	public uint16 width = 0;
	public uint16 height = 0;
	public uint16 depth = 0;
	public uint16 mipNum = 0;
	public uint16 arraySize = 0;

	public ~this()
	{
		Detex.detexFreeTexture(texture, mipNum);
		texture = null;
	}

	[Inline] public void OverrideFormat(Format fmt)
	{
		this.format = fmt;
	}

	[Inline] public bool IsBlockCompressed()
	{
		return Detex.detexFormatIsCompressed(texture[0].format);
	}

	[Inline] public uint16 GetArraySize()
	{
		return arraySize;
	}

	[Inline] public uint16 GetMipNum()
	{
		return mipNum;
	}

	[Inline] public uint16 GetWidth()
	{
		return width;
	}

	[Inline] public uint16 GetHeight()
	{
		return height;
	}

	[Inline] public uint16 GetDepth()
	{
		return depth;
	}

	[Inline] public Format GetFormat()
	{
		return format;
	}

	public void GetSubresource(ref TextureSubresourceUploadDesc subresource, uint32 mipIndex, uint32 arrayIndex = 0)
	{
		// TODO: 3D images are not supported, "subresource.slices" needs to be allocated to store pointers to all slices of the current mipmap
		Runtime.Assert(GetDepth() == 1);
		//PLATFORM_UNUSED(arrayIndex);

		int32 rowPitch = 0, slicePitch = 0;
		Detex.detexComputePitch(texture[mipIndex].format, texture[mipIndex].width, texture[mipIndex].height, &rowPitch, &slicePitch);

		subresource.slices = texture[mipIndex].data;
		subresource.sliceNum = 1;
		subresource.rowPitch = (uint32)rowPitch;
		subresource.slicePitch = (uint32)slicePitch;
	}
}