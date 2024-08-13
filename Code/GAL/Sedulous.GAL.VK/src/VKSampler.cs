using Bulkan;
using System;
using static Bulkan.VulkanNative;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL.VK;

    public class VKSampler : Sampler
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkSampler _sampler;
        private bool _disposed;
        private String _name;

        public VkSampler DeviceSampler => _sampler;

        internal ResourceRefCount RefCount { get; }

        public override bool IsDisposed => _disposed;

        public this(VKGraphicsDevice gd, in SamplerDescription description)
        {
            _gd = gd;
            VKFormats.GetFilterParams(description.Filter, var minFilter, var magFilter, var mipmapMode);

            VkSamplerCreateInfo samplerCI = VkSamplerCreateInfo()
            {
                sType = VkStructureType.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
                addressModeU = VKFormats.VdToVkSamplerAddressMode(description.AddressModeU),
                addressModeV = VKFormats.VdToVkSamplerAddressMode(description.AddressModeV),
                addressModeW = VKFormats.VdToVkSamplerAddressMode(description.AddressModeW),
                minFilter = minFilter,
                magFilter = magFilter,
                mipmapMode = mipmapMode,
                compareEnable = description.ComparisonKind != null,
                compareOp = description.ComparisonKind != null
                    ? VKFormats.VdToVkCompareOp(description.ComparisonKind.Value)
                    : VkCompareOp.VK_COMPARE_OP_NEVER,
                anisotropyEnable = description.Filter == SamplerFilter.Anisotropic,
                maxAnisotropy = description.MaximumAnisotropy,
                minLod = description.MinimumLod,
                maxLod = description.MaximumLod,
                mipLodBias = description.LodBias,
                borderColor = VKFormats.VdToVkSamplerBorderColor(description.BorderColor)
            };

            vkCreateSampler(_gd.Device, &samplerCI, null, &_sampler);
            RefCount = new ResourceRefCount(new => DisposeCore);
        }

        public override String Name
        {
            get => _name;
            set
            {
                _name = value;
                _gd.SetResourceName(this, value);
            }
        }

        public override void Dispose()
        {
            RefCount.Decrement();
        }

        private void DisposeCore()
        {
            if (!_disposed)
            {
                vkDestroySampler(_gd.Device, _sampler, null);
                _disposed = true;
            }
        }
    }
}
