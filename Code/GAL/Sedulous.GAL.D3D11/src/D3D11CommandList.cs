using System;
using System.Diagnostics;
using System.Threading;
using Win32.Graphics.Direct3D11;
using Win32.Foundation;
using System.Collections;
using Win32.Graphics.Direct3D;
using Win32;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.D3D11;

    public class D3D11CommandList : CommandList
    {
        private readonly D3D11GraphicsDevice _gd;
        private readonly ID3D11DeviceContext* _context;
        private readonly ID3D11DeviceContext1* _context1;
        private readonly ID3DUserDefinedAnnotation* _uda;
        private bool _begun;
        private bool _disposed;
        private ID3D11CommandList* _commandList;

        private D3D11_VIEWPORT[] _viewports = new D3D11_VIEWPORT[0];
        private RECT[] _scissors = new RECT[0];
        private bool _viewportsChanged;
        private bool _scissorRectsChanged;

        private uint32 _numVertexBindings = 0;
        private ID3D11Buffer*[] _vertexBindings = new ID3D11Buffer*[1];
        private int32[] _vertexStrides = new int32[1];
        private int32[] _vertexOffsets = new int32[1];

        // Cached pipeline State
        private DeviceBuffer _ib;
        private uint32 _ibOffset;
        private ID3D11BlendState* _blendState;
        private float[4] _blendFactor;
        private ID3D11DepthStencilState* _depthStencilState;
        private uint32 _stencilReference;
        private ID3D11RasterizerState* _rasterizerState;
        private D3D_PRIMITIVE_TOPOLOGY _primitiveTopology;
        private ID3D11InputLayout* _inputLayout;
        private ID3D11VertexShader* _vertexShader;
        private ID3D11GeometryShader* _geometryShader;
        private ID3D11HullShader* _hullShader;
        private ID3D11DomainShader* _domainShader;
        private ID3D11PixelShader* _pixelShader;

        private new D3D11Pipeline _graphicsPipeline;
        private BoundResourceSetInfo[] _graphicsResourceSets = new BoundResourceSetInfo[1];
        // Resource sets are invalidated when a new resource set is bound with an incompatible SRV or UAV.
        private bool[] _invalidatedGraphicsResourceSets = new bool[1];

        private new D3D11Pipeline _computePipeline;
        private BoundResourceSetInfo[] _computeResourceSets = new BoundResourceSetInfo[1];
        // Resource sets are invalidated when a new resource set is bound with an incompatible SRV or UAV.
        private bool[] _invalidatedComputeResourceSets = new bool[1];
        private String _name;
        private bool _vertexBindingsChanged;
        private ID3D11Buffer*[] _cbOut = new ID3D11Buffer*[1];
        private int32[] _firstConstRef = new int32[1];
        private int32[] _numConstsRef = new int32[1];

        // Cached resources
        private const int32 MaxCachedUniformBuffers = 15;
        private readonly D3D11BufferRange[] _vertexBoundUniformBuffers = new D3D11BufferRange[MaxCachedUniformBuffers];
        private readonly D3D11BufferRange[] _fragmentBoundUniformBuffers = new D3D11BufferRange[MaxCachedUniformBuffers];
        private const int32 MaxCachedTextureViews = 16;
        private readonly D3D11TextureView[] _vertexBoundTextureViews = new D3D11TextureView[MaxCachedTextureViews];
        private readonly D3D11TextureView[] _fragmentBoundTextureViews = new D3D11TextureView[MaxCachedTextureViews];
        private const int32 MaxCachedSamplers = 4;
        private readonly D3D11Sampler[] _vertexBoundSamplers = new D3D11Sampler[MaxCachedSamplers];
        private readonly D3D11Sampler[] _fragmentBoundSamplers = new D3D11Sampler[MaxCachedSamplers];

        private readonly Dictionary<Texture, List<BoundTextureInfo>> _boundSRVs = new Dictionary<Texture, List<BoundTextureInfo>>();
        private readonly Dictionary<Texture, List<BoundTextureInfo>> _boundUAVs = new Dictionary<Texture, List<BoundTextureInfo>>();
        private readonly List<List<BoundTextureInfo>> _boundTextureInfoPool = new List<List<BoundTextureInfo>>(20);

        private const int32 MaxUAVs = 8;
        private readonly List<(DeviceBuffer Buffer, int32 Slot)> _boundComputeUAVBuffers = new .(MaxUAVs);
        private readonly List<(DeviceBuffer Buffer, int32 Slot)> _boundOMUAVBuffers = new .(MaxUAVs);

        private readonly List<D3D11Buffer> _availableStagingBuffers = new List<D3D11Buffer>();
        private readonly List<D3D11Buffer> _submittedStagingBuffers = new List<D3D11Buffer>();

        private readonly List<D3D11Swapchain> _referencedSwapchains = new List<D3D11Swapchain>();

        public this(D3D11GraphicsDevice gd, in CommandListDescription description)
            : base(description, gd.Features, gd.UniformBufferMinOffsetAlignment, gd.StructuredBufferMinOffsetAlignment)
        {
            _gd = gd;
            _gd.Device.CreateDeferredContext(0, &_context);
			_context1 = _context.QueryInterface<ID3D11DeviceContext1>();
			_uda = _context.QueryInterface<ID3DUserDefinedAnnotation>();
        }

        public ID3D11CommandList* DeviceCommandList => _commandList;

        internal ID3D11DeviceContext* DeviceContext => _context;

        private D3D11Framebuffer D3D11Framebuffer => Util.AssertSubtype<Framebuffer, D3D11Framebuffer>(_framebuffer);

        public override bool IsDisposed => _disposed;

        public override void Begin()
        {
            _commandList?.Release();
            _commandList = null;
            ClearState();
            _begun = true;
        }

        private void ClearState()
        {
            ClearCachedState();
            _context.ClearState();
            ResetManagedState();
        }

        private void ResetManagedState()
        {
            _numVertexBindings = 0;
            Util.ClearArray(_vertexBindings);
            Util.ClearArray(_vertexStrides);
            Util.ClearArray(_vertexOffsets);

            _framebuffer = null;

            Util.ClearArray(_viewports);
            Util.ClearArray(_scissors);
            _viewportsChanged = false;
            _scissorRectsChanged = false;

            _ib = null;
            _graphicsPipeline = null;
            _blendState = null;
            _depthStencilState = null;
            _rasterizerState = null;
            _primitiveTopology = D3D_PRIMITIVE_TOPOLOGY.D3D_PRIMITIVE_TOPOLOGY_UNDEFINED;
            _inputLayout = null;
            _vertexShader = null;
            _geometryShader = null;
            _hullShader = null;
            _domainShader = null;
            _pixelShader = null;

            ClearSets(_graphicsResourceSets);

            Util.ClearArray(_vertexBoundUniformBuffers);
            Util.ClearArray(_vertexBoundTextureViews);
            Util.ClearArray(_vertexBoundSamplers);

            Util.ClearArray(_fragmentBoundUniformBuffers);
            Util.ClearArray(_fragmentBoundTextureViews);
            Util.ClearArray(_fragmentBoundSamplers);

            _computePipeline = null;
            ClearSets(_computeResourceSets);

            for ((Texture, List<BoundTextureInfo> Value) kvp in _boundSRVs)
            {
                List<BoundTextureInfo> list = kvp.Value;
                list.Clear();
                PoolBoundTextureList(list);
            }
            _boundSRVs.Clear();

            for ((Texture, List<BoundTextureInfo> Value) kvp in _boundUAVs)
            {
                List<BoundTextureInfo> list = kvp.Value;
                list.Clear();
                PoolBoundTextureList(list);
            }
            _boundUAVs.Clear();
        }

        private void ClearSets(BoundResourceSetInfo[] boundSets)
        {
            for (BoundResourceSetInfo boundSetInfo in boundSets)
            {
                boundSetInfo.Offsets.Dispose();
            }
            Util.ClearArray(boundSets);
        }

        public override void End()
        {
            if (_commandList != null)
            {
                Runtime.GALError("Invalid use of End().");
            }

            HRESULT hr = _context.FinishCommandList(FALSE, &_commandList);
			D3D11Util.SetDebugName(_commandList, _name);
            ResetManagedState();
            _begun = false;
        }

        public void Reset()
        {
            if (_commandList != null)
            {
                _commandList.Release();
                _commandList = null;
            }
            else if (_begun)
            {
                _context.ClearState();
                _context.FinishCommandList(FALSE, &_commandList);
				_commandList.Release();
                _commandList = null;
            }

            ResetManagedState();
            _begun = false;
        }

        protected override void SetIndexBufferCore(DeviceBuffer buffer, IndexFormat format, uint32 offset)
        {
            if (_ib != buffer || _ibOffset != offset)
            {
                _ib = buffer;
                _ibOffset = offset;
                D3D11Buffer d3d11Buffer = Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(buffer);
                UnbindUAVBuffer(buffer);
                _context.IASetIndexBuffer(d3d11Buffer.Buffer, D3D11Formats.ToDxgiFormat(format), offset);
            }
        }

        protected override void SetPipelineCore(Pipeline pipeline)
        {
            if (!pipeline.IsComputePipeline && _graphicsPipeline != pipeline)
            {
                D3D11Pipeline d3dPipeline = Util.AssertSubtype<Pipeline, D3D11Pipeline>(pipeline);
                _graphicsPipeline = d3dPipeline;
                ClearSets(_graphicsResourceSets); // Invalidate resource set bindings -- they may be invalid.
                Util.ClearArray(_invalidatedGraphicsResourceSets);

                ID3D11BlendState* blendState = d3dPipeline.BlendState;
                float[4] blendFactor = d3dPipeline.BlendFactor;
                if (_blendState != blendState || _blendFactor != blendFactor)
                {
                    _blendState = blendState;
                    _blendFactor = blendFactor;
                    _context.OMSetBlendState(blendState, &blendFactor, uint32.MaxValue);
                }

                ID3D11DepthStencilState* depthStencilState = d3dPipeline.DepthStencilState;
                uint32 stencilReference = d3dPipeline.StencilReference;
                if (_depthStencilState != depthStencilState || _stencilReference != stencilReference)
                {
                    _depthStencilState = depthStencilState;
                    _stencilReference = stencilReference;
                    _context.OMSetDepthStencilState(depthStencilState, stencilReference);
                }

                ID3D11RasterizerState* rasterizerState = d3dPipeline.RasterizerState;
                if (_rasterizerState != rasterizerState)
                {
                    _rasterizerState = rasterizerState;
                    _context.RSSetState(rasterizerState);
                }

                D3D_PRIMITIVE_TOPOLOGY primitiveTopology = d3dPipeline.PrimitiveTopology;
                if (_primitiveTopology != primitiveTopology)
                {
                    _primitiveTopology = primitiveTopology;
                    _context.IASetPrimitiveTopology(primitiveTopology);
                }

                ID3D11InputLayout* inputLayout = d3dPipeline.InputLayout;
                if (_inputLayout != inputLayout)
                {
                    _inputLayout = inputLayout;
                    _context.IASetInputLayout(inputLayout);
                }

                ID3D11VertexShader* vertexShader = d3dPipeline.VertexShader;
                if (_vertexShader != vertexShader)
                {
                    _vertexShader = vertexShader;
                    _context.VSSetShader(vertexShader, null, 0);
                }

                ID3D11GeometryShader* geometryShader = d3dPipeline.GeometryShader;
                if (_geometryShader != geometryShader)
                {
                    _geometryShader = geometryShader;
                    _context.GSSetShader(geometryShader, null, 0);
                }

                ID3D11HullShader* hullShader = d3dPipeline.HullShader;
                if (_hullShader != hullShader)
                {
                    _hullShader = hullShader;
                    _context.HSSetShader(hullShader, null, 0);
                }

                ID3D11DomainShader* domainShader = d3dPipeline.DomainShader;
                if (_domainShader != domainShader)
                {
                    _domainShader = domainShader;
                    _context.DSSetShader(domainShader, null, 0);
                }

                ID3D11PixelShader* pixelShader = d3dPipeline.PixelShader;
                if (_pixelShader != pixelShader)
                {
                    _pixelShader = pixelShader;
                    _context.PSSetShader(pixelShader, null, 0);
                }

                if (!Util.ArrayEqualsEquatable(_vertexStrides, d3dPipeline.VertexStrides))
                {
                    _vertexBindingsChanged = true;

                    if (d3dPipeline.VertexStrides != null)
                    {
                        Util.EnsureArrayMinimumSize(ref _vertexStrides, (uint32)d3dPipeline.VertexStrides.Count);
                        d3dPipeline.VertexStrides.CopyTo(_vertexStrides, 0);
                    }
                }

                Util.EnsureArrayMinimumSize(ref _vertexStrides, 1);
                Util.EnsureArrayMinimumSize(ref _vertexBindings, (uint32)_vertexStrides.Count);
                Util.EnsureArrayMinimumSize(ref _vertexOffsets, (uint32)_vertexStrides.Count);

                Util.EnsureArrayMinimumSize(ref _graphicsResourceSets, (uint32)d3dPipeline.ResourceLayouts.Count);
                Util.EnsureArrayMinimumSize(ref _invalidatedGraphicsResourceSets, (uint32)d3dPipeline.ResourceLayouts.Count);
            }
            else if (pipeline.IsComputePipeline && _computePipeline != pipeline)
            {
                D3D11Pipeline d3dPipeline = Util.AssertSubtype<Pipeline, D3D11Pipeline>(pipeline);
                _computePipeline = d3dPipeline;
                ClearSets(_computeResourceSets); // Invalidate resource set bindings -- they may be invalid.
                Util.ClearArray(_invalidatedComputeResourceSets);

                ID3D11ComputeShader* computeShader = d3dPipeline.ComputeShader;
                _context.CSSetShader(computeShader, null, 0);
                Util.EnsureArrayMinimumSize(ref _computeResourceSets, (uint32)d3dPipeline.ResourceLayouts.Count);
                Util.EnsureArrayMinimumSize(ref _invalidatedComputeResourceSets, (uint32)d3dPipeline.ResourceLayouts.Count);
            }
        }

        protected override void SetGraphicsResourceSetCore(uint32 slot, ResourceSet rs, uint32 dynamicOffsetsCount, uint32* dynamicOffsets)
        {
            if (_graphicsResourceSets[slot].Equals(rs, dynamicOffsetsCount, dynamicOffsets))
            {
                return;
            }

            _graphicsResourceSets[slot].Offsets.Dispose();
            _graphicsResourceSets[slot] = BoundResourceSetInfo(rs, dynamicOffsetsCount, dynamicOffsets);
            ActivateResourceSet(slot, _graphicsResourceSets[slot], true);
        }

        protected override void SetComputeResourceSetCore(uint32 slot, ResourceSet set, uint32 dynamicOffsetsCount, uint32* dynamicOffsets)
        {
            if (_computeResourceSets[slot].Equals(set, dynamicOffsetsCount, dynamicOffsets))
            {
                return;
            }

            _computeResourceSets[slot].Offsets.Dispose();
            _computeResourceSets[slot] = BoundResourceSetInfo(set, dynamicOffsetsCount, dynamicOffsets);
            ActivateResourceSet(slot, _computeResourceSets[slot], false);
        }

        private void ActivateResourceSet(uint32 slot, BoundResourceSetInfo brsi, bool graphics)
        {
            D3D11ResourceSet d3d11RS = Util.AssertSubtype<ResourceSet, D3D11ResourceSet>(brsi.Set);

            int32 cbBase = GetConstantBufferBase(slot, graphics);
            int32 uaBase = GetUnorderedAccessBase(slot, graphics);
            int32 textureBase = GetTextureBase(slot, graphics);
            int32 samplerBase = GetSamplerBase(slot, graphics);

            D3D11ResourceLayout layout = d3d11RS.Layout;
            BindableResource[] resources = d3d11RS.Resources;
            uint32 dynamicOffsetIndex = 0;
            for (int32 i = 0; i < resources.Count; i++)
            {
                BindableResource resource = resources[i];
                uint32 bufferOffset = 0;
                if (layout.IsDynamicBuffer(i))
                {
                    bufferOffset = brsi.Offsets.Get(dynamicOffsetIndex);
                    dynamicOffsetIndex += 1;
                }
                D3D11ResourceLayout.ResourceBindingInfo rbi = layout.GetDeviceSlotIndex(i);
                switch (rbi.Kind)
                {
                    case ResourceKind.UniformBuffer:
                        {
                            D3D11BufferRange range = GetBufferRange(resource, bufferOffset);
                            BindUniformBuffer(range, cbBase + rbi.Slot, rbi.Stages);
                            break;
                        }
                    case ResourceKind.StructuredBufferReadOnly:
                        {
                            D3D11BufferRange range = GetBufferRange(resource, bufferOffset);
                            BindStorageBufferView(range, textureBase + rbi.Slot, rbi.Stages);
                            break;
                        }
                    case ResourceKind.StructuredBufferReadWrite:
                        {
                            D3D11BufferRange range = GetBufferRange(resource, bufferOffset);
                            ID3D11UnorderedAccessView* uav = range.Buffer.GetUnorderedAccessView(range.Offset, range.Size);
                            BindUnorderedAccessView(null, range.Buffer, ref uav, uaBase + rbi.Slot, rbi.Stages, slot);
                            break;
                        }
                    case ResourceKind.TextureReadOnly:
                        TextureView texView = Util.GetTextureView(_gd, resource);
                        D3D11TextureView d3d11TexView = Util.AssertSubtype<TextureView, D3D11TextureView>(texView);
                        UnbindUAVTexture(d3d11TexView.Target);
                        BindTextureView(d3d11TexView, textureBase + rbi.Slot, rbi.Stages, slot);
                        break;
                    case ResourceKind.TextureReadWrite:
                        TextureView rwTexView = Util.GetTextureView(_gd, resource);
                        D3D11TextureView d3d11RWTexView = Util.AssertSubtype<TextureView, D3D11TextureView>(rwTexView);
                        UnbindSRVTexture(d3d11RWTexView.Target);
                        BindUnorderedAccessView(d3d11RWTexView.Target, null, ref d3d11RWTexView.UnorderedAccessView, uaBase + rbi.Slot, rbi.Stages, slot);
                        break;
                    case ResourceKind.Sampler:
                        D3D11Sampler sampler = Util.AssertSubtype<BindableResource, D3D11Sampler>(resource);
                        BindSampler(sampler, samplerBase + rbi.Slot, rbi.Stages);
                        break;
                    default: Runtime.IllegalValue<ResourceKind>();
                }
            }
        }

        private D3D11BufferRange GetBufferRange(BindableResource resource, uint32 additionalOffset)
        {
            if (let d3d11Buff = resource as D3D11Buffer)
            {
                return D3D11BufferRange(d3d11Buff, additionalOffset, d3d11Buff.SizeInBytes);
            }
            else if (let range = resource as DeviceBufferRange?)
            {
                return D3D11BufferRange(
                    Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(range.Buffer),
                    range.Offset + additionalOffset,
                    range.SizeInBytes);
            }
            else
            {
                Runtime.GALError(scope $"Unexpected resource type used in a buffer type slot: {resource.GetType().GetName(.. scope .())}");
            }
        }

        private void UnbindSRVTexture(Texture target)
        {
            if (_boundSRVs.TryGetValue(target, var btis))
            {
                for (BoundTextureInfo bti in btis)
                {
                    BindTextureView(null, bti.Slot, bti.Stages, 0);

                    if ((bti.Stages & ShaderStages.Compute) == ShaderStages.Compute)
                    {
                        _invalidatedComputeResourceSets[bti.ResourceSet] = true;
                    }
                    else
                    {
                        _invalidatedGraphicsResourceSets[bti.ResourceSet] = true;
                    }
                }

                bool result = _boundSRVs.Remove(target);
                Debug.Assert(result);

                btis.Clear();
                PoolBoundTextureList(btis);
            }
        }

        private void PoolBoundTextureList(List<BoundTextureInfo> btis)
        {
            _boundTextureInfoPool.Add(btis);
        }

        private void UnbindUAVTexture(Texture target)
        {
            if (_boundUAVs.TryGetValue(target, var btis))
            {
				ID3D11UnorderedAccessView* pNullView = null;
                for (BoundTextureInfo bti in btis)
                {
                    BindUnorderedAccessView(null, null, ref pNullView, bti.Slot, bti.Stages, bti.ResourceSet);
                    if ((bti.Stages & ShaderStages.Compute) == ShaderStages.Compute)
                    {
                        _invalidatedComputeResourceSets[bti.ResourceSet] = true;
                    }
                    else
                    {
                        _invalidatedGraphicsResourceSets[bti.ResourceSet] = true;
                    }
                }

                bool result = _boundUAVs.Remove(target);
                Debug.Assert(result);

                btis.Clear();
                PoolBoundTextureList(btis);
            }
        }

        private int32 GetConstantBufferBase(uint32 slot, bool graphics)
        {
            D3D11ResourceLayout[] layouts = graphics ? _graphicsPipeline.ResourceLayouts : _computePipeline.ResourceLayouts;
            int32 ret = 0;
            for (int i = 0; i < slot; i++)
            {
                Debug.Assert(layouts[i] != null);
                ret += layouts[i].UniformBufferCount;
            }

            return ret;
        }

        private int32 GetUnorderedAccessBase(uint32 slot, bool graphics)
        {
            D3D11ResourceLayout[] layouts = graphics ? _graphicsPipeline.ResourceLayouts : _computePipeline.ResourceLayouts;
            int32 ret = 0;
            for (int i = 0; i < slot; i++)
            {
                Debug.Assert(layouts[i] != null);
                ret += layouts[i].StorageBufferCount;
            }

            return ret;
        }

        private int32 GetTextureBase(uint32 slot, bool graphics)
        {
            D3D11ResourceLayout[] layouts = graphics ? _graphicsPipeline.ResourceLayouts : _computePipeline.ResourceLayouts;
            int32 ret = 0;
            for (int i = 0; i < slot; i++)
            {
                Debug.Assert(layouts[i] != null);
                ret += layouts[i].TextureCount;
            }

            return ret;
        }

        private int32 GetSamplerBase(uint32 slot, bool graphics)
        {
            D3D11ResourceLayout[] layouts = graphics ? _graphicsPipeline.ResourceLayouts : _computePipeline.ResourceLayouts;
            int32 ret = 0;
            for (int i = 0; i < slot; i++)
            {
                Debug.Assert(layouts[i] != null);
                ret += layouts[i].SamplerCount;
            }

            return ret;
        }

        protected override void SetVertexBufferCore(uint32 index, DeviceBuffer buffer, uint32 offset)
        {
            D3D11Buffer d3d11Buffer = Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(buffer);
            if (_vertexBindings[index] != d3d11Buffer.Buffer || _vertexOffsets[index] != (int32)offset)
            {
                _vertexBindingsChanged = true;
                UnbindUAVBuffer(buffer);
                _vertexBindings[index] = d3d11Buffer.Buffer;
                _vertexOffsets[index] = (int32)offset;
                _numVertexBindings = Math.Max((index + 1), _numVertexBindings);
            }
        }

        protected override void DrawCore(uint32 vertexCount, uint32 instanceCount, uint32 vertexStart, uint32 instanceStart)
        {
            PreDrawCommand();

            if (instanceCount == 1 && instanceStart == 0)
            {
                _context.Draw(vertexCount, vertexStart);
            }
            else
            {
                _context.DrawInstanced(vertexCount, instanceCount, vertexStart, instanceStart);
            }
        }

        protected override void DrawIndexedCore(uint32 indexCount, uint32 instanceCount, uint32 indexStart, int32 vertexOffset, uint32 instanceStart)
        {
            PreDrawCommand();

            Debug.Assert(_ib != null);
            if (instanceCount == 1 && instanceStart == 0)
            {
                _context.DrawIndexed(indexCount, indexStart, vertexOffset);
            }
            else
            {
                _context.DrawIndexedInstanced(indexCount, instanceCount, indexStart, vertexOffset, instanceStart);
            }
        }

        protected override void DrawIndirectCore(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            PreDrawCommand();

            D3D11Buffer d3d11Buffer = Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(indirectBuffer);
            uint32 currentOffset = offset;
            for (uint32 i = 0; i < drawCount; i++)
            {
                _context.DrawInstancedIndirect(d3d11Buffer.Buffer, currentOffset);
                currentOffset += stride;
            }
        }

        protected override void DrawIndexedIndirectCore(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            PreDrawCommand();

            D3D11Buffer d3d11Buffer = Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(indirectBuffer);
            uint32 currentOffset = offset;
            for (uint32 i = 0; i < drawCount; i++)
            {
                _context.DrawIndexedInstancedIndirect(d3d11Buffer.Buffer, currentOffset);
                currentOffset += stride;
            }
        }

        private void PreDrawCommand()
        {
            FlushViewports();
            FlushScissorRects();
            FlushVertexBindings();

            int graphicsResourceCount = _graphicsPipeline.ResourceLayouts.Count;
            for (uint32 i = 0; i < graphicsResourceCount; i++)
            {
                if (_invalidatedGraphicsResourceSets[i])
                {
                    _invalidatedGraphicsResourceSets[i] = false;
                    ActivateResourceSet(i, _graphicsResourceSets[i], true);
                }
            }
        }

        public override void Dispatch(uint32 groupCountX, uint32 groupCountY, uint32 groupCountZ)
        {
            PreDispatchCommand();

            _context.Dispatch(groupCountX, groupCountY, groupCountZ);
        }

        protected override void DispatchIndirectCore(DeviceBuffer indirectBuffer, uint32 offset)
        {
            PreDispatchCommand();
            D3D11Buffer d3d11Buffer = Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(indirectBuffer);
            _context.DispatchIndirect(d3d11Buffer.Buffer, offset);
        }

        private void PreDispatchCommand()
        {
            int computeResourceCount = _computePipeline.ResourceLayouts.Count;
            for (uint32 i = 0; i < computeResourceCount; i++)
            {
                if (_invalidatedComputeResourceSets[i])
                {
                    _invalidatedComputeResourceSets[i] = false;
                    ActivateResourceSet(i, _computeResourceSets[i], false);
                }
            }
        }

        protected override void ResolveTextureCore(Texture source, Texture destination)
        {
            D3D11Texture d3d11Source = Util.AssertSubtype<Texture, D3D11Texture>(source);
            D3D11Texture d3d11Destination = Util.AssertSubtype<Texture, D3D11Texture>(destination);
            _context.ResolveSubresource(
                d3d11Destination.DeviceTexture,
                0,
                d3d11Source.DeviceTexture,
                0,
                d3d11Destination.DxgiFormat);
        }

        private void FlushViewports()
        {
            if (_viewportsChanged)
            {
                _viewportsChanged = false;
                _context.RSSetViewports((uint32)_viewports.Count, _viewports.Ptr);
            }
        }

        private void FlushScissorRects()
        {
            if (_scissorRectsChanged)
            {
                _scissorRectsChanged = false;
                if (_scissors.Count > 0)
                {
                    // Because this array is resized using Util.EnsureMinimumArraySize, this might set more scissor rectangles
                    // than are actually needed, but this is okay -- extras are essentially ignored and should be harmless.
                    _context.RSSetScissorRects((uint32)_scissors.Count, _scissors.Ptr);
                }
            }
        }

        private void FlushVertexBindings()
        {
            if (_vertexBindingsChanged)
            {
                _context.IASetVertexBuffers(
                    0, _numVertexBindings,
                    _vertexBindings.Ptr,
                    (uint32*)_vertexStrides.Ptr,
                    (uint32*)_vertexOffsets.Ptr);

                _vertexBindingsChanged = false;
            }
        }

        public override void SetScissorRect(uint32 index, uint32 x, uint32 y, uint32 width, uint32 height)
        {
            _scissorRectsChanged = true;
            Util.EnsureArrayMinimumSize(ref _scissors, index + 1);
            _scissors[index] = RECT((int32)x, (int32)y, (int32)(x + width), (int32)(y + height));
        }

        public override void SetViewport(uint32 index, in Viewport viewport)
        {
            _viewportsChanged = true;
            Util.EnsureArrayMinimumSize(ref _viewports, index + 1);
            _viewports[index] =  D3D11_VIEWPORT(viewport.X, viewport.Y, viewport.Width, viewport.Height, viewport.MinDepth, viewport.MaxDepth);
        }

        private void BindTextureView(D3D11TextureView texView, int32 slot, ShaderStages stages, uint32 resourceSet)
        {
		    ID3D11ShaderResourceView* srv = texView?.ShaderResourceView ?? null;
		    if (srv != null)
		    {
		        if (!_boundSRVs.TryGetValue(texView.Target, var list))
		        {
		            list = GetNewOrCachedBoundTextureInfoList();
		            _boundSRVs.Add(texView.Target, list);
		        }
		        list.Add(BoundTextureInfo { Slot = slot, Stages = stages, ResourceSet = resourceSet });
		    }

		    if ((stages & ShaderStages.Vertex) == ShaderStages.Vertex)
		    {
		        bool bind = false;
		        if (slot < MaxCachedUniformBuffers)
		        {
		            if (_vertexBoundTextureViews[slot] != texView)
		            {
		                _vertexBoundTextureViews[slot] = texView;
		                bind = true;
		            }
		        }
		        else
		        {
		            bind = true;
		        }
		        if (bind)
		        {
		            _context.VSSetShaderResources((uint32)slot, 1, &srv);
		        }
		    }
		    if ((stages & ShaderStages.Geometry) == ShaderStages.Geometry)
		    {
		        _context.GSSetShaderResources((uint32)slot, 1, &srv);
		    }
		    if ((stages & ShaderStages.TessellationControl) == ShaderStages.TessellationControl)
		    {
		        _context.HSSetShaderResources((uint32)slot, 1, &srv);
		    }
		    if ((stages & ShaderStages.TessellationEvaluation) == ShaderStages.TessellationEvaluation)
		    {
		        _context.DSSetShaderResources((uint32)slot, 1, &srv);
		    }
		    if ((stages & ShaderStages.Fragment) == ShaderStages.Fragment)
		    {
		        bool bind = false;
		        if (slot < MaxCachedUniformBuffers)
		        {
		            if (_fragmentBoundTextureViews[slot] != texView)
		            {
		                _fragmentBoundTextureViews[slot] = texView;
		                bind = true;
		            }
		        }
		        else
		        {
		            bind = true;
		        }
		        if (bind)
		        {
		            _context.PSSetShaderResources((uint32)slot, 1, &srv);
		        }
		    }
		    if ((stages & ShaderStages.Compute) == ShaderStages.Compute)
		    {
		        _context.CSSetShaderResources((uint32)slot, 1, &srv);
		    }
		}

        private List<BoundTextureInfo> GetNewOrCachedBoundTextureInfoList()
        {
            if (_boundTextureInfoPool.Count > 0)
            {
                int index = _boundTextureInfoPool.Count - 1;
                List<BoundTextureInfo> ret = _boundTextureInfoPool[index];
                _boundTextureInfoPool.RemoveAt(index);
                return ret;
            }

            return new List<BoundTextureInfo>();
        }

        private void BindStorageBufferView(D3D11BufferRange range, int32 slot, ShaderStages stages)
        {
            bool compute = (stages & ShaderStages.Compute) != 0;
            UnbindUAVBuffer(range.Buffer);

            ID3D11ShaderResourceView* srv = range.Buffer.GetShaderResourceView(range.Offset, range.Size);

            if ((stages & ShaderStages.Vertex) == ShaderStages.Vertex)
			{
			    _context.VSSetShaderResources((uint32)slot, 1, &srv);
			}
			if ((stages & ShaderStages.Geometry) == ShaderStages.Geometry)
			{
			    _context.GSSetShaderResources((uint32)slot, 1, &srv);
			}
			if ((stages & ShaderStages.TessellationControl) == ShaderStages.TessellationControl)
			{
			    _context.HSSetShaderResources((uint32)slot, 1, &srv);
			}
			if ((stages & ShaderStages.TessellationEvaluation) == ShaderStages.TessellationEvaluation)
			{
			    _context.DSSetShaderResources((uint32)slot, 1, &srv);
			}
			if ((stages & ShaderStages.Fragment) == ShaderStages.Fragment)
			{
			    _context.PSSetShaderResources((uint32)slot, 1, &srv);
			}
			if (compute)
			{
			    _context.CSSetShaderResources((uint32)slot, 1, &srv);
			}
        }

        private void BindUniformBuffer(D3D11BufferRange range, int32 slot, ShaderStages stages)
        {
            if ((stages & ShaderStages.Vertex) == ShaderStages.Vertex)
            {
                bool bind = false;
                if (slot < MaxCachedUniformBuffers)
                {
                    if (!_vertexBoundUniformBuffers[slot].Equals(range))
                    {
                        _vertexBoundUniformBuffers[slot] = range;
                        bind = true;
                    }
                }
                else
                {
                    bind = true;
                }
                if (bind)
                {
                    if (range.IsFullRange)
                    {
                        _context.VSSetConstantBuffers((uint32)slot, 1, &range.Buffer.Buffer);
                    }
                    else
                    {
                        PackRangeParams(range);
                        if (!_gd.SupportsCommandLists)
                        {
                            _context.VSSetConstantBuffers((.)slot, 1, null);
                        }
                        _context1.VSSetConstantBuffers1((.)slot, 1, _cbOut.Ptr, (.)_firstConstRef.Ptr, (.)_numConstsRef.Ptr);
                    }
                }
            }
            if ((stages & ShaderStages.Geometry) == ShaderStages.Geometry)
            {
                if (range.IsFullRange)
                {
                    _context.GSSetConstantBuffers((.)slot, 1, &range.Buffer.Buffer);
                }
                else
                {
                    PackRangeParams(range);
                    if (!_gd.SupportsCommandLists)
                    {
                        _context.GSSetConstantBuffers((.)slot, 1, null);
                    }
                    _context1.GSSetConstantBuffers1((.)slot, 1, _cbOut.Ptr, (.)_firstConstRef.Ptr, (.)_numConstsRef.Ptr);
                }
            }
            if ((stages & ShaderStages.TessellationControl) == ShaderStages.TessellationControl)
            {
                if (range.IsFullRange)
                {
                    _context.HSSetConstantBuffers((.)slot, 1, &range.Buffer.Buffer);
                }
                else
                {
                    PackRangeParams(range);
                    if (!_gd.SupportsCommandLists)
                    {
                        _context.HSSetConstantBuffers((.)slot, 1, null);
                    }
                    _context1.HSSetConstantBuffers1((.)slot, 1, _cbOut.Ptr, (.)_firstConstRef.Ptr, (.)_numConstsRef.Ptr);
                }
            }
            if ((stages & ShaderStages.TessellationEvaluation) == ShaderStages.TessellationEvaluation)
            {
                if (range.IsFullRange)
                {
                    _context.DSSetConstantBuffers((.)slot, 1, &range.Buffer.Buffer);
                }
                else
                {
                    PackRangeParams(range);
                    if (!_gd.SupportsCommandLists)
                    {
                         _context.DSSetConstantBuffers((.)slot, 1, null);
                    }
                    _context1.DSSetConstantBuffers1((.)slot, 1, _cbOut.Ptr, (.)_firstConstRef.Ptr, (.)_numConstsRef.Ptr);
                }
            }
            if ((stages & ShaderStages.Fragment) == ShaderStages.Fragment)
            {
                bool bind = false;
                if (slot < MaxCachedUniformBuffers)
                {
                    if (!_fragmentBoundUniformBuffers[slot].Equals(range))
                    {
                        _fragmentBoundUniformBuffers[slot] = range;
                        bind = true;
                    }
                }
                else
                {
                    bind = true;
                }
                if (bind)
                {
                    if (range.IsFullRange)
                    {
                        _context.PSSetConstantBuffers((.)slot, 1, &range.Buffer.Buffer);
                    }
                    else
                    {
                        PackRangeParams(range);
                        if (!_gd.SupportsCommandLists)
                        {
                            _context.PSSetConstantBuffers((.)slot, 1, null);
                        }
                        _context1.PSSetConstantBuffers1((.)slot, 1, _cbOut.Ptr, (.)_firstConstRef.Ptr, (.)_numConstsRef.Ptr);
                    }
                }
            }
            if ((stages & ShaderStages.Compute) == ShaderStages.Compute)
            {
                if (range.IsFullRange)
                {
                    _context.CSSetConstantBuffers((.)slot, 1, &range.Buffer.Buffer);
                }
                else
                {
                    PackRangeParams(range);
                    if (!_gd.SupportsCommandLists)
                    {
                        _context.CSSetConstantBuffers((.)slot, 1, (ID3D11Buffer**)null);
                    }
                    _context1.CSSetConstantBuffers1((.)slot, 1, _cbOut.Ptr, (.)_firstConstRef.Ptr, (.)_numConstsRef.Ptr);
                }
            }
        }

        private void PackRangeParams(D3D11BufferRange range)
        {
            _cbOut[0] = range.Buffer.Buffer;
            _firstConstRef[0] = (int32)range.Offset / 16;
            uint32 roundedSize = range.Size < 256 ? 256u : range.Size;
            _numConstsRef[0] = (int32)roundedSize / 16;
        }

        private void BindUnorderedAccessView(
            Texture texture,
            DeviceBuffer buffer,
            ref ID3D11UnorderedAccessView* uav,
            int32 slot,
            ShaderStages stages,
            uint32 resourceSet)
        {
            bool compute = stages == ShaderStages.Compute;
            Debug.Assert(compute || ((stages & ShaderStages.Compute) == 0));
            Debug.Assert(texture == null || buffer == null);

            if (texture != null && uav != null)
            {
                if (!_boundUAVs.TryGetValue(texture, var list))
                {
                    list = GetNewOrCachedBoundTextureInfoList();
                    _boundUAVs.Add(texture, list);
                }
                list.Add(BoundTextureInfo() { Slot = slot, Stages = stages, ResourceSet = resourceSet });
            }

            int baseSlot = 0;
            if (!compute && _fragmentBoundSamplers != null)
            {
                baseSlot = _framebuffer.ColorTargets.Count;
            }
            uint32 actualSlot = (uint32)baseSlot + (uint32)slot;

            if (buffer != null)
            {
                TrackBoundUAVBuffer(buffer, (int32)actualSlot, compute);
            }

            if (compute)
            {
                _context.CSSetUnorderedAccessViews(actualSlot, 1, &uav, null);
            }
            else
            {
                _context.OMSetRenderTargetsAndUnorderedAccessViews(D3D11_KEEP_RENDER_TARGETS_AND_DEPTH_STENCIL, null, null, (uint32)actualSlot, 1, &uav, null);
            }
        }

        private void TrackBoundUAVBuffer(DeviceBuffer buffer, int32 slot, bool compute)
        {
            List<(DeviceBuffer Buffer, int32 Slot)> list = compute ? _boundComputeUAVBuffers : _boundOMUAVBuffers;
            list.Add((buffer, slot));
        }

        private void UnbindUAVBuffer(DeviceBuffer buffer)
        {
            UnbindUAVBufferIndividual(buffer, false);
            UnbindUAVBufferIndividual(buffer, true);
        }

        private void UnbindUAVBufferIndividual(DeviceBuffer buffer, bool compute)
        {
            List<(DeviceBuffer Buffer, int32 Slot)> list = compute ? _boundComputeUAVBuffers : _boundOMUAVBuffers;
            for (int i = 0; i < list.Count; i++)
            {
                if (list[i].Buffer == buffer)
                {
                    int32 slot = list[i].Slot;
                    if (compute)
                    {
                        _context.CSSetUnorderedAccessViews((.)slot, 1, null, null);
                    }
                    else
                    {
                        _context.OMSetRenderTargetsAndUnorderedAccessViews(D3D11_KEEP_RENDER_TARGETS_AND_DEPTH_STENCIL , null, null, (.)slot, 1, null, null);
                    }

                    list.RemoveAt(i);
                    i -= 1;
                }
            }
        }

        private void BindSampler(D3D11Sampler sampler, int32 slot, ShaderStages stages)
        {
            if ((stages & ShaderStages.Vertex) == ShaderStages.Vertex)
            {
                bool bind = false;
                if (slot < MaxCachedSamplers)
                {
                    if (_vertexBoundSamplers[slot] != sampler)
                    {
                        _vertexBoundSamplers[slot] = sampler;
                        bind = true;
                    }
                }
                else
                {
                    bind = true;
                }
                if (bind)
                {
                     _context.VSSetSamplers((.)slot, 1, &sampler.DeviceSampler);
                }
            }
            if ((stages & ShaderStages.Geometry) == ShaderStages.Geometry)
            {
                _context.GSSetSamplers((.)slot, 1, &sampler.DeviceSampler);
            }
            if ((stages & ShaderStages.TessellationControl) == ShaderStages.TessellationControl)
            {
                _context.HSSetSamplers((.)slot, 1, &sampler.DeviceSampler);
            }
            if ((stages & ShaderStages.TessellationEvaluation) == ShaderStages.TessellationEvaluation)
            {
                _context.DSSetSamplers((.)slot, 1, &sampler.DeviceSampler);
            }
            if ((stages & ShaderStages.Fragment) == ShaderStages.Fragment)
            {
                bool bind = false;
                if (slot < MaxCachedSamplers)
                {
                    if (_fragmentBoundSamplers[slot] != sampler)
                    {
                        _fragmentBoundSamplers[slot] = sampler;
                        bind = true;
                    }
                }
                else
                {
                    bind = true;
                }
                if (bind)
                {
                    _context.PSSetSamplers((.)slot, 1, &sampler.DeviceSampler);
                }
            }
            if((stages & ShaderStages.Compute) == ShaderStages.Compute)
            {
                _context.CSSetSamplers((.)slot, 1, &sampler.DeviceSampler);
            }
        }

        protected override void SetFramebufferCore(Framebuffer fb)
        {
            D3D11Framebuffer d3dFB = Util.AssertSubtype<Framebuffer, D3D11Framebuffer>(fb);
            if (d3dFB.Swapchain != null)
            {
                d3dFB.Swapchain.AddCommandListReference(this);
                _referencedSwapchains.Add(d3dFB.Swapchain);
            }

            for (int32 i = 0; i < fb.ColorTargets.Count; i++)
            {
                UnbindSRVTexture(fb.ColorTargets[i].Target);
            }

            _context.OMSetRenderTargets((uint32)d3dFB.RenderTargetViews.Count, d3dFB.RenderTargetViews.Ptr, d3dFB.DepthStencilView);
        }

        protected override void ClearColorTargetCore(uint32 index, RgbaFloat clearColor)
        {
			float[4] colorRGBA = .(clearColor.R, clearColor.G, clearColor.B, clearColor.A);
            _context.ClearRenderTargetView(D3D11Framebuffer.RenderTargetViews[index], &colorRGBA);
        }

        protected override void ClearDepthStencilCore(float depth, uint8 stencil)
        {
            _context.ClearDepthStencilView(D3D11Framebuffer.DepthStencilView, (uint32)(D3D11_CLEAR_FLAG.D3D11_CLEAR_DEPTH | D3D11_CLEAR_FLAG.D3D11_CLEAR_STENCIL), depth, stencil);
        }

        protected override void UpdateBufferCore(DeviceBuffer buffer, uint32 bufferOffsetInBytes, void* source, uint32 sizeInBytes)
        {
            D3D11Buffer d3dBuffer = Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(buffer);
            if (sizeInBytes == 0)
            {
                return;
            }

            bool isDynamic = (buffer.Usage & BufferUsage.Dynamic) == BufferUsage.Dynamic;
            bool isStaging = (buffer.Usage & BufferUsage.Staging) == BufferUsage.Staging;
            bool isUniformBuffer = (buffer.Usage & BufferUsage.UniformBuffer) == BufferUsage.UniformBuffer;
            bool useMap = isDynamic;
            bool updateFullBuffer = bufferOffsetInBytes == 0 && sizeInBytes == buffer.SizeInBytes;
            bool useUpdateSubresource = !isDynamic && !isStaging && (!isUniformBuffer || updateFullBuffer);

            if (useUpdateSubresource)
            {
                D3D11_BOX* subregion = scope :: .(bufferOffsetInBytes, 0, 0, (sizeInBytes + bufferOffsetInBytes), 1, 1);
                if (isUniformBuffer)
                {
                    subregion = null;
                }

                if (bufferOffsetInBytes == 0)
                {
                    _context.UpdateSubresource(d3dBuffer.Buffer, 0, subregion, source, 0, 0);
                }
                else
                {
                    UpdateSubresource_Workaround(d3dBuffer.Buffer, 0, subregion, source);
                }
            }
            else if (useMap && updateFullBuffer) // Can only update full buffer with WriteDiscard.
            {
                D3D11_MAPPED_SUBRESOURCE msb = .();
				HRESULT hr = _context.Map(
					d3dBuffer.Buffer,
					0,
					D3D11Formats.VdToD3D11MapMode(isDynamic, MapMode.Write),
					0, &msb);
                if (sizeInBytes < 1024)
                {
                    Internal.MemCpy(msb.pData, source, sizeInBytes);
                }
                else
                {
                    Internal.MemCpy(msb.pData, source, sizeInBytes);
                }
                _context.Unmap(d3dBuffer.Buffer, 0);
            }
            else
            {
                D3D11Buffer staging = GetFreeStagingBuffer(sizeInBytes);
                _gd.UpdateBuffer(staging, 0, source, sizeInBytes);
                CopyBuffer(staging, 0, buffer, bufferOffsetInBytes, sizeInBytes);
                _submittedStagingBuffers.Add(staging);
            }
        }

        private void UpdateSubresource_Workaround(
            ID3D11Resource* resource,
            int32 subresource,
            D3D11_BOX* region,
            void* data)
        {
            bool needWorkaround = !_gd.SupportsCommandLists;
            void* pAdjustedSrcData = data;
            if (needWorkaround)
            {
                Debug.Assert(region.top == 0 && region.front == 0);
                pAdjustedSrcData = (uint8*)data - region.left;
            }

            _context.UpdateSubresource(resource, (uint32)subresource, region, pAdjustedSrcData, 0, 0);
        }


        private D3D11Buffer GetFreeStagingBuffer(uint32 sizeInBytes)
        {
            for (D3D11Buffer buffer in _availableStagingBuffers)
            {
                if (buffer.SizeInBytes >= sizeInBytes)
                {
                    _availableStagingBuffers.Remove(buffer);
                    return buffer;
                }
            }

            DeviceBuffer staging = _gd.ResourceFactory.CreateBuffer(
                BufferDescription(sizeInBytes, BufferUsage.Staging));

            return Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(staging);
        }

        protected override void CopyBufferCore(DeviceBuffer source, uint32 sourceOffset, DeviceBuffer destination, uint32 destinationOffset, uint32 sizeInBytes)
        {
            D3D11Buffer srcD3D11Buffer = Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(source);
            D3D11Buffer dstD3D11Buffer = Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(destination);

            D3D11_BOX* region = scope .(sourceOffset, 0, 0, (sourceOffset + sizeInBytes), 1, 1);

            _context.CopySubresourceRegion(dstD3D11Buffer.Buffer, 0, destinationOffset, 0, 0, srcD3D11Buffer.Buffer, 0, region);
        }

        protected override void CopyTextureCore(
            Texture source,
            uint32 srcX, uint32 srcY, uint32 srcZ,
            uint32 srcMipLevel,
            uint32 srcBaseArrayLayer,
            Texture destination,
            uint32 dstX, uint32 dstY, uint32 dstZ,
            uint32 dstMipLevel,
            uint32 dstBaseArrayLayer,
            uint32 width, uint32 height, uint32 depth,
            uint32 layerCount)
        {
            D3D11Texture srcD3D11Texture = Util.AssertSubtype<Texture, D3D11Texture>(source);
            D3D11Texture dstD3D11Texture = Util.AssertSubtype<Texture, D3D11Texture>(destination);

            uint32 blockSize = FormatHelpers.IsCompressedFormat(source.Format) ? 4u : 1u;
            uint32 clampedWidth = Math.Max(blockSize, width);
            uint32 clampedHeight = Math.Max(blockSize, height);

            D3D11_BOX* region = null;
            if (srcX != 0 || srcY != 0 || srcZ != 0
                || clampedWidth != source.Width || clampedHeight != source.Height || depth != source.Depth)
            {
                region = scope :: .(
                    srcX,
                    srcY,
                    srcZ,
                    (srcX + clampedWidth),
                    (srcY + clampedHeight),
                    (srcZ + depth));
            }

            for (uint32 i = 0; i < layerCount; i++)
            {
                int32 srcSubresource = D3D11Util.ComputeSubresource(srcMipLevel, source.MipLevels, srcBaseArrayLayer + i);
                int32 dstSubresource = D3D11Util.ComputeSubresource(dstMipLevel, destination.MipLevels, dstBaseArrayLayer + i);

                _context.CopySubresourceRegion(
                    dstD3D11Texture.DeviceTexture,
                    (uint32)dstSubresource,
                    dstX,
                    dstY,
                    dstZ,
                    srcD3D11Texture.DeviceTexture,
                    (uint32)srcSubresource,
                    region);
            }
        }

        protected override void GenerateMipmapsCore(Texture texture)
        {
            TextureView fullTexView = texture.GetFullTextureView(_gd);
            D3D11TextureView d3d11View = Util.AssertSubtype<TextureView, D3D11TextureView>(fullTexView);
            ID3D11ShaderResourceView* srv = d3d11View.ShaderResourceView;
            _context.GenerateMips(srv);
        }

        public override String Name
        {
            get => _name;
            set
            {
                _name = value;
                D3D11Util.SetDebugName(_context, value);
            }
        }

        internal void OnCompleted()
        {
            _commandList.Release();
            _commandList = null;

            for (D3D11Swapchain sc in _referencedSwapchains)
            {
                sc.RemoveCommandListReference(this);
            }
            _referencedSwapchains.Clear();

            for (D3D11Buffer buffer in _submittedStagingBuffers)
            {
                _availableStagingBuffers.Add(buffer);
            }

            _submittedStagingBuffers.Clear();
        }

        protected override void PushDebugGroupCore(String name)
        {
            _uda?.BeginEvent(name.ToScopedNativeWChar!());
        }

        protected override void PopDebugGroupCore()
        {
            _uda?.EndEvent();
        }

        protected override void InsertDebugMarkerCore(String name)
        {
            _uda?.SetMarker(name.ToScopedNativeWChar!());
        }

        public override void Dispose()
        {
            if (!_disposed)
            {
                _uda?.Release();
                DeviceCommandList?.Release();
                _context1?.Release();
                _context.Release();

                for (BoundResourceSetInfo boundGraphicsSet in _graphicsResourceSets)
                {
                    boundGraphicsSet.Offsets.Dispose();
                }
                for (BoundResourceSetInfo boundComputeSet in _computeResourceSets)
                {
                    boundComputeSet.Offsets.Dispose();
                }

                for (D3D11Buffer buffer in _availableStagingBuffers)
                {
                    buffer.Dispose();
                }
                _availableStagingBuffers.Clear();

                _disposed = true;
            }
        }

        private struct BoundTextureInfo
        {
            public int32 Slot;
            public ShaderStages Stages;
            public uint32 ResourceSet;
        }

        private struct D3D11BufferRange : IEquatable<D3D11BufferRange>
        {
            public readonly D3D11Buffer Buffer;
            public readonly uint32 Offset;
            public readonly uint32 Size;

            public bool IsFullRange => Offset == 0 && Size == Buffer.SizeInBytes;

            public this(D3D11Buffer buffer, uint32 offset, uint32 size)
            {
                Buffer = buffer;
                Offset = offset;
                Size = size;
            }

            public bool Equals(D3D11BufferRange other)
            {
                return Buffer == other.Buffer && Offset == other.Offset && Size == other.Size;
            }
        }
    }
}
