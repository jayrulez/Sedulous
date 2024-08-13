using System;
using Win32.Graphics.Direct3D11;
using System.Threading;
using System.Collections;
using Win32.Foundation;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL.D3D11;

    internal class D3D11Buffer : DeviceBuffer
    {
        private readonly ID3D11Device* _device;
        private /*readonly*/ ID3D11Buffer* _buffer;
        private readonly Monitor _accessViewLock = new .() ~ delete _;
        private readonly Dictionary<OffsetSizePair, ID3D11ShaderResourceView*> _srvs = new .();
        private readonly Dictionary<OffsetSizePair, ID3D11UnorderedAccessView*> _uavs = new .();
        private readonly uint32 _structureByteStride;
        private readonly bool _rawBuffer;
        private String _name;

        public override uint32 SizeInBytes { get; protected set; }

        public override BufferUsage Usage { get; protected set; }

        public override bool IsDisposed => _buffer == null;

        public ref ID3D11Buffer* Buffer => ref _buffer;

        public this(ID3D11Device* device, uint32 sizeInBytes, BufferUsage usage, uint32 structureByteStride, bool rawBuffer)
        {
            _device = device;
            SizeInBytes = sizeInBytes;
            Usage = usage;
            _structureByteStride = structureByteStride;
            _rawBuffer = rawBuffer;

            D3D11_BUFFER_DESC bd = D3D11_BUFFER_DESC()
				{
					ByteWidth = sizeInBytes,
					BindFlags = D3D11Formats.VdToD3D11BindFlags(usage),
					Usage = .D3D11_USAGE_DEFAULT,
					CPUAccessFlags = 0,
					MiscFlags = 0,
					StructureByteStride = 0
				};
            if ((usage & BufferUsage.StructuredBufferReadOnly) == BufferUsage.StructuredBufferReadOnly
                || (usage & BufferUsage.StructuredBufferReadWrite) == BufferUsage.StructuredBufferReadWrite)
            {
                if (rawBuffer)
                {
                    bd.MiscFlags = .D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS;
                }
                else
                {
                    bd.MiscFlags = .D3D11_RESOURCE_MISC_BUFFER_STRUCTURED;
                    bd.StructureByteStride = structureByteStride;
                }
            }
            if ((usage & BufferUsage.IndirectBuffer) == BufferUsage.IndirectBuffer)
            {
                bd.MiscFlags = .D3D11_RESOURCE_MISC_DRAWINDIRECT_ARGS;
            }

            if ((usage & BufferUsage.Dynamic) == BufferUsage.Dynamic)
            {
                bd.Usage = .D3D11_USAGE_DYNAMIC;
				bd.CPUAccessFlags = .D3D11_CPU_ACCESS_WRITE;
            }
            else if ((usage & BufferUsage.Staging) == BufferUsage.Staging)
            {
                bd.Usage = .D3D11_USAGE_STAGING;
				bd.CPUAccessFlags = .D3D11_CPU_ACCESS_READ | .D3D11_CPU_ACCESS_WRITE;
            }

            HRESULT hr = device.CreateBuffer(&bd, null, &_buffer);
        }

        public override String Name
        {
            get => _name;
            set
            {
                _name = value;
				D3D11Util.SetDebugName(Buffer, _name);
				for ((OffsetSizePair Key, ID3D11ShaderResourceView* Value) kvp in _srvs)
				{
					D3D11Util.SetDebugName(kvp.Value, scope $"{_name}_SRV");
				}
				for ((OffsetSizePair Key, ID3D11UnorderedAccessView* Value) kvp in _uavs)
				{
					D3D11Util.SetDebugName(kvp.Value, scope $"{_name}_UAV");
				}
            }
        }

        public override void Dispose()
        {
            for ((OffsetSizePair Key, ID3D11ShaderResourceView* Value) kvp in _srvs)
			{
				kvp.Value.Release();
			}
			for ((OffsetSizePair Key, ID3D11UnorderedAccessView* Value) kvp in _uavs)
			{
				kvp.Value.Release();
			}
			_buffer.Release();
			//_buffer = null;
        }

        internal ID3D11ShaderResourceView* GetShaderResourceView(uint32 offset, uint32 size)
        {
            using (_accessViewLock.Enter())
            {
                OffsetSizePair pair = OffsetSizePair(offset, size);
                if (!_srvs.TryGetValue(pair, var srv))
                {
                    srv = CreateShaderResourceView(offset, size);
                    _srvs.Add(pair, srv);
                }

                return srv;
            }
        }

        internal ID3D11UnorderedAccessView* GetUnorderedAccessView(uint32 offset, uint32 size)
        {
            using (_accessViewLock.Enter())
            {
                OffsetSizePair pair = OffsetSizePair(offset, size);
                if (!_uavs.TryGetValue(pair, var uav))
                {
                    uav = CreateUnorderedAccessView(offset, size);
                    _uavs.Add(pair, uav);
                }

                return uav;
            }
        }

        private ID3D11ShaderResourceView* CreateShaderResourceView(uint32 offset, uint32 size)
        {
            if (_rawBuffer)
            {
                D3D11_SHADER_RESOURCE_VIEW_DESC srvDesc = .()
				{
					Format = .DXGI_FORMAT_R32_TYPELESS,
					BufferEx = .()
						{
							FirstElement = offset / 4,
							NumElements = size / 4,
							Flags = (.)D3D11_BUFFEREX_SRV_FLAG.D3D11_BUFFEREX_SRV_FLAG_RAW
						}
				};

                ID3D11ShaderResourceView* pSrv = null;
				HRESULT hr = _device.CreateShaderResourceView(_buffer, &srvDesc, &pSrv);
				//Runtime.Assert(SUCCEEDED(hr));
				return pSrv;
            }
            else
            {
                D3D11_SHADER_RESOURCE_VIEW_DESC srvDesc = .()
					{
						ViewDimension = .D3D_SRV_DIMENSION_BUFFER
					};
				srvDesc.Buffer.NumElements = size / _structureByteStride;
				srvDesc.Buffer.ElementOffset = offset / _structureByteStride;
				ID3D11ShaderResourceView* pSrv = null;
				HRESULT hr = _device.CreateShaderResourceView(_buffer, &srvDesc, &pSrv);
				//Runtime.Assert(SUCCEEDED(hr));
				return pSrv;
            }
        }

        private ID3D11UnorderedAccessView* CreateUnorderedAccessView(uint32 offset, uint32 size)
        {
			if (_rawBuffer)
			{
				D3D11_UNORDERED_ACCESS_VIEW_DESC uavDesc = .()
					{
						Format = .DXGI_FORMAT_R32_TYPELESS,
						ViewDimension = .D3D11_UAV_DIMENSION_BUFFER,
						Buffer = .()
							{
								FirstElement = (uint32)offset / 4,
								NumElements = (uint32)size / 4,
								Flags = (.)D3D11_BUFFER_UAV_FLAG.D3D11_BUFFER_UAV_FLAG_RAW
							}
					};

				ID3D11UnorderedAccessView* pUav = null;
				HRESULT hr = _device.CreateUnorderedAccessView(_buffer, &uavDesc, &pUav);
				return pUav;
			}
			else
			{
				D3D11_UNORDERED_ACCESS_VIEW_DESC uavDesc = .()
					{
						Format = .DXGI_FORMAT_UNKNOWN,
						ViewDimension = .D3D11_UAV_DIMENSION_BUFFER,
						Buffer = .()
							{
								FirstElement = (uint32)(offset / _structureByteStride),
								NumElements = (uint32)(size / _structureByteStride)
							}
					};

				ID3D11UnorderedAccessView* pUav = null;
				HRESULT hr = _device.CreateUnorderedAccessView(_buffer, &uavDesc, &pUav);
				return pUav;
			}
        }

        private struct OffsetSizePair : IEquatable<OffsetSizePair>, IHashable
        {
            public readonly uint32 Offset;
            public readonly uint32 Size;

            public this(uint32 offset, uint32 size)
            {
                Offset = offset;
                Size = size;
            }

            public bool Equals(OffsetSizePair other) => Offset == other.Offset && Size == other.Size;
            public int GetHashCode() => HashHelper.Combine(Offset.GetHashCode(), Size.GetHashCode());
        }
    }
}
