using System;
using System.Diagnostics;
using System.Text;
using Bulkan;
using Sedulous.RHI;
using Sedulous.Foundation.Mathematics;
using System.Collections;

namespace Sedulous.RHI.Vulkan;

/// <summary>
/// A set of Vulkan helpers.
/// </summary>
public static class VKHelpers
{
	/// <summary>
	/// Creates a valid API version uint.
	/// </summary>
	/// <param name="major">The major version.</param>
	/// <param name="minor">The minor version.</param>
	/// <param name="patch">The patch version.</param>
	/// <returns>Vulkan API version.</returns>
	public static uint32 Version(uint32 major, uint32 minor, uint32 patch)
	{
		return (major << 22) | (minor << 12) | patch;
	}

	/// <summary>
	/// Checks for errors.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="result">The result of the last operation.</param>
#if !DEBUG
	//[Conditional("DEBUG")]
	[SkipCall]
#endif
	public static void CheckErrors(GraphicsContext context, VkResult result)
	{
		if (result != 0)
		{
			context.ValidationLayer?.Notify("Vulkan", result.ToString(.. scope .()));
		}
	}

	/// <summary>
	/// Gets the memory type.
	/// </summary>
	/// <param name="memoryProperties">The device's memory properties.</param>
	/// <param name="index">The memory index.</param>
	/// <returns>The resulting memory type.</returns>
	public static VkMemoryType GetMemoryType(this VkPhysicalDeviceMemoryProperties memoryProperties, uint32 index)
	{
		return memoryProperties.memoryTypes[index];
	}

	/// <summary>
	/// Finds a memory type.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="typeFilter">The type filter.</param>
	/// <param name="properties">The memory properties.</param>
	/// <returns>A value greater than 0 if successful.</returns>
	public static int32 FindMemoryType(VKGraphicsContext context, uint32 typeFilter, VkMemoryPropertyFlags properties)
	{
		VkPhysicalDeviceMemoryProperties memProperties = context.VkPhysicalDeviceMemoryProperties;
		for (int i = 0; i < memProperties.memoryTypeCount; i++)
		{
			if ((typeFilter & (1 << i)) != 0L && (memProperties.GetMemoryType((uint32)i).propertyFlags & properties) == properties)
			{
				return (int32)i;
			}
		}
		context.ValidationLayer?.Notify("Vulkan", "No suitable memory type.");
		return -1;
	}

	/// <summary>
	/// Returns up to the requested number of global layer properties.
	/// </summary>
	/// <param name="instanceLayers">The string array of supported layers.</param>
	public static void EnumerateInstanceLayers(List<String> instanceLayers)
	{
		uint32 propCount = 0;
		VulkanNative.vkEnumerateInstanceLayerProperties(&propCount, null);
		if (propCount == 0)
		{
			return;
		}
		VkLayerProperties* props = scope VkLayerProperties[(int32)propCount]*;
		VulkanNative.vkEnumerateInstanceLayerProperties(&propCount, props);
		for (int i = 0; i < propCount; i++)
		{
			instanceLayers.Add(new String(&props[i].layerName));
		}
	}

	/// <summary>
	/// Returns up to the requested number of global extension properties.
	/// </summary>
	/// <param name="instanceExtensions">A string array of supported extensions.</param>
	public static void EnumerateInstanceExtensions(List<String> instanceExtensions)
	{
		uint32 propCount = 0;
		VulkanNative.vkEnumerateInstanceExtensionProperties(null, &propCount, null);
		if (propCount == 0)
		{
			return;
		}
		VkExtensionProperties* props = scope VkExtensionProperties[(int32)propCount]*;
		VulkanNative.vkEnumerateInstanceExtensionProperties(null, &propCount, props);
		for (int i = 0; i < propCount; i++)
		{
			instanceExtensions.Add(new String(&props[i].extensionName));
		}
	}

	/// <summary>
	/// Gets the bindings offset to avoid overlap.
	/// </summary>
	/// <param name="element">The layout element description.</param>
	/// <returns>The first slot available.</returns>
	public static uint32 GetBinding(LayoutElementDescription element)
	{
		switch (element.Type)
		{
		case ResourceType.ConstantBuffer:
			return element.Slot;
		case ResourceType.StructuredBufferReadWrite,
			 ResourceType.TextureReadWrite:
			return element.Slot + 20;
		case ResourceType.Sampler:
			return element.Slot + 40;
		case ResourceType.StructuredBuffer,
			 ResourceType.Texture,
			 ResourceType.AccelerationStructure:
			return element.Slot + 60;
		default:
			return 0;
		}
	}

	/// <summary>
	/// Converts a Matrix4x4 into a Vulkan transform matrix 3x4.
	/// </summary>
	/// <param name="m">The matrix to convert.</param>
	/// <returns>The Vulkan transform matrix.</returns>
	public static VkTransformMatrixKHR ToTransformMatrix(this Matrix m)
	{
		VkTransformMatrixKHR result = default(VkTransformMatrixKHR);
		result.matrix[0] = m.M11;
		result.matrix[1] = m.M12;
		result.matrix[2] = m.M13;
		result.matrix[3] = m.M14;
		result.matrix[4] = m.M21;
		result.matrix[5] = m.M22;
		result.matrix[6] = m.M23;
		result.matrix[7] = m.M24;
		result.matrix[8] = m.M31;
		result.matrix[9] = m.M32;
		result.matrix[10] = m.M33;
		result.matrix[11] = m.M34;
		return result;
	}
}
