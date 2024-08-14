using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
	using internal Sedulous.MetalBindings;

    [CRepr]
    public struct CAMetalDrawable
    {
        public readonly void* NativePtr;
        public bool IsNull => NativePtr == null;
        public MTLTexture texture => objc_msgSend<MTLTexture>(NativePtr, Selectors.texture);
    }
}