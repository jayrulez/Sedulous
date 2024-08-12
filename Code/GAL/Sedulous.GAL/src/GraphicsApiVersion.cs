using System;

namespace Sedulous.GAL
{
    public struct GraphicsApiVersion
    {
        public static GraphicsApiVersion Unknown => default;

        public int32 Major { get; }
        public int32 Minor { get; }
        public int32 Subminor { get; }
        public int32 Patch { get; }

        public bool IsKnown => Major != 0 && Minor != 0 && Subminor != 0 && Patch != 0;

        public this(int32 major, int32 minor, int32 subminor, int32 patch)
        {
            Major = major;
            Minor = minor;
            Subminor = subminor;
            Patch = patch;
        }

        public override void ToString(String str)
        {
            str.Append(scope $"{Major}.{Minor}.{Subminor}.{Patch}");
        }
    }
}
