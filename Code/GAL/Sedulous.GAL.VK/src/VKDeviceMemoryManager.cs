using Bulkan;
using static Bulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using System.Diagnostics;
using System;
using Bulkan;
using System.Threading;
using System.Collections;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL.VK;

    internal class VKDeviceMemoryManager : IDisposable
    {
        private const uint64 MinDedicatedAllocationSizeDynamic = 1024 * 1024 * 64;
        private const uint64 MinDedicatedAllocationSizeNonDynamic = 1024 * 1024 * 256;
        private readonly VkDevice _device;
        private readonly VkPhysicalDevice _physicalDevice;
        private readonly uint64 _bufferImageGranularity;
        private readonly Monitor _lock = new .() ~ delete _;
        private uint64 _totalAllocatedBytes;
        private readonly Dictionary<uint32, ChunkAllocatorSet> _allocatorsByMemoryTypeUnmapped = new .();
        private readonly Dictionary<uint32, ChunkAllocatorSet> _allocatorsByMemoryType = new .();

        private readonly vkGetBufferMemoryRequirements2_t _getBufferMemoryRequirements2;
        private readonly vkGetImageMemoryRequirements2_t _getImageMemoryRequirements2;

        public this(
            VkDevice device,
            VkPhysicalDevice physicalDevice,
            uint64 bufferImageGranularity,
            vkGetBufferMemoryRequirements2_t getBufferMemoryRequirements2,
            vkGetImageMemoryRequirements2_t getImageMemoryRequirements2)
        {
            _device = device;
            _physicalDevice = physicalDevice;
            _bufferImageGranularity = bufferImageGranularity;
            _getBufferMemoryRequirements2 = getBufferMemoryRequirements2;
            _getImageMemoryRequirements2 = getImageMemoryRequirements2;
        }

        public VkMemoryBlock Allocate(
            VkPhysicalDeviceMemoryProperties memProperties,
            uint32 memoryTypeBits,
            VkMemoryPropertyFlags flags,
            bool persistentMapped,
            uint64 size,
            uint64 alignment)
        {
            return Allocate(
                memProperties,
                memoryTypeBits,
                flags,
                persistentMapped,
                size,
                alignment,
                false,
                VkImage.Null,
                .Null);
        }

        public VkMemoryBlock Allocate(
            VkPhysicalDeviceMemoryProperties memProperties,
            uint32 memoryTypeBits,
            VkMemoryPropertyFlags flags,
            bool persistentMapped,
            uint64 size,
            uint64 alignment,
            bool dedicated,
            VkImage dedicatedImage,
            VkBuffer dedicatedBuffer)
        {
			var size;
            if (dedicated)
            {
                if (dedicatedImage != VkImage.Null && _getImageMemoryRequirements2 != null)
                {
                    VkImageMemoryRequirementsInfo2 requirementsInfo = VkImageMemoryRequirementsInfo2()
						{
							sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_REQUIREMENTS_INFO_2
						};
                    requirementsInfo.image = dedicatedImage;
                    VkMemoryRequirements2 requirements = VkMemoryRequirements2() {
						sType = .VK_STRUCTURE_TYPE_MEMORY_REQUIREMENTS_2
					};
                    _getImageMemoryRequirements2(_device, &requirementsInfo, &requirements);
                    size = requirements.memoryRequirements.size;
                }
                else if(dedicatedBuffer != .Null && _getBufferMemoryRequirements2 != null)
                {
                    VkBufferMemoryRequirementsInfo2 requirementsInfo = VkBufferMemoryRequirementsInfo2KHR.New();
                    requirementsInfo.buffer = dedicatedBuffer;
                    VkMemoryRequirements2 requirements = VkMemoryRequirements2KHR.New();
                    _getBufferMemoryRequirements2(_device, &requirementsInfo, &requirements);
                    size = requirements.memoryRequirements.size;
                }
            }
            else
            {
                // Round up to the nearest multiple of bufferImageGranularity.
                size = ((size / _bufferImageGranularity) + 1) * _bufferImageGranularity;
            }
            _totalAllocatedBytes += size;

            using (_lock.Enter())
            {
                if (!TryFindMemoryType(memProperties, memoryTypeBits, flags, var memoryTypeIndex))
                {
                    Runtime.GALError("No suitable memory type.");
                }

                uint64 minDedicatedAllocationSize = persistentMapped
                    ? MinDedicatedAllocationSizeDynamic
                    : MinDedicatedAllocationSizeNonDynamic;

                if (dedicated || size >= minDedicatedAllocationSize)
                {
                    VkMemoryAllocateInfo allocateInfo = VkMemoryAllocateInfo.New();
                    allocateInfo.allocationSize = size;
                    allocateInfo.memoryTypeIndex = memoryTypeIndex;

                    VkMemoryDedicatedAllocateInfo dedicatedAI = .();
                    if (dedicated)
                    {
                        dedicatedAI = VkMemoryDedicatedAllocateInfo() { sType = .VK_STRUCTURE_TYPE_MEMORY_DEDICATED_ALLOCATE_INFO };
                        dedicatedAI.buffer = dedicatedBuffer;
                        dedicatedAI.image = dedicatedImage;
                        allocateInfo.pNext = &dedicatedAI;
                    }

					VkDeviceMemory memory = .Null;
                    VkResult allocationResult = vkAllocateMemory(_device, &allocateInfo, null, &memory);
                    if (allocationResult != VkResult.VK_SUCCESS)
                    {
                        Runtime.GALError("Unable to allocate sufficient Vulkan memory.");
                    }

                    void* mappedPtr = null;
                    if (persistentMapped)
                    {
                        VkResult mapResult = vkMapMemory(_device, memory, 0, size, 0, &mappedPtr);
                        if (mapResult != VkResult.VK_SUCCESS)
                        {
                            Runtime.GALError("Unable to map newly-allocated Vulkan memory.");
                        }
                    }

                    return VkMemoryBlock(memory, 0, size, memoryTypeBits, mappedPtr, true);
                }
                else
                {
                    ChunkAllocatorSet allocator = GetAllocator(memoryTypeIndex, persistentMapped);
                    bool result = allocator.Allocate(size, alignment, out VkMemoryBlock ret);
                    if (!result)
                    {
                        Runtime.GALError("Unable to allocate sufficient Vulkan memory.");
                    }

                    return ret;
                }
            }
        }

        public void Free(VkMemoryBlock block)
        {
            _totalAllocatedBytes -= block.Size;
            lock (_lock)
            {
                if (block.DedicatedAllocation)
                {
                    vkFreeMemory(_device, block.DeviceMemory, null);
                }
                else
                {
                    GetAllocator(block.MemoryTypeIndex, block.IsPersistentMapped).Free(block);
                }
            }
        }

        private ChunkAllocatorSet GetAllocator(uint32 memoryTypeIndex, bool persistentMapped)
        {
            ChunkAllocatorSet ret = null;
            if (persistentMapped)
            {
                if (!_allocatorsByMemoryType.TryGetValue(memoryTypeIndex, out ret))
                {
                    ret = new ChunkAllocatorSet(_device, memoryTypeIndex, true);
                    _allocatorsByMemoryType.Add(memoryTypeIndex, ret);
                }
            }
            else
            {
                if (!_allocatorsByMemoryTypeUnmapped.TryGetValue(memoryTypeIndex, out ret))
                {
                    ret = new ChunkAllocatorSet(_device, memoryTypeIndex, false);
                    _allocatorsByMemoryTypeUnmapped.Add(memoryTypeIndex, ret);
                }
            }

            return ret;
        }

        private class ChunkAllocatorSet : IDisposable
        {
            private readonly VkDevice _device;
            private readonly uint32 _memoryTypeIndex;
            private readonly bool _persistentMapped;
            private readonly List<ChunkAllocator> _allocators = new List<ChunkAllocator>();

            public ChunkAllocatorSet(VkDevice device, uint32 memoryTypeIndex, bool persistentMapped)
            {
                _device = device;
                _memoryTypeIndex = memoryTypeIndex;
                _persistentMapped = persistentMapped;
            }

            public bool Allocate(uint64 size, uint64 alignment, out VkMemoryBlock block)
            {
                for (ChunkAllocator allocator in _allocators)
                {
                    if (allocator.Allocate(size, alignment, out block))
                    {
                        return true;
                    }
                }

                ChunkAllocator newAllocator = new ChunkAllocator(_device, _memoryTypeIndex, _persistentMapped);
                _allocators.Add(newAllocator);
                return newAllocator.Allocate(size, alignment, out block);
            }

            public void Free(VkMemoryBlock block)
            {
                for (ChunkAllocator chunk in _allocators)
                {
                    if (chunk.Memory == block.DeviceMemory)
                    {
                        chunk.Free(block);
                    }
                }
            }

            public void Dispose()
            {
                for (ChunkAllocator allocator in _allocators)
                {
                    allocator.Dispose();
                }
            }
        }

        private class ChunkAllocator : IDisposable
        {
            private const uint64 PersistentMappedChunkSize = 1024 * 1024 * 64;
            private const uint64 UnmappedChunkSize = 1024 * 1024 * 256;
            private readonly VkDevice _device;
            private readonly uint32 _memoryTypeIndex;
            private readonly bool _persistentMapped;
            private readonly List<VkMemoryBlock> _freeBlocks = new List<VkMemoryBlock>();
            private readonly VkDeviceMemory _memory;
            private readonly void* _mappedPtr;

            private uint64 _totalMemorySize;
            private uint64 _totalAllocatedBytes = 0;

            public VkDeviceMemory Memory => _memory;

            public ChunkAllocator(VkDevice device, uint32 memoryTypeIndex, bool persistentMapped)
            {
                _device = device;
                _memoryTypeIndex = memoryTypeIndex;
                _persistentMapped = persistentMapped;
                _totalMemorySize = persistentMapped ? PersistentMappedChunkSize : UnmappedChunkSize;

                VkMemoryAllocateInfo memoryAI = VkMemoryAllocateInfo.New();
                memoryAI.allocationSize = _totalMemorySize;
                memoryAI.memoryTypeIndex = _memoryTypeIndex;
                VkResult result = vkAllocateMemory(_device, ref memoryAI, null, out _memory);
                CheckResult(result);

                void* mappedPtr = null;
                if (persistentMapped)
                {
                    result = vkMapMemory(_device, _memory, 0, _totalMemorySize, 0, &mappedPtr);
                    CheckResult(result);
                }
                _mappedPtr = mappedPtr;

                VkMemoryBlock initialBlock = new VkMemoryBlock(
                    _memory,
                    0,
                    _totalMemorySize,
                    _memoryTypeIndex,
                    _mappedPtr,
                    false);
                _freeBlocks.Add(initialBlock);
            }

            public bool Allocate(uint64 size, uint64 alignment, out VkMemoryBlock block)
            {
                checked
                {
                    for (int32 i = 0; i < _freeBlocks.Count; i++)
                    {
                        VkMemoryBlock freeBlock = _freeBlocks[i];
                        uint64 alignedBlockSize = freeBlock.Size;
                        if (freeBlock.Offset % alignment != 0)
                        {
                            uint64 alignmentCorrection = (alignment - freeBlock.Offset % alignment);
                            if (alignedBlockSize <= alignmentCorrection)
                            {
                                continue;
                            }
                            alignedBlockSize -= alignmentCorrection;
                        }

                        if (alignedBlockSize >= size) // Valid match -- split it and return.
                        {
                            _freeBlocks.RemoveAt(i);

                            freeBlock.Size = alignedBlockSize;
                            if ((freeBlock.Offset % alignment) != 0)
                            {
                                freeBlock.Offset += alignment - (freeBlock.Offset % alignment);
                            }

                            block = freeBlock;

                            if (alignedBlockSize != size)
                            {
                                VkMemoryBlock splitBlock = new VkMemoryBlock(
                                    freeBlock.DeviceMemory,
                                    freeBlock.Offset + size,
                                    freeBlock.Size - size,
                                    _memoryTypeIndex,
                                    freeBlock.BaseMappedPointer,
                                    false);
                                _freeBlocks.Insert(i, splitBlock);
                                block = freeBlock;
                                block.Size = size;
                            }

#if DEBUG
                            CheckAllocatedBlock(block);
#endif
                            _totalAllocatedBytes += alignedBlockSize;
                            return true;
                        }
                    }

                    block = default(VkMemoryBlock);
                    return false;
                }
            }

            public void Free(VkMemoryBlock block)
            {
                for (int32 i = 0; i < _freeBlocks.Count; i++)
                {
                    if (_freeBlocks[i].Offset > block.Offset)
                    {
                        _freeBlocks.Insert(i, block);
                        MergeContiguousBlocks();
#if DEBUG
                        RemoveAllocatedBlock(block);
#endif
                        return;
                    }
                }

                _freeBlocks.Add(block);
#if DEBUG
                RemoveAllocatedBlock(block);
#endif
                _totalAllocatedBytes -= block.Size;
            }

            private void MergeContiguousBlocks()
            {
                int32 contiguousLength = 1;
                for (int32 i = 0; i < _freeBlocks.Count - 1; i++)
                {
                    uint64 blockStart = _freeBlocks[i].Offset;
                    while (i + contiguousLength < _freeBlocks.Count
                        && _freeBlocks[i + contiguousLength - 1].End == _freeBlocks[i + contiguousLength].Offset)
                    {
                        contiguousLength += 1;
                    }

                    if (contiguousLength > 1)
                    {
                        uint64 blockEnd = _freeBlocks[i + contiguousLength - 1].End;
                        _freeBlocks.RemoveRange(i, contiguousLength);
                        VkMemoryBlock mergedBlock = new VkMemoryBlock(
                            Memory,
                            blockStart,
                            blockEnd - blockStart,
                            _memoryTypeIndex,
                            _mappedPtr,
                            false);
                        _freeBlocks.Insert(i, mergedBlock);
                        contiguousLength = 0;
                    }
                }
            }

#if DEBUG
            private List<VkMemoryBlock> _allocatedBlocks = new List<VkMemoryBlock>();

            private void CheckAllocatedBlock(VkMemoryBlock block)
            {
                for (VkMemoryBlock oldBlock in _allocatedBlocks)
                {
                    Debug.Assert(!BlocksOverlap(block, oldBlock), "Allocated blocks have overlapped.");
                }

                _allocatedBlocks.Add(block);
            }

            private bool BlocksOverlap(VkMemoryBlock first, VkMemoryBlock second)
            {
                uint64 firstStart = first.Offset;
                uint64 firstEnd = first.Offset + first.Size;
                uint64 secondStart = second.Offset;
                uint64 secondEnd = second.Offset + second.Size;

                return (firstStart <= secondStart && firstEnd > secondStart
                    || firstStart >= secondStart && firstEnd <= secondEnd
                    || firstStart < secondEnd && firstEnd >= secondEnd
                    || firstStart <= secondStart && firstEnd >= secondEnd);
            }

            private void RemoveAllocatedBlock(VkMemoryBlock block)
            {
                Debug.Assert(_allocatedBlocks.Remove(block), "Unable to remove a supposedly allocated block.");
            }
#endif

            public void Dispose()
            {
                vkFreeMemory(_device, _memory, null);
            }
        }

        public void Dispose()
        {
            for (KeyValuePair<uint32, ChunkAllocatorSet> kvp in _allocatorsByMemoryType)
            {
                kvp.Value.Dispose();
            }

            for (KeyValuePair<uint32, ChunkAllocatorSet> kvp in _allocatorsByMemoryTypeUnmapped)
            {
                kvp.Value.Dispose();
            }
        }

        internal IntPtr Map(VkMemoryBlock memoryBlock)
        {
            void* ret;
            VkResult result = vkMapMemory(_device, memoryBlock.DeviceMemory, memoryBlock.Offset, memoryBlock.Size, 0, &ret);
            CheckResult(result);
            return (IntPtr)ret;
        }
    }

    //[DebuggerDisplay("[Mem:{DeviceMemory.Handle}] Off:{Offset}, Size:{Size} End:{Offset+Size}")]
    internal struct VkMemoryBlock : IEquatable<VkMemoryBlock>
    {
        public readonly uint32 MemoryTypeIndex;
        public readonly VkDeviceMemory DeviceMemory;
        public readonly void* BaseMappedPointer;
        public readonly bool DedicatedAllocation;

        public uint64 Offset;
        public uint64 Size;

        public void* BlockMappedPointer => ((uint8*)BaseMappedPointer) + Offset;
        public bool IsPersistentMapped => BaseMappedPointer != null;
        public uint64 End => Offset + Size;

        public VkMemoryBlock(
            VkDeviceMemory memory,
            uint64 offset,
            uint64 size,
            uint32 memoryTypeIndex,
            void* mappedPtr,
            bool dedicatedAllocation)
        {
            DeviceMemory = memory;
            Offset = offset;
            Size = size;
            MemoryTypeIndex = memoryTypeIndex;
            BaseMappedPointer = mappedPtr;
            DedicatedAllocation = dedicatedAllocation;
        }

        public bool Equals(VkMemoryBlock other)
        {
            return DeviceMemory.Equals(other.DeviceMemory)
                && Offset.Equals(other.Offset)
                && Size.Equals(other.Size);
        }
    }
}
