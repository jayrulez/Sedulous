using NRI.Helpers;
namespace NRI;

interface Device
{
	public DeviceLogger GetLogger();
	public DeviceAllocator<uint8> GetAllocator();

	public void SetDebugName(char8* name);

	public readonly ref DeviceDesc GetDesc();
	public Result GetCommandQueue(CommandQueueType commandQueueType, out CommandQueue commandQueue);

	public Result CreateCommandAllocator(CommandQueue commandQueue, uint32 physicalDeviceMask, out CommandAllocator commandAllocator);
	public Result CreateDescriptorPool(DescriptorPoolDesc descriptorPoolDesc, out DescriptorPool descriptorPool);
	public Result CreateBuffer(BufferDesc bufferDesc, out Buffer buffer);
	public Result CreateTexture(TextureDesc textureDesc, out Texture texture);
	public Result CreateBufferView(BufferViewDesc bufferViewDesc, out Descriptor bufferView);
	public Result CreateTexture1DView(Texture1DViewDesc textureViewDesc, out Descriptor textureView);
	public Result CreateTexture2DView(Texture2DViewDesc textureViewDesc, out Descriptor textureView);
	public Result CreateTexture3DView(Texture3DViewDesc textureViewDesc, out Descriptor textureView);
	public Result CreateSampler(SamplerDesc samplerDesc, out Descriptor sampler);
	public Result CreatePipelineLayout(PipelineLayoutDesc pipelineLayoutDesc, out PipelineLayout pipelineLayout);
	public Result CreateGraphicsPipeline(GraphicsPipelineDesc graphicsPipelineDesc, out Pipeline pipeline);
	public Result CreateComputePipeline(ComputePipelineDesc computePipelineDesc, out Pipeline pipeline);
	public Result CreateFrameBuffer(FrameBufferDesc frameBufferDesc, out FrameBuffer frameBuffer);
	public Result CreateQueryPool(QueryPoolDesc queryPoolDesc, out QueryPool queryPool);
	public Result CreateQueueSemaphore(out QueueSemaphore queueSemaphore);
	public Result CreateDeviceSemaphore(bool signaled, out DeviceSemaphore deviceSemaphore);
	public Result CreateCommandBuffer(CommandAllocator commandAllocator, out CommandBuffer commandBuffer);
    public Result CreateSwapChain(SwapChainDesc swapChainDesc, out SwapChain swapChain);
    public Result CreateRayTracingPipeline(RayTracingPipelineDesc rayTracingPipelineDesc, out Pipeline pipeline);
    public Result CreateAccelerationStructure(AccelerationStructureDesc accelerationStructureDesc, out AccelerationStructure accelerationStructure);


	public void DestroyCommandAllocator(CommandAllocator commandAllocator);
	public void DestroyDescriptorPool(DescriptorPool descriptorPool);
	public void DestroyBuffer(Buffer buffer);
	public void DestroyTexture(Texture texture);
	public void DestroyDescriptor(Descriptor descriptor);
	public void DestroyPipelineLayout(PipelineLayout pipelineLayout);
	public void DestroyPipeline(Pipeline pipeline);
	public void DestroyFrameBuffer(FrameBuffer frameBuffer);
	public void DestroyQueryPool(QueryPool queryPool);
	public void DestroyQueueSemaphore(QueueSemaphore queueSemaphore);
	public void DestroyDeviceSemaphore(DeviceSemaphore deviceSemaphore);
	public void DestroyCommandBuffer(CommandBuffer commandBuffer);
    public void DestroySwapChain(SwapChain swapChain);
	public void DestroyAccelerationStructure(AccelerationStructure accelerationStructure);
	public void Destroy();
	
	public Result GetDisplays(Display** displays, ref uint32 displayNum);
	public Result GetDisplaySize(ref Display display, ref uint16 width, ref uint16 height);

	public Result AllocateMemory(uint32 physicalDeviceMask, MemoryType memoryType, uint64 size, out Memory memory);
	public Result BindBufferMemory(BufferMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum);
	public Result BindTextureMemory(TextureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum);
    public Result BindAccelerationStructureMemory(AccelerationStructureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum);
	public void FreeMemory(Memory memory);

	public FormatSupportBits GetFormatSupport(Format format);

	
	public uint32 CalculateAllocationNumber(ResourceGroupDesc resourceGroupDesc);
	public Result AllocateAndBindMemory(ResourceGroupDesc resourceGroupDesc, Memory* allocations);

	public void* GetDeviceNativeObject();
}