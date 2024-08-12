using System;

namespace Sedulous.GAL
{
    internal struct SmallFixedOrDynamicArray : IDisposable
    {
        private const int MaxFixedValues = 5;

        public readonly uint32 Count;
        private uint32[MaxFixedValues] FixedData = .();
        public readonly uint32[] Data;

        public uint32 Get(uint32 i) => Count > MaxFixedValues ? Data[i] : FixedData[i];

        public this(uint32 count, ref uint32* data)
        {
            if (count > MaxFixedValues)
            {
                Data = new uint32[(int32)count];
            }
            else
            {
                for (int i = 0; i < count; i++)
                {
                    FixedData[i] = data[i];
                }

                Data = null;
            }

            Count = count;
        }

        public void Dispose()
        {
            if (Data != null) { delete Data; }
        }
    }
}
