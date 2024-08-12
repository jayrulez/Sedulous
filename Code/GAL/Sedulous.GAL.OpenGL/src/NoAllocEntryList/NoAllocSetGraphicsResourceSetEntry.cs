using System.Runtime.CompilerServices;

namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocSetResourceSetEntry
    {
        public const int32 MaxInlineDynamicOffsets = 10;

        public readonly uint32 Slot;
        public readonly Tracked<ResourceSet> ResourceSet;
        public readonly bool IsGraphics;
        public readonly uint32 DynamicOffsetCount;
        public fixed uint32 DynamicOffsets_Inline[MaxInlineDynamicOffsets];
        public readonly StagingBlock DynamicOffsets_Block;

        public NoAllocSetResourceSetEntry(
            uint32 slot,
            Tracked<ResourceSet> rs,
            bool isGraphics,
            uint32 dynamicOffsetCount,
            ref uint32 dynamicOffsets)
        {
            Slot = slot;
            ResourceSet = rs;
            IsGraphics = isGraphics;
            DynamicOffsetCount = dynamicOffsetCount;
            for (int32 i = 0; i < dynamicOffsetCount; i++)
            {
                DynamicOffsets_Inline[i] = Unsafe.Add(ref dynamicOffsets, i);
            }

            DynamicOffsets_Block = default;
        }

        public NoAllocSetResourceSetEntry(
            uint32 slot,
            Tracked<ResourceSet> rs,
            bool isGraphics,
            StagingBlock dynamicOffsets)
        {
            Slot = slot;
            ResourceSet = rs;
            IsGraphics = isGraphics;
            DynamicOffsetCount = (uint32)dynamicOffsets.SizeInBytes / sizeof(uint32);
            DynamicOffsets_Block = dynamicOffsets;
        }
    }
}
