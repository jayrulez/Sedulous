using Bulkan;
using System.Collections;
using System;
namespace Sedulous.Renderer.VK.Internal;

static
{
	public const bool FORCE_MINOR_VERSION = false; // 0 for default version, otherwise minorVersion = (FORCE_MINOR_VERSION - 1)

	public const bool FORCE_ENABLE_VALIDATION  = false;
	public const bool FORCE_DISABLE_VALIDATION = true;

	//using List;

#if DEBUG /*> 0 && !FORCE_DISABLE_VALIDATION || FORCE_ENABLE_VALIDATION*/
	public const bool DISABLE_VALIDATION_ASSERTIONS = true; // 0 for default behavior, otherwise assertions will be disabled
	public static VkBool32 debugUtilsMessengerCallback(VkDebugUtilsMessageSeverityFlagsEXT messageSeverity,
		VkDebugUtilsMessageTypeFlagsEXT messageType,
		VkDebugUtilsMessengerCallbackDataEXT* callbackData,
		void* userData) {
		if (messageSeverity & .VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT != 0) {
			//CC_LOG_ERROR("%s: %s", callbackData.pMessageIdName, callbackData.pMessage);
			//CC_ASSERT(DISABLE_VALIDATION_ASSERTIONS);
			return VulkanNative.VK_FALSE;
		}
		if (messageSeverity & .VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT != 0) {
			//CC_LOG_WARNING("%s: %s", callbackData.pMessageIdName, callbackData.pMessage);
			return VulkanNative.VK_FALSE;
		}
		if (messageSeverity & .VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT != 0) {
			// CC_LOG_INFO("%s: %s", callbackData.pMessageIdName, callbackData.pMessage);
			return VulkanNative.VK_FALSE;
		}
		if (messageSeverity & .VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT != 0) {
			// CC_LOG_DEBUG("%s: %s", callbackData.pMessageIdName, callbackData.pMessage);
			return VulkanNative.VK_FALSE;
		}
		//CC_LOG_ERROR("%s: %s", callbackData.pMessageIdName, callbackData.pMessage);
		return VulkanNative.VK_FALSE;
	}

	public static VkBool32 debugReportCallback(VkDebugReportFlagsEXT flags,
		VkDebugReportObjectTypeEXT type,
		uint64 object,
		uint location,
		int32 messageCode,
		char8* layerPrefix,
		char8* message,
		void* userData) {
		if (flags & .VK_DEBUG_REPORT_ERROR_BIT_EXT != 0) {
			//CC_LOG_ERROR("%s: %s", layerPrefix, message);
			//CC_ASSERT(DISABLE_VALIDATION_ASSERTIONS);
			return VulkanNative.VK_FALSE;
		}
		if (flags & (.VK_DEBUG_REPORT_WARNING_BIT_EXT | .VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT) != 0) {
			//CC_LOG_WARNING("%s: %s", layerPrefix, message);
			return VulkanNative.VK_FALSE;
		}
		if (flags & .VK_DEBUG_REPORT_INFORMATION_BIT_EXT != 0) {
			// CC_LOG_INFO("%s: %s", layerPrefix, message);
			return VulkanNative.VK_FALSE;
		}
		if (flags & .VK_DEBUG_REPORT_DEBUG_BIT_EXT != 0) {
			// CC_LOG_DEBUG("%s: %s", layerPrefix, message);
			return VulkanNative.VK_FALSE;
		}
		//CC_LOG_ERROR("%s: %s", layerPrefix, message);
		return VulkanNative.VK_FALSE;
	} 
#endif
		}

typealias FN_vkDebugUtilsMessengerCallbackEXT = function VkBool32(VkDebugUtilsMessageSeverityFlagsEXT messageSeverity,
		VkDebugUtilsMessageTypeFlagsEXT messageType,
		VkDebugUtilsMessengerCallbackDataEXT* callbackData,
		void* userData);

typealias FN_vkDebugReportCallbackEXT = function VkBool32(VkDebugReportFlagsEXT flags,
VkDebugReportObjectTypeEXT type,
uint64 object,
uint location,
int32 messageCode,
char8* layerPrefix,
char8* message,
void* userData);

		class CCVKGPUContext {
		public bool initialize() {
				// only enable the absolute essentials
				List<char8*> requestedLayers = scope .(){
					//"VK_LAYER_KHRONOS_synchronization2",
				};
				List<char8*> requestedExtensions = scope .(){
					VulkanNative.VK_KHR_SURFACE_EXTENSION_NAME,
				};

				///////////////////// Instance Creation /////////////////////

				if (VulkanNative.Initialize() case .Ok) {
					return false;
				}
			VulkanNative.LoadPreInstanceFunctions();

				uint32 apiVersion = VulkanNative.VK_API_VERSION_1_0;
				if (VulkanNative.[Friend]vkEnumerateInstanceVersion_ptr != null) {
					VulkanNative.vkEnumerateInstanceVersion(&apiVersion);
					if (FORCE_MINOR_VERSION) {
						uint32 force = FORCE_MINOR_VERSION ? 1 : 0;
						apiVersion = VulkanNative.VK_MAKE_API_VERSION(0, 1, force - 1, 0);
					}
				}

				//IXRInterface* xr = CC_GET_XR_INTERFACE();
				//if (xr) apiVersion = xr.getXRVkApiVersion(apiVersion);
				minorVersion = VulkanNative.VK_API_VERSION_MINOR(apiVersion);
				if (minorVersion < 1) {
					requestedExtensions.Add(VulkanNative.VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME);
				}

				uint32 availableLayerCount = 0;
				VK_CHECK!(VulkanNative.vkEnumerateInstanceLayerProperties(&availableLayerCount, null));
				List<VkLayerProperties> supportedLayers = scope .(){Count=availableLayerCount};
				VK_CHECK!(VulkanNative.vkEnumerateInstanceLayerProperties(&availableLayerCount, supportedLayers.Ptr));

				uint32 availableExtensionCount = 0;
				VK_CHECK!(VulkanNative.vkEnumerateInstanceExtensionProperties(null, &availableExtensionCount, null));
				List<VkExtensionProperties> supportedExtensions = scope .(){Count=availableExtensionCount};
				VK_CHECK!(VulkanNative.vkEnumerateInstanceExtensionProperties(null, &availableExtensionCount, supportedExtensions.Ptr));

//#if defined(VK_USE_PLATFORM_ANDROID_KHR)
//				requestedExtensions.push_back(VK_KHR_ANDROID_SURFACE_EXTENSION_NAME);
//#elif defined(VK_USE_PLATFORM_WIN32_KHR)
				requestedExtensions.Add(VulkanNative.VK_KHR_WIN32_SURFACE_EXTENSION_NAME);
//#elif defined(VK_USE_PLATFORM_VI_NN)
//				requestedExtensions.push_back(VK_NN_VI_SURFACE_EXTENSION_NAME);
//#elif defined(VK_USE_PLATFORM_MACOS_MVK)
//				requestedExtensions.push_back(VK_MVK_MACOS_SURFACE_EXTENSION_NAME);
//				if (minorVersion >= 3) {
//					requestedExtensions.push_back("VK_KHR_portability_enumeration");
//					requestedExtensions.push_back("VK_KHR_portability_subset");
//				}
//#elif defined(VK_USE_PLATFORM_WAYLAND_KHR)
//				requestedExtensions.push_back(VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME);
//#elif defined(VK_USE_PLATFORM_XCB_KHR)
//				requestedExtensions.push_back(VK_KHR_XCB_SURFACE_EXTENSION_NAME);
//#else
//#pragma error Platform not supported
//#endif

#if DEBUG /*> 0 && !FORCE_DISABLE_VALIDATION || FORCE_ENABLE_VALIDATION*/
				// Determine the optimal validation layers to enable that are necessary for useful debugging
				List<List<char8*>> validationLayerPriorityList = scope .(){
					// The preferred validation layer is "VK_LAYER_KHRONOS_validation"
					scope :: .(){"VK_LAYER_KHRONOS_validation"},

					// Otherwise we fallback to using the LunarG meta layer
					scope :: .(){"VK_LAYER_LUNARG_standard_validation"},

					// Otherwise we attempt to enable the individual layers that compose the LunarG meta layer since it doesn't exist
					scope :: .(){
						"VK_LAYER_GOOGLE_threading",
						"VK_LAYER_LUNARG_parameter_validation",
						"VK_LAYER_LUNARG_object_tracker",
						"VK_LAYER_LUNARG_core_validation",
						"VK_LAYER_GOOGLE_unique_objects",
					},

					// Otherwise as a last resort we fallback to attempting to enable the LunarG core layer
					scope :: .() {"VK_LAYER_LUNARG_core_validation"},
				};
				for (List<char8*> validationLayers in validationLayerPriorityList) {
					bool found = true;
					for (char8* layer in validationLayers) {
						if (!isLayerSupported(layer, supportedLayers)) {
							found = false;
							break;
						}
					}
					if (found) {
						requestedLayers.AddRange(validationLayers);
						break;
					}
				}
#endif

#if DEBUG
				// Check if VK_EXT_debug_utils is supported, which supersedes VK_EXT_Debug_Report
				bool debugUtils = false;
				if (isExtensionSupported(VulkanNative.VK_EXT_DEBUG_UTILS_EXTENSION_NAME, supportedExtensions)) {
					debugUtils = true;
					requestedExtensions.Add(VulkanNative.VK_EXT_DEBUG_UTILS_EXTENSION_NAME);
				}
				else {
					requestedExtensions.Add(VulkanNative.VK_EXT_DEBUG_REPORT_EXTENSION_NAME);
				}
#endif

				// just filter out the unsupported layers & extensions
				for (char8* layer in requestedLayers) {
					if (isLayerSupported(layer, supportedLayers)) {
						layers.Add(layer);
					}
				}
				for (char8* @extension in requestedExtensions) {
					if (isExtensionSupported(@extension, supportedExtensions)) {
						extensions.Add(@extension);
					}
				}

				VkApplicationInfo app =.(){sType = .VK_STRUCTURE_TYPE_APPLICATION_INFO };
				app.pEngineName = "Cocos Creator";
				app.apiVersion = apiVersion;

				VkInstanceCreateInfo instanceInfo=.(){sType = .VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO };
//#if defined(VK_USE_PLATFORM_MACOS_MVK)
//				if (minorVersion >= 3) {
//					instanceInfo.flags |= 0x01; // VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
//				}
//#endif

				instanceInfo.pApplicationInfo = &app;
				instanceInfo.enabledExtensionCount = (uint32)extensions.Count;
				instanceInfo.ppEnabledExtensionNames = extensions.Ptr;
				instanceInfo.enabledLayerCount = (uint32)layers.Count;
				instanceInfo.ppEnabledLayerNames = layers.Ptr;

#if DEBUG /*> 0 && !FORCE_DISABLE_VALIDATION || FORCE_ENABLE_VALIDATION*/
				VkDebugUtilsMessengerCreateInfoEXT debugUtilsCreateInfo=.(){sType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT };
				VkDebugReportCallbackCreateInfoEXT debugReportCreateInfo=.(){sType = .VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT };
				if (debugUtils) {
					debugUtilsCreateInfo.messageSeverity = .VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT |
						.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
						.VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT |
						.VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT;
					debugUtilsCreateInfo.messageType = .VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | .VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | .VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;
					FN_vkDebugUtilsMessengerCallbackEXT fn = => debugUtilsMessengerCallback;
					debugUtilsCreateInfo.pfnUserCallback = fn;

					instanceInfo.pNext = &debugUtilsCreateInfo;
				}
				else {
					debugReportCreateInfo.flags = .VK_DEBUG_REPORT_ERROR_BIT_EXT |
						.VK_DEBUG_REPORT_WARNING_BIT_EXT |
						.VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT |
						.VK_DEBUG_REPORT_INFORMATION_BIT_EXT |
						.VK_DEBUG_REPORT_DEBUG_BIT_EXT;
					FN_vkDebugReportCallbackEXT fn = => debugReportCallback;
					debugReportCreateInfo.pfnCallback = fn;

					instanceInfo.pNext = &debugReportCreateInfo;
				}
#endif

				// Create the Vulkan instance
				//if (xr) {
				//	xr.initializeVulkanData(vkGetInstanceProcAddr);
				//	vkInstance = xr.createXRVulkanInstance(instanceInfo);
				//}
				//else
			{
					VkResult res = VulkanNative.vkCreateInstance(&instanceInfo, null, &vkInstance);
					if (res == .VK_ERROR_LAYER_NOT_PRESENT) {
						//CC_LOG_ERROR("Create Vulkan instance failed due to missing layers, aborting...");
						return false;
					}
				}
				VulkanNative.LoadInstanceFunctions(vkInstance, .Agnostic | .Win32); // todo: refactor this load method
			VulkanNative.LoadPostInstanceFunctions();

#if DEBUG /*> 0 && !FORCE_DISABLE_VALIDATION || FORCE_ENABLE_VALIDATION*/
				if (debugUtils) {
					VK_CHECK!(VulkanNative.vkCreateDebugUtilsMessengerEXT(vkInstance, &debugUtilsCreateInfo, null, &vkDebugUtilsMessenger));
				}
				else {
					VK_CHECK!(VulkanNative.vkCreateDebugReportCallbackEXT(vkInstance, &debugReportCreateInfo, null, &vkDebugReport));
				}
				validationEnabled = true;
#endif

				///////////////////// Physical Device Selection /////////////////////

				// Querying valid physical devices on the machine
				uint32 physicalDeviceCount = 0;
				VkResult res = VulkanNative.vkEnumeratePhysicalDevices(vkInstance, &physicalDeviceCount, null);

				if (res != .VK_SUCCESS || physicalDeviceCount < 1) {
					return false;
				}

				List<VkPhysicalDevice> physicalDeviceHandles = scope .() {Count=physicalDeviceCount};
				//if (xr) {
				//	physicalDeviceHandles[0] = xr.getXRVulkanGraphicsDevice();
				//}
				//else
			{
					VK_CHECK!(VulkanNative.vkEnumeratePhysicalDevices(vkInstance, &physicalDeviceCount, physicalDeviceHandles.Ptr));
				}

				List<VkPhysicalDeviceProperties> physicalDevicePropertiesList = scope .(){Count = physicalDeviceCount};

				uint32 deviceIndex = 0;
				for (deviceIndex = 0U; deviceIndex < physicalDeviceCount; ++deviceIndex) {
					ref VkPhysicalDeviceProperties properties = ref physicalDevicePropertiesList[deviceIndex];
					VulkanNative.vkGetPhysicalDeviceProperties(physicalDeviceHandles[deviceIndex], &properties);
				}

				for (deviceIndex = 0U; deviceIndex < physicalDeviceCount; ++deviceIndex) {
					ref VkPhysicalDeviceProperties properties = ref physicalDevicePropertiesList[deviceIndex];
					if (properties.deviceType == .VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU) {
						break;
					}
				}

				if (deviceIndex == physicalDeviceCount) {
					deviceIndex = 0;
				}

				physicalDevice = physicalDeviceHandles[deviceIndex];
				physicalDeviceProperties = physicalDevicePropertiesList[deviceIndex];
				VulkanNative.vkGetPhysicalDeviceFeatures(physicalDevice, &physicalDeviceFeatures);

				majorVersion = VulkanNative.VK_API_VERSION_MAJOR(physicalDeviceProperties.apiVersion);
				minorVersion = VulkanNative.VK_API_VERSION_MINOR(physicalDeviceProperties.apiVersion);

				if (minorVersion >= 1 || checkExtension(scope String(VulkanNative.VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME))) {
					physicalDeviceFeatures2.pNext = &physicalDeviceVulkan11Features;
					physicalDeviceVulkan11Features.pNext = &physicalDeviceVulkan12Features;
					physicalDeviceVulkan12Features.pNext = &physicalDeviceFragmentShadingRateFeatures;
					physicalDeviceProperties2.pNext = &physicalDeviceDepthStencilResolveProperties;
					//if (minorVersion >= 1) {
						VulkanNative.vkGetPhysicalDeviceProperties2(physicalDevice, &physicalDeviceProperties2);
						VulkanNative.vkGetPhysicalDeviceFeatures2(physicalDevice, &physicalDeviceFeatures2);
					//}
					//else {
					//	VulkanNative.vkGetPhysicalDeviceProperties2KHR(physicalDevice, &physicalDeviceProperties2);
					//	VulkanNative.vkGetPhysicalDeviceFeatures2KHR(physicalDevice, &physicalDeviceFeatures2);
					//}
				}

				VulkanNative.vkGetPhysicalDeviceMemoryProperties(physicalDevice, &physicalDeviceMemoryProperties);
				uint32 queueFamilyPropertiesCount = 0;
				VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyPropertiesCount, null);
				queueFamilyProperties.Resize(queueFamilyPropertiesCount);
				VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyPropertiesCount, queueFamilyProperties.Ptr);
				return true;
			}
			public void destroy() {
#if DEBUG /*> 0 && !FORCE_DISABLE_VALIDATION || FORCE_ENABLE_VALIDATION*/
				if (vkDebugUtilsMessenger != .Null) {
					VulkanNative.vkDestroyDebugUtilsMessengerEXT(vkInstance, vkDebugUtilsMessenger, null);
					vkDebugUtilsMessenger = .Null;
				}
				if (vkDebugReport != .Null) {
					VulkanNative.vkDestroyDebugReportCallbackEXT(vkInstance, vkDebugReport, null);
					vkDebugReport = .Null;
				}
#endif

				if (vkInstance != .Null) {
					VulkanNative.vkDestroyInstance(vkInstance, null);
					vkInstance = .Null;
				}
			}

			public VkInstance vkInstance = .Null;
			public VkDebugUtilsMessengerEXT vkDebugUtilsMessenger = .Null;
			public VkDebugReportCallbackEXT vkDebugReport = .Null;

			public VkPhysicalDevice physicalDevice = .Null;
			public VkPhysicalDeviceFeatures physicalDeviceFeatures = .();
			public VkPhysicalDeviceFeatures2 physicalDeviceFeatures2 = .(){ sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2 };
			public VkPhysicalDeviceVulkan11Features physicalDeviceVulkan11Features = .(){ sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES };
			public VkPhysicalDeviceVulkan12Features physicalDeviceVulkan12Features = .(){ sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES };
			public VkPhysicalDeviceFragmentShadingRateFeaturesKHR physicalDeviceFragmentShadingRateFeatures = .(){ sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_FEATURES_KHR };
			public VkPhysicalDeviceDepthStencilResolveProperties physicalDeviceDepthStencilResolveProperties = .(){ sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEPTH_STENCIL_RESOLVE_PROPERTIES };
			public VkPhysicalDeviceProperties physicalDeviceProperties = .();
			public VkPhysicalDeviceProperties2 physicalDeviceProperties2 = .(){ sType = .VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2 };
			public VkPhysicalDeviceMemoryProperties physicalDeviceMemoryProperties = .();
			public List<VkQueueFamilyProperties> queueFamilyProperties = new .() ~ delete _;

			public uint32 majorVersion = 0;
			public uint32 minorVersion = 0;

			public bool validationEnabled = false;
			public bool debugUtils = false;
			public bool debugReport = false;

			public List<char8*> layers = new .() ~ delete _;
			public List<char8*> extensions = new .() ~ delete _;

			[Inline] public bool checkExtension(char8* extensionToCheck) {
				return extensions.FindIndex(scope [&](ext)=> {
					return String.Equals(ext, extensionToCheck);
				}) != -1;
			}
		}