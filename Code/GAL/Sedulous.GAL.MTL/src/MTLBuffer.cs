using System;
using Sedulous.MetalBindings;

namespace Sedulous.GAL.MTL
{
    internal class MTLBuffer : DeviceBuffer
    {
        private string _name;
        private bool _disposed;

        public override uint32 SizeInBytes { get; }
        public override BufferUsage Usage { get; }

        public uint32 ActualCapacity { get; }

        public override string Name
        {
            get => _name;
            set
            {
                NSString nameNSS = NSString.New(value);
                DeviceBuffer.addDebugMarker(nameNSS, new NSRange(0, SizeInBytes));
                ObjectiveCRuntime.release(nameNSS.NativePtr);
                _name = value;
            }
        }

        public override bool IsDisposed => _disposed;

        public MetalBindings.MTLBuffer DeviceBuffer { get; private set; }

        public MTLBuffer(ref BufferDescription bd, MTLGraphicsDevice gd)
        {
            SizeInBytes = bd.SizeInBytes;
            uint32 roundFactor = (4 - (SizeInBytes % 4)) % 4;
            ActualCapacity = SizeInBytes + roundFactor;
            Usage = bd.Usage;
            DeviceBuffer = gd.Device.newBufferWithLengthOptions(
                (UIntPtr)ActualCapacity,
                0);
        }

        public override void Dispose()
        {
            if (!_disposed)
            {
                _disposed = true;
                ObjectiveCRuntime.release(DeviceBuffer.NativePtr);
            }
        }
    }
}
