using System;
using System.Runtime.InteropServices;

namespace Sedulous.MetalBindings
{
    [StructLayout(LayoutKind.Sequential)]
    public struct MTLSize
    {
        public UIntPtr Width;
        public UIntPtr Height;
        public UIntPtr Depth;

        public MTLSize(uint32 width, uint32 height, uint32 depth)
        {
            Width = (UIntPtr)width;
            Height = (UIntPtr)height;
            Depth = (UIntPtr)depth;
        }
    }
}