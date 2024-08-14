using System;

namespace Sedulous.MetalBindings
{
    //[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
	[CallingConvention(.Cdecl)]
    public function void MTLCommandBufferHandler(void* block, MTLCommandBuffer buffer);
}