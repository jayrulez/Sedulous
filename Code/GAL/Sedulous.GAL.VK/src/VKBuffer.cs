using System;
using Bulkan;
using static Sedulous.GAL.VK.VulkanUtil;
using static Bulkan.VulkanNative;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL.VK;

    internal class VKBuffer : DeviceBuffer
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkBuffer _deviceBuffer;
        private readonly VkMemoryBlock _memory;
        private readonly VkMemoryRequirements _bufferMemoryRequirements;
        public ResourceRefCount RefCount { get; }
        private bool _destroyed;
        private String _name;
        public override bool IsDisposed => _destroyed;

        public override uint32 SizeInBytes { get; }
        public override BufferUsage Usage { get; }

        public VkBuffer DeviceBuffer => _deviceBuffer;
        public VkMemoryBlock Memory => _memory;

        public VkMemoryRequirements BufferMemoryRequirements => _bufferMemoryRequirements;

        public this(VKGraphicsDevice gd, uint32 sizeInBytes, BufferUsage usage, String callerMember = null)
        {
            _gd = gd;
            SizeInBytes = sizeInBytes;
            Usage = usage;

            VkBufferUsageFlags vkUsage = VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_DST_BIT;
            if ((usage & BufferUsage.VertexBuffer) == BufferUsage.VertexBuffer)
            {
                vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT;
            }
            if ((usage & BufferUsage.IndexBuffer) == BufferUsage.IndexBuffer)
            {
                vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_INDEX_BUFFER_BIT;
            }
            if ((usage & BufferUsage.UniformBuffer) == BufferUsage.UniformBuffer)
            {
                vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;
            }
            if ((usage & BufferUsage.StructuredBufferReadWrite) == BufferUsage.StructuredBufferReadWrite
                || (usage & BufferUsage.StructuredBufferReadOnly) == BufferUsage.StructuredBufferReadOnly)
            {
                vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT;
            }
            if ((usage & BufferUsage.IndirectBuffer) == BufferUsage.IndirectBuffer)
            {
                vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT;
            }

            VkBufferCreateInfo bufferCI = VkBufferCreateInfo() {sType = .VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO};
            bufferCI.size = sizeInBytes;
            bufferCI.usage = vkUsage;
            VkResult result = vkCreateBuffer(gd.Device, &bufferCI, null, &_deviceBuffer);
            CheckResult(result);

            bool prefersDedicatedAllocation;
            if (_gd.GetBufferMemoryRequirements2 != null)
            {
                VkBufferMemoryRequirementsInfo2 memReqInfo2 = VkBufferMemoryRequirementsInfo2() {sType = .VK_STRUCTURE_TYPE_BUFFER_MEMORY_REQUIREMENTS_INFO_2};
                memReqInfo2.buffer = _deviceBuffer;
                VkMemoryRequirements2 memReqs2 = VkMemoryRequirements2() {sType = .VK_STRUCTURE_TYPE_MEMORY_REQUIREMENTS_2};
                VkMemoryDedicatedRequirements dedicatedReqs = VkMemoryDedicatedRequirements(){sType = .VK_STRUCTURE_TYPE_MEMORY_DEDICATED_REQUIREMENTS};
                memReqs2.pNext = &dedicatedReqs;
                _gd.GetBufferMemoryRequirements2(_gd.Device, &memReqInfo2, &memReqs2);
                _bufferMemoryRequirements = memReqs2.memoryRequirements;
                prefersDedicatedAllocation = dedicatedReqs.prefersDedicatedAllocation || dedicatedReqs.requiresDedicatedAllocation;
            }
            else
            {
                vkGetBufferMemoryRequirements(gd.Device, _deviceBuffer, &_bufferMemoryRequirements);
                prefersDedicatedAllocation = false;
            }

            var isStaging = (usage & BufferUsage.Staging) == BufferUsage.Staging;
            var hostVisible = isStaging || (usage & BufferUsage.Dynamic) == BufferUsage.Dynamic;

            VkMemoryPropertyFlags memoryPropertyFlags =
                hostVisible
                ? VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT
                : VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT;
            if (isStaging)
            {
                // Use "host cached" memory for staging when available, for better performance of GPU -> CPU transfers
                var hostCachedAvailable = TryFindMemoryType(
                    gd.PhysicalDeviceMemProperties,
                    _bufferMemoryRequirements.memoryTypeBits,
                    memoryPropertyFlags | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_CACHED_BIT,
                    ?);
                if (hostCachedAvailable)
                {
                    memoryPropertyFlags |= VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_CACHED_BIT;
                }
            }

            VkMemoryBlock memoryToken = gd.MemoryManager.Allocate(
                gd.PhysicalDeviceMemProperties,
                _bufferMemoryRequirements.memoryTypeBits,
                memoryPropertyFlags,
                hostVisible,
                _bufferMemoryRequirements.size,
                _bufferMemoryRequirements.alignment,
                prefersDedicatedAllocation,
                VkImage.Null,
                _deviceBuffer);
            _memory = memoryToken;
            result = vkBindBufferMemory(gd.Device, _deviceBuffer, _memory.DeviceMemory, _memory.Offset);
            CheckResult(result);

            RefCount = new ResourceRefCount(new => DisposeCore);
        }

        public override String Name
        {
            get => _name;
            set
            {
                _name = value;
                _gd.SetResourceName(this, value);
            }
        }

        public override void Dispose()
        {
            RefCount.Decrement();
        }

        private void DisposeCore()
        {
            if (!_destroyed)
            {
                _destroyed = true;
                vkDestroyBuffer(_gd.Device, _deviceBuffer, null);
                _gd.MemoryManager.Free(Memory);
            }
        }
    }
}
