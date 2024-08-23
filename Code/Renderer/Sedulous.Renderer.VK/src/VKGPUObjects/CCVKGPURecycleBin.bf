using Bulkan;
using Bulkan.Utilities;
using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

using static Bulkan.Utilities.VulkanMemoryAllocator;

		/**
		 * Recycle bin for GPU resources, clears after vkDeviceWaitIdle every frame.
		 * All the destroy events will be postponed to that time.
		 */
class CCVKGPURecycleBin
{
	public this(CCVKGPUDevice device)
	{
		_device = device;
		_resources.Resize(16);
	}

	public void collect(CCVKGPUTexture texture)
	{
		delegate void(VkImage image, VmaAllocation allocation) collectHandleFn = scope [&] (image, allocation) =>
			{
				ref Resource res = ref emplaceBack();
				res.type = RecycledType.TEXTURE;
				res.image.vkImage = image;
				res.image.vmaAllocation = allocation;
			};
		collectHandleFn(texture.vkImage, texture.vmaAllocation);

		if (texture.swapchain != null)
		{
			for (uint32 i = 0; i < texture.swapchainVkImages.Count && i < texture.swapchainVmaAllocations.Count; ++i)
			{
				collectHandleFn(texture.swapchainVkImages[i], texture.swapchainVmaAllocations[i]);
			}
		}
	}
	public void collect(CCVKGPUTextureView textureView)
	{
		delegate void(VkImageView view) collectHandleFn = scope [&] (view) =>
			{
				ref Resource res = ref emplaceBack();
				res.type = RecycledType.TEXTURE_VIEW;
				res.vkImageView = view;
			};
		collectHandleFn(textureView.vkImageView);
		for (var swapChainView in textureView.swapchainVkImageViews)
		{
			collectHandleFn(swapChainView);
		}
	}
	public void collect(CCVKGPUFramebuffer frameBuffer)
	{
		delegate void(VkFramebuffer fbo) collectHandleFn = scope [&] (fbo) =>
			{
				ref Resource res = ref emplaceBack();
				res.type = RecycledType.FRAMEBUFFER;
				res.vkFramebuffer = fbo;
			};
		collectHandleFn(frameBuffer.vkFramebuffer);
		for (var fbo in frameBuffer.vkFrameBuffers)
		{
			collectHandleFn(fbo);
		}
	}
	public void collect(CCVKGPUDescriptorSet set)
	{
		for (var instance in set.instances)
		{
			collect(set.layoutID, instance.vkDescriptorSet);
		}
	}
	public void collect(uint32 layoutId, VkDescriptorSet set)
	{
		ref Resource res = ref emplaceBack();
		res.type = RecycledType.DESCRIPTOR_SET;
		res.set.layoutId = layoutId;
		res.set.vkSet = set;
	}
	public void collect(CCVKGPUBuffer buffer)
	{
		ref Resource res = ref emplaceBack();
		res.type = RecycledType.BUFFER;
		res.buffer.vkBuffer = buffer.vkBuffer;
		res.buffer.vmaAllocation = buffer.vmaAllocation;
	}

/*#define DEFINE_RECYCLE_BIN_COLLECT_FN(_type, typeValue, expr)                        \
void collect(const _type *gpuRes) { /* NOLINT(bugprone-macro-parentheses) N/A */ \
	Resource &res = emplaceBack();                                               \
	res.type = typeValue;                                                        \
	expr;                                                                        \
}

		DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPURenderPass, RecycledType.RENDER_PASS, res.vkRenderPass = gpuRes.vkRenderPass)
			DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPUSampler, RecycledType.SAMPLER, res.vkSampler = gpuRes.vkSampler)
			DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPUQueryPool, RecycledType.QUERY_POOL, res.vkQueryPool = gpuRes.vkPool)
			DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPUPipelineState, RecycledType.PIPELINE_STATE, res.vkPipeline = gpuRes.vkPipeline)*/

	public void collect(CCVKGPURenderPass gpuRes)
	{
		ref Resource res = ref emplaceBack();
		res.type = RecycledType.RENDER_PASS;
		res.vkRenderPass = gpuRes.vkRenderPass;
	}
	public void collect(CCVKGPUSampler gpuRes)
	{
		ref Resource res = ref emplaceBack();
		res.type = RecycledType.SAMPLER;
		res.vkSampler = gpuRes.vkSampler;
	}
	public void collect(CCVKGPUQueryPool gpuRes)
	{
		ref Resource res = ref emplaceBack();
		res.type = RecycledType.QUERY_POOL;
		res.vkQueryPool = gpuRes.vkPool;
	}
	public void collect(CCVKGPUPipelineState gpuRes)
	{
		ref Resource res = ref emplaceBack();
		res.type = RecycledType.PIPELINE_STATE;
		res.vkPipeline = gpuRes.vkPipeline;
	}

	public void clear()
	{
		for (uint32 i = 0U; i < _count; ++i)
		{
			ref Resource res = ref _resources[i];
			switch (res.type) {
			case RecycledType.BUFFER:
				if (res.buffer.vkBuffer != .Null && res.buffer.vmaAllocation != 0)
				{
					vmaDestroyBuffer(_device.memoryAllocator, res.buffer.vkBuffer, res.buffer.vmaAllocation);
					res.buffer.vkBuffer = .Null;
					res.buffer.vmaAllocation = 0;
				}
				break;
			case RecycledType.TEXTURE:
				if (res.image.vkImage != .Null && res.image.vmaAllocation != 0)
				{
					vmaDestroyImage(_device.memoryAllocator, res.image.vkImage, res.image.vmaAllocation);
					res.image.vkImage = .Null;
					res.image.vmaAllocation = 0;
				}
				break;
			case RecycledType.TEXTURE_VIEW:
				if (res.vkImageView != .Null)
				{
					VulkanNative.vkDestroyImageView(_device.vkDevice, res.vkImageView, null);
					res.vkImageView = .Null;
				}
				break;
			case RecycledType.FRAMEBUFFER:
				if (res.vkFramebuffer != .Null)
				{
					VulkanNative.vkDestroyFramebuffer(_device.vkDevice, res.vkFramebuffer, null);
					res.vkFramebuffer = .Null;
				}
				break;
			case RecycledType.QUERY_POOL:
				if (res.vkQueryPool != .Null)
				{
					VulkanNative.vkDestroyQueryPool(_device.vkDevice, res.vkQueryPool, null);
				}
				break;
			case RecycledType.RENDER_PASS:
				if (res.vkRenderPass != .Null)
				{
					VulkanNative.vkDestroyRenderPass(_device.vkDevice, res.vkRenderPass, null);
				}
				break;
			case RecycledType.SAMPLER:
				if (res.vkSampler != .Null)
				{
					VulkanNative.vkDestroySampler(_device.vkDevice, res.vkSampler, null);
				}
				break;
			case RecycledType.PIPELINE_STATE:
				if (res.vkPipeline != .Null)
				{
					VulkanNative.vkDestroyPipeline(_device.vkDevice, res.vkPipeline, null);
				}
				break;
			case RecycledType.DESCRIPTOR_SET:
				if (res.set.vkSet != .Null)
				{
					CCVKDevice.getInstance().gpuDevice().getDescriptorSetPool(res.set.layoutId)._yield(res.set.vkSet);
				}
				break;
			default: break;
			}
			res.type = RecycledType.UNKNOWN;
		}
		_count = 0;
	}

	private enum RecycledType
	{
		UNKNOWN,
		BUFFER,
		BUFFER_VIEW,
		TEXTURE,
		TEXTURE_VIEW,
		FRAMEBUFFER,
		QUERY_POOL,
		RENDER_PASS,
		SAMPLER,
		PIPELINE_STATE,
		DESCRIPTOR_SET,
		EVENT
	};
	private struct Buffer
	{
		public VkBuffer vkBuffer;
		public VmaAllocation vmaAllocation;
	};
	private struct Image
	{
		public VkImage vkImage;
		public VmaAllocation vmaAllocation;
	};
	private struct Set
	{
		public uint32 layoutId;
		public VkDescriptorSet vkSet;
	};
	private struct Resource
	{
		public RecycledType type = RecycledType.UNKNOWN;
		private struct Value
		{
			// resizable resources, cannot take over directly
			// or descriptor sets won't work
			public Buffer buffer;
			public Image image;
			public Set set;
			public VkBufferView vkBufferView;
			public VkImageView vkImageView;
			public VkFramebuffer vkFramebuffer;
			public VkQueryPool vkQueryPool;
			public VkRenderPass vkRenderPass;
			public VkSampler vkSampler;
			public VkEvent vkEvent;
			public VkPipeline vkPipeline;
		}
		public using private Value value;
	}

	private ref Resource emplaceBack()
	{
		if (_resources.Count <= _count)
		{
			_resources.Resize(_count * 2);
		}
		return ref _resources[_count++];
	}

	private CCVKGPUDevice _device = null;
	private List<Resource> _resources;
	private int _count = 0U;
}