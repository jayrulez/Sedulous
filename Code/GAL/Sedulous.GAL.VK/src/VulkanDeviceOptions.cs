using System;
namespace Sedulous.GAL.VK
{
    /// <summary>
    /// A structure describing Vulkan-specific device creation options.
    /// </summary>
    public struct VulkanDeviceOptions
    {
        /// <summary>
        /// An array of required Vulkan instance extensions. Entries in this array will be enabled in the GraphicsDevice's
        /// created VkInstance.
        /// </summary>
        public Span<String> InstanceExtensions;
        /// <summary>
        /// An array of required Vulkan device extensions. Entries in this array will be enabled in the GraphicsDevice's
        /// created VkDevice.
        /// </summary>
        public Span<String> DeviceExtensions;

        /// <summary>
        /// Constructs a new VulkanDeviceOptions.
        /// </summary>
        /// <param name="instanceExtensions">An array of required Vulkan instance extensions. Entries in this array will be
        /// enabled in the GraphicsDevice's created VkInstance.</param>
        /// <param name="deviceExtensions">An array of required Vulkan device extensions. Entries in this array will be enabled
        /// in the GraphicsDevice's created VkDevice.</param>
        public this(Span<String> instanceExtensions, Span<String> deviceExtensions)
        {
            InstanceExtensions = instanceExtensions;
            DeviceExtensions = deviceExtensions;
        }
    }
}
