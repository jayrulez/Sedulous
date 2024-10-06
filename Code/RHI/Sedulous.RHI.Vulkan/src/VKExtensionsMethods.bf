using Bulkan;
using Sedulous.RHI;
using Sedulous.RHI.Raytracing;

namespace Sedulous.RHI.Vulkan;

/// <summary>
/// Extension methods used to convert values from RHI to DirectX.
/// </summary>
public static class VKExtensionsMethods
{
	/// <summary>
	/// Converts to Vulkan sampler address mode.
	/// </summary>
	/// <param name="addressMode">The address mode to convert.</param>
	/// <returns>The native address mode.</returns>
	public static VkSamplerAddressMode ToVulkan(this TextureAddressMode addressMode)
	{
		switch (addressMode)
		{
		case TextureAddressMode.Wrap:
			return VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_REPEAT;
		case TextureAddressMode.Mirror:
			return VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT;
		case TextureAddressMode.Border:
			return VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER;
		case TextureAddressMode.Mirror_One:
			return VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_MIRROR_CLAMP_TO_EDGE;
		case TextureAddressMode.Clamp:
			return VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
		default:
			return VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_REPEAT;
		}
	}

	/// <summary>
	/// Converts to Vulkan compare function.
	/// </summary>
	/// <param name="function">The value to convert.</param>
	/// <returns>The native value.</returns>
	public static VkCompareOp ToVulkan(this ComparisonFunction @function)
	{
		switch (@function)
		{
		case ComparisonFunction.Less:
			return VkCompareOp.VK_COMPARE_OP_LESS;
		case ComparisonFunction.Equal:
			return VkCompareOp.VK_COMPARE_OP_EQUAL;
		case ComparisonFunction.LessEqual:
			return VkCompareOp.VK_COMPARE_OP_LESS_OR_EQUAL;
		case ComparisonFunction.Greater:
			return VkCompareOp.VK_COMPARE_OP_GREATER;
		case ComparisonFunction.NotEqual:
			return VkCompareOp.VK_COMPARE_OP_NOT_EQUAL;
		case ComparisonFunction.GreaterEqual:
			return VkCompareOp.VK_COMPARE_OP_GREATER_OR_EQUAL;
		case ComparisonFunction.Always:
			return VkCompareOp.VK_COMPARE_OP_ALWAYS;
		case ComparisonFunction.Never:
			return VkCompareOp.VK_COMPARE_OP_NEVER;
		default:
			return VkCompareOp.VK_COMPARE_OP_NEVER;
		}
	}

	/// <summary>
	/// Converts to Vulkan stencil operation.
	/// </summary>
	/// <param name="operation">The value to convert.</param>
	/// <returns>The converted native value.</returns>
	public static VkStencilOp ToVulkan(this StencilOperation operation)
	{
		switch (operation)
		{
		case StencilOperation.Keep:
			return VkStencilOp.VK_STENCIL_OP_KEEP;
		case StencilOperation.Zero:
			return VkStencilOp.VK_STENCIL_OP_ZERO;
		case StencilOperation.Replace:
			return VkStencilOp.VK_STENCIL_OP_REPLACE;
		case StencilOperation.IncrementSaturation:
			return VkStencilOp.VK_STENCIL_OP_INCREMENT_AND_CLAMP;
		case StencilOperation.DecrementSaturation:
			return VkStencilOp.VK_STENCIL_OP_DECREMENT_AND_CLAMP;
		case StencilOperation.Invert:
			return VkStencilOp.VK_STENCIL_OP_INVERT;
		case StencilOperation.Increment:
			return VkStencilOp.VK_STENCIL_OP_INCREMENT_AND_WRAP;
		case StencilOperation.Decrement:
			return VkStencilOp.VK_STENCIL_OP_DECREMENT_AND_WRAP;
		default:
			return VkStencilOp.VK_STENCIL_OP_KEEP;
		}
	}

	/// <summary>
	/// Converts to a Vulkan blend operation.
	/// </summary>
	/// <param name="operation">The value to convert.</param>
	/// <returns>The native value.</returns>
	public static VkBlendOp ToVulkan(this BlendOperation operation)
	{
		switch (operation)
		{
		case BlendOperation.Add:
			return VkBlendOp.VK_BLEND_OP_ADD;
		case BlendOperation.Substract:
			return VkBlendOp.VK_BLEND_OP_SUBTRACT;
		case BlendOperation.ReverseSubstract:
			return VkBlendOp.VK_BLEND_OP_REVERSE_SUBTRACT;
		case BlendOperation.Min:
			return VkBlendOp.VK_BLEND_OP_MIN;
		case BlendOperation.Max:
			return VkBlendOp.VK_BLEND_OP_MAX;
		default:
			return VkBlendOp.VK_BLEND_OP_ADD;
		}
	}

	/// <summary>
	/// Converts to Vulkan blend factor.
	/// </summary>
	/// <param name="blend">The value to convert.</param>
	/// <returns>The native value.</returns>
	public static VkBlendFactor ToVulkan(this Blend blend)
	{
		switch (blend)
		{
		case Blend.Zero:
			return VkBlendFactor.VK_BLEND_FACTOR_ZERO;
		case Blend.One:
			return VkBlendFactor.VK_BLEND_FACTOR_ONE;
		case Blend.SourceColor:
			return VkBlendFactor.VK_BLEND_FACTOR_SRC_COLOR;
		case Blend.InverseSourceColor:
			return VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR;
		case Blend.SourceAlpha:
			return VkBlendFactor.VK_BLEND_FACTOR_SRC_ALPHA;
		case Blend.InverseSourceAlpha:
			return VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA;
		case Blend.DestinationAlpha:
			return VkBlendFactor.VK_BLEND_FACTOR_DST_ALPHA;
		case Blend.InverseDestinationAlpha:
			return VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA;
		case Blend.DestinationColor:
			return VkBlendFactor.VK_BLEND_FACTOR_DST_COLOR;
		case Blend.InverseDestinationColor:
			return VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR;
		case Blend.SourceAlphaSaturate:
			return VkBlendFactor.VK_BLEND_FACTOR_SRC_ALPHA_SATURATE;
		case Blend.BlendFactor:
			return VkBlendFactor.VK_BLEND_FACTOR_CONSTANT_COLOR;
		case Blend.InverseBlendFactor:
			return VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR;
		case Blend.SecondarySourceColor:
			return VkBlendFactor.VK_BLEND_FACTOR_SRC1_COLOR;
		case Blend.InverseSecondarySourceColor:
			return VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_SRC1_COLOR;
		case Blend.SecondarySourceAlpha:
			return VkBlendFactor.VK_BLEND_FACTOR_SRC1_ALPHA;
		case Blend.InverseSecondarySourceAlpha:
			return VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_SRC1_ALPHA;
		default:
			return VkBlendFactor.VK_BLEND_FACTOR_ZERO;
		}
	}

	/// <summary>
	/// Converts to Vulkan ColorComponentFlags.
	/// </summary>
	/// <param name="channels">The value to be converted.</param>
	/// <returns>The native value.</returns>
	public static VkColorComponentFlags ToVulkan(this ColorWriteChannels channels)
	{
		switch (channels)
		{
		case ColorWriteChannels.None:
			return VkColorComponentFlags.None;
		case ColorWriteChannels.Red:
			return VkColorComponentFlags.VK_COLOR_COMPONENT_R_BIT;
		case ColorWriteChannels.Green:
			return VkColorComponentFlags.VK_COLOR_COMPONENT_G_BIT;
		case ColorWriteChannels.Blue:
			return VkColorComponentFlags.VK_COLOR_COMPONENT_B_BIT;
		case ColorWriteChannels.Alpha:
			return VkColorComponentFlags.VK_COLOR_COMPONENT_A_BIT;
		case ColorWriteChannels.All:
			return VkColorComponentFlags.VK_COLOR_COMPONENT_R_BIT | VkColorComponentFlags.VK_COLOR_COMPONENT_G_BIT | VkColorComponentFlags.VK_COLOR_COMPONENT_B_BIT | VkColorComponentFlags.VK_COLOR_COMPONENT_A_BIT;
		default:
			return VkColorComponentFlags.None;
		}
	}

	/// <summary>
	/// Converts to Vulkan primitive topology.
	/// </summary>
	/// <param name="topology">The value to convert.</param>
	/// <returns>The native value.</returns>
	public static VkPrimitiveTopology ToVulkan(this PrimitiveTopology topology)
	{
		switch (topology)
		{
		case PrimitiveTopology.PointList:
			return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_POINT_LIST;
		case PrimitiveTopology.LineList:
			return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_LIST;
		case PrimitiveTopology.LineStrip:
			return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_STRIP;
		case PrimitiveTopology.TriangleList:
			return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
		case PrimitiveTopology.TriangleStrip:
			return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP;
		case PrimitiveTopology.LineListWithAdjacency:
			return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_LIST_WITH_ADJACENCY;
		case PrimitiveTopology.LineStripWithAdjacency:
			return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_STRIP_WITH_ADJACENCY;
		case PrimitiveTopology.TriangleListWithAdjacency:
			return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST_WITH_ADJACENCY;
		case PrimitiveTopology.TriangleStripWithAdjacency:
			return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP_WITH_ADJACENCY;
		default:
			return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_POINT_LIST;
		}
	}

	/// <summary>
	/// Converts to native Vulkan minFilter, magFilter, and samplerMipmapMode.
	/// </summary>
	/// <param name="filter">The texture filter to convert.</param>
	/// <param name="minFilter">The native minFilter.</param>
	/// <param name="magFilter">The native magFilter.</param>
	/// <param name="mipmapMode">The native mipmapMode.</param>
	public static void ToVulkan(this TextureFilter filter, out VkFilter minFilter, out VkFilter magFilter, out VkSamplerMipmapMode mipmapMode)
	{
		switch (filter)
		{
		case TextureFilter.MinPoint_MagPoint_MipPoint:
			minFilter = VkFilter.VK_FILTER_NEAREST;
			magFilter = VkFilter.VK_FILTER_NEAREST;
			mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST;
			break;
		case TextureFilter.MinPoint_MagPoint_MipLinear:
			minFilter = VkFilter.VK_FILTER_NEAREST;
			magFilter = VkFilter.VK_FILTER_NEAREST;
			mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR;
			break;
		case TextureFilter.MinPoint_MagLinear_MipPoint:
			minFilter = VkFilter.VK_FILTER_NEAREST;
			magFilter = VkFilter.VK_FILTER_LINEAR;
			mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST;
			break;
		case TextureFilter.MinPoint_MagLinear_MipLinear:
			minFilter = VkFilter.VK_FILTER_NEAREST;
			magFilter = VkFilter.VK_FILTER_LINEAR;
			mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR;
			break;
		case TextureFilter.MinLinear_MagPoint_MipPoint:
			minFilter = VkFilter.VK_FILTER_LINEAR;
			magFilter = VkFilter.VK_FILTER_NEAREST;
			mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST;
			break;
		case TextureFilter.MinLinear_MagPoint_MipLinear:
			minFilter = VkFilter.VK_FILTER_LINEAR;
			magFilter = VkFilter.VK_FILTER_NEAREST;
			mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR;
			break;
		case TextureFilter.MinLinear_MagLinear_MipPoint:
			minFilter = VkFilter.VK_FILTER_LINEAR;
			magFilter = VkFilter.VK_FILTER_LINEAR;
			mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST;
			break;
		case TextureFilter.Anisotropic:
			minFilter = VkFilter.VK_FILTER_LINEAR;
			magFilter = VkFilter.VK_FILTER_LINEAR;
			mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR;
			break;
		default:
			minFilter = VkFilter.VK_FILTER_LINEAR;
			magFilter = VkFilter.VK_FILTER_LINEAR;
			mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR;
			break;
		}
	}

	/// <summary>
	/// Converts to native border color.
	/// </summary>
	/// <param name="borderColor">The value to convert.</param>
	/// <returns>The MTLSamplerBorderColor value.</returns>
	public static VkBorderColor ToVulkan(this SamplerBorderColor borderColor)
	{
		switch (borderColor)
		{
		case SamplerBorderColor.TransparentBlack:
			return VkBorderColor.VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK;
		case SamplerBorderColor.OpaqueBlack:
			return VkBorderColor.VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK;
		case SamplerBorderColor.OpaqueWhite:
			return VkBorderColor.VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE;
		default:
			return VkBorderColor.VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK;
		}
	}

	/// <summary>
	/// Converts to a native shader stage.
	/// </summary>
	/// <param name="stage">The stage value to convert.</param>
	/// <returns>The native shader stage.</returns>
	public static VkShaderStageFlags ToVulkan(this ShaderStages stage)
	{
		VkShaderStageFlags result = VkShaderStageFlags.None;
		if ((stage & ShaderStages.Vertex) != 0)
		{
			result |= VkShaderStageFlags.VK_SHADER_STAGE_VERTEX_BIT;
		}
		if ((stage & ShaderStages.Hull) != 0)
		{
			result |= VkShaderStageFlags.VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT;
		}
		if ((stage & ShaderStages.Domain) != 0)
		{
			result |= VkShaderStageFlags.VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT;
		}
		if ((stage & ShaderStages.Geometry) != 0)
		{
			result |= VkShaderStageFlags.VK_SHADER_STAGE_GEOMETRY_BIT;
		}
		if ((stage & ShaderStages.Pixel) != 0)
		{
			result |= VkShaderStageFlags.VK_SHADER_STAGE_FRAGMENT_BIT;
		}
		if ((stage & ShaderStages.Compute) != 0)
		{
			result |= VkShaderStageFlags.VK_SHADER_STAGE_COMPUTE_BIT;
		}
		if ((stage & ShaderStages.RayGeneration) != 0)
		{
			result |= VkShaderStageFlags.VK_SHADER_STAGE_RAYGEN_BIT_KHR;
		}
		if ((stage & ShaderStages.Miss) != 0)
		{
			result |= VkShaderStageFlags.VK_SHADER_STAGE_MISS_BIT_KHR;
		}
		if ((stage & ShaderStages.ClosestHit) != 0)
		{
			result |= VkShaderStageFlags.VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR;
		}
		if ((stage & ShaderStages.AnyHit) != 0)
		{
			result |= VkShaderStageFlags.VK_SHADER_STAGE_ANY_HIT_BIT_KHR;
		}
		if ((stage & ShaderStages.Intersection) != 0)
		{
			result |= VkShaderStageFlags.VK_SHADER_STAGE_INTERSECTION_BIT_KHR;
		}
		return result;
	}

	/// <summary>
	/// Converts to native DescriptorType.
	/// </summary>
	/// <param name="type">The resource type value.</param>
	/// <param name="allowDynamicOffset">Allows dynamic offset.</param>
	/// <returns>The native resource type.</returns>
	public static VkDescriptorType ToVulkan(this ResourceType type, bool allowDynamicOffset = false)
	{
		switch (type)
		{
		case ResourceType.ConstantBuffer:
			if (!allowDynamicOffset)
			{
				return VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
			}
			return VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC;
		case ResourceType.Texture:
			return VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE;
		case ResourceType.Sampler:
			return VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER;
		case ResourceType.StructuredBuffer,
			 ResourceType.StructuredBufferReadWrite:
			if (!allowDynamicOffset)
			{
				return VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
			}
			return VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC;
		case ResourceType.TextureReadWrite:
			return VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
		case ResourceType.AccelerationStructure:
			return VkDescriptorType.VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR;
		default:
			return VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER;
		}
	}

	/// <summary>
	/// Converts to native sample count.
	/// </summary>
	/// <param name="sampleCount">The sample count value to convert.</param>
	/// <returns>The native sample count.</returns>
	public static VkSampleCountFlags ToVulkan(this TextureSampleCount sampleCount)
	{
		switch (sampleCount)
		{
		case TextureSampleCount.None:
			return VkSampleCountFlags.VK_SAMPLE_COUNT_1_BIT;
		case TextureSampleCount.Count2:
			return VkSampleCountFlags.VK_SAMPLE_COUNT_2_BIT;
		case TextureSampleCount.Count4:
			return VkSampleCountFlags.VK_SAMPLE_COUNT_4_BIT;
		case TextureSampleCount.Count8:
			return VkSampleCountFlags.VK_SAMPLE_COUNT_8_BIT;
		case TextureSampleCount.Count16:
			return VkSampleCountFlags.VK_SAMPLE_COUNT_16_BIT;
		case TextureSampleCount.Count32:
			return VkSampleCountFlags.VK_SAMPLE_COUNT_32_BIT;
		default:
			return VkSampleCountFlags.None;
		}
	}

	/// <summary>
	/// Converts to the native CullMode.
	/// </summary>
	/// <param name="cullMode">The value to convert.</param>
	/// <returns>The native value.</returns>
	public static VkCullModeFlags ToVulkan(this CullMode cullMode)
	{
		switch (cullMode)
		{
		case CullMode.Front:
			return VkCullModeFlags.VK_CULL_MODE_FRONT_BIT;
		case CullMode.Back:
			return VkCullModeFlags.VK_CULL_MODE_BACK_BIT;
		case CullMode.None:
			return VkCullModeFlags.VK_CULL_MODE_NONE;
		default:
			return VkCullModeFlags.VK_CULL_MODE_NONE;
		}
	}

	/// <summary>
	/// Converts to the native PolygonMode.
	/// </summary>
	/// <param name="fillMode">The value to convert.</param>
	/// <returns>The native value.</returns>
	public static VkPolygonMode ToVulkan(this FillMode fillMode)
	{
		switch (fillMode)
		{
		case FillMode.Wireframe:
			return VkPolygonMode.VK_POLYGON_MODE_LINE;
		case FillMode.Solid:
			return VkPolygonMode.VK_POLYGON_MODE_FILL;
		default:
			return VkPolygonMode.VK_POLYGON_MODE_FILL;
		}
	}

	/// <summary>
	/// Converts from index format to Vulkan format.
	/// </summary>
	/// <param name="format">The index format to convert.</param>
	/// <returns>The resulting Vulkan format.</returns>
	public static VkIndexType ToVulkan(this IndexFormat format)
	{
		switch (format)
		{
		case IndexFormat.UInt32:
			return VkIndexType.VK_INDEX_TYPE_UINT32;
		case IndexFormat.UInt16:
			return VkIndexType.VK_INDEX_TYPE_UINT16;
		default:
			return VkIndexType.VK_INDEX_TYPE_NONE_KHR;
		}
	}

	/// <summary>
	/// Converts instance flags to Vulkan instance flags.
	/// </summary>
	/// <param name="flags">The flags to convert.</param>
	/// <returns>The Vulkan flags.</returns>
	public static VkGeometryInstanceFlagsKHR ToVulkan(this AccelerationStructureInstanceFlags flags)
	{
		switch (flags)
		{
		case AccelerationStructureInstanceFlags.TriangleCullDisable:
			return VkGeometryInstanceFlagsKHR.VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR;
		case AccelerationStructureInstanceFlags.ForceOpaque:
			return VkGeometryInstanceFlagsKHR.VK_GEOMETRY_INSTANCE_FORCE_OPAQUE_BIT_KHR;
		case AccelerationStructureInstanceFlags.ForceNonOpaque:
			return VkGeometryInstanceFlagsKHR.VK_GEOMETRY_INSTANCE_FORCE_NO_OPAQUE_BIT_KHR;
		default:
			return VkGeometryInstanceFlagsKHR.VK_GEOMETRY_INSTANCE_TRIANGLE_FRONT_COUNTERCLOCKWISE_BIT_KHR;
		}
	}

	/// <summary>
	/// Converts from AccelerationStructureFlags to Vulkan VkBuildAccelerationStructureFlagsKHR.
	/// </summary>
	/// <param name="flags">The flags to convert.</param>
	/// <returns>The converted flags.</returns>
	public static VkBuildAccelerationStructureFlagsKHR ToVulkan(this AccelerationStructureFlags flags)
	{
		switch (flags)
		{
		case AccelerationStructureFlags.AllowUpdate,
			 AccelerationStructureFlags.PerformUpdate:
			return VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR;
		case AccelerationStructureFlags.AllowCompactation:
			return VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_COMPACTION_BIT_KHR;
		case AccelerationStructureFlags.PreferFastTrace:
			return VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR;
		case AccelerationStructureFlags.PreferFastBuild:
			return VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_BUILD_BIT_KHR;
		case AccelerationStructureFlags.MinimizeMemory:
			return VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_LOW_MEMORY_BIT_KHR;
		default:
			return VkBuildAccelerationStructureFlagsKHR.None;
		}
	}

	/// <summary>
	/// Converts to a native pixel format.
	/// </summary>
	/// <param name="format">The format to convert.</param>
	/// <param name="depthFormat">Indicates whether it is a depth texture.</param>
	/// <returns>The native Vulkan format.</returns>
	public static VkFormat ToVulkan(this PixelFormat format, bool depthFormat)
	{
		switch (format)
		{
		case PixelFormat.R8_UNorm:
			return VkFormat.VK_FORMAT_R8_UNORM;
		case PixelFormat.R8_UInt:
			return VkFormat.VK_FORMAT_R8_UINT;
		case PixelFormat.R8_SNorm:
			return VkFormat.VK_FORMAT_R8_SNORM;
		case PixelFormat.R8_SInt:
			return VkFormat.VK_FORMAT_R8_SINT;
		case PixelFormat.R16_Float:
			return VkFormat.VK_FORMAT_R16_SFLOAT;
		case PixelFormat.D16_UNorm:
			return VkFormat.VK_FORMAT_D16_UNORM;
		case PixelFormat.R16_UNorm:
			if (!depthFormat)
			{
				return VkFormat.VK_FORMAT_R16_UNORM;
			}
			return VkFormat.VK_FORMAT_D16_UNORM;
		case PixelFormat.R16_UInt:
			return VkFormat.VK_FORMAT_R16_UINT;
		case PixelFormat.R16_SNorm:
			return VkFormat.VK_FORMAT_R16_SNORM;
		case PixelFormat.R16_SInt:
			return VkFormat.VK_FORMAT_R16_SINT;
		case PixelFormat.D32_Float:
			return VkFormat.VK_FORMAT_D32_SFLOAT;
		case PixelFormat.R32_Typeless,
			 PixelFormat.R32_Float:
			if (!depthFormat)
			{
				return VkFormat.VK_FORMAT_R32_SFLOAT;
			}
			return VkFormat.VK_FORMAT_D32_SFLOAT;
		case PixelFormat.R32_UInt:
			return VkFormat.VK_FORMAT_R32_UINT;
		case PixelFormat.R32_SInt:
			return VkFormat.VK_FORMAT_R32_SINT;
		case PixelFormat.R8G8_UNorm:
			return VkFormat.VK_FORMAT_R8G8_UNORM;
		case PixelFormat.R8G8_UInt:
			return VkFormat.VK_FORMAT_R8G8_UINT;
		case PixelFormat.R8G8_SNorm:
			return VkFormat.VK_FORMAT_R8G8_SNORM;
		case PixelFormat.R8G8_SInt:
			return VkFormat.VK_FORMAT_R8G8_SINT;
		case PixelFormat.R16G16_Float:
			return VkFormat.VK_FORMAT_R16G16_SFLOAT;
		case PixelFormat.R16G16_UNorm:
			return VkFormat.VK_FORMAT_R16G16_UNORM;
		case PixelFormat.R16G16_UInt:
			return VkFormat.VK_FORMAT_R16G16_UINT;
		case PixelFormat.R16G16_SNorm:
			return VkFormat.VK_FORMAT_R16G16_SNORM;
		case PixelFormat.R16G16_SInt:
			return VkFormat.VK_FORMAT_R16G16_SINT;
		case PixelFormat.R32G32_Float:
			return VkFormat.VK_FORMAT_R32G32_SFLOAT;
		case PixelFormat.R32G32_UInt:
			return VkFormat.VK_FORMAT_R32G32_UINT;
		case PixelFormat.R32G32_SInt:
			return VkFormat.VK_FORMAT_R32G32_SINT;
		case PixelFormat.R8G8B8A8_UNorm:
			return VkFormat.VK_FORMAT_R8G8B8A8_UNORM;
		case PixelFormat.R8G8B8A8_UNorm_SRgb:
			return VkFormat.VK_FORMAT_R8G8B8A8_SRGB;
		case PixelFormat.R8G8B8A8_UInt:
			return VkFormat.VK_FORMAT_R8G8B8A8_UINT;
		case PixelFormat.R8G8B8A8_SNorm:
			return VkFormat.VK_FORMAT_R8G8B8A8_SNORM;
		case PixelFormat.R8G8B8A8_SInt:
			return VkFormat.VK_FORMAT_R8G8B8A8_SINT;
		case PixelFormat.R16G16B16A16_Float:
			return VkFormat.VK_FORMAT_R16G16B16A16_SFLOAT;
		case PixelFormat.R16G16B16A16_UNorm:
			return VkFormat.VK_FORMAT_R16G16B16A16_UNORM;
		case PixelFormat.R16G16B16A16_UInt:
			return VkFormat.VK_FORMAT_R16G16B16A16_UINT;
		case PixelFormat.R16G16B16A16_SNorm:
			return VkFormat.VK_FORMAT_R16G16B16A16_SNORM;
		case PixelFormat.R16G16B16A16_SInt:
			return VkFormat.VK_FORMAT_R16G16B16A16_SINT;
		case PixelFormat.R32G32B32A32_Float:
			return VkFormat.VK_FORMAT_R32G32B32A32_SFLOAT;
		case PixelFormat.R32G32B32A32_UInt:
			return VkFormat.VK_FORMAT_R32G32B32A32_UINT;
		case PixelFormat.R32G32B32A32_SInt:
			return VkFormat.VK_FORMAT_R32G32B32A32_SINT;
		case PixelFormat.R32G32B32_Float:
			return VkFormat.VK_FORMAT_R32G32B32_SFLOAT;
		case PixelFormat.R32G32B32_UInt:
			return VkFormat.VK_FORMAT_R32G32B32_UINT;
		case PixelFormat.R32G32B32_SInt:
			return VkFormat.VK_FORMAT_R32G32B32_SINT;
		case PixelFormat.D32_Float_S8X24_UInt:
			return VkFormat.VK_FORMAT_X8_D24_UNORM_PACK32;
		case PixelFormat.R10G10B10A2_UNorm:
			return VkFormat.VK_FORMAT_A2B10G10R10_UNORM_PACK32;
		case PixelFormat.R10G10B10A2_UInt:
			return VkFormat.VK_FORMAT_A2B10G10R10_UINT_PACK32;
		case PixelFormat.R11G11B10_Float:
			return VkFormat.VK_FORMAT_B10G11R11_UFLOAT_PACK32;
		case PixelFormat.D24_UNorm_S8_UInt:
			return VkFormat.VK_FORMAT_D24_UNORM_S8_UINT;
		case PixelFormat.BC1_UNorm:
			return VkFormat.VK_FORMAT_BC1_RGBA_UNORM_BLOCK;
		case PixelFormat.BC1_UNorm_SRgb:
			return VkFormat.VK_FORMAT_BC1_RGBA_SRGB_BLOCK;
		case PixelFormat.BC2_UNorm:
			return VkFormat.VK_FORMAT_BC2_UNORM_BLOCK;
		case PixelFormat.BC2_UNorm_SRgb:
			return VkFormat.VK_FORMAT_BC2_SRGB_BLOCK;
		case PixelFormat.BC3_UNorm:
			return VkFormat.VK_FORMAT_BC3_UNORM_BLOCK;
		case PixelFormat.BC3_UNorm_SRgb:
			return VkFormat.VK_FORMAT_BC3_SRGB_BLOCK;
		case PixelFormat.BC4_UNorm:
			return VkFormat.VK_FORMAT_BC4_UNORM_BLOCK;
		case PixelFormat.BC4_SNorm:
			return VkFormat.VK_FORMAT_BC4_SNORM_BLOCK;
		case PixelFormat.BC5_UNorm:
			return VkFormat.VK_FORMAT_BC5_UNORM_BLOCK;
		case PixelFormat.BC5_SNorm:
			return VkFormat.VK_FORMAT_BC5_SNORM_BLOCK;
		case PixelFormat.BC6H_Uf16:
			return VkFormat.VK_FORMAT_BC6H_UFLOAT_BLOCK;
		case PixelFormat.BC6H_Sf16:
			return VkFormat.VK_FORMAT_BC6H_SFLOAT_BLOCK;
		case PixelFormat.BC7_UNorm:
			return VkFormat.VK_FORMAT_BC7_UNORM_BLOCK;
		case PixelFormat.BC7_UNorm_SRgb:
			return VkFormat.VK_FORMAT_BC7_SRGB_BLOCK;
		case PixelFormat.B5G6R5_UNorm:
			return VkFormat.VK_FORMAT_B5G6R5_UNORM_PACK16;
		case PixelFormat.B5G5R5A1_UNorm:
			return VkFormat.VK_FORMAT_B5G5R5A1_UNORM_PACK16;
		case PixelFormat.B8G8R8A8_UNorm:
			return VkFormat.VK_FORMAT_B8G8R8A8_UNORM;
		case PixelFormat.B8G8R8A8_UNorm_SRgb:
			return VkFormat.VK_FORMAT_B8G8R8A8_SRGB;
		case PixelFormat.R4G4B4A4:
			return VkFormat.VK_FORMAT_R4G4B4A4_UNORM_PACK16;
		case PixelFormat.ETC1_RGB8:
			return VkFormat.VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK;
		case PixelFormat.ETC2_RGBA:
			return VkFormat.VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK;
		case PixelFormat.ETC2_RGBA_SRGB:
			return VkFormat.VK_FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK;
		case PixelFormat.R24G8_Typeless:
			return VkFormat.VK_FORMAT_D24_UNORM_S8_UINT;
		case PixelFormat.R32_Float_X8X24_Typeless:
			return VkFormat.VK_FORMAT_D32_SFLOAT_S8_UINT;
		case PixelFormat.Unknown:
			return VkFormat.VK_FORMAT_UNDEFINED;
		default:
			return VkFormat.VK_FORMAT_UNDEFINED;
		}
	}

	/// <summary>
	/// Converts to the RHI pixel format.
	/// </summary>
	/// <param name="format">The format to be converted.</param>
	/// <returns>The RHI format.</returns>
	public static PixelFormat FromVulkan(this VkFormat format)
	{
		switch (format)
		{
		case VkFormat.VK_FORMAT_R8_UNORM:
			return PixelFormat.R8_UNorm;
		case VkFormat.VK_FORMAT_R8_UINT:
			return PixelFormat.R8_UInt;
		case VkFormat.VK_FORMAT_R8_SNORM:
			return PixelFormat.R8_SNorm;
		case VkFormat.VK_FORMAT_R8_SINT:
			return PixelFormat.R8_SInt;
		case VkFormat.VK_FORMAT_R16_SFLOAT:
			return PixelFormat.R16_Float;
		case VkFormat.VK_FORMAT_D16_UNORM:
			return PixelFormat.D16_UNorm;
		case VkFormat.VK_FORMAT_R16_UNORM:
			return PixelFormat.R16_UNorm;
		case VkFormat.VK_FORMAT_R16_UINT:
			return PixelFormat.R16_UInt;
		case VkFormat.VK_FORMAT_R16_SNORM:
			return PixelFormat.R16_SNorm;
		case VkFormat.VK_FORMAT_R16_SINT:
			return PixelFormat.R16_SInt;
		case VkFormat.VK_FORMAT_D32_SFLOAT:
			return PixelFormat.D32_Float;
		case VkFormat.VK_FORMAT_R32_SFLOAT:
			return PixelFormat.R32_Float;
		case VkFormat.VK_FORMAT_R32_UINT:
			return PixelFormat.R32_UInt;
		case VkFormat.VK_FORMAT_R32_SINT:
			return PixelFormat.R32_SInt;
		case VkFormat.VK_FORMAT_R8G8_UNORM:
			return PixelFormat.R8G8_UNorm;
		case VkFormat.VK_FORMAT_R8G8_UINT:
			return PixelFormat.R8G8_UInt;
		case VkFormat.VK_FORMAT_R8G8_SNORM:
			return PixelFormat.R8G8_SNorm;
		case VkFormat.VK_FORMAT_R8G8_SINT:
			return PixelFormat.R8G8_SInt;
		case VkFormat.VK_FORMAT_R16G16_SFLOAT:
			return PixelFormat.R16G16_Float;
		case VkFormat.VK_FORMAT_R16G16_UNORM:
			return PixelFormat.R16G16_UNorm;
		case VkFormat.VK_FORMAT_R16G16_UINT:
			return PixelFormat.R16G16_UInt;
		case VkFormat.VK_FORMAT_R16G16_SNORM:
			return PixelFormat.R16G16_SNorm;
		case VkFormat.VK_FORMAT_R16G16_SINT:
			return PixelFormat.R16G16_SInt;
		case VkFormat.VK_FORMAT_R32G32_SFLOAT:
			return PixelFormat.R32G32_Float;
		case VkFormat.VK_FORMAT_R32G32_UINT:
			return PixelFormat.R32G32_UInt;
		case VkFormat.VK_FORMAT_R32G32_SINT:
			return PixelFormat.R32G32_SInt;
		case VkFormat.VK_FORMAT_R8G8B8A8_UNORM:
			return PixelFormat.R8G8B8A8_UNorm;
		case VkFormat.VK_FORMAT_R8G8B8A8_SRGB:
			return PixelFormat.R8G8B8A8_UNorm_SRgb;
		case VkFormat.VK_FORMAT_R8G8B8A8_UINT:
			return PixelFormat.R8G8B8A8_UInt;
		case VkFormat.VK_FORMAT_R8G8B8A8_SNORM:
			return PixelFormat.R8G8B8A8_SNorm;
		case VkFormat.VK_FORMAT_R8G8B8A8_SINT:
			return PixelFormat.R8G8B8A8_SInt;
		case VkFormat.VK_FORMAT_R16G16B16A16_SFLOAT:
			return PixelFormat.R16G16B16A16_Float;
		case VkFormat.VK_FORMAT_R16G16B16A16_UNORM:
			return PixelFormat.R16G16B16A16_UNorm;
		case VkFormat.VK_FORMAT_R16G16B16A16_UINT:
			return PixelFormat.R16G16B16A16_UInt;
		case VkFormat.VK_FORMAT_R16G16B16A16_SNORM:
			return PixelFormat.R16G16B16A16_SNorm;
		case VkFormat.VK_FORMAT_R16G16B16A16_SINT:
			return PixelFormat.R16G16B16A16_SInt;
		case VkFormat.VK_FORMAT_R32G32B32A32_SFLOAT:
			return PixelFormat.R32G32B32A32_Float;
		case VkFormat.VK_FORMAT_R32G32B32A32_UINT:
			return PixelFormat.R32G32B32A32_UInt;
		case VkFormat.VK_FORMAT_R32G32B32A32_SINT:
			return PixelFormat.R32G32B32A32_SInt;
		case VkFormat.VK_FORMAT_R32G32B32_SFLOAT:
			return PixelFormat.R32G32B32_Float;
		case VkFormat.VK_FORMAT_R32G32B32_UINT:
			return PixelFormat.R32G32B32_UInt;
		case VkFormat.VK_FORMAT_R32G32B32_SINT:
			return PixelFormat.R32G32B32_SInt;
		case VkFormat.VK_FORMAT_X8_D24_UNORM_PACK32:
			return PixelFormat.D32_Float_S8X24_UInt;
		case VkFormat.VK_FORMAT_A2B10G10R10_UNORM_PACK32:
			return PixelFormat.R10G10B10A2_UNorm;
		case VkFormat.VK_FORMAT_A2B10G10R10_UINT_PACK32:
			return PixelFormat.R10G10B10A2_UInt;
		case VkFormat.VK_FORMAT_B10G11R11_UFLOAT_PACK32:
			return PixelFormat.R11G11B10_Float;
		case VkFormat.VK_FORMAT_D24_UNORM_S8_UINT:
			return PixelFormat.D24_UNorm_S8_UInt;
		case VkFormat.VK_FORMAT_BC1_RGBA_UNORM_BLOCK:
			return PixelFormat.BC1_UNorm;
		case VkFormat.VK_FORMAT_BC1_RGBA_SRGB_BLOCK:
			return PixelFormat.BC1_UNorm_SRgb;
		case VkFormat.VK_FORMAT_BC2_UNORM_BLOCK:
			return PixelFormat.BC2_UNorm;
		case VkFormat.VK_FORMAT_BC2_SRGB_BLOCK:
			return PixelFormat.BC2_UNorm_SRgb;
		case VkFormat.VK_FORMAT_BC3_UNORM_BLOCK:
			return PixelFormat.BC3_UNorm;
		case VkFormat.VK_FORMAT_BC3_SRGB_BLOCK:
			return PixelFormat.BC3_UNorm_SRgb;
		case VkFormat.VK_FORMAT_BC4_UNORM_BLOCK:
			return PixelFormat.BC4_UNorm;
		case VkFormat.VK_FORMAT_BC4_SNORM_BLOCK:
			return PixelFormat.BC4_SNorm;
		case VkFormat.VK_FORMAT_BC5_UNORM_BLOCK:
			return PixelFormat.BC5_UNorm;
		case VkFormat.VK_FORMAT_BC5_SNORM_BLOCK:
			return PixelFormat.BC5_SNorm;
		case VkFormat.VK_FORMAT_BC6H_UFLOAT_BLOCK:
			return PixelFormat.BC6H_Uf16;
		case VkFormat.VK_FORMAT_BC6H_SFLOAT_BLOCK:
			return PixelFormat.BC6H_Sf16;
		case VkFormat.VK_FORMAT_BC7_UNORM_BLOCK:
			return PixelFormat.BC7_UNorm;
		case VkFormat.VK_FORMAT_BC7_SRGB_BLOCK:
			return PixelFormat.BC7_UNorm_SRgb;
		case VkFormat.VK_FORMAT_B5G6R5_UNORM_PACK16:
			return PixelFormat.B5G6R5_UNorm;
		case VkFormat.VK_FORMAT_B5G5R5A1_UNORM_PACK16:
			return PixelFormat.B5G5R5A1_UNorm;
		case VkFormat.VK_FORMAT_B8G8R8A8_UNORM:
			return PixelFormat.B8G8R8A8_UNorm;
		case VkFormat.VK_FORMAT_B8G8R8A8_SRGB:
			return PixelFormat.B8G8R8A8_UNorm_SRgb;
		case VkFormat.VK_FORMAT_R4G4B4A4_UNORM_PACK16:
			return PixelFormat.R4G4B4A4;
		case VkFormat.VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK:
			return PixelFormat.ETC1_RGB8;
		case VkFormat.VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK:
			return PixelFormat.ETC2_RGBA;
		case VkFormat.VK_FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK:
			return PixelFormat.ETC2_RGBA_SRGB;
		case VkFormat.VK_FORMAT_UNDEFINED:
			return PixelFormat.Unknown;
		default:
			return PixelFormat.Unknown;
		}
	}

	/// <summary>
	/// Converts to Vulkan vertex format.
	/// </summary>
	/// <param name="format">The value to convert.</param>
	/// <returns>The native value.</returns>
	public static VkFormat ToVulkan(this ElementFormat format)
	{
		switch (format)
		{
		case ElementFormat.UByte:
			return VkFormat.VK_FORMAT_R8_UINT;
		case ElementFormat.UByte2:
			return VkFormat.VK_FORMAT_R8G8_UINT;
		case ElementFormat.UByte4:
			return VkFormat.VK_FORMAT_R8G8B8A8_UINT;
		case ElementFormat.Byte:
			return VkFormat.VK_FORMAT_R8_SINT;
		case ElementFormat.Byte2:
			return VkFormat.VK_FORMAT_R8G8_SINT;
		case ElementFormat.Byte4:
			return VkFormat.VK_FORMAT_R8G8B8A8_SINT;
		case ElementFormat.UByteNormalized:
			return VkFormat.VK_FORMAT_R8_UNORM;
		case ElementFormat.UByte2Normalized:
			return VkFormat.VK_FORMAT_R8G8_UNORM;
		case ElementFormat.UByte4Normalized:
			return VkFormat.VK_FORMAT_R8G8B8A8_UNORM;
		case ElementFormat.ByteNormalized:
			return VkFormat.VK_FORMAT_R8_SNORM;
		case ElementFormat.Byte2Normalized:
			return VkFormat.VK_FORMAT_R8G8_SNORM;
		case ElementFormat.Byte4Normalized:
			return VkFormat.VK_FORMAT_R8G8B8A8_SNORM;
		case ElementFormat.UShort:
			return VkFormat.VK_FORMAT_R16_UINT;
		case ElementFormat.UShort2:
			return VkFormat.VK_FORMAT_R16G16_UINT;
		case ElementFormat.UShort4:
			return VkFormat.VK_FORMAT_R16G16B16A16_UINT;
		case ElementFormat.Short:
			return VkFormat.VK_FORMAT_R16_SINT;
		case ElementFormat.Short2:
			return VkFormat.VK_FORMAT_R16G16_SINT;
		case ElementFormat.Short4:
			return VkFormat.VK_FORMAT_R16G16B16A16_SINT;
		case ElementFormat.UShortNormalized:
			return VkFormat.VK_FORMAT_R16_UNORM;
		case ElementFormat.UShort2Normalized:
			return VkFormat.VK_FORMAT_R16G16_UNORM;
		case ElementFormat.UShort4Normalized:
			return VkFormat.VK_FORMAT_R16G16B16A16_UNORM;
		case ElementFormat.ShortNormalized:
			return VkFormat.VK_FORMAT_R16_SNORM;
		case ElementFormat.Short2Normalized:
			return VkFormat.VK_FORMAT_R16G16_SNORM;
		case ElementFormat.Short4Normalized:
			return VkFormat.VK_FORMAT_R16G16B16A16_SNORM;
		case ElementFormat.Half:
			return VkFormat.VK_FORMAT_R16_SFLOAT;
		case ElementFormat.Half2:
			return VkFormat.VK_FORMAT_R16G16_SFLOAT;
		case ElementFormat.Half4:
			return VkFormat.VK_FORMAT_R16G16B16A16_SFLOAT;
		case ElementFormat.Float:
			return VkFormat.VK_FORMAT_R32_SFLOAT;
		case ElementFormat.Float2:
			return VkFormat.VK_FORMAT_R32G32_SFLOAT;
		case ElementFormat.Float3:
			return VkFormat.VK_FORMAT_R32G32B32_SFLOAT;
		case ElementFormat.Float4:
			return VkFormat.VK_FORMAT_R32G32B32A32_SFLOAT;
		case ElementFormat.UInt:
			return VkFormat.VK_FORMAT_R32_UINT;
		case ElementFormat.UInt2:
			return VkFormat.VK_FORMAT_R32G32_UINT;
		case ElementFormat.UInt3:
			return VkFormat.VK_FORMAT_R32G32B32_UINT;
		case ElementFormat.UInt4:
			return VkFormat.VK_FORMAT_R32G32B32A32_UINT;
		case ElementFormat.Int:
			return VkFormat.VK_FORMAT_R32_SINT;
		case ElementFormat.Int2:
			return VkFormat.VK_FORMAT_R32G32_SINT;
		case ElementFormat.Int3:
			return VkFormat.VK_FORMAT_R32G32B32_SINT;
		case ElementFormat.Int4:
			return VkFormat.VK_FORMAT_R32G32B32A32_SINT;
		default:
			return VkFormat.VK_FORMAT_UNDEFINED;
		}
	}

	/// <summary>
	/// Gets the address from a native Vulkan buffer.
	/// </summary>
	/// <param name="buffer">Native buffer.</param>
	/// <param name="device">Vulkan device.</param>
	/// <returns>Buffer address.</returns>
	public static uint64 GetBufferAddress(this VkBuffer buffer, VkDevice device)
	{
		VkBufferDeviceAddressInfo vkBufferDeviceAddressInfo = default(VkBufferDeviceAddressInfo);
		vkBufferDeviceAddressInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO;
		vkBufferDeviceAddressInfo.buffer = buffer;
		VkBufferDeviceAddressInfo sAddressInfo = vkBufferDeviceAddressInfo;
		return VulkanNative.vkGetBufferDeviceAddress(device, &sAddressInfo);
	}

	/// <summary>
	/// Gets the address from the native Vulkan acceleration structure.
	/// </summary>
	/// <param name="accelerationStructure">Native acceleration structure.</param>
	/// <param name="device">Vulkan device.</param>
	/// <returns>Acceleration structure address.</returns>
	public static uint64 GetAccelerationStructureAddress(this VkAccelerationStructureKHR accelerationStructure, VkDevice device)
	{
		VkAccelerationStructureDeviceAddressInfoKHR vkAccelerationStructureDeviceAddressInfoKHR = default(VkAccelerationStructureDeviceAddressInfoKHR);
		vkAccelerationStructureDeviceAddressInfoKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR;
		vkAccelerationStructureDeviceAddressInfoKHR.accelerationStructure = accelerationStructure;
		VkAccelerationStructureDeviceAddressInfoKHR deviceAddressInfo = vkAccelerationStructureDeviceAddressInfoKHR;
		return VulkanNative.vkGetAccelerationStructureDeviceAddressKHR(device, &deviceAddressInfo);
	}
}
