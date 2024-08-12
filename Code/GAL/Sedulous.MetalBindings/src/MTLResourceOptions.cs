namespace Sedulous.MetalBindings
{
    public enum MTLResourceOptions : uint64
    {
        CPUCacheModeDefaultCache = MTLCPUCacheMode.DefaultCache,
        CPUCacheModeWriteCombined = MTLCPUCacheMode.WriteCombined,

        StorageModeShared = MTLStorageMode.Shared << 4,
        StorageModeManaged = MTLStorageMode.Managed << 4,
        StorageModePrivate = MTLStorageMode.Private << 4,
        StorageModeMemoryless = MTLStorageMode.Memoryless << 4,

        HazardTrackingModeUntracked = (uint32)(0x1UL << 8),
    }
}
