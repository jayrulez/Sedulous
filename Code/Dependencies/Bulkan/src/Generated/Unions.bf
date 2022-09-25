using System;
namespace Bulkan
{
	[CRepr, Union]
	public struct VkClearColorValue
	{
		public float[4] float32;
		public int32[4] int32;
		public uint32[4] uint32;

		public ref Self setFloat32(float[4] @float32) mut { float32 = @float32;  return ref this; }
		public ref Self setInt32(int32[4] @int32) mut { int32 = @int32;  return ref this; }
		public ref Self setUint32(uint32[4] @uint32) mut { uint32 = @uint32;  return ref this; }
	}

	[CRepr, Union]
	public struct VkClearValue
	{
		public VkClearColorValue color;
		public VkClearDepthStencilValue depthStencil;

		public ref Self setColor(VkClearColorValue @color) mut { color = @color;  return ref this; }
		public ref Self setDepthStencil(VkClearDepthStencilValue @depthStencil) mut { depthStencil = @depthStencil;  return ref this; }
	}

	[CRepr, Union]
	public struct VkPerformanceCounterResultKHR
	{
		public int32 int32;
		public int64 int64;
		public uint32 uint32;
		public uint64 uint64;
		public float float32;
		public double float64;

		public ref Self setInt32(int32 @int32) mut { int32 = @int32;  return ref this; }
		public ref Self setInt64(int64 @int64) mut { int64 = @int64;  return ref this; }
		public ref Self setUint32(uint32 @uint32) mut { uint32 = @uint32;  return ref this; }
		public ref Self setUint64(uint64 @uint64) mut { uint64 = @uint64;  return ref this; }
		public ref Self setFloat32(float @float32) mut { float32 = @float32;  return ref this; }
		public ref Self setFloat64(double @float64) mut { float64 = @float64;  return ref this; }
	}

	[CRepr, Union]
	public struct VkPerformanceValueDataINTEL
	{
		public uint32 value32;
		public uint64 value64;
		public float valueFloat;
		public VkBool32 valueBool;
		public char8* valueString;

		public ref Self setValue32(uint32 @value32) mut { value32 = @value32;  return ref this; }
		public ref Self setValue64(uint64 @value64) mut { value64 = @value64;  return ref this; }
		public ref Self setValueFloat(float @valueFloat) mut { valueFloat = @valueFloat;  return ref this; }
		public ref Self setValueBool(VkBool32 @valueBool) mut { valueBool = @valueBool;  return ref this; }
		public ref Self setValueString(char8* @valueString) mut { valueString = @valueString;  return ref this; }
	}

	[CRepr, Union]
	public struct VkPipelineExecutableStatisticValueKHR
	{
		public VkBool32 b32;
		public int64 i64;
		public uint64 u64;
		public double f64;

		public ref Self setB32(VkBool32 @b32) mut { b32 = @b32;  return ref this; }
		public ref Self setI64(int64 @i64) mut { i64 = @i64;  return ref this; }
		public ref Self setU64(uint64 @u64) mut { u64 = @u64;  return ref this; }
		public ref Self setF64(double @f64) mut { f64 = @f64;  return ref this; }
	}

	[CRepr, Union]
	public struct VkDeviceOrHostAddressKHR
	{
		public uint64 deviceAddress;
		public void* hostAddress;

		public ref Self setDeviceAddress(uint64 @deviceAddress) mut { deviceAddress = @deviceAddress;  return ref this; }
		public ref Self setHostAddress(void* @hostAddress) mut { hostAddress = @hostAddress;  return ref this; }
	}

	[CRepr, Union]
	public struct VkDeviceOrHostAddressConstKHR
	{
		public uint64 deviceAddress;
		public void* hostAddress;

		public ref Self setDeviceAddress(uint64 @deviceAddress) mut { deviceAddress = @deviceAddress;  return ref this; }
		public ref Self setHostAddress(void* @hostAddress) mut { hostAddress = @hostAddress;  return ref this; }
	}

	[CRepr, Union]
	public struct VkAccelerationStructureGeometryDataKHR
	{
		public VkAccelerationStructureGeometryTrianglesDataKHR triangles;
		public VkAccelerationStructureGeometryAabbsDataKHR aabbs;
		public VkAccelerationStructureGeometryInstancesDataKHR instances;

		public ref Self setTriangles(VkAccelerationStructureGeometryTrianglesDataKHR @triangles) mut { triangles = @triangles;  return ref this; }
		public ref Self setAabbs(VkAccelerationStructureGeometryAabbsDataKHR @aabbs) mut { aabbs = @aabbs;  return ref this; }
		public ref Self setInstances(VkAccelerationStructureGeometryInstancesDataKHR @instances) mut { instances = @instances;  return ref this; }
	}

	[CRepr, Union]
	public struct VkAccelerationStructureMotionInstanceDataNV
	{
		public VkAccelerationStructureInstanceKHR staticInstance;
		public VkAccelerationStructureMatrixMotionInstanceNV matrixMotionInstance;
		public VkAccelerationStructureSRTMotionInstanceNV srtMotionInstance;

		public ref Self setStaticInstance(VkAccelerationStructureInstanceKHR @staticInstance) mut { staticInstance = @staticInstance;  return ref this; }
		public ref Self setMatrixMotionInstance(VkAccelerationStructureMatrixMotionInstanceNV @matrixMotionInstance) mut { matrixMotionInstance = @matrixMotionInstance;  return ref this; }
		public ref Self setSrtMotionInstance(VkAccelerationStructureSRTMotionInstanceNV @srtMotionInstance) mut { srtMotionInstance = @srtMotionInstance;  return ref this; }
	}

}

