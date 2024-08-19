/****************************************************************************
 Copyright (c) 2020-2023 Xiamen Yaji Software Co., Ltd.

 http://www.cocos.com

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
****************************************************************************/

#pragma once

#include "VKStd.h"
#include "VKUtils.h"
#include "base/Log.h"
#include "base/std/container/unordered_set.h"
#include "core/memop/CachedArray.h"
#include "gfx-base/GFXDeviceObject.h"

#define TBB_USE_EXCEPTIONS 0 // no-rtti for now
#include "tbb/concurrent_unordered_map.h"

namespace cc {
namespace gfx {

static
{
constexpr uint32_t FORCE_MINOR_VERSION = 0; // 0 for default version, otherwise minorVersion = (FORCE_MINOR_VERSION - 1)

#define FORCE_ENABLE_VALIDATION  0
#define FORCE_DISABLE_VALIDATION 1

using ccstd::vector;

#if CC_DEBUG > 0 && !FORCE_DISABLE_VALIDATION || FORCE_ENABLE_VALIDATION
constexpr uint32_t DISABLE_VALIDATION_ASSERTIONS = 1; // 0 for default behavior, otherwise assertions will be disabled
VKAPI_ATTR VkBool32 VKAPI_CALL debugUtilsMessengerCallback(VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity,
                                                           VkDebugUtilsMessageTypeFlagsEXT /*messageType*/,
                                                           const VkDebugUtilsMessengerCallbackDataEXT *callbackData,
                                                           void * /*userData*/) {
    if (messageSeverity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT) {
        CC_LOG_ERROR("%s: %s", callbackData->pMessageIdName, callbackData->pMessage);
        CC_ASSERT(DISABLE_VALIDATION_ASSERTIONS);
        return VK_FALSE;
    }
    if (messageSeverity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT) {
        CC_LOG_WARNING("%s: %s", callbackData->pMessageIdName, callbackData->pMessage);
        return VK_FALSE;
    }
    if (messageSeverity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT) {
        // CC_LOG_INFO("%s: %s", callbackData->pMessageIdName, callbackData->pMessage);
        return VK_FALSE;
    }
    if (messageSeverity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT) {
        // CC_LOG_DEBUG("%s: %s", callbackData->pMessageIdName, callbackData->pMessage);
        return VK_FALSE;
    }
    CC_LOG_ERROR("%s: %s", callbackData->pMessageIdName, callbackData->pMessage);
    return VK_FALSE;
}

VKAPI_ATTR VkBool32 VKAPI_CALL debugReportCallback(VkDebugReportFlagsEXT flags,
                                                   VkDebugReportObjectTypeEXT /*type*/,
                                                   uint64_t /*object*/,
                                                   size_t /*location*/,
                                                   int32_t /*messageCode*/,
                                                   const char *layerPrefix,
                                                   const char *message,
                                                   void * /*userData*/) {
    if (flags & VK_DEBUG_REPORT_ERROR_BIT_EXT) {
        CC_LOG_ERROR("%s: %s", layerPrefix, message);
        CC_ASSERT(DISABLE_VALIDATION_ASSERTIONS);
        return VK_FALSE;
    }
    if (flags & (VK_DEBUG_REPORT_WARNING_BIT_EXT | VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT)) {
        CC_LOG_WARNING("%s: %s", layerPrefix, message);
        return VK_FALSE;
    }
    if (flags & VK_DEBUG_REPORT_INFORMATION_BIT_EXT) {
        // CC_LOG_INFO("%s: %s", layerPrefix, message);
        return VK_FALSE;
    }
    if (flags & VK_DEBUG_REPORT_DEBUG_BIT_EXT) {
        // CC_LOG_DEBUG("%s: %s", layerPrefix, message);
        return VK_FALSE;
    }
    CC_LOG_ERROR("%s: %s", layerPrefix, message);
    return VK_FALSE;
}
#endif
}

class CCVKGPUContext final {
public:
    bool initialize(){
    // only enable the absolute essentials
    ccstd::vector<const char *> requestedLayers{
        //"VK_LAYER_KHRONOS_synchronization2",
    };
    ccstd::vector<const char *> requestedExtensions{
        VK_KHR_SURFACE_EXTENSION_NAME,
    };

    ///////////////////// Instance Creation /////////////////////

    if (volkInitialize()) {
        return false;
    }

    uint32_t apiVersion = VK_API_VERSION_1_0;
    if (vkEnumerateInstanceVersion) {
        vkEnumerateInstanceVersion(&apiVersion);
        if (FORCE_MINOR_VERSION) {
            apiVersion = VK_MAKE_VERSION(1, FORCE_MINOR_VERSION - 1, 0);
        }
    }

    IXRInterface *xr = CC_GET_XR_INTERFACE();
    if (xr) apiVersion = xr->getXRVkApiVersion(apiVersion);
    minorVersion = VK_VERSION_MINOR(apiVersion);
    if (minorVersion < 1) {
        requestedExtensions.push_back(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME);
    }

    uint32_t availableLayerCount;
    VK_CHECK(vkEnumerateInstanceLayerProperties(&availableLayerCount, nullptr));
    ccstd::vector<VkLayerProperties> supportedLayers(availableLayerCount);
    VK_CHECK(vkEnumerateInstanceLayerProperties(&availableLayerCount, supportedLayers.data()));

    uint32_t availableExtensionCount;
    VK_CHECK(vkEnumerateInstanceExtensionProperties(nullptr, &availableExtensionCount, nullptr));
    ccstd::vector<VkExtensionProperties> supportedExtensions(availableExtensionCount);
    VK_CHECK(vkEnumerateInstanceExtensionProperties(nullptr, &availableExtensionCount, supportedExtensions.data()));

#if defined(VK_USE_PLATFORM_ANDROID_KHR)
    requestedExtensions.push_back(VK_KHR_ANDROID_SURFACE_EXTENSION_NAME);
#elif defined(VK_USE_PLATFORM_WIN32_KHR)
    requestedExtensions.push_back(VK_KHR_WIN32_SURFACE_EXTENSION_NAME);
#elif defined(VK_USE_PLATFORM_VI_NN)
    requestedExtensions.push_back(VK_NN_VI_SURFACE_EXTENSION_NAME);
#elif defined(VK_USE_PLATFORM_MACOS_MVK)
    requestedExtensions.push_back(VK_MVK_MACOS_SURFACE_EXTENSION_NAME);
    if (minorVersion >= 3) {
        requestedExtensions.push_back("VK_KHR_portability_enumeration");
        requestedExtensions.push_back("VK_KHR_portability_subset");
    }
#elif defined(VK_USE_PLATFORM_WAYLAND_KHR)
    requestedExtensions.push_back(VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME);
#elif defined(VK_USE_PLATFORM_XCB_KHR)
    requestedExtensions.push_back(VK_KHR_XCB_SURFACE_EXTENSION_NAME);
#else
    #pragma error Platform not supported
#endif

#if CC_DEBUG > 0 && !FORCE_DISABLE_VALIDATION || FORCE_ENABLE_VALIDATION
    // Determine the optimal validation layers to enable that are necessary for useful debugging
    ccstd::vector<ccstd::vector<const char *>> validationLayerPriorityList{
        // The preferred validation layer is "VK_LAYER_KHRONOS_validation"
        {"VK_LAYER_KHRONOS_validation"},

        // Otherwise we fallback to using the LunarG meta layer
        {"VK_LAYER_LUNARG_standard_validation"},

        // Otherwise we attempt to enable the individual layers that compose the LunarG meta layer since it doesn't exist
        {
            "VK_LAYER_GOOGLE_threading",
            "VK_LAYER_LUNARG_parameter_validation",
            "VK_LAYER_LUNARG_object_tracker",
            "VK_LAYER_LUNARG_core_validation",
            "VK_LAYER_GOOGLE_unique_objects",
        },

        // Otherwise as a last resort we fallback to attempting to enable the LunarG core layer
        {"VK_LAYER_LUNARG_core_validation"},
    };
    for (ccstd::vector<const char *> &validationLayers : validationLayerPriorityList) {
        bool found = true;
        for (const char *layer : validationLayers) {
            if (!isLayerSupported(layer, supportedLayers)) {
                found = false;
                break;
            }
        }
        if (found) {
            requestedLayers.insert(requestedLayers.end(), validationLayers.begin(), validationLayers.end());
            break;
        }
    }
#endif

#if CC_DEBUG
    // Check if VK_EXT_debug_utils is supported, which supersedes VK_EXT_Debug_Report
    bool debugUtils = false;
    if (isExtensionSupported(VK_EXT_DEBUG_UTILS_EXTENSION_NAME, supportedExtensions)) {
        debugUtils = true;
        requestedExtensions.push_back(VK_EXT_DEBUG_UTILS_EXTENSION_NAME);
    } else {
        requestedExtensions.push_back(VK_EXT_DEBUG_REPORT_EXTENSION_NAME);
    }
#endif

    // just filter out the unsupported layers & extensions
    for (const char *layer : requestedLayers) {
        if (isLayerSupported(layer, supportedLayers)) {
            layers.push_back(layer);
        }
    }
    for (const char *extension : requestedExtensions) {
        if (isExtensionSupported(extension, supportedExtensions)) {
            extensions.push_back(extension);
        }
    }

    VkApplicationInfo app{VK_STRUCTURE_TYPE_APPLICATION_INFO};
    app.pEngineName = "Cocos Creator";
    app.apiVersion = apiVersion;

    VkInstanceCreateInfo instanceInfo{VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO};
#if defined(VK_USE_PLATFORM_MACOS_MVK)
    if (minorVersion >= 3) {
        instanceInfo.flags |= 0x01; // VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
    }
#endif

    instanceInfo.pApplicationInfo = &app;
    instanceInfo.enabledExtensionCount = utils::toUint(extensions.size());
    instanceInfo.ppEnabledExtensionNames = extensions.data();
    instanceInfo.enabledLayerCount = utils::toUint(layers.size());
    instanceInfo.ppEnabledLayerNames = layers.data();

#if CC_DEBUG > 0 && !FORCE_DISABLE_VALIDATION || FORCE_ENABLE_VALIDATION
    VkDebugUtilsMessengerCreateInfoEXT debugUtilsCreateInfo{VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT};
    VkDebugReportCallbackCreateInfoEXT debugReportCreateInfo{VK_STRUCTURE_TYPE_DEBUG_REPORT_CREATE_INFO_EXT};
    if (debugUtils) {
        debugUtilsCreateInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT |
                                               VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
                                               VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT |
                                               VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT;
        debugUtilsCreateInfo.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;
        debugUtilsCreateInfo.pfnUserCallback = debugUtilsMessengerCallback;

        instanceInfo.pNext = &debugUtilsCreateInfo;
    } else {
        debugReportCreateInfo.flags = VK_DEBUG_REPORT_ERROR_BIT_EXT |
                                      VK_DEBUG_REPORT_WARNING_BIT_EXT |
                                      VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT |
                                      VK_DEBUG_REPORT_INFORMATION_BIT_EXT |
                                      VK_DEBUG_REPORT_DEBUG_BIT_EXT;
        debugReportCreateInfo.pfnCallback = debugReportCallback;

        instanceInfo.pNext = &debugReportCreateInfo;
    }
#endif

    // Create the Vulkan instance
    if (xr) {
        xr->initializeVulkanData(vkGetInstanceProcAddr);
        vkInstance = xr->createXRVulkanInstance(instanceInfo);
    } else {
        VkResult res = vkCreateInstance(&instanceInfo, nullptr, &vkInstance);
        if (res == VK_ERROR_LAYER_NOT_PRESENT) {
            CC_LOG_ERROR("Create Vulkan instance failed due to missing layers, aborting...");
            return false;
        }
    }
    volkLoadInstanceOnly(vkInstance);

#if CC_DEBUG > 0 && !FORCE_DISABLE_VALIDATION || FORCE_ENABLE_VALIDATION
    if (debugUtils) {
        VK_CHECK(vkCreateDebugUtilsMessengerEXT(vkInstance, &debugUtilsCreateInfo, nullptr, &vkDebugUtilsMessenger));
    } else {
        VK_CHECK(vkCreateDebugReportCallbackEXT(vkInstance, &debugReportCreateInfo, nullptr, &vkDebugReport));
    }
    validationEnabled = true;
#endif

    ///////////////////// Physical Device Selection /////////////////////

    // Querying valid physical devices on the machine
    uint32_t physicalDeviceCount{0};
    VkResult res = vkEnumeratePhysicalDevices(vkInstance, &physicalDeviceCount, nullptr);

    if (res || physicalDeviceCount < 1) {
        return false;
    }

    ccstd::vector<VkPhysicalDevice> physicalDeviceHandles(physicalDeviceCount);
    if (xr) {
        physicalDeviceHandles[0] = xr->getXRVulkanGraphicsDevice();
    } else {
        VK_CHECK(vkEnumeratePhysicalDevices(vkInstance, &physicalDeviceCount, physicalDeviceHandles.data()));
    }

    ccstd::vector<VkPhysicalDeviceProperties> physicalDevicePropertiesList(physicalDeviceCount);

    uint32_t deviceIndex;
    for (deviceIndex = 0U; deviceIndex < physicalDeviceCount; ++deviceIndex) {
        VkPhysicalDeviceProperties &properties = physicalDevicePropertiesList[deviceIndex];
        vkGetPhysicalDeviceProperties(physicalDeviceHandles[deviceIndex], &properties);
    }

    for (deviceIndex = 0U; deviceIndex < physicalDeviceCount; ++deviceIndex) {
        VkPhysicalDeviceProperties &properties = physicalDevicePropertiesList[deviceIndex];
        if (properties.deviceType == VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU) {
            break;
        }
    }

    if (deviceIndex == physicalDeviceCount) {
        deviceIndex = 0;
    }

    physicalDevice = physicalDeviceHandles[deviceIndex];
    physicalDeviceProperties = physicalDevicePropertiesList[deviceIndex];
    vkGetPhysicalDeviceFeatures(physicalDevice, &physicalDeviceFeatures);

    majorVersion = VK_VERSION_MAJOR(physicalDeviceProperties.apiVersion);
    minorVersion = VK_VERSION_MINOR(physicalDeviceProperties.apiVersion);

    if (minorVersion >= 1 || checkExtension(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME)) {
        physicalDeviceFeatures2.pNext = &physicalDeviceVulkan11Features;
        physicalDeviceVulkan11Features.pNext = &physicalDeviceVulkan12Features;
        physicalDeviceVulkan12Features.pNext = &physicalDeviceFragmentShadingRateFeatures;
        physicalDeviceProperties2.pNext = &physicalDeviceDepthStencilResolveProperties;
        if (minorVersion >= 1) {
            vkGetPhysicalDeviceProperties2(physicalDevice, &physicalDeviceProperties2);
            vkGetPhysicalDeviceFeatures2(physicalDevice, &physicalDeviceFeatures2);
        } else {
            vkGetPhysicalDeviceProperties2KHR(physicalDevice, &physicalDeviceProperties2);
            vkGetPhysicalDeviceFeatures2KHR(physicalDevice, &physicalDeviceFeatures2);
        }
    }

    vkGetPhysicalDeviceMemoryProperties(physicalDevice, &physicalDeviceMemoryProperties);
    uint32_t queueFamilyPropertiesCount = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyPropertiesCount, nullptr);
    queueFamilyProperties.resize(queueFamilyPropertiesCount);
    vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyPropertiesCount, queueFamilyProperties.data());
    return true;
}
    void destroy(){
#if CC_DEBUG > 0 && !FORCE_DISABLE_VALIDATION || FORCE_ENABLE_VALIDATION
    if (vkDebugUtilsMessenger != VK_NULL_HANDLE) {
        vkDestroyDebugUtilsMessengerEXT(vkInstance, vkDebugUtilsMessenger, nullptr);
        vkDebugUtilsMessenger = VK_NULL_HANDLE;
    }
    if (vkDebugReport != VK_NULL_HANDLE) {
        vkDestroyDebugReportCallbackEXT(vkInstance, vkDebugReport, nullptr);
        vkDebugReport = VK_NULL_HANDLE;
    }
#endif

    if (vkInstance != VK_NULL_HANDLE) {
        vkDestroyInstance(vkInstance, nullptr);
        vkInstance = VK_NULL_HANDLE;
    }
}

    VkInstance vkInstance = VK_NULL_HANDLE;
    VkDebugUtilsMessengerEXT vkDebugUtilsMessenger = VK_NULL_HANDLE;
    VkDebugReportCallbackEXT vkDebugReport = VK_NULL_HANDLE;

    VkPhysicalDevice physicalDevice = VK_NULL_HANDLE;
    VkPhysicalDeviceFeatures physicalDeviceFeatures{};
    VkPhysicalDeviceFeatures2 physicalDeviceFeatures2{VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2};
    VkPhysicalDeviceVulkan11Features physicalDeviceVulkan11Features{VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES};
    VkPhysicalDeviceVulkan12Features physicalDeviceVulkan12Features{VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES};
    VkPhysicalDeviceFragmentShadingRateFeaturesKHR physicalDeviceFragmentShadingRateFeatures{VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_FEATURES_KHR};
    VkPhysicalDeviceDepthStencilResolveProperties physicalDeviceDepthStencilResolveProperties{VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEPTH_STENCIL_RESOLVE_PROPERTIES};
    VkPhysicalDeviceProperties physicalDeviceProperties{};
    VkPhysicalDeviceProperties2 physicalDeviceProperties2{VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2};
    VkPhysicalDeviceMemoryProperties physicalDeviceMemoryProperties{};
    ccstd::vector<VkQueueFamilyProperties> queueFamilyProperties;

    uint32_t majorVersion = 0;
    uint32_t minorVersion = 0;

    bool validationEnabled = false;
    bool debugUtils = false;
    bool debugReport = false;

    ccstd::vector<const char *> layers;
    ccstd::vector<const char *> extensions;

    inline bool checkExtension(const ccstd::string &extension) const {
        return std::any_of(extensions.begin(), extensions.end(), [&extension](auto &ext) {
            return std::strcmp(ext, extension.c_str()) == 0;
        });
    }
};

struct CCVKAccessInfo {
    VkPipelineStageFlags stageMask{0};
    VkAccessFlags accessMask{0};
    VkImageLayout imageLayout{VK_IMAGE_LAYOUT_UNDEFINED};
    bool hasWriteAccess{false};
};

struct CCVKGPUGeneralBarrier {
    VkPipelineStageFlags srcStageMask = 0U;
    VkPipelineStageFlags dstStageMask = 0U;
    VkMemoryBarrier vkBarrier{};

    ccstd::vector<ThsvsAccessType> prevAccesses;
    ccstd::vector<ThsvsAccessType> nextAccesses;

    ThsvsGlobalBarrier barrier{};
};

struct CCVKDeviceObjectDeleter {
    template <typename T>
    void operator()(T *ptr) const;
};

class CCVKGPUDeviceObject : public GFXDeviceObject<CCVKDeviceObjectDeleter> {
public:
    CCVKGPUDeviceObject() = default;
    ~CCVKGPUDeviceObject() = default;

    virtual void shutdown(){};
};

template <typename T>
void CCVKDeviceObjectDeleter::operator()(T *ptr) const {
    auto *object = const_cast<CCVKGPUDeviceObject *>(static_cast<const CCVKGPUDeviceObject *>(ptr));
    object->shutdown();
    delete object;
}

class CCVKGPURenderPass final : public CCVKGPUDeviceObject {
public:
    void shutdown() {
    CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
}

    ColorAttachmentList colorAttachments;
    DepthStencilAttachment depthStencilAttachment;
    DepthStencilAttachment depthStencilResolveAttachment;
    SubpassInfoList subpasses;
    SubpassDependencyList dependencies;

    VkRenderPass vkRenderPass;

    // helper storage
    ccstd::vector<VkClearValue> clearValues;
    ccstd::vector<VkSampleCountFlagBits> sampleCounts; // per subpass
    ccstd::vector<bool> hasSelfDependency; // per subpass

    const CCVKGPUGeneralBarrier *getBarrier(size_t index, CCVKGPUDevice *gpuDevice) {
    if (index < colorAttachments.size()) {
        return colorAttachments[index].barrier ? static_cast<CCVKGeneralBarrier *>(colorAttachments[index].barrier)->gpuBarrier() : &gpuDevice->defaultColorBarrier;
    }
    return depthStencilAttachment.barrier ? static_cast<CCVKGeneralBarrier *>(depthStencilAttachment.barrier)->gpuBarrier() : &gpuDevice->defaultDepthStencilBarrier;
}
    bool hasShadingAttachment(uint32_t subPassId) {
    CC_ASSERT(subPassId < subpasses.size());
    return subpasses[subPassId].shadingRate != INVALID_BINDING;
}
};

struct CCVKGPUSwapchain;
struct CCVKGPUFramebuffer;
struct CCVKGPUTexture : public CCVKGPUDeviceObject {
    void shutdown() {
    if (memoryAllocated) {
        CCVKDevice::getInstance()->getMemoryStatus().textureSize -= size;
        CC_PROFILE_MEMORY_DEC(Texture, size);
    }

    CCVKDevice::getInstance()->gpuBarrierManager()->cancel(this);
    if (!hasFlag(flags, TextureFlagBit::EXTERNAL_NORMAL)) {
        CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
    }
}
    void init(){
    cmdFuncCCVKCreateTexture(CCVKDevice::getInstance(), this);

    if (memoryAllocated) {
        CCVKDevice::getInstance()->getMemoryStatus().textureSize += size;
        CC_PROFILE_MEMORY_INC(Texture, size);
    }
}

    TextureType type = TextureType::TEX2D;
    Format format = Format::UNKNOWN;
    TextureUsage usage = TextureUsageBit::NONE;
    uint32_t width = 0U;
    uint32_t height = 0U;
    uint32_t depth = 1U;
    uint32_t size = 0U;
    uint32_t arrayLayers = 1U;
    uint32_t mipLevels = 1U;
    SampleCount samples = SampleCount::X1;
    TextureFlags flags = TextureFlagBit::NONE;
    VkImageAspectFlags aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;

    /*
     * allocate and bind memory by Texture.
     * If any of the following conditions are met, then the statement is false
     * 1. Texture is a swapchain image.
     * 2. Texture has flag LAZILY_ALLOCATED.
     * 3. Memory bound manually bound.
     * 4. Sparse Image.
     */
    bool memoryAllocated = true;

    VkImage vkImage = VK_NULL_HANDLE;
    VmaAllocation vmaAllocation = VK_NULL_HANDLE;

    CCVKGPUSwapchain *swapchain = nullptr;
    ccstd::vector<VkImage> swapchainVkImages;
    ccstd::vector<VmaAllocation> swapchainVmaAllocations;

    ccstd::vector<ThsvsAccessType> currentAccessTypes;

    // for barrier manager
    ccstd::vector<ThsvsAccessType> renderAccessTypes; // gathered from descriptor sets
    ThsvsAccessType transferAccess = THSVS_ACCESS_NONE;

    VkImage externalVKImage = VK_NULL_HANDLE;
};

struct CCVKGPUTextureView : public CCVKGPUDeviceObject {
    void shutdown() {
    CCVKDevice::getInstance()->gpuDescriptorHub()->disengage(this);
    CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
}
    void init(){
    cmdFuncCCVKCreateTextureView(CCVKDevice::getInstance(), this);
}

    IntrusivePtr<CCVKGPUTexture> gpuTexture;
    TextureType type = TextureType::TEX2D;
    Format format = Format::UNKNOWN;
    uint32_t baseLevel = 0U;
    uint32_t levelCount = 1U;
    uint32_t baseLayer = 0U;
    uint32_t layerCount = 1U;
    uint32_t basePlane = 0U;
    uint32_t planeCount = 1U;

    ccstd::vector<VkImageView> swapchainVkImageViews;

    // descriptor infos
    VkImageView vkImageView = VK_NULL_HANDLE;
};

struct CCVKGPUSampler : public CCVKGPUDeviceObject {
    void shutdown() {
    CCVKDevice::getInstance()->gpuDescriptorHub()->disengage(this);
    CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
}
    void init(){
    cmdFuncCCVKCreateSampler(CCVKDevice::getInstance(), this);
}

    Filter minFilter = Filter::LINEAR;
    Filter magFilter = Filter::LINEAR;
    Filter mipFilter = Filter::NONE;
    Address addressU = Address::WRAP;
    Address addressV = Address::WRAP;
    Address addressW = Address::WRAP;
    uint32_t maxAnisotropy = 0U;
    ComparisonFunc cmpFunc = ComparisonFunc::NEVER;

    // descriptor infos
    VkSampler vkSampler;
};

struct CCVKGPUBuffer : public CCVKGPUDeviceObject {
    void shutdown() {
    CCVKDevice::getInstance()->gpuBarrierManager()->cancel(this);
    CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
    CCVKDevice::getInstance()->gpuBufferHub()->erase(this);

    CCVKDevice::getInstance()->getMemoryStatus().bufferSize -= size;
    CC_PROFILE_MEMORY_DEC(Buffer, size);
}
    void init(){
    if (hasFlag(usage, BufferUsageBit::INDIRECT)) {
        const size_t drawInfoCount = size / sizeof(DrawInfo);
        indexedIndirectCmds.resize(drawInfoCount);
        indirectCmds.resize(drawInfoCount);
    }

    cmdFuncCCVKCreateBuffer(CCVKDevice::getInstance(), this);
    CCVKDevice::getInstance()->getMemoryStatus().bufferSize += size;
    CC_PROFILE_MEMORY_INC(Buffer, size);
}

    BufferUsage usage = BufferUsage::NONE;
    MemoryUsage memUsage = MemoryUsage::NONE;
    uint32_t stride = 0U;
    uint32_t count = 0U;
    void *buffer = nullptr;

    bool isDrawIndirectByIndex = false;
    ccstd::vector<VkDrawIndirectCommand> indirectCmds;
    ccstd::vector<VkDrawIndexedIndirectCommand> indexedIndirectCmds;

    uint8_t *mappedData = nullptr;
    VmaAllocation vmaAllocation = VK_NULL_HANDLE;

    // descriptor infos
    VkBuffer vkBuffer = VK_NULL_HANDLE;
    VkDeviceSize size = 0U;

    VkDeviceSize instanceSize = 0U; // per-back-buffer instance
    ccstd::vector<ThsvsAccessType> currentAccessTypes;

    // for barrier manager
    ccstd::vector<ThsvsAccessType> renderAccessTypes; // gathered from descriptor sets
    ThsvsAccessType transferAccess = THSVS_ACCESS_NONE;

    VkDeviceSize getStartOffset(uint32_t curBackBufferIndex) const {
        return instanceSize * curBackBufferIndex;
    }
};

struct CCVKGPUBufferView : public CCVKGPUDeviceObject {
    void shutdown() {
    CCVKDevice::getInstance()->gpuDescriptorHub()->disengage(this);
    CCVKDevice::getInstance()->gpuIAHub()->disengage(this);
}
    ConstPtr<CCVKGPUBuffer> gpuBuffer;
    uint32_t offset = 0U;
    uint32_t range = 0U;

    uint8_t *mappedData() const {
        return gpuBuffer->mappedData + offset;
    }

    VkDeviceSize getStartOffset(uint32_t curBackBufferIndex) const {
        return gpuBuffer->getStartOffset(curBackBufferIndex) + offset;
    }
};

struct CCVKGPUFramebuffer : public CCVKGPUDeviceObject {
    void shutdown() {
    CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
}

    ConstPtr<CCVKGPURenderPass> gpuRenderPass;
    ccstd::vector<ConstPtr<CCVKGPUTextureView>> gpuColorViews;
    ConstPtr<CCVKGPUTextureView> gpuDepthStencilView;
    ConstPtr<CCVKGPUTextureView> gpuDepthStencilResolveView;
    VkFramebuffer vkFramebuffer = VK_NULL_HANDLE;
    std::vector<VkFramebuffer> vkFrameBuffers;
    CCVKGPUSwapchain *swapchain = nullptr;
    bool isOffscreen = true;
    uint32_t width = 0U;
    uint32_t height = 0U;
};

struct CCVKGPUSwapchain : public CCVKGPUDeviceObject {
    VkSurfaceKHR vkSurface = VK_NULL_HANDLE;
    VkSwapchainCreateInfoKHR createInfo{VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR};

    uint32_t curImageIndex = 0U;
    VkSwapchainKHR vkSwapchain = VK_NULL_HANDLE;
    ccstd::vector<VkBool32> queueFamilyPresentables;
    VkResult lastPresentResult = VK_NOT_READY;

    // external references
    ccstd::vector<VkImage> swapchainImages;
};

struct CCVKGPUCommandBuffer : public CCVKGPUDeviceObject {
    VkCommandBuffer vkCommandBuffer = VK_NULL_HANDLE;
    VkCommandBufferLevel level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    uint32_t queueFamilyIndex = 0U;
    bool began = false;
    mutable ccstd::unordered_set<VkBuffer> recordedBuffers;
};

struct CCVKGPUQueue {
    QueueType type = QueueType::GRAPHICS;
    VkQueue vkQueue = VK_NULL_HANDLE;
    uint32_t queueFamilyIndex = 0U;
    ccstd::vector<uint32_t> possibleQueueFamilyIndices;
    ccstd::vector<VkSemaphore> lastSignaledSemaphores;
    ccstd::vector<VkPipelineStageFlags> submitStageMasks;
    ccstd::vector<VkCommandBuffer> commandBuffers;
};

struct CCVKGPUQueryPool : public CCVKGPUDeviceObject {
    void shutdown() {
    CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
}

    QueryType type{QueryType::OCCLUSION};
    uint32_t maxQueryObjects{0};
    bool forceWait{true};
    VkQueryPool vkPool{VK_NULL_HANDLE};
};

struct CCVKGPUShaderStage {
    CCVKGPUShaderStage(ShaderStageFlagBit t, ccstd::string s)
    : type(t),
      source(std::move(s)) {
    }
    ShaderStageFlagBit type = ShaderStageFlagBit::NONE;
    ccstd::string source;
    VkShaderModule vkShader = VK_NULL_HANDLE;
};

struct CCVKGPUShader : public CCVKGPUDeviceObject {
    void shutdown() {
    cmdFuncCCVKDestroyShader(CCVKDevice::getInstance()->gpuDevice(), this);
}

    ccstd::string name;
    AttributeList attributes;
    ccstd::vector<CCVKGPUShaderStage> gpuStages;
    bool initialized = false;
};

struct CCVKGPUInputAssembler : public CCVKGPUDeviceObject {
    void shutdown() {
    auto *hub = CCVKDevice::getInstance()->gpuIAHub();
    for (auto &vb : gpuVertexBuffers) {
        hub->disengage(this, vb);
    }
    if (gpuIndexBuffer) {
        hub->disengage(this, gpuIndexBuffer);
    }
    if (gpuIndirectBuffer) {
        hub->disengage(this, gpuIndirectBuffer);
    }
}
    void update(const CCVKGPUBufferView *oldBuffer, const CCVKGPUBufferView *newBuffer){
    for (uint32_t i = 0; i < gpuVertexBuffers.size(); ++i) {
        if (gpuVertexBuffers[i].get() == oldBuffer) {
            gpuVertexBuffers[i] = newBuffer;
            vertexBuffers[i] = newBuffer->gpuBuffer->vkBuffer;
        }
    }
    if (gpuIndexBuffer.get() == oldBuffer) {
        gpuIndexBuffer = newBuffer;
    }
    if (gpuIndirectBuffer.get() == oldBuffer) {
        gpuIndirectBuffer = newBuffer;
    }
}

    AttributeList attributes;
    ccstd::vector<ConstPtr<CCVKGPUBufferView>> gpuVertexBuffers;
    ConstPtr<CCVKGPUBufferView> gpuIndexBuffer;
    ConstPtr<CCVKGPUBufferView> gpuIndirectBuffer;
    ccstd::vector<VkBuffer> vertexBuffers;
    ccstd::vector<VkDeviceSize> vertexBufferOffsets;
};

union CCVKDescriptorInfo {
    VkDescriptorImageInfo image;
    VkDescriptorBufferInfo buffer;
    VkBufferView texelBufferView;
};
struct CCVKGPUDescriptor {
    DescriptorType type = DescriptorType::UNKNOWN;
    ccstd::vector<ThsvsAccessType> accessTypes;
    ConstPtr<CCVKGPUBufferView> gpuBufferView;
    ConstPtr<CCVKGPUTextureView> gpuTextureView;
    ConstPtr<CCVKGPUSampler> gpuSampler;
};

struct CCVKGPUDescriptorSetLayout;
struct CCVKGPUDescriptorSet : public CCVKGPUDeviceObject {
    void shutdown() {
    CCVKDevice *device = CCVKDevice::getInstance();
    CCVKGPUDescriptorHub *descriptorHub = CCVKDevice::getInstance()->gpuDescriptorHub();
    uint32_t instanceCount = utils::toUint(instances.size());

    for (uint32_t t = 0U; t < instanceCount; ++t) {
        CCVKGPUDescriptorSet::Instance &instance = instances[t];

        for (uint32_t i = 0U; i < gpuDescriptors.size(); i++) {
            CCVKGPUDescriptor &binding = gpuDescriptors[i];

            CCVKDescriptorInfo &descriptorInfo = instance.descriptorInfos[i];
            if (binding.gpuBufferView) {
                descriptorHub->disengage(this, binding.gpuBufferView, &descriptorInfo.buffer);
            }
            if (binding.gpuTextureView) {
                descriptorHub->disengage(this, binding.gpuTextureView, &descriptorInfo.image);
            }
            if (binding.gpuSampler) {
                descriptorHub->disengage(binding.gpuSampler, &descriptorInfo.image);
            }
        }

        if (instance.vkDescriptorSet) {
            device->gpuRecycleBin()->collect(layoutID, instance.vkDescriptorSet);
        }
    }

    CCVKDevice::getInstance()->gpuDescriptorSetHub()->erase(this);
}

    void update(const CCVKGPUBufferView *oldView, const CCVKGPUBufferView *newView){
    CCVKGPUDescriptorHub *descriptorHub = CCVKDevice::getInstance()->gpuDescriptorHub();
    uint32_t instanceCount = utils::toUint(instances.size());

    for (size_t i = 0U; i < gpuDescriptors.size(); i++) {
        CCVKGPUDescriptor &binding = gpuDescriptors[i];
        if (hasFlag(DESCRIPTOR_BUFFER_TYPE, binding.type) && (binding.gpuBufferView == oldView)) {
            for (uint32_t t = 0U; t < instanceCount; ++t) {
                CCVKDescriptorInfo &descriptorInfo = instances[t].descriptorInfos[i];

                if (newView != nullptr) {
                    descriptorHub->connect(this, newView, &descriptorInfo.buffer, t);
                    descriptorHub->update(newView, &descriptorInfo.buffer);
                }
            }
            binding.gpuBufferView = newView;
        }
    }
    CCVKDevice::getInstance()->gpuDescriptorSetHub()->record(this);
}

    void update(const CCVKGPUTextureView *oldView, const CCVKGPUTextureView *newView){
    CCVKGPUDescriptorHub *descriptorHub = CCVKDevice::getInstance()->gpuDescriptorHub();
    uint32_t instanceCount = utils::toUint(instances.size());

    for (size_t i = 0U; i < gpuDescriptors.size(); i++) {
        CCVKGPUDescriptor &binding = gpuDescriptors[i];
        if (hasFlag(DESCRIPTOR_TEXTURE_TYPE, binding.type) && (binding.gpuTextureView == oldView)) {
            for (uint32_t t = 0U; t < instanceCount; ++t) {
                CCVKDescriptorInfo &descriptorInfo = instances[t].descriptorInfos[i];

                if (newView != nullptr) {
                    descriptorHub->connect(this, newView, &descriptorInfo.image);
                    descriptorHub->update(newView, &descriptorInfo.image);
                }
            }
            binding.gpuTextureView = newView;
        }
    }
    CCVKDevice::getInstance()->gpuDescriptorSetHub()->record(this);
}

    ccstd::vector<CCVKGPUDescriptor> gpuDescriptors;

    // references
    ConstPtr<CCVKGPUDescriptorSetLayout> gpuLayout;

    struct Instance {
        VkDescriptorSet vkDescriptorSet = VK_NULL_HANDLE;
        ccstd::vector<CCVKDescriptorInfo> descriptorInfos;
        ccstd::vector<VkWriteDescriptorSet> descriptorUpdateEntries;
    };
    ccstd::vector<Instance> instances; // per swapchain image

    uint32_t layoutID = 0U;
};

struct CCVKGPUPipelineLayout : public CCVKGPUDeviceObject {
    void shutdown() {
    cmdFuncCCVKDestroyPipelineLayout(CCVKDevice::getInstance()->gpuDevice(), this);
}

    ccstd::vector<ConstPtr<CCVKGPUDescriptorSetLayout>> setLayouts;

    VkPipelineLayout vkPipelineLayout = VK_NULL_HANDLE;

    // helper storage
    ccstd::vector<uint32_t> dynamicOffsetOffsets;
    uint32_t dynamicOffsetCount;
};

struct CCVKGPUPipelineState : public CCVKGPUDeviceObject {
    void shutdown() {
    CCVKDevice::getInstance()->gpuRecycleBin()->collect(this);
}

    PipelineBindPoint bindPoint = PipelineBindPoint::GRAPHICS;
    PrimitiveMode primitive = PrimitiveMode::TRIANGLE_LIST;
    ConstPtr<CCVKGPUShader> gpuShader;
    ConstPtr<CCVKGPUPipelineLayout> gpuPipelineLayout;
    InputState inputState;
    RasterizerState rs;
    DepthStencilState dss;
    BlendState bs;
    DynamicStateList dynamicStates;
    ConstPtr<CCVKGPURenderPass> gpuRenderPass;
    uint32_t subpass = 0U;
    VkPipeline vkPipeline = VK_NULL_HANDLE;
};

struct CCVKGPUBufferBarrier {
    VkPipelineStageFlags srcStageMask = 0U;
    VkPipelineStageFlags dstStageMask = 0U;
    VkBufferMemoryBarrier vkBarrier{};

    ccstd::vector<ThsvsAccessType> prevAccesses;
    ccstd::vector<ThsvsAccessType> nextAccesses;

    ThsvsBufferBarrier barrier{};
};

struct CCVKGPUTextureBarrier {
    VkPipelineStageFlags srcStageMask = 0U;
    VkPipelineStageFlags dstStageMask = 0U;
    VkImageMemoryBarrier vkBarrier{};

    ccstd::vector<ThsvsAccessType> prevAccesses;
    ccstd::vector<ThsvsAccessType> nextAccesses;

    ThsvsImageBarrier barrier{};
};

class CCVKGPUCommandBufferPool;
class CCVKGPUDescriptorSetPool;
class CCVKGPUDevice final {
public:
    VkDevice vkDevice{VK_NULL_HANDLE};
    ccstd::vector<VkLayerProperties> layers;
    ccstd::vector<VkExtensionProperties> extensions;
    VmaAllocator memoryAllocator{VK_NULL_HANDLE};
    uint32_t minorVersion{0U};

    VkFormat depthFormat{VK_FORMAT_UNDEFINED};
    VkFormat depthStencilFormat{VK_FORMAT_UNDEFINED};

    uint32_t curBackBufferIndex{0U};
    uint32_t backBufferCount{3U};

    bool useDescriptorUpdateTemplate{false};
    bool useMultiDrawIndirect{false};

    PFN_vkCreateRenderPass2 createRenderPass2{nullptr};

    // for default backup usages
    IntrusivePtr<CCVKGPUSampler> defaultSampler;
    IntrusivePtr<CCVKGPUTexture> defaultTexture;
    IntrusivePtr<CCVKGPUTextureView> defaultTextureView;
    IntrusivePtr<CCVKGPUBuffer> defaultBuffer;

    CCVKGPUGeneralBarrier defaultColorBarrier;
    CCVKGPUGeneralBarrier defaultDepthStencilBarrier;

    ccstd::unordered_set<CCVKGPUSwapchain *> swapchains;

    CCVKGPUCommandBufferPool *getCommandBufferPool(){
    static thread_local size_t threadID = std::hash<std::thread::id>{}(std::this_thread::get_id());
    if (!_commandBufferPools.count(threadID)) {
        _commandBufferPools[threadID] = ccnew CCVKGPUCommandBufferPool(this);
    }
    return _commandBufferPools[threadID];
}
    CCVKGPUDescriptorSetPool *getDescriptorSetPool(uint32_t layoutID){
    if (_descriptorSetPools.find(layoutID) == _descriptorSetPools.end()) {
        _descriptorSetPools[layoutID] = std::make_unique<CCVKGPUDescriptorSetPool>();
    }
    return _descriptorSetPools[layoutID].get();
}

private:
    friend class CCVKDevice;

    // cannot use thread_local here because we need explicit control over their destruction
    using CommandBufferPools = tbb::concurrent_unordered_map<size_t, CCVKGPUCommandBufferPool *, std::hash<size_t>>;
    CommandBufferPools _commandBufferPools;

    ccstd::unordered_map<uint32_t, std::unique_ptr<CCVKGPUDescriptorSetPool>> _descriptorSetPools;
};

/**
 * A simple pool for reusing fences.
 */
class CCVKGPUFencePool final {
public:
    explicit CCVKGPUFencePool(CCVKGPUDevice *device)
    : _device(device) {
    }

    ~CCVKGPUFencePool() {
        for (VkFence fence : _fences) {
            vkDestroyFence(_device->vkDevice, fence, nullptr);
        }
        _fences.clear();
        _count = 0;
    }

    VkFence alloc() {
        if (_count < _fences.size()) {
            return _fences[_count++];
        }

        VkFence fence = VK_NULL_HANDLE;
        VkFenceCreateInfo createInfo{VK_STRUCTURE_TYPE_FENCE_CREATE_INFO};
        VK_CHECK(vkCreateFence(_device->vkDevice, &createInfo, nullptr, &fence));
        _fences.push_back(fence);
        _count++;

        return fence;
    }

    void reset() {
        if (_count) {
            VK_CHECK(vkResetFences(_device->vkDevice, _count, _fences.data()));
            _count = 0;
        }
    }

    VkFence *data() {
        return _fences.data();
    }

    uint32_t size() const {
        return _count;
    }

private:
    CCVKGPUDevice *_device = nullptr;
    uint32_t _count = 0U;
    ccstd::vector<VkFence> _fences;
};

/**
 * A simple pool for reusing semaphores.
 */
class CCVKGPUSemaphorePool final {
public:
    explicit CCVKGPUSemaphorePool(CCVKGPUDevice *device)
    : _device(device) {
    }

    ~CCVKGPUSemaphorePool() {
        for (VkSemaphore semaphore : _semaphores) {
            vkDestroySemaphore(_device->vkDevice, semaphore, nullptr);
        }
        _semaphores.clear();
        _count = 0;
    }

    VkSemaphore alloc() {
        if (_count < _semaphores.size()) {
            return _semaphores[_count++];
        }

        VkSemaphore semaphore = VK_NULL_HANDLE;
        VkSemaphoreCreateInfo createInfo{VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO};
        VK_CHECK(vkCreateSemaphore(_device->vkDevice, &createInfo, nullptr, &semaphore));
        _semaphores.push_back(semaphore);
        _count++;

        return semaphore;
    }

    void reset() {
        _count = 0;
    }

    uint32_t size() const {
        return _count;
    }

private:
    CCVKGPUDevice *_device;
    uint32_t _count = 0U;
    ccstd::vector<VkSemaphore> _semaphores;
};

/**
 * Unlimited descriptor set pool, based on multiple fix-sized VkDescriptorPools.
 */
class CCVKGPUDescriptorSetPool final {
public:
    ~CCVKGPUDescriptorSetPool() {
        for (auto &pool : _pools) {
            vkDestroyDescriptorPool(_device->vkDevice, pool, nullptr);
        }
    }

    void link(CCVKGPUDevice *device, uint32_t maxSetsPerPool, const ccstd::vector<VkDescriptorSetLayoutBinding> &bindings, VkDescriptorSetLayout setLayout) {
        _device = device;
        _maxSetsPerPool = maxSetsPerPool;
        _setLayouts.insert(_setLayouts.cbegin(), _maxSetsPerPool, setLayout);

        ccstd::unordered_map<VkDescriptorType, uint32_t> typeMap;
        for (const auto &vkBinding : bindings) {
            typeMap[vkBinding.descriptorType] += maxSetsPerPool * vkBinding.descriptorCount;
        }

        // minimal reserve for empty set layouts
        if (bindings.empty()) {
            typeMap[VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER] = 1;
        }

        _poolSizes.clear();
        for (auto &it : typeMap) {
            _poolSizes.push_back({it.first, it.second});
        }
    }

    VkDescriptorSet request() {
        if (_freeList.empty()) {
            requestPool();
        }
        return pop();
    }

    void requestPool() {
        VkDescriptorPoolCreateInfo createInfo{VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO};
        createInfo.maxSets = _maxSetsPerPool;
        createInfo.poolSizeCount = utils::toUint(_poolSizes.size());
        createInfo.pPoolSizes = _poolSizes.data();

        VkDescriptorPool descriptorPool = VK_NULL_HANDLE;
        VK_CHECK(vkCreateDescriptorPool(_device->vkDevice, &createInfo, nullptr, &descriptorPool));
        _pools.push_back(descriptorPool);

        std::vector<VkDescriptorSet> sets(_maxSetsPerPool, VK_NULL_HANDLE);
        VkDescriptorSetAllocateInfo info{VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO};
        info.pSetLayouts = _setLayouts.data();
        info.descriptorSetCount = _maxSetsPerPool;
        info.descriptorPool = descriptorPool;
        VK_CHECK(vkAllocateDescriptorSets(_device->vkDevice, &info, sets.data()));

        _freeList.insert(_freeList.end(), sets.begin(), sets.end());
    }

    void yield(VkDescriptorSet set) {
        _freeList.emplace_back(set);
    }

private:
    VkDescriptorSet pop() {
        VkDescriptorSet output = VK_NULL_HANDLE;
        if (!_freeList.empty()) {
            output = _freeList.back();
            _freeList.pop_back();
            return output;
        }
        return VK_NULL_HANDLE;
    }

    CCVKGPUDevice *_device = nullptr;

    ccstd::vector<VkDescriptorPool> _pools;
    ccstd::vector<VkDescriptorSet> _freeList;

    ccstd::vector<VkDescriptorPoolSize> _poolSizes;
    ccstd::vector<VkDescriptorSetLayout> _setLayouts;
    uint32_t _maxSetsPerPool = 0U;
};

struct CCVKGPUDescriptorSetLayout : public CCVKGPUDeviceObject {
    void shutdown() {
    if (defaultDescriptorSet != VK_NULL_HANDLE) {
        CCVKDevice::getInstance()->gpuRecycleBin()->collect(id, defaultDescriptorSet);
    }

    cmdFuncCCVKDestroyDescriptorSetLayout(CCVKDevice::getInstance()->gpuDevice(), this);
}

    DescriptorSetLayoutBindingList bindings;
    ccstd::vector<uint32_t> dynamicBindings;

    ccstd::vector<VkDescriptorSetLayoutBinding> vkBindings;
    VkDescriptorSetLayout vkDescriptorSetLayout = VK_NULL_HANDLE;
    VkDescriptorUpdateTemplate vkDescriptorUpdateTemplate = VK_NULL_HANDLE;
    VkDescriptorSet defaultDescriptorSet = VK_NULL_HANDLE;

    ccstd::vector<uint32_t> bindingIndices;
    ccstd::vector<uint32_t> descriptorIndices;
    uint32_t descriptorCount = 0U;

    uint32_t id = 0U;
    uint32_t maxSetsPerPool = 10U;
};

/**
 * Command buffer pool based on VkCommandPools, always try to reuse previous allocations first.
 */
class CCVKGPUCommandBufferPool final {
public:
    explicit CCVKGPUCommandBufferPool(CCVKGPUDevice *device)
    : _device(device) {
    }

    ~CCVKGPUCommandBufferPool() {
        for (auto &it : _pools) {
            CommandBufferPool &pool = it.second;
            if (pool.vkCommandPool != VK_NULL_HANDLE) {
                vkDestroyCommandPool(_device->vkDevice, pool.vkCommandPool, nullptr);
                pool.vkCommandPool = VK_NULL_HANDLE;
            }
            for (auto &item: pool.usedCommandBuffers)item.clear();
            for (auto &item: pool.commandBuffers)item.clear();
        }
        _pools.clear();
    }

    uint32_t getHash(uint32_t queueFamilyIndex) {
        return (queueFamilyIndex << 10) | _device->curBackBufferIndex;
    }
    static uint32_t getBackBufferIndex(uint32_t hash) {
        return hash & ((1 << 10) - 1);
    }

    void request(CCVKGPUCommandBuffer *gpuCommandBuffer) {
        uint32_t hash = getHash(gpuCommandBuffer->queueFamilyIndex);

        if (_device->curBackBufferIndex != _lastBackBufferIndex) {
            reset();
            _lastBackBufferIndex = _device->curBackBufferIndex;
        }

        if (!_pools.count(hash)) {
            VkCommandPoolCreateInfo createInfo{VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO};
            createInfo.queueFamilyIndex = gpuCommandBuffer->queueFamilyIndex;
            createInfo.flags = VK_COMMAND_POOL_CREATE_TRANSIENT_BIT;
            VK_CHECK(vkCreateCommandPool(_device->vkDevice, &createInfo, nullptr, &_pools[hash].vkCommandPool));
        }
        CommandBufferPool &pool = _pools[hash];

        CachedArray<VkCommandBuffer> &availableList = pool.commandBuffers[gpuCommandBuffer->level];
        if (availableList.size()) {
            gpuCommandBuffer->vkCommandBuffer = availableList.pop();
        } else {
            VkCommandBufferAllocateInfo allocateInfo{VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO};
            allocateInfo.commandPool = pool.vkCommandPool;
            allocateInfo.commandBufferCount = 1;
            allocateInfo.level = gpuCommandBuffer->level;
            VK_CHECK(vkAllocateCommandBuffers(_device->vkDevice, &allocateInfo, &gpuCommandBuffer->vkCommandBuffer));
        }
    }

    void yield(CCVKGPUCommandBuffer *gpuCommandBuffer) {
        if (gpuCommandBuffer->vkCommandBuffer) {
            uint32_t hash = getHash(gpuCommandBuffer->queueFamilyIndex);
            CC_ASSERT(_pools.count(hash)); // Wrong command pool to yield?

            CommandBufferPool &pool = _pools[hash];
            pool.usedCommandBuffers[gpuCommandBuffer->level].push(gpuCommandBuffer->vkCommandBuffer);
            gpuCommandBuffer->vkCommandBuffer = VK_NULL_HANDLE;
        }
    }

    void reset() {
        for (auto &it : _pools) {
            if (getBackBufferIndex(it.first) != _device->curBackBufferIndex) {
                continue;
            }
            CommandBufferPool &pool = it.second;

            bool needsReset = false;
            for (uint32_t i = 0U; i < 2U; ++i) {
                CachedArray<VkCommandBuffer> &usedList = pool.usedCommandBuffers[i];
                if (usedList.size()) {
                    pool.commandBuffers[i].concat(usedList);
                    usedList.clear();
                    needsReset = true;
                }
            }
            if (needsReset) {
                VK_CHECK(vkResetCommandPool(_device->vkDevice, pool.vkCommandPool, 0));
            }
        }
    }

private:
    struct CommandBufferPool {
        VkCommandPool vkCommandPool = VK_NULL_HANDLE;
        CachedArray<VkCommandBuffer> commandBuffers[2];
        CachedArray<VkCommandBuffer> usedCommandBuffers[2];
    };

    CCVKGPUDevice *_device = nullptr;
    uint32_t _lastBackBufferIndex = 0U;

    ccstd::unordered_map<uint32_t, CommandBufferPool> _pools;
};

/**
 * Staging buffer pool, based on multiple fix-sized VkBuffer blocks.
 */
class CCVKGPUStagingBufferPool final {
public:
    static constexpr VkDeviceSize CHUNK_SIZE = 16 * 1024 * 1024; // 16M per block by default

    explicit CCVKGPUStagingBufferPool(CCVKGPUDevice *device)

    : _device(device) {
    }

    ~CCVKGPUStagingBufferPool() {
        _pool.clear();
    }

    IntrusivePtr<CCVKGPUBufferView> alloc(uint32_t size) { return alloc(size, 1U); }

    IntrusivePtr<CCVKGPUBufferView> alloc(uint32_t size, uint32_t alignment) {
        CC_ASSERT_LE(size, CHUNK_SIZE);

        size_t bufferCount = _pool.size();
        Buffer *buffer = nullptr;
        VkDeviceSize offset = 0U;
        for (size_t idx = 0U; idx < bufferCount; idx++) {
            Buffer *cur = &_pool[idx];
            offset = roundUp(cur->curOffset, alignment);
            if (size + offset <= CHUNK_SIZE) {
                buffer = cur;
                break;
            }
        }
        if (!buffer) {
            _pool.resize(bufferCount + 1);
            buffer = &_pool.back();
            buffer->gpuBuffer = new CCVKGPUBuffer();
            buffer->gpuBuffer->size = CHUNK_SIZE;
            buffer->gpuBuffer->usage = BufferUsage::TRANSFER_SRC | BufferUsage::TRANSFER_DST;
            buffer->gpuBuffer->memUsage = MemoryUsage::HOST;
            buffer->gpuBuffer->init();
            offset = 0U;
        }
        auto *bufferView = new CCVKGPUBufferView;
        bufferView->gpuBuffer = buffer->gpuBuffer;
        bufferView->offset = offset;
        buffer->curOffset = offset + size;
        return bufferView;
    }

    void reset() {
        for (Buffer &buffer : _pool) {
            buffer.curOffset = 0U;
        }
    }

private:
    struct Buffer {
        IntrusivePtr<CCVKGPUBuffer> gpuBuffer;
        VkDeviceSize curOffset = 0U;
    };

    CCVKGPUDevice *_device = nullptr;
    ccstd::vector<Buffer> _pool;
};

/**
 * Manages descriptor set update events, across all back buffer instances.
 */
class CCVKGPUDescriptorSetHub final {
public:
    explicit CCVKGPUDescriptorSetHub(CCVKGPUDevice *device)
    : _device(device) {
        _setsToBeUpdated.resize(device->backBufferCount);
        if (device->minorVersion > 0) {
            _updateFn = vkUpdateDescriptorSetWithTemplate;
        } else {
            _updateFn = vkUpdateDescriptorSetWithTemplateKHR;
        }
    }

    void record(const CCVKGPUDescriptorSet *gpuDescriptorSet) {
        update(gpuDescriptorSet);
        for (uint32_t i = 0U; i < _device->backBufferCount; ++i) {
            if (i == _device->curBackBufferIndex) {
                _setsToBeUpdated[i].erase(gpuDescriptorSet);
            } else {
                _setsToBeUpdated[i].insert(gpuDescriptorSet);
            }
        }
    }

    void erase(CCVKGPUDescriptorSet *gpuDescriptorSet) {
        for (uint32_t i = 0U; i < _device->backBufferCount; ++i) {
            if (_setsToBeUpdated[i].count(gpuDescriptorSet)) {
                _setsToBeUpdated[i].erase(gpuDescriptorSet);
            }
        }
    }

    void flush() {
        DescriptorSetList &sets = _setsToBeUpdated[_device->curBackBufferIndex];
        for (const auto *set : sets) {
            update(set);
        }
        sets.clear();
    }

    void updateBackBufferCount(uint32_t backBufferCount) {
        _setsToBeUpdated.resize(backBufferCount);
    }

private:
    void update(const CCVKGPUDescriptorSet *gpuDescriptorSet) {
        const CCVKGPUDescriptorSet::Instance &instance = gpuDescriptorSet->instances[_device->curBackBufferIndex];
        if (gpuDescriptorSet->gpuLayout->vkDescriptorUpdateTemplate) {
            _updateFn(_device->vkDevice, instance.vkDescriptorSet,
                      gpuDescriptorSet->gpuLayout->vkDescriptorUpdateTemplate, instance.descriptorInfos.data());
        } else {
            const ccstd::vector<VkWriteDescriptorSet> &entries = instance.descriptorUpdateEntries;
            vkUpdateDescriptorSets(_device->vkDevice, utils::toUint(entries.size()), entries.data(), 0, nullptr);
        }
    }

    using DescriptorSetList = ccstd::unordered_set<const CCVKGPUDescriptorSet *>;

    CCVKGPUDevice *_device = nullptr;
    ccstd::vector<DescriptorSetList> _setsToBeUpdated;
    PFN_vkUpdateDescriptorSetWithTemplate _updateFn = nullptr;
};

/**
 * Descriptor data maintenance hub, events like buffer/texture resizing,
 * descriptor set binding change, etc. should all request an update operation here.
 */
class CCVKGPUDescriptorHub final {
public:
    explicit CCVKGPUDescriptorHub(CCVKGPUDevice * /*device*/) {
    }

    void connect(CCVKGPUDescriptorSet *set, const CCVKGPUBufferView *buffer, VkDescriptorBufferInfo *descriptor, uint32_t instanceIdx) {
        _gpuBufferViewSet[buffer].sets.insert(set);
        _gpuBufferViewSet[buffer].descriptors.push(descriptor);
        _bufferInstanceIndices[descriptor] = instanceIdx;
    }
    void connect(CCVKGPUDescriptorSet *set, const CCVKGPUTextureView *texture, VkDescriptorImageInfo *descriptor) {
        _gpuTextureViewSet[texture].sets.insert(set);
        _gpuTextureViewSet[texture].descriptors.push(descriptor);
    }
    void connect(CCVKGPUSampler *sampler, VkDescriptorImageInfo *descriptor) {
        _samplers[sampler].push(descriptor);
    }

    void update(const CCVKGPUBufferView *buffer, VkDescriptorBufferInfo *descriptor) {
        auto it = _gpuBufferViewSet.find(buffer);
        if (it == _gpuBufferViewSet.end()) return;
        auto &descriptors = it->second.descriptors;
        for (uint32_t i = 0U; i < descriptors.size(); i++) {
            if (descriptors[i] == descriptor) {
                doUpdate(buffer, descriptor);
                break;
            }
        }
    }

    void update(const CCVKGPUTextureView *texture, VkDescriptorImageInfo *descriptor) {
        auto it = _gpuTextureViewSet.find(texture);
        if (it == _gpuTextureViewSet.end()) return;
        auto &descriptors = it->second.descriptors;
        for (uint32_t i = 0U; i < descriptors.size(); i++) {
            if (descriptors[i] == descriptor) {
                doUpdate(texture, descriptor);
                break;
            }
        }
    }

    void update(const CCVKGPUTextureView *texture, VkDescriptorImageInfo *descriptor, AccessFlags flags) {
        auto it = _gpuTextureViewSet.find(texture);
        if (it == _gpuTextureViewSet.end()) return;
        auto &descriptors = it->second.descriptors;
        for (uint32_t i = 0U; i < descriptors.size(); i++) {
            if (descriptors[i] == descriptor) {
                doUpdate(texture, descriptor, flags);
                break;
            }
        }
    }

    void update(const CCVKGPUSampler *sampler, VkDescriptorImageInfo *descriptor) {
        auto it = _samplers.find(sampler);
        if (it == _samplers.end()) return;
        auto &descriptors = it->second;
        for (uint32_t i = 0U; i < descriptors.size(); ++i) {
            if (descriptors[i] == descriptor) {
                doUpdate(sampler, descriptor);
                break;
            }
        }
    }
    // for resize events
    void update(const CCVKGPUBufferView *oldView, const CCVKGPUBufferView *newView) {
        auto iter = _gpuBufferViewSet.find(oldView);
        if (iter != _gpuBufferViewSet.end()) {
            auto &sets = iter->second.sets;
            for (auto *set : sets) {
                set->update(oldView, newView);
            }
            _gpuBufferViewSet.erase(iter);
        }
    }

    void update(const CCVKGPUTextureView *oldView, const CCVKGPUTextureView *newView) {
        auto iter = _gpuTextureViewSet.find(oldView);
        if (iter != _gpuTextureViewSet.end()) {
            auto &sets = iter->second.sets;
            for (auto *set : sets) {
                set->update(oldView, newView);
            }
            _gpuTextureViewSet.erase(iter);
        }
    }

    void disengage(const CCVKGPUBufferView *buffer) {
        auto it = _gpuBufferViewSet.find(buffer);
        if (it == _gpuBufferViewSet.end()) return;
        for (uint32_t i = 0; i < it->second.descriptors.size(); ++i) {
            _bufferInstanceIndices.erase(it->second.descriptors[i]);
        }
        _gpuBufferViewSet.erase(it);
    }
    void disengage(CCVKGPUDescriptorSet *set, const CCVKGPUBufferView *buffer, VkDescriptorBufferInfo *descriptor) {
        auto it = _gpuBufferViewSet.find(buffer);
        if (it == _gpuBufferViewSet.end()) return;
        it->second.sets.erase(set);
        auto &descriptors = it->second.descriptors;
        descriptors.fastRemove(descriptors.indexOf(descriptor));
        _bufferInstanceIndices.erase(descriptor);
    }
    void disengage(const CCVKGPUTextureView *texture) {
        auto it = _gpuTextureViewSet.find(texture);
        if (it == _gpuTextureViewSet.end()) return;
        _gpuTextureViewSet.erase(it);
    }
    void disengage(CCVKGPUDescriptorSet *set, const CCVKGPUTextureView *texture, VkDescriptorImageInfo *descriptor) {
        auto it = _gpuTextureViewSet.find(texture);
        if (it == _gpuTextureViewSet.end()) return;
        it->second.sets.erase(set);
        auto &descriptors = it->second.descriptors;
        descriptors.fastRemove(descriptors.indexOf(descriptor));
    }
    void disengage(const CCVKGPUSampler *sampler) {
        auto it = _samplers.find(sampler);
        if (it == _samplers.end()) return;
        _samplers.erase(it);
    }
    void disengage(const CCVKGPUSampler *sampler, VkDescriptorImageInfo *descriptor) {
        auto it = _samplers.find(sampler);
        if (it == _samplers.end()) return;
        auto &descriptors = it->second;
        descriptors.fastRemove(descriptors.indexOf(descriptor));
    }

private:
    void doUpdate(const CCVKGPUBufferView *buffer, VkDescriptorBufferInfo *descriptor) {
        descriptor->buffer = buffer->gpuBuffer->vkBuffer;
        descriptor->offset = buffer->getStartOffset(_bufferInstanceIndices[descriptor]);
        descriptor->range = buffer->range;
    }

    static void doUpdate(const CCVKGPUTextureView *texture, VkDescriptorImageInfo *descriptor) {
        descriptor->imageView = texture->vkImageView;
    }

    static void doUpdate(const CCVKGPUTextureView *texture, VkDescriptorImageInfo *descriptor, AccessFlags flags) {
        descriptor->imageView = texture->vkImageView;
        if (hasFlag(texture->gpuTexture->flags, TextureFlagBit::GENERAL_LAYOUT)) {
            descriptor->imageLayout = VK_IMAGE_LAYOUT_GENERAL;
        } else {
            bool inoutAttachment = hasAllFlags(flags, AccessFlagBit::FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT | AccessFlagBit::COLOR_ATTACHMENT_WRITE) ||
                                   hasAllFlags(flags, AccessFlagBit::FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT | AccessFlagBit::DEPTH_STENCIL_ATTACHMENT_WRITE);
            bool storageWrite = hasAnyFlags(flags, AccessFlagBit::VERTEX_SHADER_WRITE | AccessFlagBit::FRAGMENT_SHADER_WRITE | AccessFlagBit::COMPUTE_SHADER_WRITE);

            if (inoutAttachment || storageWrite) {
                descriptor->imageLayout = VK_IMAGE_LAYOUT_GENERAL;
            } else if (hasFlag(texture->gpuTexture->usage, TextureUsage::DEPTH_STENCIL_ATTACHMENT)) {
                descriptor->imageLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL;
            } else {
                descriptor->imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
            }
        }
    }

    static void doUpdate(const CCVKGPUSampler *sampler, VkDescriptorImageInfo *descriptor) {
        descriptor->sampler = sampler->vkSampler;
    }

    template <typename T>
    struct DescriptorInfo {
        ccstd::unordered_set<CCVKGPUDescriptorSet *> sets;
        CachedArray<T *> descriptors;
    };

    ccstd::unordered_map<const VkDescriptorBufferInfo *, uint32_t> _bufferInstanceIndices;
    ccstd::unordered_map<const CCVKGPUBufferView *, DescriptorInfo<VkDescriptorBufferInfo>> _gpuBufferViewSet;
    ccstd::unordered_map<const CCVKGPUTextureView *, DescriptorInfo<VkDescriptorImageInfo>> _gpuTextureViewSet;
    ccstd::unordered_map<const CCVKGPUSampler *, CachedArray<VkDescriptorImageInfo *>> _samplers;
};

/**
 * Recycle bin for GPU resources, clears after vkDeviceWaitIdle every frame.
 * All the destroy events will be postponed to that time.
 */
class CCVKGPURecycleBin final {
public:
    explicit CCVKGPURecycleBin(CCVKGPUDevice *device)
    : _device(device) {
        _resources.resize(16);
    }

    void collect(const CCVKGPUTexture *texture){
    auto collectHandleFn = [this](VkImage image, VmaAllocation allocation) {
        Resource &res = emplaceBack();
        res.type = RecycledType::TEXTURE;
        res.image.vkImage = image;
        res.image.vmaAllocation = allocation;
    };
    collectHandleFn(texture->vkImage, texture->vmaAllocation);

    if (texture->swapchain != nullptr) {
        for (uint32_t i = 0; i < texture->swapchainVkImages.size() && i < texture->swapchainVmaAllocations.size(); ++i) {
            collectHandleFn(texture->swapchainVkImages[i], texture->swapchainVmaAllocations[i]);
        }
    }
}
    void collect(const CCVKGPUTextureView *textureView){
    auto collectHandleFn = [this](VkImageView view) {
        Resource &res = emplaceBack();
        res.type = RecycledType::TEXTURE_VIEW;
        res.vkImageView = view;
    };
    collectHandleFn(textureView->vkImageView);
    for (const auto &swapChainView : textureView->swapchainVkImageViews) {
        collectHandleFn(swapChainView);
    }
}
    void collect(const CCVKGPUFramebuffer *frameBuffer){
    auto collectHandleFn = [this](VkFramebuffer fbo) {
        Resource &res = emplaceBack();
        res.type = RecycledType::FRAMEBUFFER;
        res.vkFramebuffer = fbo;
    };
    collectHandleFn(frameBuffer->vkFramebuffer);
    for (const auto &fbo : frameBuffer->vkFrameBuffers) {
        collectHandleFn(fbo);
    }
}
    void collect(const CCVKGPUDescriptorSet *set){
    for (const auto &instance : set->instances) {
        collect(set->layoutID, instance.vkDescriptorSet);
    }
}
    void collect(uint32_t layoutId, VkDescriptorSet set){
    Resource &res = emplaceBack();
    res.type = RecycledType::DESCRIPTOR_SET;
    res.set.layoutId = layoutId;
    res.set.vkSet = set;
}
    void collect(const CCVKGPUBuffer *buffer){
    Resource &res = emplaceBack();
    res.type = RecycledType::BUFFER;
    res.buffer.vkBuffer = buffer->vkBuffer;
    res.buffer.vmaAllocation = buffer->vmaAllocation;
}

#define DEFINE_RECYCLE_BIN_COLLECT_FN(_type, typeValue, expr)                        \
    void collect(const _type *gpuRes) { /* NOLINT(bugprone-macro-parentheses) N/A */ \
        Resource &res = emplaceBack();                                               \
        res.type = typeValue;                                                        \
        expr;                                                                        \
    }

    DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPURenderPass, RecycledType::RENDER_PASS, res.vkRenderPass = gpuRes->vkRenderPass)
    DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPUSampler, RecycledType::SAMPLER, res.vkSampler = gpuRes->vkSampler)
    DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPUQueryPool, RecycledType::QUERY_POOL, res.vkQueryPool = gpuRes->vkPool)
    DEFINE_RECYCLE_BIN_COLLECT_FN(CCVKGPUPipelineState, RecycledType::PIPELINE_STATE, res.vkPipeline = gpuRes->vkPipeline)

    void clear(){
    for (uint32_t i = 0U; i < _count; ++i) {
        Resource &res = _resources[i];
        switch (res.type) {
            case RecycledType::BUFFER:
                if (res.buffer.vkBuffer != VK_NULL_HANDLE && res.buffer.vmaAllocation != VK_NULL_HANDLE) {
                    vmaDestroyBuffer(_device->memoryAllocator, res.buffer.vkBuffer, res.buffer.vmaAllocation);
                    res.buffer.vkBuffer = VK_NULL_HANDLE;
                    res.buffer.vmaAllocation = VK_NULL_HANDLE;
                }
                break;
            case RecycledType::TEXTURE:
                if (res.image.vkImage != VK_NULL_HANDLE && res.image.vmaAllocation != VK_NULL_HANDLE) {
                    vmaDestroyImage(_device->memoryAllocator, res.image.vkImage, res.image.vmaAllocation);
                    res.image.vkImage = VK_NULL_HANDLE;
                    res.image.vmaAllocation = VK_NULL_HANDLE;
                }
                break;
            case RecycledType::TEXTURE_VIEW:
                if (res.vkImageView != VK_NULL_HANDLE) {
                    vkDestroyImageView(_device->vkDevice, res.vkImageView, nullptr);
                    res.vkImageView = VK_NULL_HANDLE;
                }
                break;
            case RecycledType::FRAMEBUFFER:
                if (res.vkFramebuffer != VK_NULL_HANDLE) {
                    vkDestroyFramebuffer(_device->vkDevice, res.vkFramebuffer, nullptr);
                    res.vkFramebuffer = VK_NULL_HANDLE;
                }
                break;
            case RecycledType::QUERY_POOL:
                if (res.vkQueryPool != VK_NULL_HANDLE) {
                    vkDestroyQueryPool(_device->vkDevice, res.vkQueryPool, nullptr);
                }
                break;
            case RecycledType::RENDER_PASS:
                if (res.vkRenderPass != VK_NULL_HANDLE) {
                    vkDestroyRenderPass(_device->vkDevice, res.vkRenderPass, nullptr);
                }
                break;
            case RecycledType::SAMPLER:
                if (res.vkSampler != VK_NULL_HANDLE) {
                    vkDestroySampler(_device->vkDevice, res.vkSampler, nullptr);
                }
                break;
            case RecycledType::PIPELINE_STATE:
                if (res.vkPipeline != VK_NULL_HANDLE) {
                    vkDestroyPipeline(_device->vkDevice, res.vkPipeline, nullptr);
                }
                break;
            case RecycledType::DESCRIPTOR_SET:
                if (res.set.vkSet != VK_NULL_HANDLE) {
                    CCVKDevice::getInstance()->gpuDevice()->getDescriptorSetPool(res.set.layoutId)->yield(res.set.vkSet);
                }
                break;
            default: break;
        }
        res.type = RecycledType::UNKNOWN;
    }
    _count = 0;
}

private:
    enum class RecycledType {
        UNKNOWN,
        BUFFER,
        BUFFER_VIEW,
        TEXTURE,
        TEXTURE_VIEW,
        FRAMEBUFFER,
        QUERY_POOL,
        RENDER_PASS,
        SAMPLER,
        PIPELINE_STATE,
        DESCRIPTOR_SET,
        EVENT
    };
    struct Buffer {
        VkBuffer vkBuffer;
        VmaAllocation vmaAllocation;
    };
    struct Image {
        VkImage vkImage;
        VmaAllocation vmaAllocation;
    };
    struct Set {
        uint32_t layoutId;
        VkDescriptorSet vkSet;
    };
    struct Resource {
        RecycledType type = RecycledType::UNKNOWN;
        union {
            // resizable resources, cannot take over directly
            // or descriptor sets won't work
            Buffer buffer;
            Image image;
            Set set;
            VkBufferView vkBufferView;
            VkImageView vkImageView;
            VkFramebuffer vkFramebuffer;
            VkQueryPool vkQueryPool;
            VkRenderPass vkRenderPass;
            VkSampler vkSampler;
            VkEvent vkEvent;
            VkPipeline vkPipeline;
        };
    };

    Resource &emplaceBack() {
        if (_resources.size() <= _count) {
            _resources.resize(_count * 2);
        }
        return _resources[_count++];
    }

    CCVKGPUDevice *_device = nullptr;
    ccstd::vector<Resource> _resources;
    size_t _count = 0U;
};

class CCVKGPUInputAssemblerHub {
public:
    explicit CCVKGPUInputAssemblerHub(CCVKGPUDevice *device)
    : _gpuDevice(device) {
    }

    ~CCVKGPUInputAssemblerHub() = default;

    void connect(CCVKGPUInputAssembler *ia, const CCVKGPUBufferView *buffer) {
        _ias[buffer].insert(ia);
    }

    void update(CCVKGPUBufferView *oldBuffer, CCVKGPUBufferView *newBuffer) {
        auto iter = _ias.find(oldBuffer);
        if (iter != _ias.end()) {
            for (const auto &ia : iter->second) {
                ia->update(oldBuffer, newBuffer);
                _ias[newBuffer].insert(ia);
            }
            _ias.erase(iter);
        }
    }

    void disengage(const CCVKGPUBufferView *buffer) {
        auto iter = _ias.find(buffer);
        if (iter != _ias.end()) {
            _ias.erase(iter);
        }
    }

    void disengage(CCVKGPUInputAssembler *set, const CCVKGPUBufferView *buffer) {
        auto iter = _ias.find(buffer);
        if (iter != _ias.end()) {
            iter->second.erase(set);
        }
    }

private:
    CCVKGPUDevice *_gpuDevice = nullptr;
    ccstd::unordered_map<const CCVKGPUBufferView *, ccstd::unordered_set<CCVKGPUInputAssembler *>> _ias;
};

/**
 * Transport hub for data traveling between host and devices.
 * Record all transfer commands until batched submission.
 */
// #define ASYNC_BUFFER_UPDATE
class CCVKGPUTransportHub final {
public:
    CCVKGPUTransportHub(CCVKGPUDevice *device, CCVKGPUQueue *queue)
    : _device(device),
      _queue(queue) {
        _earlyCmdBuff.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
        _earlyCmdBuff.queueFamilyIndex = _queue->queueFamilyIndex;

        _lateCmdBuff.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
        _lateCmdBuff.queueFamilyIndex = _queue->queueFamilyIndex;

        VkFenceCreateInfo createInfo{VK_STRUCTURE_TYPE_FENCE_CREATE_INFO};
        VK_CHECK(vkCreateFence(_device->vkDevice, &createInfo, nullptr, &_fence));
    }

    ~CCVKGPUTransportHub() {
        if (_fence) {
            vkDestroyFence(_device->vkDevice, _fence, nullptr);
            _fence = VK_NULL_HANDLE;
        }
    }

    bool empty(bool late) const {
        const CCVKGPUCommandBuffer *cmdBuff = late ? &_lateCmdBuff : &_earlyCmdBuff;

        return !cmdBuff->vkCommandBuffer;
    }

    template <typename TFunc>
    void checkIn(const TFunc &record, bool immediateSubmission = false, bool late = false) {
        CCVKGPUCommandBufferPool *commandBufferPool = _device->getCommandBufferPool();
        CCVKGPUCommandBuffer *cmdBuff = late ? &_lateCmdBuff : &_earlyCmdBuff;

        if (!cmdBuff->vkCommandBuffer) {
            commandBufferPool->request(cmdBuff);
            VkCommandBufferBeginInfo beginInfo{VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO};
            beginInfo.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
            VK_CHECK(vkBeginCommandBuffer(cmdBuff->vkCommandBuffer, &beginInfo));
        }

        record(cmdBuff);

        if (immediateSubmission) {
            VK_CHECK(vkEndCommandBuffer(cmdBuff->vkCommandBuffer));
            VkSubmitInfo submitInfo{VK_STRUCTURE_TYPE_SUBMIT_INFO};
            submitInfo.commandBufferCount = 1;
            submitInfo.pCommandBuffers = &cmdBuff->vkCommandBuffer;
            VK_CHECK(vkQueueSubmit(_queue->vkQueue, 1, &submitInfo, _fence));
            VK_CHECK(vkWaitForFences(_device->vkDevice, 1, &_fence, VK_TRUE, DEFAULT_TIMEOUT));
            vkResetFences(_device->vkDevice, 1, &_fence);
            commandBufferPool->yield(cmdBuff);
            cmdBuff->vkCommandBuffer = VK_NULL_HANDLE;
        }
    }

    VkCommandBuffer packageForFlight(bool late) {
        CCVKGPUCommandBuffer *cmdBuff = late ? &_lateCmdBuff : &_earlyCmdBuff;

        VkCommandBuffer vkCommandBuffer = cmdBuff->vkCommandBuffer;
        if (vkCommandBuffer) {
            VK_CHECK(vkEndCommandBuffer(vkCommandBuffer));
            _device->getCommandBufferPool()->yield(cmdBuff);
        }
        return vkCommandBuffer;
    }

private:
    CCVKGPUDevice *_device = nullptr;

    CCVKGPUQueue *_queue = nullptr;
    CCVKGPUCommandBuffer _earlyCmdBuff;
    CCVKGPUCommandBuffer _lateCmdBuff;
    VkFence _fence = VK_NULL_HANDLE;
};

class CCVKGPUBarrierManager final {
public:
    explicit CCVKGPUBarrierManager(CCVKGPUDevice *device)
    : _device(device) {}

    void checkIn(CCVKGPUBuffer *gpuBuffer) {
        _buffersToBeChecked.insert(gpuBuffer);
    }

    void checkIn(CCVKGPUTexture *gpuTexture, const ThsvsAccessType *newTypes = nullptr, uint32_t newTypeCount = 0) {
        ccstd::vector<ThsvsAccessType> &target = gpuTexture->renderAccessTypes;
        for (uint32_t i = 0U; i < newTypeCount; ++i) {
            if (std::find(target.begin(), target.end(), newTypes[i]) == target.end()) {
                target.push_back(newTypes[i]);
            }
        }
        _texturesToBeChecked.insert(gpuTexture);
    }

    void update(CCVKGPUTransportHub *transportHub){
    if (_buffersToBeChecked.empty() && _texturesToBeChecked.empty()) return;

    static ccstd::vector<ThsvsAccessType> prevAccesses;
    static ccstd::vector<ThsvsAccessType> nextAccesses;
    static ccstd::vector<VkImageMemoryBarrier> vkImageBarriers;
    VkPipelineStageFlags srcStageMask = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
    VkPipelineStageFlags dstStageMask = VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
    vkImageBarriers.clear();
    prevAccesses.clear();
    nextAccesses.clear();

    for (CCVKGPUBuffer *gpuBuffer : _buffersToBeChecked) {
        ccstd::vector<ThsvsAccessType> &render = gpuBuffer->renderAccessTypes;
        if (gpuBuffer->transferAccess == THSVS_ACCESS_NONE) continue;
        if (std::find(prevAccesses.begin(), prevAccesses.end(), gpuBuffer->transferAccess) == prevAccesses.end()) {
            prevAccesses.push_back(gpuBuffer->transferAccess);
        }
        nextAccesses.insert(nextAccesses.end(), render.begin(), render.end());
        gpuBuffer->transferAccess = THSVS_ACCESS_NONE;
    }

    VkMemoryBarrier vkBarrier;
    VkMemoryBarrier *pVkBarrier = nullptr;
    if (!prevAccesses.empty()) {
        ThsvsGlobalBarrier globalBarrier{};
        globalBarrier.prevAccessCount = utils::toUint(prevAccesses.size());
        globalBarrier.pPrevAccesses = prevAccesses.data();
        globalBarrier.nextAccessCount = utils::toUint(nextAccesses.size());
        globalBarrier.pNextAccesses = nextAccesses.data();
        VkPipelineStageFlags tempSrcStageMask = 0;
        VkPipelineStageFlags tempDstStageMask = 0;
        thsvsGetVulkanMemoryBarrier(globalBarrier, &tempSrcStageMask, &tempDstStageMask, &vkBarrier);
        srcStageMask |= tempSrcStageMask;
        dstStageMask |= tempDstStageMask;
        pVkBarrier = &vkBarrier;
    }

    ThsvsImageBarrier imageBarrier{};
    imageBarrier.discardContents = false;
    imageBarrier.prevLayout = THSVS_IMAGE_LAYOUT_OPTIMAL;
    imageBarrier.nextLayout = THSVS_IMAGE_LAYOUT_OPTIMAL;
    imageBarrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
    imageBarrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
    imageBarrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
    imageBarrier.subresourceRange.layerCount = VK_REMAINING_ARRAY_LAYERS;
    imageBarrier.prevAccessCount = 1;

    for (CCVKGPUTexture *gpuTexture : _texturesToBeChecked) {
        ccstd::vector<ThsvsAccessType> &render = gpuTexture->renderAccessTypes;
        if (gpuTexture->transferAccess == THSVS_ACCESS_NONE || render.empty()) continue;
        ccstd::vector<ThsvsAccessType> &current = gpuTexture->currentAccessTypes;
        imageBarrier.pPrevAccesses = &gpuTexture->transferAccess;
        imageBarrier.nextAccessCount = utils::toUint(render.size());
        imageBarrier.pNextAccesses = render.data();
        imageBarrier.image = gpuTexture->vkImage;
        imageBarrier.subresourceRange.aspectMask = gpuTexture->aspectMask;

        VkPipelineStageFlags tempSrcStageMask = 0;
        VkPipelineStageFlags tempDstStageMask = 0;
        vkImageBarriers.emplace_back();
        thsvsGetVulkanImageMemoryBarrier(imageBarrier, &tempSrcStageMask, &tempDstStageMask, &(vkImageBarriers.back()));
        srcStageMask |= tempSrcStageMask;
        dstStageMask |= tempDstStageMask;

        // don't override any other access changes since this barrier always happens first
        if (current.size() == 1 && current[0] == gpuTexture->transferAccess) {
            current = render;
        }
        gpuTexture->transferAccess = THSVS_ACCESS_NONE;
    }

    if (pVkBarrier || !vkImageBarriers.empty()) {
        transportHub->checkIn([&](CCVKGPUCommandBuffer *gpuCommandBuffer) {
            vkCmdPipelineBarrier(gpuCommandBuffer->vkCommandBuffer, srcStageMask, dstStageMask, 0,
                                 pVkBarrier ? 1 : 0, pVkBarrier, 0, nullptr, utils::toUint(vkImageBarriers.size()), vkImageBarriers.data());
        });
    }

    _buffersToBeChecked.clear();
    _texturesToBeChecked.clear();
}

    inline void cancel(CCVKGPUBuffer *gpuBuffer) { _buffersToBeChecked.erase(gpuBuffer); }
    inline void cancel(CCVKGPUTexture *gpuTexture) { _texturesToBeChecked.erase(gpuTexture); }

private:
    ccstd::unordered_set<CCVKGPUBuffer *> _buffersToBeChecked;
    ccstd::unordered_set<CCVKGPUTexture *> _texturesToBeChecked;
    CCVKGPUDevice *_device = nullptr;
};

/**
 * Manages buffer update events, across all back buffer instances.
 */
class CCVKGPUBufferHub final {
public:
    explicit CCVKGPUBufferHub(CCVKGPUDevice *device)
    : _device(device) {
        _buffersToBeUpdated.resize(device->backBufferCount);
    }

    void record(CCVKGPUBuffer *gpuBuffer, uint32_t backBufferIndex, size_t size, bool canMemcpy) {
        for (uint32_t i = 0U; i < _device->backBufferCount; ++i) {
            if (i == backBufferIndex) {
                _buffersToBeUpdated[i].erase(gpuBuffer);
            } else {
                _buffersToBeUpdated[i][gpuBuffer] = {backBufferIndex, size, canMemcpy};
            }
        }
    }

    void erase(CCVKGPUBuffer *gpuBuffer) {
        for (uint32_t i = 0U; i < _device->backBufferCount; ++i) {
            if (_buffersToBeUpdated[i].count(gpuBuffer)) {
                _buffersToBeUpdated[i].erase(gpuBuffer);
            }
        }
    }

    void updateBackBufferCount(uint32_t backBufferCount) {
        _buffersToBeUpdated.resize(backBufferCount);
    }

    void flush(CCVKGPUTransportHub *transportHub){
    auto &buffers = _buffersToBeUpdated[_device->curBackBufferIndex];
    if (buffers.empty()) return;

    bool needTransferCmds = false;
    for (auto &buffer : buffers) {
        if (buffer.second.canMemcpy) {
            uint8_t *src = buffer.first->mappedData + buffer.second.srcIndex * buffer.first->instanceSize;
            uint8_t *dst = buffer.first->mappedData + _device->curBackBufferIndex * buffer.first->instanceSize;
            memcpy(dst, src, buffer.second.size);
        } else {
            needTransferCmds = true;
        }
    }
    if (needTransferCmds) {
        transportHub->checkIn([&](const CCVKGPUCommandBuffer *gpuCommandBuffer) {
            VkBufferCopy region;
            for (auto &buffer : buffers) {
                if (buffer.second.canMemcpy) continue;
                region.srcOffset = buffer.first->getStartOffset(buffer.second.srcIndex);
                region.dstOffset = buffer.first->getStartOffset(_device->curBackBufferIndex);
                region.size = buffer.second.size;
                vkCmdCopyBuffer(gpuCommandBuffer->vkCommandBuffer, buffer.first->vkBuffer, buffer.first->vkBuffer, 1, &region);
            }
        });
    }

    buffers.clear();
}

private:
    struct BufferUpdate {
        uint32_t srcIndex = 0U;
        size_t size = 0U;
        bool canMemcpy = false;
    };

    ccstd::vector<ccstd::unordered_map<CCVKGPUBuffer *, BufferUpdate>> _buffersToBeUpdated;

    CCVKGPUDevice *_device = nullptr;
};

} // namespace gfx
} // namespace cc
