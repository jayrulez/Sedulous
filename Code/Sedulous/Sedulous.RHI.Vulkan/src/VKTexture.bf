using System;
using Bulkan;
using Sedulous.RHI;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;
namespace Sedulous.RHI.Vulkan;

/// <summary>
/// This class represents a native texture object on Metal.
/// </summary>
public class VKTexture : Texture
{
	/// <summary>
	/// The native Vulkan image object.
	/// </summary>
	public VkImage NativeImage;

	/// <summary>
	/// The native vulkan memory linked with native image.
	/// </summary>
	public VkDeviceMemory ImageMemory;

	/// <summary>
	/// The native Vulkan buffer object used for staging textures.
	/// </summary>
	public VkBuffer NativeBuffer;

	/// <summary>
	/// The native buffer memory linked with native buffer.
	/// </summary>
	public VkDeviceMemory BufferMemory;

	/// <summary>
	/// The memory requirements for this texture.
	/// </summary>
	public VkMemoryRequirements MemoryRequirements;

	/// <summary>
	/// The native Image layouts for this texture.
	/// </summary>
	public VkImageLayout[] ImageLayouts;

	/// <summary>
	/// The native pixel format for this texture.
	/// </summary>
	public VkFormat Format;

	private VKGraphicsContext vkContext;

	private VkImageView imageView;

	private String name = new .() ~ delete _;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			if (!String.IsNullOrEmpty(value))
			{
				name.Set(value);
				vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_IMAGE, NativeImage.Handle, name);
			}
		}
	}

	/// <inheritdoc />
	public override void* NativePointer
	{
		get
		{
			if (Description.Usage == ResourceUsage.Staging)
			{
				return (void*)(int)NativeBuffer.Handle;
			}
			return (void*)(int)NativeImage.Handle;
		}
	}

	/// <summary>
	/// Gets the vulkan image view.
	/// </summary>
	public VkImageView ImageView
	{
		get
		{
			if (imageView.Handle == 0L)
			{
				imageView = GetImageView();
			}
			return imageView;
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKTexture" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="data">The data pointer.</param>
	/// <param name="description">The texture description.</param>
	/// <param name="samplerState">the sampler state description for this texture.</param>
	public this(VKGraphicsContext context, DataBox[] data, ref TextureDescription description, ref SamplerStateDescription samplerState)
		: base(context, ref description)
	{
		vkContext = context;
		bool isStaging = description.Usage == ResourceUsage.Staging;
		VkMemoryRequirements memoryRequirements = default(VkMemoryRequirements);
		VkMemoryAllocateInfo allocInfo;
		int32 memoryType;
		VkDeviceMemory deviceMemory = default(VkDeviceMemory);
		uint32 subResourceCount;
		uint32 totalSize;
		if (isStaging)
		{
			totalSize = Helpers.ComputeTextureSize(description);
			VkBufferCreateInfo bufferInfo = VkBufferCreateInfo()
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
				usage = (VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_DST_BIT),
				size = totalSize,
				sharingMode = (context.CopyQueueSupported ? VkSharingMode.VK_SHARING_MODE_CONCURRENT : VkSharingMode.VK_SHARING_MODE_EXCLUSIVE)
			};
			int32 queueFamilies = ((!context.CopyQueueSupported) ? 1 : 2);
			uint32* queueFamilyIndices = scope uint32[queueFamilies]*;
			*queueFamilyIndices = (uint32)context.QueueIndices.GraphicsFamily;
			if (context.CopyQueueSupported)
			{
				queueFamilyIndices[1] = (uint32)context.QueueIndices.CopyFamily;
			}
			bufferInfo.pQueueFamilyIndices = queueFamilyIndices;
			bufferInfo.queueFamilyIndexCount = (uint32)queueFamilies;
			VkBuffer newBuffer = default(VkBuffer);
			VulkanNative.vkCreateBuffer(context.VkDevice, &bufferInfo, null, &newBuffer);
			NativeBuffer = newBuffer;
			VulkanNative.vkGetBufferMemoryRequirements(context.VkDevice, NativeBuffer, &memoryRequirements);
			MemoryRequirements = memoryRequirements;
			allocInfo = VkMemoryAllocateInfo()
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
				allocationSize = MemoryRequirements.size
			};
			memoryType = VKHelpers.FindMemoryType(context, MemoryRequirements.memoryTypeBits, VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
			if (memoryType == -1)
			{
				vkContext.ValidationLayer?.Notify("Vulkan", "No suitable memory type.");
			}
			allocInfo.memoryTypeIndex = (uint32)memoryType;
			VulkanNative.vkAllocateMemory(context.VkDevice, &allocInfo, null, &deviceMemory);
			BufferMemory = deviceMemory;
			VulkanNative.vkBindBufferMemory(context.VkDevice, NativeBuffer, BufferMemory, 0UL);
			subResourceCount = description.MipLevels * description.ArraySize * description.Faces * description.Depth;
			ImageLayouts = new VkImageLayout[subResourceCount];
			for (int i = 0; i < (int32)subResourceCount; i++)
			{
				ImageLayouts[i] = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
			}
			return;
		}
		bool isDepthFormat = (description.Flags & TextureFlags.DepthStencil) != 0;
		VkImageUsageFlags vkUsage = VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_SRC_BIT | VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_DST_BIT;
		if (isDepthFormat)
		{
			vkUsage |= VkImageUsageFlags.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT;
		}
		if ((description.Flags & TextureFlags.RenderTarget) != 0)
		{
			vkUsage |= VkImageUsageFlags.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
		}
		if ((description.Flags & TextureFlags.UnorderedAccess) != 0)
		{
			vkUsage |= VkImageUsageFlags.VK_IMAGE_USAGE_STORAGE_BIT;
		}
		if ((description.Flags & TextureFlags.ShaderResource) != 0)
		{
			vkUsage |= VkImageUsageFlags.VK_IMAGE_USAGE_SAMPLED_BIT;
		}
		Format = description.Format.ToVulkan(isDepthFormat);
		VkImageCreateInfo imageInfo = VkImageCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
			mipLevels = description.MipLevels,
			arrayLayers = description.ArraySize * description.Faces,
			extent = .()
			{
				width = description.Width,
				height = description.Height,
				depth = description.Depth
			},
			initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED,
			usage = vkUsage,
			tiling = (isStaging ? VkImageTiling.VK_IMAGE_TILING_LINEAR : VkImageTiling.VK_IMAGE_TILING_OPTIMAL),
			samples = description.SampleCount.ToVulkan(),
			format = Format
		};
		switch (description.Type)
		{
		case TextureType.Texture1D,
			 TextureType.Texture1DArray:
			imageInfo.imageType = VkImageType.VK_IMAGE_TYPE_1D;
			break;
		case TextureType.Texture2D,
			 TextureType.Texture2DArray:
			imageInfo.imageType = VkImageType.VK_IMAGE_TYPE_2D;
			break;
		case TextureType.TextureCube,
			 TextureType.TextureCubeArray:
			imageInfo.imageType = VkImageType.VK_IMAGE_TYPE_2D;
			imageInfo.flags |= VkImageCreateFlags.VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT;
			break;
		case TextureType.Texture3D:
			imageInfo.imageType = VkImageType.VK_IMAGE_TYPE_3D;
			break;
		default:
			Context.ValidationLayer?.Notify("Vulkan", "Invalid textureType.");
			break;
		}
		VkImage newImage = default(VkImage);
		VulkanNative.vkCreateImage(context.VkDevice, &imageInfo, null, &newImage);
		NativeImage = newImage;
		VulkanNative.vkGetImageMemoryRequirements(context.VkDevice, NativeImage, &memoryRequirements);
		MemoryRequirements = memoryRequirements;
		allocInfo = VkMemoryAllocateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
			allocationSize = MemoryRequirements.size
		};
		memoryType = VKHelpers.FindMemoryType(context, MemoryRequirements.memoryTypeBits, VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
		if (memoryType == -1)
		{
			vkContext.ValidationLayer?.Notify("Vulkan", "No suitable memory type.");
		}
		allocInfo.memoryTypeIndex = (uint32)memoryType;
		VulkanNative.vkAllocateMemory(context.VkDevice, &allocInfo, null, &deviceMemory);
		ImageMemory = deviceMemory;
		VulkanNative.vkBindImageMemory(context.VkDevice, NativeImage, ImageMemory, 0UL);
		subResourceCount = description.MipLevels * description.ArraySize * description.Faces * description.Depth;
		ImageLayouts = new VkImageLayout[subResourceCount];
		for (int i = 0; i < (int32)subResourceCount; i++)
		{
			ImageLayouts[i] = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
		}
		if (data == null)
		{
			return;
		}
		totalSize = Helpers.ComputeTextureSize(description);
		uint64 bufferPointer = context.TextureUploader.Allocate(totalSize);
		uint32 regionCount = description.ArraySize * description.Faces * description.MipLevels;
		VkBufferImageCopy* copyRegions = scope VkBufferImageCopy[(int32)regionCount]*;
		uint32 copyOffset = 0;
		for (uint32 a = 0; a < description.ArraySize; a++)
		{
			for (uint32 f = 0; f < description.Faces; f++)
			{
				uint32 levelWidth = description.Width;
				uint32 levelHeight = description.Height;
				uint32 levelDepth = description.Depth;
				for (uint32 m = 0; m < description.MipLevels; m++)
				{
					uint32 index = a * description.Faces * description.MipLevels + f * description.MipLevels + m;
					uint64 copyPointer = bufferPointer + copyOffset;
					DataBox dataBox = data[index];
					Internal.MemCpy((void*)(int)copyPointer, (void*)dataBox.DataPointer, dataBox.SlicePitch * description.Depth);
					copyOffset += dataBox.SlicePitch;
					copyRegions[index] = VkBufferImageCopy()
					{
						bufferOffset = context.TextureUploader.CalculateOffset(copyPointer),
						bufferRowLength = 0,
						bufferImageHeight = 0,
						imageSubresource = .()
						{
							aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
							mipLevel = m,
							baseArrayLayer = a * description.Faces + f,
							layerCount = 1
						},
						imageOffset = default(VkOffset3D),
						imageExtent = VkExtent3D()
						{
							width = levelWidth,
							height = levelHeight,
							depth = levelDepth
						}
					};
					levelWidth = Math.Max(1, levelWidth / 2);
					levelHeight = Math.Max(1, levelHeight / 2);
					levelDepth = Math.Max(1, levelDepth / 2);
				}
			}
		}
		VkImageMemoryBarrier barrier = VkImageMemoryBarrier()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
			image = NativeImage,
			oldLayout = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED,
			newLayout = VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
			srcAccessMask = VkAccessFlags.VK_ACCESS_NONE,
			dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT,
			subresourceRange = .()
			{
				aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
				baseArrayLayer = 0,
				layerCount = description.ArraySize * description.Faces,
				baseMipLevel = 0,
				levelCount = description.MipLevels
			},
			srcQueueFamilyIndex = uint32.MaxValue,
			dstQueueFamilyIndex = uint32.MaxValue
		};
		VulkanNative.vkCmdPipelineBarrier(context.CopyCommandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, VkDependencyFlags.None, 0, null, 0, null, 1, &barrier);
		VulkanNative.vkCmdCopyBufferToImage(context.CopyCommandBuffer, context.TextureUploader.NativeBuffer, NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, regionCount, copyRegions);
		if ((Description.Flags & TextureFlags.ShaderResource) != 0)
		{
			barrier.oldLayout = VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
			barrier.newLayout = VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
			barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
			barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT | VkAccessFlags.VK_ACCESS_SHADER_WRITE_BIT;
			VulkanNative.vkCmdPipelineBarrier(context.CopyCommandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkDependencyFlags.None, 0, null, 0, null, 1, &barrier);

			for (int i = 0; i < (int32)subResourceCount; i++)
			{
				ImageLayouts[i] = VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
			}
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKTexture" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="data">The data pointer.</param>
	/// <param name="description">The texture description.</param>
	public this(VKGraphicsContext context, DataBox[] data, ref TextureDescription description)
		: base(context, ref description)
	{
	}

	/// <summary>
	/// Create a new texture from a VKImage.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The texture description.</param>
	/// <param name="image">The vulkan image already created.</param>
	/// <returns>A new VKTexture.</returns>
	public static VKTexture FromVulkanImage(VKGraphicsContext context, ref TextureDescription description, VkImage image)
	{
		VKTexture texture = new VKTexture(context, null, ref description);
		texture.vkContext = context;
		texture.NativeImage = image;
		//texture.ImageLayouts = Enumerable.Repeat(VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED, (int32)description.ArraySize).ToArray();
		texture.ImageLayouts = new .[(int32)description.ArraySize]
			..SetAll(VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED);
		if (description.Usage != ResourceUsage.Staging)
		{
			bool isDepthFormat = (description.Flags & TextureFlags.DepthStencil) != 0;
			texture.Format = description.Format.ToVulkan(isDepthFormat);
		}
		return texture;
	}

	/// <summary>
	/// Transition the images linked with this texture to a VKImageLayout state.
	/// </summary>
	/// <param name="command">The command buffer to execute.</param>
	/// <param name="newLayout">The new state layout.</param>
	/// <param name="baseMiplevel">The start mip level.</param>
	/// <param name="levelCount">The number of mip levels.</param>
	/// <param name="baseArrayLayer">The start array layer.</param>
	/// <param name="layerCount">The number of array layers.</param>
	public void TransitionImageLayout(VkCommandBuffer command, VkImageLayout newLayout, uint32 baseMiplevel, uint32 levelCount, uint32 baseArrayLayer, uint32 layerCount)
	{
		uint32 subResource = Helpers.CalculateSubResource(Description, baseMiplevel, baseArrayLayer);
		VkImageLayout oldLayout = ImageLayouts[subResource];
		if (oldLayout == newLayout)
		{
			return;
		}
		VkImageAspectFlags aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
		if ((Description.Flags & TextureFlags.DepthStencil) != 0)
		{
			aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT;
			if (Helpers.IsStencilFormat(Description.Format))
			{
				aspectMask |= VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT;
			}
		}
		VkImageMemoryBarrier imageBarrier = default(VkImageMemoryBarrier);
		imageBarrier.sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
		imageBarrier.oldLayout = oldLayout;
		imageBarrier.newLayout = newLayout;
		imageBarrier.srcQueueFamilyIndex = uint32.MaxValue;
		imageBarrier.dstQueueFamilyIndex = uint32.MaxValue;
		imageBarrier.image = NativeImage;
		imageBarrier.subresourceRange.aspectMask = aspectMask;
		imageBarrier.subresourceRange.baseMipLevel = baseMiplevel;
		imageBarrier.subresourceRange.levelCount = levelCount;
		imageBarrier.subresourceRange.baseArrayLayer = baseArrayLayer;
		imageBarrier.subresourceRange.layerCount = layerCount;
		VkPipelineStageFlags srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_NONE;
		VkPipelineStageFlags dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_NONE;
		switch (oldLayout)
		{
		case VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED,
			 VkImageLayout.VK_IMAGE_LAYOUT_PREINITIALIZED:
			imageBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
			srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:
			imageBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
			srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:
			imageBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
			srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:
			imageBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
			srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_GENERAL,
			 VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:
			imageBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
			srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:
			imageBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
			srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR:
			imageBarrier.srcAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT;
			srcStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL:
			break;
		default:
			Runtime.InvalidOperationError("Source Image layout not supported.");
		}
		switch (newLayout)
		{
		case VkImageLayout.VK_IMAGE_LAYOUT_GENERAL:
			imageBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
			dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:
			imageBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
			dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:
			imageBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
			dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:
			imageBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
			dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:
			imageBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_READ_BIT;
			dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:
			imageBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
			dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR:
			imageBarrier.dstAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT;
			dstStageFlags = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
			break;
		case VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL:
			break;
		default:
			Runtime.InvalidOperationError("Destination Image layout not supported.");
		}
		VulkanNative.vkCmdPipelineBarrier(command, srcStageFlags, dstStageFlags, VkDependencyFlags.None, 0, null, 0, null, 1, &imageBarrier);
		uint32 numLayers = baseArrayLayer + layerCount;
		uint32 numLevels = baseMiplevel + levelCount;
		for (uint32 layer = baseArrayLayer; layer < numLayers; layer++)
		{
			for (uint32 level = baseMiplevel; level < numLevels; level++)
			{
				ImageLayouts[Helpers.CalculateSubResource(Description, level, layer)] = newLayout;
			}
		}
	}

	/// <summary>
	/// Copy a pixel region from source to destination texture.
	/// </summary>
	/// <param name="commandBuffer">The commandbuffer where execute.</param>
	/// <param name="sourceX">U coord source texture.</param>
	/// <param name="sourceY">V coord source texture.</param>
	/// <param name="sourceZ">W coord source texture.</param>
	/// <param name="sourceMipLevel">Source mip level.</param>
	/// <param name="sourceBaseArray">Source array index.</param>
	/// <param name="destination">Destination texture.</param>
	/// <param name="destinationX">U coord destination texture.</param>
	/// <param name="destinationY">V coord destination texture.</param>
	/// <param name="destinationZ">W coord destination texture.</param>
	/// <param name="destinationMipLevel">Destination mip level.</param>
	/// <param name="destinationBasedArray">Destination array index.</param>
	/// <param name="width">Destination width.</param>
	/// <param name="height">Destination heigh.</param>
	/// <param name="depth">Destination depth.</param>
	/// <param name="layerCount">Destination layer count.</param>
	public void CopyTo(VkCommandBuffer commandBuffer, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBaseArray, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArray, uint32 width, uint32 height, uint32 depth, uint32 layerCount)
	{
		bool sourceStaging = Description.Usage == ResourceUsage.Staging;
		bool destinationStaging = destination.Description.Usage == ResourceUsage.Staging;
		VKTexture vkDestination = destination as VKTexture;
		if (!sourceStaging && !destinationStaging)
		{
			TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, sourceMipLevel, 1, sourceBaseArray, layerCount);
			VkImageSubresourceLayers vkImageSubresourceLayers = default(VkImageSubresourceLayers);
			vkImageSubresourceLayers.aspectMask = (((Description.Flags & TextureFlags.DepthStencil) == 0) ? VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
			vkImageSubresourceLayers.layerCount = layerCount;
			vkImageSubresourceLayers.mipLevel = sourceMipLevel;
			vkImageSubresourceLayers.baseArrayLayer = sourceBaseArray;
			VkImageSubresourceLayers sourceSubresource = vkImageSubresourceLayers;
			vkDestination.TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, destinationMipLevel, 1, destinationBasedArray, layerCount);
			vkImageSubresourceLayers = default(VkImageSubresourceLayers);
			vkImageSubresourceLayers.aspectMask = (((destination.Description.Flags & TextureFlags.DepthStencil) == 0) ? VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
			vkImageSubresourceLayers.layerCount = layerCount;
			vkImageSubresourceLayers.mipLevel = destinationMipLevel;
			vkImageSubresourceLayers.baseArrayLayer = destinationBasedArray;
			VkImageSubresourceLayers destinationSubresource = vkImageSubresourceLayers;
			VkImageCopy vkImageCopy = default(VkImageCopy);
			vkImageCopy.srcOffset = VkOffset3D()
			{
				x = (int32)sourceX,
				y = (int32)sourceY,
				z = (int32)sourceZ
			};
			vkImageCopy.dstOffset = VkOffset3D()
			{
				x = (int32)destinationX,
				y = (int32)destinationY,
				z = (int32)destinationZ
			};
			vkImageCopy.srcSubresource = sourceSubresource;
			vkImageCopy.dstSubresource = destinationSubresource;
			vkImageCopy.extent = VkExtent3D()
			{
				width = Description.Width,
				height = Description.Height,
				depth = Description.Depth
			};
			VkImageCopy region = vkImageCopy;
			VulkanNative.vkCmdCopyImage(commandBuffer, NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, vkDestination.NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &region);
			return;
		}
		uint32 blockSizeInBytes;
		if (sourceStaging && !destinationStaging)
		{
			vkDestination.TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, destinationMipLevel, 1, destinationBasedArray, layerCount);
			VkImageSubresourceLayers vkImageSubresourceLayers = default(VkImageSubresourceLayers);
			vkImageSubresourceLayers.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
			vkImageSubresourceLayers.layerCount = layerCount;
			vkImageSubresourceLayers.mipLevel = destinationMipLevel;
			vkImageSubresourceLayers.baseArrayLayer = destinationBasedArray;
			VkImageSubresourceLayers destinationSubresource = vkImageSubresourceLayers;
			uint32 subResource = Helpers.CalculateSubResource(Description, sourceMipLevel, sourceBaseArray);
			Helpers.GetMipDimensions(Description, sourceMipLevel, var mipWidth, var mipHeight, var mipDepth);
			uint32 blockSize = ((!Helpers.IsCompressedFormat(Description.Format)) ? 1 : 4);
			uint32 bufferRowLength = Math.Max(mipWidth, blockSize);
			uint32 bufferImageHeight = Math.Max(mipHeight, blockSize);
			uint32 compressedX = sourceX / blockSize;
			uint32 compressedY = sourceY / blockSize;
			blockSizeInBytes = ((blockSize == 1) ? Helpers.GetSizeInBytes(Description.Format) : Helpers.GetBlockSizeInBytes(Description.Format));
			uint32 rowPitch = Helpers.GetRowPitch(bufferRowLength, Description.Format);
			uint32 slicePitch = Helpers.GetSlicePitch(rowPitch, bufferImageHeight, Description.Format);
			uint64 offset = Helpers.ComputeSubResourceOffset(vkDestination.Description, subResource) + sourceZ * slicePitch + compressedY * rowPitch + compressedX * blockSizeInBytes;
			VkBufferImageCopy vkBufferImageCopy = default(VkBufferImageCopy);
			vkBufferImageCopy.imageSubresource = destinationSubresource;
			vkBufferImageCopy.imageExtent = VkExtent3D()
			{
				width = width,
				height = height,
				depth = depth
			};
			vkBufferImageCopy.imageOffset = VkOffset3D()
			{
				x = (int32)destinationX,
				y = (int32)destinationY,
				z = (int32)destinationZ
			};
			vkBufferImageCopy.bufferRowLength = bufferRowLength;
			vkBufferImageCopy.bufferImageHeight = bufferImageHeight;
			vkBufferImageCopy.bufferOffset = offset;
			VkBufferImageCopy region = vkBufferImageCopy;
			VulkanNative.vkCmdCopyBufferToImage(commandBuffer, NativeBuffer, vkDestination.NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &region);
			return;
		}
		if (!sourceStaging && destinationStaging)
		{
			TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, sourceMipLevel, 1, sourceBaseArray, layerCount);
			VkImageSubresourceLayers vkImageSubresourceLayers = default(VkImageSubresourceLayers);
			vkImageSubresourceLayers.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
			vkImageSubresourceLayers.layerCount = layerCount;
			vkImageSubresourceLayers.mipLevel = sourceMipLevel;
			vkImageSubresourceLayers.baseArrayLayer = sourceBaseArray;
			VkImageSubresourceLayers sourceSubresource = vkImageSubresourceLayers;
			uint32 subResource = Helpers.CalculateSubResource(vkDestination.Description, destinationMipLevel, destinationBasedArray);
			Helpers.GetMipDimensions(vkDestination.Description, destinationMipLevel, var mipWidth, var mipHeight, var mipDepth);
			uint32 blockSize = ((!Helpers.IsCompressedFormat(vkDestination.Description.Format)) ? 1 : 4);
			uint32 bufferRowLength = Math.Max(mipWidth, blockSize);
			uint32 bufferImageHeight = Math.Max(mipHeight, blockSize);
			uint32 compressedX = sourceX / blockSize;
			uint32 compressedY = sourceY / blockSize;
			blockSizeInBytes = ((blockSize == 1) ? Helpers.GetSizeInBytes(vkDestination.Description.Format) : Helpers.GetBlockSizeInBytes(vkDestination.Description.Format));
			uint32 rowPitch = Helpers.GetRowPitch(bufferRowLength, vkDestination.Description.Format);
			uint32 slicePitch = Helpers.GetSlicePitch(rowPitch, bufferImageHeight, vkDestination.Description.Format);
			uint64 offset = Helpers.ComputeSubResourceOffset(vkDestination.Description, subResource) + sourceZ * slicePitch + compressedY * rowPitch + compressedX * blockSizeInBytes;
			VkBufferImageCopy vkBufferImageCopy = default(VkBufferImageCopy);
			vkBufferImageCopy.imageSubresource = sourceSubresource;
			vkBufferImageCopy.imageExtent = VkExtent3D()
			{
				width = width,
				height = height,
				depth = depth
			};
			vkBufferImageCopy.imageOffset = VkOffset3D()
			{
				x = (int32)sourceX,
				y = (int32)sourceY,
				z = (int32)sourceZ
			};
			vkBufferImageCopy.bufferRowLength = bufferRowLength;
			vkBufferImageCopy.bufferImageHeight = bufferImageHeight;
			vkBufferImageCopy.bufferOffset = offset;
			VkBufferImageCopy region = vkBufferImageCopy;
			VulkanNative.vkCmdCopyImageToBuffer(commandBuffer, NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, vkDestination.NativeBuffer, 1, &region);
			return;
		}
		uint32 srcSubresource = Helpers.CalculateSubResource(Description, sourceMipLevel, sourceBaseArray);
		SubResourceInfo srcSubresourceInfo = Helpers.GetSubResourceInfo(Description, srcSubresource);
		uint32 dstSubresource = Helpers.CalculateSubResource(destination.Description, destinationMipLevel, destinationBasedArray);
		SubResourceInfo dstSubresourceInfo = Helpers.GetSubResourceInfo(destination.Description, dstSubresource);
		uint32 zLimit = Math.Max(depth, layerCount);
		if (!Helpers.IsCompressedFormat(Description.Format))
		{
			uint32 pixelSize = Helpers.GetSizeInBytes(Description.Format);
			for (uint32 zz = 0; zz < zLimit; zz++)
			{
				for (uint32 yy = 0; yy < height; yy++)
				{
					VkBufferCopy vkBufferCopy = default(VkBufferCopy);
					vkBufferCopy.srcOffset = srcSubresourceInfo.Offset + srcSubresourceInfo.SlicePitch * (zz + sourceZ) + srcSubresourceInfo.RowPitch * (yy + sourceY) + pixelSize * sourceX;
					vkBufferCopy.dstOffset = dstSubresourceInfo.Offset + dstSubresourceInfo.SlicePitch * (zz + destinationX) + dstSubresourceInfo.RowPitch * (yy + destinationY) + pixelSize * destinationZ;
					vkBufferCopy.size = width * pixelSize;
					VkBufferCopy region = vkBufferCopy;
					VulkanNative.vkCmdCopyBuffer(commandBuffer, NativeBuffer, vkDestination.NativeBuffer, 1, &region);
				}
			}
			return;
		}
		uint32 denseRowSize = Helpers.GetRowPitch(width, Description.Format);
		uint32 numRows = Helpers.GetNumRows(height, Description.Format);
		uint32 compressedSrcX = sourceX / 4;
		uint32 compressedSrcY = sourceY / 4;
		uint32 compressedDstX = destinationX / 4;
		uint32 compressedDstY = destinationY / 4;
		blockSizeInBytes = Helpers.GetBlockSizeInBytes(Description.Format);
		for (uint32 zz = 0; zz < zLimit; zz++)
		{
			for (uint32 row = 0; row < numRows; row++)
			{
				VkBufferCopy vkBufferCopy = default(VkBufferCopy);
				vkBufferCopy.srcOffset = srcSubresourceInfo.Offset + srcSubresourceInfo.SlicePitch * (zz + sourceZ) + srcSubresourceInfo.RowPitch * (row + compressedSrcY) + blockSizeInBytes * compressedSrcX;
				vkBufferCopy.dstOffset = dstSubresourceInfo.Offset + dstSubresourceInfo.SlicePitch * (zz + destinationZ) + dstSubresourceInfo.RowPitch * (row + compressedDstY) + blockSizeInBytes * compressedDstX;
				vkBufferCopy.size = denseRowSize;
				VkBufferCopy region = vkBufferCopy;
				VulkanNative.vkCmdCopyBuffer(commandBuffer, NativeBuffer, vkDestination.NativeBuffer, 1, &region);
			}
		}
	}

	/// <summary>
	/// Copy a pixel region from source to destination texture with format conversion and preparing to present in swapchain.
	/// </summary>
	/// <param name="commandBuffer">The commandbuffer where execute.</param>
	/// <param name="sourceX">U coord source texture.</param>
	/// <param name="sourceY">V coord source texture.</param>
	/// <param name="sourceZ">W coord source texture.</param>
	/// <param name="sourceMipLevel">Source mip level.</param>
	/// <param name="sourceBaseArray">Source array index.</param>
	/// <param name="destination">Destination texture.</param>
	/// <param name="destinationX">U coord destination texture.</param>
	/// <param name="destinationY">V coord destination texture.</param>
	/// <param name="destinationZ">W coord destination texture.</param>
	/// <param name="destinationMipLevel">Destination mip level.</param>
	/// <param name="destinationBasedArray">Destination array index.</param>
	/// <param name="layerCount">Destination layer count.</param>
	public void Blit(VkCommandBuffer commandBuffer, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBaseArray, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArray, uint32 layerCount)
	{
		VKTexture vkDestination = destination as VKTexture;
		TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, sourceMipLevel, 1, sourceBaseArray, layerCount);
		VkImageSubresourceLayers vkImageSubresourceLayers = default(VkImageSubresourceLayers);
		vkImageSubresourceLayers.aspectMask = (((Description.Flags & TextureFlags.DepthStencil) == 0) ? VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
		vkImageSubresourceLayers.layerCount = layerCount;
		vkImageSubresourceLayers.mipLevel = sourceMipLevel;
		vkImageSubresourceLayers.baseArrayLayer = sourceBaseArray;
		VkImageSubresourceLayers sourceSubresource = vkImageSubresourceLayers;
		vkDestination.TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, destinationMipLevel, 1, destinationBasedArray, layerCount);
		vkImageSubresourceLayers = default(VkImageSubresourceLayers);
		vkImageSubresourceLayers.aspectMask = (((destination.Description.Flags & TextureFlags.DepthStencil) == 0) ? VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
		vkImageSubresourceLayers.layerCount = layerCount;
		vkImageSubresourceLayers.mipLevel = destinationMipLevel;
		vkImageSubresourceLayers.baseArrayLayer = destinationBasedArray;
		VkImageSubresourceLayers destinationSubresource = vkImageSubresourceLayers;
		VkImageBlit vkImageBlit = default(VkImageBlit);
		vkImageBlit.srcOffsets[0] = VkOffset3D()
		{
			x = (int32)sourceX,
			y = (int32)sourceY,
			z = (int32)sourceZ
		};
		vkImageBlit.srcOffsets[1] = VkOffset3D()
		{
			x = (int32)Description.Width,
			y = (int32)Description.Height,
			z = (int32)Description.Depth
		};
		vkImageBlit.dstOffsets[0] = VkOffset3D()
		{
			x = (int32)destinationX,
			y = (int32)destinationY,
			z = (int32)destinationZ
		};
		vkImageBlit.dstOffsets[1] = VkOffset3D()
		{
			x = (int32)Description.Width,
			y = (int32)Description.Height,
			z = (int32)Description.Depth
		};
		vkImageBlit.srcSubresource = sourceSubresource;
		vkImageBlit.dstSubresource = destinationSubresource;
		VkImageBlit region = vkImageBlit;
		VulkanNative.vkCmdBlitImage(commandBuffer, NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, vkDestination.NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &region, VkFilter.VK_FILTER_LINEAR);
		vkDestination.TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR, destinationMipLevel, 1, destinationBasedArray, layerCount);
	}

	/// <summary>
	/// The a new image layout.
	/// </summary>
	/// <param name="mipLevel">The mipLevel of this texture.</param>
	/// <param name="arrayLevel">The arraylelvel of this texture.</param>
	/// <param name="layout">The new layout to set.</param>
	public void SetImageLayout(uint32 mipLevel, uint32 arrayLevel, VkImageLayout layout)
	{
		uint32 subResource = Helpers.CalculateSubResource(Description, mipLevel, arrayLevel);
		ImageLayouts[subResource] = layout;
	}

	/// <summary>
	/// The a new image layout based on subResource.
	/// </summary>
	/// <param name="subResource">The subResource index.</param>
	/// <param name="layout">The new layout state.</param>
	public void SetImageLayout(uint32 subResource, VkImageLayout layout)
	{
		ImageLayouts[subResource] = layout;
	}

	/// <summary>
	/// Fill the buffer from a pointer.
	/// </summary>
	/// <param name="commandBuffer">The commandbuffer.</param>
	/// <param name="source">The data pointer.</param>
	/// <param name="sourceSizeInBytes">The size in bytes.</param>
	/// <param name="subResource">The subresource index.</param>
	public void SetData(VkCommandBuffer commandBuffer, void* source, uint32 sourceSizeInBytes, uint32 subResource = 0)
	{
		VKGraphicsContext vkContext = Context as VKGraphicsContext;
		bool num = Description.Usage == ResourceUsage.Staging;
		SubResourceInfo subResourceInfo = Helpers.GetSubResourceInfo(Description, subResource);
		if (sourceSizeInBytes > subResourceInfo.SizeInBytes)
		{
			Context.ValidationLayer?.Notify("Vulkan", scope $"The sourceSizeInBytes: {sourceSizeInBytes} is bigger than the subResource size: {subResourceInfo.SizeInBytes}");
		}
		if (num)
		{
			void* dataPointer = default(void*);
			VulkanNative.vkMapMemory(vkContext.VkDevice, BufferMemory, subResourceInfo.Offset, subResourceInfo.SizeInBytes, VkMemoryMapFlags.None, &dataPointer);
			Internal.MemCpy(dataPointer, (void*)source, sourceSizeInBytes);
			VulkanNative.vkUnmapMemory(vkContext.VkDevice, BufferMemory);
			return;
		}
		uint64 bufferPointer = vkContext.TextureUploader.Allocate(sourceSizeInBytes);
		uint32 regionCount = 1;
		VkBufferImageCopy* copyRegions = scope VkBufferImageCopy[(int32)regionCount]*;
		Internal.MemCpy((void*)(int)bufferPointer, (void*)source, sourceSizeInBytes);
		VkBufferImageCopy region = default(VkBufferImageCopy);
		region.bufferOffset = vkContext.TextureUploader.CalculateOffset(bufferPointer);
		region.bufferRowLength = 0;
		region.bufferImageHeight = 0;
		region.imageSubresource.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
		region.imageSubresource.mipLevel = subResourceInfo.MipLevel;
		region.imageSubresource.baseArrayLayer = subResourceInfo.ArrayLayer;
		region.imageSubresource.layerCount = 1;
		region.imageOffset = default(VkOffset3D);
		region.imageExtent = VkExtent3D()
		{
			width = subResourceInfo.MipWidth,
			height = subResourceInfo.MipHeight,
			depth = subResourceInfo.MipDepth
		};
		*copyRegions = region;
		TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, subResourceInfo.MipLevel, 1, subResourceInfo.ArrayLayer, Description.ArraySize * Description.Faces);
		VulkanNative.vkCmdCopyBufferToImage(vkContext.CopyCommandBuffer, vkContext.TextureUploader.NativeBuffer, NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, regionCount, copyRegions);
		if ((Description.Flags & TextureFlags.ShaderResource) != 0)
		{
			TransitionImageLayout(commandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, subResourceInfo.MipLevel, 1, subResourceInfo.ArrayLayer, Description.ArraySize * Description.Faces);
		}
	}

	/// <summary>
	/// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
	/// </summary>
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	private VkImageView GetImageView()
	{
		VkImageViewCreateInfo imageViewInfo = default(VkImageViewCreateInfo);
		imageViewInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
		imageViewInfo.image = NativeImage;
		imageViewInfo.format = Format;
		VkImageAspectFlags aspectFlags = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
		if ((Description.Flags & TextureFlags.DepthStencil) != 0)
		{
			aspectFlags = VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT;
		}
		imageViewInfo.subresourceRange = VkImageSubresourceRange()
		{
			aspectMask = aspectFlags,
			baseMipLevel = 0,
			levelCount = Description.MipLevels,
			baseArrayLayer = 0,
			layerCount = Description.ArraySize * Description.Faces
		};
		switch (Description.Type)
		{
		case TextureType.Texture1D:
			imageViewInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_1D;
			break;
		case TextureType.Texture1DArray:
			imageViewInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_1D_ARRAY;
			break;
		case TextureType.Texture2D:
			imageViewInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D;
			break;
		case TextureType.Texture2DArray:
			imageViewInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D_ARRAY;
			break;
		case TextureType.TextureCube:
			imageViewInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_CUBE;
			break;
		case TextureType.TextureCubeArray:
			imageViewInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_CUBE_ARRAY;
			break;
		case TextureType.Texture3D:
			imageViewInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_3D;
			break;
		}
		VkImageView imageView = default(VkImageView);
		VulkanNative.vkCreateImageView((Context as VKGraphicsContext).VkDevice, &imageViewInfo, null, &imageView);
		return imageView;
	}

	private void Dispose(bool disposing)
	{
		//base.Dispose();
		if (disposed)
		{
			return;
		}
		if (disposing)
		{
			if (Description.Usage == ResourceUsage.Staging)
			{
				VulkanNative.vkDestroyBuffer(vkContext.VkDevice, NativeBuffer, null);
				VulkanNative.vkFreeMemory(vkContext.VkDevice, BufferMemory, null);
			}
			else
			{
				VulkanNative.vkDestroyImage(vkContext.VkDevice, NativeImage, null);
				VulkanNative.vkFreeMemory(vkContext.VkDevice, ImageMemory, null);
			}
		}
		disposed = true;
	}
}
