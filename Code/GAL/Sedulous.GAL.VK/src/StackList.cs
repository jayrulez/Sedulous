﻿using System;
using System.Diagnostics;
using System.Runtime.CompilerServices;

namespace Sedulous.GAL.VK
{
    /// <summary>
    /// A super-dangerous stack-only list which can hold up to 256 bytes of blittable data.
    /// </summary>
    /// <typeparam name="T">The type of element held in the list. Must be blittable.</typeparam>
    internal struct StackList<T> where T : struct
    {
        public const int32 CapacityInBytes = 256;
        private static readonly int32 s_sizeofT = Unsafe.SizeOf<T>();

        private fixed uint8 _storage[CapacityInBytes];
        private uint32 _count;

        public uint32 Count => _count;
        public void* Data => Unsafe.AsPointer(ref this);

        public void Add(T item)
        {
            uint8* basePtr = (uint8*)Data;
            int32 offset = (int32)(_count * s_sizeofT);
#if DEBUG
            Debug.Assert((offset + s_sizeofT) <= CapacityInBytes);
#endif
            Unsafe.Write(basePtr + offset, item);

            _count += 1;
        }

        public ref T this[uint32 index]
        {
            get
            {
                uint8* basePtr = (uint8*)Unsafe.AsPointer(ref this);
                int32 offset = (int32)(index * s_sizeofT);
                return ref Unsafe.AsRef<T>(basePtr + offset);
            }
        }

        public ref T this[int32 index]
        {
            get
            {
                uint8* basePtr = (uint8*)Unsafe.AsPointer(ref this);
                int32 offset = index * s_sizeofT;
                return ref Unsafe.AsRef<T>(basePtr + offset);
            }
        }
    }

    /// <summary>
    /// A super-dangerous stack-only list which can hold a number of bytes determined by the second type parameter.
    /// </summary>
    /// <typeparam name="T">The type of element held in the list. Must be blittable.</typeparam>
    /// <typeparam name="TSize">A type parameter dictating the capacity of the list.</typeparam>
    internal struct StackList<T, TSize> where T : struct where TSize : struct
    {
        private static readonly int32 s_sizeofT = Unsafe.SizeOf<T>();

#pragma warning disable 0169 // Unused field. This is used implicity because it controls the size of the structure on the stack.
        private TSize _storage;
#pragma warning restore 0169
        private uint32 _count;

        public uint32 Count => _count;
        public void* Data => Unsafe.AsPointer(ref this);

        public void Add(T item)
        {
            ref T dest = ref Unsafe.Add(ref Unsafe.As<TSize, T>(ref _storage), (int32)_count);
#if DEBUG
            int32 offset = (int32)(_count * s_sizeofT);
            Debug.Assert((offset + s_sizeofT) <= Unsafe.SizeOf<TSize>());
#endif
            dest = item;

            _count += 1;
        }

        public ref T this[int32 index] => ref Unsafe.Add(ref Unsafe.AsRef<T>(Data), index);
        public ref T this[uint32 index] => ref Unsafe.Add(ref Unsafe.AsRef<T>(Data), (int32)index);
    }

    internal struct Size16Bytes { public fixed uint8 Data[16]; }
    internal struct Size64Bytes { public fixed uint8 Data[64]; }
    internal struct Size128Bytes { public fixed uint8 Data[64]; }
    internal struct Size512Bytes { public fixed uint8 Data[1024]; }
    internal struct Size1024Bytes { public fixed uint8 Data[1024]; }
    internal struct Size2048Bytes { public fixed uint8 Data[2048]; }
#pragma warning disable 0649 // Fields are not assigned directly -- expected.
    internal struct Size2IntPtr { public IntPtr First; public IntPtr Second; }
    internal struct Size6IntPtr { public IntPtr First; public IntPtr Second; public IntPtr Third; public IntPtr Fourth; public IntPtr Fifth; public IntPtr Sixth; }
#pragma warning restore 0649
}
