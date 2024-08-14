using System;
using Sedulous.MetalBindings;

namespace Sedulous.GAL.MTL
{
    public class MTLBuffer : DeviceBuffer
    {
        private String _name;
        private bool _disposed;

        public override uint32 SizeInBytes { get; protected set; }
        public override BufferUsage Usage { get; protected set; }

        public uint32 ActualCapacity { get; }

        public override String Name
        {
            get => _name;
            set
            {
                NSString nameNSS = NSString.New(value);
                DeviceBuffer.addDebugMarker(nameNSS, NSRange(0, SizeInBytes));
                ObjectiveCRuntime.release(nameNSS.NativePtr);
                _name = value;
            }
        }

        public override bool IsDisposed => _disposed;

        public Sedulous.MetalBindings.MTLBuffer DeviceBuffer { get; private set; }

        public this(in BufferDescription bd, MTLGraphicsDevice gd)
        {
            SizeInBytes = bd.SizeInBytes;
            uint32 roundFactor = (4 - (SizeInBytes % 4)) % 4;
            ActualCapacity = SizeInBytes + roundFactor;
            Usage = bd.Usage;
            DeviceBuffer = gd.Device.newBufferWithLengthOptions(
                (uint)ActualCapacity,
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
