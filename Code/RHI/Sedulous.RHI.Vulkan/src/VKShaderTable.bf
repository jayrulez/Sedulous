using System;
using Bulkan;
using System.Collections;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// Vulkan Shader binding table.
/// </summary>
public class VKShaderTable : IDisposable
{
	/// <summary>
	/// Shader Table Entry.
	/// </summary>
	public struct ShaderTableRecord
	{
		/// <summary>
		/// Record type.
		/// </summary>
		public enum RecordType
		{
			/// <summary>
			/// RayGen record.
			/// </summary>
			RayGen,
			/// <summary>
			///  Miss record.
			/// </summary>
			Miss,
			/// <summary>
			///  Hit record.
			/// </summary>
			Hit
		}

		/// <summary>
		/// Pipeline shader identifier.
		/// </summary>
		public String name;

		/// <summary>
		/// Record type.
		/// </summary>
		public RecordType type;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKShaderTable.ShaderTableRecord" /> struct.
		/// </summary>
		/// <param name="name">Pipeline shader identifier.</param>
		/// <param name="type">Record type.</param>
		public this(String name, RecordType type)
		{
			this.name = name;
			this.type = type;
		}
	}

	private const uint32 VKShaderIdentifierSizeInBytes = 32;

	private const uint32 VKRaytracingShaderRecordByteAlignment = 64;

	/// <summary>
	/// Holds if the instance has been disposed.
	/// </summary>
	protected bool disposed;

	private uint16[] data;

	private int64 dataPointer;

	private VKGraphicsContext context;

	private List<ShaderTableRecord> entries;

	private uint32 shaderTableEntrySize;

	private uint32 shaderTableEntrySizeAligned;

	private uint32 raygenCount;

	private uint32 missCount;

	private uint32 hitgroupCount;

	private VKRaytracingHelpers.BufferData rayGenBuffer;

	private VKRaytracingHelpers.BufferData missBuffer;

	private VKRaytracingHelpers.BufferData hitBuffer;

	/// <summary>
	/// Gets a value indicating whether the graphic resource has been disposed.
	/// </summary>
	public bool Disposed => disposed;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKShaderTable" /> class.
	/// </summary>
	/// <param name="graphicsContext">Vulkan Graphics Context.</param>
	public this(VKGraphicsContext graphicsContext)
	{
		context = graphicsContext;
		entries = new List<ShaderTableRecord>();
	}

	/// <summary>
	/// Add Raygen Program.
	/// </summary>
	/// <param name="shaderIdentifier">Shader identifier.</param>
	public void AddRayGenProgram(String shaderIdentifier)
	{
		entries.Add(ShaderTableRecord(shaderIdentifier, ShaderTableRecord.RecordType.RayGen));
		raygenCount++;
	}

	/// <summary>
	/// Add Miss Program.
	/// </summary>
	/// <param name="shaderIdentifier">Shader identifier.</param>
	public void AddMissProgram(String shaderIdentifier)
	{
		entries.Add(ShaderTableRecord(shaderIdentifier, ShaderTableRecord.RecordType.Miss));
		missCount++;
	}

	/// <summary>
	/// Add HitGroup Program.
	/// </summary>
	/// <param name="shaderIdentifier">Shader identifier.</param>
	public void AddHitGroupProgram(String shaderIdentifier)
	{
		entries.Add(ShaderTableRecord(shaderIdentifier, ShaderTableRecord.RecordType.Hit));
		hitgroupCount++;
	}

	/// <summary>
	/// Generate ShaderTable (filling buffer).
	/// </summary>
	/// <param name="pipeline">Raytracing pipeline.</param>
	public void Generate(VkPipeline pipeline)
	{
		shaderTableEntrySize = 32;
		shaderTableEntrySizeAligned = AlignTo(shaderTableEntrySize, 64);
		uint32 shaderTableSize = shaderTableEntrySize * (uint32)entries.Count;
		data = new uint16[shaderTableSize];
		dataPointer = (int64)(int)(void*)data.Ptr;
		VulkanNative.vkGetRayTracingShaderGroupHandlesKHR(context.VkDevice, pipeline, 0, (uint32)entries.Count, uint(shaderTableSize), (void*)(int)dataPointer);
		uint32 rayGenBufferSize = shaderTableEntrySizeAligned * raygenCount;
		rayGenBuffer = VKRaytracingHelpers.CreateBuffer(context, rayGenBufferSize, VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR);
		void* raygenBufferDataPointer = default(void*);
		VulkanNative.vkMapMemory(context.VkDevice, rayGenBuffer.Memory, 0uL, shaderTableSize, VkMemoryMapFlags.None, &raygenBufferDataPointer);
		uint32 missBufferSize = shaderTableEntrySizeAligned * missCount;
		missBuffer = VKRaytracingHelpers.CreateBuffer(context, missBufferSize, VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR);
		void* missBufferDataPointer = default(void*);
		VulkanNative.vkMapMemory(context.VkDevice, missBuffer.Memory, 0uL, shaderTableSize, VkMemoryMapFlags.None, &missBufferDataPointer);
		uint32 hitBufferSize = shaderTableEntrySizeAligned * hitgroupCount;
		hitBuffer = VKRaytracingHelpers.CreateBuffer(context, hitBufferSize, VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR);
		void* hitBufferDataPointer = default(void*);
		VulkanNative.vkMapMemory(context.VkDevice, hitBuffer.Memory, 0uL, shaderTableSize, VkMemoryMapFlags.None, &hitBufferDataPointer);
		int raygenBufferCurrentPointer = int(raygenBufferDataPointer);
		int missBufferCurrentPointer = int(missBufferDataPointer);
		int hitBufferCurrentPointer = int(hitBufferDataPointer);
		for (int32 g = 0; g < entries.Count; g++)
		{
			switch (entries[g].type)
			{
			case ShaderTableRecord.RecordType.RayGen:
				Internal.MemCpy((void*)raygenBufferCurrentPointer, (void*)(int)dataPointer, shaderTableEntrySize);
				raygenBufferCurrentPointer += (int32)shaderTableEntrySizeAligned;
				break;
			case ShaderTableRecord.RecordType.Miss:
				Internal.MemCpy((void*)missBufferCurrentPointer, (void*)(int)dataPointer, shaderTableEntrySize);
				missBufferCurrentPointer += (int32)shaderTableEntrySizeAligned;
				break;
			case ShaderTableRecord.RecordType.Hit:
				Internal.MemCpy((void*)hitBufferCurrentPointer, (void*)(int)dataPointer, shaderTableEntrySize);
				hitBufferCurrentPointer += (int32)shaderTableEntrySizeAligned;
				break;
			}
			dataPointer += shaderTableEntrySize;
		}
		VulkanNative.vkUnmapMemory(context.VkDevice, rayGenBuffer.Memory);
	}

	/// <summary>
	/// ShaderBindingTable alignment.
	/// </summary>
	/// <param name="value">Record size.</param>
	/// <param name="alignment">Record alignment.</param>
	/// <returns>Record size aligned.</returns>
	public uint32 AlignTo(uint32 value, uint32 alignment)
	{
		return (value + alignment - 1) & ~(alignment - 1);
	}

	/// <summary>
	/// Get Ray generation start address.
	/// </summary>
	/// <returns>buffer adress.</returns>
	public uint64 GetRayGenStartAddress()
	{
		return rayGenBuffer.Buffer.GetBufferAddress(context.VkDevice);
	}

	/// <summary>
	/// Gets Ray generation stride.
	/// </summary>
	/// <returns>Entry stride.</returns>
	public uint64 GetRayGenStride()
	{
		return shaderTableEntrySizeAligned;
	}

	/// <summary>
	/// Gets Ray generation entry size.
	/// </summary>
	/// <returns>Entry size.</returns>
	public uint64 GetRayGenSize()
	{
		return shaderTableEntrySizeAligned * raygenCount;
	}

	/// <summary>
	/// Get Miss start address.
	/// </summary>
	/// <returns>buffer adress.</returns>
	public uint64 GetMissStartAddress()
	{
		return missBuffer.Buffer.GetBufferAddress(context.VkDevice);
	}

	/// <summary>
	/// Gets Miss stride.
	/// </summary>
	/// <returns>Entry stride.</returns>
	public uint64 GetMissStride()
	{
		return shaderTableEntrySizeAligned;
	}

	/// <summary>
	/// Gets Ray generation entry size.
	/// </summary>
	/// <returns>Entry size.</returns>
	public uint64 GetMissSize()
	{
		return shaderTableEntrySizeAligned * missCount;
	}

	/// <summary>
	/// Get HitGroup start address.
	/// </summary>
	/// <returns>buffer adress.</returns>
	public uint64 GetHitGroupStartAddress()
	{
		return hitBuffer.Buffer.GetBufferAddress(context.VkDevice);
	}

	/// <summary>
	/// Gets Miss stride.
	/// </summary>
	/// <returns>Entry stride.</returns>
	public uint64 GetHitGroupStride()
	{
		return shaderTableEntrySizeAligned;
	}

	/// <summary>
	/// Gets Ray generation entry size.
	/// </summary>
	/// <returns>Entry size.</returns>
	public uint64 GetHitGroupSize()
	{
		return shaderTableEntrySizeAligned * hitgroupCount;
	}

	/// <inheritdoc />
	public void Dispose()
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
				VulkanNative.vkDestroyBuffer(context.VkDevice, rayGenBuffer.Buffer, null);
				VulkanNative.vkDestroyBuffer(context.VkDevice, missBuffer.Buffer, null);
				VulkanNative.vkDestroyBuffer(context.VkDevice, hitBuffer.Buffer, null);
			}
			disposed = true;
		}
	}
}
