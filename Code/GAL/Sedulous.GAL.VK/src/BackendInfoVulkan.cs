#if !EXCLUDE_VULKAN_BACKEND
using System;
using Sedulous.GAL.VK;
using Bulkan;

namespace Sedulous.GAL
{
    /// <summary>
    /// Exposes Vulkan-specific functionality,
    /// useful for interoperating with native components which interface directly with Vulkan.
    /// Can only be used on <see cref="GraphicsBackend.Vulkan"/>.
    /// </summary>
    public class BackendInfoVulkan
    {
        private readonly VKGraphicsDevice _gd;
        private readonly Lazy<ReadOnlyCollection<string>> _instanceLayers;
        private readonly ReadOnlyCollection<string> _instanceExtensions;
        private readonly Lazy<ReadOnlyCollection<ExtensionProperties>> _deviceExtensions;

        internal this(VKGraphicsDevice gd)
        {
            _gd = gd;
            _instanceLayers = new Lazy<ReadOnlyCollection<string>>(() => new ReadOnlyCollection<string>(VulkanUtil.EnumerateInstanceLayers()));
            _instanceExtensions = new ReadOnlyCollection<string>(VulkanUtil.GetInstanceExtensions());
            _deviceExtensions = new Lazy<ReadOnlyCollection<ExtensionProperties>>(EnumerateDeviceExtensions);
        }

        /// <summary>
        /// Gets the underlying VkInstance used by the GraphicsDevice.
        /// </summary>
        public VkInstance Instance => _gd.Instance.Handle;

        /// <summary>
        /// Gets the underlying VkDevice used by the GraphicsDevice.
        /// </summary>
        public VkDevice Device => _gd.Device.Handle;

        /// <summary>
        /// Gets the underlying VkPhysicalDevice used by the GraphicsDevice.
        /// </summary>
        public VkPhysicalDevice PhysicalDevice => _gd.PhysicalDevice.Handle;

        /// <summary>
        /// Gets the VkQueue which is used by the GraphicsDevice to submit graphics work.
        /// </summary>
        public VkQueue GraphicsQueue => _gd.GraphicsQueue.Handle;

        /// <summary>
        /// Gets the queue family index of the graphics VkQueue.
        /// </summary>
        public uint32 GraphicsQueueFamilyIndex => _gd.GraphicsQueueIndex;

        /// <summary>
        /// Gets the driver name of the device. May be null.
        /// </summary>
        public String DriverName => _gd.DriverName;

        /// <summary>
        /// Gets the driver information of the device. May be null.
        /// </summary>
        public String DriverInfo => _gd.DriverInfo;

        public Span<String> AvailableInstanceLayers => _instanceLayers.Value;

        public Span<String> AvailableInstanceExtensions => _instanceExtensions;

        public Span<ExtensionProperties> AvailableDeviceExtensions => _deviceExtensions.Value;

        /// <summary>
        /// Overrides the current VkImageLayout tracked by the given Texture. This should be used when a VkImage is created by
        /// an external library to inform the GAL about its initial layout.
        /// </summary>
        /// <param name="texture">The Texture whose currently-tracked VkImageLayout will be overridden.</param>
        /// <param name="layout">The new VkImageLayout value.</param>
        public void OverrideImageLayout(Texture texture, uint32 layout)
        {
            VKTexture vkTex = Util.AssertSubtype<Texture, VKTexture>(texture);
            for (uint32 layer = 0; layer < vkTex.ArrayLayers; layer++)
            {
                for (uint32 level = 0; level < vkTex.MipLevels; level++)
                {
                    vkTex.SetImageLayout(level, layer, (VkImageLayout)layout);
                }
            }
        }

        /// <summary>
        /// Gets the underlying VkImage wrapped by the given GAL Texture. This method can not be used on Textures with
        /// TextureUsage.Staging.
        /// </summary>
        /// <param name="texture">The Texture whose underlying VkImage will be returned.</param>
        /// <returns>The underlying VkImage for the given Texture.</returns>
        public uint64 GetVkImage(Texture texture)
        {
            VKTexture vkTexture = Util.AssertSubtype<Texture, VKTexture>(texture);
            if ((vkTexture.Usage & TextureUsage.Staging) != 0)
            {
                Runtime.GALError(
                    $"{nameof(GetVkImage)} cannot be used if the {nameof(Texture)} " +
                    $"has {nameof(TextureUsage)}.{nameof(TextureUsage.Staging)}.");
            }

            return vkTexture.OptimalDeviceImage.Handle;
        }

        /// <summary>
        /// Transitions the given Texture's underlying VkImage into a new layout.
        /// </summary>
        /// <param name="texture">The Texture whose underlying VkImage will be transitioned.</param>
        /// <param name="layout">The new VkImageLayout value.</param>
        public void TransitionImageLayout(Texture texture, uint32 layout)
        {
            _gd.TransitionImageLayout(Util.AssertSubtype<Texture, VKTexture>(texture), (VkImageLayout)layout);
        }

        private ReadOnlyCollection<ExtensionProperties> EnumerateDeviceExtensions()
        {
            VkExtensionProperties[] vkProps = _gd.GetDeviceExtensionProperties();
            ExtensionProperties[] galProps = new ExtensionProperties[vkProps.Length];

            for (int32 i = 0; i < vkProps.Length; i++)
            {
                VkExtensionProperties prop = vkProps[i];
                galProps[i] = new ExtensionProperties(Util.GetString(prop.extensionName), prop.specVersion);
            }

            return new ReadOnlyCollection<ExtensionProperties>(galProps);
        }

        public struct ExtensionProperties
        {
            public readonly string Name;
            public readonly uint32 SpecVersion;

            public ExtensionProperties(string name, uint32 specVersion)
            {
                Name = name ?? throw new ArgumentNullException(nameof(name));
                SpecVersion = specVersion;
            }

            public override string ToString()
            {
                return Name;
            }
        }
    }
}
#endif
