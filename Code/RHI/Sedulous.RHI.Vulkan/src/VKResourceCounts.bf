namespace Sedulous.RHI.Vulkan;

internal struct VKResourceCounts
{
	public readonly uint32 ConstantBufferCount;

	public readonly uint32 TextureCount;

	public readonly uint32 SamplerCount;

	public readonly uint32 StorageBufferCount;

	public readonly uint32 StorageImageCount;

	public readonly uint32 AccelerationStructureCount;

	public this(uint32 constants, uint32 textures, uint32 samplers, uint32 storageBuffer, uint32 storageImage, uint32 accelerationStructure)
	{
		ConstantBufferCount = constants;
		TextureCount = textures;
		SamplerCount = samplers;
		StorageBufferCount = storageBuffer;
		StorageImageCount = storageImage;
		AccelerationStructureCount = accelerationStructure;
	}
}
