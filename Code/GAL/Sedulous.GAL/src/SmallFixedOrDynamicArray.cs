using System;
using System.Buffers;
using System.Runtime.CompilerServices;

namespace Veldrid
{
    internal struct SmallFixedOrDynamicArray : IDisposable
    {
        private const int32 MaxFixedValues = 5;

        public readonly uint32 Count;
        private fixed uint32 FixedData[MaxFixedValues];
        public readonly uint32[] Data;

        public uint32 Get(uint32 i) => Count > MaxFixedValues ? Data[i] : FixedData[i];

        public SmallFixedOrDynamicArray(uint32 count, ref uint32 data)
        {
            if (count > MaxFixedValues)
            {
                Data = ArrayPool<uint32>.Shared.Rent((int32)count);
            }
            else
            {
                for (int32 i = 0; i < count; i++)
                {
                    FixedData[i] = Unsafe.Add(ref data, i);
                }

                Data = null;
            }

            Count = count;
        }

        public void Dispose()
        {
            if (Data != null) { ArrayPool<uint32>.Shared.Return(Data); }
        }
    }
}
