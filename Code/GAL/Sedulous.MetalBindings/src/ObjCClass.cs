using System;
using System.Runtime.CompilerServices;
using System.Text;

namespace Sedulous.MetalBindings
{
    public struct ObjCClass
    {
        public readonly IntPtr NativePtr;
        public static implicit operator IntPtr(ObjCClass c) => c.NativePtr;

        public ObjCClass(string name)
        {
            int32 byteCount = Encoding.UTF8.GetMaxByteCount(name.Length);
            uint8* utf8BytesPtr = stackalloc uint8[byteCount];
            fixed (char* namePtr = name)
            {
                Encoding.UTF8.GetBytes(namePtr, name.Length, utf8BytesPtr, byteCount);
            }

            NativePtr = ObjectiveCRuntime.objc_getClass(utf8BytesPtr);
        }

        public IntPtr GetProperty(string propertyName)
        {
            int32 byteCount = Encoding.UTF8.GetMaxByteCount(propertyName.Length);
            uint8* utf8BytesPtr = stackalloc uint8[byteCount];
            fixed (char* namePtr = propertyName)
            {
                Encoding.UTF8.GetBytes(namePtr, propertyName.Length, utf8BytesPtr, byteCount);
            }

            return ObjectiveCRuntime.class_getProperty(this, utf8BytesPtr);
        }

        public string Name => MTLUtil.GetUtf8String(ObjectiveCRuntime.class_getName(this));

        public T Alloc<T>() where T : struct
        {
            IntPtr value = ObjectiveCRuntime.IntPtr_objc_msgSend(NativePtr, Selectors.alloc);
            return Unsafe.AsRef<T>(&value);
        }

        public T AllocInit<T>() where T : struct
        {
            IntPtr value = ObjectiveCRuntime.IntPtr_objc_msgSend(NativePtr, Selectors.alloc);
            ObjectiveCRuntime.objc_msgSend(value, Selectors.init);
            return Unsafe.AsRef<T>(&value);
        }

        public ObjectiveCMethod* class_copyMethodList(out uint32 count)
        {
            return ObjectiveCRuntime.class_copyMethodList(this, out count);
        }
    }
}