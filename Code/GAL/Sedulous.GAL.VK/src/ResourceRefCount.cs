using System;
using System.Threading;

namespace Sedulous.GAL.VK
{
    internal class ResourceRefCount
    {
        private readonly Action _disposeAction;
        private int32 _refCount;

        public ResourceRefCount(Action disposeAction)
        {
            _disposeAction = disposeAction;
            _refCount = 1;
        }

        public int32 Increment()
        {
            int32 ret = Interlocked.Increment(ref _refCount);
#if VALIDATE_USAGE
            if (ret == 0)
            {
                Runtime.GALError("An attempt was made to reference a disposed resource.");
            }
#endif
            return ret;
        }

        public int32 Decrement()
        {
            int32 ret = Interlocked.Decrement(ref _refCount);
            if (ret == 0)
            {
                _disposeAction();
            }

            return ret;
        }
    }
}
