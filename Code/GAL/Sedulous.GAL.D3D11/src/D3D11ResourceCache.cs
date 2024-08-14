using System;
using System.Diagnostics;
using System.Threading;
using Win32.Graphics.Direct3D11;
using System.Collections;
using Win32;
using Win32.Foundation;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.D3D11;

    internal class D3D11ResourceCache : IDisposable
    {
        private readonly ID3D11Device* _device;
        private readonly Monitor _lock = new .() ~ delete _;

        private readonly Dictionary<BlendStateDescription, ID3D11BlendState*> _blendStates = new .() ~ delete _;

        private readonly Dictionary<DepthStencilStateDescription, ID3D11DepthStencilState*> _depthStencilStates = new .() ~ delete _;

        private readonly Dictionary<D3D11RasterizerStateCacheKey, ID3D11RasterizerState*> _rasterizerStates = new .() ~ delete _;

        private readonly Dictionary<InputLayoutCacheKey, ID3D11InputLayout*> _inputLayouts = new .() ~ delete _;

        public this(ID3D11Device* device)
        {
            _device = device;
        }

        public void GetPipelineResources(
            in BlendStateDescription blendDesc,
            in DepthStencilStateDescription dssDesc,
            in RasterizerStateDescription rasterDesc,
            bool multisample,
            VertexLayoutDescription[] vertexLayouts,
            List<uint8> vsBytecode,
            out ID3D11BlendState* blendState,
            out ID3D11DepthStencilState* depthState,
            out ID3D11RasterizerState* rasterState,
            out ID3D11InputLayout* inputLayout)
        {
            using (_lock.Enter())
            {
                blendState = GetBlendState(blendDesc);
                depthState = GetDepthStencilState(dssDesc);
                rasterState = GetRasterizerState(rasterDesc, multisample);
                inputLayout = GetInputLayout(vertexLayouts, vsBytecode);
            }
        }

        private ID3D11BlendState* GetBlendState(in BlendStateDescription description)
        {
            //Debug.Assert(Monitor.IsEntered(_lock));
            if (!_blendStates.TryGetValue(description, var blendState))
            {
                blendState = CreateNewBlendState(description);
                BlendStateDescription key = description;
				//key.AttachmentStates = (BlendAttachmentDescription[])key.AttachmentStates.Clone(); // AttachmentStates is value type and is copied
                _blendStates.Add(key, blendState);
            }

            return blendState;
        }

        private ID3D11BlendState* CreateNewBlendState(in BlendStateDescription description)
        {
            BlendAttachmentList attachmentStates = description.AttachmentStates;
            D3D11_BLEND_DESC d3dBlendStateDesc = D3D11_BLEND_DESC();

            for (int i = 0; i < attachmentStates.Count; i++)
            {
                BlendAttachmentDescription state = attachmentStates[i];
                d3dBlendStateDesc.RenderTarget[i].BlendEnable = state.BlendEnabled ? TRUE : FALSE;
                d3dBlendStateDesc.RenderTarget[i].RenderTargetWriteMask = (uint8)D3D11Formats.VdToD3D11ColorWriteEnable(state.ColorWriteMask.GetValueOrDefault());
                d3dBlendStateDesc.RenderTarget[i].SrcBlend = D3D11Formats.VdToD3D11Blend(state.SourceColorFactor);
                d3dBlendStateDesc.RenderTarget[i].DestBlend = D3D11Formats.VdToD3D11Blend(state.DestinationColorFactor);
                d3dBlendStateDesc.RenderTarget[i].BlendOp = D3D11Formats.VdToD3D11BlendOperation(state.ColorFunction);
                d3dBlendStateDesc.RenderTarget[i].SrcBlendAlpha = D3D11Formats.VdToD3D11Blend(state.SourceAlphaFactor);
                d3dBlendStateDesc.RenderTarget[i].DestBlendAlpha = D3D11Formats.VdToD3D11Blend(state.DestinationAlphaFactor);
                d3dBlendStateDesc.RenderTarget[i].BlendOpAlpha = D3D11Formats.VdToD3D11BlendOperation(state.AlphaFunction);
            }

            d3dBlendStateDesc.AlphaToCoverageEnable = description.AlphaToCoverageEnabled ? TRUE : FALSE;
			d3dBlendStateDesc.IndependentBlendEnable = TRUE;

			ID3D11BlendState* bs = null;
			HRESULT hr = _device.CreateBlendState(&d3dBlendStateDesc, &bs);
			return bs;
        }

        private ID3D11DepthStencilState* GetDepthStencilState(in DepthStencilStateDescription description)
        {
            //Debug.Assert(Monitor.IsEntered(_lock));
            if (!_depthStencilStates.TryGetValue(description, var dss))
            {
                dss = CreateNewDepthStencilState(description);
                DepthStencilStateDescription key = description;
                _depthStencilStates.Add(key, dss);
            }

            return dss;
        }

        private ID3D11DepthStencilState* CreateNewDepthStencilState(in DepthStencilStateDescription description)
        {
            D3D11_DEPTH_STENCIL_DESC dssDesc = D3D11_DEPTH_STENCIL_DESC()
            {
                DepthFunc = D3D11Formats.VdToD3D11ComparisonFunc(description.DepthComparison),
                DepthEnable = description.DepthTestEnabled ? TRUE : FALSE,
				DepthWriteMask = description.DepthWriteEnabled ? .D3D11_DEPTH_WRITE_MASK_ALL : .D3D11_DEPTH_WRITE_MASK_ZERO,
				StencilEnable = description.StencilTestEnabled ? TRUE : FALSE,
                FrontFace = ToD3D11StencilOpDesc(description.StencilFront),
                BackFace = ToD3D11StencilOpDesc(description.StencilBack),
                StencilReadMask = description.StencilReadMask,
                StencilWriteMask = description.StencilWriteMask
            };

            ID3D11DepthStencilState* dss = null;
			HRESULT hr = _device.CreateDepthStencilState(&dssDesc, &dss);
			return dss;
        }

        private D3D11_DEPTH_STENCILOP_DESC ToD3D11StencilOpDesc(StencilBehaviorDescription sbd)
        {
            return D3D11_DEPTH_STENCILOP_DESC()
            {
                StencilFunc = D3D11Formats.VdToD3D11ComparisonFunc(sbd.Comparison),
                StencilPassOp = D3D11Formats.VdToD3D11StencilOperation(sbd.Pass),
                StencilFailOp = D3D11Formats.VdToD3D11StencilOperation(sbd.Fail),
                StencilDepthFailOp = D3D11Formats.VdToD3D11StencilOperation(sbd.DepthFail)
            };
        }

        private ID3D11RasterizerState* GetRasterizerState(in RasterizerStateDescription description, bool multisample)
        {
            //Debug.Assert(Monitor.IsEntered(_lock));
            D3D11RasterizerStateCacheKey key = D3D11RasterizerStateCacheKey(description, multisample);
            if (!_rasterizerStates.TryGetValue(key, var rasterizerState))
            {
                rasterizerState = CreateNewRasterizerState(key);
                _rasterizerStates.Add(key, rasterizerState);
            }

            return rasterizerState;
        }

        private ID3D11RasterizerState* CreateNewRasterizerState(in D3D11RasterizerStateCacheKey key)
        {
            D3D11_RASTERIZER_DESC rssDesc = D3D11_RASTERIZER_DESC()
            {
                CullMode = D3D11Formats.VdToD3D11CullMode(key.GALDescription.CullMode),
                FillMode = D3D11Formats.VdToD3D11FillMode(key.GALDescription.FillMode),
                DepthClipEnable = key.GALDescription.DepthClipEnabled ? TRUE : FALSE,
                ScissorEnable = key.GALDescription.ScissorTestEnabled ? TRUE : FALSE,
                FrontCounterClockwise = key.GALDescription.FrontFace == FrontFace.CounterClockwise ? TRUE : FALSE,
                MultisampleEnable = key.Multisampled ? TRUE : FALSE
            };

            ID3D11RasterizerState* rs = null;
			HRESULT hr = _device.CreateRasterizerState(&rssDesc, &rs);
			return rs;
        }

        private ID3D11InputLayout* GetInputLayout(VertexLayoutDescription[] vertexLayouts, List<uint8> vsBytecode)
        {
            //Debug.Assert(Monitor.IsEntered(_lock));

            if (vsBytecode == null || vertexLayouts == null || vertexLayouts.Count == 0) { return null; }

            InputLayoutCacheKey tempKey = InputLayoutCacheKey.CreateTempKey(vertexLayouts);
            if (!_inputLayouts.TryGetValue(tempKey, var inputLayout))
            {
                inputLayout = CreateNewInputLayout(vertexLayouts, vsBytecode);
                InputLayoutCacheKey permanentKey = InputLayoutCacheKey.CreatePermanentKey(vertexLayouts);
                _inputLayouts.Add(permanentKey, inputLayout);
            }

            return inputLayout;
        }

        private ID3D11InputLayout* CreateNewInputLayout(VertexLayoutDescription[] vertexLayouts, List<uint8> vsBytecode)
        {
            int totalCount = 0;
            for (int i = 0; i < vertexLayouts.Count; i++)
            {
                totalCount += vertexLayouts[i].Elements.Count;
            }

            int32 element = 0; // Total element index across slots.
            D3D11_INPUT_ELEMENT_DESC[] elements = scope D3D11_INPUT_ELEMENT_DESC[totalCount];
            SemanticIndices si = SemanticIndices();
            for (int32 slot = 0; slot < vertexLayouts.Count; slot++)
            {
                VertexElementDescription[] elementDescs = vertexLayouts[slot].Elements;
                uint32 stepRate = vertexLayouts[slot].InstanceStepRate;
                uint32 currentOffset = 0;
                for (int32 i = 0; i < elementDescs.Count; i++)
                {
                    VertexElementDescription desc = elementDescs[i];
                    elements[element] = D3D11_INPUT_ELEMENT_DESC(
                        semanticName: (uint8*)GetSemanticString(desc.Semantic).CStr(),
                        semanticIndex: (uint32)SemanticIndices.GetAndIncrement(ref si, desc.Semantic),
                        format: D3D11Formats.ToDxgiFormat(desc.Format),
                        alignedByteOffset: desc.Offset != 0 ? desc.Offset : currentOffset,
                        inputSlot: (uint32)slot,
                        inputSlotClass: stepRate == 0 ? .D3D11_INPUT_PER_VERTEX_DATA : .D3D11_INPUT_PER_INSTANCE_DATA,
                        instanceDataStepRate: stepRate);

                    currentOffset += FormatSizeHelpers.GetSizeInBytes(desc.Format);
                    element += 1;
                }
            }

            ID3D11InputLayout* il = null;
			HRESULT hr = _device.CreateInputLayout(elements.Ptr, (.)elements.Count, vsBytecode.Ptr, (.)vsBytecode.Count, &il);
			return il;
        }

        private String GetSemanticString(VertexElementSemantic semantic)
        {
            switch (semantic)
            {
                case VertexElementSemantic.Position:
                    return "POSITION";
                case VertexElementSemantic.Normal:
                    return "NORMAL";
                case VertexElementSemantic.TextureCoordinate:
                    return "TEXCOORD";
                case VertexElementSemantic.Color:
                    return "COLOR";
                default:
                    Runtime.IllegalValue<VertexElementSemantic>();
            }
        }

        public void Dispose()
        {
            for ((BlendStateDescription Key, ID3D11BlendState* Value)kvp in _blendStates)
            {
                kvp.Value.Release();
            }
            for ((DepthStencilStateDescription Key, ID3D11DepthStencilState* Value) kvp in _depthStencilStates)
            {
                kvp.Value.Release();
            }
            for ((D3D11RasterizerStateCacheKey Key, ID3D11RasterizerState* Value) kvp in _rasterizerStates)
            {
                kvp.Value.Release();
            }
            for ((InputLayoutCacheKey Key, ID3D11InputLayout* Value) kvp in _inputLayouts)
            {
				kvp.Key.Dispose();
                kvp.Value.Release();
            }
        }

        private struct SemanticIndices
        {
            private int32 _position;
            private int32 _texCoord;
            private int32 _normal;
            private int32 _color;

            public static int32 GetAndIncrement(ref SemanticIndices si, VertexElementSemantic type)
            {
                switch (type)
                {
                    case VertexElementSemantic.Position:
                        return si._position++;
                    case VertexElementSemantic.TextureCoordinate:
                        return si._texCoord++;
                    case VertexElementSemantic.Normal:
                        return si._normal++;
                    case VertexElementSemantic.Color:
                        return si._color++;
                    default:
                        Runtime.IllegalValue<VertexElementSemantic>();
                }
            }
        }

        private struct InputLayoutCacheKey : IEquatable<InputLayoutCacheKey>, IHashable, IDisposable
        {
			private bool mDispose = false;
            public VertexLayoutDescription[] VertexLayouts;

            public static InputLayoutCacheKey CreateTempKey(VertexLayoutDescription[] original)
                => InputLayoutCacheKey() { VertexLayouts = original };

            public static InputLayoutCacheKey CreatePermanentKey(VertexLayoutDescription[] original)
            {
                VertexLayoutDescription[] vertexLayouts = new VertexLayoutDescription[original.Count];
                for (int i = 0; i < original.Count; i++)
                {
                    vertexLayouts[i].Stride = original[i].Stride;
                    vertexLayouts[i].InstanceStepRate = original[i].InstanceStepRate;
					//vertexLayouts[i].Elements = (VertexElementDescription[])original[i].Elements.Clone();
                    vertexLayouts[i].Elements = new .[original[i].Elements.Count];
					for(int j = 0; j < original[i].Elements.Count; j++)
					{
						vertexLayouts[i].Elements[j] = original[i].Elements[j];
					}
                }

                return InputLayoutCacheKey() { VertexLayouts = vertexLayouts };
            }

            public bool Equals(InputLayoutCacheKey other)
            {
                return Util.ArrayEqualsEquatable(VertexLayouts, other.VertexLayouts);
            }

            public int GetHashCode()
            {
                return HashHelper.Array(VertexLayouts);
            }

			public void Dispose()
			{
				for (int i = 0; i < VertexLayouts.Count; i++)
				{
				    delete VertexLayouts[i].Elements;
				}
				delete VertexLayouts;
			}
        }

        private struct D3D11RasterizerStateCacheKey : IEquatable<D3D11RasterizerStateCacheKey>, IHashable
        {
            public RasterizerStateDescription GALDescription;
            public bool Multisampled;

            public this(RasterizerStateDescription galDescription, bool multisampled)
            {
                GALDescription = galDescription;
                Multisampled = multisampled;
            }

            public bool Equals(D3D11RasterizerStateCacheKey other)
            {
                return GALDescription.Equals(other.GALDescription)
                    && Multisampled == other.Multisampled;
            }

            public int GetHashCode()
            {
                return HashHelper.Combine(GALDescription.GetHashCode(), Multisampled.GetHashCode());
            }
        }
    }
}
