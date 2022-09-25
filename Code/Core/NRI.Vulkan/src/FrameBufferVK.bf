using Bulkan;
using System;
namespace NRI.Vulkan;

class FrameBufferVK : FrameBuffer
{
	private void FillDescriptionsAndFormats(FrameBufferDesc frameBufferDesc, VkAttachmentDescription* descriptions, VkFormat* formats)
	{
		readonly bool clearColor = frameBufferDesc.colorClearValues != null;
		readonly bool clearDepth = frameBufferDesc.depthStencilClearValue != null;

		for (uint32 i = 0; i < frameBufferDesc.colorAttachmentNum; i++)
		{
			readonly DescriptorVK descriptorImpl = (DescriptorVK)frameBufferDesc.colorAttachments[i];
			readonly TextureVK textureImpl = descriptorImpl.GetTexture();

			formats[i] = descriptorImpl.GetFormat();

			descriptions[i] = .()
				{
					flags =  (VkAttachmentDescriptionFlags)0,
					format = descriptorImpl.GetFormat(),
					samples = textureImpl.GetSampleCount(),
					loadOp = clearColor ? .VK_ATTACHMENT_LOAD_OP_CLEAR : .VK_ATTACHMENT_LOAD_OP_LOAD,
					storeOp = .VK_ATTACHMENT_STORE_OP_STORE,
					stencilLoadOp = clearColor ? .VK_ATTACHMENT_LOAD_OP_CLEAR : .VK_ATTACHMENT_LOAD_OP_LOAD,
					stencilStoreOp = .VK_ATTACHMENT_STORE_OP_STORE,
					initialLayout = .VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
					finalLayout = .VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
				};
		}

		if (frameBufferDesc.depthStencilAttachment != null)
		{
			readonly DescriptorVK descriptorImpl = (DescriptorVK)frameBufferDesc.depthStencilAttachment;
			readonly TextureVK textureImpl = descriptorImpl.GetTexture();

			descriptions[frameBufferDesc.colorAttachmentNum] = .()
				{
					flags = (VkAttachmentDescriptionFlags)0,
					format = descriptorImpl.GetFormat(),
					samples = textureImpl.GetSampleCount(),
					loadOp = clearDepth ? .VK_ATTACHMENT_LOAD_OP_CLEAR : .VK_ATTACHMENT_LOAD_OP_LOAD,
					storeOp = .VK_ATTACHMENT_STORE_OP_STORE,
					stencilLoadOp = clearDepth ? .VK_ATTACHMENT_LOAD_OP_CLEAR : .VK_ATTACHMENT_LOAD_OP_LOAD,
					stencilStoreOp = .VK_ATTACHMENT_STORE_OP_STORE,
					initialLayout = .VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
					finalLayout = .VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
				};
		}
	}

	private Result SaveClearColors(FrameBufferDesc frameBufferDesc)
	{
		if (frameBufferDesc.colorClearValues != null)
			Internal.MemCpy(&m_ClearValues, frameBufferDesc.colorClearValues, frameBufferDesc.colorAttachmentNum * sizeof(ClearValueDesc));

		if (frameBufferDesc.depthStencilClearValue != null)
			m_ClearValues[frameBufferDesc.colorAttachmentNum] = *frameBufferDesc.depthStencilClearValue;

		return Result.SUCCESS;
	}

	private Result CreateRenderPass(FrameBufferDesc frameBufferDesc)
	{
		VkAttachmentDescription* descriptions = STACK_ALLOC!<VkAttachmentDescription>(m_AttachmentNum);
		VkFormat* formats = STACK_ALLOC!<VkFormat>(m_AttachmentNum);
		FillDescriptionsAndFormats(frameBufferDesc, descriptions, formats);

		VkAttachmentReference* references = STACK_ALLOC!<VkAttachmentReference>(frameBufferDesc.colorAttachmentNum);

		for (uint32 i = 0; i < frameBufferDesc.colorAttachmentNum; i++)
			references[i] = .() { attachment = i, layout = .VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL };

		/*readonly*/ VkAttachmentReference depth = .()
			{
				attachment = frameBufferDesc.colorAttachmentNum,
				layout = .VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
			};

		/*readonly*/ VkSubpassDescription subpass = .()
			{
				flags = (VkSubpassDescriptionFlags)0,
				pipelineBindPoint = .VK_PIPELINE_BIND_POINT_GRAPHICS,
				inputAttachmentCount = 0,
				pInputAttachments = null,
				colorAttachmentCount = frameBufferDesc.colorAttachmentNum,
				pColorAttachments = references,
				pResolveAttachments = null,
				pDepthStencilAttachment = frameBufferDesc.depthStencilAttachment != null ? &depth : null,
				preserveAttachmentCount = 0,
				pPreserveAttachments = null
			};

		/*readonly*/ VkRenderPassCreateInfo renderPassInfo = .()
			{
				sType = .VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
				pNext = null,
				flags = (VkRenderPassCreateFlags)0,
				attachmentCount = m_AttachmentNum,
				pAttachments = descriptions,
				subpassCount = 1,
				pSubpasses = &subpass,
				dependencyCount = 0,
				pDependencies = null
			};

		VkResult result = VulkanNative.vkCreateRenderPass(m_Device, &renderPassInfo, m_Device.GetAllocationCallbacks(), &m_RenderPassWithClear);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't create a render pass: vkCreateRenderPass returned {0}.", (int32)result);

		for (uint32 i = 0; i < m_AttachmentNum; i++)
		{
			descriptions[i].loadOp = .VK_ATTACHMENT_LOAD_OP_LOAD;
			descriptions[i].stencilLoadOp = .VK_ATTACHMENT_LOAD_OP_LOAD;
		}

		result = VulkanNative.vkCreateRenderPass(m_Device, &renderPassInfo, m_Device.GetAllocationCallbacks(), &m_RenderPass);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't create a render pass: vkCreateRenderPass returned {0}.", (int32)result);

		return Result.SUCCESS;
	}

	private const uint32 ATTACHMENT_MAX_NUM = 8;

	private VkFramebuffer[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_Handles = .();
	private VkRenderPass m_RenderPassWithClear = .Null;
	private VkRenderPass m_RenderPass = .Null;
	private ClearValueDesc[ATTACHMENT_MAX_NUM] m_ClearValues = .();
	private VkRect2D m_RenderArea = .();
	private uint32 m_AttachmentNum = 0;
	private DeviceVK m_Device;

	public this(DeviceVK device)
	{
		m_Device = device;
	}

	public ~this()
	{
		for (uint32 i = 0; i < m_Handles.Count; i++)
		{
			if (m_Handles[i] != .Null)
				VulkanNative.vkDestroyFramebuffer(m_Device, m_Handles[i], m_Device.GetAllocationCallbacks());
		}

		if (m_RenderPass != .Null)
			VulkanNative.vkDestroyRenderPass(m_Device, m_RenderPass, m_Device.GetAllocationCallbacks());
		if (m_RenderPassWithClear != .Null)
			VulkanNative.vkDestroyRenderPass(m_Device, m_RenderPassWithClear, m_Device.GetAllocationCallbacks());
	}

	public DeviceVK GetDevice() => m_Device;

	public Result Create(FrameBufferDesc frameBufferDesc)
	{
		/*readonly*/ DescriptorVK descriptor = null;
		if (frameBufferDesc.colorAttachmentNum > 0)
			descriptor = ((DescriptorVK)frameBufferDesc.colorAttachments[0]);
		else if (frameBufferDesc.depthStencilAttachment != null)
			descriptor = (DescriptorVK)frameBufferDesc.depthStencilAttachment;

		VkExtent3D extent = .();

		if (descriptor != null)
		{
			readonly TextureVK texture = descriptor.GetTexture();
			readonly ref DescriptorTextureDesc descriptorDesc = ref descriptor.GetTextureDesc();

			extent.width = texture.GetSize(0, descriptorDesc.imageMipOffset);
			extent.height = texture.GetSize(1, descriptorDesc.imageMipOffset);
			extent.depth = descriptorDesc.imageArraySize;
		}

		m_RenderArea = .() { offset = .(), extent = .() { width = extent.width, height = extent.height } };
		m_AttachmentNum = frameBufferDesc.colorAttachmentNum + (frameBufferDesc.depthStencilAttachment != null ? 1 : 0);

		Result result = SaveClearColors(frameBufferDesc);
		if (result != Result.SUCCESS)
			return result;

		result = CreateRenderPass(frameBufferDesc);
		if (result != Result.SUCCESS)
			return result;

		VkImageView[ATTACHMENT_MAX_NUM] imageViews = .();

		VkFramebufferCreateInfo framebufferInfo = .()
			{
				sType = .VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
				pNext = null,
				flags = (VkFramebufferCreateFlags)0,
				renderPass = m_RenderPass,
				attachmentCount = m_AttachmentNum,
				pAttachments = &imageViews,
				width = m_RenderArea.extent.width,
				height = m_RenderArea.extent.height,
				layers = 1
			};

		readonly uint32 physicalDeviceMask = GetPhysicalDeviceGroupMask(frameBufferDesc.physicalDeviceMask);

		for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
		{
			if ((1 << i) & physicalDeviceMask != 0)
			{
				for (uint32 j = 0; j < frameBufferDesc.colorAttachmentNum; j++)
				{
					readonly DescriptorVK descriptorImpl = (DescriptorVK)frameBufferDesc.colorAttachments[j];
					imageViews[j] = descriptorImpl.GetImageView(i);
				}

				if (frameBufferDesc.depthStencilAttachment != null)
				{
					readonly DescriptorVK descriptorImpl = (DescriptorVK)frameBufferDesc.depthStencilAttachment;
					imageViews[frameBufferDesc.colorAttachmentNum] = descriptorImpl.GetImageView(i);
				}

				readonly VkResult res = VulkanNative.vkCreateFramebuffer(m_Device, &framebufferInfo, m_Device.GetAllocationCallbacks(), &m_Handles[i]);
				RETURN_ON_FAILURE!(m_Device.GetLogger(), res == .VK_SUCCESS, GetReturnCode(res),
					"Can't create a frame buffer: vkCreateFramebuffer returned {0}.", (int32)res);
			}
		}

		return Result.SUCCESS;
	}

	public VkFramebuffer GetHandle(uint32 physicalDeviceIndex) => m_Handles[physicalDeviceIndex];
	public readonly ref VkRect2D GetRenderArea() => ref m_RenderArea;
	public VkRenderPass GetRenderPass(RenderPassBeginFlag renderPassBeginFlag) => (renderPassBeginFlag == RenderPassBeginFlag.SKIP_FRAME_BUFFER_CLEAR) ? m_RenderPass : m_RenderPassWithClear;
	public uint32 GetAttachmentNum() => m_AttachmentNum;
	public void GetClearValues(VkClearValue* values)
	{
		Internal.MemCpy(values, &m_ClearValues, m_AttachmentNum * sizeof(VkClearValue));
	}

	public void SetDebugName(char8* name)
	{
		uint64[PHYSICAL_DEVICE_GROUP_MAX_SIZE] handles = .();
		for (uint i = 0; i < handles.Count; i++)
			handles[i] = (uint64)m_Handles[i];

		m_Device.SetDebugNameToDeviceGroupObject(.VK_OBJECT_TYPE_FRAMEBUFFER, &handles, name);
		m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_RENDER_PASS, (uint64)m_RenderPass, name);
		m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_RENDER_PASS, (uint64)m_RenderPassWithClear, name);
	}
}