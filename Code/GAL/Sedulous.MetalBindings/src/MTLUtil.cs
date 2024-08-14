using System.Text;
using System;

namespace Sedulous.MetalBindings
{
    public static class MTLUtil
    {
        /*public static String GetUtf8String(uint8* stringStart)
        {
            int32 characters = 0;
            while (stringStart[characters] != 0)
            {
                characters++;
            }

            return Encoding.UTF8.GetString(stringStart, characters);
        }*/

        public static T AllocInit<T>(String typeName) where T : struct
        {
            var cls = ObjCClass(typeName);
            return cls.AllocInit<T>();
        }
    }
}