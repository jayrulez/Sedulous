using System;
using Bulkan;
using Sedulous.RHI.Raytracing;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;
using static Sedulous.RHI.Vulkan.VKHelpers;
namespace Sedulous.RHI.Vulkan;

/// <summary>
/// Vulkan Top Level Acceleration Structure implementation.
/// </summary>
public class VKTopLevelAS : TopLevelAS
{
	/// <summary>
	/// The top level acceleration structure instance.
	/// </summary>
	public VkAccelerationStructureKHR TopLevelAS;

	private uint64 topLevelASHandle;

	private VKRaytracingHelpers.BufferData instanceBuffer;

	private VkBuffer scratchBuffer;

	private VKGraphicsContext vkContext;

	/// <inheritdoc />
	public override void* NativePointer => (void*)(int)topLevelASHandle;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKTopLevelAS" /> class.
	/// </summary>
	/// <param name="context">DirectX12 Context.</param>
	/// <param name="commandBuffer">Command buffer.</param>
	/// <param name="description">Top Level Description.</param>
	public this(VKGraphicsContext context, VkCommandBuffer commandBuffer, ref TopLevelASDescription description)
		: base(context, ref description)
	{
		vkContext = context;
		VkAccelerationStructureInstanceKHR* instanceDescriptions = scope VkAccelerationStructureInstanceKHR[description.Instances.Count]*;
		for (int i = 0; i < description.Instances.Count; i++)
		{
			AccelerationStructureInstance instance = description.Instances[i];
			instanceDescriptions[i] = VkAccelerationStructureInstanceKHR()
			{
				transform = instance.Transform4x4.ToTransformMatrix(),
				instanceCustomIndex = instance.InstanceID,
				mask = instance.InstanceMask,
				instanceShaderBindingTableRecordOffset = instance.InstanceContributionToHitGroupIndex,
				flags = instance.Flags.ToVulkan(),
				accelerationStructureReference = (uint64)(int)(instance.BottonLevel as VKBottomLevelAS).NativePointer
			};
		}
		instanceBuffer = VKRaytracingHelpers.CreateMappedBuffer(vkContext, (void*)instanceDescriptions, (uint64)sizeof(VkAccelerationStructureInstanceKHR) * (uint64)description.Instances.Count, VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR);
		VkAccelerationStructureGeometryKHR geometryInfo = VkAccelerationStructureGeometryKHR()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
			flags = VkGeometryFlagsKHR.VK_GEOMETRY_OPAQUE_BIT_KHR,
			geometryType = VkGeometryTypeKHR.VK_GEOMETRY_TYPE_INSTANCES_KHR,
			geometry = VkAccelerationStructureGeometryDataKHR()
			{
				instances = VkAccelerationStructureGeometryInstancesDataKHR()
				{
					sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR,
					arrayOfPointers = false,
					data = VkDeviceOrHostAddressConstKHR()
					{
						deviceAddress = instanceBuffer.Buffer.GetBufferAddress(vkContext.VkDevice)
					}
				}
			}
		};
		VkAccelerationStructureBuildGeometryInfoKHR buildInfoSize = VkAccelerationStructureBuildGeometryInfoKHR()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
			type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR,
			mode = VkBuildAccelerationStructureModeKHR.VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR,
			flags = description.Flags.ToVulkan(),
			geometryCount = 1,
			pGeometries = &geometryInfo
		};
		VkAccelerationStructureBuildRangeInfoKHR* ranges = scope VkAccelerationStructureBuildRangeInfoKHR[1]*;
		ranges.primitiveCount = (uint32)description.Instances.Count;
		ranges.primitiveOffset = description.Offset;
		ranges.firstVertex = 0;
		ranges.transformOffset = 0;
		uint32 primitiveCount = (uint32)description.Instances.Count;
		VkAccelerationStructureBuildSizesInfoKHR sizeInfo = default(VkAccelerationStructureBuildSizesInfoKHR);
		sizeInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR;
		VulkanNative.vkGetAccelerationStructureBuildSizesKHR(vkContext.VkDevice, VkAccelerationStructureBuildTypeKHR.VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR, &buildInfoSize, &primitiveCount, &sizeInfo);
		VkBuffer resultBuffer = VKRaytracingHelpers.CreateBuffer(vkContext, sizeInfo.accelerationStructureSize, VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR).Buffer;
		VkAccelerationStructureCreateInfoKHR asInfo = VkAccelerationStructureCreateInfoKHR()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR,
			buffer = resultBuffer,
			size = sizeInfo.accelerationStructureSize,
			type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR
		};
		VkAccelerationStructureKHR newTopLevelAS = default(VkAccelerationStructureKHR);
		VulkanNative.vkCreateAccelerationStructureKHR(vkContext.VkDevice, &asInfo, null, &newTopLevelAS);
		TopLevelAS = newTopLevelAS;
		topLevelASHandle = TopLevelAS.GetAccelerationStructureAddress(vkContext.VkDevice);
		scratchBuffer = VKRaytracingHelpers.CreateBuffer(vkContext, sizeInfo.buildScratchSize, VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT).Buffer;
		VkAccelerationStructureBuildGeometryInfoKHR buildInfo = VkAccelerationStructureBuildGeometryInfoKHR()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
			type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR,
			flags = description.Flags.ToVulkan(),
			dstAccelerationStructure = TopLevelAS,
			geometryCount = 1,
			pGeometries = &geometryInfo,
			scratchData = VkDeviceOrHostAddressKHR()
			{
				deviceAddress = scratchBuffer.GetBufferAddress(vkContext.VkDevice)
			}
		};
		VulkanNative.vkCmdBuildAccelerationStructuresKHR(commandBuffer, buildInfo.geometryCount, &buildInfo, &ranges);
		VkMemoryBarrier memoryBarrier = VkMemoryBarrier()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_BARRIER,
			pNext = null,
			srcAccessMask = (VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR | VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR),
			dstAccessMask = (VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR | VkAccessFlags.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR)
		};
		VulkanNative.vkCmdPipelineBarrier(commandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR, VkPipelineStageFlags.VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR, VkDependencyFlags.None, 1, &memoryBarrier, 0, null, 0, null);
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKTopLevelAS" /> class.
	/// </summary>
	/// <param name="commandBuffer">Command Buffer instance.</param>
	/// <param name="description">New top level description.</param>
	public void UpdateAccelerationStructure(VkCommandBuffer commandBuffer, ref TopLevelASDescription description)
	{
		Description = description;
		VkAccelerationStructureInstanceKHR[] instanceDescriptions = new VkAccelerationStructureInstanceKHR[description.Instances.Count];
		for (int i = 0; i < description.Instances.Count; i++)
		{
			AccelerationStructureInstance instance = description.Instances[i];
			VkAccelerationStructureInstanceKHR instanceDesc = default(VkAccelerationStructureInstanceKHR);
			instanceDesc.transform = instance.Transform4x4.ToTransformMatrix();
			instanceDesc.instanceCustomIndex = instance.InstanceID;
			instanceDesc.mask = instance.InstanceMask;
			instanceDesc.instanceShaderBindingTableRecordOffset = instance.InstanceContributionToHitGroupIndex;
			instanceDesc.flags = instance.Flags.ToVulkan();
			instanceDesc.accelerationStructureReference = (uint64)(int)(instance.BottonLevel as VKBottomLevelAS).NativePointer;
			instanceDescriptions[i] = instanceDesc;
		}
		uint32 instanceSize = (uint32)(sizeof(VkAccelerationStructureInstanceKHR) * instanceDescriptions.Count);
		void* instanceBufferPointer = default(void*);
		VulkanNative.vkMapMemory(vkContext.VkDevice, instanceBuffer.Memory, 0UL, instanceSize, VkMemoryMapFlags.None, &instanceBufferPointer);
		Internal.MemCpy(instanceBufferPointer, (void*)instanceDescriptions.Ptr, instanceSize);
		VulkanNative.vkUnmapMemory(vkContext.VkDevice, instanceBuffer.Memory);
		VkAccelerationStructureGeometryKHR vkAccelerationStructureGeometryKHR = default(VkAccelerationStructureGeometryKHR);
		vkAccelerationStructureGeometryKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR;
		vkAccelerationStructureGeometryKHR.flags = VkGeometryFlagsKHR.VK_GEOMETRY_OPAQUE_BIT_KHR;
		vkAccelerationStructureGeometryKHR.geometryType = VkGeometryTypeKHR.VK_GEOMETRY_TYPE_INSTANCES_KHR;
		vkAccelerationStructureGeometryKHR.geometry = VkAccelerationStructureGeometryDataKHR()
		{
			instances = VkAccelerationStructureGeometryInstancesDataKHR()
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR,
				arrayOfPointers = false,
				data = VkDeviceOrHostAddressConstKHR()
				{
					deviceAddress = instanceBuffer.Buffer.GetBufferAddress(vkContext.VkDevice)
				}
			}
		};
		VkAccelerationStructureGeometryKHR geometryInfo = vkAccelerationStructureGeometryKHR;
		VkAccelerationStructureBuildGeometryInfoKHR vkAccelerationStructureBuildGeometryInfoKHR = default(VkAccelerationStructureBuildGeometryInfoKHR);
		vkAccelerationStructureBuildGeometryInfoKHR.sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
		vkAccelerationStructureBuildGeometryInfoKHR.type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR;
		vkAccelerationStructureBuildGeometryInfoKHR.flags = description.Flags.ToVulkan();
		vkAccelerationStructureBuildGeometryInfoKHR.mode = VkBuildAccelerationStructureModeKHR.VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR;
		vkAccelerationStructureBuildGeometryInfoKHR.dstAccelerationStructure = TopLevelAS;
		vkAccelerationStructureBuildGeometryInfoKHR.srcAccelerationStructure = TopLevelAS;
		vkAccelerationStructureBuildGeometryInfoKHR.geometryCount = 1;
		vkAccelerationStructureBuildGeometryInfoKHR.pGeometries = &geometryInfo;
		vkAccelerationStructureBuildGeometryInfoKHR.scratchData = VkDeviceOrHostAddressKHR()
		{
			deviceAddress = scratchBuffer.GetBufferAddress(vkContext.VkDevice)
		};
		VkAccelerationStructureBuildGeometryInfoKHR buildInfo = vkAccelerationStructureBuildGeometryInfoKHR;
		VkAccelerationStructureBuildRangeInfoKHR* ranges = scope VkAccelerationStructureBuildRangeInfoKHR[1]*;
		ranges.primitiveCount = (uint32)description.Instances.Count;
		ranges.primitiveOffset = description.Offset;
		ranges.firstVertex = 0;
		ranges.transformOffset = 0;
		VulkanNative.vkCmdBuildAccelerationStructuresKHR(commandBuffer, buildInfo.geometryCount, &buildInfo, &ranges);
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	private void Dispose(bool disposing)
	{
		if (!disposed)
		{
			if (disposing)
			{
				VulkanNative.vkDestroyAccelerationStructureKHR(vkContext.VkDevice, TopLevelAS, null);
			}
			disposed = true;
		}
	}
}
