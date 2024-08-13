namespace Sedulous.GAL.VK
{
    internal struct DescriptorResourceCounts
    {
        public readonly uint32 UniformBufferCount;
        public readonly uint32 SampledImageCount;
        public readonly uint32 SamplerCount;
        public readonly uint32 StorageBufferCount;
        public readonly uint32 StorageImageCount;
        public readonly uint32 UniformBufferDynamicCount;
        public readonly uint32 StorageBufferDynamicCount;

        public this(
            uint32 uniformBufferCount,
            uint32 uniformBufferDynamicCount,
            uint32 sampledImageCount,
            uint32 samplerCount,
            uint32 storageBufferCount,
            uint32 storageBufferDynamicCount,
            uint32 storageImageCount)
        {
            UniformBufferCount = uniformBufferCount;
            UniformBufferDynamicCount = uniformBufferDynamicCount;
            SampledImageCount = sampledImageCount;
            SamplerCount = samplerCount;
            StorageBufferCount = storageBufferCount;
            StorageBufferDynamicCount = storageBufferDynamicCount;
            StorageImageCount = storageImageCount;
        }
    }
}
