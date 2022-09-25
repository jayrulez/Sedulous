using System;
using System.Diagnostics;
using NRI.Validation;
using NRI.D3D12;
namespace NRI.Framework;

public static
{
	public static SPIRVBindingOffsets SPIRV_BINDING_OFFSETS = .()
		{
			samplerOffset = 100,
			textureOffset = 200,
			constantBufferOffset = 300,
			storageTextureAndBufferOffset = 400
		};
	public const bool D3D11_COMMANDBUFFER_EMULATION = false;
	public const uint32 DEFAULT_MEMORY_ALIGNMENT = 16;
	public const uint32 BUFFERED_FRAME_MAX_NUM = 2;
	public const uint32 SWAP_CHAIN_TEXTURE_NUM = BUFFERED_FRAME_MAX_NUM;

	public static Result CreateDevice(DeviceCreationDesc deviceDesc, out Device device)
	{
		Result result = .SUCCESS;


		DeviceLogger logger = new .(deviceDesc.graphicsAPI, deviceDesc.callbackInterface);
		DeviceAllocator<uint8> allocator = new .(deviceDesc.memoryAllocatorInterface);

		if (deviceDesc.graphicsAPI == .VULKAN)
		{
			result = NRI.Vulkan.CreateDeviceVK(logger, allocator, deviceDesc, out device);
		} else if (deviceDesc.graphicsAPI == .D3D12)
		{
			result = NRI.D3D12.CreateDeviceD3D12(logger, allocator, deviceDesc, out device);
		} else
		{
			Runtime.FatalError(scope $"GraphicsAPI {deviceDesc.graphicsAPI} is not supported.");
		}

		if (deviceDesc.enableNRIValidation)
		{
			Device deviceVal = null;

			result = CreateDeviceValidation(deviceDesc, device, out deviceVal);
			if (result != .SUCCESS)
			{
				DestroyDevice(device);

				device = null;

				return .FAILURE;
			}

			device = deviceVal;
		}

		return result;
	}

	public static void DestroyDevice(Device device)
	{
		DeviceAllocator<uint8> allocator = device.GetAllocator();
		DeviceLogger logger = device.GetLogger();

		device.Destroy();

		delete allocator;

		delete logger;
	}
}

class NRIApplication : Application
{
	protected Window Window { get; private set; }
	protected GraphicsAPI GraphicsAPI = .VULKAN;

	protected Device mDevice = null;

	public this(Window window, GraphicsAPI graphicsAPI)
	{
		Window = window;
		GraphicsAPI = graphicsAPI;
	}

	protected override Result<void> OnStartup()
	{
		if (base.OnStartup() case .Err)
			return .Err;

		DeviceCreationDesc deviceDesc = .()
			{
				graphicsAPI = GraphicsAPI,
				enableAPIValidation = true,
				enableNRIValidation = true,
				D3D11CommandBufferEmulation = D3D11_COMMANDBUFFER_EMULATION,
				spirvBindingOffsets = SPIRV_BINDING_OFFSETS
			};

		Result result = .SUCCESS;

		result = CreateDevice(deviceDesc, out mDevice);

		if (result != .SUCCESS)
		{
			Debug.WriteLine("Failed to create Device");
			return .Err;
		}

		return .Ok;
	}

	protected override void OnShutdown()
	{
		DestroyDevice(mDevice);

		base.OnShutdown();
	}
}