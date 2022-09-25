namespace NRI;

public static
{
	public static Format GetSupportedDepthFormat(Device device, uint32 minBits, bool stencil)
	{
		if (stencil)
		{
			if (minBits <= 24)
			{
				if (device.GetFormatSupport(Format.D24_UNORM_S8_UINT) & FormatSupportBits.DEPTH_STENCIL_ATTACHMENT != 0)
					return Format.D24_UNORM_S8_UINT;
			}
		}
		else
		{
			if (minBits <= 16)
			{
				if (device.GetFormatSupport(Format.D16_UNORM) & FormatSupportBits.DEPTH_STENCIL_ATTACHMENT != 0)
					return Format.D16_UNORM;
			}
			else if (minBits <= 24)
			{
				if (device.GetFormatSupport(Format.D24_UNORM_S8_UINT) & FormatSupportBits.DEPTH_STENCIL_ATTACHMENT != 0)
					return Format.D24_UNORM_S8_UINT;
			}

			if (device.GetFormatSupport(Format.D32_SFLOAT) & FormatSupportBits.DEPTH_STENCIL_ATTACHMENT != 0)
				return Format.D32_SFLOAT;
		}

		if (device.GetFormatSupport(Format.D32_SFLOAT_S8_UINT_X24) & FormatSupportBits.DEPTH_STENCIL_ATTACHMENT != 0)
			return Format.D32_SFLOAT_S8_UINT_X24;

		return Format.UNKNOWN;
	}

	public static TextureTransitionBarrierDesc TextureTransition(Texture texture, AccessBits prevAccess, AccessBits nextAccess, TextureLayout prevLayout, TextureLayout nextLayout,
		uint16 mipOffset = 0, uint16 mipNum = REMAINING_MIP_LEVELS, uint16 arrayOffset = 0, uint16 arraySize = REMAINING_ARRAY_LAYERS)
	{
		TextureTransitionBarrierDesc textureTransitionBarrierDesc = .();
		textureTransitionBarrierDesc.texture = texture;
		textureTransitionBarrierDesc.prevAccess = prevAccess;
		textureTransitionBarrierDesc.nextAccess = nextAccess;
		textureTransitionBarrierDesc.prevLayout = prevLayout;
		textureTransitionBarrierDesc.nextLayout = nextLayout;
		textureTransitionBarrierDesc.mipOffset = mipOffset;
		textureTransitionBarrierDesc.mipNum = mipNum;
		textureTransitionBarrierDesc.arrayOffset = arrayOffset;
		textureTransitionBarrierDesc.arraySize = arraySize;

		return textureTransitionBarrierDesc;
	}

	public static TextureTransitionBarrierDesc TextureTransition(Texture texture, AccessBits nextAccess, TextureLayout nextLayout,
		uint16 mipOffset = 0, uint16 mipNum = REMAINING_MIP_LEVELS, uint16 arrayOffset = 0, uint16 arraySize = REMAINING_ARRAY_LAYERS)
	{
		TextureTransitionBarrierDesc textureTransitionBarrierDesc = .();
		textureTransitionBarrierDesc.texture = texture;
		textureTransitionBarrierDesc.prevAccess = AccessBits.UNKNOWN;
		textureTransitionBarrierDesc.nextAccess = nextAccess;
		textureTransitionBarrierDesc.prevLayout = TextureLayout.UNKNOWN;
		textureTransitionBarrierDesc.nextLayout = nextLayout;
		textureTransitionBarrierDesc.mipOffset = mipOffset;
		textureTransitionBarrierDesc.mipNum = mipNum;
		textureTransitionBarrierDesc.arrayOffset = arrayOffset;
		textureTransitionBarrierDesc.arraySize = arraySize;

		return textureTransitionBarrierDesc;
	}

	public static readonly ref TextureTransitionBarrierDesc TextureTransition(ref TextureTransitionBarrierDesc prevState, AccessBits nextAccess, TextureLayout nextLayout, uint16 mipOffset = 0, uint16 mipNum = REMAINING_MIP_LEVELS)
	{
		prevState.mipOffset = mipOffset;
		prevState.mipNum = mipNum;
		prevState.prevAccess = prevState.nextAccess;
		prevState.nextAccess = nextAccess;
		prevState.prevLayout = prevState.nextLayout;
		prevState.nextLayout = nextLayout;

		return ref prevState;
	}
}

struct CTextureDesc : TextureDesc
{
	this(TextureDesc textureDesc) : base()
	{
		type = textureDesc.type;
		usageMask = textureDesc.usageMask;
		format = textureDesc.format;
		size = textureDesc.size;
		mipNum = textureDesc.mipNum;
		arraySize = textureDesc.arraySize;
		sampleNum = textureDesc.sampleNum;
		physicalDeviceMask = textureDesc.physicalDeviceMask;
	}

	public const TextureUsageBits DEFAULT_USAGE_MASK = TextureUsageBits.SHADER_RESOURCE;

	public static CTextureDesc Texture1D(Format format, uint16 width, uint16 mipNum = 1, uint16 arraySize = 1, TextureUsageBits usageMask = DEFAULT_USAGE_MASK)
	{
		TextureDesc textureDesc = .();
		textureDesc.type = TextureType.TEXTURE_1D;
		textureDesc.format = format;
		textureDesc.usageMask = usageMask;
		textureDesc.size[0] = width;
		textureDesc.size[1] = 1;
		textureDesc.size[2] = 1;
		textureDesc.mipNum = mipNum;
		textureDesc.arraySize = arraySize;
		textureDesc.sampleNum = 1;

		return CTextureDesc(textureDesc);
	}

	public static CTextureDesc Texture2D(Format format, uint16 width, uint16 height, uint16 mipNum = 1, uint16 arraySize = 1, TextureUsageBits usageMask = DEFAULT_USAGE_MASK, uint8 sampleNum = 1)
	{
		TextureDesc textureDesc = .();
		textureDesc.type = TextureType.TEXTURE_2D;
		textureDesc.format = format;
		textureDesc.usageMask = usageMask;
		textureDesc.size[0] = width;
		textureDesc.size[1] = height;
		textureDesc.size[2] = 1;
		textureDesc.mipNum = mipNum;
		textureDesc.arraySize = arraySize;
		textureDesc.sampleNum = sampleNum;

		return CTextureDesc(textureDesc);
	}

	public static CTextureDesc Texture3D(Format format, uint16 width, uint16 height, uint16 depth, uint16 mipNum = 1, TextureUsageBits usageMask = DEFAULT_USAGE_MASK)
	{
		TextureDesc textureDesc = .();
		textureDesc.type = TextureType.TEXTURE_3D;
		textureDesc.format = format;
		textureDesc.usageMask = usageMask;
		textureDesc.size[0] = width;
		textureDesc.size[1] = height;
		textureDesc.size[2] = depth;
		textureDesc.mipNum = mipNum;
		textureDesc.arraySize = 1;
		textureDesc.sampleNum = 1;

		return CTextureDesc(textureDesc);
	}
}