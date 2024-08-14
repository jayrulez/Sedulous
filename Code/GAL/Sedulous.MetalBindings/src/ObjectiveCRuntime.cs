using System;

namespace Sedulous.MetalBindings
{
    public static class ObjectiveCRuntime
    {
        private const String ObjCLibrary = "/usr/lib/libobjc.A.dylib";

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, float a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, double a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, CGRect a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, void* a, uint32 b);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, void* a, NSRange b);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, MTLSize a, MTLSize b);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, void* c, uint d, MTLSize e);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, MTLClearColor a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, CGSize a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, void* a, uint b, uint c);
        //[Import(ObjCLibrary), LinkName("objc_msgSend")]
        //public static extern void objc_msgSend(void* receiver, Selector selector, void* a, uint b, uint c);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, MTLPrimitiveType a, uint b, uint c, uint d, uint e);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, MTLPrimitiveType a, uint b, uint c, uint d);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, NSRange a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, uint a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, MTLCommandBufferHandler a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, void* a, uint b);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, MTLViewport a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, MTLScissorRect a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, void* a, uint32 b, uint c);
        //[Import(ObjCLibrary), LinkName("objc_msgSend")]
        //public static extern void objc_msgSend(void* receiver, Selector selector, void* a, uint b);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, MTLPrimitiveType a, uint b, MTLIndexType c, void* d, uint e, uint f);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, MTLPrimitiveType a, MTLBuffer b, uint c);

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(
            void* receiver,
            Selector selector,
            MTLPrimitiveType a,
            uint b,
            MTLIndexType c,
            void* d,
            uint e,
            uint f,
            void* g,
            uint h);

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(
            void* receiver,
            Selector selector,
            MTLPrimitiveType a,
            MTLIndexType b,
            MTLBuffer c,
            uint d,
            MTLBuffer e,
            uint f);

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(
            void* receiver,
            Selector selector,
            MTLBuffer a,
            uint b,
            MTLBuffer c,
            uint d,
            uint e);

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(
            void* receiver,
            Selector selector,
            void* a,
            uint b,
            uint c,
            uint d,
            MTLSize e,
            void* f,
            uint g,
            uint h,
            MTLOrigin i);

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(
            void* receiver,
            Selector selector,
            MTLRegion a,
            uint b,
            uint c,
            void* d,
            uint e,
            uint f);

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(
            void* receiver,
            Selector selector,
            MTLTexture a,
            uint b,
            uint c,
            MTLOrigin d,
            MTLSize e,
            MTLBuffer f,
            uint g,
            uint h,
            uint i);

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(
            void* receiver,
            Selector selector,
            MTLTexture sourceTexture,
            uint sourceSlice,
            uint sourceLevel,
            MTLOrigin sourceOrigin,
            MTLSize sourceSize,
            MTLTexture destinationTexture,
            uint destinationSlice,
            uint destinationLevel,
            MTLOrigin destinationOrigin);

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern uint8* bytePtr_objc_msgSend(void* receiver, Selector selector);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern CGSize CGSize_objc_msgSend(void* receiver, Selector selector);


        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern uint8 byte_objc_msgSend(void* receiver, Selector selector);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern Bool8 bool8_objc_msgSend(void* receiver, Selector selector);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern Bool8 bool8_objc_msgSend(void* receiver, Selector selector, uint a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern Bool8 bool8_objc_msgSend(void* receiver, Selector selector, void* a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern Bool8 bool8_objc_msgSend(void* receiver, Selector selector, uint a, void* b);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern Bool8 bool8_objc_msgSend(void* receiver, Selector selector, uint32 a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern uint32 uint_objc_msgSend(void* receiver, Selector selector);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern float float_objc_msgSend(void* receiver, Selector selector);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]

        public static extern CGFloat CGFloat_objc_msgSend(void* receiver, Selector selector);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern double double_objc_msgSend(void* receiver, Selector selector);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void* IntPtr_objc_msgSend(void* receiver, Selector selector);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void* IntPtr_objc_msgSend(void* receiver, Selector selector, void* a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void* IntPtr_objc_msgSend(void* receiver, Selector selector, void* a, out NSError error);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void* IntPtr_objc_msgSend(void* receiver, Selector selector, uint32 a, uint32 b, NSRange c, NSRange d);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void* IntPtr_objc_msgSend(void* receiver, Selector selector, MTLComputePipelineDescriptor a, uint32 b, void* c, out NSError error);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void* IntPtr_objc_msgSend(void* receiver, Selector selector, uint32 a);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void* IntPtr_objc_msgSend(void* receiver, Selector selector, uint a);

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void* IntPtr_objc_msgSend(void* receiver, Selector selector, void* a, void* b, out NSError error);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void* IntPtr_objc_msgSend(void* receiver, Selector selector, void* a, uint b);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void* IntPtr_objc_msgSend(void* receiver, Selector selector, uint b, MTLResourceOptions c);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void* IntPtr_objc_msgSend(void* receiver, Selector selector, void* a, uint b, MTLResourceOptions c);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern uint UIntPtr_objc_msgSend(void* receiver, Selector selector);

        public static T objc_msgSend<T>(void* receiver, Selector selector) where T : struct
        {
            void* value = IntPtr_objc_msgSend(receiver, selector);
            return *(T*)value;
        }
        public static T objc_msgSend<T>(void* receiver, Selector selector, void* a) where T : struct
        {
            void* value = IntPtr_objc_msgSend(receiver, selector, a);
			return *(T*)value;
        }
        /*public static String string_objc_msgSend(void* receiver, Selector selector)
        {
            return objc_msgSend<NSString>(receiver, selector).GetValue();
        }*/
		public static void string_objc_msgSend(void* receiver, Selector selector, String name)
		{
		    objc_msgSend<NSString>(receiver, selector).GetValue(name);
		}

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, uint8 b);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, Bool8 b);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, uint32 b);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, float a, float b, float c, float d);
        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern void objc_msgSend(void* receiver, Selector selector, void* b);

        [Import(ObjCLibrary), LinkName("objc_msgSend_stret")]
        public static extern void objc_msgSend_stret(void* retPtr, void* receiver, Selector selector);
        public static T objc_msgSend_stret<T>(void* receiver, Selector selector) where T : struct
        {
            T ret = default(T);
            objc_msgSend_stret(&ret, receiver, selector);
            return ret;
        }

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern MTLClearColor MTLClearColor_objc_msgSend(void* receiver, Selector selector);

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern MTLSize MTLSize_objc_msgSend(void* receiver, Selector selector);

        [Import(ObjCLibrary), LinkName("objc_msgSend")]
        public static extern CGRect CGRect_objc_msgSend(void* receiver, Selector selector);

        // TODO: This should check the current processor type, struct size, etc.
        // At the moment there is no need because all existing occurences of
        // this can safely use the non-stret versions everywhere.
        public static bool UseStret<T>() => false;

        [Import(ObjCLibrary)]
        public static extern void* sel_registerName(uint8* namePtr);

        [Import(ObjCLibrary)]
        public static extern uint8* sel_getName(void* selector);

        [Import(ObjCLibrary)]
        public static extern void* objc_getClass(uint8* namePtr);

        [Import(ObjCLibrary)]
        public static extern ObjCClass object_getClass(void* obj);

        [Import(ObjCLibrary)]
        public static extern void* class_getProperty(ObjCClass cls, uint8* namePtr);

        [Import(ObjCLibrary)]
        public static extern uint8* class_getName(ObjCClass cls);

        [Import(ObjCLibrary)]
        public static extern uint8* property_copyAttributeValue(void* property, uint8* attributeNamePtr);

        [Import(ObjCLibrary)]
        public static extern Selector method_getName(ObjectiveCMethod method);

        [Import(ObjCLibrary)]
        public static extern ObjectiveCMethod* class_copyMethodList(ObjCClass cls, out uint32 outCount);

        [Import(ObjCLibrary)]
        public static extern void free(void* receiver);
        public static void retain(void* receiver) => objc_msgSend(receiver, "retain");
        public static void release(void* receiver) => objc_msgSend(receiver, "release");
        public static uint64 GetRetainCount(void* receiver) => (uint64)UIntPtr_objc_msgSend(receiver, "retainCount");
    }
}
