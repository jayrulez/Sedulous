using Bulkan;
using System.Collections;
namespace NRI.Vulkan;

class AccelerationStructureVK : AccelerationStructure
{
	private void PrecreateBottomLevel(AccelerationStructureDesc accelerationStructureDesc)
	{
		readonly VkAccelerationStructureBuildTypeKHR buildType = .VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR;

		VkAccelerationStructureBuildGeometryInfoKHR buildInfo = .();
		buildInfo.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
		buildInfo.type = m_Type;
		buildInfo.flags = m_BuildFlags;
		buildInfo.geometryCount = accelerationStructureDesc.instanceOrGeometryObjectNum;

		VkAccelerationStructureBuildSizesInfoKHR sizeInfo = .();
		sizeInfo.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR;

		List<VkAccelerationStructureGeometryKHR> geometries = Allocate!<List<VkAccelerationStructureGeometryKHR>>(m_Device.GetAllocator());
		defer
		{
			Deallocate!(m_Device.GetAllocator(), geometries);
		}
		uint32* primitiveMaxNums = ALLOCATE_SCRATCH!<uint32>(m_Device, accelerationStructureDesc.instanceOrGeometryObjectNum);

		geometries.Resize(accelerationStructureDesc.instanceOrGeometryObjectNum);
		ConvertGeometryObjectSizesVK(0, geometries.Ptr, primitiveMaxNums, accelerationStructureDesc.geometryObjects, (uint32)geometries.Count);
		buildInfo.pGeometries = geometries.Ptr;

		VulkanNative.vkGetAccelerationStructureBuildSizesKHR(m_Device, buildType, &buildInfo, primitiveMaxNums, &sizeInfo);

		m_BuildScratchSize = sizeInfo.buildScratchSize;
		m_UpdateScratchSize = sizeInfo.updateScratchSize;
		m_AccelerationStructureSize = sizeInfo.accelerationStructureSize;

		FREE_SCRATCH!(m_Device, primitiveMaxNums, accelerationStructureDesc.instanceOrGeometryObjectNum);
	}

	private void PrecreateTopLevel(AccelerationStructureDesc accelerationStructureDesc)
	{
		readonly VkAccelerationStructureBuildTypeKHR buildType = .VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR;

		VkAccelerationStructureGeometryKHR geometry = .();
		geometry.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR;
		geometry.geometryType = .VK_GEOMETRY_TYPE_INSTANCES_KHR;
		geometry.geometry.triangles.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR;
		geometry.geometry.aabbs.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR;
		geometry.geometry.instances.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR;

		VkAccelerationStructureBuildGeometryInfoKHR buildInfo = .();
		buildInfo.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR;
		buildInfo.type = m_Type;
		buildInfo.flags = m_BuildFlags;
		buildInfo.geometryCount = 1;
		buildInfo.pGeometries = &geometry;

		/*readonly*/ uint32 instanceMaxNum = accelerationStructureDesc.instanceOrGeometryObjectNum;

		VkAccelerationStructureBuildSizesInfoKHR sizeInfo = .();
		sizeInfo.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR;

		VulkanNative.vkGetAccelerationStructureBuildSizesKHR(m_Device, buildType, &buildInfo, &instanceMaxNum, &sizeInfo);

		m_BuildScratchSize = sizeInfo.buildScratchSize;
		m_UpdateScratchSize = sizeInfo.updateScratchSize;
		m_AccelerationStructureSize = sizeInfo.accelerationStructureSize;
	}

	private VkAccelerationStructureKHR[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_Handles = .();
	private VkDeviceAddress[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_DeviceAddresses = .();
	private BufferVK m_Buffer = null;
	private DeviceVK m_Device;
	private uint64 m_BuildScratchSize = 0;
	private uint64 m_UpdateScratchSize = 0;
	private uint64 m_AccelerationStructureSize = 0;
	private uint32 m_PhysicalDeviceMask = 0;
	private VkAccelerationStructureTypeKHR m_Type = (VkAccelerationStructureTypeKHR)0;
	private VkBuildAccelerationStructureFlagsKHR m_BuildFlags = (VkBuildAccelerationStructureFlagsKHR)0;

	public this(DeviceVK device)
	{
		m_Device = device;
	}

	public ~this()
	{
		for (uint32 i = 0; i < m_Handles.Count; i++)
		{
			if (m_Handles[i] != .Null)
				VulkanNative.vkDestroyAccelerationStructureKHR(m_Device, m_Handles[i], m_Device.GetAllocationCallbacks());
		}

		if (m_Buffer != null)
			m_Device.DestroyBuffer((Buffer)m_Buffer);
	}

	public DeviceVK GetDevice() => m_Device;

	public Result Create(AccelerationStructureDesc accelerationStructureDesc)
	{
		m_Type = GetAccelerationStructureType(accelerationStructureDesc.type);
		m_BuildFlags = GetAccelerationStructureBuildFlags(accelerationStructureDesc.flags);

		uint32 physicalDeviceMask = accelerationStructureDesc.physicalDeviceMask;
		physicalDeviceMask = (physicalDeviceMask == WHOLE_DEVICE_GROUP) ? 0xff : physicalDeviceMask;
		m_PhysicalDeviceMask = physicalDeviceMask;

		if (accelerationStructureDesc.type == AccelerationStructureType.BOTTOM_LEVEL)
			PrecreateBottomLevel(accelerationStructureDesc);
		else
			PrecreateTopLevel(accelerationStructureDesc);

		BufferDesc bufferDesc = .();
		bufferDesc.physicalDeviceMask = m_PhysicalDeviceMask;
		bufferDesc.size = m_AccelerationStructureSize;
		bufferDesc.usageMask = BufferUsageBits.RAY_TRACING_BUFFER;

		Buffer buffer = null;
		readonly Result result = m_Device.CreateBuffer(bufferDesc, out buffer);
		m_Buffer = (BufferVK)buffer;

		return result;
	}

	public Result FinishCreation()
	{
		if (m_Buffer == null)
			return Result.FAILURE;

		VkAccelerationStructureCreateInfoKHR accelerationStructureCreateInfo = .();
		accelerationStructureCreateInfo.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR;
		accelerationStructureCreateInfo.type = m_Type;
		accelerationStructureCreateInfo.size = m_AccelerationStructureSize;

		for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
		{
			if ((1 << i) & m_PhysicalDeviceMask != 0)
			{
				accelerationStructureCreateInfo.buffer = m_Buffer.GetHandle(i);

				readonly VkResult result = VulkanNative.vkCreateAccelerationStructureKHR(m_Device, &accelerationStructureCreateInfo,
					m_Device.GetAllocationCallbacks(), &m_Handles[i]);

				RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
					"Can't create an acceleration structure: vkCreateAccelerationStructureKHR returned {0}.", (int32)result);

				VkAccelerationStructureDeviceAddressInfoKHR deviceAddressInfo = .();
				deviceAddressInfo.sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR;
				deviceAddressInfo.accelerationStructure = m_Handles[i];

				m_DeviceAddresses[i] = VulkanNative.vkGetAccelerationStructureDeviceAddressKHR(m_Device, &deviceAddressInfo);
			}
		}

		return Result.SUCCESS;
	}

	public uint64 GetHandle(uint32 physicalDeviceIndex) => m_Handles[physicalDeviceIndex]; // todo sed: switch with GetNativeHandle?

	public BufferVK GetBuffer() => m_Buffer;


	public void SetDebugName(char8* name)
	{
		uint64[PHYSICAL_DEVICE_GROUP_MAX_SIZE] handles = .();
		for (uint i = 0; i < handles.Count; i++)
			handles[i] = (uint64)m_Handles[i];

		m_Device.SetDebugNameToDeviceGroupObject(.VK_OBJECT_TYPE_ACCELERATION_STRUCTURE_KHR, &handles, name);
		m_Buffer.SetDebugName(name);
	}

	public Result CreateDescriptor(uint32 physicalDeviceMask, out Descriptor descriptor)
	{
		DescriptorVK descriptorImpl = Allocate!<DescriptorVK>(m_Device.GetAllocator(), m_Device);
		descriptorImpl.Create(&m_Handles, physicalDeviceMask);
		descriptor = (Descriptor)descriptorImpl;

		return Result.SUCCESS;
	}

	public void GetMemoryInfo(ref MemoryDesc memoryDesc)
	{
		m_Buffer.GetMemoryInfo(MemoryLocation.DEVICE, ref memoryDesc);
	}

	public uint64 GetUpdateScratchBufferSize() => m_UpdateScratchSize;

	public uint64 GetBuildScratchBufferSize()  => m_BuildScratchSize;

	public uint64 GetNativeHandle(uint32 physicalDeviceIndex)
	{
		return m_DeviceAddresses[physicalDeviceIndex];
	}
}