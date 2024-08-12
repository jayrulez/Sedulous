using System;
using System.Runtime.InteropServices;

namespace Sedulous.MetalBindings
{
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void MTLCommandBufferHandler(IntPtr block, MTLCommandBuffer buffer);
}