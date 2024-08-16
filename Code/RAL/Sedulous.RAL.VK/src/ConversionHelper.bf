using Bulkan;
using System;
namespace Sedulous.RAL.VK;

static
{
	public static VkImageLayout ConvertState(ResourceState state)
	{
		(ResourceState key, VkImageLayout value)[?] mapping = .(
			(ResourceState.kCommon, VkImageLayout.eGeneral),
			(ResourceState.kRenderTarget, VkImageLayout.eColorAttachmentOptimal),
			(ResourceState.kUnorderedAccess, VkImageLayout.eGeneral),
			(ResourceState.kDepthStencilWrite, VkImageLayout.eDepthStencilAttachmentOptimal),
			(ResourceState.kDepthStencilRead, VkImageLayout.eDepthStencilReadOnlyOptimal),
			(ResourceState.kNonPixelShaderResource, VkImageLayout.eShaderReadOnlyOptimal),
			(ResourceState.kPixelShaderResource, VkImageLayout.eShaderReadOnlyOptimal),
			(ResourceState.kCopyDest, VkImageLayout.eTransferDstOptimal),
			(ResourceState.kCopySource, VkImageLayout.eTransferSrcOptimal),
			(ResourceState.kShadingRateSource, VkImageLayout.VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR),
			(ResourceState.kPresent, VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR),
			(ResourceState.kUndefined, VkImageLayout.eUndefined)
			);
		for (var m in mapping)
		{
			if (state & m.key != 0)
			{
				Runtime.Assert(state == m.key);
				return m.value;
			}
		}
		Runtime.Assert(false);
		return VkImageLayout.eGeneral;
	}

	public static VkBuildAccelerationStructureFlagsKHR Convert(BuildAccelerationStructureFlags flags)
	{
		VkBuildAccelerationStructureFlagsKHR vk_flags = .();
		if (flags & BuildAccelerationStructureFlags.kAllowUpdate != 0)
		{
			vk_flags |= VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR;
		}
		if (flags & BuildAccelerationStructureFlags.kAllowCompaction != 0)
		{
			vk_flags |= VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_COMPACTION_BIT_KHR;
		}
		if (flags & BuildAccelerationStructureFlags.kPreferFastTrace != 0)
		{
			vk_flags |= VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR;
		}
		if (flags & BuildAccelerationStructureFlags.kPreferFastBuild != 0)
		{
			vk_flags |= VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_BUILD_BIT_KHR;
		}
		if (flags & BuildAccelerationStructureFlags.kMinimizeMemory != 0)
		{
			vk_flags |= VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_LOW_MEMORY_BIT_KHR;
		}
		return vk_flags;
	}
}