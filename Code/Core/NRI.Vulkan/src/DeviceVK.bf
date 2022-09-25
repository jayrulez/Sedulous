using Bulkan;
using System.Collections;
using System.Threading;
using System;
using NRI.Helpers;
namespace NRI.Vulkan;

using static Bulkan.VulkanNative;

public static
{
	public static void* vkAllocateHostMemory(void* pUserData, uint size, uint alignment, VkSystemAllocationScope allocationScope)
	{
		//MaybeUnused(allocationScope);

		DeviceAllocator<uint8> allocator = (DeviceAllocator<uint8>)Internal.UnsafeCastToObject(pUserData);
		readonly var lowLevelAllocator = /*ref*/ allocator.GetInterface();

		return lowLevelAllocator.Allocate(lowLevelAllocator.userArg, size, alignment);
	}

	public static void* vkReallocateHostMemory(void* pUserData, void* pOriginal, uint size, uint alignment, VkSystemAllocationScope allocationScope)
	{
		//MaybeUnused(allocationScope);

		DeviceAllocator<uint8> allocator = (DeviceAllocator<uint8>)Internal.UnsafeCastToObject(pUserData);
		readonly var lowLevelAllocator = /*ref*/ allocator.GetInterface();

		return lowLevelAllocator.Reallocate(lowLevelAllocator.userArg, pOriginal, size, alignment);
	}

	public static void vkFreeHostMemory(void* pUserData, void* pMemory)
	{
		DeviceAllocator<uint8> stdAllocator = (DeviceAllocator<uint8>)Internal.UnsafeCastToObject(pUserData);
		readonly var lowLevelAllocator = /*ref*/ stdAllocator.GetInterface();

		lowLevelAllocator.Free(lowLevelAllocator.userArg, pMemory);
	}

	public static void vkHostMemoryInternalAllocationNotification(void* pUserData, uint size, VkInternalAllocationType allocationType,
		VkSystemAllocationScope allocationScope)
	{
		//MaybeUnused(pUserData);
		//MaybeUnused(size);
		//MaybeUnused(allocationType);
		//MaybeUnused(allocationScope);
	}

	public static void vkHostMemoryInternalFreeNotification(void* pUserData, uint size, VkInternalAllocationType allocationType,
		VkSystemAllocationScope allocationScope)
	{
		//MaybeUnused(pUserData);
		//MaybeUnused(size);
		//MaybeUnused(allocationType);
		//MaybeUnused(allocationScope);
	}

	public static char8* GetObjectTypeName(VkObjectType objectType)
	{
		switch (objectType)
		{
		case .VK_OBJECT_TYPE_INSTANCE:
			return "VkInstance";
		case .VK_OBJECT_TYPE_PHYSICAL_DEVICE:
			return "VkPhysicalDevice";
		case .VK_OBJECT_TYPE_DEVICE:
			return "VkDevice";
		case .VK_OBJECT_TYPE_QUEUE:
			return "VkQueue";
		case .VK_OBJECT_TYPE_SEMAPHORE:
			return "VkSemaphore";
		case .VK_OBJECT_TYPE_COMMAND_BUFFER:
			return "VkCommandBuffer";
		case .VK_OBJECT_TYPE_FENCE:
			return "VkFence";
		case .VK_OBJECT_TYPE_DEVICE_MEMORY:
			return "VkDeviceMemory";
		case .VK_OBJECT_TYPE_BUFFER:
			return "VkBuffer";
		case .VK_OBJECT_TYPE_IMAGE:
			return "VkImage";
		case .VK_OBJECT_TYPE_EVENT:
			return "VkEvent";
		case .VK_OBJECT_TYPE_QUERY_POOL:
			return "VkQueryPool";
		case .VK_OBJECT_TYPE_BUFFER_VIEW:
			return "VkBufferView";
		case .VK_OBJECT_TYPE_IMAGE_VIEW:
			return "VkImageView";
		case .VK_OBJECT_TYPE_SHADER_MODULE:
			return "VkShaderModule";
		case .VK_OBJECT_TYPE_PIPELINE_CACHE:
			return "VkPipelineCache";
		case .VK_OBJECT_TYPE_PIPELINE_LAYOUT:
			return "VkPipelineLayout";
		case .VK_OBJECT_TYPE_RENDER_PASS:
			return "VkRenderPass";
		case .VK_OBJECT_TYPE_PIPELINE:
			return "VkPipeline";
		case .VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT:
			return "VkDescriptorSetLayout";
		case .VK_OBJECT_TYPE_SAMPLER:
			return "VkSampler";
		case .VK_OBJECT_TYPE_DESCRIPTOR_POOL:
			return "VkDescriptorPool";
		case .VK_OBJECT_TYPE_DESCRIPTOR_SET:
			return "VkDescriptorSet";
		case .VK_OBJECT_TYPE_FRAMEBUFFER:
			return "VkFramebuffer";
		case .VK_OBJECT_TYPE_COMMAND_POOL:
			return "VkCommandPool";
		case .VK_OBJECT_TYPE_SAMPLER_YCBCR_CONVERSION:
			return "VkSamplerYcbcrConversion";
		case .VK_OBJECT_TYPE_DESCRIPTOR_UPDATE_TEMPLATE:
			return "VkDescriptorUpdateTemplate";
		case .VK_OBJECT_TYPE_SURFACE_KHR:
			return "VkSurfaceKHR";
		case .VK_OBJECT_TYPE_SWAPCHAIN_KHR:
			return "VkSwapchainKHR";
		case .VK_OBJECT_TYPE_DISPLAY_KHR:
			return "VkDisplayKHR";
		case .VK_OBJECT_TYPE_DISPLAY_MODE_KHR:
			return "VkDisplayModeKHR";
		case .VK_OBJECT_TYPE_DEBUG_REPORT_CALLBACK_EXT:
			return "VkDebugReportCallbackEXT";
		case .VK_OBJECT_TYPE_DEBUG_UTILS_MESSENGER_EXT:
			return "VkDebugUtilsMessengerEXT";
		case .VK_OBJECT_TYPE_ACCELERATION_STRUCTURE_KHR:
			return "VkAccelerationStructureKHR";
		case .VK_OBJECT_TYPE_VALIDATION_CACHE_EXT:
			return "VkValidationCacheEXT";
		case .VK_OBJECT_TYPE_PERFORMANCE_CONFIGURATION_INTEL:
			return "VkPerformanceConfigurationINTEL";
		case .VK_OBJECT_TYPE_DEFERRED_OPERATION_KHR:
			return "VkDeferredOperationKHR";
		case .VK_OBJECT_TYPE_INDIRECT_COMMANDS_LAYOUT_NV:
			return "VkIndirectCommandsLayoutNV";
		default:
			return "unknown";
		}
	}

	public static VkBool32 DebugUtilsMessenger(
		VkDebugUtilsMessageSeverityFlagsEXT messageSeverity, /*VkDebugUtilsMessageTypeFlagsEXT*/ uint32 messageTypes,
		VkDebugUtilsMessengerCallbackDataEXT* callbackData,
		void* userData)
	{
		//MaybeUnused(messageType);

		var messageSeverity;
		//VkDebugUtilsMessageTypeFlagsEXT messageType = (.)messageTypes;

		bool isError = false;
		bool isWarning = false;

		// UNASSIGNED-CoreValidation-Shader-InconsistentSpirv
		if (callbackData.messageIdNumber == 7060244)
			messageSeverity = .VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT;

		// VUID-VkShaderModuleCreateInfo-pCode-01090
		if (callbackData.messageIdNumber == 738239446)
			messageSeverity = .VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT;

		char8* type;
		switch (messageSeverity)
		{
		case .VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT:
			type = "verbose";
			break;
		case .VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT:
			type = "info";
			break;
		case .VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT:
			type = "warning";
			isWarning = true;
			break;
		case .VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT:
			type = "error";
			isError = true;
			break;
		default:
			type = "unknown";
			break;
		}

		if (!isWarning && !isError)
			return VK_FALSE;

		DeviceVK device = (DeviceVK)Internal.UnsafeCastToObject(userData);

		String message = Allocate!<String>(device.GetAllocator());
		defer { Deallocate!(device.GetAllocator(), message); }

		message.AppendF("{0} {1} {2}", callbackData.messageIdNumber, scope String(callbackData.pMessageIdName), scope String(callbackData.pMessage));

		// vkCmdCopyBufferToImage: For optimal performance VkImage 0x984b920000000104 layout should be VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL instead of GENERAL.
		if (callbackData.messageIdNumber == 1303270965)
			return VK_FALSE;

		if (messageSeverity == .VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT)
		{
			message.AppendF("\nObjectNum: {0}", callbackData.objectCount);

			for (uint32 i = 0; i < callbackData.objectCount; i++)
			{
				readonly ref VkDebugUtilsObjectNameInfoEXT object = ref callbackData.pObjects[i];
				message.AppendF("\n\tObject {0} {1} ({2:2X})", object.pObjectName != null ? scope String(object.pObjectName) : "", GetObjectTypeName(object.objectType), object.objectHandle);
			}

			REPORT_ERROR(device.GetLogger(), "DebugUtilsMessenger: {0}, {1}", scope String(type), message);
		}
		else if (messageSeverity == .VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT)
		{
			REPORT_WARNING(device.GetLogger(), "DebugUtilsMessenger: {0}, {1}", scope String(type), message);
		}
		else
		{
			REPORT_INFO(device.GetLogger(), "DebugUtilsMessenger: {0}, {1}", scope String(type), message);
		}

		return VK_FALSE;
	}
}

class DeviceVK : Device
{
	private Result CreateInstance(DeviceCreationDesc deviceCreationDesc)
	{
		List<char8*> layers = Allocate!<List<char8*>>(GetAllocator());
		defer { Deallocate!(GetAllocator(), layers); }
		List<char8*> extensions = Allocate!<List<char8*>>(GetAllocator());
		defer { Deallocate!(GetAllocator(), extensions); }

		#if true // VK_USE_PLATFORM_WIN32_KHR
		extensions.Add(VK_KHR_WIN32_SURFACE_EXTENSION_NAME);
		#endif
		#if VK_USE_PLATFORM_METAL_EXT
			extensions.Add(VK_EXT_METAL_SURFACE_EXTENSION_NAME);
		#endif
		#if VK_USE_PLATFORM_XLIB_KHR
			extensions.Add(VK_KHR_XLIB_SURFACE_EXTENSION_NAME);
		#endif
		#if VK_USE_PLATFORM_WAYLAND_KHR
			extensions.Add(VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME);
		#endif
		extensions.Add(VK_KHR_SURFACE_EXTENSION_NAME);

		for (uint32 i = 0; i < deviceCreationDesc.vulkanExtensions.instanceExtensionNum; i++)
			extensions.Add(deviceCreationDesc.vulkanExtensions.instanceExtensions[i]);

		if (!FilterInstanceExtensions(extensions))
		{
			REPORT_ERROR(GetLogger(), "Can't create VkInstance: the required extensions are not supported.");
			return Result.UNSUPPORTED;
		}

		extensions.Add(VK_EXT_DEBUG_UTILS_EXTENSION_NAME);

		if (deviceCreationDesc.enableAPIValidation)
			layers.Add("VK_LAYER_KHRONOS_validation");

		FilterInstanceLayers(layers);
		FilterInstanceExtensions(extensions);

		CheckSupportedInstanceExtensions(extensions);

		/*const*/ VkApplicationInfo appInfo = .()
			{
				sType = .VK_STRUCTURE_TYPE_APPLICATION_INFO,
				pNext = null,
				pApplicationName  = null,
				applicationVersion = 0,
				pEngineName = null,
				engineVersion  = 0,
				apiVersion  = VulkanNative.VK_API_VERSION_1_2
			};

		/*const*/ VkInstanceCreateInfo info = .()
			{
				sType = .VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
				pNext = null,
				flags = (VkInstanceCreateFlags)0,
				pApplicationInfo  = &appInfo,
				enabledLayerCount  = (uint32)layers.Count,
				ppEnabledLayerNames  = layers.Ptr,
				enabledExtensionCount  = (uint32)extensions.Count,
				ppEnabledExtensionNames  = extensions.Ptr
			};

		VkResult result = VulkanNative.vkCreateInstance(&info, m_AllocationCallbackPtr, &m_Instance);

		RETURN_ON_FAILURE!(GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't create a VkInstance: vkCreateInstance returned {0}.", (int32)result);

		if (deviceCreationDesc.enableAPIValidation)
		{
			vkCreateDebugUtilsMessengerEXTFunction vkCreateDebugUtilsMessengerEXTFunc = null;
			vkCreateDebugUtilsMessengerEXTFunc = (vkCreateDebugUtilsMessengerEXTFunction)VulkanNative.vkGetInstanceProcAddr(m_Instance, "vkCreateDebugUtilsMessengerEXT");

			VkDebugUtilsMessengerCreateInfoEXT createInfo = .() { sType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT };

			createInfo.messageSeverity = .VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | .VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT;
			createInfo.messageSeverity |= .VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | .VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;

			createInfo.messageType = .VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | .VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT;
			createInfo.messageType |= .VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;

			PFN_vkDebugUtilsMessengerCallbackEXT debugCallbackFunction = => DebugUtilsMessenger;
			createInfo.pUserData = Internal.UnsafeCastToPtr(this);
			createInfo.pfnUserCallback = debugCallbackFunction;

			result = vkCreateDebugUtilsMessengerEXTFunc(m_Instance, &createInfo, m_AllocationCallbackPtr, &m_Messenger);

			RETURN_ON_FAILURE!(GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't create a debug utils messenger callback: vkCreateDebugUtilsMessengerEXT returned {0}.", (int32)result);
		}

		return Result.SUCCESS;
	}

	private Result FindPhysicalDeviceGroup(PhysicalDeviceGroup* physicalDeviceGroup, bool enableMGPU)
	{
		uint32 deviceGroupNum = 0;
		VulkanNative.vkEnumeratePhysicalDeviceGroups(m_Instance, &deviceGroupNum, null);

		VkPhysicalDeviceGroupProperties* deviceGroups = STACK_ALLOC!<VkPhysicalDeviceGroupProperties>(deviceGroupNum);
		VkResult result = VulkanNative.vkEnumeratePhysicalDeviceGroups(m_Instance, &deviceGroupNum, deviceGroups);

		RETURN_ON_FAILURE!(GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't enumerate physical devices: vkEnumeratePhysicalDevices returned {0}.", (int32)result);

		VkPhysicalDeviceIDProperties idProps = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ID_PROPERTIES };
		VkPhysicalDeviceProperties2 props = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2 };
		props.pNext = &idProps;

		bool isVulkan11Supported = false;

		uint32 i = 0;
		for (; i < deviceGroupNum && m_PhysicalDevices.IsEmpty; i++)
		{
			readonly ref VkPhysicalDeviceGroupProperties group = ref deviceGroups[i];
			VulkanNative.vkGetPhysicalDeviceProperties2(group.physicalDevices[0], &props);

			readonly uint32 majorVersion = VulkanNative.VK_API_VERSION_MAJOR(props.properties.apiVersion);
			readonly uint32 minorVersion = VulkanNative.VK_API_VERSION_MINOR(props.properties.apiVersion);
			isVulkan11Supported = majorVersion > 1 || (majorVersion == 1 && minorVersion >= 1);

			readonly bool isPhysicalDeviceSpecified = physicalDeviceGroup != null;

			if (isPhysicalDeviceSpecified)
			{
				readonly uint64 luid = *(uint64*)&idProps.deviceLUID;
				if (luid == physicalDeviceGroup.luid && group.physicalDeviceCount == physicalDeviceGroup.physicalDeviceGroupSize)
				{
					RETURN_ON_FAILURE!(GetLogger(), isVulkan11Supported, Result.UNSUPPORTED,
						"Can't create a device: the specified physical device does not support Vulkan 1.1.");
					break;
				}
			}
			else
			{
				if (isVulkan11Supported)
					break;
			}
		}

		RETURN_ON_FAILURE!(GetLogger(), i != deviceGroupNum, Result.UNSUPPORTED,
			"Can't create a device: physical device not found.");

		/*readonly*/ ref VkPhysicalDeviceGroupProperties group = ref deviceGroups[i];

		m_IsSubsetAllocationSupported = true;
		if (group.subsetAllocation == VK_FALSE && group.physicalDeviceCount > 1)
		{
			m_IsSubsetAllocationSupported = false;
			REPORT_WARNING(GetLogger(), "The device group does not support memory allocation on a subset of the physical devices.");
		}

		m_PhysicalDevices.Insert(0, Span<VkPhysicalDevice>(&group.physicalDevices, group.physicalDeviceCount));

		if (!enableMGPU)
			m_PhysicalDevices.Resize(1);

		return Result.SUCCESS;
	}

	private static bool IsExtensionInList(char8* @extension, List<char8*> list)
	{
		for (ref char8* extensionFromList in ref list)
		{
			if (String.Equals(@extension, extensionFromList))
				return true;
		}

		return false;
	}

	private static void EraseIncompatibleExtension(List<char8*> extensions, char8* extensionToErase)
	{
		int i = 0;
		for (; i < extensions.Count && !String.Equals(extensions[i], extensionToErase); i++)
			{ }

		if (i < extensions.Count)
			extensions.Remove(extensions[i]);
	}

	private Result CreateLogicalDevice(DeviceCreationDesc deviceCreationDesc)
	{
		List<char8*> extensions = Allocate!<List<char8*>>(GetAllocator());
		defer
		{
			Deallocate!(GetAllocator(), extensions);
		}

		extensions.Add(VK_KHR_SWAPCHAIN_EXTENSION_NAME);

		for (uint32 i = 0; i < deviceCreationDesc.vulkanExtensions.deviceExtensionNum; i++)
			extensions.Add(deviceCreationDesc.vulkanExtensions.deviceExtensions[i]);

		if (!FilterDeviceExtensions(extensions))
		{
			REPORT_ERROR(GetLogger(), "Can't create VkDevice: Swapchain extension is unsupported.");
			return Result.UNSUPPORTED;
		}

		extensions.Add(VK_KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME);
		extensions.Add(VK_KHR_ACCELERATION_STRUCTURE_EXTENSION_NAME);
		extensions.Add(VK_KHR_PIPELINE_LIBRARY_EXTENSION_NAME);
		extensions.Add(VK_KHR_RAY_TRACING_PIPELINE_EXTENSION_NAME);
		extensions.Add(VK_KHR_RAY_QUERY_EXTENSION_NAME);
		extensions.Add(VK_NV_MESH_SHADER_EXTENSION_NAME);
		extensions.Add(VK_EXT_DESCRIPTOR_INDEXING_EXTENSION_NAME);
		extensions.Add(VK_EXT_SAMPLE_LOCATIONS_EXTENSION_NAME);
		extensions.Add(VK_EXT_SAMPLER_FILTER_MINMAX_EXTENSION_NAME);
		extensions.Add(VK_EXT_CONSERVATIVE_RASTERIZATION_EXTENSION_NAME);
		extensions.Add(VK_EXT_SHADER_DEMOTE_TO_HELPER_INVOCATION_EXTENSION_NAME);
		extensions.Add(VK_EXT_HDR_METADATA_EXTENSION_NAME);
		extensions.Add(VK_KHR_SHADER_FLOAT16_INT8_EXTENSION_NAME);

		FilterDeviceExtensions(extensions);

		EraseIncompatibleExtension(extensions, VK_EXT_BUFFER_DEVICE_ADDRESS_EXTENSION_NAME);

		CheckSupportedDeviceExtensions(extensions);

		VkPhysicalDeviceFeatures2 deviceFeatures2 = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2 };

		VkPhysicalDeviceDescriptorIndexingFeatures descriptorIndexingFeatures =
			.() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES };

		VkPhysicalDeviceBufferDeviceAddressFeatures bufferDeviceAddressFeatures =
			.() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES };

		VkPhysicalDeviceShaderDemoteToHelperInvocationFeatures demoteToHelperInvocationFeatures =
			.() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_DEMOTE_TO_HELPER_INVOCATION_FEATURES };

		VkPhysicalDeviceMeshShaderFeaturesNV meshShaderFeatures =
			.() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MESH_SHADER_FEATURES_NV };

		VkPhysicalDeviceRayTracingPipelineFeaturesKHR rayTracingFeatures =
			.() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_FEATURES_KHR };

		VkPhysicalDeviceAccelerationStructureFeaturesKHR accelerationStructureFeatures =
			.() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR };

		VkPhysicalDeviceRayQueryFeaturesKHR rayQueryFeatures =
			.() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_QUERY_FEATURES_KHR };

		VkPhysicalDevice16BitStorageFeatures storageFeatures =
			.() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_16BIT_STORAGE_FEATURES };

		VkPhysicalDeviceShaderFloat16Int8Features float16Int8Features =
			.() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_FLOAT16_INT8_FEATURES };

		deviceFeatures2.pNext = &bufferDeviceAddressFeatures;

		storageFeatures.pNext = deviceFeatures2.pNext;
		deviceFeatures2.pNext = &storageFeatures;

		if (m_IsDescriptorIndexingExtSupported)
		{
			descriptorIndexingFeatures.pNext = deviceFeatures2.pNext;
			deviceFeatures2.pNext = &descriptorIndexingFeatures;
		}

		if (m_IsDemoteToHelperInvocationSupported)
		{
			demoteToHelperInvocationFeatures.pNext = deviceFeatures2.pNext;
			deviceFeatures2.pNext = &demoteToHelperInvocationFeatures;
		}

		if (m_IsMeshShaderExtSupported)
		{
			meshShaderFeatures.pNext = deviceFeatures2.pNext;
			deviceFeatures2.pNext = &meshShaderFeatures;
		}

		if (m_IsRayTracingExtSupported)
		{
			rayTracingFeatures.pNext = deviceFeatures2.pNext;
			deviceFeatures2.pNext = &rayTracingFeatures;
			accelerationStructureFeatures.pNext = deviceFeatures2.pNext;
			deviceFeatures2.pNext = &accelerationStructureFeatures;
			rayQueryFeatures.pNext = deviceFeatures2.pNext;
			deviceFeatures2.pNext = &rayQueryFeatures;
		}

		if (m_IsFP16Supported)
		{
			float16Int8Features.pNext = deviceFeatures2.pNext;
			deviceFeatures2.pNext = &float16Int8Features;
		}

		VulkanNative.vkGetPhysicalDeviceFeatures2(m_PhysicalDevices.Front, &deviceFeatures2);

		m_IsBufferDeviceAddressSupported = bufferDeviceAddressFeatures.bufferDeviceAddress;

		if (!deviceCreationDesc.enableAPIValidation)
			deviceFeatures2.features.robustBufferAccess = false;
		deviceFeatures2.features.inheritedQueries = false;
		deviceFeatures2.features.occlusionQueryPrecise = false;

		List<VkDeviceQueueCreateInfo> queues = Allocate!<List<VkDeviceQueueCreateInfo>>(GetAllocator());
		defer
		{
			Deallocate!(GetAllocator(), queues);
		}
		/*const*/ float priorities = 1.0f;
		for (uint i = 0; i < m_FamilyIndices.Count; i++)
		{
			if (m_FamilyIndices[i] == uint32.MaxValue)
				continue;

			VkDeviceQueueCreateInfo info = .() { sType = .VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO };
			info.queueCount = 1;
			info.queueFamilyIndex = m_FamilyIndices[i];
			info.pQueuePriorities = &priorities;
			queues.Add(info);
		}

		VkDeviceCreateInfo deviceCreateInfo = .() { sType = .VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO };
		deviceCreateInfo.pNext = &deviceFeatures2;
		deviceCreateInfo.queueCreateInfoCount = (uint32)queues.Count;
		deviceCreateInfo.pQueueCreateInfos = queues.Ptr;
		deviceCreateInfo.enabledExtensionCount = (uint32)extensions.Count;
		deviceCreateInfo.ppEnabledExtensionNames = extensions.Ptr;

		VkDeviceGroupDeviceCreateInfo deviceGroupInfo;
		if (m_PhysicalDevices.Count > 1)
		{
			deviceGroupInfo = .() { sType = .VK_STRUCTURE_TYPE_DEVICE_GROUP_DEVICE_CREATE_INFO };
			deviceGroupInfo.pNext = deviceCreateInfo.pNext;
			deviceGroupInfo.physicalDeviceCount = (uint32)m_PhysicalDevices.Count;
			deviceGroupInfo.pPhysicalDevices = m_PhysicalDevices.Ptr;
			deviceCreateInfo.pNext = &deviceGroupInfo;
		}

		readonly VkResult result = VulkanNative.vkCreateDevice(m_PhysicalDevices.Front, &deviceCreateInfo, m_AllocationCallbackPtr, &m_Device);

		RETURN_ON_FAILURE!(GetLogger(), result == .VK_SUCCESS, GetReturnCode(result), "Can't create a device: vkCreateDevice returned {0}.", (int32)result);

		m_IsFP16Supported = float16Int8Features.shaderFloat16 != VK_FALSE;

		return Result.SUCCESS;
	}

	private void FillFamilyIndices(bool useEnabledFamilyIndices, uint32* enabledFamilyIndices, uint32 familyIndexNum)
	{
		uint32 familyNum = 0;
		VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(m_PhysicalDevices.Front, &familyNum, null);

		List<VkQueueFamilyProperties> familyProps = Allocate!<List<VkQueueFamilyProperties>>(GetAllocator());
		familyProps.Resize(familyNum);
		defer
		{
			Deallocate!(GetAllocator(), familyProps);
		}

		VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(m_PhysicalDevices.Front, &familyNum, familyProps.Ptr);

		Internal.MemSet(&m_FamilyIndices, 0xff, m_FamilyIndices.Count * sizeof(uint32));

		for (uint32 i = 0; i < familyProps.Count; i++)
		{
			readonly VkQueueFlags mask = familyProps[i].queueFlags;
			readonly bool graphics = mask.HasFlag(.VK_QUEUE_GRAPHICS_BIT);
			readonly bool compute = mask.HasFlag(.VK_QUEUE_COMPUTE_BIT);
			readonly bool copy = mask.HasFlag(.VK_QUEUE_TRANSFER_BIT);

			if (useEnabledFamilyIndices)
			{
				bool isFamilyEnabled = false;
				for (uint32 j = 0; j < familyIndexNum && !isFamilyEnabled; j++)
					isFamilyEnabled = enabledFamilyIndices[j] == i;

				if (!isFamilyEnabled)
					continue;
			}

			if (graphics)
				m_FamilyIndices[(uint32)CommandQueueType.GRAPHICS] = i;
			else if (compute)
				m_FamilyIndices[(uint32)CommandQueueType.COMPUTE] = i;
			else if (copy)
				m_FamilyIndices[(uint32)CommandQueueType.COPY] = i;
		}
	}

	[Inline]
	private static uint8 GetMaxSampleCount(VkSampleCountFlags flags)
	{
		return (uint8)flags;
	}

	private void SetDeviceLimits(bool enableValidation)
	{
		uint8 conservativeRasterTier = 0;
		if (m_IsConservativeRasterExtSupported)
		{
			VkPhysicalDeviceConservativeRasterizationPropertiesEXT cr = .()
				{
					sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CONSERVATIVE_RASTERIZATION_PROPERTIES_EXT
				};
			VkPhysicalDeviceProperties2 props = .()
				{
					sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2,
					pNext = &cr
				};
			VulkanNative.vkGetPhysicalDeviceProperties2(m_PhysicalDevices.Front, &props);

			if (cr.fullyCoveredFragmentShaderInputVariable && cr.primitiveOverestimationSize <= (1.0 / 256.0f))
				conservativeRasterTier = 3;
			else if (cr.degenerateTrianglesRasterized && cr.primitiveOverestimationSize < (1.0f / 2.0f))
				conservativeRasterTier = 2;
			else
				conservativeRasterTier = 1;
		}

		VkPhysicalDeviceFeatures features = .();
		VulkanNative.vkGetPhysicalDeviceFeatures(m_PhysicalDevices.Front, &features);

		uint32 familyNum = 0;
		VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(m_PhysicalDevices.Front, &familyNum, null);

		List<VkQueueFamilyProperties> familyProperties = Allocate!<List<VkQueueFamilyProperties>>(GetAllocator());
		familyProperties.Resize(familyNum);
		defer
		{
			Deallocate!(GetAllocator(), familyProperties);
		}
		VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(m_PhysicalDevices.Front, &familyNum, familyProperties.Ptr);

		uint32 copyQueueTimestampValidBits = 0;
		readonly uint32 copyQueueFamilyIndex = m_FamilyIndices[(uint32)CommandQueueType.COPY];
		if (copyQueueFamilyIndex != uint32.MaxValue)
			copyQueueTimestampValidBits = familyProperties[copyQueueFamilyIndex].timestampValidBits;

		VkPhysicalDeviceIDProperties IDProperties = .();
		IDProperties.sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ID_PROPERTIES;

		VkPhysicalDeviceProperties2 props = .();
		props.sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2;
		props.pNext = &IDProperties;

		VulkanNative.vkGetPhysicalDeviceProperties2(m_PhysicalDevices.Front, &props);
		readonly ref VkPhysicalDeviceLimits limits = ref props.properties.limits;

		Compiler.Assert(VK_LUID_SIZE == sizeof(uint64), "invalid sizeof");
		m_LUID = *(uint64*)&IDProperties.deviceLUID;

		m_DeviceDesc.graphicsAPI = GraphicsAPI.VULKAN;
		m_DeviceDesc.vendor = GetVendorFromID(props.properties.vendorID);
		m_DeviceDesc.nriVersionMajor = 1; //NRI_VERSION_MAJOR;
		m_DeviceDesc.nriVersionMinor = 0; //NRI_VERSION_MINOR;

		m_DeviceDesc.viewportMaxNum = limits.maxViewports;
		m_DeviceDesc.viewportSubPixelBits = limits.viewportSubPixelBits;
		m_DeviceDesc.viewportBoundsRange[0] = int32(limits.viewportBoundsRange[0]);
		m_DeviceDesc.viewportBoundsRange[1] = int32(limits.viewportBoundsRange[1]);

		m_DeviceDesc.frameBufferMaxDim = Math.Min(limits.maxFramebufferWidth, limits.maxFramebufferHeight);
		m_DeviceDesc.frameBufferLayerMaxNum = limits.maxFramebufferLayers;
		m_DeviceDesc.framebufferColorAttachmentMaxNum = limits.maxColorAttachments;

		m_DeviceDesc.frameBufferColorSampleMaxNum = GetMaxSampleCount(limits.framebufferColorSampleCounts);
		m_DeviceDesc.frameBufferDepthSampleMaxNum = GetMaxSampleCount(limits.framebufferDepthSampleCounts);
		m_DeviceDesc.frameBufferStencilSampleMaxNum = GetMaxSampleCount(limits.framebufferStencilSampleCounts);
		m_DeviceDesc.frameBufferNoAttachmentsSampleMaxNum = GetMaxSampleCount(limits.framebufferNoAttachmentsSampleCounts);
		m_DeviceDesc.textureColorSampleMaxNum = GetMaxSampleCount(limits.sampledImageColorSampleCounts);
		m_DeviceDesc.textureIntegerSampleMaxNum = GetMaxSampleCount(limits.sampledImageIntegerSampleCounts);
		m_DeviceDesc.textureDepthSampleMaxNum = GetMaxSampleCount(limits.sampledImageDepthSampleCounts);
		m_DeviceDesc.textureStencilSampleMaxNum = GetMaxSampleCount(limits.sampledImageStencilSampleCounts);
		m_DeviceDesc.storageTextureSampleMaxNum = GetMaxSampleCount(limits.storageImageSampleCounts);

		m_DeviceDesc.texture1DMaxDim = limits.maxImageDimension1D;
		m_DeviceDesc.texture2DMaxDim = limits.maxImageDimension2D;
		m_DeviceDesc.texture3DMaxDim = limits.maxImageDimension3D;
		m_DeviceDesc.textureArrayMaxDim = limits.maxImageArrayLayers;
		m_DeviceDesc.texelBufferMaxDim = limits.maxTexelBufferElements;

		m_DeviceDesc.memoryAllocationMaxNum = limits.maxMemoryAllocationCount;
		m_DeviceDesc.samplerAllocationMaxNum = limits.maxSamplerAllocationCount;
		m_DeviceDesc.uploadBufferTextureRowAlignment = 1;
		m_DeviceDesc.uploadBufferTextureSliceAlignment = 1;
		m_DeviceDesc.typedBufferOffsetAlignment = (uint32)limits.minTexelBufferOffsetAlignment;
		m_DeviceDesc.constantBufferOffsetAlignment = (uint32)limits.minUniformBufferOffsetAlignment;
		m_DeviceDesc.constantBufferMaxRange = limits.maxUniformBufferRange;
		m_DeviceDesc.storageBufferOffsetAlignment = (uint32)limits.minStorageBufferOffsetAlignment;
		m_DeviceDesc.storageBufferMaxRange = limits.maxStorageBufferRange;
		m_DeviceDesc.pushConstantsMaxSize = limits.maxPushConstantsSize;
		m_DeviceDesc.bufferMaxSize = uint64.MaxValue;
		m_DeviceDesc.bufferTextureGranularity = (uint32)limits.bufferImageGranularity;

		m_DeviceDesc.boundDescriptorSetMaxNum = limits.maxBoundDescriptorSets;
		m_DeviceDesc.perStageDescriptorSamplerMaxNum = limits.maxPerStageDescriptorSamplers;
		m_DeviceDesc.perStageDescriptorConstantBufferMaxNum = limits.maxPerStageDescriptorUniformBuffers;
		m_DeviceDesc.perStageDescriptorStorageBufferMaxNum = limits.maxPerStageDescriptorStorageBuffers;
		m_DeviceDesc.perStageDescriptorTextureMaxNum = limits.maxPerStageDescriptorSampledImages;
		m_DeviceDesc.perStageDescriptorStorageTextureMaxNum = limits.maxPerStageDescriptorStorageImages;
		m_DeviceDesc.perStageResourceMaxNum = limits.maxPerStageResources;

		m_DeviceDesc.descriptorSetSamplerMaxNum = limits.maxDescriptorSetSamplers;
		m_DeviceDesc.descriptorSetConstantBufferMaxNum = limits.maxDescriptorSetUniformBuffers;
		m_DeviceDesc.descriptorSetStorageBufferMaxNum = limits.maxDescriptorSetStorageBuffers;
		m_DeviceDesc.descriptorSetTextureMaxNum = limits.maxDescriptorSetSampledImages;
		m_DeviceDesc.descriptorSetStorageTextureMaxNum = limits.maxDescriptorSetStorageImages;

		m_DeviceDesc.vertexShaderAttributeMaxNum = limits.maxVertexInputAttributes;
		m_DeviceDesc.vertexShaderStreamMaxNum = limits.maxVertexInputBindings;
		m_DeviceDesc.vertexShaderOutputComponentMaxNum = limits.maxVertexOutputComponents;

		m_DeviceDesc.tessControlShaderGenerationMaxLevel = (float)limits.maxTessellationGenerationLevel;
		m_DeviceDesc.tessControlShaderPatchPointMaxNum = limits.maxTessellationPatchSize;
		m_DeviceDesc.tessControlShaderPerVertexInputComponentMaxNum = limits.maxTessellationControlPerVertexInputComponents;
		m_DeviceDesc.tessControlShaderPerVertexOutputComponentMaxNum = limits.maxTessellationControlPerVertexOutputComponents;
		m_DeviceDesc.tessControlShaderPerPatchOutputComponentMaxNum = limits.maxTessellationControlPerPatchOutputComponents;
		m_DeviceDesc.tessControlShaderTotalOutputComponentMaxNum = limits.maxTessellationControlTotalOutputComponents;

		m_DeviceDesc.tessEvaluationShaderInputComponentMaxNum = limits.maxTessellationEvaluationInputComponents;
		m_DeviceDesc.tessEvaluationShaderOutputComponentMaxNum = limits.maxTessellationEvaluationOutputComponents;

		m_DeviceDesc.geometryShaderInvocationMaxNum = limits.maxGeometryShaderInvocations;
		m_DeviceDesc.geometryShaderInputComponentMaxNum = limits.maxGeometryInputComponents;
		m_DeviceDesc.geometryShaderOutputComponentMaxNum = limits.maxGeometryOutputComponents;
		m_DeviceDesc.geometryShaderOutputVertexMaxNum = limits.maxGeometryOutputVertices;
		m_DeviceDesc.geometryShaderTotalOutputComponentMaxNum = limits.maxGeometryTotalOutputComponents;

		m_DeviceDesc.fragmentShaderInputComponentMaxNum = limits.maxFragmentInputComponents;
		m_DeviceDesc.fragmentShaderOutputAttachmentMaxNum = limits.maxFragmentOutputAttachments;
		m_DeviceDesc.fragmentShaderDualSourceAttachmentMaxNum = limits.maxFragmentDualSrcAttachments;
		m_DeviceDesc.fragmentShaderCombinedOutputResourceMaxNum = limits.maxFragmentCombinedOutputResources;

		m_DeviceDesc.computeShaderSharedMemoryMaxSize = limits.maxComputeSharedMemorySize;
		m_DeviceDesc.computeShaderWorkGroupMaxNum[0] = limits.maxComputeWorkGroupCount[0];
		m_DeviceDesc.computeShaderWorkGroupMaxNum[1] = limits.maxComputeWorkGroupCount[1];
		m_DeviceDesc.computeShaderWorkGroupMaxNum[2] = limits.maxComputeWorkGroupCount[2];
		m_DeviceDesc.computeShaderWorkGroupInvocationMaxNum = limits.maxComputeWorkGroupInvocations;
		m_DeviceDesc.computeShaderWorkGroupMaxDim[0] = limits.maxComputeWorkGroupSize[0];
		m_DeviceDesc.computeShaderWorkGroupMaxDim[1] = limits.maxComputeWorkGroupSize[1];
		m_DeviceDesc.computeShaderWorkGroupMaxDim[2] = limits.maxComputeWorkGroupSize[2];

		m_DeviceDesc.subPixelPrecisionBits = limits.subPixelPrecisionBits;
		m_DeviceDesc.subTexelPrecisionBits = limits.subTexelPrecisionBits;
		m_DeviceDesc.mipmapPrecisionBits = limits.mipmapPrecisionBits;
		m_DeviceDesc.drawIndexedIndex16ValueMax = Math.Min<uint32>(uint16.MaxValue, limits.maxDrawIndexedIndexValue);
		m_DeviceDesc.drawIndexedIndex32ValueMax = limits.maxDrawIndexedIndexValue;
		m_DeviceDesc.drawIndirectMaxNum = limits.maxDrawIndirectCount;
		m_DeviceDesc.samplerLodBiasMin = -limits.maxSamplerLodBias;
		m_DeviceDesc.samplerLodBiasMax = limits.maxSamplerLodBias;
		m_DeviceDesc.samplerAnisotropyMax = limits.maxSamplerAnisotropy;
		m_DeviceDesc.texelOffsetMin = limits.minTexelOffset;
		m_DeviceDesc.texelOffsetMax = limits.maxTexelOffset;
		m_DeviceDesc.texelGatherOffsetMin = limits.minTexelGatherOffset;
		m_DeviceDesc.texelGatherOffsetMax = limits.maxTexelGatherOffset;
		m_DeviceDesc.clipDistanceMaxNum = limits.maxClipDistances;
		m_DeviceDesc.cullDistanceMaxNum = limits.maxCullDistances;
		m_DeviceDesc.combinedClipAndCullDistanceMaxNum = limits.maxCombinedClipAndCullDistances;
		m_DeviceDesc.conservativeRasterTier = conservativeRasterTier;
		m_DeviceDesc.timestampFrequencyHz = uint64(1e9 / double(limits.timestampPeriod) + 0.5);
		m_DeviceDesc.phyiscalDeviceGroupSize = (uint32)m_PhysicalDevices.Count;

		m_DeviceDesc.isAPIValidationEnabled = enableValidation;
		m_DeviceDesc.isTextureFilterMinMaxSupported = m_IsMinMaxFilterExtSupported;
		m_DeviceDesc.isLogicOpSupported = features.logicOp;
		m_DeviceDesc.isDepthBoundsTestSupported = features.depthBounds;
		m_DeviceDesc.isProgrammableSampleLocationsSupported = m_IsSampleLocationExtSupported;
		m_DeviceDesc.isComputeQueueSupported = m_Queues[(uint32)CommandQueueType.COMPUTE] != null;
		m_DeviceDesc.isCopyQueueSupported = m_Queues[(uint32)CommandQueueType.COPY] != null;
		m_DeviceDesc.isCopyQueueTimestampSupported = copyQueueTimestampValidBits == 64;
		m_DeviceDesc.isRegisterAliasingSupported = true;
		m_DeviceDesc.isSubsetAllocationSupported = m_IsSubsetAllocationSupported;
		m_DeviceDesc.isFloat16Supported = m_IsFP16Supported;
	}

	private void CreateCommandQueues()
	{
		for (uint32 i = 0; i < m_FamilyIndices.Count; i++)
		{
			if (m_FamilyIndices[i] == uint32.MaxValue)
				continue;

			VkQueue handle = .Null;
			VulkanNative.vkGetDeviceQueue(m_Device, m_FamilyIndices[i], 0, &handle);

			m_Queues[i] = Allocate!<CommandQueueVK>(GetAllocator(), this, handle, m_FamilyIndices[i], (CommandQueueType)i);

			m_ConcurrentSharingModeQueueIndices.Add(m_FamilyIndices[i]);
		}
	}

	private mixin RESOLVE_OPTIONAL_DEVICE_FUNCTION(String name)
	{
		String vkName = scope $"vk{name}";
		VulkanNative.LoadFunction(vkName, false).IgnoreError();
	}

	private mixin RESOLVE_DEVICE_FUNCTION(String name)
	{
		String vkName = scope $"vk{name}";
		if (VulkanNative.LoadFunction(vkName, false) case .Err)
		{
			REPORT_ERROR(GetLogger(), "Failed to get device function: '{}'.", vkName);
			return Result.UNSUPPORTED;
		}
	}

	private mixin RESOLVE_DEVICE_FUNCTION_WITH_OTHER_NAME(String name, String otherName)
	{
		String vkName = scope $"{otherName}";
		if (VulkanNative.LoadFunction(vkName, false) case .Err)
		{
			REPORT_ERROR(GetLogger(), "Failed to get device function: '{}'.", vkName);
			return Result.UNSUPPORTED;
		}
	}

	private mixin RESOLVE_INSTANCE_FUNCTION(String name)
	{
		String vkName = scope $"vk{name}";
		if (VulkanNative.LoadFunction(vkName, false) case .Err)
		{
			REPORT_ERROR(GetLogger(), "Failed to get instance function: '{}'.", vkName);
			return Result.UNSUPPORTED;
		}
	}

	private mixin RESOLVE_PRE_INSTANCE_FUNCTION(String name)
	{
		String vkName = scope $"vk{name}";
		if (VulkanNative.LoadFunction(vkName, false) case .Err)
		{
			REPORT_ERROR(GetLogger(), "Failed to get instance function: '{}'.", vkName);
			return Result.UNSUPPORTED;
		}
	}

	private Result ResolvePreInstanceDispatchTable()
	{
		if (VulkanNative.LoadFunction("vkGetInstanceProcAddr", false) case .Err)
		{
			REPORT_ERROR(GetLogger(), "Failed to get vkGetInstanceProcAddr.");
			return Result.UNSUPPORTED;
		}

		RESOLVE_PRE_INSTANCE_FUNCTION!("CreateInstance");
		RESOLVE_PRE_INSTANCE_FUNCTION!("EnumerateInstanceExtensionProperties");
		RESOLVE_PRE_INSTANCE_FUNCTION!("EnumerateInstanceLayerProperties");

		return .SUCCESS;
	}

	private Result ResolveInstanceDispatchTable()
	{
		RESOLVE_INSTANCE_FUNCTION!("GetPhysicalDeviceSurfaceFormatsKHR");
		RESOLVE_INSTANCE_FUNCTION!("GetPhysicalDeviceSurfaceSupportKHR");
		RESOLVE_INSTANCE_FUNCTION!("GetPhysicalDeviceSurfaceCapabilitiesKHR");
		RESOLVE_INSTANCE_FUNCTION!("GetPhysicalDeviceSurfacePresentModesKHR");
#if true //VK_USE_PLATFORM_WIN32_KHR
		RESOLVE_INSTANCE_FUNCTION!("CreateWin32SurfaceKHR");
#endif
#if VK_USE_PLATFORM_METAL_EXT
		RESOLVE_INSTANCE_FUNCTION!("CreateMetalSurfaceEXT");
#endif
#if VK_USE_PLATFORM_XLIB_KHR
		RESOLVE_INSTANCE_FUNCTION!("CreateXlibSurfaceKHR");
#endif
#if VK_USE_PLATFORM_WAYLAND_KHR
		RESOLVE_INSTANCE_FUNCTION!("CreateWaylandSurfaceKHR");
#endif
		RESOLVE_INSTANCE_FUNCTION!("DestroySurfaceKHR");
		RESOLVE_INSTANCE_FUNCTION!("GetDeviceProcAddr");
		RESOLVE_INSTANCE_FUNCTION!("DestroyInstance");
		RESOLVE_INSTANCE_FUNCTION!("DestroyDevice");
		RESOLVE_INSTANCE_FUNCTION!("GetPhysicalDeviceMemoryProperties");
		RESOLVE_INSTANCE_FUNCTION!("GetDeviceGroupPeerMemoryFeatures");
		RESOLVE_INSTANCE_FUNCTION!("CreateDevice");
		RESOLVE_INSTANCE_FUNCTION!("GetDeviceQueue");
		RESOLVE_INSTANCE_FUNCTION!("EnumeratePhysicalDeviceGroups");
		RESOLVE_INSTANCE_FUNCTION!("GetPhysicalDeviceProperties");
		RESOLVE_INSTANCE_FUNCTION!("GetPhysicalDeviceProperties2");
		RESOLVE_INSTANCE_FUNCTION!("GetPhysicalDeviceFeatures");
		RESOLVE_INSTANCE_FUNCTION!("GetPhysicalDeviceFeatures2");
		RESOLVE_INSTANCE_FUNCTION!("GetPhysicalDeviceQueueFamilyProperties");
		RESOLVE_INSTANCE_FUNCTION!("EnumerateDeviceExtensionProperties");

		return .SUCCESS;
	}

	private Result ResolveDispatchTable()
	{
		RESOLVE_DEVICE_FUNCTION!("CreateBuffer");
		RESOLVE_DEVICE_FUNCTION!("CreateImage");
		RESOLVE_DEVICE_FUNCTION!("CreateBufferView");
		RESOLVE_DEVICE_FUNCTION!("CreateImageView");
		RESOLVE_DEVICE_FUNCTION!("CreateSampler");
		RESOLVE_DEVICE_FUNCTION!("CreateRenderPass");
		RESOLVE_DEVICE_FUNCTION!("CreateFramebuffer");
		RESOLVE_DEVICE_FUNCTION!("CreateQueryPool");
		RESOLVE_DEVICE_FUNCTION!("CreateCommandPool");
		RESOLVE_DEVICE_FUNCTION!("CreateFence");
		RESOLVE_DEVICE_FUNCTION!("CreateSemaphore");
		RESOLVE_DEVICE_FUNCTION!("CreateDescriptorPool");
		RESOLVE_DEVICE_FUNCTION!("CreatePipelineLayout");
		RESOLVE_DEVICE_FUNCTION!("CreateDescriptorSetLayout");
		RESOLVE_DEVICE_FUNCTION!("CreateShaderModule");
		RESOLVE_DEVICE_FUNCTION!("CreateGraphicsPipelines");
		RESOLVE_DEVICE_FUNCTION!("CreateComputePipelines");
		RESOLVE_DEVICE_FUNCTION!("CreateSwapchainKHR");

		RESOLVE_DEVICE_FUNCTION!("DestroyBuffer");
		RESOLVE_DEVICE_FUNCTION!("DestroyImage");
		RESOLVE_DEVICE_FUNCTION!("DestroyBufferView");
		RESOLVE_DEVICE_FUNCTION!("DestroyImageView");
		RESOLVE_DEVICE_FUNCTION!("DestroySampler");
		RESOLVE_DEVICE_FUNCTION!("DestroyRenderPass");
		RESOLVE_DEVICE_FUNCTION!("DestroyFramebuffer");
		RESOLVE_DEVICE_FUNCTION!("DestroyQueryPool");
		RESOLVE_DEVICE_FUNCTION!("DestroyCommandPool");
		RESOLVE_DEVICE_FUNCTION!("DestroyFence");
		RESOLVE_DEVICE_FUNCTION!("DestroySemaphore");
		RESOLVE_DEVICE_FUNCTION!("DestroyDescriptorPool");
		RESOLVE_DEVICE_FUNCTION!("DestroyPipelineLayout");
		RESOLVE_DEVICE_FUNCTION!("DestroyDescriptorSetLayout");
		RESOLVE_DEVICE_FUNCTION!("DestroyShaderModule");
		RESOLVE_DEVICE_FUNCTION!("DestroyPipeline");
		RESOLVE_DEVICE_FUNCTION!("DestroySwapchainKHR");

		RESOLVE_DEVICE_FUNCTION!("AllocateMemory");
		RESOLVE_DEVICE_FUNCTION!("MapMemory");
		RESOLVE_DEVICE_FUNCTION!("UnmapMemory");
		RESOLVE_DEVICE_FUNCTION!("FreeMemory");

		RESOLVE_OPTIONAL_DEVICE_FUNCTION!("BindBufferMemory2");
		if (VulkanNative.[Friend]vkBindBufferMemory2_ptr == null)
			RESOLVE_DEVICE_FUNCTION_WITH_OTHER_NAME!("BindBufferMemory2", "vkBindBufferMemory2KHR");

		RESOLVE_OPTIONAL_DEVICE_FUNCTION!("BindImageMemory2");
		if (VulkanNative.[Friend]vkBindImageMemory2_ptr == null)
			RESOLVE_DEVICE_FUNCTION_WITH_OTHER_NAME!("BindImageMemory2", "vkBindImageMemory2KHR");

		RESOLVE_OPTIONAL_DEVICE_FUNCTION!("GetBufferMemoryRequirements2");
		if (VulkanNative.[Friend]vkGetBufferMemoryRequirements2_ptr == null)
			RESOLVE_DEVICE_FUNCTION_WITH_OTHER_NAME!("GetBufferMemoryRequirements2", "vkGetBufferMemoryRequirements2KHR");

		RESOLVE_OPTIONAL_DEVICE_FUNCTION!("GetImageMemoryRequirements2");
		if (VulkanNative.[Friend]vkGetImageMemoryRequirements2_ptr == null)
			RESOLVE_DEVICE_FUNCTION_WITH_OTHER_NAME!("GetImageMemoryRequirements2", "vkGetImageMemoryRequirements2KHR");

		RESOLVE_DEVICE_FUNCTION!("QueueWaitIdle");
		RESOLVE_DEVICE_FUNCTION!("WaitForFences");
		RESOLVE_DEVICE_FUNCTION!("ResetFences");
		RESOLVE_DEVICE_FUNCTION!("AcquireNextImageKHR");
		RESOLVE_DEVICE_FUNCTION!("QueueSubmit");
		RESOLVE_DEVICE_FUNCTION!("QueuePresentKHR");

		RESOLVE_DEVICE_FUNCTION!("ResetCommandPool");
		RESOLVE_DEVICE_FUNCTION!("ResetDescriptorPool");
		RESOLVE_DEVICE_FUNCTION!("AllocateCommandBuffers");
		RESOLVE_DEVICE_FUNCTION!("AllocateDescriptorSets");
		RESOLVE_DEVICE_FUNCTION!("FreeCommandBuffers");
		RESOLVE_DEVICE_FUNCTION!("FreeDescriptorSets");

		RESOLVE_DEVICE_FUNCTION!("UpdateDescriptorSets");

		RESOLVE_DEVICE_FUNCTION!("BeginCommandBuffer");
		RESOLVE_DEVICE_FUNCTION!("CmdSetDepthBounds");
		RESOLVE_DEVICE_FUNCTION!("CmdSetViewport");
		RESOLVE_DEVICE_FUNCTION!("CmdSetScissor");
		RESOLVE_DEVICE_FUNCTION!("CmdSetStencilReference");
		RESOLVE_DEVICE_FUNCTION!("CmdClearAttachments");
		RESOLVE_DEVICE_FUNCTION!("CmdClearColorImage");
		RESOLVE_DEVICE_FUNCTION!("CmdBeginRenderPass");
		RESOLVE_DEVICE_FUNCTION!("CmdBindVertexBuffers");
		RESOLVE_DEVICE_FUNCTION!("CmdBindIndexBuffer");
		RESOLVE_DEVICE_FUNCTION!("CmdBindPipeline");
		RESOLVE_DEVICE_FUNCTION!("CmdBindDescriptorSets");
		RESOLVE_DEVICE_FUNCTION!("CmdPushConstants");
		RESOLVE_DEVICE_FUNCTION!("CmdDispatch");
		RESOLVE_DEVICE_FUNCTION!("CmdDispatchIndirect");
		RESOLVE_DEVICE_FUNCTION!("CmdDraw");
		RESOLVE_DEVICE_FUNCTION!("CmdDrawIndexed");
		RESOLVE_DEVICE_FUNCTION!("CmdDrawIndirect");
		RESOLVE_DEVICE_FUNCTION!("CmdDrawIndexedIndirect");
		RESOLVE_DEVICE_FUNCTION!("CmdCopyBuffer");
		RESOLVE_DEVICE_FUNCTION!("CmdCopyImage");
		RESOLVE_DEVICE_FUNCTION!("CmdCopyBufferToImage");
		RESOLVE_DEVICE_FUNCTION!("CmdCopyImageToBuffer");
		RESOLVE_DEVICE_FUNCTION!("CmdPipelineBarrier");
		RESOLVE_DEVICE_FUNCTION!("CmdBeginQuery");
		RESOLVE_DEVICE_FUNCTION!("CmdEndQuery");
		RESOLVE_DEVICE_FUNCTION!("CmdWriteTimestamp");
		RESOLVE_DEVICE_FUNCTION!("CmdCopyQueryPoolResults");
		RESOLVE_DEVICE_FUNCTION!("CmdResetQueryPool");
		RESOLVE_DEVICE_FUNCTION!("CmdEndRenderPass");
		RESOLVE_DEVICE_FUNCTION!("CmdFillBuffer");
		RESOLVE_DEVICE_FUNCTION!("EndCommandBuffer");

		RESOLVE_DEVICE_FUNCTION!("GetSwapchainImagesKHR");

		if (m_IsDebugUtilsSupported)
		{
			RESOLVE_DEVICE_FUNCTION!("SetDebugUtilsObjectNameEXT");
			RESOLVE_DEVICE_FUNCTION!("CmdBeginDebugUtilsLabelEXT");
			RESOLVE_DEVICE_FUNCTION!("CmdEndDebugUtilsLabelEXT");
		}

		if (m_IsRayTracingExtSupported)
		{
			RESOLVE_DEVICE_FUNCTION!("CreateAccelerationStructureKHR");
			RESOLVE_DEVICE_FUNCTION!("CreateRayTracingPipelinesKHR");
			RESOLVE_DEVICE_FUNCTION!("DestroyAccelerationStructureKHR");
			RESOLVE_DEVICE_FUNCTION!("GetAccelerationStructureDeviceAddressKHR");
			RESOLVE_DEVICE_FUNCTION!("GetAccelerationStructureBuildSizesKHR");
			RESOLVE_DEVICE_FUNCTION!("GetRayTracingShaderGroupHandlesKHR");
			RESOLVE_DEVICE_FUNCTION!("CmdBuildAccelerationStructuresKHR");
			RESOLVE_DEVICE_FUNCTION!("CmdCopyAccelerationStructureKHR");
			RESOLVE_DEVICE_FUNCTION!("CmdWriteAccelerationStructuresPropertiesKHR");
			RESOLVE_DEVICE_FUNCTION!("CmdTraceRaysKHR");
			RESOLVE_DEVICE_FUNCTION!("GetBufferDeviceAddress");
		}

		if (m_IsMeshShaderExtSupported)
		{
			RESOLVE_DEVICE_FUNCTION!("CmdDrawMeshTasksNV");
		}

		RESOLVE_INSTANCE_FUNCTION!("GetPhysicalDeviceFormatProperties");

		if (m_IsHDRExtSupported)
		{
			RESOLVE_OPTIONAL_DEVICE_FUNCTION!("SetHdrMetadataEXT");
			m_IsHDRExtSupported = VulkanNative.[Friend]vkSetHdrMetadataEXT_ptr != null;
		}

		return .SUCCESS;
	}

	private void FilterInstanceLayers(List<char8*> layers)
	{
		uint32 layerNum = 0;
		VulkanNative.vkEnumerateInstanceLayerProperties(&layerNum, null);

		List<VkLayerProperties> supportedLayers = Allocate!<List<VkLayerProperties>>(GetAllocator());
		supportedLayers.Resize(layerNum);
		defer
		{
			Deallocate!(GetAllocator(), supportedLayers);
		}
		VulkanNative.vkEnumerateInstanceLayerProperties(&layerNum, supportedLayers.Ptr);

		for (int i = 0; i < layers.Count; i++)
		{
			bool found = false;
			for (uint32 j = 0; j < layerNum && !found; j++)
			{
				if (String.Equals(&supportedLayers[j].layerName, layers[i]))
					found = true;
			}

			if (!found)
				layers.RemoveAt(i--);
		}
	}

	private bool FilterInstanceExtensions(List<char8*> extensions)
	{
		uint32 extensionNum = 0;
		VulkanNative.vkEnumerateInstanceExtensionProperties(null, &extensionNum, null);

		List<VkExtensionProperties> supportedExtensions = Allocate!<List<VkExtensionProperties>>(GetAllocator());
		supportedExtensions.Resize(extensionNum);
		defer { Deallocate!(GetAllocator(), supportedExtensions); }
		VulkanNative.vkEnumerateInstanceExtensionProperties(null, &extensionNum, supportedExtensions.Ptr);

		bool allFound = true;
		for (int i = 0; i < extensions.Count; i++)
		{
			bool found = false;
			for (uint32 j = 0; j < extensionNum && !found; j++)
			{
				if (String.Equals(&supportedExtensions[j].extensionName, extensions[i]))
					found = true;
			}

			if (!found)
			{
				extensions.RemoveAt(i--);
				allFound = false;
			}
		}

		return allFound;
	}

	private bool FilterDeviceExtensions(List<char8*> extensions)
	{
		uint32 extensionNum = 0;
		VulkanNative.vkEnumerateDeviceExtensionProperties(m_PhysicalDevices.Front, null, &extensionNum, null);

		List<VkExtensionProperties> supportedExtensions = Allocate!<List<VkExtensionProperties>>(GetAllocator());
		supportedExtensions.Resize(extensionNum);
		defer
		{
			Deallocate!(GetAllocator(), supportedExtensions);
		}
		VulkanNative.vkEnumerateDeviceExtensionProperties(m_PhysicalDevices.Front, null, &extensionNum, supportedExtensions.Ptr);

		bool allFound = true;
		for (int i = 0; i < extensions.Count; i++)
		{
			bool found = false;
			for (uint32 j = 0; j < extensionNum && !found; j++)
			{
				if (String.Equals(&supportedExtensions[j].extensionName, extensions[i]))
					found = true;
			}

			if (!found)
			{
				extensions.RemoveAt(i--);
				allFound = false;
			}
		}

		return allFound;
	}

	private void RetrieveRayTracingInfo()
	{
		m_RayTracingDeviceProperties = .() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_PROPERTIES_KHR };

		if (!m_IsRayTracingExtSupported)
			return;

		VkPhysicalDeviceAccelerationStructurePropertiesKHR accelerationStructureProperties =
			.() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_PROPERTIES_KHR };

		VkPhysicalDeviceProperties2 props = .()
			{
				sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2,
				pNext = &m_RayTracingDeviceProperties
			};

		m_RayTracingDeviceProperties.pNext = &accelerationStructureProperties;

		VulkanNative.vkGetPhysicalDeviceProperties2(m_PhysicalDevices.Front, &props);

		m_DeviceDesc.rayTracingShaderGroupIdentifierSize = m_RayTracingDeviceProperties.shaderGroupHandleSize;
		m_DeviceDesc.rayTracingShaderRecursionMaxDepth = m_RayTracingDeviceProperties.maxRayRecursionDepth;
		m_DeviceDesc.rayTracingGeometryObjectMaxNum = (uint32)accelerationStructureProperties.maxGeometryCount;
		m_DeviceDesc.rayTracingShaderTableAligment = m_RayTracingDeviceProperties.shaderGroupBaseAlignment;
		m_DeviceDesc.rayTracingShaderTableMaxStride = m_RayTracingDeviceProperties.maxShaderGroupStride;
	}

	private void RetrieveMeshShaderInfo()
	{
		VkPhysicalDeviceMeshShaderPropertiesNV meshShaderProperties =
			.() { sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MESH_SHADER_PROPERTIES_NV };

		if (!m_IsMeshShaderExtSupported)
			return;

		VkPhysicalDeviceProperties2 props = .()
			{
				sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2,
				pNext = &meshShaderProperties
			};

		VulkanNative.vkGetPhysicalDeviceProperties2(m_PhysicalDevices.Front, &props);

		m_DeviceDesc.meshTaskMaxNum = meshShaderProperties.maxDrawMeshTasksCount;
		m_DeviceDesc.meshTaskWorkGroupInvocationMaxNum = meshShaderProperties.maxTaskWorkGroupInvocations;
		m_DeviceDesc.meshTaskWorkGroupMaxDim[0] = meshShaderProperties.maxTaskWorkGroupSize[0];
		m_DeviceDesc.meshTaskWorkGroupMaxDim[1] = meshShaderProperties.maxTaskWorkGroupSize[1];
		m_DeviceDesc.meshTaskWorkGroupMaxDim[2] = meshShaderProperties.maxTaskWorkGroupSize[2];
		m_DeviceDesc.meshTaskTotalMemoryMaxSize = meshShaderProperties.maxTaskTotalMemorySize;
		m_DeviceDesc.meshTaskOutputMaxNum = meshShaderProperties.maxTaskOutputCount;
		m_DeviceDesc.meshWorkGroupInvocationMaxNum = meshShaderProperties.maxMeshWorkGroupInvocations;
		m_DeviceDesc.meshWorkGroupMaxDim[0] = meshShaderProperties.maxMeshWorkGroupSize[0];
		m_DeviceDesc.meshWorkGroupMaxDim[1] = meshShaderProperties.maxMeshWorkGroupSize[1];
		m_DeviceDesc.meshWorkGroupMaxDim[2] = meshShaderProperties.maxMeshWorkGroupSize[2];
		m_DeviceDesc.meshTotalMemoryMaxSize = meshShaderProperties.maxMeshTotalMemorySize;
		m_DeviceDesc.meshOutputVertexMaxNum = meshShaderProperties.maxMeshOutputVertices;
		m_DeviceDesc.meshOutputPrimitiveMaxNum = meshShaderProperties.maxMeshOutputPrimitives;
		m_DeviceDesc.meshMultiviewViewMaxNum = meshShaderProperties.maxMeshMultiviewViewCount;
		m_DeviceDesc.meshOutputPerVertexGranularity = meshShaderProperties.meshOutputPerVertexGranularity;
		m_DeviceDesc.meshOutputPerPrimitiveGranularity = meshShaderProperties.meshOutputPerPrimitiveGranularity;
	}

	private void ReportDeviceGroupInfo()
	{
		REPORT_INFO(GetLogger(), "Available device memory heaps:");

		for (uint32 i = 0; i < m_MemoryProps.memoryHeapCount; i++)
		{
			String text = scope String();

			if (m_MemoryProps.memoryHeaps[i].flags.HasFlag(.VK_MEMORY_HEAP_DEVICE_LOCAL_BIT))
				text.Append("DEVICE_LOCAL_BIT ");

			if (m_MemoryProps.memoryHeaps[i].flags.HasFlag(.VK_MEMORY_HEAP_MULTI_INSTANCE_BIT))
				text.Append("MULTI_INSTANCE_BIT ");

			readonly double size = double(m_MemoryProps.memoryHeaps[i].size) / (1024.0 * 1024.0);

			REPORT_INFO(GetLogger(), "\tHeap{0} {1}MiB - {2}", i, size, text);

			if (m_DeviceDesc.phyiscalDeviceGroupSize == 1)
				continue;

			for (uint32 j = 0; j < m_DeviceDesc.phyiscalDeviceGroupSize; j++)
			{
				REPORT_INFO(GetLogger(), "\t\tPhysicalDevice{0}", j);

				for (uint32 k = 0; k < m_DeviceDesc.phyiscalDeviceGroupSize; k++)
				{
					if (j == k)
						continue;

					VkPeerMemoryFeatureFlags flags = 0;
					vkGetDeviceGroupPeerMemoryFeatures(m_Device, i, j, k, &flags);

					text.Clear();
					if (flags.HasFlag(.VK_PEER_MEMORY_FEATURE_COPY_SRC_BIT))
						text.Append("COPY_SRC_BIT ");
					if (flags.HasFlag(.VK_PEER_MEMORY_FEATURE_COPY_DST_BIT))
						text.Append("COPY_DST_BIT ");
					if (flags.HasFlag(.VK_PEER_MEMORY_FEATURE_GENERIC_SRC_BIT))
						text.Append("GENERIC_SRC_BIT ");
					if (flags.HasFlag(.VK_PEER_MEMORY_FEATURE_GENERIC_DST_BIT))
						text.Append("GENERIC_DST_BIT ");

					REPORT_INFO(GetLogger(), "\t\t\tPhysicalDevice{0} - {1}", k, text);
				}
			}
		}
	}

	private void CheckSupportedDeviceExtensions(List<char8*> extensions)
	{
		m_IsDescriptorIndexingExtSupported = IsExtensionInList(VK_EXT_DESCRIPTOR_INDEXING_EXTENSION_NAME, extensions);
		m_IsSampleLocationExtSupported = IsExtensionInList(VK_EXT_SAMPLE_LOCATIONS_EXTENSION_NAME, extensions);
		m_IsMinMaxFilterExtSupported = IsExtensionInList(VK_EXT_SAMPLE_LOCATIONS_EXTENSION_NAME, extensions);
		m_IsConservativeRasterExtSupported = IsExtensionInList(VK_EXT_CONSERVATIVE_RASTERIZATION_EXTENSION_NAME, extensions);
		m_IsMeshShaderExtSupported = IsExtensionInList(VK_NV_MESH_SHADER_EXTENSION_NAME, extensions);
		m_IsHDRExtSupported = IsExtensionInList(VK_EXT_HDR_METADATA_EXTENSION_NAME, extensions);
		m_IsFP16Supported = IsExtensionInList(VK_KHR_SHADER_FLOAT16_INT8_EXTENSION_NAME, extensions);
		m_IsBufferDeviceAddressSupported = IsExtensionInList(VK_KHR_BUFFER_DEVICE_ADDRESS_EXTENSION_NAME, extensions);

		m_IsRayTracingExtSupported = m_IsDescriptorIndexingExtSupported;
		m_IsRayTracingExtSupported = m_IsRayTracingExtSupported && IsExtensionInList(VK_KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME, extensions);
		m_IsRayTracingExtSupported = m_IsRayTracingExtSupported && IsExtensionInList(VK_KHR_ACCELERATION_STRUCTURE_EXTENSION_NAME, extensions);
		m_IsRayTracingExtSupported = m_IsRayTracingExtSupported && IsExtensionInList(VK_KHR_PIPELINE_LIBRARY_EXTENSION_NAME, extensions);
		m_IsRayTracingExtSupported = m_IsRayTracingExtSupported && IsExtensionInList(VK_KHR_RAY_TRACING_PIPELINE_EXTENSION_NAME, extensions);

		m_IsDemoteToHelperInvocationSupported = IsExtensionInList(VK_EXT_SHADER_DEMOTE_TO_HELPER_INVOCATION_EXTENSION_NAME, extensions);
	}

	private void CheckSupportedInstanceExtensions(List<char8*> extensions)
	{
		m_IsDebugUtilsSupported = IsExtensionInList(VK_EXT_DEBUG_UTILS_EXTENSION_NAME, extensions);
	}

	private Result CreateImplementation<Implementation, Interface>(out Interface entity)
		where Implementation : Interface, var
	{
		entity = ?;

		Implementation implementation = Allocate!<Implementation>(GetAllocator(), this);
		readonly Result result = implementation.Create();

		if (result == Result.SUCCESS)
		{
			entity = (Interface)implementation;
			return Result.SUCCESS;
		}

		Deallocate!(GetAllocator(), implementation);
		return result;
	}

	private Result CreateImplementation<Implementation, Interface, P1>(out Interface entity, P1 p1)
		where Implementation : Interface, var
		where P1 : var
	{
		entity = ?;

		Implementation implementation = Allocate!<Implementation>(GetAllocator(), this);
		readonly Result result = implementation.Create(p1);

		if (result == Result.SUCCESS)
		{
			entity = (Interface)implementation;
			return Result.SUCCESS;
		}

		Deallocate!(GetAllocator(), implementation);
		return result;
	}

	private Result CreateImplementation<Implementation, Interface, P1, P2>(out Interface entity, P1 p1, P2 p2)
		where Implementation : Interface, var
		where P1 : var
		where P2 : var
	{
		entity = ?;

		Implementation implementation = Allocate!<Implementation>(GetAllocator(), this);
		readonly Result result = implementation.Create(p1, p2);

		if (result == Result.SUCCESS)
		{
			entity = (Interface)implementation;
			return Result.SUCCESS;
		}

		Deallocate!(GetAllocator(), implementation);
		return result;
	}

	private Result CreateImplementation<Implementation, Interface, P1, P2, P3>(out Interface entity, P1 p1, P2 p2, P3 p3)
		where Implementation : Interface, var
		where P1 : var
		where P2 : var
	{
		entity = ?;

		Implementation implementation = Allocate!<Implementation>(GetAllocator(), this);
		readonly Result result = implementation.Create(p1, p2, p3);

		if (result == Result.SUCCESS)
		{
			entity = (Interface)implementation;
			return Result.SUCCESS;
		}

		Deallocate!(GetAllocator(), implementation);
		return result;
	}

	private DeviceLogger m_Logger;
	private DeviceAllocator<uint8> m_Allocator;
	private VkDevice m_Device = .Null;
	private List<VkPhysicalDevice> m_PhysicalDevices;
	private VkInstance m_Instance = .Null;
	private VkPhysicalDeviceMemoryProperties m_MemoryProps = .();
	private DeviceDesc m_DeviceDesc = .();
	private VkPhysicalDeviceRayTracingPipelinePropertiesKHR m_RayTracingDeviceProperties = .();
	private uint32[COMMAND_QUEUE_TYPE_NUM] m_FamilyIndices = .();
	private CommandQueueVK[COMMAND_QUEUE_TYPE_NUM] m_Queues = .();
	private List<uint32> m_PhysicalDeviceIndices;
	private List<uint32> m_ConcurrentSharingModeQueueIndices;
	private VkAllocationCallbacks* m_AllocationCallbackPtr = null;
	private VkAllocationCallbacks m_AllocationCallbacks = .();
	private VkDebugUtilsMessengerEXT m_Messenger = .Null;
	private SPIRVBindingOffsets m_SPIRVBindingOffsets = .();
	private Monitor m_Lock = new .() ~ delete _;
	private uint64 m_LUID = 0;
	private bool m_OwnsNativeObjects = false;
	private bool m_IsRayTracingExtSupported = false;
	private bool m_IsDescriptorIndexingExtSupported = false;
	private bool m_IsSampleLocationExtSupported = false;
	private bool m_IsMinMaxFilterExtSupported = false;
	private bool m_IsConservativeRasterExtSupported = false;
	private bool m_IsMeshShaderExtSupported = false;
	private bool m_IsHDRExtSupported = false;
	private bool m_IsDemoteToHelperInvocationSupported = false;
	private bool m_IsSubsetAllocationSupported = false;
	private bool m_IsConcurrentSharingModeEnabledForBuffers = true;
	private bool m_IsConcurrentSharingModeEnabledForImages = true;
	private bool m_IsDebugUtilsSupported = false;
	private bool m_IsFP16Supported = false;
	private bool m_IsBufferDeviceAddressSupported = false;

	public this(DeviceLogger logger, DeviceAllocator<uint8> allocator)
	{
		m_Logger = logger;
		m_Allocator = allocator;

		m_PhysicalDevices = Allocate!<List<VkPhysicalDevice>>(GetAllocator());
		m_PhysicalDeviceIndices = Allocate!<List<uint32>>(m_Allocator);
		m_ConcurrentSharingModeQueueIndices = Allocate!<List<uint32>>(m_Allocator);

		VulkanNative.Initialize();
	}

	public ~this()
	{
		Deallocate!(GetAllocator(), m_ConcurrentSharingModeQueueIndices);
		Deallocate!(GetAllocator(), m_PhysicalDeviceIndices);
		Deallocate!(GetAllocator(), m_PhysicalDevices);

		if (m_Device == .Null)
			return;

		for (uint32 i = 0; i < m_Queues.Count; i++)
			Deallocate!(GetAllocator(), m_Queues[i]);

		if (m_Messenger != .Null)
		{
			vkDestroyDebugUtilsMessengerEXTFunction  destroyCallback = (vkDestroyDebugUtilsMessengerEXTFunction)vkGetInstanceProcAddr(m_Instance, "vkDestroyDebugUtilsMessengerEXT");
			destroyCallback(m_Instance, m_Messenger, m_AllocationCallbackPtr);
		}

		if (m_OwnsNativeObjects)
		{
			vkDestroyDevice(m_Device, m_AllocationCallbackPtr);
			vkDestroyInstance(m_Instance, m_AllocationCallbackPtr);
		}
		// todo sed: VulkanNative.Shutdown()
	}

	public static implicit operator VkDevice(Self self) => self.m_Device;

	public static implicit  operator VkPhysicalDevice(Self self) => self.m_PhysicalDevices.Front;

	public static implicit  operator VkInstance(Self self) => self.m_Instance;

	public VkAllocationCallbacks* GetAllocationCallbacks() => m_AllocationCallbackPtr;
	public readonly ref uint32[COMMAND_QUEUE_TYPE_NUM] GetQueueFamilyIndices() => ref m_FamilyIndices;
	public readonly ref SPIRVBindingOffsets GetSPIRVBindingOffsets() => ref m_SPIRVBindingOffsets;

	private PFN_vkAllocationFunction allocationFunc = => vkAllocateHostMemory;
	private PFN_vkReallocationFunction reallocFunc = => vkReallocateHostMemory;
	private PFN_vkFreeFunction freeFunc = => vkFreeHostMemory;
	private PFN_vkInternalAllocationNotification internalAllocNotificationFunc = => vkHostMemoryInternalAllocationNotification;
	private PFN_vkInternalFreeNotification internalFreeNotificationFunc = => vkHostMemoryInternalFreeNotification;

	public Result Create(DeviceCreationVulkanDesc deviceCreationVulkanDesc)
	{
		m_OwnsNativeObjects = false;

		m_Instance = (VkInstance)deviceCreationVulkanDesc.vkInstance;

		readonly VkPhysicalDevice* physicalDevices = (VkPhysicalDevice*)deviceCreationVulkanDesc.vkPhysicalDevices;
		m_PhysicalDevices.Insert(0, Span<VkPhysicalDevice>(physicalDevices, deviceCreationVulkanDesc.deviceGroupSize));

		m_Device = (VkDevice)deviceCreationVulkanDesc.vkDevice;

		/*
		m_AllocationCallbacks.pUserData = Internal.UnsafeCastToPtr(GetAllocator());
		m_AllocationCallbacks.pfnAllocation = allocationFunc;
		m_AllocationCallbacks.pfnReallocation = reallocFunc;
		m_AllocationCallbacks.pfnFree = freeFunc;
		m_AllocationCallbacks.pfnInternalAllocation = internalAllocNotificationFunc;
		m_AllocationCallbacks.pfnInternalFree = internalFreeNotificationFunc;*/

		//if (deviceCreationVulkanDesc.enableAPIValidation)
		//	m_AllocationCallbackPtr = &m_AllocationCallbacks;

		char8* loaderPath = deviceCreationVulkanDesc.vulkanLoaderPath;

		if (VulkanNative.Initialize(scope String(loaderPath)) case .Err)
		{
			REPORT_ERROR(GetLogger(), "Failed to initialize Vulkan.");
			return .FAILURE;
		}

		VulkanNative.SetLoadFunctionErrorCallBack(new (functionName) =>
			{
				GetLogger().ReportMessage(.TYPE_ERROR, scope $"Failed to load function: '{functionName}'.");
			});

		List<char8*> extensions = Allocate!<List<char8*>>(GetAllocator());
		defer
		{
			Deallocate!(GetAllocator(), extensions);
		}
		extensions.AddRange(Span<char8*>(deviceCreationVulkanDesc.instanceExtensions,  deviceCreationVulkanDesc.instanceExtensionNum));

		CheckSupportedInstanceExtensions(extensions);

		extensions.Clear();
		extensions.AddRange(Span<char8*>(deviceCreationVulkanDesc.deviceExtensions, deviceCreationVulkanDesc.deviceExtensionNum));

		CheckSupportedDeviceExtensions(extensions);

		Result res = ResolvePreInstanceDispatchTable();
		if (res != Result.SUCCESS)
			return res;

		res = ResolveInstanceDispatchTable();
		if (res != Result.SUCCESS)
			return res;

		vkGetPhysicalDeviceMemoryProperties(m_PhysicalDevices.Front, &m_MemoryProps);

		FillFamilyIndices(true, deviceCreationVulkanDesc.queueFamilyIndices, deviceCreationVulkanDesc.queueFamilyIndexNum);
		CreateCommandQueues();

		res = ResolveDispatchTable();
		if (res != Result.SUCCESS)
			return res;

		SetDeviceLimits(deviceCreationVulkanDesc.enableAPIValidation);

		if (deviceCreationVulkanDesc.enableAPIValidation)
			ReportDeviceGroupInfo();

		m_SPIRVBindingOffsets = deviceCreationVulkanDesc.spirvBindingOffsets;

		m_IsConcurrentSharingModeEnabledForBuffers = m_IsConcurrentSharingModeEnabledForBuffers && m_ConcurrentSharingModeQueueIndices.Count > 1;
		m_IsConcurrentSharingModeEnabledForImages = m_IsConcurrentSharingModeEnabledForImages && m_ConcurrentSharingModeQueueIndices.Count > 1;

		return res;
	}

	public Result Create(DeviceCreationDesc deviceCreationDesc)
	{
		m_OwnsNativeObjects = true;

		/*m_AllocationCallbacks.pUserData = Internal.UnsafeCastToPtr(GetAllocator());
		m_AllocationCallbacks.pfnAllocation = allocationFunc;
		m_AllocationCallbacks.pfnReallocation = reallocFunc;
		m_AllocationCallbacks.pfnFree = freeFunc;
		m_AllocationCallbacks.pfnInternalAllocation = internalAllocNotificationFunc;
		m_AllocationCallbacks.pfnInternalFree = internalFreeNotificationFunc;*/

		//if (deviceCreationDesc.enableAPIValidation)
		//	m_AllocationCallbackPtr = &m_AllocationCallbacks;

		if (VulkanNative.Initialize() case .Err)
		{
			REPORT_ERROR(GetLogger(), "Failed to initialize Vulkan.");
			return .FAILURE;
		}

		VulkanNative.SetLoadFunctionErrorCallBack(new (functionName) =>
			{
				GetLogger().ReportMessage(.TYPE_ERROR, "Failed to load function: '{0}'.", functionName);
			});

		Result res = ResolvePreInstanceDispatchTable();
		if (res != Result.SUCCESS)
			return res;

		res = CreateInstance(deviceCreationDesc);
		if (res != Result.SUCCESS)
			return res;

		VulkanNative.SetInstance(m_Instance);

		res = ResolveInstanceDispatchTable();
		if (res != Result.SUCCESS)
			return res;

		res = FindPhysicalDeviceGroup(deviceCreationDesc.physicalDeviceGroup, deviceCreationDesc.enableMGPU);
		if (res != Result.SUCCESS)
			return res;

		vkGetPhysicalDeviceMemoryProperties(m_PhysicalDevices.Front, &m_MemoryProps);
		FillFamilyIndices(false, null, 0);

		res = CreateLogicalDevice(deviceCreationDesc);
		if (res != Result.SUCCESS)
			return res;

		RetrieveRayTracingInfo();
		RetrieveMeshShaderInfo();
		CreateCommandQueues();

		res = ResolveDispatchTable();
		if (res != Result.SUCCESS)
			return res;

		SetDeviceLimits(deviceCreationDesc.enableAPIValidation);

		readonly uint32 groupSize = m_DeviceDesc.phyiscalDeviceGroupSize;
		m_PhysicalDeviceIndices.Resize(groupSize * groupSize);
		for (int i = 0; i < m_PhysicalDeviceIndices.Count; i++)
		{
			m_PhysicalDeviceIndices[i] = (uint32)(i / (int)groupSize);
		}

		if (deviceCreationDesc.enableAPIValidation)
			ReportDeviceGroupInfo();

		m_SPIRVBindingOffsets = deviceCreationDesc.spirvBindingOffsets;

		m_IsConcurrentSharingModeEnabledForBuffers = m_IsConcurrentSharingModeEnabledForBuffers && m_ConcurrentSharingModeQueueIndices.Count > 1;
		m_IsConcurrentSharingModeEnabledForImages = m_IsConcurrentSharingModeEnabledForImages && m_ConcurrentSharingModeQueueIndices.Count > 1;

		return res;
	}


	public bool GetMemoryType(MemoryLocation memoryLocation, uint32 memoryTypeMask, ref MemoryTypeInfo memoryTypeInfo)
	{
		readonly VkMemoryPropertyFlags host = .VK_MEMORY_PROPERTY_HOST_COHERENT_BIT | .VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT;

		VkMemoryPropertyFlags hostUnwantedFlags =
			(memoryLocation == MemoryLocation.HOST_READBACK) ? .VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT : 0;

		readonly VkMemoryPropertyFlags device = .VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT;
		readonly VkMemoryPropertyFlags deviceUnwantedFlags = 0;

		VkMemoryPropertyFlags flags = IsHostVisibleMemory(memoryLocation) ? host : device;
		VkMemoryPropertyFlags unwantedFlags = IsHostVisibleMemory(memoryLocation) ? hostUnwantedFlags : deviceUnwantedFlags;

		memoryTypeInfo.isHostCoherent = IsHostVisibleMemory(memoryLocation) ? 1 : 0;

		memoryTypeInfo.location = (uint8)memoryLocation;
		Compiler.Assert((uint32)MemoryLocation.MAX_NUM <= uint8.MaxValue, "Unexpected number of memory locations");

		for (uint16 i = 0; i < m_MemoryProps.memoryTypeCount; i++)
		{
			readonly bool isMemoryTypeSupported = memoryTypeMask & (1 << i) != 0;
			readonly bool isPropSupported = (m_MemoryProps.memoryTypes[i].propertyFlags & flags) == flags;
			readonly bool hasUnwantedProperties = (m_MemoryProps.memoryTypes[i].propertyFlags & unwantedFlags) == 0;

			if (isMemoryTypeSupported && isPropSupported && !hasUnwantedProperties)
			{
				memoryTypeInfo.memoryTypeIndex = (uint16)i;
				return true;
			}
		}

		// ignore unwanted properties
		for (uint16 i = 0; i < m_MemoryProps.memoryTypeCount; i++)
		{
			readonly bool isMemoryTypeSupported = memoryTypeMask & (1 << i) != 0;
			readonly bool isPropSupported = (m_MemoryProps.memoryTypes[i].propertyFlags & flags) == flags;

			if (isMemoryTypeSupported && isPropSupported)
			{
				memoryTypeInfo.memoryTypeIndex = (uint16)i;
				return true;
			}
		}

		return false;
	}

	public bool GetMemoryType(uint32 index, ref MemoryTypeInfo memoryTypeInfo)
	{
		if (index >= m_MemoryProps.memoryTypeCount)
			return false;

		readonly ref VkMemoryType memoryType = ref m_MemoryProps.memoryTypes[index];

		memoryTypeInfo.memoryTypeIndex = (uint16)index;
		memoryTypeInfo.isHostCoherent = memoryType.propertyFlags.HasFlag(.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT) ? 1 : 0;

		readonly bool isHostVisible = memoryType.propertyFlags.HasFlag(.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT);
		memoryTypeInfo.location = isHostVisible ? (uint8)MemoryLocation.HOST_UPLOAD : (uint8)MemoryLocation.DEVICE;
		Compiler.Assert((uint32)MemoryLocation.MAX_NUM <= uint8.MaxValue, "Unexpected number of memory locations");

		return true;
	}

	public uint32 GetPhyiscalDeviceGroupSize() => m_DeviceDesc.phyiscalDeviceGroupSize;
	public bool IsDescriptorIndexingExtSupported() => m_IsDescriptorIndexingExtSupported;
	public bool IsConcurrentSharingModeEnabledForBuffers() => m_IsConcurrentSharingModeEnabledForBuffers;
	public bool IsConcurrentSharingModeEnabledForImages() => m_IsConcurrentSharingModeEnabledForImages;
	public bool IsBufferDeviceAddressSupported() => m_IsBufferDeviceAddressSupported;
	public readonly ref List<uint32> GetConcurrentSharingModeQueueIndices() => ref m_ConcurrentSharingModeQueueIndices;

	public NRIVkPhysicalDevice GetVkPhysicalDevice()
	{
	    return (VkPhysicalDevice)((DeviceVK)this);
	}

	public NRIVkInstance GetVkInstance()
	{
	    return (VkInstance)((DeviceVK)this);
	}

	public void SetDebugNameToTrivialObject(VkObjectType objectType, uint64 handle, char8* name)
	{
		if (VulkanNative.[Friend]vkSetDebugUtilsObjectNameEXT_ptr == null)
			return;

		VkDebugUtilsObjectNameInfoEXT info = .()
			{
				sType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_NAME_INFO_EXT,
				pNext = null,
				objectType = objectType,
				objectHandle = (uint64)handle,
				pObjectName = name
			};

		readonly VkResult result = VulkanNative.vkSetDebugUtilsObjectNameEXT(m_Device, &info);

		RETURN_ON_FAILURE!(GetLogger(), result == .VK_SUCCESS, void(),
			"Can't set a debug name to an object: vkSetDebugUtilsObjectNameEXT returned {0}.", (int32)result);
	}
	public void SetDebugNameToDeviceGroupObject(VkObjectType objectType, uint64* handles, char8* name)
	{
		if (VulkanNative.[Friend]vkSetDebugUtilsObjectNameEXT_ptr == null)
			return;

		VkDebugUtilsObjectNameInfoEXT info = .()
			{
				sType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_NAME_INFO_EXT,
				pNext = null,
				objectType = objectType,
				objectHandle = (uint64)0
			};

		for (uint32 i = 0; i < m_DeviceDesc.phyiscalDeviceGroupSize; i++)
		{
			if (handles[i] != 0)
			{
				String nameWithDeviceIndex = scope String(name)..AppendF("{0}", i);

				info.objectHandle = (uint64)handles[i];
				info.pObjectName = nameWithDeviceIndex.Ptr;

				readonly VkResult result = VulkanNative.vkSetDebugUtilsObjectNameEXT(m_Device, &info);
				RETURN_ON_FAILURE!(GetLogger(), result == .VK_SUCCESS, void(),
					"Can't set a debug name to an object: vkSetDebugUtilsObjectNameEXT returned {0}.", (int32)result);
			}
		}
	}

	public DeviceLogger GetLogger()
	{
		return m_Logger;
	}

	public DeviceAllocator<uint8> GetAllocator()
	{
		return m_Allocator;
	}

	public void SetDebugName(char8* name)
	{
		SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_DEVICE, (uint64)m_Device, name);
	}

	public void* GetDeviceNativeObject()
	{
	    return (VkDevice)((DeviceVK)this);
	}

	public ref DeviceDesc GetDesc()
	{
		return ref m_DeviceDesc;
	}

	public Result GetCommandQueue(CommandQueueType commandQueueType, out CommandQueue commandQueue)
	{
		commandQueue = ?;
		using (m_Lock.Enter())
		{
			if (m_FamilyIndices[(uint32)commandQueueType] == uint32.MaxValue)
				return Result.UNSUPPORTED;

			commandQueue = (CommandQueue)m_Queues[(uint32)commandQueueType];
			return Result.SUCCESS;
		}
	}

	public Result CreateCommandAllocator(CommandQueue commandQueue, uint32 physicalDeviceMask, out CommandAllocator commandAllocator)
	{
		return CreateImplementation<CommandAllocatorVK...>(out commandAllocator, commandQueue, physicalDeviceMask);
	}

	public Result CreateDescriptorPool(DescriptorPoolDesc descriptorPoolDesc, out DescriptorPool descriptorPool)
	{
		return CreateImplementation<DescriptorPoolVK...>(out descriptorPool, descriptorPoolDesc);
	}

	public Result CreateBuffer(BufferDesc bufferDesc, out Buffer buffer)
	{
		return CreateImplementation<BufferVK...>(out buffer, bufferDesc);
	}

	public Result CreateTexture(TextureDesc textureDesc, out Texture texture)
	{
		return CreateImplementation<TextureVK...>(out texture, textureDesc);
	}

	public Result CreateBufferView(BufferViewDesc bufferViewDesc, out Descriptor bufferView)
	{
		return CreateImplementation<DescriptorVK...>(out bufferView, bufferViewDesc);
	}

	public Result CreateTexture1DView(Texture1DViewDesc textureViewDesc, out Descriptor textureView)
	{
		return CreateImplementation<DescriptorVK...>(out textureView, textureViewDesc);
	}

	public Result CreateTexture2DView(Texture2DViewDesc textureViewDesc, out Descriptor textureView)
	{
		return CreateImplementation<DescriptorVK...>(out textureView, textureViewDesc);
	}

	public Result CreateTexture3DView(Texture3DViewDesc textureViewDesc, out Descriptor textureView)
	{
		return CreateImplementation<DescriptorVK...>(out textureView, textureViewDesc);
	}

	public Result CreateSampler(SamplerDesc samplerDesc, out Descriptor sampler)
	{
		return CreateImplementation<DescriptorVK...>(out sampler, samplerDesc);
	}

	public Result CreatePipelineLayout(PipelineLayoutDesc pipelineLayoutDesc, out PipelineLayout pipelineLayout)
	{
		return CreateImplementation<PipelineLayoutVK...>(out pipelineLayout, pipelineLayoutDesc);
	}

	public Result CreateGraphicsPipeline(GraphicsPipelineDesc graphicsPipelineDesc, out Pipeline pipeline)
	{
		return CreateImplementation<PipelineVK...>(out pipeline, graphicsPipelineDesc);
	}

	public Result CreateComputePipeline(ComputePipelineDesc computePipelineDesc, out Pipeline pipeline)
	{
		return CreateImplementation<PipelineVK...>(out pipeline, computePipelineDesc);
	}

	public Result CreateFrameBuffer(FrameBufferDesc frameBufferDesc, out FrameBuffer frameBuffer)
	{
		return CreateImplementation<FrameBufferVK...>(out frameBuffer, frameBufferDesc);
	}

	public Result CreateQueryPool(QueryPoolDesc queryPoolDesc, out QueryPool queryPool)
	{
		return CreateImplementation<QueryPoolVK...>(out queryPool, queryPoolDesc);
	}

	public Result CreateQueueSemaphore(out QueueSemaphore queueSemaphore)
	{
		return CreateImplementation<QueueSemaphoreVK...>(out queueSemaphore);
	}

	public Result CreateDeviceSemaphore(bool signaled, out DeviceSemaphore deviceSemaphore)
	{
		return CreateImplementation<DeviceSemaphoreVK...>(out deviceSemaphore, signaled);
	}

	public Result CreateCommandBuffer(CommandAllocator commandAllocator, out CommandBuffer commandBuffer)
	{
		return commandAllocator.CreateCommandBuffer(out commandBuffer);
	}

	public Result CreateSwapChain(SwapChainDesc swapChainDesc, out SwapChain swapChain)
	{
		return CreateImplementation<SwapChainVK...>(out swapChain, swapChainDesc);
	}

	public Result CreateRayTracingPipeline(RayTracingPipelineDesc rayTracingPipelineDesc, out Pipeline pipeline)
	{
		return CreateImplementation<PipelineVK...>(out pipeline, rayTracingPipelineDesc);
	}

	public Result CreateAccelerationStructure(AccelerationStructureDesc accelerationStructureDesc, out AccelerationStructure accelerationStructure)
	{
		return CreateImplementation<AccelerationStructureVK...>(out accelerationStructure, accelerationStructureDesc);
	}

	public Result CreateCommandQueue(CommandQueueVulkanDesc commandQueueVulkanDesc, out CommandQueue commandQueue)
	{
		readonly uint32 commandQueueTypeIndex = (uint32)commandQueueVulkanDesc.commandQueueType;

		m_Lock.Enter();
		defer m_Lock.Exit();

		readonly bool isFamilyIndexSame = m_FamilyIndices[commandQueueTypeIndex] == commandQueueVulkanDesc.familyIndex;
		readonly bool isQueueSame = (VkQueue)m_Queues[commandQueueTypeIndex] == (VkQueue)commandQueueVulkanDesc.vkQueue;
		if (isFamilyIndexSame && isQueueSame)
		{
			commandQueue = (CommandQueue)m_Queues[commandQueueTypeIndex];
			return Result.SUCCESS;
		}

		CreateImplementation<CommandQueueVK...>(out commandQueue, commandQueueVulkanDesc);

		if (m_Queues[commandQueueTypeIndex] != null)
			Deallocate!(GetAllocator(), m_Queues[commandQueueTypeIndex]);

		m_FamilyIndices[commandQueueTypeIndex] = commandQueueVulkanDesc.familyIndex;
		m_Queues[commandQueueTypeIndex] = (CommandQueueVK)commandQueue;

		return Result.SUCCESS;
	}

	public Result CreateCommandAllocator(CommandAllocatorVulkanDesc commandAllocatorVulkanDesc, out CommandAllocator commandAllocator)
	{
		return CreateImplementation<CommandAllocatorVK...>(out commandAllocator, commandAllocatorVulkanDesc);
	}

	public Result CreateCommandBuffer(CommandBufferVulkanDesc commandBufferVulkanDesc, out CommandBuffer commandBuffer)
	{
		return CreateImplementation<CommandBufferVK...>(out commandBuffer, commandBufferVulkanDesc);
	}

	public Result CreateDescriptorPool(NRIVkDescriptorPool vkDescriptorPool, out DescriptorPool descriptorPool)
	{
		return CreateImplementation<DescriptorPoolVK...>(out descriptorPool, vkDescriptorPool);
	}

	public Result CreateBuffer(BufferVulkanDesc bufferDesc, out Buffer buffer)
	{
		return CreateImplementation<BufferVK...>(out buffer, bufferDesc);
	}

	public Result CreateTexture(TextureVulkanDesc textureVulkanDesc, out Texture texture)
	{
		return CreateImplementation<TextureVK...>(out texture, textureVulkanDesc);
	}

	public Result CreateMemory(MemoryVulkanDesc memoryVulkanDesc, out Memory memory)
	{
		return CreateImplementation<MemoryVK...>(out memory, memoryVulkanDesc);
	}

	public Result CreateGraphicsPipeline(NRIVkPipeline vkPipeline, out Pipeline pipeline)
	{
		pipeline = ?;
		PipelineVK implementation = Allocate!<PipelineVK>(GetAllocator(), this);
		readonly Result result = implementation.CreateGraphics(vkPipeline);

		if (result != Result.SUCCESS)
		{
			pipeline = (Pipeline)implementation;
			return result;
		}

		Deallocate!(GetAllocator(), implementation);

		return result;
	}

	public Result CreateComputePipeline(NRIVkPipeline vkPipeline, out Pipeline pipeline)
	{
		pipeline = ?;
		PipelineVK implementation = Allocate!<PipelineVK>(GetAllocator(), this);
		readonly Result result = implementation.CreateCompute(vkPipeline);

		if (result != Result.SUCCESS)
		{
			pipeline = (Pipeline)implementation;
			return result;
		}

		Deallocate!(GetAllocator(), implementation);

		return result;
	}

	public Result CreateQueryPool(QueryPoolVulkanDesc queryPoolVulkanDesc, out QueryPool queryPool)
	{
		return CreateImplementation<QueryPoolVK...>(out queryPool, queryPoolVulkanDesc);
	}

	public Result CreateQueueSemaphore(NRIVkSemaphore vkSemaphore, out QueueSemaphore queueSemaphore)
	{
		return CreateImplementation<QueueSemaphoreVK...>(out queueSemaphore, vkSemaphore);
	}

	public Result CreateDeviceSemaphore(NRIVkFence vkFence, out DeviceSemaphore deviceSemaphore)
	{
		return CreateImplementation<DeviceSemaphoreVK...>(out deviceSemaphore, vkFence);
	}

	public void DestroyCommandAllocator(CommandAllocator commandAllocator)
	{
		Deallocate!(GetAllocator(), (CommandAllocatorVK)commandAllocator);
	}

	public void DestroyDescriptorPool(DescriptorPool descriptorPool)
	{
		Deallocate!(GetAllocator(), (DescriptorPoolVK)descriptorPool);
	}

	public void DestroyBuffer(Buffer buffer)
	{
		Deallocate!(GetAllocator(), (BufferVK)buffer);
	}

	public void DestroyTexture(Texture texture)
	{
		Deallocate!(GetAllocator(), (TextureVK)texture);
	}

	public void DestroyDescriptor(Descriptor descriptor)
	{
		Deallocate!(GetAllocator(), (DescriptorVK)descriptor);
	}

	public void DestroyPipelineLayout(PipelineLayout pipelineLayout)
	{
		Deallocate!(GetAllocator(), (PipelineLayoutVK)pipelineLayout);
	}

	public void DestroyPipeline(Pipeline pipeline)
	{
		Deallocate!(GetAllocator(), (PipelineVK)pipeline);
	}

	public void DestroyFrameBuffer(FrameBuffer frameBuffer)
	{
		Deallocate!(GetAllocator(), (FrameBufferVK)frameBuffer);
	}

	public void DestroyQueryPool(QueryPool queryPool)
	{
		Deallocate!(GetAllocator(), (QueryPoolVK)queryPool);
	}

	public void DestroyQueueSemaphore(QueueSemaphore queueSemaphore)
	{
		Deallocate!(GetAllocator(), (QueueSemaphoreVK)queueSemaphore);
	}

	public void DestroyDeviceSemaphore(DeviceSemaphore deviceSemaphore)
	{
		Deallocate!(GetAllocator(), (DeviceSemaphoreVK)deviceSemaphore);
	}

	public void DestroyCommandBuffer(CommandBuffer commandBuffer)
	{
		Deallocate!(GetAllocator(), (CommandBufferVK)commandBuffer);
	}

	public void DestroySwapChain(SwapChain swapChain)
	{
		Deallocate!(GetAllocator(), (SwapChainVK)swapChain);
	}

	public void DestroyAccelerationStructure(AccelerationStructure accelerationStructure)
	{
		Deallocate!(GetAllocator(), (AccelerationStructureVK)accelerationStructure);
	}

	public Result GetDisplays(Display** displays, ref uint32 displayNum)
	{
		return Result.UNSUPPORTED;
	}

	public Result GetDisplaySize(ref Display display, ref uint16 width, ref uint16 height)
	{
		return Result.UNSUPPORTED;
	}

	public Result AllocateMemory(uint32 physicalDeviceMask, uint32 memoryType, uint64 size, out Memory memory)
	{
		return CreateImplementation<MemoryVK...>(out memory, physicalDeviceMask, memoryType, size);
	}

	public Result BindBufferMemory(BufferMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
	{
		if (memoryBindingDescNum == 0)
			return Result.SUCCESS;

		readonly uint32 infoMaxNum = memoryBindingDescNum * m_DeviceDesc.phyiscalDeviceGroupSize;

		VkBindBufferMemoryInfo* infos = STACK_ALLOC!<VkBindBufferMemoryInfo>(infoMaxNum);
		uint32 infoNum = 0;

		VkBindBufferMemoryDeviceGroupInfo* deviceGroupInfos = null;
		if (m_DeviceDesc.phyiscalDeviceGroupSize > 1)
			deviceGroupInfos = STACK_ALLOC!<VkBindBufferMemoryDeviceGroupInfo>(infoMaxNum);

		for (uint32 i = 0; i < memoryBindingDescNum; i++)
		{
			readonly ref BufferMemoryBindingDesc bindingDesc = ref memoryBindingDescs[i];

			MemoryVK memoryImpl = (MemoryVK)bindingDesc.memory;
			BufferVK bufferImpl = (BufferVK)bindingDesc.buffer;

			readonly MemoryTypeUnpack unpack = .() { type = memoryImpl.GetMemoryType() };
			readonly ref MemoryTypeInfo memoryTypeInfo = ref unpack.info;

			readonly MemoryLocation memoryLocation = (MemoryLocation)memoryTypeInfo.location;

			uint32 physicalDeviceMask = GetPhysicalDeviceGroupMask(bindingDesc.physicalDeviceMask);
			if (IsHostVisibleMemory(memoryLocation))
				physicalDeviceMask = 0x1;

			if (memoryTypeInfo.isDedicated == 1)
				memoryImpl.CreateDedicated(bufferImpl, physicalDeviceMask);

			for (uint32 j = 0; j < m_DeviceDesc.phyiscalDeviceGroupSize; j++)
			{
				if ((1 << j) & physicalDeviceMask != 0)
				{
					ref VkBindBufferMemoryInfo info = ref infos[infoNum++];

					info = .();
					info.sType = .VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_INFO;
					info.buffer = bufferImpl.GetHandle(j);
					info.memory = memoryImpl.GetHandle(j);
					info.memoryOffset = bindingDesc.offset;

					if (IsHostVisibleMemory(memoryLocation))
						bufferImpl.SetHostMemory(memoryImpl, info.memoryOffset);

					if (deviceGroupInfos != null)
					{
						ref VkBindBufferMemoryDeviceGroupInfo deviceGroupInfo = ref deviceGroupInfos[infoNum - 1];
						deviceGroupInfo = .();
						deviceGroupInfo.sType = .VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_DEVICE_GROUP_INFO;
						deviceGroupInfo.deviceIndexCount = m_DeviceDesc.phyiscalDeviceGroupSize;
						deviceGroupInfo.pDeviceIndices = &m_PhysicalDeviceIndices[j * m_DeviceDesc.phyiscalDeviceGroupSize];
						info.pNext = &deviceGroupInfo;
					}
				}
			}
		}

		VkResult result = .VK_SUCCESS;
		if (infoNum > 0)
			result = VulkanNative.vkBindBufferMemory2(m_Device, infoNum, infos);

		RETURN_ON_FAILURE!(GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't bind a memory to a buffer: vkBindBufferMemory2 returned {0}.", (int32)result);

		for (uint32 i = 0; i < memoryBindingDescNum; i++)
		{
			BufferVK bufferImpl = (BufferVK)memoryBindingDescs[i].buffer;
			bufferImpl.ReadDeviceAddress();
		}

		return Result.SUCCESS;
	}

	public Result BindTextureMemory(TextureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
	{
		readonly uint32 infoMaxNum = memoryBindingDescNum * m_DeviceDesc.phyiscalDeviceGroupSize;

		VkBindImageMemoryInfo* infos = STACK_ALLOC!<VkBindImageMemoryInfo>(infoMaxNum);
		uint32 infoNum = 0;

		VkBindImageMemoryDeviceGroupInfo* deviceGroupInfos = null;
		if (m_DeviceDesc.phyiscalDeviceGroupSize > 1)
			deviceGroupInfos = STACK_ALLOC!<VkBindImageMemoryDeviceGroupInfo>(infoMaxNum);

		for (uint32 i = 0; i < memoryBindingDescNum; i++)
		{
			readonly ref TextureMemoryBindingDesc bindingDesc = ref memoryBindingDescs[i];

			readonly uint32 physicalDeviceMask = GetPhysicalDeviceGroupMask(bindingDesc.physicalDeviceMask);

			MemoryVK memoryImpl = (MemoryVK)bindingDesc.memory;
			TextureVK textureImpl = (TextureVK)bindingDesc.texture;

			readonly MemoryTypeUnpack unpack = .() { type = memoryImpl.GetMemoryType() };
			readonly ref MemoryTypeInfo memoryTypeInfo = ref unpack.info;

			if (memoryTypeInfo.isDedicated == 1)
				memoryImpl.CreateDedicated(textureImpl, physicalDeviceMask);

			for (uint32 j = 0; j < m_DeviceDesc.phyiscalDeviceGroupSize; j++)
			{
				if ((1 << j) & physicalDeviceMask != 0)
				{
					ref VkBindImageMemoryInfo info = ref infos[infoNum++];
					info.sType = .VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_INFO;
					info.pNext = null;
					info.image = textureImpl.GetHandle(j);
					info.memory = memoryImpl.GetHandle(j);
					info.memoryOffset = bindingDesc.offset;

					if (deviceGroupInfos != null)
					{
						ref VkBindImageMemoryDeviceGroupInfo deviceGroupInfo = ref deviceGroupInfos[infoNum - 1];
						deviceGroupInfo = .();
						deviceGroupInfo.sType = .VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_DEVICE_GROUP_INFO;
						deviceGroupInfo.deviceIndexCount = m_DeviceDesc.phyiscalDeviceGroupSize;
						deviceGroupInfo.pDeviceIndices = &m_PhysicalDeviceIndices[j * m_DeviceDesc.phyiscalDeviceGroupSize];
						info.pNext = &deviceGroupInfo;
					}
				}
			}
		}

		VkResult result = .VK_SUCCESS;
		if (infoNum > 0)
			result = VulkanNative.vkBindImageMemory2(m_Device, infoNum, infos);

		RETURN_ON_FAILURE!(GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't bind a memory to a texture: vkBindImageMemory2 returned {0].", (int32)result);

		return Result.SUCCESS;
	}

	public Result BindAccelerationStructureMemory(AccelerationStructureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
	{
		if (memoryBindingDescNum == 0)
			return Result.SUCCESS;

		BufferMemoryBindingDesc* infos = ALLOCATE_SCRATCH!<BufferMemoryBindingDesc>(this, memoryBindingDescNum);

		for (uint32 i = 0; i < memoryBindingDescNum; i++)
		{
			readonly ref AccelerationStructureMemoryBindingDesc bindingDesc = ref memoryBindingDescs[i];
			AccelerationStructureVK accelerationStructure = (AccelerationStructureVK)bindingDesc.accelerationStructure;

			ref BufferMemoryBindingDesc bufferMemoryBinding = ref infos[i];
			bufferMemoryBinding = .();
			bufferMemoryBinding.buffer = (Buffer)accelerationStructure.GetBuffer();
			bufferMemoryBinding.memory = bindingDesc.memory;
			bufferMemoryBinding.offset = bindingDesc.offset;
			bufferMemoryBinding.physicalDeviceMask = bindingDesc.physicalDeviceMask;
		}

		Result result = BindBufferMemory(infos, memoryBindingDescNum);

		for (uint32 i = 0; i < memoryBindingDescNum && result == Result.SUCCESS; i++)
		{
			AccelerationStructureVK accelerationStructure = (AccelerationStructureVK)memoryBindingDescs[i].accelerationStructure;
			result = accelerationStructure.FinishCreation();
		}

		FREE_SCRATCH!(this, infos, memoryBindingDescNum);

		return result;
	}

	public void FreeMemory(Memory memory)
	{
		Deallocate!(GetAllocator(), (MemoryVK)memory);
	}

	public FormatSupportBits GetFormatSupport(Format format)
	{
		readonly VkFormat vulkanFormat = ConvertNRIFormatToVK(format);
		readonly VkPhysicalDevice physicalDevice = m_PhysicalDevices.Front;

		VkFormatProperties formatProperties = .();
		VulkanNative.vkGetPhysicalDeviceFormatProperties(physicalDevice, vulkanFormat, &formatProperties);

		const VkFormatFeatureFlags  transferBits = .VK_FORMAT_FEATURE_TRANSFER_DST_BIT | .VK_FORMAT_FEATURE_TRANSFER_SRC_BIT;

		const VkFormatFeatureFlags  textureBits = .VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT | transferBits;
		const VkFormatFeatureFlags  storageTextureBits = .VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT | transferBits;
		const VkFormatFeatureFlags  bufferBits = .VK_FORMAT_FEATURE_UNIFORM_TEXEL_BUFFER_BIT | transferBits;
		const VkFormatFeatureFlags  storageBufferBits = .VK_FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_BIT | transferBits;
		const VkFormatFeatureFlags  colorAttachmentBits = .VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT | .VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BLEND_BIT | transferBits;
		const VkFormatFeatureFlags  depthAttachmentBits = .VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT | transferBits;
		const VkFormatFeatureFlags  vertexBufferBits = .VK_FORMAT_FEATURE_VERTEX_BUFFER_BIT | transferBits;

		FormatSupportBits mask = FormatSupportBits.UNSUPPORTED;

		if (formatProperties.optimalTilingFeatures.HasFlag(textureBits))
			mask |= FormatSupportBits.TEXTURE;

		if (formatProperties.optimalTilingFeatures.HasFlag(storageTextureBits))
			mask |= FormatSupportBits.STORAGE_TEXTURE;

		if (formatProperties.optimalTilingFeatures.HasFlag(colorAttachmentBits))
			mask |= FormatSupportBits.COLOR_ATTACHMENT;

		if (formatProperties.optimalTilingFeatures.HasFlag(depthAttachmentBits))
			mask |= FormatSupportBits.DEPTH_STENCIL_ATTACHMENT;

		if (formatProperties.bufferFeatures.HasFlag(bufferBits))
			mask |= FormatSupportBits.BUFFER;

		if (formatProperties.bufferFeatures.HasFlag(storageBufferBits))
			mask |= FormatSupportBits.STORAGE_BUFFER;

		if (formatProperties.bufferFeatures.HasFlag(vertexBufferBits))
			mask |= FormatSupportBits.VERTEX_BUFFER;

		return mask;
	}

	public uint32 CalculateAllocationNumber(NRI.Helpers.ResourceGroupDesc resourceGroupDesc)
	{
		DeviceMemoryAllocatorHelper allocator = scope .(this, m_Allocator);

		return allocator.CalculateAllocationNumber(resourceGroupDesc);
	}

	public Result AllocateAndBindMemory(NRI.Helpers.ResourceGroupDesc resourceGroupDesc, Memory* allocations)
	{
		DeviceMemoryAllocatorHelper allocator = scope .(this, m_Allocator);

		return allocator.AllocateAndBindMemory(resourceGroupDesc, allocations);
	}

	public void SetSPIRVBindingOffsets(SPIRVBindingOffsets spirvBindingOffsets)
	{
		m_SPIRVBindingOffsets = spirvBindingOffsets;
	}

	public void Destroy()
	{
		Deallocate!(GetAllocator(), this);
	}
}

public static
{
	public static Result CreateDeviceVK(DeviceLogger logger, DeviceAllocator<uint8> allocator, DeviceCreationDesc deviceCreationDesc, out Device device)
	{
		device = ?;

		DeviceVK implementation = Allocate!<DeviceVK>(allocator, logger, allocator);

		readonly Result res = implementation.Create(deviceCreationDesc);

		if (res == Result.SUCCESS)
		{

			device = implementation;
			return Result.SUCCESS;
		}

		Deallocate!(allocator, implementation);
		return res;
	}

	public static Result CreateDeviceVK(DeviceLogger logger, DeviceAllocator<uint8> allocator, DeviceCreationVulkanDesc deviceCreationDesc, out Device device)
	{
		device = ?;

		DeviceVK implementation = Allocate!<DeviceVK>(allocator, logger, allocator);
		readonly Result res = implementation.Create(deviceCreationDesc);

		if (res == Result.SUCCESS)
		{
			device = implementation;
			return Result.SUCCESS;
		}

		Deallocate!(allocator, implementation);
		return res;
	}

	public static void DestroyDeviceVK(Device device)
	{
		DeviceVK implementation = (DeviceVK)device;

		implementation.Destroy();
	}
}