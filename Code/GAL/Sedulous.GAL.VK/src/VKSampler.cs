using Vulkan;
using static Vulkan.VulkanNative;

namespace Sedulous.GAL.VK
{
    internal unsafe class VKSampler : Sampler
    {
        private readonly VKGraphicsDevice _gd;
        private readonly Vulkan.VkSampler _sampler;
        private bool _disposed;
        private string _name;

        public Vulkan.VkSampler DeviceSampler => _sampler;

        public ResourceRefCount RefCount { get; }

        public override bool IsDisposed => _disposed;

        public VKSampler(VKGraphicsDevice gd, ref SamplerDescription description)
        {
            _gd = gd;
            VKFormats.GetFilterParams(description.Filter, out VkFilter minFilter, out VkFilter magFilter, out VkSamplerMipmapMode mipmapMode);

            VkSamplerCreateInfo samplerCI = new VkSamplerCreateInfo
            {
                sType = VkStructureType.SamplerCreateInfo,
                addressModeU = VKFormats.VdToVkSamplerAddressMode(description.AddressModeU),
                addressModeV = VKFormats.VdToVkSamplerAddressMode(description.AddressModeV),
                addressModeW = VKFormats.VdToVkSamplerAddressMode(description.AddressModeW),
                minFilter = minFilter,
                magFilter = magFilter,
                mipmapMode = mipmapMode,
                compareEnable = description.ComparisonKind != null,
                compareOp = description.ComparisonKind != null
                    ? VKFormats.VdToVkCompareOp(description.ComparisonKind.Value)
                    : VkCompareOp.Never,
                anisotropyEnable = description.Filter == SamplerFilter.Anisotropic,
                maxAnisotropy = description.MaximumAnisotropy,
                minLod = description.MinimumLod,
                maxLod = description.MaximumLod,
                mipLodBias = description.LodBias,
                borderColor = VKFormats.VdToVkSamplerBorderColor(description.BorderColor)
            };

            vkCreateSampler(_gd.Device, ref samplerCI, null, out _sampler);
            RefCount = new ResourceRefCount(DisposeCore);
        }

        public override string Name
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
