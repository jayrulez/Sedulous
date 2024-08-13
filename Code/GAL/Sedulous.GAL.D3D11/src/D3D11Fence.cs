using System;
using System.Threading;
using Win32;

namespace Sedulous.GAL.D3D11
{
    internal class D3D11Fence : Fence
    {
        private readonly ManualResetEvent _mre;
        private bool _disposed;

        public this(bool signaled)
        {
            _mre = new ManualResetEvent(signaled);
        }

        public override String Name { get; set; }
        public ManualResetEvent ResetEvent => _mre;

        public void Set() => _mre.Set();
        public override void Reset() => _mre.Reset();
        public override bool Signaled => _mre.WaitOne(0);
        public override bool IsDisposed => _disposed;

        public override void Dispose()
        {
            if (!_disposed)
            {
                _mre.Dispose();
                _disposed = true;
            }
        }

        internal bool Wait(uint64 nanosecondTimeout)
        {
            uint64 timeout = Math.Min(uint32.MaxValue, nanosecondTimeout / 1000000);
            return _mre.WaitOne((uint32)timeout);
        }
    }
}