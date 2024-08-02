using System;
using Sedulous.RHI;
using Sedulous.RHI.Raytracing;
using Win32.Graphics.Direct3D12;
using Win32.Graphics.Dxgi.Common;
using Win32.Graphics.Direct3D;

namespace Sedulous.RHI.DirectX12;

/// <summary>
/// Extensions methods used to convert values from Sedulous to DirectX.
/// </summary>
public static class DX12ExtensionsMethods
{
	public static void SetDebugName(ID3D12DeviceChild* pObject, char8* name)
	{
		var nameStr = scope String(name);
		(pObject).SetPrivateData(WKPDID_D3DDebugObjectName, (.)nameStr.Length, nameStr.ToScopedNativeWChar!());
	}

	/// <summary>
	/// To convert from VertexElementFormat to DXGI format.
	/// </summary>
	/// <param name="format">The format to convert.</param>
	/// <returns>The result DXGI format.</returns>
	public static DXGI_FORMAT ToDirectX(this ElementFormat format)
	{
		switch (format)
		{
		case ElementFormat.UByte:
			return .DXGI_FORMAT_R8_UINT;
		case ElementFormat.UByte2:
			return .DXGI_FORMAT_R8G8_UINT;
		case ElementFormat.UByte4:
			return .DXGI_FORMAT_R8G8B8A8_UINT;
		case ElementFormat.Byte:
			return .DXGI_FORMAT_R8_SINT;
		case ElementFormat.Byte2:
			return .DXGI_FORMAT_R8G8_SINT;
		case ElementFormat.Byte4:
			return .DXGI_FORMAT_R8G8B8A8_SINT;
		case ElementFormat.UByteNormalized:
			return .DXGI_FORMAT_R8_UNORM;
		case ElementFormat.UByte2Normalized:
			return .DXGI_FORMAT_R8G8_UNORM;
		case ElementFormat.UByte4Normalized:
			return .DXGI_FORMAT_R8G8B8A8_UNORM;
		case ElementFormat.ByteNormalized:
			return .DXGI_FORMAT_R8_SNORM;
		case ElementFormat.Byte2Normalized:
			return .DXGI_FORMAT_R8G8_SNORM;
		case ElementFormat.Byte4Normalized:
			return .DXGI_FORMAT_R8G8B8A8_SNORM;
		case ElementFormat.UShort:
			return .DXGI_FORMAT_R16_UINT;
		case ElementFormat.UShort2:
			return .DXGI_FORMAT_R16G16_UINT;
		case ElementFormat.UShort4:
			return .DXGI_FORMAT_R16G16B16A16_UINT;
		case ElementFormat.Short:
			return .DXGI_FORMAT_R16_SINT;
		case ElementFormat.Short2:
			return .DXGI_FORMAT_R16G16_SINT;
		case ElementFormat.Short4:
			return .DXGI_FORMAT_R16G16B16A16_SINT;
		case ElementFormat.UShortNormalized:
			return .DXGI_FORMAT_R16_UNORM;
		case ElementFormat.UShort2Normalized:
			return .DXGI_FORMAT_R16G16_UNORM;
		case ElementFormat.UShort4Normalized:
			return .DXGI_FORMAT_R16G16B16A16_UNORM;
		case ElementFormat.ShortNormalized:
			return .DXGI_FORMAT_R16_SNORM;
		case ElementFormat.Short2Normalized:
			return .DXGI_FORMAT_R16G16_SNORM;
		case ElementFormat.Short4Normalized:
			return .DXGI_FORMAT_R16G16B16A16_SNORM;
		case ElementFormat.Half:
			return .DXGI_FORMAT_R16_FLOAT;
		case ElementFormat.Half2:
			return .DXGI_FORMAT_R16G16_FLOAT;
		case ElementFormat.Half4:
			return .DXGI_FORMAT_R16G16B16A16_FLOAT;
		case ElementFormat.Float:
			return .DXGI_FORMAT_R32_FLOAT;
		case ElementFormat.Float2:
			return .DXGI_FORMAT_R32G32_FLOAT;
		case ElementFormat.Float3:
			return .DXGI_FORMAT_R32G32B32_FLOAT;
		case ElementFormat.Float4:
			return .DXGI_FORMAT_R32G32B32A32_FLOAT;
		case ElementFormat.UInt:
			return .DXGI_FORMAT_R32_UINT;
		case ElementFormat.UInt2:
			return .DXGI_FORMAT_R32G32_UINT;
		case ElementFormat.UInt3:
			return .DXGI_FORMAT_R32G32B32_UINT;
		case ElementFormat.UInt4:
			return .DXGI_FORMAT_R32G32B32A32_UINT;
		case ElementFormat.Int:
			return .DXGI_FORMAT_R32_SINT;
		case ElementFormat.Int2:
			return .DXGI_FORMAT_R32G32_SINT;
		case ElementFormat.Int3:
			return .DXGI_FORMAT_R32G32B32_SINT;
		case ElementFormat.Int4:
			return .DXGI_FORMAT_R32G32B32A32_SINT;
		default:
			return .DXGI_FORMAT_UNKNOWN;
		}
	}

	/// <summary>
	/// To convert from VertexSemanticType to HLSL semantic String.
	/// </summary>
	/// <param name="semantic">The semantic to convert.</param>
	/// <returns>The semantic String.</returns>
	public static String ToHLSLSemantic(this ElementSemanticType semantic)
	{
		switch (semantic)
		{
		case ElementSemanticType.Position:
			return "POSITION";
		case ElementSemanticType.TexCoord:
			return "TEXCOORD";
		case ElementSemanticType.Normal:
			return "NORMAL";
		case ElementSemanticType.Tangent:
			return "TANGENT";
		case ElementSemanticType.Binormal:
			return "BINORMAL";
		case ElementSemanticType.Color:
			return "COLOR";
		case ElementSemanticType.BlendIndices:
			return "BLENDINDICES";
		case ElementSemanticType.BlendWeight:
			return "BLENDWEIGHT";
		default:
			return null;
		}
	}

	/// <summary>
	/// To convert from ShaderStage to DirectX String.
	/// </summary>
	/// <param name="stage">The shaderstage to convert.</param>
	/// <returns>The result String.</returns>
	public static String ToDirectXString(this ShaderStages stage)
	{
		switch (stage)
		{
		case ShaderStages.Vertex:
			return "vs";
		case ShaderStages.Hull:
			return "hs";
		case ShaderStages.Domain:
			return "ds";
		case ShaderStages.Geometry:
			return "gs";
		case ShaderStages.Pixel:
			return "ps";
		case ShaderStages.Compute:
			return "cs";
		default:
			return null;
		}
	}

	/// <summary>
	/// To convert from indexformat to DXGI format.
	/// </summary>
	/// <param name="format">The indexformat to convert.</param>
	/// <returns>The result DXGI format.</returns>
	public static DXGI_FORMAT ToDirectX(this IndexFormat format)
	{
		switch (format)
		{
		case IndexFormat.UInt32:
			return .DXGI_FORMAT_R32_UINT;
		case IndexFormat.UInt16:
			return .DXGI_FORMAT_R16_UINT;
		default:
			return .DXGI_FORMAT_UNKNOWN;
		}
	}

	/// <summary>
	/// To convert from TextureSampleCount to DirectX SampleDescription.
	/// </summary>
	/// <param name="sampleCount">The TextureSampleCount to convert.</param>
	/// <returns>The SampleDescription value.</returns>
	public static DXGI_SAMPLE_DESC ToDirectX(this TextureSampleCount sampleCount)
	{
		switch (sampleCount)
		{
		case TextureSampleCount.Count2:
			return .(2, 0);
		case TextureSampleCount.Count4:
			return .(4, 0);
		case TextureSampleCount.Count8:
			return .(8, 0);
		case TextureSampleCount.Count16:
			return .(16, 0);
		case TextureSampleCount.Count32:
			return .(32, 0);
		case TextureSampleCount.None:
			return .(1, 0);
		default:
			return default(DXGI_SAMPLE_DESC);
		}
	}

	/// <summary>
	/// To convert from DirectX SampleDescription to TextureSampleCount.
	/// </summary>
	/// <param name="sampleDescription">The SampleDescription to convert.</param>
	/// <returns>The TextureSampleCount value.</returns>
	public static TextureSampleCount FromDirectX(this DXGI_SAMPLE_DESC sampleDescription)
	{
		switch (sampleDescription.Count)
		{
		case 2:
			return TextureSampleCount.Count2;
		case 4:
			return TextureSampleCount.Count4;
		case 8:
			return TextureSampleCount.Count8;
		case 16:
			return TextureSampleCount.Count16;
		case 32:
			return TextureSampleCount.Count32;
		case 1:
			return TextureSampleCount.None;
		default:
			return TextureSampleCount.None;
		}
	}

	/// <summary>
	/// Convert to DirectX Pixel Format.
	/// </summary>
	/// <param name="pixelFormat">pixelFormat.</param>
	/// <returns>DirectX pixel format.</returns>
	public static DXGI_FORMAT ToDirectX(this PixelFormat pixelFormat)
	{
		/*if (Enum.TryParse<Format>(pixelFormat.ToString(), out var result))
		{
			return result;
		}
		return Format.Unknown;*/

		var enumString = scope $"DXGI_FORMAT_{pixelFormat.ToString(.. scope .())}";
		if (Enum.Parse<DXGI_FORMAT>(enumString, true) case .Ok(let result))
		{
			return result;
		}
		return .DXGI_FORMAT_UNKNOWN;
	}

	/// <summary>
	/// Convert to DirectX Depth stencil format.
	/// </summary>
	/// <param name="pixelFormat">The pixel format.</param>
	/// <returns>DirectX pixel format for depth stencil.</returns>
	public static DXGI_FORMAT ToDepthStencilFormat(this PixelFormat pixelFormat)
	{
		DXGI_FORMAT result = .DXGI_FORMAT_UNKNOWN;
		switch (pixelFormat)
		{
		case PixelFormat.R16_Typeless,
			 PixelFormat.D16_UNorm:
			result = .DXGI_FORMAT_D16_UNORM;
			break;
		case PixelFormat.R32_Typeless,
			 PixelFormat.D32_Float:
			result =.DXGI_FORMAT_D32_FLOAT_S8X24_UINT;
			break;
		case PixelFormat.R24G8_Typeless,
			 PixelFormat.D24_UNorm_S8_UInt:
			result = .DXGI_FORMAT_D24_UNORM_S8_UINT;
			break;
		case PixelFormat.R32G8X24_Typeless,
			 PixelFormat.D32_Float_S8X24_UInt:
			result = .DXGI_FORMAT_D32_FLOAT_S8X24_UINT;
			break;
		default: break;
		}
		return result;
	}

	/// <summary>
	/// Convert to Veldrid PixelFormat to DirectX Pixel Format.
	/// </summary>
	/// <param name="pixelFormat">DirectX pixel format.</param>
	/// <returns>Veldrid pixel format.</returns>
	public static PixelFormat FromDirectX(this DXGI_FORMAT pixelFormat)
	{
		/*if (Enum.TryParse<PixelFormat>(pixelFormat.ToString(), out var result))
		{
			return result;
		}
		return PixelFormat.Unknown;*/

		
		var enumString = pixelFormat.ToString(.. scope .());
		enumString.Replace("DXGI_FORMAT_", "");
		if (Enum.Parse<PixelFormat>(enumString, true) case .Ok(let result))
		{
			return result;
		}
		return PixelFormat.Unknown;
	}

	/// <summary>
	/// Convert to DirectX CommandListType from CommandQueueType.
	/// </summary>
	/// <param name="queueType">The commandQueueType to convert.</param>
	/// <returns>The DirectX commandListType.</returns>
	public static D3D12_COMMAND_LIST_TYPE ToDirectX(this CommandQueueType queueType)
	{
		switch (queueType)
		{
		case CommandQueueType.Compute:
			return .D3D12_COMMAND_LIST_TYPE_COMPUTE;
		case CommandQueueType.Copy:
			return .D3D12_COMMAND_LIST_TYPE_COPY;
		case CommandQueueType.Graphics:
			return .D3D12_COMMAND_LIST_TYPE_DIRECT;
		default:
			return .D3D12_COMMAND_LIST_TYPE_DIRECT;
		}
	}

	/// <summary>
	/// To convert from DirectX BindFlags to TextureFlags.
	/// </summary>
	/// <param name="flags">the bindflags value to convert.</param>
	/// <returns>the ResourceUsage value.</returns>
	public static TextureFlags FromDirectX(this D3D12_RESOURCE_FLAGS flags)
	{
		TextureFlags textureFlags = TextureFlags.None;
		if ((flags & .D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL) != 0)
		{
			textureFlags |= TextureFlags.DepthStencil;
		}
		if ((flags & .D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET) != 0)
		{
			textureFlags |= TextureFlags.RenderTarget;
		}
		if ((flags & .D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS) != 0)
		{
			textureFlags |= TextureFlags.UnorderedAccess;
		}
		return textureFlags;
	}

	/// <summary>
	/// To convert from TextureFlags to DirectX BindFlags.
	/// </summary>
	/// <param name="flags">the textureflags value to convert.</param>
	/// <returns>the ResourceUsage value.</returns>
	public static D3D12_RESOURCE_FLAGS ToDirectX(this TextureFlags flags)
	{
		D3D12_RESOURCE_FLAGS resourceFlags = .D3D12_RESOURCE_FLAG_NONE;
		if ((flags & TextureFlags.DepthStencil) != 0)
		{
			resourceFlags |= .D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL;
		}
		if ((flags & TextureFlags.RenderTarget) != 0)
		{
			resourceFlags |= .D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET;
		}
		if ((flags & TextureFlags.UnorderedAccess) != 0)
		{
			resourceFlags |= .D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
		}
		return resourceFlags;
	}

	/// <summary>
	/// Converts to native sampler bordercolor.
	/// </summary>
	/// <param name="borderColor">The value to convert.</param>
	/// <returns>The native rawColor4.</returns>
	public static float[4] ToDirectX(this SamplerBorderColor borderColor)
	{
		switch (borderColor)
		{
		case SamplerBorderColor.TransparentBlack:
			return .(0f, 0f, 0f, 0f);
		case SamplerBorderColor.OpaqueBlack:
			return .(0f, 0f, 0f, 1f);
		case SamplerBorderColor.OpaqueWhite:
			return .(1f, 1f, 1f, 1f);
		default:
			return default;
		}
	}

	/// <summary>
	/// Converts to native Texturefilter.
	/// </summary>
	/// <param name="filter">The value to convert.</param>
	/// <param name="isComparison">If comparison function is active.</param>
	/// <returns>The native value.</returns>
	public static D3D12_FILTER ToDirectX(this TextureFilter filter, bool isComparison)
	{
		switch (filter)
		{
		case TextureFilter.MinPoint_MagPoint_MipPoint:
			if (!isComparison)
			{
				return .D3D12_FILTER_MIN_MAG_MIP_POINT;
			}
			return .D3D12_FILTER_COMPARISON_MIN_MAG_MIP_POINT;
		case TextureFilter.MinPoint_MagPoint_MipLinear:
			if (!isComparison)
			{
				return .D3D12_FILTER_MIN_MAG_POINT_MIP_LINEAR;
			}
			return .D3D12_FILTER_COMPARISON_MIN_MAG_POINT_MIP_LINEAR;
		case TextureFilter.MinPoint_MagLinear_MipPoint:
			if (!isComparison)
			{
				return .D3D12_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT;
			}
			return .D3D12_FILTER_COMPARISON_MIN_POINT_MAG_LINEAR_MIP_POINT;
		case TextureFilter.MinPoint_MagLinear_MipLinear:
			if (!isComparison)
			{
				return .D3D12_FILTER_MIN_POINT_MAG_MIP_LINEAR;
			}
			return .D3D12_FILTER_COMPARISON_MIN_POINT_MAG_MIP_LINEAR;
		case TextureFilter.MinLinear_MagPoint_MipPoint:
			if (!isComparison)
			{
				return .D3D12_FILTER_MIN_LINEAR_MAG_MIP_POINT;
			}
			return .D3D12_FILTER_COMPARISON_MIN_LINEAR_MAG_MIP_POINT;
		case TextureFilter.MinLinear_MagPoint_MipLinear:
			if (!isComparison)
			{
				return .D3D12_FILTER_MIN_LINEAR_MAG_POINT_MIP_LINEAR;
			}
			return .D3D12_FILTER_COMPARISON_MIN_LINEAR_MAG_POINT_MIP_LINEAR;
		case TextureFilter.MinLinear_MagLinear_MipPoint:
			if (!isComparison)
			{
				return .D3D12_FILTER_MIN_MAG_LINEAR_MIP_POINT;
			}
			return .D3D12_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT;
		case TextureFilter.Anisotropic:
			if (!isComparison)
			{
				return .D3D12_FILTER_ANISOTROPIC;
			}
			return .D3D12_FILTER_COMPARISON_ANISOTROPIC;
		case TextureFilter.MinLinear_MagLinear_MipLinear:
			if (!isComparison)
			{
				return .D3D12_FILTER_MIN_MAG_MIP_LINEAR;
			}
			return .D3D12_FILTER_COMPARISON_MIN_MAG_MIP_LINEAR;
		default:
			return .D3D12_FILTER_MIN_MAG_MIP_POINT;
		}
	}

	/// <summary>
	/// Converts to DirectX sampler address mode.
	/// </summary>
	/// <param name="addressMode">The address mode to convert.</param>
	/// <returns>The native addressMode.</returns>
	public static D3D12_TEXTURE_ADDRESS_MODE ToDirectX(this TextureAddressMode addressMode)
	{
		switch (addressMode)
		{
		case TextureAddressMode.Wrap:
			return .D3D12_TEXTURE_ADDRESS_MODE_WRAP;
		case TextureAddressMode.Mirror:
			return .D3D12_TEXTURE_ADDRESS_MODE_MIRROR;
		case TextureAddressMode.Border:
			return .D3D12_TEXTURE_ADDRESS_MODE_BORDER;
		case TextureAddressMode.Mirror_One:
			return .D3D12_TEXTURE_ADDRESS_MODE_MIRROR_ONCE;
		case TextureAddressMode.Clamp:
			return .D3D12_TEXTURE_ADDRESS_MODE_CLAMP;
		default:
			return (D3D12_TEXTURE_ADDRESS_MODE)0;
		}
	}

	/// <summary>
	/// Converts to DirectX compareFunction.
	/// </summary>
	/// <param name="function">The value to convert.</param>
	/// <returns>The native value.</returns>
	public static D3D12_COMPARISON_FUNC ToDirectX(this ComparisonFunction @function)
	{
		switch (@function)
		{
		case ComparisonFunction.Less:
			return .D3D12_COMPARISON_FUNC_LESS;
		case ComparisonFunction.Equal:
			return .D3D12_COMPARISON_FUNC_EQUAL;
		case ComparisonFunction.LessEqual:
			return .D3D12_COMPARISON_FUNC_LESS_EQUAL;
		case ComparisonFunction.Greater:
			return .D3D12_COMPARISON_FUNC_GREATER;
		case ComparisonFunction.NotEqual:
			return .D3D12_COMPARISON_FUNC_NOT_EQUAL;
		case ComparisonFunction.GreaterEqual:
			return .D3D12_COMPARISON_FUNC_GREATER_EQUAL;
		case ComparisonFunction.Always:
			return .D3D12_COMPARISON_FUNC_ALWAYS;
		case ComparisonFunction.Never:
			return .D3D12_COMPARISON_FUNC_NEVER;
		default:
			return (.)0;
		}
	}

	/// <summary>
	/// Converts to DirectX InputClassification enum.
	/// </summary>
	/// <param name="stepFunction">The value to convert.</param>
	/// <returns>The native value.</returns>
	public static D3D12_INPUT_CLASSIFICATION ToDirectX(this VertexStepFunction stepFunction)
	{
		if (stepFunction == VertexStepFunction.PerVertexData || stepFunction != VertexStepFunction.PerInstanceData)
		{
			return .D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA;
		}
		return .D3D12_INPUT_CLASSIFICATION_PER_INSTANCE_DATA;
	}

	/// <summary>
	/// Convert to DirectX HitGroupType.
	/// </summary>
	/// <param name="hitGroupType">HitGroup type.</param>
	/// <returns>DirectX HitGroupType.</returns>
	public static D3D12_HIT_GROUP_TYPE ToDirectX(this HitGroupDescription.HitGroupType hitGroupType)
	{
		if (hitGroupType == Raytracing.HitGroupDescription.HitGroupType.Triangles || hitGroupType != Raytracing.HitGroupDescription.HitGroupType.Procedural)
		{
			return .D3D12_HIT_GROUP_TYPE_TRIANGLES;
		}
		return .D3D12_HIT_GROUP_TYPE_PROCEDURAL_PRIMITIVE;
	}

	/// <summary>
	/// Convert to DirectX DescriptorRangeType.
	/// </summary>
	/// <param name="resourceType">The resource type.</param>
	/// <returns>DirectX DescriptorRangeType.</returns>
	public static D3D12_DESCRIPTOR_RANGE_TYPE ToDirectX(this ResourceType resourceType)
	{
		switch (resourceType)
		{
		case ResourceType.ConstantBuffer:
			return .D3D12_DESCRIPTOR_RANGE_TYPE_CBV;
		case ResourceType.StructuredBufferReadWrite,
			 ResourceType.TextureReadWrite:
			return .D3D12_DESCRIPTOR_RANGE_TYPE_UAV;
		case ResourceType.Sampler:
			return .D3D12_DESCRIPTOR_RANGE_TYPE_SAMPLER;
		default:
			return .D3D12_DESCRIPTOR_RANGE_TYPE_SRV;
		}
	}
}
