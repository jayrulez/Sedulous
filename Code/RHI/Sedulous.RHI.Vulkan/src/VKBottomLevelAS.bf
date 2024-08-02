using System;
using Bulkan;
using Sedulous.RHI.Raytracing;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;
namespace Sedulous.RHI.Vulkan;

/// <summary>
/// Vulkan Bottom Level Acceleration Structure implementation.
/// </summary>
public class VKBottomLevelAS : BottomLevelAS
{
	/// <summary>
	/// The bottom level acceleration structure instance.
	/// </summary>
	public VkAccelerationStructureKHR BottomLevelAS;

	private uint64 bottomLevelASHandle;

	private VKGraphicsContext vkContext;

	/// <inheritdoc />
	public override void* NativePointer => (void*)(int)bottomLevelASHandle;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKBottomLevelAS" /> class.
	/// </summary>
	/// <param name="context">Graphics Context.</param>
	/// <param name="commandBuffer">Command buffer.</param>
	/// <param name="description">Bottom Level Description.</param>
	public this(VKGraphicsContext context, VkCommandBuffer commandBuffer, ref BottomLevelASDescription description)
		: base(context, ref description)
	{
		vkContext = context;
		VkAccelerationStructureGeometryKHR* geometryInfos = scope VkAccelerationStructureGeometryKHR[description.Geometries.Count]*;
		VkAccelerationStructureBuildRangeInfoKHR* ranges = scope VkAccelerationStructureBuildRangeInfoKHR[description.Geometries.Count]*;
		uint32 primitiveCount = 0;
		for (int i = 0; i < description.Geometries.Count; i++)
		{
			AccelerationStructureGeometry geometry = description.Geometries[i];
			VkAccelerationStructureGeometryKHR geometryInfo = default(VkAccelerationStructureGeometryKHR);
			VkAccelerationStructureBuildRangeInfoKHR range = default(VkAccelerationStructureBuildRangeInfoKHR);
			AccelerationStructureTriangles trianglesGeometry = geometry as AccelerationStructureTriangles;
			if (trianglesGeometry != null)
			{
				VkDeviceOrHostAddressConstKHR vertexAddress = (trianglesGeometry.VertexBuffer as VKBuffer).BufferAddress;
				vertexAddress.deviceAddress += trianglesGeometry.VertexOffset;
				VkDeviceOrHostAddressConstKHR indexAddress = default(VkDeviceOrHostAddressConstKHR);
				if (trianglesGeometry.IndexBuffer != null)
				{
					indexAddress = (trianglesGeometry.IndexBuffer as VKBuffer).BufferAddress;
					indexAddress.deviceAddress += trianglesGeometry.IndexOffset;
				}
				geometryInfo = VkAccelerationStructureGeometryKHR()
				{
					sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
					flags = (VkGeometryFlagsKHR)trianglesGeometry.Flags,
					geometryType = VkGeometryTypeKHR.VK_GEOMETRY_TYPE_TRIANGLES_KHR,
					geometry = VkAccelerationStructureGeometryDataKHR()
					{
						triangles = VkAccelerationStructureGeometryTrianglesDataKHR()
						{
							sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR,
							vertexData = vertexAddress,
							vertexFormat = trianglesGeometry.VertexFormat.ToVulkan(depthFormat: false),
							vertexStride = trianglesGeometry.VertexStride,
							maxVertex = trianglesGeometry.VertexCount,
							indexData = indexAddress,
							indexType = ((indexAddress.deviceAddress != 0L) ? trianglesGeometry.IndexFormat.ToVulkan() : VkIndexType.VK_INDEX_TYPE_NONE_KHR)
						}
					}
				};
				primitiveCount = ((indexAddress.deviceAddress != 0L) ? (trianglesGeometry.IndexCount / 3) : (trianglesGeometry.VertexCount / 3));
				range = VkAccelerationStructureBuildRangeInfoKHR()
				{
					primitiveCount = primitiveCount,
					primitiveOffset = 0,
					firstVertex = 0,
					transformOffset = 0
				};
			}
			else
			{
				AccelerationStructureAABBs aabbsGeometry = geometry as AccelerationStructureAABBs;
				if (aabbsGeometry != null)
				{
					geometryInfo = VkAccelerationStructureGeometryKHR()
					{
						sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
						pNext = null,
						flags = (VkGeometryFlagsKHR)aabbsGeometry.Flags,
						geometryType = VkGeometryTypeKHR.VK_GEOMETRY_TYPE_AABBS_KHR,
						geometry = VkAccelerationStructureGeometryDataKHR()
						{
							aabbs = VkAccelerationStructureGeometryAabbsDataKHR()
							{
								sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR,
								stride = aabbsGeometry.Stride,
								data = (aabbsGeometry.AABBs as VKBuffer).BufferAddress
							}
						}
					};
					primitiveCount = (uint32)aabbsGeometry.Count;
					range = VkAccelerationStructureBuildRangeInfoKHR()
					{
						primitiveCount = primitiveCount,
						primitiveOffset = aabbsGeometry.Offset,
						firstVertex = 0,
						transformOffset = 0
					};
				}
				else
				{
					context.ValidationLayer.Notify("VK", "Acceleration Structure geometry type not supported!");
				}
			}
			geometryInfos[i] = geometryInfo;
			ranges[i] = range;
		}
		VkAccelerationStructureBuildGeometryInfoKHR buildInfoSize = VkAccelerationStructureBuildGeometryInfoKHR()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
			type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR,
			flags = VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR,
			geometryCount = (uint32)description.Geometries.Count,
			pGeometries = geometryInfos
		};
		VkAccelerationStructureBuildSizesInfoKHR sizeInfo = VkAccelerationStructureBuildSizesInfoKHR()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR
		};
		VulkanNative.vkGetAccelerationStructureBuildSizesKHR(vkContext.VkDevice, VkAccelerationStructureBuildTypeKHR.VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR, &buildInfoSize, &primitiveCount, &sizeInfo);
		VkBuffer bottomLevelASMemory = VKRaytracingHelpers.CreateBuffer(vkContext, sizeInfo.accelerationStructureSize, VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR).Buffer;
		VkAccelerationStructureCreateInfoKHR asInfo = VkAccelerationStructureCreateInfoKHR()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR,
			buffer = bottomLevelASMemory,
			size = sizeInfo.accelerationStructureSize,
			type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR
		};
		VkAccelerationStructureKHR newBottomLevelAS = default(VkAccelerationStructureKHR);
		VulkanNative.vkCreateAccelerationStructureKHR(vkContext.VkDevice, &asInfo, null, &newBottomLevelAS);
		BottomLevelAS = newBottomLevelAS;
		bottomLevelASHandle = BottomLevelAS.GetAccelerationStructureAddress(vkContext.VkDevice);
		buildInfoSize.dstAccelerationStructure = BottomLevelAS;
		VkBuffer scratchMemory = VKRaytracingHelpers.CreateBuffer(vkContext, sizeInfo.buildScratchSize, VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT).Buffer;
		VkAccelerationStructureBuildGeometryInfoKHR buildInfo = VkAccelerationStructureBuildGeometryInfoKHR()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
			type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR,
			flags = VkBuildAccelerationStructureFlagsKHR.VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR,
			mode = VkBuildAccelerationStructureModeKHR.VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR,
			dstAccelerationStructure = BottomLevelAS,
			geometryCount = 1,
			pGeometries = geometryInfos,
			scratchData = VkDeviceOrHostAddressKHR()
			{
				deviceAddress = scratchMemory.GetBufferAddress(vkContext.VkDevice)
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
				VulkanNative.vkDestroyAccelerationStructureKHR(vkContext.VkDevice, BottomLevelAS, null);
			}
			disposed = true;
		}
	}
}
