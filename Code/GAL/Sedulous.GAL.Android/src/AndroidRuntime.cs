using System;

namespace Sedulous.GAL.Android
{
    /// <summary>
    /// Function imports from the Android runtime library (android.so).
    /// </summary>
    internal static class AndroidRuntime
    {
        private const String LibName = "android.so";

        [Import(LibName)]
        public static extern void* ANativeWindow_fromSurface(void* jniEnv, void* surface);
        [Import(LibName)]
        public static extern int32 ANativeWindow_setBuffersGeometry(void* aNativeWindow, int32 width, int32 height, int32 format);
        [Import(LibName)]
        public static extern void ANativeWindow_release(void* aNativeWindow);
    }
}
