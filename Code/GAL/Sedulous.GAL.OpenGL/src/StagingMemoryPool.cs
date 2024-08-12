using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

namespace Sedulous.GAL.OpenGL
{
    internal sealed class StagingMemoryPool : IDisposable
    {
        private const uint32 MinimumCapacity = 128;

        private readonly List<StagingBlock> _storage;
        private readonly SortedList<uint32, uint32> _availableBlocks;
        private object _lock = new object();
        private bool _disposed;

        public StagingMemoryPool()
        {
            _storage = new List<StagingBlock>();
            _availableBlocks = new SortedList<uint32, uint32>(new CapacityComparer());
        }

        public StagingBlock Stage(IntPtr source, uint32 sizeInBytes)
        {
            Rent(sizeInBytes, out StagingBlock block);
            Unsafe.CopyBlock(block.Data, source.ToPointer(), sizeInBytes);
            return block;
        }

        public StagingBlock Stage(uint8[] bytes)
        {
            Rent((uint32)bytes.Length, out StagingBlock block);
            Marshal.Copy(bytes, 0, (IntPtr)block.Data, bytes.Length);
            return block;
        }

        public StagingBlock GetStagingBlock(uint32 sizeInBytes)
        {
            Rent(sizeInBytes, out StagingBlock block);
            return block;
        }

        public StagingBlock RetrieveById(uint32 id)
        {
            return _storage[(int32)id];
        }

        private void Rent(uint32 size, out StagingBlock block)
        {
            lock (_lock)
            {
                SortedList<uint32, uint32> available = _availableBlocks;
                IList<uint32> indices = available.Values;
                for (int32 i = 0; i < available.Count; i++)
                {
                    int32 index = (int32)indices[i];
                    StagingBlock current = _storage[index];
                    if (current.Capacity >= size)
                    {
                        available.RemoveAt(i);
                        current.SizeInBytes = size;
                        block = current;
                        _storage[index] = current;
                        return;
                    }
                }

                Allocate(size, out block);
            }
        }

        private void Allocate(uint32 sizeInBytes, out StagingBlock stagingBlock)
        {
            uint32 capacity = Math.Max(MinimumCapacity, sizeInBytes);
            IntPtr ptr = Marshal.AllocHGlobal((int32)capacity);
            uint32 id = (uint32)_storage.Count;
            stagingBlock = new StagingBlock(id, (void*)ptr, capacity, sizeInBytes);
            _storage.Add(stagingBlock);
        }

        public void Free(StagingBlock block)
        {
            lock (_lock)
            {
                if (!_disposed)
                {
                    Debug.Assert(block.Id < _storage.Count);
                    _availableBlocks.Add(block.Capacity, block.Id);
                }
            }
        }

        public void Dispose()
        {
            lock (_lock)
            {
                _availableBlocks.Clear();
                for (StagingBlock block in _storage)
                {
                    Marshal.FreeHGlobal((IntPtr)block.Data);
                }
                _storage.Clear();
                _disposed = true;
            }
        }

        private class CapacityComparer : IComparer<uint32>
        {
            public int32 Compare(uint32 x, uint32 y)
            {
                return x >= y ? 1 : -1;
            }
        }
    }

    internal struct StagingBlock
    {
        public readonly uint32 Id;
        public readonly void* Data;
        public readonly uint32 Capacity;
        public uint32 SizeInBytes;

        public StagingBlock(uint32 id, void* data, uint32 capacity, uint32 size)
        {
            Id = id;
            Data = data;
            Capacity = capacity;
            SizeInBytes = size;
        }
    }
}
