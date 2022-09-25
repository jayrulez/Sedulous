using Win32.Graphics.Direct3D12;
using Win32.Graphics.Dxgi.Common;
using NRI.D3DCommon;
using System.Collections;
using System;
using Win32.Graphics.Direct3D;
using Win32.Foundation;
using Win32;
namespace NRI.D3D12;

class PipelineD3D12 : Pipeline
{
	[Align(alignof(void*))] struct PipelineDescComponent<DescComponent, subobjectType> where subobjectType : const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE
	{
		public D3D12_PIPELINE_STATE_SUBOBJECT_TYPE type = subobjectType;
		public DescComponent desc = default;

		public this()
		{
		}

		public static implicit operator Self(DescComponent desc)
		{
			Self self = default;
			self.desc = desc;
			return self;
		}

		public static implicit operator ref DescComponent(ref Self self) => ref self.desc;
	}

	typealias PipelineRootSignature =  PipelineDescComponent<ID3D12RootSignature*, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_ROOT_SIGNATURE>;
	typealias PipelineInputLayout =  PipelineDescComponent<D3D12_INPUT_LAYOUT_DESC, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_INPUT_LAYOUT>;
	typealias PipelineIndexBufferStripCutValue =  PipelineDescComponent<D3D12_INDEX_BUFFER_STRIP_CUT_VALUE, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_IB_STRIP_CUT_VALUE>;
	typealias PipelinePrimitiveTopology =  PipelineDescComponent<D3D12_PRIMITIVE_TOPOLOGY_TYPE, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_PRIMITIVE_TOPOLOGY>;
	typealias PipelineVertexShader = PipelineDescComponent<D3D12_SHADER_BYTECODE, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_VS>;
	typealias PipelineHullShader = PipelineDescComponent<D3D12_SHADER_BYTECODE, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_HS>;
	typealias PipelineDomainShader = PipelineDescComponent<D3D12_SHADER_BYTECODE, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DS>;
	typealias PipelineGeometryShader =  PipelineDescComponent<D3D12_SHADER_BYTECODE, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_GS>;
	typealias PipelineAmplificationShader =  PipelineDescComponent<D3D12_SHADER_BYTECODE, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_AS>;
	typealias PipelineMeshShader = PipelineDescComponent<D3D12_SHADER_BYTECODE, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_MS>;
	typealias PipelinePixelShader =  PipelineDescComponent<D3D12_SHADER_BYTECODE, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_PS>;
	typealias PipelineNodeMask =  PipelineDescComponent<uint32, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_NODE_MASK>;
	typealias PipelineSampleDesc =  PipelineDescComponent<DXGI_SAMPLE_DESC, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_SAMPLE_DESC>;
	typealias PipelineSampleMask =  PipelineDescComponent<uint32, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_SAMPLE_MASK>;
	typealias PipelineBlend =  PipelineDescComponent<D3D12_BLEND_DESC, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_BLEND>;
	typealias PipelineRasterizer =  PipelineDescComponent<D3D12_RASTERIZER_DESC, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_RASTERIZER>;
	typealias PipelineDepthStencil =  PipelineDescComponent<D3D12_DEPTH_STENCIL_DESC, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DEPTH_STENCIL>;
	typealias PipelineDepthStencilFormat =  PipelineDescComponent<DXGI_FORMAT, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DEPTH_STENCIL_FORMAT>;
	typealias PipelineRenderTargetFormats =  PipelineDescComponent<D3D12_RT_FORMAT_ARRAY, const D3D12_PIPELINE_STATE_SUBOBJECT_TYPE.D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_RENDER_TARGET_FORMATS>;


	struct Stream
	{
		public PipelineRootSignature rootSignature;
		public PipelinePrimitiveTopology primitiveTopology;
		public PipelineInputLayout inputLayout;
		public PipelineIndexBufferStripCutValue indexBufferStripCutValue;
		public PipelineVertexShader vertexShader;
		public PipelineHullShader hullShader;
		public PipelineDomainShader domainShader;
		public PipelineGeometryShader geometryShader;
		public PipelineAmplificationShader amplificationShader;
		public PipelineMeshShader meshShader;
		public PipelinePixelShader pixelShader;
		public PipelineSampleDesc sampleDesc;
		public PipelineSampleMask sampleMask;
		public PipelineRasterizer rasterizer;
		public PipelineBlend blend;
		public PipelineRenderTargetFormats renderTargetFormats;
		public PipelineDepthStencil depthStencil;
		public PipelineDepthStencilFormat depthStencilFormat;
		public PipelineNodeMask nodeMask;
	}


	private Result CreateFromStream(GraphicsPipelineDesc graphicsPipelineDesc)
	{
//#ifdef __ID3D12GraphicsCommandList6_INTERFACE_DEFINED__
		m_PipelineLayout = (PipelineLayoutD3D12)graphicsPipelineDesc.pipelineLayout;

		if (graphicsPipelineDesc.inputAssembly != null)
			m_PrimitiveTopology = GetPrimitiveTopology(graphicsPipelineDesc.inputAssembly.topology, graphicsPipelineDesc.inputAssembly.tessControlPointNum);
		Stream stream = .();

		stream.rootSignature = m_PipelineLayout.[Friend]m_RootSignature.Get();
		stream.nodeMask = NRI_TEMP_NODE_MASK;

		for (uint32 i = 0; i < graphicsPipelineDesc.shaderStageNum; i++)
		{
			readonly ref ShaderDesc shader = ref graphicsPipelineDesc.shaderStages[i];
			if (shader.stage == ShaderStage.VERTEX)
				FillShaderBytecode(ref stream.vertexShader.desc, shader);
			else if (shader.stage == ShaderStage.TESS_CONTROL)
				FillShaderBytecode(ref stream.hullShader.desc, shader);
			else if (shader.stage == ShaderStage.TESS_EVALUATION)
				FillShaderBytecode(ref stream.domainShader.desc, shader);
			else if (shader.stage == ShaderStage.GEOMETRY)
				FillShaderBytecode(ref stream.geometryShader.desc, shader);
			else if (shader.stage == ShaderStage.MESH_CONTROL)
				FillShaderBytecode(ref stream.amplificationShader.desc, shader);
			else if (shader.stage == ShaderStage.MESH_EVALUATION)
				FillShaderBytecode(ref stream.meshShader.desc, shader);
			else if (shader.stage == ShaderStage.FRAGMENT)
				FillShaderBytecode(ref stream.pixelShader.desc, shader);
		}

		D3D12_INPUT_LAYOUT_DESC inputLayout = .();

		if (graphicsPipelineDesc.inputAssembly != null)
		{
			stream.primitiveTopology = GetPrimitiveTopologyType(graphicsPipelineDesc.inputAssembly.topology);
			stream.indexBufferStripCutValue = (D3D12_INDEX_BUFFER_STRIP_CUT_VALUE)graphicsPipelineDesc.inputAssembly.primitiveRestart;

			inputLayout.pInputElementDescs = STACK_ALLOC!<D3D12_INPUT_ELEMENT_DESC>(graphicsPipelineDesc.inputAssembly.attributeNum);
			FillInputLayout(ref inputLayout, graphicsPipelineDesc);
			stream.inputLayout = inputLayout;
		}

		FillRasterizerState(ref stream.rasterizer.desc, graphicsPipelineDesc);
		FillBlendState(ref stream.blend.desc, graphicsPipelineDesc);
		FillSampleDesc(ref stream.sampleDesc.desc, ref stream.sampleMask.desc, graphicsPipelineDesc);

		if (graphicsPipelineDesc.outputMerger != null)
		{
			FillDepthStencilState(ref stream.depthStencil.desc, *graphicsPipelineDesc.outputMerger);
			stream.depthStencilFormat = ConvertNRIFormatToDXGI(graphicsPipelineDesc.outputMerger.depthStencilFormat);

			stream.renderTargetFormats.desc.NumRenderTargets = graphicsPipelineDesc.outputMerger.colorNum;
			for (uint32 i = 0; i < graphicsPipelineDesc.outputMerger.colorNum; i++)
				stream.renderTargetFormats.desc.RTFormats[i] = ConvertNRIFormatToDXGI(graphicsPipelineDesc.outputMerger.color[i].format);
		}

		D3D12_PIPELINE_STATE_STREAM_DESC pipelineStateStreamDesc = .();
		pipelineStateStreamDesc.pPipelineStateSubobjectStream = &stream;
		pipelineStateStreamDesc.SizeInBytes = sizeof(decltype(stream));

		HRESULT hr = ((ID3D12Device2*)m_Device).CreatePipelineState(&pipelineStateStreamDesc, ID3D12PipelineState.IID, (void**)(&m_PipelineState));
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device().CreatePipelineState failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		m_IsGraphicsPipeline = true;
//#endif
		return Result.SUCCESS;
	}

	private void FillInputLayout(ref D3D12_INPUT_LAYOUT_DESC inputLayoutDesc, GraphicsPipelineDesc graphicsPipelineDesc)
	{
		uint8 attributeNum = graphicsPipelineDesc.inputAssembly.attributeNum;
		if (attributeNum < 1)
			return;

		for (uint32 i = 0; i < graphicsPipelineDesc.inputAssembly.streamNum; i++)
			m_IAStreamStride[graphicsPipelineDesc.inputAssembly.streams[i].bindingSlot] = graphicsPipelineDesc.inputAssembly.streams[i].stride;

		inputLayoutDesc.NumElements = attributeNum;
		D3D12_INPUT_ELEMENT_DESC* inputElementsDescs = (D3D12_INPUT_ELEMENT_DESC*)inputLayoutDesc.pInputElementDescs;

		for (uint32 i = 0; i < attributeNum; i++)
		{
			readonly ref VertexAttributeDesc vertexAttributeDesc = ref graphicsPipelineDesc.inputAssembly.attributes[i];
			readonly ref VertexStreamDesc vertexStreamDesc = ref graphicsPipelineDesc.inputAssembly.streams[vertexAttributeDesc.streamIndex];
			bool isPerVertexData = vertexStreamDesc.stepRate == VertexStreamStepRate.PER_VERTEX;

			inputElementsDescs[i].SemanticName = (.)vertexAttributeDesc.d3d.semanticName;
			inputElementsDescs[i].SemanticIndex = vertexAttributeDesc.d3d.semanticIndex;
			inputElementsDescs[i].Format = ConvertNRIFormatToDXGI(vertexAttributeDesc.format);
			inputElementsDescs[i].InputSlot = vertexStreamDesc.bindingSlot;
			inputElementsDescs[i].AlignedByteOffset = vertexAttributeDesc.offset;
			inputElementsDescs[i].InputSlotClass = isPerVertexData ? .D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA : .D3D12_INPUT_CLASSIFICATION_PER_INSTANCE_DATA;
			inputElementsDescs[i].InstanceDataStepRate = isPerVertexData ? 0 : 1;
		}
	}

	private void FillShaderBytecode(ref D3D12_SHADER_BYTECODE shaderBytecode, ShaderDesc shaderDesc)
	{
		shaderBytecode.pShaderBytecode = shaderDesc.bytecode;
		shaderBytecode.BytecodeLength = (uint)shaderDesc.size;
	}

	private void FillRasterizerState(ref D3D12_RASTERIZER_DESC rasterizerDesc, GraphicsPipelineDesc graphicsPipelineDesc)
	{
		if (graphicsPipelineDesc.rasterization == null)
			return;

		readonly ref RasterizationDesc rasterizationDesc = ref *graphicsPipelineDesc.rasterization;

		bool useMultisampling = rasterizationDesc.sampleNum > 1 ? true : false;
		rasterizerDesc.FillMode = GetFillMode(rasterizationDesc.fillMode);
		rasterizerDesc.CullMode = GetCullMode(rasterizationDesc.cullMode);
		rasterizerDesc.FrontCounterClockwise = rasterizationDesc.frontCounterClockwise ? 1 : 0;
		rasterizerDesc.DepthBias = rasterizationDesc.depthBiasConstantFactor;
		rasterizerDesc.DepthBiasClamp = rasterizationDesc.depthBiasClamp;
		rasterizerDesc.SlopeScaledDepthBias = rasterizationDesc.depthBiasSlopeFactor;
		rasterizerDesc.DepthClipEnable = rasterizationDesc.depthClamp ? 1 : 0;
		rasterizerDesc.MultisampleEnable = useMultisampling ? 1 : 0;
		rasterizerDesc.AntialiasedLineEnable = rasterizationDesc.antialiasedLines ? 1 : 0;
		rasterizerDesc.ForcedSampleCount = useMultisampling ? rasterizationDesc.sampleNum : 0;
		rasterizerDesc.ConservativeRaster = rasterizationDesc.conservativeRasterization ? .D3D12_CONSERVATIVE_RASTERIZATION_MODE_ON : .D3D12_CONSERVATIVE_RASTERIZATION_MODE_OFF;
	}

	private void FillDepthStencilState(ref D3D12_DEPTH_STENCIL_DESC depthStencilDesc, OutputMergerDesc outputMergerDesc)
	{
		depthStencilDesc.DepthEnable = outputMergerDesc.depth.compareFunc == CompareFunc.NONE ? FALSE : TRUE;
		depthStencilDesc.DepthWriteMask = outputMergerDesc.depth.write ? .D3D12_DEPTH_WRITE_MASK_ALL : .D3D12_DEPTH_WRITE_MASK_ZERO;
		depthStencilDesc.DepthFunc = GetComparisonFunc(outputMergerDesc.depth.compareFunc);
		depthStencilDesc.StencilEnable = (outputMergerDesc.stencil.front.compareFunc == CompareFunc.NONE && outputMergerDesc.stencil.back.compareFunc == CompareFunc.NONE) ? FALSE : TRUE;
		depthStencilDesc.StencilReadMask = (uint8)outputMergerDesc.stencil.compareMask;
		depthStencilDesc.StencilWriteMask = (uint8)outputMergerDesc.stencil.writeMask;
		depthStencilDesc.FrontFace.StencilFailOp = GetStencilOp(outputMergerDesc.stencil.front.fail);
		depthStencilDesc.FrontFace.StencilDepthFailOp = GetStencilOp(outputMergerDesc.stencil.front.depthFail);
		depthStencilDesc.FrontFace.StencilPassOp = GetStencilOp(outputMergerDesc.stencil.front.pass);
		depthStencilDesc.FrontFace.StencilFunc = GetComparisonFunc(outputMergerDesc.stencil.front.compareFunc);
		depthStencilDesc.BackFace.StencilFailOp = GetStencilOp(outputMergerDesc.stencil.back.fail);
		depthStencilDesc.BackFace.StencilDepthFailOp = GetStencilOp(outputMergerDesc.stencil.back.depthFail);
		depthStencilDesc.BackFace.StencilPassOp = GetStencilOp(outputMergerDesc.stencil.back.pass);
		depthStencilDesc.BackFace.StencilFunc = GetComparisonFunc(outputMergerDesc.stencil.back.compareFunc);
	}

	private void FillBlendState(ref D3D12_BLEND_DESC blendDesc, GraphicsPipelineDesc graphicsPipelineDesc)
	{
		if (graphicsPipelineDesc.outputMerger == null || graphicsPipelineDesc.outputMerger.colorNum == 0)
			return;

		blendDesc.AlphaToCoverageEnable = graphicsPipelineDesc.rasterization.alphaToCoverage ? 1 : 0;
		blendDesc.IndependentBlendEnable = TRUE;

		for (uint32 i = 0; i < graphicsPipelineDesc.outputMerger.colorNum; i++)
		{
			readonly ref ColorAttachmentDesc colorAttachmentDesc = ref graphicsPipelineDesc.outputMerger.color[i];
			m_BlendEnabled |= colorAttachmentDesc.blendEnabled;

			blendDesc.RenderTarget[i].BlendEnable = colorAttachmentDesc.blendEnabled ? 1 : 0;
			blendDesc.RenderTarget[i].RenderTargetWriteMask = GetRenderTargetWriteMask(colorAttachmentDesc.colorWriteMask);
			if (colorAttachmentDesc.blendEnabled)
			{
				blendDesc.RenderTarget[i].LogicOp = GetLogicOp(graphicsPipelineDesc.outputMerger.colorLogicFunc);
				blendDesc.RenderTarget[i].LogicOpEnable = blendDesc.RenderTarget[i].LogicOp == .D3D12_LOGIC_OP_NOOP ? FALSE : TRUE;
				blendDesc.RenderTarget[i].SrcBlend = GetBlend(colorAttachmentDesc.colorBlend.srcFactor);
				blendDesc.RenderTarget[i].DestBlend = GetBlend(colorAttachmentDesc.colorBlend.dstFactor);
				blendDesc.RenderTarget[i].BlendOp = GetBlendOp(colorAttachmentDesc.colorBlend.func);
				blendDesc.RenderTarget[i].SrcBlendAlpha = GetBlend(colorAttachmentDesc.alphaBlend.srcFactor);
				blendDesc.RenderTarget[i].DestBlendAlpha = GetBlend(colorAttachmentDesc.alphaBlend.dstFactor);
				blendDesc.RenderTarget[i].BlendOpAlpha = GetBlendOp(colorAttachmentDesc.alphaBlend.func);
			}
		}

		m_BlendFactor = graphicsPipelineDesc.outputMerger.blendConsts;
	}

	private void FillSampleDesc(ref DXGI_SAMPLE_DESC sampleDesc, ref uint32 sampleMask, GraphicsPipelineDesc graphicsPipelineDesc)
	{
		if (graphicsPipelineDesc.rasterization == null)
			return;

		readonly ref RasterizationDesc rasterizationDesc = ref *graphicsPipelineDesc.rasterization;

		sampleMask = graphicsPipelineDesc.rasterization.sampleMask;
		sampleDesc.Count = rasterizationDesc.sampleNum;
		sampleDesc.Quality = 0;

		m_SampleNum = rasterizationDesc.sampleNum;
	}

	private DeviceD3D12 m_Device;
	private uint32[D3D12_IA_VERTEX_INPUT_RESOURCE_SLOT_COUNT] m_IAStreamStride = .(); // TODO: optimize?
	private ComPtr<ID3D12PipelineState> m_PipelineState;
	//#ifdef __ID3D12Device5_INTERFACE_DEFINED__
	private ComPtr<ID3D12StateObject> m_StateObject;
	private ComPtr<ID3D12StateObjectProperties> m_StateObjectProperties;
	private List<String> m_ShaderGroupNames;
	//#endif
	private PipelineLayoutD3D12 m_PipelineLayout = null;
	private D3D_PRIMITIVE_TOPOLOGY m_PrimitiveTopology = .D3D_PRIMITIVE_TOPOLOGY_UNDEFINED;
	private Color<float> m_BlendFactor = .();
	private uint8 m_SampleNum = 1;
	private bool m_BlendEnabled = false;
	private bool m_IsGraphicsPipeline = false;

	public this(DeviceD3D12 device)
	{
		m_Device = device;
		m_ShaderGroupNames = Allocate!<List<String>>(m_Device.GetAllocator());
	}
	public ~this()
	{
		Deallocate!(m_Device.GetAllocator(), m_ShaderGroupNames);

		m_PipelineState.Dispose();
	}

	public DeviceD3D12 GetDevice() => m_Device;

	public static implicit operator ID3D12PipelineState*(Self self) => self.m_PipelineState.GetInterface();

	public Result Create(GraphicsPipelineDesc graphicsPipelineDesc)
	{
	//#ifdef __ID3D12GraphicsCommandList6_INTERFACE_DEFINED__
		if (m_Device.IsMeshShaderSupported())
			return CreateFromStream(graphicsPipelineDesc);
	//#endif

		D3D12_GRAPHICS_PIPELINE_STATE_DESC graphicsPipleineStateDesc = .();
		graphicsPipleineStateDesc.NodeMask = NRI_TEMP_NODE_MASK;

		m_PipelineLayout = (PipelineLayoutD3D12)graphicsPipelineDesc.pipelineLayout;

		graphicsPipleineStateDesc.pRootSignature = m_PipelineLayout;

		graphicsPipleineStateDesc.PrimitiveTopologyType = GetPrimitiveTopologyType(graphicsPipelineDesc.inputAssembly.topology);
		m_PrimitiveTopology = GetPrimitiveTopology(graphicsPipelineDesc.inputAssembly.topology, graphicsPipelineDesc.inputAssembly.tessControlPointNum);
		graphicsPipleineStateDesc.InputLayout.pInputElementDescs = STACK_ALLOC!<D3D12_INPUT_ELEMENT_DESC>(graphicsPipelineDesc.inputAssembly.attributeNum);

		Compiler.Assert((uint32)PrimitiveRestart.DISABLED == (uint32)D3D12_INDEX_BUFFER_STRIP_CUT_VALUE.D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_DISABLED, "Enum mismatch.");
		Compiler.Assert((uint32)PrimitiveRestart.INDICES_UINT16 == (uint32)D3D12_INDEX_BUFFER_STRIP_CUT_VALUE.D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_0xFFFF, "Enum mismatch.");
		Compiler.Assert((uint32)PrimitiveRestart.INDICES_UINT32 == (uint32)D3D12_INDEX_BUFFER_STRIP_CUT_VALUE.D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_0xFFFFFFFF, "Enum mismatch.");
		graphicsPipleineStateDesc.IBStripCutValue = (D3D12_INDEX_BUFFER_STRIP_CUT_VALUE)graphicsPipelineDesc.inputAssembly.primitiveRestart;

		FillInputLayout(ref graphicsPipleineStateDesc.InputLayout, graphicsPipelineDesc);

		for (uint32 i = 0; i < graphicsPipelineDesc.shaderStageNum; i++)
		{
			readonly ref ShaderDesc shader = ref graphicsPipelineDesc.shaderStages[i];
			if (shader.stage == ShaderStage.VERTEX)
				FillShaderBytecode(ref graphicsPipleineStateDesc.VS, shader);
			else if (shader.stage == ShaderStage.TESS_CONTROL)
				FillShaderBytecode(ref graphicsPipleineStateDesc.HS, shader);
			else if (shader.stage == ShaderStage.TESS_EVALUATION)
				FillShaderBytecode(ref graphicsPipleineStateDesc.DS, shader);
			else if (shader.stage == ShaderStage.GEOMETRY)
				FillShaderBytecode(ref graphicsPipleineStateDesc.GS, shader);
			else if (shader.stage == ShaderStage.FRAGMENT)
				FillShaderBytecode(ref graphicsPipleineStateDesc.PS, shader);
		}

		FillRasterizerState(ref graphicsPipleineStateDesc.RasterizerState, graphicsPipelineDesc);
		FillBlendState(ref graphicsPipleineStateDesc.BlendState, graphicsPipelineDesc);
		FillSampleDesc(ref graphicsPipleineStateDesc.SampleDesc, ref graphicsPipleineStateDesc.SampleMask, graphicsPipelineDesc);

		if (graphicsPipelineDesc.outputMerger != null)
		{
			FillDepthStencilState(ref graphicsPipleineStateDesc.DepthStencilState, *graphicsPipelineDesc.outputMerger);
			graphicsPipleineStateDesc.DSVFormat = ConvertNRIFormatToDXGI(graphicsPipelineDesc.outputMerger.depthStencilFormat);

			graphicsPipleineStateDesc.NumRenderTargets = graphicsPipelineDesc.outputMerger.colorNum;
			for (uint32 i = 0; i < graphicsPipelineDesc.outputMerger.colorNum; i++)
				graphicsPipleineStateDesc.RTVFormats[i] = ConvertNRIFormatToDXGI(graphicsPipelineDesc.outputMerger.color[i].format);
		}

		HRESULT hr = ((ID3D12Device*)m_Device).CreateGraphicsPipelineState(&graphicsPipleineStateDesc, ID3D12PipelineState.IID, (void**)(&m_PipelineState));
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device().CreateGraphicsPipelineState failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		m_IsGraphicsPipeline = true;

		return Result.SUCCESS;
	}

	public Result Create(ComputePipelineDesc computePipelineDesc)
	{
		D3D12_COMPUTE_PIPELINE_STATE_DESC computePipleineStateDesc = .();
		computePipleineStateDesc.NodeMask = NRI_TEMP_NODE_MASK;

		m_PipelineLayout = (PipelineLayoutD3D12)computePipelineDesc.pipelineLayout;

		computePipleineStateDesc.pRootSignature = m_PipelineLayout;

		FillShaderBytecode(ref computePipleineStateDesc.CS, computePipelineDesc.computeShader);

		HRESULT hr = ((ID3D12Device*)m_Device).CreateComputePipelineState(&computePipleineStateDesc, ID3D12PipelineState.IID, (void**)(&m_PipelineState));
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device().CreateComputePipelineState failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		return Result.SUCCESS;
	}

	public Result Create(RayTracingPipelineDesc rayTracingPipelineDesc)
	{
//#ifdef __ID3D12Device5_INTERFACE_DEFINED__
		ID3D12Device5* device5 = m_Device;
		if (device5 == null)
			return Result.FAILURE;

		m_PipelineLayout = (PipelineLayoutD3D12)rayTracingPipelineDesc.pipelineLayout;

		ID3D12RootSignature* rootSignature = m_PipelineLayout;

		uint32 stateSubobjectNum = 0;
		uint32 shaderNum = rayTracingPipelineDesc.shaderLibrary != null ? rayTracingPipelineDesc.shaderLibrary.shaderNum : 0;
		List<D3D12_STATE_SUBOBJECT> stateSubobjects = Allocate!<List<D3D12_STATE_SUBOBJECT>>(m_Device.GetAllocator());
		defer { Deallocate!(m_Device.GetAllocator(), stateSubobjects); }
		stateSubobjects.Resize(1 /*pipeline config*/ + 1 /*shader config*/ + 1 /*node mask*/ + shaderNum /*DXIL libraries*/ +
			rayTracingPipelineDesc.shaderGroupDescNum + (rootSignature != null ? 1 : 0));

		D3D12_RAYTRACING_PIPELINE_CONFIG rayTracingPipelineConfig = .();
		{
			rayTracingPipelineConfig.MaxTraceRecursionDepth = rayTracingPipelineDesc.recursionDepthMax;

			stateSubobjects[stateSubobjectNum].Type = .D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_PIPELINE_CONFIG;
			stateSubobjects[stateSubobjectNum].pDesc = &rayTracingPipelineConfig;
			stateSubobjectNum++;
		}

		D3D12_RAYTRACING_SHADER_CONFIG rayTracingShaderConfig = .();
		{
			rayTracingShaderConfig.MaxPayloadSizeInBytes = rayTracingPipelineDesc.payloadAttributeSizeMax;
			rayTracingShaderConfig.MaxAttributeSizeInBytes = rayTracingPipelineDesc.intersectionAttributeSizeMax;

			stateSubobjects[stateSubobjectNum].Type = .D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_SHADER_CONFIG;
			stateSubobjects[stateSubobjectNum].pDesc = &rayTracingShaderConfig;
			stateSubobjectNum++;
		}

		D3D12_NODE_MASK nodeMask = .();
		{
			nodeMask.NodeMask = NRI_TEMP_NODE_MASK;

			stateSubobjects[stateSubobjectNum].Type = .D3D12_STATE_SUBOBJECT_TYPE_NODE_MASK;
			stateSubobjects[stateSubobjectNum].pDesc = &nodeMask;
			stateSubobjectNum++;
		}

		D3D12_GLOBAL_ROOT_SIGNATURE globalRootSignature = .();
		if (rootSignature != null)
		{
			globalRootSignature.pGlobalRootSignature = rootSignature;

			stateSubobjects[stateSubobjectNum].Type = .D3D12_STATE_SUBOBJECT_TYPE_GLOBAL_ROOT_SIGNATURE;
			stateSubobjects[stateSubobjectNum].pDesc = &globalRootSignature;
			stateSubobjectNum++;
		}

		List<D3D12_DXIL_LIBRARY_DESC> libraryDescs = Allocate!<List<D3D12_DXIL_LIBRARY_DESC>>(m_Device.GetAllocator());
		defer { Deallocate!(m_Device.GetAllocator(), libraryDescs); }
		libraryDescs.Resize(rayTracingPipelineDesc.shaderLibrary.shaderNum);
		for (uint32 i = 0; i < rayTracingPipelineDesc.shaderLibrary.shaderNum; i++)
		{
			libraryDescs[i].DXILLibrary.pShaderBytecode = rayTracingPipelineDesc.shaderLibrary.shaderDescs[i].bytecode;
			libraryDescs[i].DXILLibrary.BytecodeLength = (uint)rayTracingPipelineDesc.shaderLibrary.shaderDescs[i].size;
			libraryDescs[i].NumExports = 0;
			libraryDescs[i].pExports = null;

			stateSubobjects[stateSubobjectNum].Type = .D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY;
			stateSubobjects[stateSubobjectNum].pDesc = &libraryDescs[i];
			stateSubobjectNum++;
		}

		List<char16*> wEntryPointNames = Allocate!<List<char16*>>(m_Device.GetAllocator());
		defer { Deallocate!(m_Device.GetAllocator(), wEntryPointNames); }
		wEntryPointNames.Resize(rayTracingPipelineDesc.shaderLibrary.shaderNum);
		for (uint32 i = 0; i < rayTracingPipelineDesc.shaderLibrary.shaderNum; i++)
		{
			readonly ref ShaderDesc shader = ref rayTracingPipelineDesc.shaderLibrary.shaderDescs[i];
			wEntryPointNames[i] = scope:: String(shader.entryPointName).ToScopedNativeWChar!::();
		}

		uint32 hitGroupNum = 0;
		List<D3D12_HIT_GROUP_DESC> hitGroups = Allocate!<List<D3D12_HIT_GROUP_DESC>>(m_Device.GetAllocator());
		defer { Deallocate!(m_Device.GetAllocator(), hitGroups); }
		hitGroups.Resize(rayTracingPipelineDesc.shaderGroupDescNum);
		m_ShaderGroupNames.Reserve(rayTracingPipelineDesc.shaderGroupDescNum);
		for (uint32 i = 0; i < rayTracingPipelineDesc.shaderGroupDescNum; i++)
		{
			bool isHitGroup = true;
			bool hasIntersectionShader = false;
			char16* shaderIndentifierName = null;
			var shaderIndices = rayTracingPipelineDesc.shaderGroupDescs[i].shaderIndices;
			for (uint32 j = 0; j < /*rayTracingPipelineDesc.shaderGroupDescs[i].*/shaderIndices.Count; j++)
			{
				readonly ref uint32 shaderIndex = ref rayTracingPipelineDesc.shaderGroupDescs[i].shaderIndices[j];
				if (shaderIndex > 0)
				{
					uint32 lookupIndex = shaderIndex - 1;
					readonly ref ShaderDesc shader = ref rayTracingPipelineDesc.shaderLibrary.shaderDescs[lookupIndex];
					readonly ref char16* entryPointName = ref wEntryPointNames[lookupIndex];
					if (shader.stage == ShaderStage.RAYGEN || shader.stage == ShaderStage.MISS || shader.stage == ShaderStage.CALLABLE)
					{
						shaderIndentifierName = entryPointName;
						isHitGroup = false;
						break;
					}

					switch (shader.stage)
					{
					case ShaderStage.INTERSECTION:
						hitGroups[hitGroupNum].IntersectionShaderImport = entryPointName;
						hasIntersectionShader = true;
						break;
					case ShaderStage.CLOSEST_HIT:
						hitGroups[hitGroupNum].ClosestHitShaderImport = entryPointName;
						break;
					case ShaderStage.ANY_HIT:
						hitGroups[hitGroupNum].AnyHitShaderImport = entryPointName;
						break;
					default: break;
					}

					shaderIndentifierName = scope:: $"{i}".ToScopedNativeWChar!::();
				}
			}

			m_ShaderGroupNames.Add(new String(shaderIndentifierName));

			if (isHitGroup)
			{
				hitGroups[hitGroupNum].HitGroupExport = m_ShaderGroupNames[i].ToScopedNativeWChar!::();
				hitGroups[hitGroupNum].Type = hasIntersectionShader ? .D3D12_HIT_GROUP_TYPE_PROCEDURAL_PRIMITIVE : .D3D12_HIT_GROUP_TYPE_TRIANGLES;

				stateSubobjects[stateSubobjectNum].Type = .D3D12_STATE_SUBOBJECT_TYPE_HIT_GROUP;
				stateSubobjects[stateSubobjectNum].pDesc = &hitGroups[hitGroupNum++];
				stateSubobjectNum++;
			}
		}

		D3D12_STATE_OBJECT_DESC stateObjectDesc = .();
		stateObjectDesc.Type = .D3D12_STATE_OBJECT_TYPE_RAYTRACING_PIPELINE;
		stateObjectDesc.NumSubobjects = stateSubobjectNum;
		stateObjectDesc.pSubobjects = stateSubobjectNum > 0 ? &stateSubobjects[0] : null;

		HRESULT hr = device5.CreateStateObject(&stateObjectDesc, ID3D12StateObject.IID, (void**)(&m_StateObject));
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device5().CreateStateObject failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		m_StateObject->QueryInterface(ID3D12StateObjectProperties.IID, (void**)&m_StateObjectProperties);

		return Result.SUCCESS;
//#else
	//return Result.FAILURE;
//#endif
	}

	public void Bind(ID3D12GraphicsCommandList* graphicsCommandList, ref D3D_PRIMITIVE_TOPOLOGY primitiveTopology)
	{
//#ifdef __ID3D12Device5_INTERFACE_DEFINED__
		if (m_StateObject.Get() != null)
			((ID3D12GraphicsCommandList4*)graphicsCommandList).SetPipelineState1(m_StateObject);
		else
//#endif
			graphicsCommandList.SetPipelineState(m_PipelineState);

		if (m_IsGraphicsPipeline)
		{
			//if (primitiveTopology != m_PrimitiveTopology)
			{
				primitiveTopology = m_PrimitiveTopology;
				graphicsCommandList.IASetPrimitiveTopology(m_PrimitiveTopology);
			}

			if (m_BlendEnabled)
				graphicsCommandList.OMSetBlendFactor(&m_BlendFactor.r);
		}
	}
	public bool IsGraphicsPipeline() => m_IsGraphicsPipeline;
	public uint32 GetIAStreamStride(uint32 streamSlot) => m_IAStreamStride[streamSlot];
	public uint8 GetSampleNum() => m_SampleNum;
	public PipelineLayoutD3D12 GetPipelineLayout() => m_PipelineLayout;

	public void SetDebugName(char8* name)
	{
		SET_D3D_DEBUG_OBJECT_NAME!(m_PipelineState, scope String(name));
	}

	public Result WriteShaderGroupIdentifiers(uint32 baseShaderGroupIndex, uint32 shaderGroupNum, void* buffer)
	{
		//#ifdef __ID3D12Device5_INTERFACE_DEFINED__
		uint8* byteBuffer = (uint8*)buffer;
		for (uint32 i = 0; i < shaderGroupNum; i++)
		{
			Internal.MemCpy(byteBuffer + i * D3D12_RAYTRACING_SHADER_TABLE_BYTE_ALIGNMENT, m_StateObjectProperties->GetShaderIdentifier(m_ShaderGroupNames[baseShaderGroupIndex + i].ToScopedNativeWChar!()),
				(int)m_Device.GetDesc().rayTracingShaderGroupIdentifierSize);
		}

		return Result.SUCCESS;
		//#else
			//return Result.FAILURE;
		//#endif
	}
}