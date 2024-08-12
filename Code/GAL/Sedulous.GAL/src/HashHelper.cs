using System.Diagnostics;

namespace Veldrid
{
    internal static class HashHelper
    {
        public static int32 Combine(int32 value1, int32 value2)
        {
            uint32 rol5 = ((uint32)value1 << 5) | ((uint32)value1 >> 27);
            return ((int32)rol5 + value1) ^ value2;
        }

        public static int32 Combine(int32 value1, int32 value2, int32 value3)
        {
            return Combine(value1, Combine(value2, value3));
        }

        public static int32 Combine(int32 value1, int32 value2, int32 value3, int32 value4)
        {
            return Combine(value1, Combine(value2, Combine(value3, value4)));
        }

        public static int32 Combine(int32 value1, int32 value2, int32 value3, int32 value4, int32 value5)
        {
            return Combine(value1, Combine(value2, Combine(value3, Combine(value4, value5))));
        }

        public static int32 Combine(int32 value1, int32 value2, int32 value3, int32 value4, int32 value5, int32 value6)
        {
            return Combine(value1, Combine(value2, Combine(value3, Combine(value4, Combine(value5, value6)))));
        }

        public static int32 Combine(int32 value1, int32 value2, int32 value3, int32 value4, int32 value5, int32 value6, int32 value7)
        {
            return Combine(value1, Combine(value2, Combine(value3, Combine(value4, Combine(value5, Combine(value6, value7))))));
        }

        public static int32 Combine(int32 value1, int32 value2, int32 value3, int32 value4, int32 value5, int32 value6, int32 value7, int32 value8)
        {
            return Combine(value1, Combine(value2, Combine(value3, Combine(value4, Combine(value5, Combine(value6, Combine(value7, value8)))))));
        }

        public static int32 Combine(int32 value1, int32 value2, int32 value3, int32 value4, int32 value5, int32 value6, int32 value7, int32 value8, int32 value9)
        {
            return Combine(value1, Combine(value2, Combine(value3, Combine(value4, Combine(value5, Combine(value6, Combine(value7, Combine(value8, value9))))))));
        }

        public static int32 Combine(int32 value1, int32 value2, int32 value3, int32 value4, int32 value5, int32 value6, int32 value7, int32 value8, int32 value9, int32 value10)
        {
            return Combine(value1, Combine(value2, Combine(value3, Combine(value4, Combine(value5, Combine(value6, Combine(value7, Combine(value8, Combine(value9, value10)))))))));
        }

        public static int32 Array<T>(T[] items)
        {
            if (items == null || items.Length == 0)
            {
                return 0;
            }

            int32 hash = items[0].GetHashCode();
            for (int32 i = 1; i < items.Length; i++)
            {
                hash = Combine(hash, items[i]?.GetHashCode() ?? i);
            }

            return hash;
        }
    }
}
