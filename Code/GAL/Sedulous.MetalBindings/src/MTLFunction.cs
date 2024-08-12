using static Sedulous.MetalBindings.ObjectiveCRuntime;
using System;

namespace Sedulous.MetalBindings
{
    public struct MTLFunction
    {
        public readonly IntPtr NativePtr;
        public MTLFunction(IntPtr ptr) => NativePtr = ptr;

        public NSDictionary functionConstantsDictionary => objc_msgSend<NSDictionary>(NativePtr, sel_functionConstantsDictionary);

        private static readonly Selector sel_functionConstantsDictionary = "functionConstantsDictionary";
    }
}