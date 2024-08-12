using System;

namespace Sedulous.MetalBindings
{
    public struct MTLFunctionConstantValues
    {
        public readonly IntPtr NativePtr;

        public static MTLFunctionConstantValues New()
        {
            return s_class.AllocInit<MTLFunctionConstantValues>();
        }

        public void setConstantValuetypeatIndex(void* value, MTLDataType type, UIntPtr index)
        {
            ObjectiveCRuntime.objc_msgSend(NativePtr, sel_setConstantValuetypeatIndex, value, (uint32)type, index);
        }

        private static readonly ObjCClass s_class = new ObjCClass(nameof(MTLFunctionConstantValues));
        private static readonly Selector sel_setConstantValuetypeatIndex = "setConstantValue:type:atIndex:";
    }
}
