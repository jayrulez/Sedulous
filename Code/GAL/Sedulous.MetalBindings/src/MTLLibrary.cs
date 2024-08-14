using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    [CRepr]
    public struct MTLLibrary
    {
        public readonly void* NativePtr;
        public this(void* ptr) => NativePtr = ptr;

        public MTLFunction newFunctionWithName(String name)
        {
            NSString nameNSS = NSString.New(name);
            void* @function = IntPtr_objc_msgSend(NativePtr, sel_newFunctionWithName, nameNSS);
            release(nameNSS.NativePtr);
            return MTLFunction(@function);
        }

        public MTLFunction newFunctionWithNameConstantValues(String name, MTLFunctionConstantValues constantValues)
        {
            NSString nameNSS = NSString.New(name);
            void* @function = IntPtr_objc_msgSend(
                NativePtr,
                sel_newFunctionWithNameConstantValues,
                nameNSS.NativePtr,
                constantValues.NativePtr,
                var error);
            release(nameNSS.NativePtr);

            if (@function == null)
            {
                Runtime.FatalError(scope $"Failed to create MTLFunction: {error.localizedDescription(.. scope .())}");
            }

            return MTLFunction(@function);
        }

        private static readonly Selector sel_newFunctionWithName = "newFunctionWithName:";
        private static readonly Selector sel_newFunctionWithNameConstantValues = "newFunctionWithName:constantValues:error:";
    }
}