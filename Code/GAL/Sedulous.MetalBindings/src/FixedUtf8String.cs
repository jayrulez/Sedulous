using System;
using System.Runtime.InteropServices;
using System.Text;

namespace Sedulous.MetalBindings
{
    internal class FixedUtf8String : IDisposable
    {
        private GCHandle _handle;
        private uint32 _numBytes;

        public uint8* StringPtr => (uint8*)_handle.AddrOfPinnedObject().ToPointer();

        public FixedUtf8String(string s)
        {
            if (s == null)
            {
                throw new ArgumentNullException(nameof(s));
            }

            uint8[] text = Encoding.UTF8.GetBytes(s);
            _handle = GCHandle.Alloc(text, GCHandleType.Pinned);
            _numBytes = (uint32)text.Length;
        }

        public void SetText(string s)
        {
            if (s == null)
            {
                throw new ArgumentNullException(nameof(s));
            }

            _handle.Free();
            uint8[] text = Encoding.UTF8.GetBytes(s);
            _handle = GCHandle.Alloc(text, GCHandleType.Pinned);
            _numBytes = (uint32)text.Length;
        }

        private string GetString()
        {
            return Encoding.UTF8.GetString(StringPtr, (int32)_numBytes);
        }

        public void Dispose()
        {
            _handle.Free();
        }

        public static implicit operator uint8* (FixedUtf8String utf8String) => utf8String.StringPtr;
        public static implicit operator IntPtr(FixedUtf8String utf8String) => new IntPtr(utf8String.StringPtr);
        public static implicit operator FixedUtf8String(string s) => new FixedUtf8String(s);
        public static implicit operator string(FixedUtf8String utf8String) => utf8String.GetString();
    }
}
