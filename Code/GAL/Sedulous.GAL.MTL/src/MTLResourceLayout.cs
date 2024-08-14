using System;
namespace Sedulous.GAL.MTL
{
    public class MTLResourceLayout : ResourceLayout
    {
        private readonly ResourceBindingInfo[] _bindingInfosByVdIndex;
        private bool _disposed;
        public uint32 BufferCount { get; }
        public uint32 TextureCount { get; }
        public uint32 SamplerCount { get; }
#if !VALIDATE_USAGE
        public ResourceKind[] ResourceKinds { get; }
#endif
        internal ResourceBindingInfo GetBindingInfo(int32 index) => _bindingInfosByVdIndex[index];

#if !VALIDATE_USAGE
        public ResourceLayoutDescription Description { get; }
#endif

        public this(in ResourceLayoutDescription description, MTLGraphicsDevice gd)
            : base(description)
        {
#if !VALIDATE_USAGE
            Description = description;
#endif

            ResourceLayoutElementDescription[] elements = description.Elements;
#if !VALIDATE_USAGE
            ResourceKinds = new ResourceKind[elements.Count];
            for (int32 i = 0; i < elements.Count; i++)
            {
                ResourceKinds[i] = elements[i].Kind;
            }
#endif

            _bindingInfosByVdIndex = new ResourceBindingInfo[elements.Count];

            uint32 bufferIndex = 0;
            uint32 texIndex = 0;
            uint32 samplerIndex = 0;

            for (int32 i = 0; i < _bindingInfosByVdIndex.Count; i++)
            {
                uint32 slot;
                switch (elements[i].Kind)
                {
                    case ResourceKind.UniformBuffer:
                        slot = bufferIndex++;
                        break;
                    case ResourceKind.StructuredBufferReadOnly:
                        slot = bufferIndex++;
                        break;
                    case ResourceKind.StructuredBufferReadWrite:
                        slot = bufferIndex++;
                        break;
                    case ResourceKind.TextureReadOnly:
                        slot = texIndex++;
                        break;
                    case ResourceKind.TextureReadWrite:
                        slot = texIndex++;
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

            BufferCount = bufferIndex;
            TextureCount = texIndex;
            SamplerCount = samplerIndex;
        }

        public override String Name { get; set; }

        public override bool IsDisposed => _disposed;

        public override void Dispose()
        {
            _disposed = true;
        }

        internal struct ResourceBindingInfo
        {
            public uint32 Slot;
            public ShaderStages Stages;
            public ResourceKind Kind;
            public bool DynamicBuffer;

            public this(uint32 slot, ShaderStages stages, ResourceKind kind, bool dynamicBuffer)
            {
                Slot = slot;
                Stages = stages;
                Kind = kind;
                DynamicBuffer = dynamicBuffer;
            }
        }
    }
}
