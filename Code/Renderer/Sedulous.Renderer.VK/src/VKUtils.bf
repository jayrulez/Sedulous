using Bulkan;
using System;
using System.Collections;
using Bulkan.Utilities;
using Sedulous.Renderer.VK.Internal;
namespace Sedulous.Renderer.VK;

static
{
	public const uint64 DEFAULT_TIMEOUT = 10000000000; // 10 second

	public const uint32 BARRIER_DEDUCTION_LEVEL_NONE = 0;
	public const uint32  BARRIER_DEDUCTION_LEVEL_BASIC = 1;
	public const uint32  BARRIER_DEDUCTION_LEVEL_FULL  = 2;

#if !BARRIER_DEDUCTION_LEVEL
	public const uint32 BARRIER_DEDUCTION_LEVEL = BARRIER_DEDUCTION_LEVEL_BASIC;
#endif

	public static VkQueryType mapVkQueryType(QueryType type)
	{
		switch (type) {
		case QueryType.OCCLUSION: return .VK_QUERY_TYPE_OCCLUSION;
		case QueryType.PIPELINE_STATISTICS: return .VK_QUERY_TYPE_PIPELINE_STATISTICS;
		case QueryType.TIMESTAMP: return .VK_QUERY_TYPE_TIMESTAMP;
		default:
			{
				Runtime.Assert(false);
				return .VK_QUERY_TYPE_OCCLUSION;
			}
		}
	}

	public static VkFormat mapVkFormat(Format format, CCVKGPUDevice gpuDevice)
	{
		switch (format) {
		case Format.R8: return .VK_FORMAT_R8_UNORM;
		case Format.R8SN: return .VK_FORMAT_R8_SNORM;
		case Format.R8UI: return .VK_FORMAT_R8_UINT;
		case Format.R8I: return .VK_FORMAT_R8_SINT;
		case Format.RG8: return .VK_FORMAT_R8G8_UNORM;
		case Format.RG8SN: return .VK_FORMAT_R8G8_SNORM;
		case Format.RG8UI: return .VK_FORMAT_R8G8_UINT;
		case Format.RG8I: return .VK_FORMAT_R8G8_SINT;
		case Format.RGB8: return .VK_FORMAT_R8G8B8_UNORM;
		case Format.SRGB8: return .VK_FORMAT_R8G8B8_SRGB;
		case Format.RGB8SN: return .VK_FORMAT_R8G8B8_SNORM;
		case Format.RGB8UI: return .VK_FORMAT_R8G8B8_UINT;
		case Format.RGB8I: return .VK_FORMAT_R8G8B8_SINT;
		case Format.RGBA8: return .VK_FORMAT_R8G8B8A8_UNORM;
		case Format.BGRA8: return .VK_FORMAT_B8G8R8A8_UNORM;
		case Format.SRGB8_A8: return .VK_FORMAT_R8G8B8A8_SRGB;
		case Format.RGBA8SN: return .VK_FORMAT_R8G8B8A8_SNORM;
		case Format.RGBA8UI: return .VK_FORMAT_R8G8B8A8_UINT;
		case Format.RGBA8I: return .VK_FORMAT_R8G8B8A8_SINT;
		case Format.R16I: return .VK_FORMAT_R16_SINT;
		case Format.R16UI: return .VK_FORMAT_R16_UINT;
		case Format.R16F: return .VK_FORMAT_R16_SFLOAT;
		case Format.RG16I: return .VK_FORMAT_R16G16_SINT;
		case Format.RG16UI: return .VK_FORMAT_R16G16_UINT;
		case Format.RG16F: return .VK_FORMAT_R16G16_SFLOAT;
		case Format.RGB16I: return .VK_FORMAT_R16G16B16_SINT;
		case Format.RGB16UI: return .VK_FORMAT_R16G16B16_UINT;
		case Format.RGB16F: return .VK_FORMAT_R16G16B16_SFLOAT;
		case Format.RGBA16I: return .VK_FORMAT_R16G16B16A16_SINT;
		case Format.RGBA16UI: return .VK_FORMAT_R16G16B16A16_UINT;
		case Format.RGBA16F: return .VK_FORMAT_R16G16B16A16_SFLOAT;
		case Format.R32I: return .VK_FORMAT_R32_SINT;
		case Format.R32UI: return .VK_FORMAT_R32_UINT;
		case Format.R32F: return .VK_FORMAT_R32_SFLOAT;
		case Format.RG32I: return .VK_FORMAT_R32G32_SINT;
		case Format.RG32UI: return .VK_FORMAT_R32G32_UINT;
		case Format.RG32F: return .VK_FORMAT_R32G32_SFLOAT;
		case Format.RGB32I: return .VK_FORMAT_R32G32B32_SINT;
		case Format.RGB32UI: return .VK_FORMAT_R32G32B32_UINT;
		case Format.RGB32F: return .VK_FORMAT_R32G32B32_SFLOAT;
		case Format.RGBA32I: return .VK_FORMAT_R32G32B32A32_SINT;
		case Format.RGBA32UI: return .VK_FORMAT_R32G32B32A32_UINT;
		case Format.RGBA32F: return .VK_FORMAT_R32G32B32A32_SFLOAT;

		case Format.R5G6B5: return .VK_FORMAT_R5G6B5_UNORM_PACK16;
		case Format.R11G11B10F: return .VK_FORMAT_B10G11R11_UFLOAT_PACK32;
		case Format.RGB5A1: return .VK_FORMAT_R5G5B5A1_UNORM_PACK16;
		case Format.RGBA4: return .VK_FORMAT_R4G4B4A4_UNORM_PACK16;
		case Format.RGB10A2: return .VK_FORMAT_A2B10G10R10_UNORM_PACK32;
		case Format.RGB10A2UI: return .VK_FORMAT_A2B10G10R10_UINT_PACK32;
		case Format.RGB9E5: return .VK_FORMAT_E5B9G9R9_UFLOAT_PACK32;
		case Format.DEPTH: return gpuDevice.depthFormat;
		case Format.DEPTH_STENCIL: return gpuDevice.depthStencilFormat;

		case Format.BC1: return .VK_FORMAT_BC1_RGB_UNORM_BLOCK;
		case Format.BC1_ALPHA: return .VK_FORMAT_BC1_RGBA_UNORM_BLOCK;
		case Format.BC1_SRGB: return .VK_FORMAT_BC1_RGB_SRGB_BLOCK;
		case Format.BC1_SRGB_ALPHA: return .VK_FORMAT_BC1_RGBA_SRGB_BLOCK;
		case Format.BC2: return .VK_FORMAT_BC2_UNORM_BLOCK;
		case Format.BC2_SRGB: return .VK_FORMAT_BC2_SRGB_BLOCK;
		case Format.BC3: return .VK_FORMAT_BC3_UNORM_BLOCK;
		case Format.BC3_SRGB: return .VK_FORMAT_BC3_SRGB_BLOCK;
		case Format.BC4: return .VK_FORMAT_BC4_UNORM_BLOCK;
		case Format.BC4_SNORM: return .VK_FORMAT_BC4_SNORM_BLOCK;
		case Format.BC5: return .VK_FORMAT_BC5_UNORM_BLOCK;
		case Format.BC5_SNORM: return .VK_FORMAT_BC5_SNORM_BLOCK;
		case Format.BC6H_UF16: return .VK_FORMAT_BC6H_UFLOAT_BLOCK;
		case Format.BC6H_SF16: return .VK_FORMAT_BC6H_SFLOAT_BLOCK;
		case Format.BC7: return .VK_FORMAT_BC7_UNORM_BLOCK;
		case Format.BC7_SRGB: return .VK_FORMAT_BC7_SRGB_BLOCK;

		case Format.ETC2_RGB8: return .VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK;
		case Format.ETC2_SRGB8: return .VK_FORMAT_ETC2_R8G8B8_SRGB_BLOCK;
		case Format.ETC2_RGB8_A1: return .VK_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK;
		case Format.ETC2_SRGB8_A1: return .VK_FORMAT_ETC2_R8G8B8A1_SRGB_BLOCK;
		case Format.ETC2_RGBA8: return .VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK;
		case Format.ETC2_SRGB8_A8: return .VK_FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK;
		case Format.EAC_R11: return .VK_FORMAT_EAC_R11_UNORM_BLOCK;
		case Format.EAC_R11SN: return .VK_FORMAT_EAC_R11_SNORM_BLOCK;
		case Format.EAC_RG11: return .VK_FORMAT_EAC_R11G11_UNORM_BLOCK;
		case Format.EAC_RG11SN: return .VK_FORMAT_EAC_R11G11_SNORM_BLOCK;

		case Format.PVRTC_RGB2,
			Format.PVRTC_RGBA2: return .VK_FORMAT_PVRTC1_2BPP_UNORM_BLOCK_IMG;
		case Format.PVRTC_RGB4,
			Format.PVRTC_RGBA4: return .VK_FORMAT_PVRTC1_4BPP_UNORM_BLOCK_IMG;
		case Format.PVRTC2_2BPP: return .VK_FORMAT_PVRTC2_2BPP_UNORM_BLOCK_IMG;
		case Format.PVRTC2_4BPP: return .VK_FORMAT_PVRTC2_4BPP_UNORM_BLOCK_IMG;

		case Format.ASTC_RGBA_4X4: return .VK_FORMAT_ASTC_4x4_UNORM_BLOCK;
		case Format.ASTC_RGBA_5X4: return .VK_FORMAT_ASTC_5x4_UNORM_BLOCK;
		case Format.ASTC_RGBA_5X5: return .VK_FORMAT_ASTC_5x5_UNORM_BLOCK;
		case Format.ASTC_RGBA_6X5: return .VK_FORMAT_ASTC_6x5_UNORM_BLOCK;
		case Format.ASTC_RGBA_6X6: return .VK_FORMAT_ASTC_6x6_UNORM_BLOCK;
		case Format.ASTC_RGBA_8X5: return .VK_FORMAT_ASTC_8x5_UNORM_BLOCK;
		case Format.ASTC_RGBA_8X6: return .VK_FORMAT_ASTC_8x6_UNORM_BLOCK;
		case Format.ASTC_RGBA_8X8: return .VK_FORMAT_ASTC_8x8_UNORM_BLOCK;
		case Format.ASTC_RGBA_10X5: return .VK_FORMAT_ASTC_10x5_UNORM_BLOCK;
		case Format.ASTC_RGBA_10X6: return .VK_FORMAT_ASTC_10x6_UNORM_BLOCK;
		case Format.ASTC_RGBA_10X8: return .VK_FORMAT_ASTC_10x8_UNORM_BLOCK;
		case Format.ASTC_RGBA_10X10: return .VK_FORMAT_ASTC_10x10_UNORM_BLOCK;
		case Format.ASTC_RGBA_12X10: return .VK_FORMAT_ASTC_12x10_UNORM_BLOCK;
		case Format.ASTC_RGBA_12X12: return .VK_FORMAT_ASTC_12x12_UNORM_BLOCK;

		case Format.ASTC_SRGBA_4X4: return .VK_FORMAT_ASTC_4x4_SRGB_BLOCK;
		case Format.ASTC_SRGBA_5X4: return .VK_FORMAT_ASTC_5x4_SRGB_BLOCK;
		case Format.ASTC_SRGBA_5X5: return .VK_FORMAT_ASTC_5x5_SRGB_BLOCK;
		case Format.ASTC_SRGBA_6X5: return .VK_FORMAT_ASTC_6x5_SRGB_BLOCK;
		case Format.ASTC_SRGBA_6X6: return .VK_FORMAT_ASTC_6x6_SRGB_BLOCK;
		case Format.ASTC_SRGBA_8X5: return .VK_FORMAT_ASTC_8x5_SRGB_BLOCK;
		case Format.ASTC_SRGBA_8X6: return .VK_FORMAT_ASTC_8x6_SRGB_BLOCK;
		case Format.ASTC_SRGBA_8X8: return .VK_FORMAT_ASTC_8x8_SRGB_BLOCK;
		case Format.ASTC_SRGBA_10X5: return .VK_FORMAT_ASTC_10x5_SRGB_BLOCK;
		case Format.ASTC_SRGBA_10X6: return .VK_FORMAT_ASTC_10x6_SRGB_BLOCK;
		case Format.ASTC_SRGBA_10X8: return .VK_FORMAT_ASTC_10x8_SRGB_BLOCK;
		case Format.ASTC_SRGBA_10X10: return .VK_FORMAT_ASTC_10x10_SRGB_BLOCK;
		case Format.ASTC_SRGBA_12X10: return .VK_FORMAT_ASTC_12x10_SRGB_BLOCK;
		case Format.ASTC_SRGBA_12X12: return .VK_FORMAT_ASTC_12x12_SRGB_BLOCK;

		default:
			{
				Runtime.Assert(false);
				return .VK_FORMAT_B8G8R8A8_UNORM;
			}
		}
	}

	public static VkAttachmentLoadOp mapVkLoadOp(LoadOp loadOp)
	{
		switch (loadOp) {
		case LoadOp.CLEAR: return .VK_ATTACHMENT_LOAD_OP_CLEAR;
		case LoadOp.LOAD: return .VK_ATTACHMENT_LOAD_OP_LOAD;
		case LoadOp.DISCARD: return .VK_ATTACHMENT_LOAD_OP_DONT_CARE;
		default:
			{
				Runtime.Assert(false);
				return .VK_ATTACHMENT_LOAD_OP_LOAD;
			}
		}
	}

	public static VkAttachmentStoreOp mapVkStoreOp(StoreOp storeOp)
	{
		switch (storeOp) {
		case StoreOp.STORE: return .VK_ATTACHMENT_STORE_OP_STORE;
		case StoreOp.DISCARD: return .VK_ATTACHMENT_STORE_OP_DONT_CARE;
		default:
			{
				Runtime.Assert(false);
				return .VK_ATTACHMENT_STORE_OP_STORE;
			}
		}
	}

	public static VkBufferUsageFlags mapVkBufferUsageFlagBits(BufferUsage usage)
	{
		VkBufferUsageFlags flags = 0U;
		if (hasFlag(usage, BufferUsage.TRANSFER_SRC)) flags |= .VK_BUFFER_USAGE_TRANSFER_SRC_BIT;
		if (hasFlag(usage, BufferUsage.TRANSFER_DST)) flags |= .VK_BUFFER_USAGE_TRANSFER_DST_BIT;
		if (hasFlag(usage, BufferUsage.INDEX)) flags |= .VK_BUFFER_USAGE_INDEX_BUFFER_BIT;
		if (hasFlag(usage, BufferUsage.VERTEX)) flags |= .VK_BUFFER_USAGE_VERTEX_BUFFER_BIT;
		if (hasFlag(usage, BufferUsage.UNIFORM)) flags |= .VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;
		if (hasFlag(usage, BufferUsage.STORAGE)) flags |= .VK_BUFFER_USAGE_STORAGE_BUFFER_BIT;
		if (hasFlag(usage, BufferUsage.INDIRECT)) flags |= .VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT;
		return (VkBufferUsageFlags)(flags);
	}

	public static VkImageType mapVkImageType(TextureType type)
	{
		switch (type) {
		case TextureType.TEX1D,
			TextureType.TEX1D_ARRAY: return .VK_IMAGE_TYPE_1D;
		case TextureType.CUBE,
			TextureType.TEX2D,
			TextureType.TEX2D_ARRAY: return .VK_IMAGE_TYPE_2D;
		case TextureType.TEX3D: return .VK_IMAGE_TYPE_3D;
		default:
			{
				Runtime.Assert(false);
				return .VK_IMAGE_TYPE_2D;
			}
		}
	}

	public static VkFormatFeatureFlags mapVkFormatFeatureFlags(TextureUsage usage)
	{
		VkFormatFeatureFlags flags = 0U;
		if (hasFlag(usage, TextureUsage.TRANSFER_SRC)) flags |= .VK_FORMAT_FEATURE_TRANSFER_SRC_BIT;
		if (hasFlag(usage, TextureUsage.TRANSFER_DST)) flags |= .VK_FORMAT_FEATURE_TRANSFER_DST_BIT;
		if (hasFlag(usage, TextureUsage.SAMPLED)) flags |= .VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT;
		if (hasFlag(usage, TextureUsage.STORAGE)) flags |= .VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT;
		if (hasFlag(usage, TextureUsage.COLOR_ATTACHMENT)) flags |= .VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT;
		if (hasFlag(usage, TextureUsage.DEPTH_STENCIL_ATTACHMENT)) flags |= .VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT;
		return (VkFormatFeatureFlags)(flags);
	}

	public static VkImageUsageFlags mapVkImageUsageFlags(TextureUsage usage, TextureFlags textureFlags)
	{
		VkImageUsageFlags flags = 0;
		if (hasFlag(usage, TextureUsage.TRANSFER_SRC)) flags |= .VK_IMAGE_USAGE_TRANSFER_SRC_BIT;
		if (hasFlag(usage, TextureUsage.TRANSFER_DST)) flags |= .VK_IMAGE_USAGE_TRANSFER_DST_BIT;
		if (hasFlag(usage, TextureUsage.SAMPLED)) flags |= .VK_IMAGE_USAGE_SAMPLED_BIT;
		if (hasFlag(usage, TextureUsage.STORAGE)) flags |= .VK_IMAGE_USAGE_STORAGE_BIT;
		if (hasFlag(usage, TextureUsage.COLOR_ATTACHMENT)) flags |= .VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
		if (hasFlag(usage, TextureUsage.DEPTH_STENCIL_ATTACHMENT)) flags |= .VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT;
		if (hasFlag(usage, TextureUsage.INPUT_ATTACHMENT)) flags |= .VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT;
		if (hasFlag(usage, TextureUsage.SHADING_RATE)) flags |= .VK_IMAGE_USAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR;

		if (hasFlag(textureFlags, TextureFlags.GEN_MIPMAP))
		{
			flags |= .VK_IMAGE_USAGE_TRANSFER_SRC_BIT;
		}
		if (hasFlag(textureFlags, TextureFlags.LAZILY_ALLOCATED))
		{
			flags |= .VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT;
		}
		return flags;
	}

	public static VkImageAspectFlags mapVkImageAspectFlags(Format format)
	{
		VkImageAspectFlags aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
		readonly ref FormatInfo info = ref GFX_FORMAT_INFOS[uint32(format)];
		if (info.hasDepth) aspectMask = .VK_IMAGE_ASPECT_DEPTH_BIT;
		if (info.hasStencil) aspectMask |= .VK_IMAGE_ASPECT_STENCIL_BIT;
		return aspectMask;
	}

	public static VkImageCreateFlags mapVkImageCreateFlags(TextureType type)
	{
		VkImageCreateFlags res = 0U;
		switch (type) {
		case TextureType.CUBE: res |= .VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT; break;
		default: break;
		}
		return (VkImageCreateFlags)(res);
	}

	public static VkImageViewType mapVkImageViewType(TextureType viewType)
	{
		switch (viewType) {
		case TextureType.TEX1D: return .VK_IMAGE_VIEW_TYPE_1D;
		case TextureType.TEX1D_ARRAY: return .VK_IMAGE_VIEW_TYPE_1D_ARRAY;
		case TextureType.TEX2D: return .VK_IMAGE_VIEW_TYPE_2D;
		case TextureType.TEX2D_ARRAY: return .VK_IMAGE_VIEW_TYPE_2D_ARRAY;
		case TextureType.TEX3D: return .VK_IMAGE_VIEW_TYPE_3D;
		case TextureType.CUBE: return .VK_IMAGE_VIEW_TYPE_CUBE;
		default:
			{
				Runtime.Assert(false);
				return .VK_IMAGE_VIEW_TYPE_2D;
			}
		}
	}

	public static VkCommandBufferLevel mapVkCommandBufferLevel(CommandBufferType type)
	{
		switch (type) {
		case CommandBufferType.PRIMARY: return .VK_COMMAND_BUFFER_LEVEL_PRIMARY;
		case CommandBufferType.SECONDARY: return .VK_COMMAND_BUFFER_LEVEL_SECONDARY;
		default:
			{
				Runtime.Assert(false);
				return .VK_COMMAND_BUFFER_LEVEL_SECONDARY;
			}
		}
	}

	public static VkDescriptorType mapVkDescriptorType(DescriptorType type)
	{
		switch (type) {
		case DescriptorType.DYNAMIC_UNIFORM_BUFFER: return .VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC;
		case DescriptorType.UNIFORM_BUFFER: return .VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
		case DescriptorType.DYNAMIC_STORAGE_BUFFER: return .VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC;
		case DescriptorType.STORAGE_BUFFER: return .VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
		case DescriptorType.SAMPLER_TEXTURE: return .VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
		case DescriptorType.SAMPLER: return .VK_DESCRIPTOR_TYPE_SAMPLER;
		case DescriptorType.TEXTURE: return .VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE;
		case DescriptorType.STORAGE_IMAGE: return .VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
		case DescriptorType.INPUT_ATTACHMENT: return .VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT;
		default:
			{
				Runtime.Assert(false);
				return .VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
			}
		}
	}

	public static VkColorComponentFlags mapVkColorComponentFlags(ColorMask colorMask)
	{
		VkColorComponentFlags flags = 0U;
		if (hasFlag(colorMask, ColorMask.R)) flags |= .VK_COLOR_COMPONENT_R_BIT;
		if (hasFlag(colorMask, ColorMask.G)) flags |= .VK_COLOR_COMPONENT_G_BIT;
		if (hasFlag(colorMask, ColorMask.B)) flags |= .VK_COLOR_COMPONENT_B_BIT;
		if (hasFlag(colorMask, ColorMask.A)) flags |= .VK_COLOR_COMPONENT_A_BIT;
		return (VkColorComponentFlags)(flags);
	}

	public static VkShaderStageFlags mapVkShaderStageFlagBits(ShaderStageFlagBit stage)
	{
		switch (stage) {
		case ShaderStageFlagBit.VERTEX: return .VK_SHADER_STAGE_VERTEX_BIT;
		case ShaderStageFlagBit.CONTROL: return .VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT;
		case ShaderStageFlagBit.EVALUATION: return .VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT;
		case ShaderStageFlagBit.GEOMETRY: return .VK_SHADER_STAGE_GEOMETRY_BIT;
		case ShaderStageFlagBit.FRAGMENT: return .VK_SHADER_STAGE_FRAGMENT_BIT;
		case ShaderStageFlagBit.COMPUTE: return .VK_SHADER_STAGE_COMPUTE_BIT;
		default:
			{
				Runtime.Assert(false);
				return .VK_SHADER_STAGE_VERTEX_BIT;
			}
		}
	}

	public static VkShaderStageFlags mapVkShaderStageFlags(ShaderStageFlagBit stages)
	{
		VkShaderStageFlags flags = 0U;
		if (hasFlag(stages, ShaderStageFlagBit.VERTEX)) flags |= .VK_SHADER_STAGE_VERTEX_BIT;
		if (hasFlag(stages, ShaderStageFlagBit.CONTROL)) flags |= .VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT;
		if (hasFlag(stages, ShaderStageFlagBit.EVALUATION)) flags |= .VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT;
		if (hasFlag(stages, ShaderStageFlagBit.GEOMETRY)) flags |= .VK_SHADER_STAGE_GEOMETRY_BIT;
		if (hasFlag(stages, ShaderStageFlagBit.FRAGMENT)) flags |= .VK_SHADER_STAGE_FRAGMENT_BIT;
		if (hasFlag(stages, ShaderStageFlagBit.COMPUTE)) flags |= .VK_SHADER_STAGE_COMPUTE_BIT;
		return (VkShaderStageFlags)(flags);
	}

	public static SurfaceTransform mapSurfaceTransform(VkSurfaceTransformFlagsKHR transform)
	{
		if (transform & .VK_SURFACE_TRANSFORM_ROTATE_90_BIT_KHR != 0) return SurfaceTransform.ROTATE_90;
		if (transform & .VK_SURFACE_TRANSFORM_ROTATE_180_BIT_KHR != 0) return SurfaceTransform.ROTATE_180;
		if (transform & .VK_SURFACE_TRANSFORM_ROTATE_270_BIT_KHR != 0) return SurfaceTransform.ROTATE_270;
		return SurfaceTransform.IDENTITY;
	}

	public static void mapVendorName(uint32 vendorID, String name)
	{
		switch (vendorID) {
		case 0x1002: name.Append("Advanced Micro Devices, Inc."); return;
		case 0x1010: name.Append("Imagination Technologies"); return;
		case 0x106b: name.Append("Apple Inc."); return;
		case 0x10DE: name.Append("Nvidia Corporation"); return;
		case 0x13B5: name.Append("Arm Limited"); return;
		case 0x5143: name.Append("Qualcomm Incorporated"); return;
		case 0x8086: name.Append("Intel Corporation"); return;
		}
		name.AppendF("Unknown VendorID {}", vendorID);
	}

	public const VkSurfaceTransformFlagsKHR TRANSFORMS_THAT_REQUIRE_FLIPPING =
		.VK_SURFACE_TRANSFORM_ROTATE_90_BIT_KHR |
		.VK_SURFACE_TRANSFORM_ROTATE_270_BIT_KHR;

	public const VkPrimitiveTopology[?] VK_PRIMITIVE_MODES = .(
		.VK_PRIMITIVE_TOPOLOGY_POINT_LIST, // POINT_LIST
		.VK_PRIMITIVE_TOPOLOGY_LINE_LIST, // LINE_LIST
		.VK_PRIMITIVE_TOPOLOGY_LINE_STRIP, // LINE_STRIP
		(VkPrimitiveTopology)(0), // LINE_LOOP
		.VK_PRIMITIVE_TOPOLOGY_LINE_LIST_WITH_ADJACENCY, // LINE_LIST_ADJACENCY
		.VK_PRIMITIVE_TOPOLOGY_LINE_STRIP_WITH_ADJACENCY, // LINE_STRIP_ADJACENCY
		(VkPrimitiveTopology)(0), // ISO_LINE_LIST
		.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST, // TRIANGLE_LIST
		.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP, // TRIANGLE_STRIP
		.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_FAN, // TRIANGLE_FAN
		.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST_WITH_ADJACENCY, // TRIANGLE_LIST_ADJACENCY
		.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP_WITH_ADJACENCY, // TRIANGLE_STRIP_ADJACENCY,
		(VkPrimitiveTopology)(0), // TRIANGLE_PATCH_ADJACENCY,
		.VK_PRIMITIVE_TOPOLOGY_PATCH_LIST // QUAD_PATCH_LIST,
		);

	public const VkCullModeFlags[?] VK_CULL_MODES = .(
		.VK_CULL_MODE_NONE,
		.VK_CULL_MODE_FRONT_BIT,
		.VK_CULL_MODE_BACK_BIT
		);

	public const VkPolygonMode[?] VK_POLYGON_MODES = .(
		.VK_POLYGON_MODE_FILL,
		.VK_POLYGON_MODE_LINE,
		.VK_POLYGON_MODE_POINT
		);

	public const VkCompareOp[?] VK_CMP_FUNCS = .(
		.VK_COMPARE_OP_NEVER,
		.VK_COMPARE_OP_LESS,
		.VK_COMPARE_OP_EQUAL,
		.VK_COMPARE_OP_LESS_OR_EQUAL,
		.VK_COMPARE_OP_GREATER,
		.VK_COMPARE_OP_NOT_EQUAL,
		.VK_COMPARE_OP_GREATER_OR_EQUAL,
		.VK_COMPARE_OP_ALWAYS
		);

	public const VkStencilOp[?] VK_STENCIL_OPS = .(
		.VK_STENCIL_OP_ZERO,
		.VK_STENCIL_OP_KEEP,
		.VK_STENCIL_OP_REPLACE,
		.VK_STENCIL_OP_INCREMENT_AND_CLAMP,
		.VK_STENCIL_OP_DECREMENT_AND_CLAMP,
		.VK_STENCIL_OP_INVERT,
		.VK_STENCIL_OP_INCREMENT_AND_WRAP,
		.VK_STENCIL_OP_DECREMENT_AND_WRAP
		);

	public const VkBlendOp[?] VK_BLEND_OPS = .(
		.VK_BLEND_OP_ADD,
		.VK_BLEND_OP_SUBTRACT,
		.VK_BLEND_OP_REVERSE_SUBTRACT,
		.VK_BLEND_OP_MIN,
		.VK_BLEND_OP_MAX
		);

	public const VkBlendFactor[?] VK_BLEND_FACTORS = .(
		.VK_BLEND_FACTOR_ZERO,
		.VK_BLEND_FACTOR_ONE,
		.VK_BLEND_FACTOR_SRC_ALPHA,
		.VK_BLEND_FACTOR_DST_ALPHA,
		.VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
		.VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA,
		.VK_BLEND_FACTOR_SRC_COLOR,
		.VK_BLEND_FACTOR_DST_COLOR,
		.VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR,
		.VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR,
		.VK_BLEND_FACTOR_SRC_ALPHA_SATURATE,
		.VK_BLEND_FACTOR_CONSTANT_COLOR,
		.VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR,
		.VK_BLEND_FACTOR_CONSTANT_ALPHA,
		.VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA
		);

	public const VkFilter[?] VK_FILTERS = .(
		(VkFilter)(0), // NONE
		.VK_FILTER_NEAREST, // POINT
		.VK_FILTER_LINEAR, // LINEAR
		(VkFilter)0 // ANISOTROPIC
		);

	public const VkSamplerMipmapMode[?] VK_SAMPLER_MIPMAP_MODES = .(
		(VkSamplerMipmapMode)(0), // NONE
		.VK_SAMPLER_MIPMAP_MODE_NEAREST, // POINT
		.VK_SAMPLER_MIPMAP_MODE_LINEAR, // LINEAR
		.VK_SAMPLER_MIPMAP_MODE_LINEAR // ANISOTROPIC
		);

	public const VkSamplerAddressMode[?] VK_SAMPLER_ADDRESS_MODES = .(
		.VK_SAMPLER_ADDRESS_MODE_REPEAT, // WRAP
		.VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT, // MIRROR
		.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE, // CLAMP
		.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER // BORDER
		);

	public const VkPipelineBindPoint[?] VK_PIPELINE_BIND_POINTS = .(
		.VK_PIPELINE_BIND_POINT_GRAPHICS,
		.VK_PIPELINE_BIND_POINT_COMPUTE,
		.VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR
		);

	public const VkResolveModeFlags[?] VK_RESOLVE_MODES = .(
		.VK_RESOLVE_MODE_NONE,
		.VK_RESOLVE_MODE_SAMPLE_ZERO_BIT,
		.VK_RESOLVE_MODE_AVERAGE_BIT,
		.VK_RESOLVE_MODE_MIN_BIT,
		.VK_RESOLVE_MODE_MAX_BIT
		);

	public const VkImageLayout[?] VK_IMAGE_LAYOUTS = .(
		.VK_IMAGE_LAYOUT_UNDEFINED,
		.VK_IMAGE_LAYOUT_GENERAL,
		.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
		.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
		.VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,
		.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
		.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
		.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
		.VK_IMAGE_LAYOUT_PREINITIALIZED,
		.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
		);

	public const VkStencilFaceFlags[?] VK_STENCIL_FACE_FLAGS = .(
		.VK_STENCIL_FACE_FRONT_BIT,
		.VK_STENCIL_FACE_BACK_BIT,
		.VK_STENCIL_FACE_FRONT_AND_BACK
		);

	public const VkAccessFlags FULL_ACCESS_FLAGS =
		.VK_ACCESS_INDIRECT_COMMAND_READ_BIT |
		.VK_ACCESS_INDEX_READ_BIT |
		.VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT |
		.VK_ACCESS_UNIFORM_READ_BIT |
		.VK_ACCESS_INPUT_ATTACHMENT_READ_BIT |
		.VK_ACCESS_SHADER_READ_BIT |
		.VK_ACCESS_SHADER_WRITE_BIT |
		.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT |
		.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT |
		.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT |
		.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT |
		.VK_ACCESS_TRANSFER_READ_BIT |
		.VK_ACCESS_TRANSFER_WRITE_BIT |
		.VK_ACCESS_HOST_READ_BIT |
		.VK_ACCESS_HOST_WRITE_BIT;

	public static void fullPipelineBarrier(VkCommandBuffer cmdBuff)
	{
#if DEBUG
		VkMemoryBarrier memoryBarrier = .(){ sType = .VK_STRUCTURE_TYPE_MEMORY_BARRIER };
		memoryBarrier.srcAccessMask = FULL_ACCESS_FLAGS;
		memoryBarrier.dstAccessMask = FULL_ACCESS_FLAGS;
		VulkanNative.vkCmdPipelineBarrier(cmdBuff, .VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, .VK_PIPELINE_STAGE_ALL_COMMANDS_BIT,
			0, 1, &memoryBarrier, 0, null, 0, null);
#endif
	}

	public static ThsvsAccessType[?] THSVS_ACCESS_TYPES = .(
		.THSVS_ACCESS_NONE, // NONE
		.THSVS_ACCESS_INDIRECT_BUFFER, // INDIRECT_BUFFER
		.THSVS_ACCESS_INDEX_BUFFER, // INDEX_BUFFER
		.THSVS_ACCESS_VERTEX_BUFFER, // VERTEX_BUFFER
		.THSVS_ACCESS_VERTEX_SHADER_READ_UNIFORM_BUFFER, // VERTEX_SHADER_READ_UNIFORM_BUFFER
		.THSVS_ACCESS_VERTEX_SHADER_READ_SAMPLED_IMAGE_OR_UNIFORM_TEXEL_BUFFER, // VERTEX_SHADER_READ_TEXTURE
		.THSVS_ACCESS_VERTEX_SHADER_READ_OTHER, // VERTEX_SHADER_READ_OTHER
		.THSVS_ACCESS_FRAGMENT_SHADER_READ_UNIFORM_BUFFER, // FRAGMENT_SHADER_READ_UNIFORM_BUFFER
		.THSVS_ACCESS_FRAGMENT_SHADER_READ_SAMPLED_IMAGE_OR_UNIFORM_TEXEL_BUFFER, // FRAGMENT_SHADER_READ_TEXTURE
		.THSVS_ACCESS_FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT, // FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT
		.THSVS_ACCESS_FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT, // FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT
		.THSVS_ACCESS_FRAGMENT_SHADER_READ_OTHER, // FRAGMENT_SHADER_READ_OTHER
		.THSVS_ACCESS_COLOR_ATTACHMENT_READ, // COLOR_ATTACHMENT_READ
		.THSVS_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ, // DEPTH_STENCIL_ATTACHMENT_READ
		.THSVS_ACCESS_COMPUTE_SHADER_READ_UNIFORM_BUFFER, // COMPUTE_SHADER_READ_UNIFORM_BUFFER
		.THSVS_ACCESS_COMPUTE_SHADER_READ_SAMPLED_IMAGE_OR_UNIFORM_TEXEL_BUFFER, // COMPUTE_SHADER_READ_TEXTURE
		.THSVS_ACCESS_COMPUTE_SHADER_READ_OTHER, // COMPUTE_SHADER_READ_OTHER
		.THSVS_ACCESS_TRANSFER_READ, // TRANSFER_READ
		.THSVS_ACCESS_HOST_READ, // HOST_READ
		.THSVS_ACCESS_PRESENT, // PRESENT
		.THSVS_ACCESS_VERTEX_SHADER_WRITE, // VERTEX_SHADER_WRITE
		.THSVS_ACCESS_FRAGMENT_SHADER_WRITE, // FRAGMENT_SHADER_WRITE
		.THSVS_ACCESS_COLOR_ATTACHMENT_WRITE, // COLOR_ATTACHMENT_WRITE
		.THSVS_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE, // DEPTH_STENCIL_ATTACHMENT_WRITE
		.THSVS_ACCESS_COMPUTE_SHADER_WRITE, // COMPUTE_SHADER_WRITE
		.THSVS_ACCESS_TRANSFER_WRITE, // TRANSFER_WRITE
		.THSVS_ACCESS_HOST_PREINITIALIZED, // HOST_PREINITIALIZED
		.THSVS_ACCESS_HOST_WRITE, // HOST_WRITE
		.THSVS_ACCESS_SHADING_RATE_READ_NV // SHADING_RATE
		);

	[Inline] private static T getLowestBit<T>(T mask) //where T : operator T & T
		//where T : operator -T
		where T : var
	{
		return mask & (T)(-mask);
	}

	[Inline] private static T clearLowestBit<T>(T mask) //where T : operator T & T
		//where T : operator -T
		//where T : operator T-int
		where T : var
	{
		return mask & (T)(mask - 1);
	}

	// v must be power of 2
	[Inline] private static uint32 getBitPosition(uint32 v)
	{
		if (v == 0) return 0;
		uint32 c = 32;
		if (v & 0x0000FFFF != 0) c -= 16;
		if (v & 0x00FF00FF != 0) c -= 8;
		if (v & 0x0F0F0F0F != 0) c -= 4;
		if (v & 0x33333333 != 0) c -= 2;
		if (v & 0x55555555 != 0) c -= 1;
		return c;
	}

	// v must be power of 2
	[Inline] private static uint64 getBitPosition(uint64 v)
	{
		if (v == 0) return 0;
		uint64 c = 64;
		if (v & 0x00000000FFFFFFFFL != 0) c -= 32;
		if (v & 0x0000FFFF0000FFFFL != 0) c -= 16;
		if (v & 0x00FF00FF00FF00FFL != 0) c -= 8;
		if (v & 0x0F0F0F0F0F0F0F0FL != 0) c -= 4;
		if (v & 0x3333333333333333L != 0) c -= 2;
		if (v & 0x5555555555555555L != 0) c -= 1;
		return c;
	}

	public static ThsvsAccessType* getAccessType(AccessFlagBit flag)
	{
		return &THSVS_ACCESS_TYPES[getBitPosition(uint32(flag))];
	}

	public static ThsvsImageLayout getAccessLayout(AccessFlags flag)
	{
		if (hasAllFlags(flag, AccessFlagBit.FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT | AccessFlagBit.COLOR_ATTACHMENT_WRITE) ||
			hasAllFlags(flag, AccessFlagBit.FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT | AccessFlagBit.DEPTH_STENCIL_ATTACHMENT_WRITE))
		{
			return .THSVS_IMAGE_LAYOUT_GENERAL;
		}
		return .THSVS_IMAGE_LAYOUT_OPTIMAL;
	}

	public static void getAccessTypes(AccessFlags flag, ref List<ThsvsAccessType> v)
	{
		for (uint32 mask = uint32(flag); mask != 0; mask = clearLowestBit(mask))
		{
			v.Add(THSVS_ACCESS_TYPES[getBitPosition(getLowestBit(mask))]);
		}
	}

	public static uint32 roundUp(uint32 numToRound, uint32 multiple)
	{
		return ((numToRound + multiple - 1) / multiple) * multiple;
	}

	public static bool isLayerSupported(char8* required, List<VkLayerProperties> available)
	{
		for (VkLayerProperties availableLayer in available)
		{
			if (String.Equals(scope String(&availableLayer.layerName), required))
			{
				return true;
			}
		}
		return false;
	}

	public static bool isExtensionSupported(char8* required, List<VkExtensionProperties> available)
	{
		for (VkExtensionProperties availableExtension in available)
		{
			if (String.Equals(scope String(&availableExtension.extensionName), required))
			{
				return true;
			}
		}
		return false;
	}

	public static bool isFormatSupported(VkPhysicalDevice device, VkFormat format)
	{
		VkFormatProperties properties = .();
		VulkanNative.vkGetPhysicalDeviceFormatProperties(device, format, &properties);
		return (properties.optimalTilingFeatures & .VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) != 0;
	}
}