using System;
namespace Sedulous.GAL.D3D11
{
    public class D3D11ResourceLayout : ResourceLayout
    {
        private readonly ResourceBindingInfo[] _bindingInfosByVdIndex;
        private String _name;
        private bool _disposed;

        public int32 UniformBufferCount { get; }
        public int32 StorageBufferCount { get; }
        public int32 TextureCount { get; }
        public int32 SamplerCount { get; }

        public this(in ResourceLayoutDescription description)
            : base(description)
        {
            ResourceLayoutElementDescription[] elements = description.Elements;
            _bindingInfosByVdIndex = new ResourceBindingInfo[elements.Count];

            int32 cbIndex = 0;
            int32 texIndex = 0;
            int32 samplerIndex = 0;
            int32 unorderedAccessIndex = 0;

            for (int i = 0; i < _bindingInfosByVdIndex.Count; i++)
            {
                int32 slot;
                switch (elements[i].Kind)
                {
                    case ResourceKind.UniformBuffer:
                        slot = cbIndex++;
                        break;
                    case ResourceKind.StructuredBufferReadOnly:
                        slot = texIndex++;
                        break;
                    case ResourceKind.StructuredBufferReadWrite:
                        slot = unorderedAccessIndex++;
                        break;
                    case ResourceKind.TextureReadOnly:
                        slot = texIndex++;
                        break;
                    case ResourceKind.TextureReadWrite:
                        slot = unorderedAccessIndex++;
                        break;
                    case ResourceKind.Sampler:
                        slot = samplerIndex++;
                        break;
                    default: Runtime.IllegalValue<ResourceKind>();
                }

                _bindingInfosByVdIndex[i] = ResourceBindingInfo(
                    slot,
                    elements[i].Stages,
                    elements[i].Kind,
                    (elements[i].Options & ResourceLayoutElementOptions.DynamicBinding) != 0);
            }

            UniformBufferCount = cbIndex;
            StorageBufferCount = unorderedAccessIndex;
            TextureCount = texIndex;
            SamplerCount = samplerIndex;
        }

        internal ResourceBindingInfo GetDeviceSlotIndex(int32 resourceLayoutIndex)
        {
            if (resourceLayoutIndex >= _bindingInfosByVdIndex.Count)
            {
                Runtime.GALError(scope $"Invalid resource index: {resourceLayoutIndex}. Maximum is: {_bindingInfosByVdIndex.Count - 1}.");
            }

            return _bindingInfosByVdIndex[resourceLayoutIndex];
        }

        public bool IsDynamicBuffer(int32 index) => _bindingInfosByVdIndex[index].DynamicBuffer;

        public override String Name
        {
            get => _name;
            set => _name = value;
        }

        public override bool IsDisposed => _disposed;

        public override void Dispose()
        {
            _disposed = true;
        }

        internal struct ResourceBindingInfo
        {
            public int32 Slot;
            public ShaderStages Stages;
            public ResourceKind Kind;
            public bool DynamicBuffer;

            public this(int32 slot, ShaderStages stages, ResourceKind kind, bool dynamicBuffer)
            {
                Slot = slot;
                Stages = stages;
                Kind = kind;
                DynamicBuffer = dynamicBuffer;
            }
        }
    }
}
