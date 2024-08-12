using System;
using System.Diagnostics;
using Bulkan;
using System.Collections;
using static Bulkan.VulkanNative;

namespace Sedulous.GAL.VK
{
    public static class VulkanUtil
    {
#if !VALIDATE_USAGE
        [SkipCall]//[Conditional("VALIDATE_USAGE")]
#endif
        public static void CheckResult(VkResult result)
        {
            if (result != VkResult.VK_SUCCESS)
            {
                Runtime.GALError(scope $"Unsuccessful VkResult: {result}");
            }
        }

        public static bool TryFindMemoryType(VkPhysicalDeviceMemoryProperties memProperties, uint32 typeFilter, VkMemoryPropertyFlags properties, out uint32 typeIndex)
        {
            typeIndex = 0;

            for (int i = 0; i < memProperties.memoryTypeCount; i++)
            {
                if (((typeFilter & (1 << i)) != 0)
                    && (memProperties.memoryTypes[(uint32)i].propertyFlags & properties) == properties)
                {
                    typeIndex = (uint32)i;
                    return true;
                }
            }

            return false;
        }

        public static void EnumerateInstanceLayers(List<String> instanceLayers)
        {
            uint32 propCount = 0;
            VkResult result = vkEnumerateInstanceLayerProperties(&propCount, null);
            CheckResult(result);
            if (propCount == 0)
            {
                return;
            }

            VkLayerProperties[] props = scope VkLayerProperties[propCount];
            vkEnumerateInstanceLayerProperties(&propCount, props.Ptr);

            instanceLayers.Resize(propCount);
            for (int i = 0; i < propCount; i++)
            {
                instanceLayers[i] = new String(&props[i].layerName);
            }
        }

        public static void GetInstanceExtensions(List<String> instanceExtensions)
			=> EnumerateInstanceExtensions(instanceExtensions);

        private static void EnumerateInstanceExtensions(List<String> instanceExtensions)
        {
            if (!VulkanNative.Initialized)
            {
                return;
            }

            uint32 propCount = 0;
            VkResult result = vkEnumerateInstanceExtensionProperties(null, &propCount, null);
            if (result != VkResult.VK_SUCCESS)
            {
                return;
            }

            if (propCount == 0)
            {
                return;
            }

            VkExtensionProperties[] props = scope VkExtensionProperties[propCount];
            vkEnumerateInstanceExtensionProperties(null, &propCount, props.Ptr);

            instanceExtensions.Resize(propCount);
            for (int i = 0; i < propCount; i++)
            {
                instanceExtensions[i] = new .(&props[i].extensionName);
            }
        }

        public static void TransitionImageLayout(
            VkCommandBuffer cb,
            VkImage image,
            uint32 baseMipLevel,
            uint32 levelCount,
            uint32 baseArrayLayer,
            uint32 layerCount,
            VkImageAspectFlags aspectMask,
            VkImageLayout oldLayout,
            VkImageLayout newLayout)
        {
            Debug.Assert(oldLayout != newLayout);
            VkImageMemoryBarrier barrier = VkImageMemoryBarrier() {
				sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER
			};
            barrier.oldLayout = oldLayout;
            barrier.newLayout = newLayout;
            barrier.srcQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED;
            barrier.dstQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED;
            barrier.image = image;
            barrier.subresourceRange.aspectMask = aspectMask;
            barrier.subresourceRange.baseMipLevel = baseMipLevel;
            barrier.subresourceRange.levelCount = levelCount;
            barrier.subresourceRange.baseArrayLayer = baseArrayLayer;
            barrier.subresourceRange.layerCount = layerCount;

            VkPipelineStageFlags srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_NONE;
            VkPipelineStageFlags dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_NONE;

            if ((oldLayout == VkImageLayout.Undefined || oldLayout == VkImageLayout.Preinitialized) && newLayout == VkImageLayout.TransferDstOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.None;
                barrier.dstAccessMask = VkAccessFlags.TransferWrite;
                srcStageFlags = VkPipelineStageFlags.TopOfPipe;
                dstStageFlags = VkPipelineStageFlags.Transfer;
            }
            else if (oldLayout == VkImageLayout.ShaderReadOnlyOptimal && newLayout == VkImageLayout.TransferSrcOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.ShaderRead;
                barrier.dstAccessMask = VkAccessFlags.TransferRead;
                srcStageFlags = VkPipelineStageFlags.FragmentShader;
                dstStageFlags = VkPipelineStageFlags.Transfer;
            }
            else if (oldLayout == VkImageLayout.ShaderReadOnlyOptimal && newLayout == VkImageLayout.TransferDstOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.ShaderRead;
                barrier.dstAccessMask = VkAccessFlags.TransferWrite;
                srcStageFlags = VkPipelineStageFlags.FragmentShader;
                dstStageFlags = VkPipelineStageFlags.Transfer;
            }
            else if (oldLayout == VkImageLayout.Preinitialized && newLayout == VkImageLayout.TransferSrcOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.None;
                barrier.dstAccessMask = VkAccessFlags.TransferRead;
                srcStageFlags = VkPipelineStageFlags.TopOfPipe;
                dstStageFlags = VkPipelineStageFlags.Transfer;
            }
            else if (oldLayout == VkImageLayout.Preinitialized && newLayout == VkImageLayout.General)
            {
                barrier.srcAccessMask = VkAccessFlags.None;
                barrier.dstAccessMask = VkAccessFlags.ShaderRead;
                srcStageFlags = VkPipelineStageFlags.TopOfPipe;
                dstStageFlags = VkPipelineStageFlags.ComputeShader;
            }
            else if (oldLayout == VkImageLayout.Preinitialized && newLayout == VkImageLayout.ShaderReadOnlyOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.None;
                barrier.dstAccessMask = VkAccessFlags.ShaderRead;
                srcStageFlags = VkPipelineStageFlags.TopOfPipe;
                dstStageFlags = VkPipelineStageFlags.FragmentShader;
            }
            else if (oldLayout == VkImageLayout.General && newLayout == VkImageLayout.ShaderReadOnlyOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.TransferRead;
                barrier.dstAccessMask = VkAccessFlags.ShaderRead;
                srcStageFlags = VkPipelineStageFlags.Transfer;
                dstStageFlags = VkPipelineStageFlags.FragmentShader;
            }
            else if (oldLayout == VkImageLayout.ShaderReadOnlyOptimal && newLayout == VkImageLayout.General)
            {
                barrier.srcAccessMask = VkAccessFlags.ShaderRead;
                barrier.dstAccessMask = VkAccessFlags.ShaderRead;
                srcStageFlags = VkPipelineStageFlags.FragmentShader;
                dstStageFlags = VkPipelineStageFlags.ComputeShader;
            }

            else if (oldLayout == VkImageLayout.TransferSrcOptimal && newLayout == VkImageLayout.ShaderReadOnlyOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.TransferRead;
                barrier.dstAccessMask = VkAccessFlags.ShaderRead;
                srcStageFlags = VkPipelineStageFlags.Transfer;
                dstStageFlags = VkPipelineStageFlags.FragmentShader;
            }
            else if (oldLayout == VkImageLayout.TransferDstOptimal && newLayout == VkImageLayout.ShaderReadOnlyOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.TransferWrite;
                barrier.dstAccessMask = VkAccessFlags.ShaderRead;
                srcStageFlags = VkPipelineStageFlags.Transfer;
                dstStageFlags = VkPipelineStageFlags.FragmentShader;
            }
            else if (oldLayout == VkImageLayout.TransferSrcOptimal && newLayout == VkImageLayout.TransferDstOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.TransferRead;
                barrier.dstAccessMask = VkAccessFlags.TransferWrite;
                srcStageFlags = VkPipelineStageFlags.Transfer;
                dstStageFlags = VkPipelineStageFlags.Transfer;
            }
            else if (oldLayout == VkImageLayout.TransferDstOptimal && newLayout == VkImageLayout.TransferSrcOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.TransferWrite;
                barrier.dstAccessMask = VkAccessFlags.TransferRead;
                srcStageFlags = VkPipelineStageFlags.Transfer;
                dstStageFlags = VkPipelineStageFlags.Transfer;
            }
            else if (oldLayout == VkImageLayout.ColorAttachmentOptimal && newLayout == VkImageLayout.TransferSrcOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.ColorAttachmentWrite;
                barrier.dstAccessMask = VkAccessFlags.TransferRead;
                srcStageFlags = VkPipelineStageFlags.ColorAttachmentOutput;
                dstStageFlags = VkPipelineStageFlags.Transfer;
            }
            else if (oldLayout == VkImageLayout.ColorAttachmentOptimal && newLayout == VkImageLayout.TransferDstOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.ColorAttachmentWrite;
                barrier.dstAccessMask = VkAccessFlags.TransferWrite;
                srcStageFlags = VkPipelineStageFlags.ColorAttachmentOutput;
                dstStageFlags = VkPipelineStageFlags.Transfer;
            }
            else if (oldLayout == VkImageLayout.ColorAttachmentOptimal && newLayout == VkImageLayout.ShaderReadOnlyOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.ColorAttachmentWrite;
                barrier.dstAccessMask = VkAccessFlags.ShaderRead;
                srcStageFlags = VkPipelineStageFlags.ColorAttachmentOutput;
                dstStageFlags = VkPipelineStageFlags.FragmentShader;
            }
            else if (oldLayout == VkImageLayout.DepthStencilAttachmentOptimal && newLayout == VkImageLayout.ShaderReadOnlyOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.DepthStencilAttachmentWrite;
                barrier.dstAccessMask = VkAccessFlags.ShaderRead;
                srcStageFlags = VkPipelineStageFlags.LateFragmentTests;
                dstStageFlags = VkPipelineStageFlags.FragmentShader;
            }
            else if (oldLayout == VkImageLayout.ColorAttachmentOptimal && newLayout == VkImageLayout.PresentSrcKHR)
            {
                barrier.srcAccessMask = VkAccessFlags.ColorAttachmentWrite;
                barrier.dstAccessMask = VkAccessFlags.MemoryRead;
                srcStageFlags = VkPipelineStageFlags.ColorAttachmentOutput;
                dstStageFlags = VkPipelineStageFlags.BottomOfPipe;
            }
            else if (oldLayout == VkImageLayout.TransferDstOptimal && newLayout == VkImageLayout.PresentSrcKHR)
            {
                barrier.srcAccessMask = VkAccessFlags.TransferWrite;
                barrier.dstAccessMask = VkAccessFlags.MemoryRead;
                srcStageFlags = VkPipelineStageFlags.Transfer;
                dstStageFlags = VkPipelineStageFlags.BottomOfPipe;
            }
            else if (oldLayout == VkImageLayout.TransferDstOptimal && newLayout == VkImageLayout.ColorAttachmentOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.TransferWrite;
                barrier.dstAccessMask = VkAccessFlags.ColorAttachmentWrite;
                srcStageFlags = VkPipelineStageFlags.Transfer;
                dstStageFlags = VkPipelineStageFlags.ColorAttachmentOutput;
            }
            else if (oldLayout == VkImageLayout.TransferDstOptimal && newLayout == VkImageLayout.DepthStencilAttachmentOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.TransferWrite;
                barrier.dstAccessMask = VkAccessFlags.DepthStencilAttachmentWrite;
                srcStageFlags = VkPipelineStageFlags.Transfer;
                dstStageFlags = VkPipelineStageFlags.LateFragmentTests;
            }
            else if (oldLayout == VkImageLayout.General && newLayout == VkImageLayout.TransferSrcOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.ShaderWrite;
                barrier.dstAccessMask = VkAccessFlags.TransferRead;
                srcStageFlags = VkPipelineStageFlags.ComputeShader;
                dstStageFlags = VkPipelineStageFlags.Transfer;
            }
            else if (oldLayout == VkImageLayout.General && newLayout == VkImageLayout.TransferDstOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.ShaderWrite;
                barrier.dstAccessMask = VkAccessFlags.TransferWrite;
                srcStageFlags = VkPipelineStageFlags.ComputeShader;
                dstStageFlags = VkPipelineStageFlags.Transfer;
            }
            else if (oldLayout == VkImageLayout.PresentSrcKHR && newLayout == VkImageLayout.TransferSrcOptimal)
            {
                barrier.srcAccessMask = VkAccessFlags.MemoryRead;
                barrier.dstAccessMask = VkAccessFlags.TransferRead;
                srcStageFlags = VkPipelineStageFlags.BottomOfPipe;
                dstStageFlags = VkPipelineStageFlags.Transfer;
            }
            else
            {
                Debug.WriteLine("Invalid image layout transition.");
            }

            vkCmdPipelineBarrier(
                cb,
                srcStageFlags,
                dstStageFlags,
                VkDependencyFlags.None,
                0, null,
                0, null,
                1, &barrier);
        }
    }

    internal static class VkPhysicalDeviceMemoryPropertiesEx
    {
        public static VkMemoryType GetMemoryType(this VkPhysicalDeviceMemoryProperties memoryProperties, uint32 index)
        {
            return memoryProperties.memoryTypes[index];
        }
    }
}
