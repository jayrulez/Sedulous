using System;
using Bulkan;

namespace Sedulous.GAL.VK
{
    public static class VKFormats
    {
        internal static VkSamplerAddressMode VdToVkSamplerAddressMode(SamplerAddressMode mode)
        {
            switch (mode)
            {
                case SamplerAddressMode.Wrap:
                    return VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_REPEAT;
                case SamplerAddressMode.Mirror:
                    return VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT;
                case SamplerAddressMode.Clamp:
                    return VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
                case SamplerAddressMode.Border:
                    return VkSamplerAddressMode.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER;
                default:
                    Runtime.IllegalValue<SamplerAddressMode>();
            }
        }

        internal static void GetFilterParams(
            SamplerFilter filter,
            out VkFilter minFilter,
            out VkFilter magFilter,
            out VkSamplerMipmapMode mipmapMode)
        {
            switch (filter)
            {
                case SamplerFilter.Anisotropic:
                    minFilter = VkFilter.VK_FILTER_LINEAR;
                    magFilter = VkFilter.VK_FILTER_LINEAR;
                    mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR;
                    break;
                case SamplerFilter.MinPoint_MagPoint_MipPoint:
                    minFilter = VkFilter.VK_FILTER_NEAREST;
                    magFilter = VkFilter.VK_FILTER_NEAREST;
                    mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST;
                    break;
                case SamplerFilter.MinPoint_MagPoint_MipLinear:
                    minFilter = VkFilter.VK_FILTER_NEAREST;
                    magFilter = VkFilter.VK_FILTER_NEAREST;
                    mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR;
                    break;
                case SamplerFilter.MinPoint_MagLinear_MipPoint:
                    minFilter = VkFilter.VK_FILTER_NEAREST;
                    magFilter = VkFilter.VK_FILTER_LINEAR;
                    mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST;
                    break;
                case SamplerFilter.MinPoint_MagLinear_MipLinear:
                    minFilter = VkFilter.VK_FILTER_NEAREST;
                    magFilter = VkFilter.VK_FILTER_LINEAR;
                    mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR;
                    break;
                case SamplerFilter.MinLinear_MagPoint_MipPoint:
                    minFilter = VkFilter.VK_FILTER_LINEAR;
                    magFilter = VkFilter.VK_FILTER_NEAREST;
                    mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST;
                    break;
                case SamplerFilter.MinLinear_MagPoint_MipLinear:
                    minFilter = VkFilter.VK_FILTER_LINEAR;
                    magFilter = VkFilter.VK_FILTER_NEAREST;
                    mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR;
                    break;
                case SamplerFilter.MinLinear_MagLinear_MipPoint:
                    minFilter = VkFilter.VK_FILTER_LINEAR;
                    magFilter = VkFilter.VK_FILTER_LINEAR;
                    mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST;
                    break;
                case SamplerFilter.MinLinear_MagLinear_MipLinear:
                    minFilter = VkFilter.VK_FILTER_LINEAR;
                    magFilter = VkFilter.VK_FILTER_LINEAR;
                    mipmapMode = VkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR;
                    break;
                default:
                    Runtime.IllegalValue<SamplerFilter>();
            }
        }

        internal static VkImageUsageFlags VdToVkTextureUsage(TextureUsage vdUsage)
        {
            VkImageUsageFlags vkUsage = VkImageUsageFlags.None;

            vkUsage = VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_DST_BIT | VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_SRC_BIT;
            bool isDepthStencil = (vdUsage & TextureUsage.DepthStencil) == TextureUsage.DepthStencil;
            if ((vdUsage & TextureUsage.Sampled) == TextureUsage.Sampled)
            {
                vkUsage |= VkImageUsageFlags.VK_IMAGE_USAGE_SAMPLED_BIT;
            }
            if (isDepthStencil)
            {
                vkUsage |= VkImageUsageFlags.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT;
            }
            if ((vdUsage & TextureUsage.RenderTarget) == TextureUsage.RenderTarget)
            {
                vkUsage |= VkImageUsageFlags.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
            }
            if ((vdUsage & TextureUsage.Storage) == TextureUsage.Storage)
            {
                vkUsage |= VkImageUsageFlags.VK_IMAGE_USAGE_STORAGE_BIT;
            }

            return vkUsage;
        }

        internal static VkImageType VdToVkTextureType(TextureType type)
        {
            switch (type)
            {
                case TextureType.Texture1D:
                    return VkImageType.VK_IMAGE_TYPE_1D;
                case TextureType.Texture2D:
                    return VkImageType.VK_IMAGE_TYPE_2D;
                case TextureType.Texture3D:
                    return VkImageType.VK_IMAGE_TYPE_3D;
                default:
                    Runtime.IllegalValue<TextureType>();
            }
        }

        internal static VkDescriptorType VdToVkDescriptorType(ResourceKind kind, ResourceLayoutElementOptions options)
        {
            bool dynamicBinding = (options & ResourceLayoutElementOptions.DynamicBinding) != 0;
            switch (kind)
            {
                case ResourceKind.UniformBuffer:
                    return dynamicBinding ? VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC : VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
                case ResourceKind.StructuredBufferReadWrite:
                case ResourceKind.StructuredBufferReadOnly:
                    return dynamicBinding ? VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC : VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
                case ResourceKind.TextureReadOnly:
                    return VkDescriptorType.eSampledImage;
                case ResourceKind.TextureReadWrite:
                    return VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
                case ResourceKind.Sampler:
                    return VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER;
                default:
                    Runtime.IllegalValue<ResourceKind>();
            }
        }

        internal static VkSampleCountFlags VdToVkSampleCount(TextureSampleCount sampleCount)
        {
            switch (sampleCount)
            {
                case TextureSampleCount.Count1:
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
                    Runtime.IllegalValue<TextureSampleCount>();
            }
        }

        internal static VkStencilOp VdToVkStencilOp(StencilOperation op)
        {
            switch (op)
            {
                case StencilOperation.Keep:
                    return VkStencilOp.VK_STENCIL_OP_KEEP;
                case StencilOperation.Zero:
                    return VkStencilOp.VK_STENCIL_OP_ZERO;
                case StencilOperation.Replace:
                    return VkStencilOp.VK_STENCIL_OP_REPLACE;
                case StencilOperation.IncrementAndClamp:
                    return VkStencilOp.VK_STENCIL_OP_INCREMENT_AND_CLAMP;
                case StencilOperation.DecrementAndClamp:
                    return VkStencilOp.VK_STENCIL_OP_DECREMENT_AND_CLAMP;
                case StencilOperation.Invert:
                    return VkStencilOp.VK_STENCIL_OP_INVERT;
                case StencilOperation.IncrementAndWrap:
                    return VkStencilOp.VK_STENCIL_OP_INCREMENT_AND_WRAP;
                case StencilOperation.DecrementAndWrap:
                    return VkStencilOp.VK_STENCIL_OP_DECREMENT_AND_WRAP;
                default:
                    Runtime.IllegalValue<StencilOperation>();
            }
        }

        internal static VkPolygonMode VdToVkPolygonMode(PolygonFillMode fillMode)
        {
            switch (fillMode)
            {
                case PolygonFillMode.Solid:
                    return VkPolygonMode.VK_POLYGON_MODE_FILL;
                case PolygonFillMode.Wireframe:
                    return VkPolygonMode.VK_POLYGON_MODE_LINE;
                default:
                    Runtime.IllegalValue<PolygonFillMode>();
            }
        }

        internal static VkCullModeFlags VdToVkCullMode(FaceCullMode cullMode)
        {
            switch (cullMode)
            {
                case FaceCullMode.Back:
                    return VkCullModeFlags.VK_CULL_MODE_BACK_BIT;
                case FaceCullMode.Front:
                    return VkCullModeFlags.VK_CULL_MODE_FRONT_BIT;
                case FaceCullMode.None:
                    return VkCullModeFlags.VK_CULL_MODE_NONE;
                default:
                    Runtime.IllegalValue<FaceCullMode>();
            }
        }

        internal static VkBlendOp VdToVkBlendOp(BlendFunction func)
        {
            switch (func)
            {
                case BlendFunction.Add:
                    return VkBlendOp.VK_BLEND_OP_ADD;
                case BlendFunction.Subtract:
                    return VkBlendOp.VK_BLEND_OP_SUBTRACT;
                case BlendFunction.ReverseSubtract:
                    return VkBlendOp.VK_BLEND_OP_REVERSE_SUBTRACT;
                case BlendFunction.Minimum:
                    return VkBlendOp.VK_BLEND_OP_MIN;
                case BlendFunction.Maximum:
                    return VkBlendOp.VK_BLEND_OP_MAX;
                default:
                    Runtime.IllegalValue<BlendFunction>();
            }
        }

        internal static VkColorComponentFlags VdToVkColorWriteMask(ColorWriteMask mask)
        {
            VkColorComponentFlags flags = VkColorComponentFlags.None;

            if ((mask & ColorWriteMask.Red) == ColorWriteMask.Red)
                flags |= VkColorComponentFlags.VK_COLOR_COMPONENT_R_BIT;
            if ((mask & ColorWriteMask.Green) == ColorWriteMask.Green)
                flags |= VkColorComponentFlags.VK_COLOR_COMPONENT_G_BIT;
            if ((mask & ColorWriteMask.Blue) == ColorWriteMask.Blue)
                flags |= VkColorComponentFlags.VK_COLOR_COMPONENT_B_BIT;
            if ((mask & ColorWriteMask.Alpha) == ColorWriteMask.Alpha)
                flags |= VkColorComponentFlags.VK_COLOR_COMPONENT_A_BIT;

            return flags;
        }

        internal static VkPrimitiveTopology VdToVkPrimitiveTopology(PrimitiveTopology topology)
        {
            switch (topology)
            {
                case PrimitiveTopology.TriangleList:
                    return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
                case PrimitiveTopology.TriangleStrip:
                    return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP;
                case PrimitiveTopology.LineList:
                    return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_LIST;
                case PrimitiveTopology.LineStrip:
                    return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_STRIP;
                case PrimitiveTopology.PointList:
                    return VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_POINT_LIST;
                default:
                    Runtime.IllegalValue<PrimitiveTopology>();
            }
        }

        internal static uint32 GetSpecializationConstantSize(ShaderConstantType type)
        {
            switch (type)
            {
                case ShaderConstantType.Bool:
                    return 4;
                case ShaderConstantType.UInt16:
                    return 2;
                case ShaderConstantType.Int16:
                    return 2;
                case ShaderConstantType.UInt32:
                    return 4;
                case ShaderConstantType.Int32:
                    return 4;
                case ShaderConstantType.UInt64:
                    return 8;
                case ShaderConstantType.Int64:
                    return 8;
                case ShaderConstantType.Float:
                    return 4;
                case ShaderConstantType.Double:
                    return 8;
                default:
                    Runtime.IllegalValue<ShaderConstantType>();
            }
        }

        internal static VkBlendFactor VdToVkBlendFactor(BlendFactor factor)
        {
            switch (factor)
            {
                case BlendFactor.Zero:
                    return VkBlendFactor.VK_BLEND_FACTOR_ZERO;
                case BlendFactor.One:
                    return VkBlendFactor.VK_BLEND_FACTOR_ONE;
                case BlendFactor.SourceAlpha:
                    return VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA;
                case BlendFactor.InverseSourceAlpha:
                    return VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA;
                case BlendFactor.DestinationAlpha:
                    return VkBlendFactor.VK_BLEND_FACTOR_DST_ALPHA;
                case BlendFactor.InverseDestinationAlpha:
                    return VkBlendFactor.OneMinusDstAlpha;
                case BlendFactor.SourceColor:
                    return VkBlendFactor.SrcColor;
                case BlendFactor.InverseSourceColor:
                    return VkBlendFactor.OneMinusSrcColor;
                case BlendFactor.DestinationColor:
                    return VkBlendFactor.DstColor;
                case BlendFactor.InverseDestinationColor:
                    return VkBlendFactor.OneMinusDstColor;
                case BlendFactor.BlendFactor:
                    return VkBlendFactor.VK_BLEND_FACTOR_CONSTANT_COLOR;
                case BlendFactor.InverseBlendFactor:
                    return VkBlendFactor.VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR;
                default:
                    Runtime.IllegalValue<BlendFactor>();
            }
        }

        internal static VkFormat VdToVkVertexElementFormat(VertexElementFormat format)
        {
            switch (format)
            {
                case VertexElementFormat.Float1:
                    return VkFormat.R32Sfloat;
                case VertexElementFormat.Float2:
                    return VkFormat.R32g32Sfloat;
                case VertexElementFormat.Float3:
                    return VkFormat.R32g32b32Sfloat;
                case VertexElementFormat.Float4:
                    return VkFormat.R32g32b32a32Sfloat;
                case VertexElementFormat.Byte2_Norm:
                    return VkFormat.R8g8Unorm;
                case VertexElementFormat.Byte2:
                    return VkFormat.R8g8Uint;
                case VertexElementFormat.Byte4_Norm:
                    return VkFormat.R8g8b8a8Unorm;
                case VertexElementFormat.Byte4:
                    return VkFormat.R8g8b8a8Uint;
                case VertexElementFormat.SByte2_Norm:
                    return VkFormat.R8g8Snorm;
                case VertexElementFormat.SByte2:
                    return VkFormat.R8g8Sint;
                case VertexElementFormat.SByte4_Norm:
                    return VkFormat.R8g8b8a8Snorm;
                case VertexElementFormat.SByte4:
                    return VkFormat.R8g8b8a8Sint;
                case VertexElementFormat.UShort2_Norm:
                    return VkFormat.R16g16Unorm;
                case VertexElementFormat.UShort2:
                    return VkFormat.R16g16Uint;
                case VertexElementFormat.UShort4_Norm:
                    return VkFormat.R16g16b16a16Unorm;
                case VertexElementFormat.UShort4:
                    return VkFormat.R16g16b16a16Uint;
                case VertexElementFormat.Short2_Norm:
                    return VkFormat.R16g16Snorm;
                case VertexElementFormat.Short2:
                    return VkFormat.R16g16Sint;
                case VertexElementFormat.Short4_Norm:
                    return VkFormat.R16g16b16a16Snorm;
                case VertexElementFormat.Short4:
                    return VkFormat.R16g16b16a16Sint;
                case VertexElementFormat.UInt1:
                    return VkFormat.R32Uint;
                case VertexElementFormat.UInt2:
                    return VkFormat.R32g32Uint;
                case VertexElementFormat.UInt3:
                    return VkFormat.R32g32b32Uint;
                case VertexElementFormat.UInt4:
                    return VkFormat.R32g32b32a32Uint;
                case VertexElementFormat.Int1:
                    return VkFormat.R32Sint;
                case VertexElementFormat.Int2:
                    return VkFormat.R32g32Sint;
                case VertexElementFormat.Int3:
                    return VkFormat.R32g32b32Sint;
                case VertexElementFormat.Int4:
                    return VkFormat.R32g32b32a32Sint;
                case VertexElementFormat.Half1:
                    return VkFormat.R16Sfloat;
                case VertexElementFormat.Half2:
                    return VkFormat.R16g16Sfloat;
                case VertexElementFormat.Half4:
                    return VkFormat.R16g16b16a16Sfloat;
                default:
                    Runtime.IllegalValue<VertexElementFormat>();
            }
        }

        internal static VkShaderStageFlags VdToVkShaderStages(ShaderStages stage)
        {
            VkShaderStageFlags ret = VkShaderStageFlags.None;

            if ((stage & ShaderStages.Vertex) == ShaderStages.Vertex)
                ret |= VkShaderStageFlags.VK_SHADER_STAGE_VERTEX_BIT;

            if ((stage & ShaderStages.Geometry) == ShaderStages.Geometry)
                ret |= VkShaderStageFlags.VK_SHADER_STAGE_GEOMETRY_BIT;

            if ((stage & ShaderStages.TessellationControl) == ShaderStages.TessellationControl)
                ret |= VkShaderStageFlags.VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT;

            if ((stage & ShaderStages.TessellationEvaluation) == ShaderStages.TessellationEvaluation)
                ret |= VkShaderStageFlags.VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT;

            if ((stage & ShaderStages.Fragment) == ShaderStages.Fragment)
                ret |= VkShaderStageFlags.VK_SHADER_STAGE_FRAGMENT_BIT;

            if ((stage & ShaderStages.Compute) == ShaderStages.Compute)
                ret |= VkShaderStageFlags.VK_SHADER_STAGE_COMPUTE_BIT;

            return ret;
        }

        internal static VkBorderColor VdToVkSamplerBorderColor(SamplerBorderColor borderColor)
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
                    Runtime.IllegalValue<SamplerBorderColor>();
            }
        }

        internal static VkIndexType VdToVkIndexFormat(IndexFormat format)
        {
            switch (format)
            {
                case IndexFormat.UInt16:
                    return VkIndexType.VK_INDEX_TYPE_UINT16;
                case IndexFormat.UInt32:
                    return VkIndexType.VK_INDEX_TYPE_UINT32;
                default:
                    Runtime.IllegalValue<IndexFormat>();
            }
        }

        internal static VkCompareOp VdToVkCompareOp(ComparisonKind comparisonKind)
        {
            switch (comparisonKind)
            {
                case ComparisonKind.Never:
                    return VkCompareOp.VK_COMPARE_OP_NEVER;
                case ComparisonKind.Less:
                    return VkCompareOp.VK_COMPARE_OP_LESS;
                case ComparisonKind.Equal:
                    return VkCompareOp.VK_COMPARE_OP_EQUAL;
                case ComparisonKind.LessEqual:
                    return VkCompareOp.VK_COMPARE_OP_LESS_OR_EQUAL;
                case ComparisonKind.Greater:
                    return VkCompareOp.VK_COMPARE_OP_GREATER;
                case ComparisonKind.NotEqual:
                    return VkCompareOp.VK_COMPARE_OP_NOT_EQUAL;
                case ComparisonKind.GreaterEqual:
                    return VkCompareOp.VK_COMPARE_OP_GREATER_OR_EQUAL;
                case ComparisonKind.Always:
                    return VkCompareOp.VK_COMPARE_OP_ALWAYS;
                default:
                    Runtime.IllegalValue<ComparisonKind>();
            }
        }

        internal static PixelFormat VkToVdPixelFormat(VkFormat vkFormat)
        {
            switch (vkFormat)
            {
                case VkFormat.R8Unorm:
                    return PixelFormat.R8_UNorm;
                case VkFormat.R8Snorm:
                    return PixelFormat.R8_SNorm;
                case VkFormat.R8Uint:
                    return PixelFormat.R8_UInt;
                case VkFormat.R8Sint:
                    return PixelFormat.R8_SInt;

                case VkFormat.R16Unorm:
                    return PixelFormat.R16_UNorm;
                case VkFormat.R16Snorm:
                    return PixelFormat.R16_SNorm;
                case VkFormat.R16Uint:
                    return PixelFormat.R16_UInt;
                case VkFormat.R16Sint:
                    return PixelFormat.R16_SInt;
                case VkFormat.R16Sfloat:
                    return PixelFormat.R16_Float;

                case VkFormat.R32Uint:
                    return PixelFormat.R32_UInt;
                case VkFormat.R32Sint:
                    return PixelFormat.R32_SInt;
                case VkFormat.R32Sfloat,
					 VkFormat.D32Sfloat:
                    return PixelFormat.R32_Float;

                case VkFormat.R8g8Unorm:
                    return PixelFormat.R8_G8_UNorm;
                case VkFormat.R8g8Snorm:
                    return PixelFormat.R8_G8_SNorm;
                case VkFormat.R8g8Uint:
                    return PixelFormat.R8_G8_UInt;
                case VkFormat.R8g8Sint:
                    return PixelFormat.R8_G8_SInt;

                case VkFormat.R16g16Unorm:
                    return PixelFormat.R16_G16_UNorm;
                case VkFormat.R16g16Snorm:
                    return PixelFormat.R16_G16_SNorm;
                case VkFormat.R16g16Uint:
                    return PixelFormat.R16_G16_UInt;
                case VkFormat.R16g16Sint:
                    return PixelFormat.R16_G16_SInt;
                case VkFormat.R16g16Sfloat:
                    return PixelFormat.R16_G16_Float;

                case VkFormat.R32g32Uint:
                    return PixelFormat.R32_G32_UInt;
                case VkFormat.R32g32Sint:
                    return PixelFormat.R32_G32_SInt;
                case VkFormat.R32g32Sfloat:
                    return PixelFormat.R32_G32_Float;

                case VkFormat.R8g8b8a8Unorm:
                    return PixelFormat.R8_G8_B8_A8_UNorm;
                case VkFormat.R8g8b8a8Srgb:
                    return PixelFormat.R8_G8_B8_A8_UNorm_SRgb;
                case VkFormat.B8g8r8a8Unorm:
                    return PixelFormat.B8_G8_R8_A8_UNorm;
                case VkFormat.B8g8r8a8Srgb:
                    return PixelFormat.B8_G8_R8_A8_UNorm_SRgb;
                case VkFormat.R8g8b8a8Snorm:
                    return PixelFormat.R8_G8_B8_A8_SNorm;
                case VkFormat.R8g8b8a8Uint:
                    return PixelFormat.R8_G8_B8_A8_UInt;
                case VkFormat.R8g8b8a8Sint:
                    return PixelFormat.R8_G8_B8_A8_SInt;

                case VkFormat.R16g16b16a16Unorm:
                    return PixelFormat.R16_G16_B16_A16_UNorm;
                case VkFormat.R16g16b16a16Snorm:
                    return PixelFormat.R16_G16_B16_A16_SNorm;
                case VkFormat.R16g16b16a16Uint:
                    return PixelFormat.R16_G16_B16_A16_UInt;
                case VkFormat.R16g16b16a16Sint:
                    return PixelFormat.R16_G16_B16_A16_SInt;
                case VkFormat.R16g16b16a16Sfloat:
                    return PixelFormat.R16_G16_B16_A16_Float;

                case VkFormat.R32g32b32a32Uint:
                    return PixelFormat.R32_G32_B32_A32_UInt;
                case VkFormat.R32g32b32a32Sint:
                    return PixelFormat.R32_G32_B32_A32_SInt;
                case VkFormat.R32g32b32a32Sfloat:
                    return PixelFormat.R32_G32_B32_A32_Float;

                case VkFormat.Bc1RgbUnormBlock:
                    return PixelFormat.BC1_Rgb_UNorm;
                case VkFormat.Bc1RgbSrgbBlock:
                    return PixelFormat.BC1_Rgb_UNorm_SRgb;
                case VkFormat.Bc1RgbaUnormBlock:
                    return PixelFormat.BC1_Rgba_UNorm;
                case VkFormat.Bc1RgbaSrgbBlock:
                    return PixelFormat.BC1_Rgba_UNorm_SRgb;
                case VkFormat.Bc2UnormBlock:
                    return PixelFormat.BC2_UNorm;
                case VkFormat.Bc2SrgbBlock:
                    return PixelFormat.BC2_UNorm_SRgb;
                case VkFormat.Bc3UnormBlock:
                    return PixelFormat.BC3_UNorm;
                case VkFormat.Bc3SrgbBlock:
                    return PixelFormat.BC3_UNorm_SRgb;
                case VkFormat.Bc4UnormBlock:
                    return PixelFormat.BC4_UNorm;
                case VkFormat.Bc4SnormBlock:
                    return PixelFormat.BC4_SNorm;
                case VkFormat.Bc5UnormBlock:
                    return PixelFormat.BC5_UNorm;
                case VkFormat.Bc5SnormBlock:
                    return PixelFormat.BC5_SNorm;
                case VkFormat.Bc7UnormBlock:
                    return PixelFormat.BC7_UNorm;
                case VkFormat.Bc7SrgbBlock:
                    return PixelFormat.BC7_UNorm_SRgb;

                case VkFormat.A2b10g10r10UnormPack32:
                    return PixelFormat.R10_G10_B10_A2_UNorm;
                case VkFormat.A2b10g10r10UintPack32:
                    return PixelFormat.R10_G10_B10_A2_UInt;
                case VkFormat.B10g11r11UfloatPack32:
                    return PixelFormat.R11_G11_B10_Float;

                default:
                    Runtime.IllegalValue<VkFormat>();
            }
        }
    }
}
