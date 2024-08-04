using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;
using Win32.Graphics.Direct3D;
using System.Collections;
using Win32;

namespace Sedulous.RHI.DirectX12;

using internal Sedulous.RHI.DirectX12;
using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// The DirectX version of PipelineState.
/// </summary>
public class DX12GraphicsPipelineState : GraphicsPipelineState
{
	internal int32[] VertexStrides;

	internal bool ScissorEnabled;

	private bool disposed;

	private ID3D12PipelineState* nativePipeline;

	private ID3D12RootSignature* rootSignature;

	private int32 stencilReference;

	private D3D12_PRIMITIVE_TOPOLOGY_TYPE primitiveTopologyType;

	private D3D_PRIMITIVE_TOPOLOGY primitiveTopology;

	private String name = new .() ~ delete _;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			name.Set(value);
			SetDebugName(nativePipeline, name);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12GraphicsPipelineState" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The graphics pipeline state description.</param>
	public this(DX12GraphicsContext context, in GraphicsPipelineDescription description)
		: base(description)
	{
		rootSignature = context.DefaultGraphicsSignature;
		if (description.InputLayouts != null && description.Shaders.VertexShader != null)
		{
			int numBuffers = description.InputLayouts.LayoutElements.Count;
			DX12Helpers.EnsureArraySize(ref VertexStrides, numBuffers);
			for (int32 i = 0; i < numBuffers; i++)
			{
				VertexStrides[i] = (int32)description.InputLayouts.LayoutElements[i].Stride;
			}
		}
		primitiveTopologyType = CreateNativePrimitiveTopologyType(description.PrimitiveTopology);
		primitiveTopology = CreateNativePrimitiveTopology(description.PrimitiveTopology);
		stencilReference = description.RenderStates.StencilReference;
		ScissorEnabled = description.RenderStates.RasterizerState.ScissorEnable;
		D3D12_GRAPHICS_PIPELINE_STATE_DESC nativePipelineStateDescription = .()
		{
			InputLayout = ((description.InputLayouts != null) ? CreateNativeInputLayout(description.InputLayouts) : .()),
			pRootSignature = rootSignature,
			RasterizerState = CreateNativeRasterizerState(description.RenderStates.RasterizerState, description.Outputs.SampleCount != TextureSampleCount.None),
			BlendState = CreateNativeBlendState(description.RenderStates.BlendState),
			DepthStencilState = CreateNativeDepthStencilState(description.RenderStates.DepthStencilState),
			SampleMask = (description.RenderStates.SampleMask.HasValue ? ((uint32)description.RenderStates.SampleMask.Value) : uint32.MaxValue),
			PrimitiveTopologyType = primitiveTopologyType
		};
		if (description.Outputs.DepthAttachment.HasValue)
		{
			nativePipelineStateDescription.DSVFormat = description.Outputs.DepthAttachment.Value.Format.ToDepthStencilFormat();
		}
		nativePipelineStateDescription.RTVFormats = .();//scope .[description.Outputs.ColorAttachments.Count];
		for (int32 i = 0; i < description.Outputs.ColorAttachments.Count; i++)
		{
			nativePipelineStateDescription.RTVFormats[i] = description.Outputs.ColorAttachments[i].Format.ToDirectX();
		}
		nativePipelineStateDescription.Flags = .D3D12_PIPELINE_STATE_FLAG_NONE;
		nativePipelineStateDescription.SampleDesc = description.Outputs.SampleCount.ToDirectX();
		nativePipelineStateDescription.StreamOutput = .();
		if (description.Shaders.VertexShader != null)
		{
			nativePipelineStateDescription.VS = (description.Shaders.VertexShader as DX12Shader).NativeShader;
		}
		if (description.Shaders.HullShader != null)
		{
			nativePipelineStateDescription.HS = (description.Shaders.HullShader as DX12Shader).NativeShader;
		}
		if (description.Shaders.DomainShader != null)
		{
			nativePipelineStateDescription.DS = (description.Shaders.DomainShader as DX12Shader).NativeShader;
		}
		if (description.Shaders.GeometryShader != null)
		{
			nativePipelineStateDescription.GS = (description.Shaders.GeometryShader as DX12Shader).NativeShader;
		}
		if (description.Shaders.PixelShader != null)
		{
			nativePipelineStateDescription.PS = (description.Shaders.PixelShader as DX12Shader).NativeShader;
		}
		context.DXDevice.CreateGraphicsPipelineState(&nativePipelineStateDescription, ID3D12PipelineState.IID, (void**)&nativePipeline);
	}

	/// <summary>
	/// Apply only changes compare with the previous pipelineState.
	/// </summary>
	/// <param name="commandList">The commandList where to set this pipeline.</param>
	/// <param name="previousPipeline">The previous pipelineState.</param>
	public void Apply(ID3D12GraphicsCommandList* commandList, DX12GraphicsPipelineState previousPipeline)
	{
		commandList.OMSetStencilRef((uint32)stencilReference);
		commandList.SetPipelineState(nativePipeline);
		commandList.IASetPrimitiveTopology(primitiveTopology);
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	private D3D12_RASTERIZER_DESC CreateNativeRasterizerState(in RasterizerStateDescription description, bool isMultisampleEnabled)
	{
		D3D12_RASTERIZER_DESC nativeDescription = default(D3D12_RASTERIZER_DESC);
		nativeDescription.CullMode = (D3D12_CULL_MODE)description.CullMode;
		nativeDescription.FillMode = (D3D12_FILL_MODE)description.FillMode;
		nativeDescription.FrontCounterClockwise = description.FrontCounterClockwise ? TRUE : FALSE;
		nativeDescription.DepthBias = description.DepthBias;
		nativeDescription.SlopeScaledDepthBias = description.SlopeScaledDepthBias;
		nativeDescription.DepthBiasClamp = description.DepthBiasClamp;
		nativeDescription.DepthClipEnable = description.DepthClipEnable ? TRUE : FALSE;
		nativeDescription.MultisampleEnable = isMultisampleEnabled ? TRUE : FALSE;
		nativeDescription.AntialiasedLineEnable = description.AntialiasedLineEnable ? TRUE : FALSE;
		nativeDescription.ConservativeRaster = .D3D12_CONSERVATIVE_RASTERIZATION_MODE_OFF;
		nativeDescription.ForcedSampleCount = 0;
		return nativeDescription;
	}

	private D3D12_BLEND_DESC CreateNativeBlendState(BlendStateDescription description)
	{
		var description;
		D3D12_BLEND_DESC  nativeDescription = default(D3D12_BLEND_DESC );
		nativeDescription.AlphaToCoverageEnable = description.AlphaToCoverageEnable ? TRUE : FALSE;
		nativeDescription.IndependentBlendEnable = description.IndependentBlendEnable ? TRUE : FALSE;
		BlendStateRenderTargetDescription* renderTargets = &description.RenderTarget0;
		for (int32 i = 0; i < 8; i++)
		{
			nativeDescription.RenderTarget[i].BlendEnable = renderTargets[i].BlendEnable ? TRUE : FALSE;
			nativeDescription.RenderTarget[i].SrcBlend = (D3D12_BLEND)renderTargets[i].SourceBlendColor;
			nativeDescription.RenderTarget[i].DestBlend = (D3D12_BLEND)renderTargets[i].DestinationBlendColor;
			nativeDescription.RenderTarget[i].BlendOp = (D3D12_BLEND_OP)renderTargets[i].BlendOperationColor;
			nativeDescription.RenderTarget[i].SrcBlendAlpha = (D3D12_BLEND)renderTargets[i].SourceBlendAlpha;
			nativeDescription.RenderTarget[i].DestBlendAlpha = (D3D12_BLEND)renderTargets[i].DestinationBlendAlpha;
			nativeDescription.RenderTarget[i].BlendOpAlpha = (D3D12_BLEND_OP)renderTargets[i].BlendOperationAlpha;
			nativeDescription.RenderTarget[i].RenderTargetWriteMask = (uint8)(D3D12_COLOR_WRITE_ENABLE)renderTargets[i].ColorWriteChannels;
		}
		return nativeDescription;
	}

	private D3D12_DEPTH_STENCIL_DESC CreateNativeDepthStencilState(in DepthStencilStateDescription description)
	{
		D3D12_DEPTH_STENCIL_DESC result = default(D3D12_DEPTH_STENCIL_DESC);
		result.DepthEnable = description.DepthEnable ? TRUE : FALSE;
		result.DepthFunc = description.DepthFunction.ToDirectX();
		result.DepthWriteMask = (description.DepthWriteMask ? .D3D12_DEPTH_WRITE_MASK_ALL : .D3D12_DEPTH_WRITE_MASK_ZERO);
		result.StencilEnable = description.StencilEnable ? TRUE : FALSE;
		result.StencilReadMask = description.StencilReadMask;
		result.StencilWriteMask = description.StencilWriteMask;
		result.FrontFace = D3D12_DEPTH_STENCILOP_DESC()
		{
			StencilFailOp = (D3D12_STENCIL_OP)description.FrontFace.StencilFailOperation,
			StencilPassOp = (D3D12_STENCIL_OP)description.FrontFace.StencilPassOperation,
			StencilDepthFailOp = (D3D12_STENCIL_OP)description.FrontFace.StencilDepthFailOperation,
			StencilFunc = description.FrontFace.StencilFunction.ToDirectX()
		};
		result.BackFace = D3D12_DEPTH_STENCILOP_DESC()
		{
			StencilFailOp = (D3D12_STENCIL_OP)description.BackFace.StencilFailOperation,
			StencilPassOp = (D3D12_STENCIL_OP)description.BackFace.StencilPassOperation,
			StencilDepthFailOp = (D3D12_STENCIL_OP)description.BackFace.StencilDepthFailOperation,
			StencilFunc = description.BackFace.StencilFunction.ToDirectX()
		};
		return result;
	}

	private D3D12_INPUT_LAYOUT_DESC CreateNativeInputLayout(InputLayouts vertexLayouts)
	{
		int32 totalCount = 0;
		for (int32 i = 0; i < vertexLayouts.LayoutElements.Count; i++)
		{
			totalCount += (int32)vertexLayouts.LayoutElements[i].Elements.Count;
		}
		int32 index = 0;
		// todo: how do we handle freeing this memory?
		// perhaps make this a mixin and scope alloc in the caller?
		D3D12_INPUT_ELEMENT_DESC[] inputElements = new D3D12_INPUT_ELEMENT_DESC[totalCount];
		for (int32 slot = 0; slot < vertexLayouts.LayoutElements.Count; slot++)
		{
			LayoutDescription layoutDescription = vertexLayouts.LayoutElements[slot];
			List<ElementDescription> elementDescriptions = layoutDescription.Elements;
			int32 stepRate = layoutDescription.StepRate;
			VertexStepFunction stepFunction = layoutDescription.StepFunction;
			for (int32 i = 0; i < elementDescriptions.Count; i++)
			{
				ElementDescription description = elementDescriptions[i];
				inputElements[index] = D3D12_INPUT_ELEMENT_DESC(description.Semantic.ToHLSLSemantic(), (int32)description.SemanticIndex, description.Format.ToDirectX(), description.Offset, slot, stepFunction.ToDirectX(), stepRate);
				index++;
			}
		}
		return D3D12_INPUT_LAYOUT_DESC(){
				pInputElementDescs = inputElements.Ptr,
				NumElements = (.)inputElements.Count
			};
	}

	private D3D_PRIMITIVE_TOPOLOGY  CreateNativePrimitiveTopology(PrimitiveTopology primitiveTopology)
	{
		switch (primitiveTopology)
		{
		case PrimitiveTopology.Undefined:
			return D3D_PRIMITIVE_TOPOLOGY .D3D_PRIMITIVE_TOPOLOGY_UNDEFINED;
		case PrimitiveTopology.PointList:
			return D3D_PRIMITIVE_TOPOLOGY .D3D_PRIMITIVE_TOPOLOGY_POINTLIST;
		case PrimitiveTopology.LineList:
			return D3D_PRIMITIVE_TOPOLOGY .D3D_PRIMITIVE_TOPOLOGY_LINELIST;
		case PrimitiveTopology.LineStrip:
			return D3D_PRIMITIVE_TOPOLOGY .D3D_PRIMITIVE_TOPOLOGY_LINESTRIP;
		case PrimitiveTopology.TriangleList:
			return D3D_PRIMITIVE_TOPOLOGY .D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST;
		case PrimitiveTopology.TriangleStrip:
			return D3D_PRIMITIVE_TOPOLOGY .D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP;
		case PrimitiveTopology.LineListWithAdjacency:
			return D3D_PRIMITIVE_TOPOLOGY .D3D_PRIMITIVE_TOPOLOGY_LINELIST_ADJ;
		case PrimitiveTopology.LineStripWithAdjacency:
			return D3D_PRIMITIVE_TOPOLOGY .D3D_PRIMITIVE_TOPOLOGY_LINESTRIP_ADJ;
		case PrimitiveTopology.TriangleListWithAdjacency:
			return D3D_PRIMITIVE_TOPOLOGY .D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST_ADJ;
		case PrimitiveTopology.TriangleStripWithAdjacency:
			return D3D_PRIMITIVE_TOPOLOGY .D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP_ADJ;
		default:
			if (primitiveTopology >= PrimitiveTopology.Patch_List && primitiveTopology < (PrimitiveTopology)65)
			{
				return (D3D_PRIMITIVE_TOPOLOGY )primitiveTopology;
			}
			return D3D_PRIMITIVE_TOPOLOGY .D3D_PRIMITIVE_TOPOLOGY_UNDEFINED;
		}
	}

	private D3D12_PRIMITIVE_TOPOLOGY_TYPE CreateNativePrimitiveTopologyType(PrimitiveTopology primitiveTopology)
	{
		switch (primitiveTopology)
		{
		case PrimitiveTopology.Undefined:
			return D3D12_PRIMITIVE_TOPOLOGY_TYPE.D3D12_PRIMITIVE_TOPOLOGY_TYPE_UNDEFINED;
		case PrimitiveTopology.PointList:
			return D3D12_PRIMITIVE_TOPOLOGY_TYPE.D3D12_PRIMITIVE_TOPOLOGY_TYPE_POINT;
		case PrimitiveTopology.LineList,
			 PrimitiveTopology.LineStrip,
			 PrimitiveTopology.LineListWithAdjacency,
			 PrimitiveTopology.LineStripWithAdjacency:
			return D3D12_PRIMITIVE_TOPOLOGY_TYPE.D3D12_PRIMITIVE_TOPOLOGY_TYPE_LINE;
		case PrimitiveTopology.TriangleList,
			 PrimitiveTopology.TriangleStrip,
			 PrimitiveTopology.TriangleListWithAdjacency,
			 PrimitiveTopology.TriangleStripWithAdjacency:
			return D3D12_PRIMITIVE_TOPOLOGY_TYPE.D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE;
		default:
			if (primitiveTopology >= PrimitiveTopology.Patch_List && primitiveTopology < (PrimitiveTopology)65)
			{
				return D3D12_PRIMITIVE_TOPOLOGY_TYPE.D3D12_PRIMITIVE_TOPOLOGY_TYPE_PATCH;
			}
			return D3D12_PRIMITIVE_TOPOLOGY_TYPE.D3D12_PRIMITIVE_TOPOLOGY_TYPE_UNDEFINED;
		}
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	private void Dispose(bool disposing)
	{
		if (!disposed)
		{
			if (disposing)
			{
				nativePipeline?.Release();
				rootSignature?.Release();
			}
			disposed = true;
		}
	}
}
