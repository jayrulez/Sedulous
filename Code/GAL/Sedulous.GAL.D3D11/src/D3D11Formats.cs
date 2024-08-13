using System;
using System.Diagnostics;
using Win32.Graphics.Direct3D11;
using Win32.Graphics.Dxgi.Common;
using Win32.Graphics.Direct3D;

namespace Sedulous.GAL.D3D11
{
	internal static class D3D11Formats
	{
		internal static DXGI_FORMAT ToDxgiFormat(PixelFormat format, bool depthFormat)
		{
			switch (format)
			{
			case PixelFormat.R8_UNorm:
				return .DXGI_FORMAT_R8_UNORM;
			case PixelFormat.R8_SNorm:
				return .DXGI_FORMAT_R8_SNORM;
			case PixelFormat.R8_UInt:
				return .DXGI_FORMAT_R8_UINT;
			case PixelFormat.R8_SInt:
				return .DXGI_FORMAT_R8_SINT;

			case PixelFormat.R16_UNorm:
				return depthFormat ? .DXGI_FORMAT_R16_TYPELESS : .DXGI_FORMAT_R16_UNORM;
			case PixelFormat.R16_SNorm:
				return .DXGI_FORMAT_R16_SNORM;
			case PixelFormat.R16_UInt:
				return .DXGI_FORMAT_R16_UINT;
			case PixelFormat.R16_SInt:
				return .DXGI_FORMAT_R16_SINT;
			case PixelFormat.R16_Float:
				return .DXGI_FORMAT_R16_FLOAT;

			case PixelFormat.R32_UInt:
				return .DXGI_FORMAT_R32_UINT;
			case PixelFormat.R32_SInt:
				return .DXGI_FORMAT_R32_SINT;
			case PixelFormat.R32_Float:
				return depthFormat ? .DXGI_FORMAT_R32_TYPELESS : .DXGI_FORMAT_R32_FLOAT;

			case PixelFormat.R8_G8_UNorm:
				return .DXGI_FORMAT_R8G8_UNORM;
			case PixelFormat.R8_G8_SNorm:
				return .DXGI_FORMAT_R8G8_SNORM;
			case PixelFormat.R8_G8_UInt:
				return .DXGI_FORMAT_R8G8_UINT;
			case PixelFormat.R8_G8_SInt:
				return .DXGI_FORMAT_R8G8_SINT;

			case PixelFormat.R16_G16_UNorm:
				return .DXGI_FORMAT_R16G16_UNORM;
			case PixelFormat.R16_G16_SNorm:
				return .DXGI_FORMAT_R16G16_SNORM;
			case PixelFormat.R16_G16_UInt:
				return .DXGI_FORMAT_R16G16_UINT;
			case PixelFormat.R16_G16_SInt:
				return .DXGI_FORMAT_R16G16_SINT;
			case PixelFormat.R16_G16_Float:
				return .DXGI_FORMAT_R16G16_FLOAT;

			case PixelFormat.R32_G32_UInt:
				return .DXGI_FORMAT_R32G32_UINT;
			case PixelFormat.R32_G32_SInt:
				return .DXGI_FORMAT_R32G32_SINT;
			case PixelFormat.R32_G32_Float:
				return .DXGI_FORMAT_R32G32_FLOAT;

			case PixelFormat.R8_G8_B8_A8_UNorm:
				return .DXGI_FORMAT_R8G8B8A8_UNORM;
			case PixelFormat.R8_G8_B8_A8_UNorm_SRgb:
				return .DXGI_FORMAT_R8G8B8A8_UNORM_SRGB;
			case PixelFormat.B8_G8_R8_A8_UNorm:
				return .DXGI_FORMAT_B8G8R8A8_UNORM;
			case PixelFormat.B8_G8_R8_A8_UNorm_SRgb:
				return .DXGI_FORMAT_B8G8R8A8_UNORM_SRGB;
			case PixelFormat.R8_G8_B8_A8_SNorm:
				return .DXGI_FORMAT_R8G8B8A8_SNORM;
			case PixelFormat.R8_G8_B8_A8_UInt:
				return .DXGI_FORMAT_R8G8B8A8_UINT;
			case PixelFormat.R8_G8_B8_A8_SInt:
				return .DXGI_FORMAT_R8G8B8A8_SINT;

			case PixelFormat.R16_G16_B16_A16_UNorm:
				return .DXGI_FORMAT_R16G16B16A16_UNORM;
			case PixelFormat.R16_G16_B16_A16_SNorm:
				return .DXGI_FORMAT_R16G16B16A16_SNORM;
			case PixelFormat.R16_G16_B16_A16_UInt:
				return .DXGI_FORMAT_R16G16B16A16_UINT;
			case PixelFormat.R16_G16_B16_A16_SInt:
				return .DXGI_FORMAT_R16G16B16A16_SINT;
			case PixelFormat.R16_G16_B16_A16_Float:
				return .DXGI_FORMAT_R16G16B16A16_FLOAT;

			case PixelFormat.R32_G32_B32_A32_UInt:
				return .DXGI_FORMAT_R32G32B32A32_UINT;
			case PixelFormat.R32_G32_B32_A32_SInt:
				return .DXGI_FORMAT_R32G32B32A32_SINT;
			case PixelFormat.R32_G32_B32_A32_Float:
				return .DXGI_FORMAT_R32G32B32A32_FLOAT;

			case PixelFormat.BC1_Rgb_UNorm,
				PixelFormat.BC1_Rgba_UNorm:
				return .DXGI_FORMAT_BC1_UNORM;
			case PixelFormat.BC1_Rgb_UNorm_SRgb,
				PixelFormat.BC1_Rgba_UNorm_SRgb:
				return .DXGI_FORMAT_BC1_UNORM_SRGB;
			case PixelFormat.BC2_UNorm:
				return .DXGI_FORMAT_BC2_UNORM;
			case PixelFormat.BC2_UNorm_SRgb:
				return .DXGI_FORMAT_BC2_UNORM_SRGB;
			case PixelFormat.BC3_UNorm:
				return .DXGI_FORMAT_BC3_UNORM;
			case PixelFormat.BC3_UNorm_SRgb:
				return .DXGI_FORMAT_BC3_UNORM_SRGB;
			case PixelFormat.BC4_UNorm:
				return .DXGI_FORMAT_BC4_UNORM;
			case PixelFormat.BC4_SNorm:
				return .DXGI_FORMAT_BC4_SNORM;
			case PixelFormat.BC5_UNorm:
				return .DXGI_FORMAT_BC5_UNORM;
			case PixelFormat.BC5_SNorm:
				return .DXGI_FORMAT_BC5_SNORM;
			case PixelFormat.BC7_UNorm:
				return .DXGI_FORMAT_BC7_UNORM;
			case PixelFormat.BC7_UNorm_SRgb:
				return .DXGI_FORMAT_BC7_UNORM_SRGB;

			case PixelFormat.D24_UNorm_S8_UInt:
				Debug.Assert(depthFormat);
				return .DXGI_FORMAT_R24G8_TYPELESS;
			case PixelFormat.D32_Float_S8_UInt:
				Debug.Assert(depthFormat);
				return .DXGI_FORMAT_R32G8X24_TYPELESS;

			case PixelFormat.R10_G10_B10_A2_UNorm:
				return .DXGI_FORMAT_R10G10B10A2_UNORM;
			case PixelFormat.R10_G10_B10_A2_UInt:
				return .DXGI_FORMAT_R10G10B10A2_UINT;
			case PixelFormat.R11_G11_B10_Float:
				return .DXGI_FORMAT_R11G11B10_FLOAT;

			case PixelFormat.ETC2_R8_G8_B8_UNorm,
				PixelFormat.ETC2_R8_G8_B8_A1_UNorm,
				PixelFormat.ETC2_R8_G8_B8_A8_UNorm:
				System.Runtime.GALError("ETC2 formats are not supported on Direct3D 11.");

			default:
				Runtime.IllegalValue<PixelFormat>();
			}
		}

		internal static DXGI_FORMAT GetTypelessFormat(DXGI_FORMAT format)
		{
			switch (format)
			{
			case .DXGI_FORMAT_R32G32B32A32_TYPELESS,
				.DXGI_FORMAT_R32G32B32A32_FLOAT,
				.DXGI_FORMAT_R32G32B32A32_UINT,
				.DXGI_FORMAT_R32G32B32A32_SINT:
				return .DXGI_FORMAT_R32G32B32A32_TYPELESS;
			case .DXGI_FORMAT_R32G32B32_TYPELESS,
				.DXGI_FORMAT_R32G32B32_FLOAT,
				.DXGI_FORMAT_R32G32B32_UINT,
				.DXGI_FORMAT_R32G32B32_SINT:
				return .DXGI_FORMAT_R32G32B32_TYPELESS;
			case .DXGI_FORMAT_R16G16B16A16_TYPELESS,
				.DXGI_FORMAT_R16G16B16A16_FLOAT,
				.DXGI_FORMAT_R16G16B16A16_UNORM,
				.DXGI_FORMAT_R16G16B16A16_UINT,
				.DXGI_FORMAT_R16G16B16A16_SNORM,
				.DXGI_FORMAT_R16G16B16A16_SINT:
				return .DXGI_FORMAT_R16G16B16A16_TYPELESS;
			case .DXGI_FORMAT_R32G32_TYPELESS,
				.DXGI_FORMAT_R32G32_FLOAT,
				.DXGI_FORMAT_R32G32_UINT,
				.DXGI_FORMAT_R32G32_SINT:
				return .DXGI_FORMAT_R32G32_TYPELESS;
			case .DXGI_FORMAT_R10G10B10A2_TYPELESS,
				.DXGI_FORMAT_R10G10B10A2_UNORM,
				.DXGI_FORMAT_R10G10B10A2_UINT:
				return .DXGI_FORMAT_R10G10B10A2_TYPELESS;
			case .DXGI_FORMAT_R8G8B8A8_TYPELESS,
				.DXGI_FORMAT_R8G8B8A8_UNORM,
				.DXGI_FORMAT_R8G8B8A8_UNORM_SRGB,
				.DXGI_FORMAT_R8G8B8A8_UINT,
				.DXGI_FORMAT_R8G8B8A8_SNORM,
				.DXGI_FORMAT_R8G8B8A8_SINT:
				return .DXGI_FORMAT_R8G8B8A8_TYPELESS;
			case .DXGI_FORMAT_R16G16_TYPELESS,
				.DXGI_FORMAT_R16G16_FLOAT,
				.DXGI_FORMAT_R16G16_UNORM,
				.DXGI_FORMAT_R16G16_UINT,
				.DXGI_FORMAT_R16G16_SNORM,
				.DXGI_FORMAT_R16G16_SINT:
				return .DXGI_FORMAT_R16G16_TYPELESS;
			case .DXGI_FORMAT_R32_TYPELESS,
				.DXGI_FORMAT_D32_FLOAT,
				.DXGI_FORMAT_R32_FLOAT,
				.DXGI_FORMAT_R32_UINT,
				.DXGI_FORMAT_R32_SINT:
				return .DXGI_FORMAT_R32_TYPELESS;
			case .DXGI_FORMAT_R24G8_TYPELESS,
				.DXGI_FORMAT_D24_UNORM_S8_UINT,
				.DXGI_FORMAT_R24_UNORM_X8_TYPELESS,
				.DXGI_FORMAT_X24_TYPELESS_G8_UINT:
				return .DXGI_FORMAT_R24G8_TYPELESS;
			case .DXGI_FORMAT_R8G8_TYPELESS,
				.DXGI_FORMAT_R8G8_UNORM,
				.DXGI_FORMAT_R8G8_UINT,
				.DXGI_FORMAT_R8G8_SNORM,
				.DXGI_FORMAT_R8G8_SINT:
				return .DXGI_FORMAT_R8G8_TYPELESS;
			case .DXGI_FORMAT_R16_TYPELESS,
				.DXGI_FORMAT_R16_FLOAT,
				.DXGI_FORMAT_D16_UNORM,
				.DXGI_FORMAT_R16_UNORM,
				.DXGI_FORMAT_R16_UINT,
				.DXGI_FORMAT_R16_SNORM,
				.DXGI_FORMAT_R16_SINT:
				return .DXGI_FORMAT_R16_TYPELESS;
			case .DXGI_FORMAT_R8_TYPELESS,
				.DXGI_FORMAT_R8_UNORM,
				.DXGI_FORMAT_R8_UINT,
				.DXGI_FORMAT_R8_SNORM,
				.DXGI_FORMAT_R8_SINT,
				.DXGI_FORMAT_A8_UNORM:
				return .DXGI_FORMAT_R8_TYPELESS;
			case .DXGI_FORMAT_BC1_TYPELESS,
				.DXGI_FORMAT_BC1_UNORM,
				.DXGI_FORMAT_BC1_UNORM_SRGB:
				return .DXGI_FORMAT_BC1_TYPELESS;
			case .DXGI_FORMAT_BC2_TYPELESS,
				.DXGI_FORMAT_BC2_UNORM,
				.DXGI_FORMAT_BC2_UNORM_SRGB:
				return .DXGI_FORMAT_BC2_TYPELESS;
			case .DXGI_FORMAT_BC3_TYPELESS,
				.DXGI_FORMAT_BC3_UNORM,
				.DXGI_FORMAT_BC3_UNORM_SRGB:
				return .DXGI_FORMAT_BC3_TYPELESS;
			case .DXGI_FORMAT_BC4_TYPELESS,
				.DXGI_FORMAT_BC4_UNORM,
				.DXGI_FORMAT_BC4_SNORM:
				return .DXGI_FORMAT_BC4_TYPELESS;
			case .DXGI_FORMAT_BC5_TYPELESS,
				.DXGI_FORMAT_BC5_UNORM,
				.DXGI_FORMAT_BC5_SNORM:
				return .DXGI_FORMAT_BC5_TYPELESS;
			case .DXGI_FORMAT_B8G8R8A8_TYPELESS,
				.DXGI_FORMAT_B8G8R8A8_UNORM,
				.DXGI_FORMAT_B8G8R8A8_UNORM_SRGB:
				return .DXGI_FORMAT_B8G8R8A8_TYPELESS;
			case .DXGI_FORMAT_BC7_TYPELESS,
				.DXGI_FORMAT_BC7_UNORM,
				.DXGI_FORMAT_BC7_UNORM_SRGB:
				return .DXGI_FORMAT_BC7_TYPELESS;
			default:
				return format;
			}
		}

		internal static D3D11_BIND_FLAG VdToD3D11BindFlags(BufferUsage usage)
		{
			D3D11_BIND_FLAG flags = 0;
			if ((usage & BufferUsage.VertexBuffer) == BufferUsage.VertexBuffer)
			{
				flags |= .D3D11_BIND_VERTEX_BUFFER;
			}
			if ((usage & BufferUsage.IndexBuffer) == BufferUsage.IndexBuffer)
			{
				flags |= .D3D11_BIND_INDEX_BUFFER;
			}
			if ((usage & BufferUsage.UniformBuffer) == BufferUsage.UniformBuffer)
			{
				flags |= .D3D11_BIND_CONSTANT_BUFFER;
			}
			if ((usage & BufferUsage.StructuredBufferReadOnly) == BufferUsage.StructuredBufferReadOnly
				|| (usage & BufferUsage.StructuredBufferReadWrite) == BufferUsage.StructuredBufferReadWrite)
			{
				flags |= .D3D11_BIND_SHADER_RESOURCE;
			}
			if ((usage & BufferUsage.StructuredBufferReadWrite) == BufferUsage.StructuredBufferReadWrite)
			{
				flags |= .D3D11_BIND_UNORDERED_ACCESS;
			}

			return flags;
		}

		internal static TextureUsage GetVdUsage(D3D11_BIND_FLAG bindFlags, D3D11_CPU_ACCESS_FLAG cpuFlags, D3D11_RESOURCE_MISC_FLAG optionFlags)
		{
			TextureUsage usage = 0;
			if ((bindFlags & .D3D11_BIND_RENDER_TARGET) != 0)
			{
				usage |= TextureUsage.RenderTarget;
			}
			if ((bindFlags & .D3D11_BIND_DEPTH_STENCIL) != 0)
			{
				usage |= TextureUsage.DepthStencil;
			}
			if ((bindFlags & .D3D11_BIND_SHADER_RESOURCE) != 0)
			{
				usage |= TextureUsage.Sampled;
			}
			if ((bindFlags & .D3D11_BIND_UNORDERED_ACCESS) != 0)
			{
				usage |= TextureUsage.Storage;
			}

			if ((optionFlags & .D3D11_RESOURCE_MISC_TEXTURECUBE) != 0)
			{
				usage |= TextureUsage.Cubemap;
			}
			if ((optionFlags & .D3D11_RESOURCE_MISC_GENERATE_MIPS) != 0)
			{
				usage |= TextureUsage.GenerateMipmaps;
			}

			return usage;
		}

		internal static bool IsUnsupportedFormat(PixelFormat format)
		{
			return format == PixelFormat.ETC2_R8_G8_B8_UNorm
				|| format == PixelFormat.ETC2_R8_G8_B8_A1_UNorm
				|| format == PixelFormat.ETC2_R8_G8_B8_A8_UNorm;
		}

		internal static DXGI_FORMAT GetViewFormat(DXGI_FORMAT format)
		{
			switch (format)
			{
			case .DXGI_FORMAT_R16_TYPELESS:
				return .DXGI_FORMAT_R16_UNORM;
			case .DXGI_FORMAT_R32_TYPELESS:
				return .DXGI_FORMAT_R32_FLOAT;
			case .DXGI_FORMAT_R32G8X24_TYPELESS:
				return .DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS;
			case .DXGI_FORMAT_R24G8_TYPELESS:
				return .DXGI_FORMAT_R24_UNORM_X8_TYPELESS;
			default:
				return format;
			}
		}

		internal static D3D11_BLEND VdToD3D11Blend(BlendFactor factor)
		{
			switch (factor)
			{
			case BlendFactor.Zero:
				return .D3D11_BLEND_ZERO;
			case BlendFactor.One:
				return .D3D11_BLEND_ONE;
			case BlendFactor.SourceAlpha:
				return .D3D11_BLEND_SRC_ALPHA;
			case BlendFactor.InverseSourceAlpha:
				return .D3D11_BLEND_INV_SRC_ALPHA;
			case BlendFactor.DestinationAlpha:
				return .D3D11_BLEND_DEST_ALPHA;
			case BlendFactor.InverseDestinationAlpha:
				return .D3D11_BLEND_INV_DEST_ALPHA;
			case BlendFactor.SourceColor:
				return .D3D11_BLEND_SRC_COLOR;
			case BlendFactor.InverseSourceColor:
				return .D3D11_BLEND_INV_SRC_COLOR;
			case BlendFactor.DestinationColor:
				return .D3D11_BLEND_DEST_COLOR;
			case BlendFactor.InverseDestinationColor:
				return .D3D11_BLEND_INV_DEST_COLOR;
			case BlendFactor.BlendFactor:
				return .D3D11_BLEND_BLEND_FACTOR;
			case BlendFactor.InverseBlendFactor:
				return .D3D11_BLEND_INV_BLEND_FACTOR;
			default:
				Runtime.IllegalValue<BlendFactor>();
			}
		}

		internal static DXGI_FORMAT ToDxgiFormat(IndexFormat format)
		{
			switch (format)
			{
			case IndexFormat.UInt16:
				return .DXGI_FORMAT_R16_UINT;
			case IndexFormat.UInt32:
				return .DXGI_FORMAT_R32_UINT;
			default:
				Runtime.IllegalValue<IndexFormat>();
			}
		}

		internal static D3D11_STENCIL_OP VdToD3D11StencilOperation(StencilOperation op)
		{
			switch (op)
			{
			case StencilOperation.Keep:
				return .D3D11_STENCIL_OP_KEEP;
			case StencilOperation.Zero:
				return .D3D11_STENCIL_OP_ZERO;
			case StencilOperation.Replace:
				return .D3D11_STENCIL_OP_REPLACE;
			case StencilOperation.IncrementAndClamp:
				return .D3D11_STENCIL_OP_INCR_SAT;
			case StencilOperation.DecrementAndClamp:
				return .D3D11_STENCIL_OP_DECR_SAT;
			case StencilOperation.Invert:
				return .D3D11_STENCIL_OP_INVERT;
			case StencilOperation.IncrementAndWrap:
				return .D3D11_STENCIL_OP_INCR;
			case StencilOperation.DecrementAndWrap:
				return .D3D11_STENCIL_OP_DECR;
			default:
				Runtime.IllegalValue<StencilOperation>();
			}
		}

		internal static PixelFormat ToVdFormat(DXGI_FORMAT format)
		{
			switch (format)
			{
			case .DXGI_FORMAT_R8_UNORM:
				return PixelFormat.R8_UNorm;
			case .DXGI_FORMAT_R8_SNORM:
				return PixelFormat.R8_SNorm;
			case .DXGI_FORMAT_R8_UINT:
				return PixelFormat.R8_UInt;
			case .DXGI_FORMAT_R8_SINT:
				return PixelFormat.R8_SInt;

			case .DXGI_FORMAT_R16_UNORM,
				.DXGI_FORMAT_D16_UNORM:
				return PixelFormat.R16_UNorm;
			case .DXGI_FORMAT_R16_SNORM:
				return PixelFormat.R16_SNorm;
			case .DXGI_FORMAT_R16_UINT:
				return PixelFormat.R16_UInt;
			case .DXGI_FORMAT_R16_SINT:
				return PixelFormat.R16_SInt;
			case .DXGI_FORMAT_R16_FLOAT:
				return PixelFormat.R16_Float;

			case .DXGI_FORMAT_R32_UINT:
				return PixelFormat.R32_UInt;
			case .DXGI_FORMAT_R32_SINT:
				return PixelFormat.R32_SInt;
			case .DXGI_FORMAT_R32_FLOAT,
				.DXGI_FORMAT_D32_FLOAT:
				return PixelFormat.R32_Float;

			case .DXGI_FORMAT_R8G8_UNORM:
				return PixelFormat.R8_G8_UNorm;
			case .DXGI_FORMAT_R8G8_SNORM:
				return PixelFormat.R8_G8_SNorm;
			case .DXGI_FORMAT_R8G8_UINT:
				return PixelFormat.R8_G8_UInt;
			case .DXGI_FORMAT_R8G8_SINT:
				return PixelFormat.R8_G8_SInt;

			case .DXGI_FORMAT_R16G16_UNORM:
				return PixelFormat.R16_G16_UNorm;
			case .DXGI_FORMAT_R16G16_SNORM:
				return PixelFormat.R16_G16_SNorm;
			case .DXGI_FORMAT_R16G16_UINT:
				return PixelFormat.R16_G16_UInt;
			case .DXGI_FORMAT_R16G16_SINT:
				return PixelFormat.R16_G16_SInt;
			case .DXGI_FORMAT_R16G16_FLOAT:
				return PixelFormat.R16_G16_Float;

			case .DXGI_FORMAT_R32G32_UINT:
				return PixelFormat.R32_G32_UInt;
			case .DXGI_FORMAT_R32G32_SINT:
				return PixelFormat.R32_G32_SInt;
			case .DXGI_FORMAT_R32G32_FLOAT:
				return PixelFormat.R32_G32_Float;

			case .DXGI_FORMAT_R8G8B8A8_UNORM:
				return PixelFormat.R8_G8_B8_A8_UNorm;
			case .DXGI_FORMAT_R8G8B8A8_UNORM_SRGB:
				return PixelFormat.R8_G8_B8_A8_UNorm_SRgb;

			case .DXGI_FORMAT_B8G8R8A8_UNORM:
				return PixelFormat.B8_G8_R8_A8_UNorm;
			case .DXGI_FORMAT_B8G8R8A8_UNORM_SRGB:
				return PixelFormat.B8_G8_R8_A8_UNorm_SRgb;
			case .DXGI_FORMAT_R8G8B8A8_SNORM:
				return PixelFormat.R8_G8_B8_A8_SNorm;
			case .DXGI_FORMAT_R8G8B8A8_UINT:
				return PixelFormat.R8_G8_B8_A8_UInt;
			case .DXGI_FORMAT_R8G8B8A8_SINT:
				return PixelFormat.R8_G8_B8_A8_SInt;

			case .DXGI_FORMAT_R16G16B16A16_UNORM:
				return PixelFormat.R16_G16_B16_A16_UNorm;
			case .DXGI_FORMAT_R16G16B16A16_SNORM:
				return PixelFormat.R16_G16_B16_A16_SNorm;
			case .DXGI_FORMAT_R16G16B16A16_UINT:
				return PixelFormat.R16_G16_B16_A16_UInt;
			case .DXGI_FORMAT_R16G16B16A16_SINT:
				return PixelFormat.R16_G16_B16_A16_SInt;
			case .DXGI_FORMAT_R16G16B16A16_FLOAT:
				return PixelFormat.R16_G16_B16_A16_Float;

			case .DXGI_FORMAT_R32G32B32A32_UINT:
				return PixelFormat.R32_G32_B32_A32_UInt;
			case .DXGI_FORMAT_R32G32B32A32_SINT:
				return PixelFormat.R32_G32_B32_A32_SInt;
			case .DXGI_FORMAT_R32G32B32A32_FLOAT:
				return PixelFormat.R32_G32_B32_A32_Float;

			case .DXGI_FORMAT_BC1_UNORM,
				.DXGI_FORMAT_BC1_TYPELESS:
				return PixelFormat.BC1_Rgba_UNorm;
			case .DXGI_FORMAT_BC2_UNORM:
				return PixelFormat.BC2_UNorm;
			case .DXGI_FORMAT_BC3_UNORM:
				return PixelFormat.BC3_UNorm;
			case .DXGI_FORMAT_BC4_UNORM:
				return PixelFormat.BC4_UNorm;
			case .DXGI_FORMAT_BC4_SNORM:
				return PixelFormat.BC4_SNorm;
			case .DXGI_FORMAT_BC5_UNORM:
				return PixelFormat.BC5_UNorm;
			case .DXGI_FORMAT_BC5_SNORM:
				return PixelFormat.BC5_SNorm;
			case .DXGI_FORMAT_BC7_UNORM:
				return PixelFormat.BC7_UNorm;

			case .DXGI_FORMAT_D24_UNORM_S8_UINT:
				return PixelFormat.D24_UNorm_S8_UInt;
			case .DXGI_FORMAT_D32_FLOAT_S8X24_UINT:
				return PixelFormat.D32_Float_S8_UInt;

			case .DXGI_FORMAT_R10G10B10A2_UINT:
				return PixelFormat.R10_G10_B10_A2_UInt;
			case .DXGI_FORMAT_R10G10B10A2_UNORM:
				return PixelFormat.R10_G10_B10_A2_UNorm;
			case .DXGI_FORMAT_R11G11B10_FLOAT:
				return PixelFormat.R11_G11_B10_Float;
			default:
				Runtime.IllegalValue<PixelFormat>();
			}
		}

		internal static D3D11_BLEND_OP VdToD3D11BlendOperation(BlendFunction @function)
		{
			switch (@function)
			{
			case BlendFunction.Add:
				return .D3D11_BLEND_OP_ADD;
			case BlendFunction.Subtract:
				return .D3D11_BLEND_OP_SUBTRACT;
			case BlendFunction.ReverseSubtract:
				return .D3D11_BLEND_OP_REV_SUBTRACT;
			case BlendFunction.Minimum:
				return .D3D11_BLEND_OP_MIN;
			case BlendFunction.Maximum:
				return .D3D11_BLEND_OP_MAX;
			default:
				Runtime.IllegalValue<BlendFunction>();
			}
		}

		internal static D3D11_COLOR_WRITE_ENABLE VdToD3D11ColorWriteEnable(ColorWriteMask mask)
		{
			D3D11_COLOR_WRITE_ENABLE enable = 0;

			if ((mask & ColorWriteMask.Red) == ColorWriteMask.Red)
				enable |= .D3D11_COLOR_WRITE_ENABLE_RED;
			if ((mask & ColorWriteMask.Green) == ColorWriteMask.Green)
				enable |= .D3D11_COLOR_WRITE_ENABLE_GREEN;
			if ((mask & ColorWriteMask.Blue) == ColorWriteMask.Blue)
				enable |= .D3D11_COLOR_WRITE_ENABLE_BLUE;
			if ((mask & ColorWriteMask.Alpha) == ColorWriteMask.Alpha)
				enable |= .D3D11_COLOR_WRITE_ENABLE_ALPHA;

			return enable;
		}

		internal static D3D11_FILTER ToD3D11Filter(SamplerFilter filter, bool isComparison)
		{
			switch (filter)
			{
			case SamplerFilter.MinPoint_MagPoint_MipPoint:
				return isComparison ? .D3D11_FILTER_COMPARISON_MIN_MAG_MIP_POINT : .D3D11_FILTER_MIN_MAG_MIP_POINT;
			case SamplerFilter.MinPoint_MagPoint_MipLinear:
				return isComparison ? .D3D11_FILTER_COMPARISON_MIN_MAG_POINT_MIP_LINEAR : .D3D11_FILTER_MIN_MAG_POINT_MIP_LINEAR;
			case SamplerFilter.MinPoint_MagLinear_MipPoint:
				return isComparison ? .D3D11_FILTER_COMPARISON_MIN_POINT_MAG_LINEAR_MIP_POINT : .D3D11_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT;
			case SamplerFilter.MinPoint_MagLinear_MipLinear:
				return isComparison ? .D3D11_FILTER_COMPARISON_MIN_POINT_MAG_MIP_LINEAR : .D3D11_FILTER_MIN_POINT_MAG_MIP_LINEAR;
			case SamplerFilter.MinLinear_MagPoint_MipPoint:
				return isComparison ? .D3D11_FILTER_COMPARISON_MIN_LINEAR_MAG_MIP_POINT : .D3D11_FILTER_MIN_LINEAR_MAG_MIP_POINT;
			case SamplerFilter.MinLinear_MagPoint_MipLinear:
				return isComparison ? .D3D11_FILTER_COMPARISON_MIN_LINEAR_MAG_POINT_MIP_LINEAR : .D3D11_FILTER_MIN_LINEAR_MAG_POINT_MIP_LINEAR;
			case SamplerFilter.MinLinear_MagLinear_MipPoint:
				return isComparison ? .D3D11_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT : .D3D11_FILTER_MIN_MAG_LINEAR_MIP_POINT;
			case SamplerFilter.MinLinear_MagLinear_MipLinear:
				return isComparison ? .D3D11_FILTER_COMPARISON_MIN_MAG_MIP_LINEAR : .D3D11_FILTER_MIN_MAG_MIP_LINEAR;
			case SamplerFilter.Anisotropic:
				return isComparison ? .D3D11_FILTER_COMPARISON_ANISOTROPIC : .D3D11_FILTER_ANISOTROPIC;
			default:
				Runtime.IllegalValue<SamplerFilter>();
			}
		}

		internal static D3D11_MAP VdToD3D11MapMode(bool isDynamic, MapMode mode)
		{
			switch (mode)
			{
			case MapMode.Read:
				return .D3D11_MAP_READ;
			case MapMode.Write:
				return isDynamic ? .D3D11_MAP_WRITE_DISCARD : .D3D11_MAP_WRITE;
			case MapMode.ReadWrite:
				return .D3D11_MAP_READ_WRITE;
			default:
				Runtime.IllegalValue<MapMode>();
			}
		}

		internal static D3D_PRIMITIVE_TOPOLOGY VdToD3D11PrimitiveTopology(PrimitiveTopology primitiveTopology)
		{
			switch (primitiveTopology)
			{
			case PrimitiveTopology.TriangleList:
				return .D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST;
			case PrimitiveTopology.TriangleStrip:
				return .D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP;
			case PrimitiveTopology.LineList:
				return .D3D_PRIMITIVE_TOPOLOGY_LINELIST;
			case PrimitiveTopology.LineStrip:
				return .D3D_PRIMITIVE_TOPOLOGY_LINESTRIP;
			case PrimitiveTopology.PointList:
				return .D3D_PRIMITIVE_TOPOLOGY_POINTLIST;
			default:
				Runtime.IllegalValue<PrimitiveTopology>();
			}
		}

		internal static D3D11_FILL_MODE VdToD3D11FillMode(PolygonFillMode fillMode)
		{
			switch (fillMode)
			{
			case PolygonFillMode.Solid:
				return .D3D11_FILL_SOLID;
			case PolygonFillMode.Wireframe:
				return .D3D11_FILL_WIREFRAME;
			default:
				Runtime.IllegalValue<PolygonFillMode>();
			}
		}

		internal static D3D11_CULL_MODE VdToD3D11CullMode(FaceCullMode cullingMode)
		{
			switch (cullingMode)
			{
			case FaceCullMode.Back:
				return .D3D11_CULL_BACK;
			case FaceCullMode.Front:
				return .D3D11_CULL_FRONT;
			case FaceCullMode.None:
				return .D3D11_CULL_NONE;
			default:
				Runtime.IllegalValue<FaceCullMode>();
			}
		}

		internal static DXGI_FORMAT ToDxgiFormat(VertexElementFormat format)
		{
			switch (format)
			{
			case VertexElementFormat.Float1:
				return .DXGI_FORMAT_R32_FLOAT;
			case VertexElementFormat.Float2:
				return .DXGI_FORMAT_R32G32_FLOAT;
			case VertexElementFormat.Float3:
				return .DXGI_FORMAT_R32G32B32_FLOAT;
			case VertexElementFormat.Float4:
				return .DXGI_FORMAT_R32G32B32A32_FLOAT;
			case VertexElementFormat.Byte2_Norm:
				return .DXGI_FORMAT_R8G8_UNORM;
			case VertexElementFormat.Byte2:
				return .DXGI_FORMAT_R8G8_UINT;
			case VertexElementFormat.Byte4_Norm:
				return .DXGI_FORMAT_R8G8B8A8_UNORM;
			case VertexElementFormat.Byte4:
				return .DXGI_FORMAT_R8G8B8A8_UINT;
			case VertexElementFormat.SByte2_Norm:
				return .DXGI_FORMAT_R8G8_SNORM;
			case VertexElementFormat.SByte2:
				return .DXGI_FORMAT_R8G8_SINT;
			case VertexElementFormat.SByte4_Norm:
				return .DXGI_FORMAT_R8G8B8A8_SNORM;
			case VertexElementFormat.SByte4:
				return .DXGI_FORMAT_R8G8B8A8_SINT;
			case VertexElementFormat.UShort2_Norm:
				return .DXGI_FORMAT_R16G16_UNORM;
			case VertexElementFormat.UShort2:
				return .DXGI_FORMAT_R16G16_UINT;
			case VertexElementFormat.UShort4_Norm:
				return .DXGI_FORMAT_R16G16B16A16_UNORM;
			case VertexElementFormat.UShort4:
				return .DXGI_FORMAT_R16G16B16A16_UINT;
			case VertexElementFormat.Short2_Norm:
				return .DXGI_FORMAT_R16G16_SNORM;
			case VertexElementFormat.Short2:
				return .DXGI_FORMAT_R16G16_SINT;
			case VertexElementFormat.Short4_Norm:
				return .DXGI_FORMAT_R16G16B16A16_SNORM;
			case VertexElementFormat.Short4:
				return .DXGI_FORMAT_R16G16B16A16_SINT;
			case VertexElementFormat.UInt1:
				return .DXGI_FORMAT_R32_UINT;
			case VertexElementFormat.UInt2:
				return .DXGI_FORMAT_R32G32_UINT;
			case VertexElementFormat.UInt3:
				return .DXGI_FORMAT_R32G32B32_UINT;
			case VertexElementFormat.UInt4:
				return .DXGI_FORMAT_R32G32B32A32_UINT;
			case VertexElementFormat.Int1:
				return .DXGI_FORMAT_R32_SINT;
			case VertexElementFormat.Int2:
				return .DXGI_FORMAT_R32G32_SINT;
			case VertexElementFormat.Int3:
				return .DXGI_FORMAT_R32G32B32_SINT;
			case VertexElementFormat.Int4:
				return .DXGI_FORMAT_R32G32B32A32_SINT;
			case VertexElementFormat.Half1:
				return .DXGI_FORMAT_R16_FLOAT;
			case VertexElementFormat.Half2:
				return .DXGI_FORMAT_R16G16_FLOAT;
			case VertexElementFormat.Half4:
				return .DXGI_FORMAT_R16G16B16A16_FLOAT;

			default:
				Runtime.IllegalValue<VertexElementFormat>();
			}
		}

		internal static D3D11_COMPARISON_FUNC VdToD3D11ComparisonFunc(ComparisonKind comparisonKind)
		{
			switch (comparisonKind)
			{
			case ComparisonKind.Never:
				return .D3D11_COMPARISON_NEVER;
			case ComparisonKind.Less:
				return .D3D11_COMPARISON_LESS;
			case ComparisonKind.Equal:
				return .D3D11_COMPARISON_EQUAL;
			case ComparisonKind.LessEqual:
				return .D3D11_COMPARISON_LESS_EQUAL;
			case ComparisonKind.Greater:
				return .D3D11_COMPARISON_GREATER;
			case ComparisonKind.NotEqual:
				return .D3D11_COMPARISON_NOT_EQUAL;
			case ComparisonKind.GreaterEqual:
				return .D3D11_COMPARISON_GREATER_EQUAL;
			case ComparisonKind.Always:
				return .D3D11_COMPARISON_ALWAYS;
			default:
				Runtime.IllegalValue<ComparisonKind>();
			}
		}

		internal static D3D11_TEXTURE_ADDRESS_MODE VdToD3D11AddressMode(SamplerAddressMode mode)
		{
			switch (mode)
			{
			case SamplerAddressMode.Wrap:
				return .D3D11_TEXTURE_ADDRESS_WRAP;
			case SamplerAddressMode.Mirror:
				return .D3D11_TEXTURE_ADDRESS_MIRROR;
			case SamplerAddressMode.Clamp:
				return .D3D11_TEXTURE_ADDRESS_CLAMP;
			case SamplerAddressMode.Border:
				return .D3D11_TEXTURE_ADDRESS_BORDER;
			default:
				Runtime.IllegalValue<SamplerAddressMode>();
			}
		}

		internal static DXGI_FORMAT GetDepthFormat(PixelFormat format)
		{
			switch (format)
			{
			case PixelFormat.R32_Float:
				return .DXGI_FORMAT_D32_FLOAT;
			case PixelFormat.R16_UNorm:
				return .DXGI_FORMAT_D16_UNORM;
			case PixelFormat.D24_UNorm_S8_UInt:
				return .DXGI_FORMAT_D24_UNORM_S8_UINT;
			case PixelFormat.D32_Float_S8_UInt:
				return .DXGI_FORMAT_D32_FLOAT_S8X24_UINT;
			default:
				System.Runtime.GALError(scope $"Invalid depth texture format: {format}");
			}
		}
	}
}
