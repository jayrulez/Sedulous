namespace Sedulous.MetalBindings
{
    public enum MTLResourceOptions : uint64
    {
        CPUCacheModeDefaultCache = (.)MTLCPUCacheMode.DefaultCache,
        CPUCacheModeWriteCombined = (.)MTLCPUCacheMode.WriteCombined,

        StorageModeShared = (uint64)MTLStorageMode.Shared << 4,
        StorageModeManaged = (uint64)MTLStorageMode.Managed << 4,
        StorageModePrivate = (uint64)MTLStorageMode.Private << 4,
        StorageModeMemoryless = (uint64)MTLStorageMode.Memoryless << 4,

        HazardTrackingModeUntracked = (uint32)(0x1UL << 8),
    }
}
