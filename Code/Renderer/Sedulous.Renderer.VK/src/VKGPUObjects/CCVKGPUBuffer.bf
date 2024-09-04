using Bulkan;
using Bulkan.Utilities;
using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUBuffer : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		CCVKDevice.getInstance().gpuBarrierManager().cancel(this);
		CCVKDevice.getInstance().gpuRecycleBin().collect(this);
		CCVKDevice.getInstance().gpuBufferHub().erase(this);

		CCVKDevice.getInstance().getMemoryStatus().bufferSize -= size;
		//CC_PROFILE_MEMORY_DEC(Buffer, size);
	}
	public void init()
	{
		if (usage.HasFlag(BufferUsageBit.INDIRECT))
		{
			readonly uint32 drawInfoCount = size / sizeof(DrawInfo);
			indexedIndirectCmds.Resize(drawInfoCount);
			indirectCmds.Resize(drawInfoCount);
		}

		cmdFuncCCVKCreateBuffer(CCVKDevice.getInstance(), this);
		CCVKDevice.getInstance().getMemoryStatus().bufferSize += size;
		//CC_PROFILE_MEMORY_INC(Buffer, size);
	}

	public BufferUsage usage = BufferUsage.NONE;
	public MemoryUsage memUsage = MemoryUsage.NONE;
	public uint32 stride = 0U;
	public uint32 count = 0U;
	public void* buffer = null;

	public bool isDrawIndirectByIndex = false;
	public List<VkDrawIndirectCommand> indirectCmds = new .() ~ delete _;
	public List<VkDrawIndexedIndirectCommand> indexedIndirectCmds = new .() ~ delete _;

	public uint8* mappedData = null;
	public VmaAllocation vmaAllocation = .();

	// descriptor infos
	public VkBuffer vkBuffer = .Null;
	public uint32 size = 0U;

	public uint32 instanceSize = 0U; // per-back-buffer instance
	public List<ThsvsAccessType> currentAccessTypes = new .() ~ delete _;

	// for barrier manager
	public List<ThsvsAccessType> renderAccessTypes = new .() ~ delete _; // gathered from descriptor sets
	public ThsvsAccessType transferAccess = .THSVS_ACCESS_NONE;

	public uint32 getStartOffset(uint32 curBackBufferIndex)
	{
		return instanceSize * curBackBufferIndex;
	}
}