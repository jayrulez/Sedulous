using System;
using Vortice.Direct3D11;
using System.Collections.Generic;
using Vortice.DXGI;
using Vortice.Direct3D;

namespace Sedulous.GAL.D3D11
{
    internal class D3D11Buffer : DeviceBuffer
    {
        private readonly ID3D11Device _device;
        private readonly ID3D11Buffer _buffer;
        private readonly object _accessViewLock = new object();
        private readonly Dictionary<OffsetSizePair, ID3D11ShaderResourceView> _srvs
            = new Dictionary<OffsetSizePair, ID3D11ShaderResourceView>();
        private readonly Dictionary<OffsetSizePair, ID3D11UnorderedAccessView> _uavs
            = new Dictionary<OffsetSizePair, ID3D11UnorderedAccessView>();
        private readonly uint32 _structureByteStride;
        private readonly bool _rawBuffer;
        private string _name;

        public override uint32 SizeInBytes { get; }

        public override BufferUsage Usage { get; }

        public override bool IsDisposed => _buffer.NativePointer == IntPtr.Zero;

        public ID3D11Buffer Buffer => _buffer;

        public D3D11Buffer(ID3D11Device device, uint32 sizeInBytes, BufferUsage usage, uint32 structureByteStride, bool rawBuffer)
        {
            _device = device;
            SizeInBytes = sizeInBytes;
            Usage = usage;
            _structureByteStride = structureByteStride;
            _rawBuffer = rawBuffer;

            Vortice.Direct3D11.BufferDescription bd = new Vortice.Direct3D11.BufferDescription(
                (int32)sizeInBytes,
                D3D11Formats.VdToD3D11BindFlags(usage),
                ResourceUsage.Default);
            if ((usage & BufferUsage.StructuredBufferReadOnly) == BufferUsage.StructuredBufferReadOnly
                || (usage & BufferUsage.StructuredBufferReadWrite) == BufferUsage.StructuredBufferReadWrite)
            {
                if (rawBuffer)
                {
                    bd.MiscFlags = ResourceOptionFlags.BufferAllowRawViews;
                }
                else
                {
                    bd.MiscFlags = ResourceOptionFlags.BufferStructured;
                    bd.StructureByteStride = (int32)structureByteStride;
                }
            }
            if ((usage & BufferUsage.IndirectBuffer) == BufferUsage.IndirectBuffer)
            {
                bd.MiscFlags = ResourceOptionFlags.DrawIndirectArguments;
            }

            if ((usage & BufferUsage.Dynamic) == BufferUsage.Dynamic)
            {
                bd.Usage = ResourceUsage.Dynamic;
                bd.CPUAccessFlags = CpuAccessFlags.Write;
            }
            else if ((usage & BufferUsage.Staging) == BufferUsage.Staging)
            {
                bd.Usage = ResourceUsage.Staging;
                bd.CPUAccessFlags = CpuAccessFlags.Read | CpuAccessFlags.Write;
            }

            _buffer = device.CreateBuffer(bd);
        }

        public override string Name
        {
            get => _name;
            set
            {
                _name = value;
                Buffer.DebugName = value;
                for (KeyValuePair<OffsetSizePair, ID3D11ShaderResourceView> kvp in _srvs)
                {
                    kvp.Value.DebugName = value + "_SRV";
                }
                for (KeyValuePair<OffsetSizePair, ID3D11UnorderedAccessView> kvp in _uavs)
                {
                    kvp.Value.DebugName = value + "_UAV";
                }
            }
        }

        public override void Dispose()
        {
            for (KeyValuePair<OffsetSizePair, ID3D11ShaderResourceView> kvp in _srvs)
            {
                kvp.Value.Dispose();
            }
            for (KeyValuePair<OffsetSizePair, ID3D11UnorderedAccessView> kvp in _uavs)
            {
                kvp.Value.Dispose();
            }
            _buffer.Dispose();
        }

        internal ID3D11ShaderResourceView GetShaderResourceView(uint32 offset, uint32 size)
        {
            lock (_accessViewLock)
            {
                OffsetSizePair pair = new OffsetSizePair(offset, size);
                if (!_srvs.TryGetValue(pair, out ID3D11ShaderResourceView srv))
                {
                    srv = CreateShaderResourceView(offset, size);
                    _srvs.Add(pair, srv);
                }

                return srv;
            }
        }

        internal ID3D11UnorderedAccessView GetUnorderedAccessView(uint32 offset, uint32 size)
        {
            lock (_accessViewLock)
            {
                OffsetSizePair pair = new OffsetSizePair(offset, size);
                if (!_uavs.TryGetValue(pair, out ID3D11UnorderedAccessView uav))
                {
                    uav = CreateUnorderedAccessView(offset, size);
                    _uavs.Add(pair, uav);
                }

                return uav;
            }
        }

        private ID3D11ShaderResourceView CreateShaderResourceView(uint32 offset, uint32 size)
        {
            if (_rawBuffer)
            {
                ShaderResourceViewDescription srvDesc = new ShaderResourceViewDescription(_buffer,
                    Format.R32_Typeless,
                    (int32)offset / 4,
                    (int32)size / 4,
                    BufferExtendedShaderResourceViewFlags.Raw);

                return _device.CreateShaderResourceView(_buffer, srvDesc);
            }
            else
            {
                ShaderResourceViewDescription srvDesc = new ShaderResourceViewDescription
                {
                    ViewDimension = ShaderResourceViewDimension.Buffer
                };
                srvDesc.Buffer.NumElements = (int32)(size / _structureByteStride);
                srvDesc.Buffer.ElementOffset = (int32)(offset / _structureByteStride);
                return _device.CreateShaderResourceView(_buffer, srvDesc);
            }
        }

        private ID3D11UnorderedAccessView CreateUnorderedAccessView(uint32 offset, uint32 size)
        {
            if (_rawBuffer)
            {
                UnorderedAccessViewDescription uavDesc = new UnorderedAccessViewDescription(_buffer,
                    Format.R32_Typeless,
                    (int32)offset / 4,
                    (int32)size / 4,
                    BufferUnorderedAccessViewFlags.Raw);

                return _device.CreateUnorderedAccessView(_buffer, uavDesc);
            }
            else
            {
                UnorderedAccessViewDescription uavDesc = new UnorderedAccessViewDescription(_buffer,
                    Format.Unknown,
                    (int32)(offset / _structureByteStride),
                    (int32)(size / _structureByteStride)
                    );

                return _device.CreateUnorderedAccessView(_buffer, uavDesc);
            }
        }

        private struct OffsetSizePair : IEquatable<OffsetSizePair>
        {
            public readonly uint32 Offset;
            public readonly uint32 Size;

            public OffsetSizePair(uint32 offset, uint32 size)
            {
                Offset = offset;
                Size = size;
            }

            public bool Equals(OffsetSizePair other) => Offset.Equals(other.Offset) && Size.Equals(other.Size);
            public override int32 GetHashCode() => HashHelper.Combine(Offset.GetHashCode(), Size.GetHashCode());
        }
    }
}
