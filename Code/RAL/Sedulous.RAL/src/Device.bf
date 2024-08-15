using System;
using Sedulous.Platform;
namespace Sedulous.RAL;

abstract class Device : QueryInterface
{
	public abstract Memory AllocateMemory(uint64 size,
		MemoryType memory_type,
		uint32 memory_type_bits);
	public abstract CommandQueue GetCommandQueue(CommandListType type);
	public abstract uint32 GetTextureDataPitchAlignment();
	public abstract Swapchain CreateSwapchain(SurfaceInfo window,
		uint32 width,
		uint32 height,
		uint32 frame_count,
		bool vsync);
	public abstract CommandList CreateCommandList(CommandListType type);
	public abstract Fence CreateFence(uint64 initial_value);
	public abstract Resource CreateTexture(TextureType type,
		uint32 bind_flag,
		Format format,
		uint32 sample_count,
		int width,
		int height,
		int depth,
		int mip_levels);
	public abstract Resource CreateBuffer(uint32 bind_flag, uint32 buffer_size);
	public abstract Resource CreateSampler(in SamplerDesc desc);
	public abstract View CreateView(in Resource resource, in ViewDesc view_desc);
	public abstract BindingSetLayout CreateBindingSetLayout(Span<BindKey> descs);
	public abstract BindingSet CreateBindingSet(in BindingSetLayout layout);
	public abstract RenderPass CreateRenderPass(in RenderPassDesc desc);
	public abstract Framebuffer CreateFramebuffer(in FramebufferDesc desc);
	public abstract Shader CreateShader(Span<uint8> blob,
		ShaderBlobType blob_type,
		ShaderType shader_type);
	public abstract Shader CompileShader(in ShaderDesc desc);
	public abstract ShaderProgram CreateProgram(Span<Shader> shaders);
	public abstract Pipeline CreateGraphicsPipeline(in GraphicsPipelineDesc desc);
	public abstract Pipeline CreateComputePipeline(in ComputePipelineDesc desc);
	public abstract Pipeline CreateRayTracingPipeline(in RayTracingPipelineDesc desc);
	public abstract Resource CreateAccelerationStructure(AccelerationStructureType type,
		in Resource resource,
		uint64 offset);
	public abstract QueryHeap CreateQueryHeap(QueryHeapType type, uint32 count);
	public abstract bool IsDxrSupported();
	public abstract bool IsRayQuerySupported();
	public abstract bool IsVariableRateShadingSupported();
	public abstract bool IsMeshShadingSupported();
	public abstract bool IsDrawIndirectCountSupported();
	public abstract bool IsGeometryShaderSupported();
	public abstract uint32 GetShadingRateImageTileSize();
	public abstract MemoryBudget GetMemoryBudget();
	public abstract uint32 GetShaderGroupHandleSize();
	public abstract uint32 GetShaderRecordAlignment();
	public abstract uint32 GetShaderTableAlignment();
	public abstract RaytracingASPrebuildInfo GetBLASPrebuildInfo(Span<RaytracingGeometryDesc> descs,
		BuildAccelerationStructureFlags flags);
	public abstract RaytracingASPrebuildInfo GetTLASPrebuildInfo(uint32 instance_count,
		BuildAccelerationStructureFlags flags);
	public abstract ShaderBlobType GetSupportedShaderBlobType();
}