using System.Collections;
using Bulkan;
using System;
using System.Diagnostics;
namespace Sedulous.RAL.VK;

using static Bulkan.VulkanNative;

class VKInstance : Instance
{
	private VkInstance m_instance;
	private VkDebugReportCallbackEXT m_callback;
	private bool m_debug_utils_supported = false;

	public this()
	{
		VulkanNative.Initialize();
		VulkanNative.SetLoadFunctionErrorCallBack(scope (functionName) =>
			{
				Console.WriteLine(scope $"Failed to load function: '{functionName}'.");
			});
		VulkanNative.LoadPreInstanceFunctions();

		uint32 instanceLayerCount = 0;
		vkEnumerateInstanceLayerProperties(&instanceLayerCount, null);
		VkLayerProperties[] instanceLayerProperties = scope .[instanceLayerCount];
		vkEnumerateInstanceLayerProperties(&instanceLayerCount, instanceLayerProperties.Ptr);

		bool debugEnabled = Debug.IsDebuggerPresent;

		List<String> requestedInstanceLayers = scope .();

		if (debugEnabled)
		{
			requestedInstanceLayers.Add("VK_LAYER_KHRONOS_validation");
		}

		List<char8*> foundInstanceLayers = scope .();

		for (var properties in instanceLayerProperties)
		{
			String layerName = scope:: .(&properties.layerName);
			if (requestedInstanceLayers.Contains(layerName))
				foundInstanceLayers.Add(layerName);
		}

		uint32 instanceExtensionCount = 0;
		vkEnumerateInstanceExtensionProperties(null, &instanceExtensionCount, null);
		VkExtensionProperties[] instanceExtensionProperties = scope .[instanceExtensionCount];
		vkEnumerateInstanceExtensionProperties(null, &instanceExtensionCount, instanceExtensionProperties.Ptr);

		List<String> requestedInstanceExtensions = scope .()
			{
				scope .(VulkanNative.VK_EXT_DEBUG_REPORT_EXTENSION_NAME),
				scope .(VulkanNative.VK_KHR_SURFACE_EXTENSION_NAME),
				scope .(VulkanNative.VK_EXT_DEBUG_UTILS_EXTENSION_NAME),
				scope .(VulkanNative.VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME),
				scope .(VulkanNative.VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME)
			};

		if (OperatingSystem.IsWindows())
		{
			requestedInstanceExtensions.Add(scope .(VulkanNative.VK_KHR_WIN32_SURFACE_EXTENSION_NAME));
		}

		if (OperatingSystem.IsLinux())
		{
			requestedInstanceExtensions.Add(scope .(VulkanNative.VK_KHR_XCB_SURFACE_EXTENSION_NAME));
		}

		if (OperatingSystem.IsMacOS() || OperatingSystem.IsIOS())
		{
			requestedInstanceExtensions.Add(scope .(VulkanNative.VK_EXT_METAL_SURFACE_EXTENSION_NAME));
		}

		List<char8*> foundInstanceExtensions = scope .();

		VkInstanceCreateFlags flags = .None;

		for (var propeties in instanceExtensionProperties)
		{
			String extensionName = scope:: .();
			if (requestedInstanceExtensions.Contains(extensionName))
				foundInstanceExtensions.Add(extensionName);

			if (String.Equals(extensionName, VK_EXT_DEBUG_UTILS_EXTENSION_NAME))
			{
				m_debug_utils_supported = true;
			}

			if (String.Equals(extensionName, VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME))
			{
				flags = .VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
			}
		}

		VkApplicationInfo appCreateInfo = .()
			{
				sType = .VK_STRUCTURE_TYPE_APPLICATION_INFO,
				pNext = null,
				pApplicationName = "",
				applicationVersion = VK_MAKE_API_VERSION(0, 1, 0, 0),
				pEngineName = "",
				engineVersion = VK_MAKE_API_VERSION(0, 1, 0, 0),
				apiVersion = VK_API_VERSION_1_3
			};

		VkInstanceCreateInfo instanceCreateInfo = .()
			{
				sType = .VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
				pNext = null,
				flags = flags,
				pApplicationInfo = &appCreateInfo,
				enabledLayerCount = (uint32)foundInstanceLayers.Count,
				ppEnabledLayerNames = foundInstanceLayers.Ptr,
				enabledExtensionCount = (uint32)foundInstanceExtensions.Count,
				ppEnabledExtensionNames = foundInstanceExtensions.Ptr
			};

		vkCreateInstance(&instanceCreateInfo, null, &m_instance);

		VulkanNative.LoadInstanceFunctions(m_instance, .Agnostic | .Win32);
		VulkanNative.LoadPostInstanceFunctions();

		if (debugEnabled)
		{
			PFN_vkDebugReportCallbackEXT debugCallbackFunction = => DebugReportCallback;
			VkDebugReportCallbackCreateInfoEXT debugCallbackCreateInfo = .()
				{
					sType = .VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT,
					pNext = null,
					flags = .VK_DEBUG_REPORT_WARNING_BIT_EXT | .VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT | .VK_DEBUG_REPORT_ERROR_BIT_EXT | .VK_DEBUG_REPORT_DEBUG_BIT_EXT,
					pfnCallback = debugCallbackFunction,
					pUserData = Internal.UnsafeCastToPtr(this)
				};

			vkCreateDebugReportCallbackEXT(m_instance, &debugCallbackCreateInfo, null, &m_callback);
		}
	}

	public ~this()
	{
	}

	public override Result<void> EnumerateAdapters(List<Adapter> adapters)
	{
		uint32 deviceCount = 0;
		vkEnumeratePhysicalDevices(m_instance, &deviceCount, null);
		VkPhysicalDevice[] physicalDevices = scope .[deviceCount];
		vkEnumeratePhysicalDevices(m_instance, &deviceCount, physicalDevices.Ptr);
		for (var physicalDevice in physicalDevices)
		{
			VkPhysicalDeviceProperties deviceProperties = .();
			vkGetPhysicalDeviceProperties(physicalDevice, &deviceProperties);

			if (deviceProperties.deviceType == .VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU ||
				deviceProperties.deviceType == .eIntegratedGpu)
			{
				adapters.Add(new VKAdapter(this, physicalDevice));
			}
		}
		return .Ok;
	}

	public VkInstance GetInstance()
	{
		return m_instance;
	}

	public bool IsDebugUtilsSupported()
	{
		return m_debug_utils_supported;
	}

	private static bool SkipIt(VkDebugReportFlagsEXT flags, VkDebugReportObjectTypeEXT object_type, String message)
	{
		if (object_type == .VK_DEBUG_REPORT_OBJECT_TYPE_INSTANCE_EXT && flags != .VK_DEBUG_REPORT_ERROR_BIT_EXT)
		{
			return true;
		}

		String[?] muted_warnings = .(
			"UNASSIGNED-CoreValidation-Shader-InconsistentSpirv",
			"VUID-vkCmdDrawIndexed-None-04007",
			"VUID-vkDestroyDevice-device-00378",
			"VUID-VkSubmitInfo-pWaitSemaphores-03243",
			"VUID-VkSubmitInfo-pSignalSemaphores-03244",
			"VUID-vkCmdPipelineBarrier-pDependencies-02285",
			"VUID-VkImageMemoryBarrier-oldLayout-01213",
			"VUID-vkCmdDrawIndexed-None-02721",
			"VUID-vkCmdDrawIndexed-None-02699",
			"VUID-vkCmdTraceRaysKHR-None-02699",
			"VUID-VkShaderModuleCreateInfo-pCode-04147"
			);
		for (var warning in muted_warnings)
		{
			if (message.Contains(warning))
			{
				return true;
			}
		}

		return false;
	}

	private static VkBool32 DebugReportCallback( /*VkDebugReportFlagsEXT*/uint32 flags,
		VkDebugReportObjectTypeEXT objectType,
		uint64 object,
		uint location,
		int32 messageCode,
		char8* pLayerPrefix,
		char8* pMessage,
		void* pUserData)
	{
		String message = scope String(pMessage);

		const uint error_limit = 1024;
		static uint error_count = 0;
		if (error_count >= error_limit || SkipIt((VkDebugReportFlagsEXT)flags, objectType, message))
		{
			return VK_FALSE;
		}
		if (error_count < error_limit)
		{
			String fullMessage = scope $"{scope String(pLayerPrefix)} {(VkDebugReportFlagsEXT)flags} {message}";
			System.Diagnostics.Debug.WriteLine(fullMessage);
		}
		++error_count;
		return VK_FALSE;
	}
}