using Bulkan;
using System.Collections;
using System;
namespace Sedulous.RAL.VK;

static
{
	public static VkAccelerationStructureTypeKHR Convert(AccelerationStructureType type)
	{
		switch (type) {
		case AccelerationStructureType.kTopLevel:
			return VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR;
		case AccelerationStructureType.kBottomLevel:
			return VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR;
		}
		//Runtime.Assert(false);
		//return default;
	}
}

class VKDevice : Device
{
	private VKAdapter m_adapter;
	private VkPhysicalDevice m_physical_device;
	private VkDevice m_device;
	private struct QueueInfo
	{
		public uint32 queue_family_index;
		public uint32 queue_count;
	}
	private Dictionary<CommandListType, QueueInfo> m_queues_info = new .() ~ delete _;
	private Dictionary<CommandListType, VkCommandPool> m_cmd_pools;
	private Dictionary<CommandListType, VKCommandQueue> m_command_queues;
	private Dictionary<VkDescriptorType, VKGPUBindlessDescriptorPoolTyped> m_gpu_bindless_descriptor_pool;
	private VKGPUDescriptorPool m_gpu_descriptor_pool;
	private bool m_is_variable_rate_shading_supported = false;
	private uint32 m_shading_rate_image_tile_size = 0;
	private bool m_is_dxr_supported = false;
	private bool m_is_ray_query_supported = false;
	private bool m_is_mesh_shading_supported = false;
	private uint32 m_shader_group_handle_size = 0;
	private uint32 m_shader_record_alignment = 0;
	private uint32 m_shader_table_alignment = 0;
	private bool m_draw_indirect_count_supported = false;
	private bool m_geometry_shader_supported = false;
	private VkPhysicalDeviceProperties m_device_properties = .();

	public this(VKAdapter adapter)
	{
		m_adapter = adapter;
		m_physical_device = adapter.GetPhysicalDevice();
		m_gpu_descriptor_pool = new .(this);

		VulkanNative.vkGetPhysicalDeviceProperties(m_physical_device, &m_device_properties);

		uint32 queueFamilyCount = 0;
		VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(m_physical_device, &queueFamilyCount, null);
		VkQueueFamilyProperties[] queue_families = scope .[queueFamilyCount];
		VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(m_physical_device, &queueFamilyCount, queue_families.Ptr);

		delegate bool(VkQueueFlags flags, VkQueueFlags bits) has_all_bits = scope (flags, bits) => { return (flags & bits) == bits; };
		delegate bool(VkQueueFlags flags, VkQueueFlags bits) has_any_bits = scope (flags, bits) => { return flags & bits != 0; };
		for (uint32 i = 0; i < queue_families.Count; ++i)
		{
			VkQueueFamilyProperties queue = queue_families[i];
			if (queue.queueCount > 0 &&
				has_all_bits(queue.queueFlags,
				VkQueueFlags.VK_QUEUE_GRAPHICS_BIT | VkQueueFlags.VK_QUEUE_COMPUTE_BIT | VkQueueFlags.VK_QUEUE_TRANSFER_BIT))
			{
				m_queues_info[CommandListType.kGraphics].queue_family_index = i;
				m_queues_info[CommandListType.kGraphics].queue_count = queue.queueCount;
			} else if (queue.queueCount > 0 &&
				has_all_bits(queue.queueFlags, VkQueueFlags.VK_QUEUE_COMPUTE_BIT | VkQueueFlags.VK_QUEUE_TRANSFER_BIT) &&
				!has_any_bits(queue.queueFlags, VkQueueFlags.VK_QUEUE_GRAPHICS_BIT))
			{
				m_queues_info[CommandListType.kCompute].queue_family_index = i;
				m_queues_info[CommandListType.kCompute].queue_count = queue.queueCount;
			} else if (queue.queueCount > 0 && has_all_bits(queue.queueFlags, VkQueueFlags.VK_QUEUE_TRANSFER_BIT) &&
				!has_any_bits(queue.queueFlags, VkQueueFlags.VK_QUEUE_GRAPHICS_BIT | VkQueueFlags.VK_QUEUE_COMPUTE_BIT))
			{
				m_queues_info[CommandListType.kCopy].queue_family_index = i;
				m_queues_info[CommandListType.kCopy].queue_count = queue.queueCount;
			}
		}

		uint32 deviceExtensionCount = 0;
		VulkanNative.vkEnumerateDeviceExtensionProperties(m_physical_device, null, &deviceExtensionCount, null);
		VkExtensionProperties[] extensions = scope .[deviceExtensionCount];
		VulkanNative.vkEnumerateDeviceExtensionProperties(m_physical_device, null, &deviceExtensionCount, extensions.Ptr);
		List<char8*> req_extension = scope .()
			{
				VulkanNative.VK_KHR_SWAPCHAIN_EXTENSION_NAME,
				VulkanNative.VK_KHR_RAY_TRACING_PIPELINE_EXTENSION_NAME,
				VulkanNative.VK_KHR_RAY_QUERY_EXTENSION_NAME,
				VulkanNative.VK_KHR_ACCELERATION_STRUCTURE_EXTENSION_NAME,
				VulkanNative.VK_KHR_BUFFER_DEVICE_ADDRESS_EXTENSION_NAME,
				VulkanNative.VK_KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME,
				VulkanNative.VK_KHR_MAINTENANCE3_EXTENSION_NAME,
				VulkanNative.VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME,
				VulkanNative.VK_KHR_GET_MEMORY_REQUIREMENTS_2_EXTENSION_NAME,
				VulkanNative.VK_KHR_FRAGMENT_SHADING_RATE_EXTENSION_NAME,
				VulkanNative.VK_KHR_TIMELINE_SEMAPHORE_EXTENSION_NAME,
				VulkanNative.VK_KHR_MAINTENANCE1_EXTENSION_NAME,
				VulkanNative.VK_KHR_DEDICATED_ALLOCATION_EXTENSION_NAME,
				VulkanNative.VK_EXT_MEMORY_BUDGET_EXTENSION_NAME,
				VulkanNative.VK_NV_MESH_SHADER_EXTENSION_NAME,
				VulkanNative.VK_KHR_CREATE_RENDERPASS_2_EXTENSION_NAME
			};

		List<char8*> found_extension = scope .();
		for (var @extension in extensions)
		{
			String extensionName = scope:: String(&@extension.extensionName);
			if (req_extension.FindIndex(scope (req_extension) =>
				{
					return String.Equals(req_extension, extensionName);
				}) != -1)
			{
				found_extension.Add(extensionName);
			}

			if (String.Equals(extensionName, VulkanNative.VK_KHR_FRAGMENT_SHADING_RATE_EXTENSION_NAME))
			{
				m_is_variable_rate_shading_supported = true;
			}
			if (String.Equals(extensionName, VulkanNative.VK_KHR_RAY_TRACING_PIPELINE_EXTENSION_NAME))
			{
				m_is_dxr_supported = true;
			}
			if (String.Equals(extensionName, VulkanNative.VK_NV_MESH_SHADER_EXTENSION_NAME))
			{
				m_is_mesh_shading_supported = true;
			}
			if (String.Equals(extensionName, VulkanNative.VK_KHR_RAY_QUERY_EXTENSION_NAME))
			{
				m_is_ray_query_supported = true;
			}
			if (String.Equals(extensionName, VulkanNative.VK_KHR_DRAW_INDIRECT_COUNT_EXTENSION_NAME))
			{
				m_draw_indirect_count_supported = true;
			}
		}

		void* device_create_info_next = null;
		void add_extension<T>(ref T @extension) where T : var
		{
			@extension.pNext = device_create_info_next;
			device_create_info_next = &@extension;
		}

		if (m_is_variable_rate_shading_supported)
		{
			Dictionary<ShadingRate, VkExtent2D> shading_rate_palette = scope:: .()
				{
					(ShadingRate.k1x1, .() { width = 1, height = 1 }),
					(ShadingRate.k1x2, .() { width = 1, height = 2 }),
					(ShadingRate.k2x1, .() { width = 2, height = 1 }),
					(ShadingRate.k2x2, .() { width = 2, height = 2 }),
					(ShadingRate.k2x4, .() { width = 2, height = 4 }),
					(ShadingRate.k4x2, .() { width = 4, height = 2 }),
					(ShadingRate.k4x4, .() { width = 4, height = 4 })
				};

			uint32 fragmentShadingRateCount = 0;
			VulkanNative.vkGetPhysicalDeviceFragmentShadingRatesKHR(m_physical_device, &fragmentShadingRateCount, null);
			VkPhysicalDeviceFragmentShadingRateKHR[] fragment_shading_rates = scope .[fragmentShadingRateCount];
			VulkanNative.vkGetPhysicalDeviceFragmentShadingRatesKHR(m_physical_device, &fragmentShadingRateCount, fragment_shading_rates.Ptr);
			for (var fragment_shading_rate in fragment_shading_rates)
			{
				VkExtent2D size = fragment_shading_rate.fragmentSize;
				uint8 shading_rate = (((uint8)size.width >> 1) << 2) | ((uint8)size.height >> 1);
				Runtime.Assert((1 << ((shading_rate >> 2) & 3)) == size.width);
				Runtime.Assert((1 << (shading_rate & 3)) == size.height);
				Runtime.Assert(shading_rate_palette[(ShadingRate)shading_rate] == size);
				shading_rate_palette.Remove((ShadingRate)shading_rate);
			}

			Runtime.Assert(shading_rate_palette.IsEmpty);

			VkPhysicalDeviceFragmentShadingRatePropertiesKHR shading_rate_image_properties = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_PROPERTIES_KHR };
			VkPhysicalDeviceProperties2 device_props2 = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2 };
			device_props2.pNext = &shading_rate_image_properties;
			VulkanNative.vkGetPhysicalDeviceProperties2(m_physical_device, &device_props2);
			Runtime.Assert(shading_rate_image_properties.minFragmentShadingRateAttachmentTexelSize ==
				shading_rate_image_properties.maxFragmentShadingRateAttachmentTexelSize);
			Runtime.Assert(shading_rate_image_properties.minFragmentShadingRateAttachmentTexelSize.width ==
				shading_rate_image_properties.minFragmentShadingRateAttachmentTexelSize.height);
			Runtime.Assert(shading_rate_image_properties.maxFragmentShadingRateAttachmentTexelSize.width ==
				shading_rate_image_properties.maxFragmentShadingRateAttachmentTexelSize.height);
			m_shading_rate_image_tile_size = shading_rate_image_properties.maxFragmentShadingRateAttachmentTexelSize.width;

			VkPhysicalDeviceFragmentShadingRateFeaturesKHR fragment_shading_rate_features = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_FEATURES_KHR };
			fragment_shading_rate_features.attachmentFragmentShadingRate = true;
			add_extension(ref fragment_shading_rate_features);
		}

		if (m_is_dxr_supported)
		{
			VkPhysicalDeviceRayTracingPipelinePropertiesKHR ray_tracing_properties = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_PROPERTIES_KHR };
			VkPhysicalDeviceProperties2 device_props2 = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2 };
			device_props2.pNext = &ray_tracing_properties;
			VulkanNative.vkGetPhysicalDeviceProperties2(m_physical_device, &device_props2);
			m_shader_group_handle_size = ray_tracing_properties.shaderGroupHandleSize;
			m_shader_record_alignment = ray_tracing_properties.shaderGroupHandleSize;
			m_shader_table_alignment = ray_tracing_properties.shaderGroupBaseAlignment;
		}

		float queue_priority = 1.0f;
		List<VkDeviceQueueCreateInfo> queues_create_info = scope .();
		for (var queue_info in m_queues_info)
		{
			VkDeviceQueueCreateInfo queue_create_info = .() { sType = .VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO };
			queue_create_info.queueFamilyIndex = queue_info.value.queue_family_index;
			queue_create_info.queueCount = 1;
			queue_create_info.pQueuePriorities = &queue_priority;
			queues_create_info.Add(queue_create_info);
		}

		VkPhysicalDeviceFeatures physical_device_features = .();
		VulkanNative.vkGetPhysicalDeviceFeatures(m_physical_device, &physical_device_features);
		m_geometry_shader_supported = physical_device_features.geometryShader;

		VkPhysicalDeviceFeatures device_features = .();
		device_features.textureCompressionBC = physical_device_features.textureCompressionBC;
		device_features.vertexPipelineStoresAndAtomics = physical_device_features.vertexPipelineStoresAndAtomics;
		device_features.samplerAnisotropy = physical_device_features.samplerAnisotropy;
		device_features.fragmentStoresAndAtomics = physical_device_features.fragmentStoresAndAtomics;
		device_features.sampleRateShading = physical_device_features.sampleRateShading;
		device_features.geometryShader = physical_device_features.geometryShader;
		device_features.imageCubeArray = physical_device_features.imageCubeArray;
		device_features.shaderImageGatherExtended = physical_device_features.shaderImageGatherExtended;

		VkPhysicalDeviceVulkan12Features device_vulkan12_features = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES };
		device_vulkan12_features.drawIndirectCount = m_draw_indirect_count_supported;
		device_vulkan12_features.bufferDeviceAddress = true;
		device_vulkan12_features.timelineSemaphore = true;
		device_vulkan12_features.runtimeDescriptorArray = true;
		device_vulkan12_features.descriptorBindingVariableDescriptorCount = true;
		add_extension(ref device_vulkan12_features);

		VkPhysicalDeviceMeshShaderFeaturesNV mesh_shader_feature = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MESH_SHADER_FEATURES_NV };
		mesh_shader_feature.taskShader = true;
		mesh_shader_feature.meshShader = true;
		if (m_is_mesh_shading_supported)
		{
			add_extension(ref mesh_shader_feature);
		}

		VkPhysicalDeviceRayTracingPipelineFeaturesKHR raytracing_pipeline_feature = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_FEATURES_KHR };
		raytracing_pipeline_feature.rayTracingPipeline = true;

		VkPhysicalDeviceAccelerationStructureFeaturesKHR acceleration_structure_feature = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR };
		acceleration_structure_feature.accelerationStructure = true;

		VkPhysicalDeviceRayQueryFeaturesKHR rayquery_pipeline_feature = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_QUERY_FEATURES_KHR };
		rayquery_pipeline_feature.rayQuery = true;

		if (m_is_dxr_supported)
		{
			add_extension(ref raytracing_pipeline_feature);
			add_extension(ref acceleration_structure_feature);

			if (m_is_ray_query_supported)
			{
				raytracing_pipeline_feature.rayTraversalPrimitiveCulling = true;
				add_extension(ref rayquery_pipeline_feature);
			}
		}

		VkDeviceCreateInfo device_create_info = .() { sType = .VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO };
		device_create_info.pNext = device_create_info_next;
		device_create_info.queueCreateInfoCount = (uint32)queues_create_info.Count;
		device_create_info.pQueueCreateInfos = queues_create_info.Ptr;
		device_create_info.pEnabledFeatures = &device_features;
		device_create_info.enabledExtensionCount = (uint32)found_extension.Count;
		device_create_info.ppEnabledExtensionNames = found_extension.Ptr;

		VkResult result = VulkanNative.vkCreateDevice(m_physical_device, &device_create_info, null, &m_device);
		Runtime.Assert(result == .VK_SUCCESS);

		for (var queue_info in m_queues_info)
		{
			VkCommandPoolCreateInfo cmd_pool_create_info = .() { sType = .VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO };
			cmd_pool_create_info.flags = VkCommandPoolCreateFlags.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
			cmd_pool_create_info.queueFamilyIndex = queue_info.value.queue_family_index;
			VkCommandPool command_pool = .Null;
			VulkanNative.vkCreateCommandPool(m_device, &cmd_pool_create_info, null, &command_pool);
			m_cmd_pools.Add(queue_info.key, command_pool);
			m_command_queues[queue_info.key] =
				new VKCommandQueue(this, queue_info.key, queue_info.value.queue_family_index);
		}
	}

	public override Memory AllocateMemory(uint64 size, MemoryType memory_type, uint32 memory_type_bits)
	{
		return new VKMemory(this, size, memory_type, memory_type_bits, null);
	}

	public override CommandQueue GetCommandQueue(CommandListType type)
	{
		return m_command_queues[GetAvailableCommandListType(type)];
	}

	public override uint32 GetTextureDataPitchAlignment()
	{
		return 1;
	}

	public override Swapchain CreateSwapchain(Sedulous.Platform.SurfaceInfo surfaceInfo, uint32 width, uint32 height, uint32 frame_count, bool vsync)
	{
		return new VKSwapchain(m_command_queues[CommandListType.kGraphics], surfaceInfo, width, height,
			frame_count, vsync);
	}

	public override CommandList CreateCommandList(CommandListType type)
	{
		return new VKCommandList(this, type);
	}

	public override Fence CreateFence(uint64 initial_value)
	{
		return new VKTimelineSemaphore(this, initial_value);
	}

	public override Resource CreateTexture(TextureType type, uint32 bind_flag, Format format, uint32 sample_count, int width, int height, int depth, int mip_levels)
	{
		VKResource res = new VKResource(this);
		res.format = format;
		res.resource_type = ResourceType.kTexture;
		res.image.size.height = (uint32)height;
		res.image.size.width = (uint32)width;
		res.image.format = (VkFormat)format;
		res.image.level_count = (uint32)mip_levels;
		res.image.sample_count = sample_count;
		res.image.array_layers = (uint32)depth;

		VkImageUsageFlags usage = .();
		if (bind_flag & (uint32)BindFlag.kDepthStencil != 0)
		{
			usage |= VkImageUsageFlags.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT | VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_DST_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kShaderResource != 0)
		{
			usage |= VkImageUsageFlags.VK_IMAGE_USAGE_SAMPLED_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kRenderTarget != 0)
		{
			usage |= VkImageUsageFlags.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_DST_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kUnorderedAccess != 0)
		{
			usage |= VkImageUsageFlags.VK_IMAGE_USAGE_STORAGE_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kCopyDest != 0)
		{
			usage |= VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_DST_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kCopySource != 0)
		{
			usage |= VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_SRC_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kShadingRateSource != 0)
		{
			usage |= VkImageUsageFlags.VK_IMAGE_USAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR;
		}

		VkImageCreateInfo image_info = .() { sType = .VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO };
		switch (type) {
		case TextureType.k1D:
			image_info.imageType = VkImageType.VK_IMAGE_TYPE_1D;
			break;
		case TextureType.k2D:
			image_info.imageType = VkImageType.VK_IMAGE_TYPE_2D;
			break;
		case TextureType.k3D:
			image_info.imageType = VkImageType.VK_IMAGE_TYPE_3D;
			break;
		}
		image_info.extent.width = (uint32)width;
		image_info.extent.height = (uint32)height;
		if (type == TextureType.k3D)
		{
			image_info.extent.depth = (uint32)depth;
		} else
		{
			image_info.extent.depth = 1;
		}
		image_info.mipLevels = (uint32)mip_levels;
		if (type == TextureType.k3D)
		{
			image_info.arrayLayers = 1;
		} else
		{
			image_info.arrayLayers = (uint32)depth;
		}
		image_info.format = res.image.format;
		image_info.tiling = VkImageTiling.eOptimal;
		image_info.initialLayout = VkImageLayout.eUndefined;
		image_info.usage = usage;
		image_info.samples = (VkSampleCountFlags)sample_count;
		image_info.sharingMode = VkSharingMode.eExclusive;

		if (image_info.arrayLayers % 6 == 0)
		{
			image_info.flags = VkImageCreateFlags.VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT;
		}
		VulkanNative.vkCreateImage(m_device, &image_info, null, &res.image.res_owner);
		res.image.res = res.image.res_owner;

		res.SetInitialState(ResourceState.kUndefined);

		return res;
	}

	public override Resource CreateBuffer(uint32 bind_flag, uint32 buffer_size)
	{
		if (buffer_size == 0)
		{
			return null;
		}

		VKResource res = new VKResource(this);
		res.resource_type = ResourceType.kBuffer;
		res.buffer.size = buffer_size;

		VkBufferCreateInfo buffer_info = .() { sType = .VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO };
		buffer_info.size = buffer_size;
		buffer_info.usage = VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT;

		if (bind_flag & (uint32)BindFlag.kVertexBuffer != 0)
		{
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kIndexBuffer != 0)
		{
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_INDEX_BUFFER_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kConstantBuffer != 0)
		{
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kUnorderedAccess != 0)
		{
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT;
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kShaderResource != 0)
		{
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT;
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_UNIFORM_TEXEL_BUFFER_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kAccelerationStructure != 0)
		{
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR;
		}
		if (bind_flag & (uint32)BindFlag.kCopySource != 0)
		{
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_SRC_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kCopyDest != 0)
		{
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_DST_BIT;
		}
		if (bind_flag & (uint32)BindFlag.kShaderTable != 0)
		{
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR;
		}
		if (bind_flag & (uint32)BindFlag.kIndirectBuffer != 0)
		{
			buffer_info.usage |= VkBufferUsageFlags.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT;
		}

		VulkanNative.vkCreateBuffer(m_device, &buffer_info, null, &res.buffer.res);
		res.SetInitialState(ResourceState.kCommon);

		return res;
	}

	public override Resource CreateSampler(in SamplerDesc desc)
	{
		VKResource res = new VKResource(this);

		VkSamplerCreateInfo samplerInfo = .() { sType = .VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO };
		samplerInfo.magFilter = VkFilter.eLinear;
		samplerInfo.minFilter = VkFilter.eLinear;
		samplerInfo.anisotropyEnable = true;
		samplerInfo.maxAnisotropy = 16;
		samplerInfo.borderColor = VkBorderColor.eIntOpaqueBlack;
		samplerInfo.unnormalizedCoordinates = VulkanNative.VK_FALSE;
		samplerInfo.mipmapMode = VkSamplerMipmapMode.eLinear;
		samplerInfo.mipLodBias = 0.0f;
		samplerInfo.minLod = 0.0f;
		samplerInfo.maxLod = float.MaxValue;

		/*switch (desc.filter)
		{
		case SamplerFilter.kAnisotropic:
			sampler_desc.Filter = D3D12_FILTER_ANISOTROPIC;
			break;
		case SamplerFilter.kMinMagMipLinear:
			sampler_desc.Filter = D3D12_FILTER_MIN_MAG_MIP_LINEAR;
			break;
		case SamplerFilter.kComparisonMinMagMipLinear:
			sampler_desc.Filter = D3D12_FILTER_COMPARISON_MIN_MAG_MIP_LINEAR;
			break;
		}*/

		switch (desc.mode) {
		case SamplerTextureAddressMode.kWrap:
			samplerInfo.addressModeU = VkSamplerAddressMode.eRepeat;
			samplerInfo.addressModeV = VkSamplerAddressMode.eRepeat;
			samplerInfo.addressModeW = VkSamplerAddressMode.eRepeat;
			break;
		case SamplerTextureAddressMode.kClamp:
			samplerInfo.addressModeU = VkSamplerAddressMode.eClampToEdge;
			samplerInfo.addressModeV = VkSamplerAddressMode.eClampToEdge;
			samplerInfo.addressModeW = VkSamplerAddressMode.eClampToEdge;
			break;
		}

		switch (desc.func) {
		case SamplerComparisonFunc.kNever:
			samplerInfo.compareEnable = false;
			samplerInfo.compareOp = VkCompareOp.eNever;
			break;
		case SamplerComparisonFunc.kAlways:
			samplerInfo.compareEnable = true;
			samplerInfo.compareOp = VkCompareOp.eAlways;
			break;
		case SamplerComparisonFunc.kLess:
			samplerInfo.compareEnable = true;
			samplerInfo.compareOp = VkCompareOp.eLess;
			break;
		}
		VulkanNative.vkCreateSampler(m_device, &samplerInfo, null, &res.sampler.res);

		res.resource_type = ResourceType.kSampler;
		return res;
	}

	public override View CreateView(in Resource resource, in ViewDesc view_desc)
	{
		return new VKView(this, resource.As<VKResource>(), view_desc);
	}

	public override BindingSetLayout CreateBindingSetLayout(System.Span<BindKey> descs)
	{
		return new VKBindingSetLayout(this, descs);
	}

	public override BindingSet CreateBindingSet(in BindingSetLayout layout)
	{
		return new VKBindingSet(this, layout.As<VKBindingSetLayout>());
	}

	public override RenderPass CreateRenderPass(in RenderPassDesc desc)
	{
		return new VKRenderPass(this, desc);
	}

	public override Framebuffer CreateFramebuffer(in FramebufferDesc desc)
	{
		return new VKFramebuffer(this, desc);
	}

	public override Shader CreateShader(Span<uint8> blob, ShaderBlobType blob_type, ShaderType shader_type)
	{
		return new ShaderBase(blob, blob_type, shader_type);
	}

	public override Shader CompileShader(in ShaderDesc desc)
	{
		return new ShaderBase(desc, ShaderBlobType.kSPIRV);
	}

	public override ShaderProgram CreateProgram(System.Span<Shader> shaders)
	{
		return new ShaderProgramBase(shaders);
	}

	public override Pipeline CreateGraphicsPipeline(in GraphicsPipelineDesc desc)
	{
		return new VKGraphicsPipeline(this, desc);
	}

	public override Pipeline CreateComputePipeline(in ComputePipelineDesc desc)
	{
		return new VKComputePipeline(this, desc);
	}

	public override Pipeline CreateRayTracingPipeline(in RayTracingPipelineDesc desc)
	{
		return new VKRayTracingPipeline(this, desc);
	}

	public override Resource CreateAccelerationStructure(AccelerationStructureType type, in Resource resource, uint64 offset)
	{
		VKResource res = new VKResource(this);
		res.resource_type = ResourceType.kAccelerationStructure;
		res.acceleration_structures_memory = resource;

		VkAccelerationStructureCreateInfoKHR acceleration_structure_create_info = .() { sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR };
		acceleration_structure_create_info.buffer = resource.As<VKResource>().buffer.res;
		acceleration_structure_create_info.offset = offset;
		acceleration_structure_create_info.size = 0;
		acceleration_structure_create_info.type = Convert(type);
		VulkanNative.vkCreateAccelerationStructureKHR(m_device, &acceleration_structure_create_info, null, &res.acceleration_structure_handle);

		return res;
	}

	public override QueryHeap CreateQueryHeap(QueryHeapType type, uint32 count)
	{
		return new VKQueryHeap(this, type, count);
	}

	public override bool IsDxrSupported()
	{
		return m_is_dxr_supported;
	}

	public override bool IsRayQuerySupported()
	{
		return m_is_ray_query_supported;
	}

	public override bool IsVariableRateShadingSupported()
	{
		return m_is_variable_rate_shading_supported;
	}

	public override bool IsMeshShadingSupported()
	{
		return m_is_mesh_shading_supported;
	}

	public override bool IsDrawIndirectCountSupported()
	{
		return m_draw_indirect_count_supported;
	}

	public override bool IsGeometryShaderSupported()
	{
		return m_geometry_shader_supported;
	}

	public override uint32 GetShadingRateImageTileSize()
	{
		return m_shading_rate_image_tile_size;
	}

	public override MemoryBudget GetMemoryBudget()
	{
		VkPhysicalDeviceMemoryBudgetPropertiesEXT memory_budget = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_BUDGET_PROPERTIES_EXT };
		VkPhysicalDeviceMemoryProperties2 mem_properties = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_PROPERTIES_2 };
		mem_properties.pNext = &memory_budget;
		VulkanNative.vkGetPhysicalDeviceMemoryProperties2(m_physical_device, &mem_properties);
		MemoryBudget res = .();
		for (uint i = 0; i < VulkanNative.VK_MAX_MEMORY_HEAPS; ++i)
		{
			res.budget += memory_budget.heapBudget[i];
			res.usage += memory_budget.heapUsage[i];
		}
		return res;
	}

	public override uint32 GetShaderGroupHandleSize()
	{
		return m_shader_group_handle_size;
	}

	public override uint32 GetShaderRecordAlignment()
	{
		return m_shader_record_alignment;
	}

	public override uint32 GetShaderTableAlignment()
	{
		return m_shader_table_alignment;
	}

	public override RaytracingASPrebuildInfo GetBLASPrebuildInfo(System.Span<RaytracingGeometryDesc> descs, BuildAccelerationStructureFlags flags)
	{
		List<VkAccelerationStructureGeometryKHR> geometry_descs = scope .();
		List<uint32> max_primitive_counts = scope .();
		for (var desc in descs)
		{
			geometry_descs.Add(FillRaytracingGeometryTriangles(desc.vertex, desc.index, desc.flags));
			if (desc.index.res != null)
			{
				max_primitive_counts.Add(desc.index.count / 3);
			} else
			{
				max_primitive_counts.Add(desc.vertex.count / 3);
			}
		}
		VkAccelerationStructureBuildGeometryInfoKHR acceleration_structure_info = .() { sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR };
		acceleration_structure_info.type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR;
		acceleration_structure_info.geometryCount = (uint32)geometry_descs.Count;
		acceleration_structure_info.pGeometries = geometry_descs.Ptr;
		acceleration_structure_info.flags = Convert(flags);
		return GetAccelerationStructurePrebuildInfo(acceleration_structure_info, max_primitive_counts);
	}

	public override RaytracingASPrebuildInfo GetTLASPrebuildInfo(uint32 instance_count, BuildAccelerationStructureFlags flags)
	{
		VkAccelerationStructureGeometryKHR geometry_info = .() { sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR };
		geometry_info.geometryType = VkGeometryTypeKHR.VK_GEOMETRY_TYPE_INSTANCES_KHR;
		geometry_info.geometry.instances = .() { sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR };

		VkAccelerationStructureBuildGeometryInfoKHR acceleration_structure_info = .() { sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR };
		acceleration_structure_info.type = VkAccelerationStructureTypeKHR.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR;
		acceleration_structure_info.pGeometries = &geometry_info;
		acceleration_structure_info.geometryCount = 1;
		acceleration_structure_info.flags = Convert(flags);
		return GetAccelerationStructurePrebuildInfo(acceleration_structure_info, scope uint32[](instance_count));
	}

	public override ShaderBlobType GetSupportedShaderBlobType()
	{
		return ShaderBlobType.kSPIRV;
	}

	public ref VKAdapter GetAdapter()
	{
		return ref m_adapter;
	}

	public VkDevice GetDevice()
	{
		return m_device;
	}

	public CommandListType GetAvailableCommandListType(CommandListType type)
	{
		if (m_queues_info.ContainsKey(type))
		{
			return type;
		}
		return CommandListType.kGraphics;
	}

	public VkCommandPool GetCmdPool(CommandListType type)
	{
		return m_cmd_pools[GetAvailableCommandListType(type)];
	}

	public VkImageAspectFlags GetAspectFlags(VkFormat format)
	{
		switch (format) {
		case VkFormat.eD32SfloatS8Uint,
			VkFormat.eD24UnormS8Uint,
			VkFormat.eD16UnormS8Uint:
			return VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT;
		case VkFormat.eD16Unorm,
			VkFormat.eD32Sfloat,
			VkFormat.VK_FORMAT_X8_D24_UNORM_PACK32:
			return VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT;
		case VkFormat.eS8Uint:
			return VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT;
		default:
			return VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
		}
	}

	public ref VKGPUBindlessDescriptorPoolTyped GetGPUBindlessDescriptorPool(VkDescriptorType type)
	{
		if (!m_gpu_bindless_descriptor_pool.ContainsKey(type))
		{
			m_gpu_bindless_descriptor_pool.Add(type, new VKGPUBindlessDescriptorPoolTyped(this, type));
		}

		return ref m_gpu_bindless_descriptor_pool[type];
	}

	public ref VKGPUDescriptorPool GetGPUDescriptorPool()
	{
		return ref m_gpu_descriptor_pool;
	}

	public uint32 FindMemoryType(uint32 type_filter, VkMemoryPropertyFlags properties)
	{
		VkPhysicalDeviceMemoryProperties memProperties = .();
		VulkanNative.vkGetPhysicalDeviceMemoryProperties(m_physical_device, &memProperties);

		for (uint32 i = 0; i < memProperties.memoryTypeCount; ++i)
		{
			if ((type_filter & (1 << i) != 0) && (memProperties.memoryTypes[i].propertyFlags & properties) == properties)
			{
				return i;
			}
		}
		Runtime.FatalError("failed to find suitable memory type!");
	}

	public VkAccelerationStructureGeometryKHR FillRaytracingGeometryTriangles(in BufferDesc vertex,
		in BufferDesc index,
		RaytracingGeometryFlags flags)
	{
		VkAccelerationStructureGeometryKHR geometry_desc = .() { sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR };
		geometry_desc.geometryType = VkGeometryTypeKHR.VK_GEOMETRY_TYPE_TRIANGLES_KHR;
		switch (flags) {
		case RaytracingGeometryFlags.kOpaque:
			geometry_desc.flags = VkGeometryFlagsKHR.VK_GEOMETRY_OPAQUE_BIT_KHR;
			break;
		case RaytracingGeometryFlags.kNoDuplicateAnyHitInvocation:
			geometry_desc.flags = VkGeometryFlagsKHR.VK_GEOMETRY_NO_DUPLICATE_ANY_HIT_INVOCATION_BIT_KHR;
			break;
		default:
			break;
		}

		VKResource vk_vertex_res = (VKResource)vertex.res;
		VKResource vk_index_res = (VKResource)index.res;

		var vertex_stride = vertex.format.GetBytesPerPixel();
		geometry_desc.geometry.triangles.vertexData.deviceAddress =
			VulkanNative.vkGetBufferDeviceAddress(m_device, scope .()
			{
				sType = .VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
				buffer = vk_vertex_res.buffer.res
			}) + vertex.offset * vertex_stride;
		geometry_desc.geometry.triangles.vertexStride = vertex_stride;
		geometry_desc.geometry.triangles.vertexFormat = (VkFormat)vertex.format;
		geometry_desc.geometry.triangles.maxVertex = vertex.count;
		if (vk_index_res != null)
		{
			var index_stride = index.format.GetBytesPerPixel();
			geometry_desc.geometry.triangles.indexData.deviceAddress =
				VulkanNative.vkGetBufferDeviceAddress(m_device, scope .()
				{
					sType = .VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
					buffer = vk_index_res.buffer.res
				}) + index.offset * index_stride;
			geometry_desc.geometry.triangles.indexType = GetVkIndexType(index.format);
		} else
		{
			geometry_desc.geometry.triangles.indexType = VkIndexType.VK_INDEX_TYPE_NONE_KHR;
		}

		return geometry_desc;
	}

	public uint32 GetMaxDescriptorSetBindings(VkDescriptorType type)
	{
		switch (type) {
		case VkDescriptorType.eSampler:
			return m_device_properties.limits.maxPerStageDescriptorSamplers;
		case VkDescriptorType.eCombinedImageSampler,
			VkDescriptorType.eSampledImage,
			VkDescriptorType.eUniformTexelBuffer:
			return m_device_properties.limits.maxPerStageDescriptorSampledImages;
		case VkDescriptorType.eUniformBuffer,
			VkDescriptorType.eUniformBufferDynamic:
			return m_device_properties.limits.maxPerStageDescriptorUniformBuffers;
		case VkDescriptorType.eStorageBuffer,
			VkDescriptorType.eStorageBufferDynamic:
			return m_device_properties.limits.maxPerStageDescriptorStorageBuffers;
		case VkDescriptorType.eStorageImage,
			VkDescriptorType.eStorageTexelBuffer:
			return m_device_properties.limits.maxPerStageDescriptorStorageImages;
		default:
			Runtime.Assert(false);
			return 0;
		}
	}

	private  RaytracingASPrebuildInfo GetAccelerationStructurePrebuildInfo(
		in VkAccelerationStructureBuildGeometryInfoKHR acceleration_structure_info,
		Span<uint32> max_primitive_counts)
	{
		var acceleration_structure_info;
		VkAccelerationStructureBuildSizesInfoKHR size_info = .() { sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR };
		VulkanNative.vkGetAccelerationStructureBuildSizesKHR(m_device, VkAccelerationStructureBuildTypeKHR.VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR,
			&acceleration_structure_info, max_primitive_counts.Ptr,
			&size_info);
		RaytracingASPrebuildInfo prebuild_info = .();
		prebuild_info.acceleration_structure_size = size_info.accelerationStructureSize;
		prebuild_info.build_scratch_data_size = size_info.buildScratchSize;
		prebuild_info.update_scratch_data_size = size_info.updateScratchSize;
		return prebuild_info;
	}
}