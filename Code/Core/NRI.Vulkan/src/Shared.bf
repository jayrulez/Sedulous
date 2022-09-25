using System;
namespace NRI.Vulkan;

[CRepr]
struct MemoryTypeInfo
{
	public uint16 memoryTypeIndex;
	public uint8 location;
	//public uint8 isDedicated;// : 1;
	//public uint8 isHostCoherent;// : 1;
	[Bitfield(.Public, .Bits(1), "isDedicated")]
	[Bitfield(.Public, .Bits(1), "isHostCoherent")]
	private uint8 bits;
}

public static
{
	public static void Asserts1()
	{
		Compiler.Assert(sizeof(MemoryTypeInfo) <= sizeof(MemoryType), "Unexpected structure size");
	}
}

[Union]
struct MemoryTypeUnpack
{
	public MemoryType type;
	public MemoryTypeInfo info;
}

public static
{
	public static HandleType GetVulkanHandle<HandleType, ImplType, NRIType>(NRIType object, uint32 physicalDeviceIndex)
		where ImplType : NRIType, var
		where HandleType : var
	{
		return (object != null) ? ((ImplType)object).GetHandle(physicalDeviceIndex) : HandleType.Null;
	}

	public static bool IsHostVisibleMemory(MemoryLocation location)
	{
		return location > MemoryLocation.DEVICE;
	}
}