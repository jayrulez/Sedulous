using System;
using System.Text;

namespace Sedulous.MetalBindings
{
	using internal Sedulous.MetalBindings;

    public struct ObjCClass
    {
        public readonly void* NativePtr;
        public static implicit operator void*(ObjCClass c) => c.NativePtr;

        public this(String name)
        {
            NativePtr = ObjectiveCRuntime.objc_getClass((uint8*)name.Ptr);
        }

        public void* GetProperty(String propertyName)
        {
            return ObjectiveCRuntime.class_getProperty(this, (uint8*)propertyName.Ptr);
        }

        public String Name => MTLUtil.GetUtf8String(ObjectiveCRuntime.class_getName(this));

        public T Alloc<T>() where T : struct
        {
            void* value = ObjectiveCRuntime.IntPtr_objc_msgSend(NativePtr, Selectors.alloc);
            return *(T*)value;
        }

        public T AllocInit<T>() where T : struct
        {
            void* value = ObjectiveCRuntime.IntPtr_objc_msgSend(NativePtr, Selectors.alloc);
            ObjectiveCRuntime.objc_msgSend(value, Selectors.init);
            return *(T*)value;
        }

        public ObjectiveCMethod* class_copyMethodList(out uint32 count)
        {
            return ObjectiveCRuntime.class_copyMethodList(this, out count);
        }
    }
}