namespace NRI.Validation;

class PipelineVal : Pipeline, DeviceObjectVal<Pipeline>
{
	private PipelineLayout m_PipelineLayout = null;

	public this(DeviceVal device, Pipeline pipeline) : base(device, pipeline)
	{
	}

	public this(DeviceVal device, Pipeline pipeline, GraphicsPipelineDesc graphicsPipelineDesc) : base(device, pipeline)
	{
		m_PipelineLayout = graphicsPipelineDesc.pipelineLayout;
	}

	public this(DeviceVal device, Pipeline pipeline, ComputePipelineDesc computePipelineDesc) : base(device, pipeline)
	{
		m_PipelineLayout = computePipelineDesc.pipelineLayout;
	}

	public this(DeviceVal device, Pipeline pipeline, RayTracingPipelineDesc rayTracingPipelineDesc) : base(device, pipeline)
	{
		m_PipelineLayout = rayTracingPipelineDesc.pipelineLayout;
	}

	public PipelineLayout GetPipelineLayout() => m_PipelineLayout;

	public void SetDebugName(char8* name)
	{
		m_Name.Set(scope .(name));
		m_ImplObject.SetDebugName(name);
	}

	public Result WriteShaderGroupIdentifiers(uint32 baseShaderGroupIndex, uint32 shaderGroupNum, void* buffer)
	{
		return m_ImplObject.WriteShaderGroupIdentifiers(baseShaderGroupIndex, shaderGroupNum, buffer);
	}
}