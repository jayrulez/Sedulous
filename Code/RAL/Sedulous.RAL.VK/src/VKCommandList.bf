using Bulkan;
using System;
using System.Collections;
namespace Sedulous.RAL.VK;

static
{
	public static VkStridedDeviceAddressRegionKHR GetStridedDeviceAddressRegion(VKDevice device, in RayTracingShaderTable table)
	{
		if (table.resource == null)
		{
			return default;
		}
		var vk_resource = table.resource.As<VKResource>();
		VkStridedDeviceAddressRegionKHR vk_table = .();
		vk_table.deviceAddress = VulkanNative.vkGetBufferDeviceAddress(device.GetDevice(), scope .()
			{
				sType = .VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
				buffer = vk_resource.buffer.res
			}) + table.offset;
		vk_table.size = table.size;
		vk_table.stride = table.stride;
		return vk_table;
	}

	public static VkIndexType GetVkIndexType(Format format)
	{
		VkFormat vk_format = (VkFormat)format;
		switch (vk_format) {
		case VkFormat.eR16Uint:
			return VkIndexType.VK_INDEX_TYPE_UINT16;
		case VkFormat.eR32Uint:
			return VkIndexType.VK_INDEX_TYPE_UINT32;
		default:
			Runtime.Assert(false);
			return default;
		}
	}

	public static VkPipelineBindPoint GetPipelineBindPoint(PipelineType type)
	{
		switch (type) {
		case PipelineType.kGraphics:
			return VkPipelineBindPoint.eGraphics;
		case PipelineType.kCompute:
			return VkPipelineBindPoint.eCompute;
		case PipelineType.kRayTracing:
			return VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR;
		}
		//Runtime.Assert(false);
		//return default;
	}
}

class VKCommandList : CommandList
{
	private VKDevice m_device;
	private VkCommandBuffer m_command_list;
	private bool m_closed = false;
	private VKPipeline m_state;
	private BindingSet m_binding_set;

	public this(VKDevice device, CommandListType type)
	{
		m_device = device;

		VkCommandBufferAllocateInfo cmd_buf_alloc_info = .() { sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO };
		cmd_buf_alloc_info.commandPool = device.GetCmdPool(type);
		cmd_buf_alloc_info.commandBufferCount = 1;
		cmd_buf_alloc_info.level = VkCommandBufferLevel.ePrimary;
		VulkanNative.vkAllocateCommandBuffers(device.GetDevice(), &cmd_buf_alloc_info, &m_command_list);
		VkCommandBufferBeginInfo begin_info = .() { sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
		VulkanNative.vkBeginCommandBuffer(m_command_list, &begin_info);
	}

	public override void Reset()
	{
		Close();
		VkCommandBufferBeginInfo begin_info = .() { sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
		VulkanNative.vkBeginCommandBuffer(m_command_list, &begin_info);
		m_closed = false;
		m_state = null;
		m_binding_set = null;
	}

	public override void Close()
	{
		if (!m_closed)
		{
			VulkanNative.vkEndCommandBuffer(m_command_list);
			m_closed = true;
		}
	}

	public override void BindPipeline(Pipeline state)
	{
		if (state == m_state)
		{
			return;
		}
		m_state = state.As<VKPipeline>();
		VulkanNative.vkCmdBindPipeline(m_command_list, GetPipelineBindPoint(m_state.GetPipelineType()), m_state.GetPipeline());
	}

	public override void BindBindingSet(BindingSet binding_set)
	{
		if (binding_set == m_binding_set)
		{
			return;
		}
		m_binding_set = binding_set;
		VKBindingSet vk_binding_set = binding_set.As<VKBindingSet>();
		readonly ref List<VkDescriptorSet> descriptor_sets = ref vk_binding_set.GetDescriptorSets();
		if (descriptor_sets.IsDynAlloc)
		{
			return;
		}
		VulkanNative.vkCmdBindDescriptorSets(m_command_list, GetPipelineBindPoint(m_state.GetPipelineType()), m_state.GetPipelineLayout(),
			0, (uint32)descriptor_sets.Count, descriptor_sets.Ptr, 0, null);
	}

	public override void BeginRenderPass(RenderPass render_pass, Framebuffer framebuffer, in ClearDesc clear_desc)
	{
		VKFramebuffer vk_framebuffer = framebuffer.As<VKFramebuffer>();
		VKRenderPass vk_render_pass = render_pass.As<VKRenderPass>();
		VkRenderPassBeginInfo render_pass_info = .() { sType = .VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO };
		render_pass_info.renderPass = vk_render_pass.GetRenderPass();
		render_pass_info.framebuffer = vk_framebuffer.GetFramebuffer();
		render_pass_info.renderArea.extent = vk_framebuffer.GetExtent();
		List<VkClearValue> clear_values = scope .();
		for (var color in clear_desc.colors)
		{
			VkClearValue clear_value = .();
			clear_value.color.float32[0] = color.X;
			clear_value.color.float32[1] = color.Y;
			clear_value.color.float32[2] = color.Z;
			clear_value.color.float32[3] = color.W;
			clear_values.Add(clear_value);
		}
		clear_values.Resize(vk_render_pass.GetDesc().colors.Count);
		if (vk_render_pass.GetDesc().depth_stencil.format != Format.FORMAT_UNDEFINED)
		{
			VkClearValue clear_value = .();
			clear_value.depthStencil.depth = clear_desc.depth;
			clear_value.depthStencil.stencil = clear_desc.stencil;
			clear_values.Add(clear_value);
		}
		render_pass_info.clearValueCount = (uint32)clear_values.Count;
		render_pass_info.pClearValues = clear_values.Ptr;
		VulkanNative.vkCmdBeginRenderPass(m_command_list, &render_pass_info, VkSubpassContents.eInline);
	}

	public override void EndRenderPass()
	{
		VulkanNative.vkCmdEndRenderPass(m_command_list);
	}

	public override void BeginEvent(System.String name)
	{
		if (m_device.GetAdapter().GetInstance().IsDebugUtilsSupported())
		{
			VkDebugUtilsLabelEXT label = .() { sType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_LABEL_EXT };
			label.pLabelName = name;
			VulkanNative.vkCmdBeginDebugUtilsLabelEXT(m_command_list, &label);
		}
	}

	public override void EndEvent()
	{
		if (m_device.GetAdapter().GetInstance().IsDebugUtilsSupported())
		{
			VulkanNative.vkCmdEndDebugUtilsLabelEXT(m_command_list);
		}
	}

	public override void Draw(uint32 vertex_count, uint32 instance_count, uint32 first_vertex, uint32 first_instance)
	{
		VulkanNative.vkCmdDraw(m_command_list, vertex_count, instance_count, first_vertex, first_instance);
	}

	public override void DrawIndexed(uint32 index_count, uint32 instance_count, uint32 first_index, int32 vertex_offset, uint32 first_instance)
	{
		VulkanNative.vkCmdDrawIndexed(m_command_list, index_count, instance_count, first_index, vertex_offset, first_instance);
	}

	public override void DrawIndirect(Resource argument_buffer, uint64 argument_buffer_offset)
	{
		DrawIndirectCount(argument_buffer, argument_buffer_offset, default, 0, 1, sizeof(DrawIndirectCommand));
	}

	public override void DrawIndexedIndirect(Resource argument_buffer, uint64 argument_buffer_offset)
	{
		DrawIndexedIndirectCount(argument_buffer, argument_buffer_offset, default, 0, 1, sizeof(DrawIndexedIndirectCommand));
	}

	public override void DrawIndirectCount(Resource argument_buffer, uint64 argument_buffer_offset, Resource count_buffer, uint64 count_buffer_offset, uint32 max_draw_count, uint32 stride)
	{
		VKResource vk_argument_buffer = argument_buffer.As<VKResource>();
		if (count_buffer != null)
		{
			VKResource vk_count_buffer = count_buffer.As<VKResource>();
			VulkanNative.vkCmdDrawIndirectCount(m_command_list, vk_argument_buffer.buffer.res, argument_buffer_offset,
				vk_count_buffer.buffer.res, count_buffer_offset, max_draw_count,
				stride);
		} else
		{
			Runtime.Assert(count_buffer_offset == 0);
			VulkanNative.vkCmdDrawIndirect(m_command_list, vk_argument_buffer.buffer.res, argument_buffer_offset, max_draw_count,
				stride);
		}
	}

	public override void DrawIndexedIndirectCount(Resource argument_buffer, uint64 argument_buffer_offset, Resource count_buffer, uint64 count_buffer_offset, uint32 max_draw_count, uint32 stride)
	{
		VKResource vk_argument_buffer = argument_buffer.As<VKResource>();
		if (count_buffer != null)
		{
			VKResource vk_count_buffer = count_buffer.As<VKResource>();
			VulkanNative.vkCmdDrawIndexedIndirectCount(m_command_list, vk_argument_buffer.buffer.res, argument_buffer_offset,
				vk_count_buffer.buffer.res, count_buffer_offset, max_draw_count,
				stride);
		} else
		{
			Runtime.Assert(count_buffer_offset == 0);
			VulkanNative.vkCmdDrawIndexedIndirect(m_command_list, vk_argument_buffer.buffer.res, argument_buffer_offset, max_draw_count,
				stride);
		}
	}

	public override void Dispatch(uint32 thread_group_count_x, uint32 thread_group_count_y, uint32 thread_group_count_z)
	{
		VulkanNative.vkCmdDispatch(m_command_list, thread_group_count_x, thread_group_count_y, thread_group_count_z);
	}

	public override void DispatchIndirect(Resource argument_buffer, uint64 argument_buffer_offset)
	{
		VKResource vk_argument_buffer = argument_buffer.As<VKResource>();
		VulkanNative.vkCmdDispatchIndirect(m_command_list, vk_argument_buffer.buffer.res, argument_buffer_offset);
	}

	public override void DispatchMesh(uint32 thread_group_count_x)
	{
		VulkanNative.vkCmdDrawMeshTasksNV(m_command_list, thread_group_count_x, 0);
	}

	public override void DispatchRays(in RayTracingShaderTables shader_tables, uint32 width, uint32 height, uint32 depth)
	{
		VkStridedDeviceAddressRegionKHR raygen = GetStridedDeviceAddressRegion(m_device, shader_tables.raygen);
		VkStridedDeviceAddressRegionKHR miss = GetStridedDeviceAddressRegion(m_device, shader_tables.miss);
		VkStridedDeviceAddressRegionKHR hit = GetStridedDeviceAddressRegion(m_device, shader_tables.hit);
		VkStridedDeviceAddressRegionKHR callable = GetStridedDeviceAddressRegion(m_device, shader_tables.callable);
		VulkanNative.vkCmdTraceRaysKHR(
			m_command_list,
			&raygen,
			&miss,
			&hit,
			&callable,
			width,
			height,
			depth
			);
	}

	public override void ResourceBarrier(System.Span<ResourceBarrierDesc> barriers)
	{
		List<VkImageMemoryBarrier> image_memory_barriers = scope .();
		for (var barrier in barriers)
		{
			if (barrier.resource == null)
			{
				Runtime.Assert(false);
				continue;
			}

			VKResource vk_resource = barrier.resource.As<VKResource>();
			ref VKResource.Image image = ref vk_resource.image;
			if (image.res == .Null)
			{
				continue;
			}

			VkImageLayout vk_state_before = ConvertState(barrier.state_before);
			VkImageLayout vk_state_after = ConvertState(barrier.state_after);
			if (vk_state_before == vk_state_after)
			{
				continue;
			}

			VkImageMemoryBarrier image_memory_barrier = .() { sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER };
			image_memory_barrier.oldLayout = vk_state_before;
			image_memory_barrier.newLayout = vk_state_after;
			image_memory_barrier.srcQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED;
			image_memory_barrier.dstQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED;
			image_memory_barrier.image = image.res;

			ref VkImageSubresourceRange range = ref image_memory_barrier.subresourceRange;
			range.aspectMask = m_device.GetAspectFlags(image.format);
			range.baseMipLevel = barrier.base_mip_level;
			range.levelCount = barrier.level_count;
			range.baseArrayLayer = barrier.base_array_layer;
			range.layerCount = barrier.layer_count;

			// Source layouts (old)
			// Source access mask controls actions that have to be finished on the old layout
			// before it will be transitioned to the new layout
			switch (image_memory_barrier.oldLayout) {
			case VkImageLayout.eUndefined:
				// Image layout is undefined (or does not matter)
				// Only valid as initial layout
				// No flags required, listed only for completeness
				image_memory_barrier.srcAccessMask = .();
				break;
			case VkImageLayout.ePreinitialized:
				// Image is preinitialized
				// Only valid as initial layout for linear images, preserves memory contents
				// Make sure host writes have been finished
				image_memory_barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_HOST_WRITE_BIT;
				break;
			case VkImageLayout.eColorAttachmentOptimal:
				// Image is a color attachment
				// Make sure any writes to the color buffer have been finished
				image_memory_barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
				break;
			case VkImageLayout.eDepthAttachmentOptimal:
				// Image is a depth/stencil attachment
				// Make sure any writes to the depth/stencil buffer have been finished
				image_memory_barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
				break;
			case VkImageLayout.eTransferSrcOptimal:
				// Image is a transfer source
				// Make sure any reads from the image have been finished
				image_memory_barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
				break;
			case VkImageLayout.eTransferDstOptimal:
				// Image is a transfer destination
				// Make sure any writes to the image have been finished
				image_memory_barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
				break;

			case VkImageLayout.eShaderReadOnlyOptimal:
				// Image is read by a shader
				// Make sure any shader reads from the image have been finished
				image_memory_barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR:
				image_memory_barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR;
			default:
				// Other source layouts aren't handled (yet)
				break;
			}

			// Target layouts (new)
			// Destination access mask controls the dependency for the new image layout
			switch (image_memory_barrier.newLayout) {
			case VkImageLayout.eTransferDstOptimal:
				// Image will be used as a transfer destination
				// Make sure any writes to the image have been finished
				image_memory_barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
				break;

			case VkImageLayout.eTransferSrcOptimal:
				// Image will be used as a transfer source
				// Make sure any reads from the image have been finished
				image_memory_barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
				break;

			case VkImageLayout.eColorAttachmentOptimal:
				// Image will be used as a color attachment
				// Make sure any writes to the color buffer have been finished
				image_memory_barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
				break;

			case VkImageLayout.eDepthAttachmentOptimal:
				// Image layout will be used as a depth/stencil attachment
				// Make sure any writes to depth/stencil buffer have been finished
				image_memory_barrier.dstAccessMask =
					image_memory_barrier.dstAccessMask | VkAccessFlags.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
				break;

			case VkImageLayout.eShaderReadOnlyOptimal:
				// Image will be read in a shader (sampler, input attachment)
				// Make sure any writes to the image have been finished
				if (image_memory_barrier.srcAccessMask == .VK_ACCESS_NONE)
				{
					image_memory_barrier.srcAccessMask =
						VkAccessFlags.VK_ACCESS_HOST_WRITE_BIT | VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
				}
				image_memory_barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
				break;
			case VkImageLayout.VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR:
				image_memory_barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR;
				break;
			default:
				// Other source layouts aren't handled (yet)
				break;
			}

			image_memory_barriers.Add(image_memory_barrier);
		}

		if (!image_memory_barriers.IsEmpty)
		{
			VulkanNative.vkCmdPipelineBarrier(m_command_list, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT,
				VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT, 0,
				null, 0, null, (uint32)image_memory_barriers.Count,
				image_memory_barriers.Ptr);
		}
	}

	public override void UAVResourceBarrier(Resource resource)
	{
		VkMemoryBarrier memory_barrier = .() { sType = .VK_STRUCTURE_TYPE_MEMORY_BARRIER };
		memory_barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR |
			VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR |
			VkAccessFlags.VK_ACCESS_SHADER_WRITE_BIT | VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
		memory_barrier.dstAccessMask = memory_barrier.srcAccessMask;
		VulkanNative.vkCmdPipelineBarrier(m_command_list, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT,
			VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT, 1, &memory_barrier, 0, null, 0, null);
	}

	public override void SetViewport(float x, float y, float width, float height)
	{
		VkViewport viewport = .();
		viewport.x = 0;
		viewport.y = height - y;
		viewport.width = width;
		viewport.height = -height;
		viewport.minDepth = 0;
		viewport.maxDepth = 1.0f;
		VulkanNative.vkCmdSetViewport(m_command_list, 0, 1, &viewport);
	}

	public override void SetScissorRect(int32 left, int32 top, uint32 right, uint32 bottom)
	{
		VkRect2D rect = .();
		rect.offset.x = left;
		rect.offset.y = top;
		rect.extent.width = right;
		rect.extent.height = bottom;
		VulkanNative.vkCmdSetScissor(m_command_list, 0, 1, &rect);
	}

	public override void IASetIndexBuffer(Resource resource, Format format)
	{
		VKResource vk_resource = resource.As<VKResource>();
		VkIndexType index_type = GetVkIndexType(format);
		VulkanNative.vkCmdBindIndexBuffer(m_command_list, vk_resource.buffer.res, 0, index_type);
	}

	public override void IASetVertexBuffer(uint32 slot, Resource resource)
	{
		VKResource vk_resource = resource.As<VKResource>();
		VkBuffer[] vertex_buffers = scope .(vk_resource.buffer.res);
		uint64[] offsets = scope .(0);
		VulkanNative.vkCmdBindVertexBuffers(m_command_list, slot, 1, vertex_buffers.Ptr, offsets.Ptr);
	}

	public override void RSSetShadingRate(ShadingRate shading_rate, ShadingRateCombiner[2] combiners)
	{
		VkExtent2D fragment_size = .(1, 1);
		switch (shading_rate) {
		case ShadingRate.k1x1:
			fragment_size.width = 1;
			fragment_size.height = 1;
			break;
		case ShadingRate.k1x2:
			fragment_size.width = 1;
			fragment_size.height = 2;
			break;
		case ShadingRate.k2x1:
			fragment_size.width = 2;
			fragment_size.height = 1;
			break;
		case ShadingRate.k2x2:
			fragment_size.width = 2;
			fragment_size.height = 2;
			break;
		case ShadingRate.k2x4:
			fragment_size.width = 2;
			fragment_size.height = 4;
			break;
		case ShadingRate.k4x2:
			fragment_size.width = 4;
			fragment_size.height = 2;
			break;
		case ShadingRate.k4x4:
			fragment_size.width = 4;
			fragment_size.height = 4;
			break;
		default:
			Runtime.Assert(false);
			break;
		}

		VkFragmentShadingRateCombinerOpKHR[2] vk_combiners = .();
		for (uint i = 0; i < vk_combiners.Count; ++i)
		{
			switch (combiners[i]) {
			case ShadingRateCombiner.kPassthrough:
				vk_combiners[i] = VkFragmentShadingRateCombinerOpKHR.VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR;
				break;
			case ShadingRateCombiner.kOverride:
				vk_combiners[i] = VkFragmentShadingRateCombinerOpKHR.VK_FRAGMENT_SHADING_RATE_COMBINER_OP_REPLACE_KHR;
				break;
			case ShadingRateCombiner.kMin:
				vk_combiners[i] = VkFragmentShadingRateCombinerOpKHR.VK_FRAGMENT_SHADING_RATE_COMBINER_OP_MIN_KHR;
				break;
			case ShadingRateCombiner.kMax:
				vk_combiners[i] = VkFragmentShadingRateCombinerOpKHR.VK_FRAGMENT_SHADING_RATE_COMBINER_OP_MAX_KHR;
				break;
			case ShadingRateCombiner.kSum:
				vk_combiners[i] = VkFragmentShadingRateCombinerOpKHR.VK_FRAGMENT_SHADING_RATE_COMBINER_OP_MUL_KHR;
				break;
			default:
				Runtime.Assert(false);
				break;
			}
		}

		VulkanNative.vkCmdSetFragmentShadingRateKHR(m_command_list, &fragment_size, vk_combiners);
	}

	public override void BuildBottomLevelAS(Resource src, Resource dst, Resource scratch, uint64 scratch_offset, System.Span<RaytracingGeometryDesc> descs, BuildAccelerationStructureFlags flags)
	{
		List<VkAccelerationStructureGeometryKHR> geometry_descs = scope .();
		for (var desc in descs)
		{
			geometry_descs.Add(m_device.FillRaytracingGeometryTriangles(desc.vertex, desc.index, desc.flags));
		}

		VKResource vk_dst = dst.As<VKResource>();
		VKResource vk_scratch = scratch.As<VKResource>();

		VkAccelerationStructureKHR vk_src_as = .Null;
		if (src != null)
		{
			VKResource vk_src = src.As<VKResource>();
			vk_src_as = vk_src.acceleration_structure_handle;
		}

		List<VkAccelerationStructureBuildRangeInfoKHR> ranges = scope .();
		for (var desc in descs)
		{
			VkAccelerationStructureBuildRangeInfoKHR offset = .();
			if (desc.index.res != null)
			{
				offset.primitiveCount = desc.index.count / 3;
			} else
			{
				offset.primitiveCount = desc.vertex.count / 3;
			}
			ranges.Add(offset);
		}
		List<VkAccelerationStructureBuildRangeInfoKHR*> range_infos = scope .() { Count = ranges.Count };
		for (int i = 0; i < ranges.Count; ++i)
		{
			range_infos[i] = &ranges[i];
		}

		VkAccelerationStructureBuildGeometryInfoKHR infos = .() { sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR };
		infos.type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR;
		infos.flags = Convert(flags);
		infos.dstAccelerationStructure = vk_dst.acceleration_structure_handle;
		infos.srcAccelerationStructure = vk_src_as;
		if (vk_src_as != .Null)
		{
			infos.mode = VkBuildAccelerationStructureModeKHR.VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR;
		} else
		{
			infos.mode = VkBuildAccelerationStructureModeKHR.VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR;
		}
		infos.scratchData.deviceAddress = VulkanNative.vkGetBufferDeviceAddress(m_device.GetDevice(), scope .()
			{
				sType = .VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
				buffer = vk_scratch.buffer.res
			}) + scratch_offset;
		infos.pGeometries = geometry_descs.Ptr;
		infos.geometryCount = (uint32)geometry_descs.Count;

		VulkanNative.vkCmdBuildAccelerationStructuresKHR(m_command_list, 1, &infos, range_infos.Ptr);
	}

	public override void BuildTopLevelAS(Resource src, Resource dst, Resource scratch, uint64 scratch_offset, Resource instance_data, uint64 instance_offset, uint32 instance_count, BuildAccelerationStructureFlags flags)
	{
		VKResource vk_instance_data = instance_data.As<VKResource>();
		VkDeviceAddress instance_address = .();
		instance_address = VulkanNative.vkGetBufferDeviceAddress(m_device.GetDevice(), scope .()
			{
				sType = .VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
				buffer = vk_instance_data.buffer.res
			}) + instance_offset;
		VkAccelerationStructureGeometryKHR top_as_geometry = .() { sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR };
		top_as_geometry.geometryType = VkGeometryTypeKHR.VK_GEOMETRY_TYPE_INSTANCES_KHR;
		top_as_geometry.geometry.instances = .() { sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR };
		top_as_geometry.geometry.instances.arrayOfPointers = VulkanNative.VK_FALSE;
		top_as_geometry.geometry.instances.data.deviceAddress = instance_address;

		VKResource vk_dst = dst.As<VKResource>();
		VKResource vk_scratch = scratch.As<VKResource>();

		VkAccelerationStructureKHR vk_src_as = .Null;
		if (src != null)
		{
			VKResource vk_src = src.As<VKResource>();
			vk_src_as = vk_src.acceleration_structure_handle;
		}

		VkAccelerationStructureBuildRangeInfoKHR acceleration_structure_build_range_info = .();
		acceleration_structure_build_range_info.primitiveCount = instance_count;
		List<VkAccelerationStructureBuildRangeInfoKHR*> offset_infos = scope .()
			{
				&acceleration_structure_build_range_info
			};

		VkAccelerationStructureBuildGeometryInfoKHR infos = .() { sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR };
		infos.type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR;
		infos.flags = Convert(flags);
		infos.dstAccelerationStructure = vk_dst.acceleration_structure_handle;
		infos.srcAccelerationStructure = vk_src_as;
		if (vk_src_as != .Null)
		{
			infos.mode = VkBuildAccelerationStructureModeKHR.VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR;
		} else
		{
			infos.mode = VkBuildAccelerationStructureModeKHR.VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR;
		}
		infos.scratchData.deviceAddress = VulkanNative.vkGetBufferDeviceAddress(m_device.GetDevice(), scope .()
			{
				sType = .VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
				buffer = vk_scratch.buffer.res
			}) + scratch_offset;
		infos.pGeometries = &top_as_geometry;
		infos.geometryCount = 1;

		VulkanNative.vkCmdBuildAccelerationStructuresKHR(m_command_list, 1, &infos, offset_infos.Ptr);
	}

	public override void CopyAccelerationStructure(Resource src, Resource dst, CopyAccelerationStructureMode mode)
	{
		VKResource vk_src = src.As<VKResource>();
		VKResource vk_dst = dst.As<VKResource>();
		VkCopyAccelerationStructureInfoKHR info = .() { sType = .VK_STRUCTURE_TYPE_COPY_ACCELERATION_STRUCTURE_INFO_KHR };
		switch (mode) {
		case CopyAccelerationStructureMode.kClone:
			info.mode = VkCopyAccelerationStructureModeKHR.VK_COPY_ACCELERATION_STRUCTURE_MODE_CLONE_KHR;
			break;
		case CopyAccelerationStructureMode.kCompact:
			info.mode = VkCopyAccelerationStructureModeKHR.VK_COPY_ACCELERATION_STRUCTURE_MODE_COMPACT_KHR;
			break;
		default:
			Runtime.Assert(false);
			info.mode = VkCopyAccelerationStructureModeKHR.VK_COPY_ACCELERATION_STRUCTURE_MODE_CLONE_KHR;
			break;
		}
		info.dst = vk_dst.acceleration_structure_handle;
		info.src = vk_src.acceleration_structure_handle;
		VulkanNative.vkCmdCopyAccelerationStructureKHR(m_command_list, &info);
	}

	public override void CopyBuffer(Resource src_buffer, Resource dst_buffer, System.Span<BufferCopyRegion> regions)
	{
		VKResource vk_src_buffer = src_buffer.As<VKResource>();
		VKResource vk_dst_buffer = dst_buffer.As<VKResource>();
		List<VkBufferCopy> vk_regions = scope .();
		for (var region in regions)
		{
			vk_regions..Add(.() { srcOffset = region.src_offset, dstOffset = region.dst_offset, size = region.num_bytes });
		}
		VulkanNative.vkCmdCopyBuffer(m_command_list, vk_src_buffer.buffer.res, vk_dst_buffer.buffer.res, (uint32)vk_regions.Count, vk_regions.Ptr);
	}

	public override void CopyBufferToTexture(Resource src_buffer, Resource dst_texture, System.Span<BufferToTextureCopyRegion> regions)
	{
		VKResource vk_src_buffer = src_buffer.As<VKResource>();
		VKResource vk_dst_texture = dst_texture.As<VKResource>();
		List<VkBufferImageCopy> vk_regions = scope .();
		var format = dst_texture.GetFormat();
		for (var region in regions)
		{
			VkBufferImageCopy vk_region = .();
			vk_region.bufferOffset = region.buffer_offset;
			if (format.IsCompressed())
			{
				var extent = format.GetBlockExtent();
				vk_region.bufferRowLength = region.buffer_row_pitch / (uint32)format.GetBlockSize() * extent.X;
				vk_region.bufferImageHeight =
					((region.texture_extent.height + format.GetBlockExtent().Y - 1) / format.GetBlockExtent().Y) *
					extent.X;
			} else
			{
				vk_region.bufferRowLength = region.buffer_row_pitch / format.GetBytesPerPixel();
				vk_region.bufferImageHeight = region.texture_extent.height;
			}
			vk_region.imageSubresource.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
			vk_region.imageSubresource.mipLevel = region.texture_mip_level;
			vk_region.imageSubresource.baseArrayLayer = region.texture_array_layer;
			vk_region.imageSubresource.layerCount = 1;
			vk_region.imageOffset.x = region.texture_offset.x;
			vk_region.imageOffset.y = region.texture_offset.y;
			vk_region.imageOffset.z = region.texture_offset.z;
			vk_region.imageExtent.width = region.texture_extent.width;
			vk_region.imageExtent.height = region.texture_extent.height;
			vk_region.imageExtent.depth = region.texture_extent.depth;

			vk_regions.Add(vk_region);
		}
		VulkanNative.vkCmdCopyBufferToImage(m_command_list, vk_src_buffer.buffer.res, vk_dst_texture.image.res,
			VkImageLayout.eTransferDstOptimal, (uint32)vk_regions.Count, vk_regions.Ptr);
	}

	public override void CopyTexture(Resource src_texture, Resource dst_texture, System.Span<TextureCopyRegion> regions)
	{
		VKResource vk_src_texture = src_texture.As<VKResource>();
		VKResource vk_dst_texture = dst_texture.As<VKResource>();
		List<VkImageCopy> vk_regions = scope .();
		for (var region in regions)
		{
			VkImageCopy vk_region = .();
			vk_region.srcSubresource.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
			vk_region.srcSubresource.mipLevel = region.src_mip_level;
			vk_region.srcSubresource.baseArrayLayer = region.src_array_layer;
			vk_region.srcSubresource.layerCount = 1;
			vk_region.srcOffset.x = region.src_offset.x;
			vk_region.srcOffset.y = region.src_offset.y;
			vk_region.srcOffset.z = region.src_offset.z;

			vk_region.dstSubresource.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
			vk_region.dstSubresource.mipLevel = region.dst_mip_level;
			vk_region.dstSubresource.baseArrayLayer = region.dst_array_layer;
			vk_region.dstSubresource.layerCount = 1;
			vk_region.dstOffset.x = region.dst_offset.x;
			vk_region.dstOffset.y = region.dst_offset.y;
			vk_region.dstOffset.z = region.dst_offset.z;

			vk_region.extent.width = region.extent.width;
			vk_region.extent.height = region.extent.height;
			vk_region.extent.depth = region.extent.depth;

			vk_regions.Add(vk_region);
		}
		VulkanNative.vkCmdCopyImage(m_command_list, vk_src_texture.image.res, VkImageLayout.eTransferSrcOptimal, vk_dst_texture.image.res,
			VkImageLayout.eTransferDstOptimal, (uint32)vk_regions.Count, vk_regions.Ptr);
	}

	public override void WriteAccelerationStructuresProperties(in System.Collections.List<Resource> acceleration_structures, QueryHeap query_heap, uint32 first_query)
	{
		List<VkAccelerationStructureKHR> vk_acceleration_structures = scope .();
		vk_acceleration_structures.Reserve(acceleration_structures.Count);
		for (var acceleration_structure in acceleration_structures)
		{
			vk_acceleration_structures.Add(acceleration_structure.As<VKResource>().acceleration_structure_handle);
		}
		VKQueryHeap vk_query_heap = query_heap.As<VKQueryHeap>();
		var query_type = vk_query_heap.GetQueryType();
		Runtime.Assert(query_type == VkQueryType.VK_QUERY_TYPE_ACCELERATION_STRUCTURE_COMPACTED_SIZE_KHR);
		VulkanNative.vkCmdResetQueryPool(m_command_list, vk_query_heap.GetQueryPool(), first_query, (uint32)acceleration_structures.Count);
		VulkanNative.vkCmdWriteAccelerationStructuresPropertiesKHR(m_command_list, (uint32)vk_acceleration_structures.Count,
			vk_acceleration_structures.Ptr, query_type,
			vk_query_heap.GetQueryPool(), first_query);
	}

	public override void ResolveQueryData(QueryHeap query_heap, uint32 first_query, uint32 query_count, Resource dst_buffer, uint64 dst_offset)
	{
		VKQueryHeap vk_query_heap = query_heap.As<VKQueryHeap>();
		var query_type = vk_query_heap.GetQueryType();
		Runtime.Assert(query_type == VkQueryType.VK_QUERY_TYPE_ACCELERATION_STRUCTURE_COMPACTED_SIZE_KHR);
		VulkanNative.vkCmdCopyQueryPoolResults(m_command_list, vk_query_heap.GetQueryPool(), first_query, query_count,
			dst_buffer.As<VKResource>().buffer.res, dst_offset, sizeof(uint64),
			VkQueryResultFlags.VK_QUERY_RESULT_WAIT_BIT);
	}

	public VkCommandBuffer GetCommandList()
	{
		return m_command_list;
	}

	/*private void BuildAccelerationStructure(ref VkAccelerationStructureCreateInfoKHR build_info,
		in VkBuffer instance_data,
		uint64 instance_offset,
		in Resource src,
		in Resource dst,
		in Resource scratch,
		uint64 scratch_offset){

		}*/
}