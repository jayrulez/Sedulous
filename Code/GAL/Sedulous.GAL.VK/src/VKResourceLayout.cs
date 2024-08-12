using Vulkan;
using static Vulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;

namespace Sedulous.GAL.VK
{
    internal class VKResourceLayout : ResourceLayout
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkDescriptorSetLayout _dsl;
        private readonly VkDescriptorType[] _descriptorTypes;
        private bool _disposed;
        private string _name;

        public VkDescriptorSetLayout DescriptorSetLayout => _dsl;
        public VkDescriptorType[] DescriptorTypes => _descriptorTypes;
        public DescriptorResourceCounts DescriptorResourceCounts { get; }
        public new int32 DynamicBufferCount { get; }

        public override bool IsDisposed => _disposed;

        public VKResourceLayout(VKGraphicsDevice gd, ref ResourceLayoutDescription description)
            : base(ref description)
        {
            _gd = gd;
            VkDescriptorSetLayoutCreateInfo dslCI = VkDescriptorSetLayoutCreateInfo.New();
            ResourceLayoutElementDescription[] elements = description.Elements;
            _descriptorTypes = new VkDescriptorType[elements.Length];
            VkDescriptorSetLayoutBinding* bindings = stackalloc VkDescriptorSetLayoutBinding[elements.Length];

            uint32 uniformBufferCount = 0;
            uint32 uniformBufferDynamicCount = 0;
            uint32 sampledImageCount = 0;
            uint32 samplerCount = 0;
            uint32 storageBufferCount = 0;
            uint32 storageBufferDynamicCount = 0;
            uint32 storageImageCount = 0;

            for (uint32 i = 0; i < elements.Length; i++)
            {
                bindings[i].binding = i;
                bindings[i].descriptorCount = 1;
                VkDescriptorType descriptorType = VKFormats.VdToVkDescriptorType(elements[i].Kind, elements[i].Options);
                bindings[i].descriptorType = descriptorType;
                bindings[i].stageFlags = VKFormats.VdToVkShaderStages(elements[i].Stages);
                if ((elements[i].Options & ResourceLayoutElementOptions.DynamicBinding) != 0)
                {
                    DynamicBufferCount += 1;
                }

                _descriptorTypes[i] = descriptorType;

                switch (descriptorType)
                {
                    case VkDescriptorType.Sampler:
                        samplerCount += 1;
                        break;
                    case VkDescriptorType.SampledImage:
                        sampledImageCount += 1;
                        break;
                    case VkDescriptorType.StorageImage:
                        storageImageCount += 1;
                        break;
                    case VkDescriptorType.UniformBuffer:
                        uniformBufferCount += 1;
                        break;
                    case VkDescriptorType.UniformBufferDynamic:
                        uniformBufferDynamicCount += 1;
                        break;
                    case VkDescriptorType.StorageBuffer:
                        storageBufferCount += 1;
                        break;
                    case VkDescriptorType.StorageBufferDynamic:
                        storageBufferDynamicCount += 1;
                        break;
                }
            }

            DescriptorResourceCounts = new DescriptorResourceCounts(
                uniformBufferCount,
                uniformBufferDynamicCount,
                sampledImageCount,
                samplerCount,
                storageBufferCount,
                storageBufferDynamicCount,
                storageImageCount);

            dslCI.bindingCount = (uint32)elements.Length;
            dslCI.pBindings = bindings;

            VkResult result = vkCreateDescriptorSetLayout(_gd.Device, ref dslCI, null, out _dsl);
            CheckResult(result);
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
            if (!_disposed)
            {
                _disposed = true;
                vkDestroyDescriptorSetLayout(_gd.Device, _dsl, null);
            }
        }
    }
}
