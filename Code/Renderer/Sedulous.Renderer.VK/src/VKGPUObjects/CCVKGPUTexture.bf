using Bulkan;
using Bulkan.Utilities;
using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUTexture : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		if (memoryAllocated)
		{
			CCVKDevice.getInstance().getMemoryStatus().textureSize -= size;
			//CC_PROFILE_MEMORY_DEC(Texture, size);
		}

		CCVKDevice.getInstance().gpuBarrierManager().cancel(this);
		if (!flags.HasFlag(TextureFlagBit.EXTERNAL_NORMAL))
		{
			CCVKDevice.getInstance().gpuRecycleBin().collect(this);
		}
	}
	public void init()
	{
		cmdFuncCCVKCreateTexture(CCVKDevice.getInstance(), this);

		if (memoryAllocated)
		{
			CCVKDevice.getInstance().getMemoryStatus().textureSize += size;
			//CC_PROFILE_MEMORY_INC(Texture, size);
		}
	}

	public TextureType type = TextureType.TEX2D;
	public Format format = Format.UNKNOWN;
	public TextureUsage usage = TextureUsageBit.NONE;
	public uint32 width = 0U;
	public uint32 height = 0U;
	public uint32 depth = 1U;
	public uint32 size = 0U;
	public uint32 arrayLayers = 1U;
	public uint32 mipLevels = 1U;
	public SampleCount samples = SampleCount.X1;
	public TextureFlags flags = TextureFlagBit.NONE;
	public VkImageAspectFlags aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;

	/*
	 * allocate and bind memory by Texture.
	 * If any of the following conditions are met, then the statement is false
	 * 1. Texture is a swapchain image.
	 * 2. Texture has flag LAZILY_ALLOCATED.
	 * 3. Memory bound manually bound.
	 * 4. Sparse Image.
	 */
	public bool memoryAllocated = true;

	public VkImage vkImage = .Null;
	public VmaAllocation vmaAllocation = .();

	public CCVKGPUSwapchain swapchain = null;
	public List<VkImage> swapchainVkImages;
	public List<VmaAllocation> swapchainVmaAllocations;

	public List<ThsvsAccessType> currentAccessTypes;

	// for barrier manager
	public List<ThsvsAccessType> renderAccessTypes; // gathered from descriptor sets
	public ThsvsAccessType transferAccess = .THSVS_ACCESS_NONE;

	public VkImage externalVKImage = .Null;
}