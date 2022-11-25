using Sedulous.Core;
using System;
using Sedulous.Foundation.Logging.Abstractions;
using Sedulous.Foundation.Logging.Debug;
using System.Threading;
using Sedulous.Foundation.Mathematics;
using Sedulous.SDL;
using Sedulous.NRI;
using Sedulous.NRI.Validation;
using Sedulous.Graphics;

namespace Sedulous.Sandbox;

static
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

class SandboxApplication
{
	private readonly ILogger mLogger = new DebugLogger(.Trace) ~ delete _;



	protected void OnInitialized(Engine engine)
	{
		engine.Jobs.AddJob(new () =>
			{
				Thread.Sleep(1000);
				mLogger.LogInformation("Loading Task 1 finished.");
			}, "Load Task 1");

		engine.Jobs.AddJob(new () =>
			{
				Thread.Sleep(1000);
				mLogger.LogInformation("Loading Task 2 finished.");
			}, "Load Task 2");

		engine.Jobs.AddJob(new () =>
			{
				mLogger.LogInformation("Loading on main thread started.");
				Thread.Sleep(5000);
				mLogger.LogInformation("Loading on main thread finished.");
			}, "Load Content", .RunOnMainThread);

		/*engine.Jobs.AddJob(new () =>
			{
				mLogger.LogInformation("Stop application.");
				Thread.Sleep(6000);
				this.Exit();
				mLogger.LogInformation("Stop application job completed.");
			}, "Stopping application", .RunOnMainThread);*/
	}

	public void Run()
	{
		GraphicsAPI graphicsAPI = .VULKAN;

		var windowSystem = scope SDLWindowSystem();

		var primaryWindow = windowSystem.CreateWindow("Sandbox", 1280, 720, true, graphicsAPI, .. ?);
		defer windowSystem.DestroyWindow(primaryWindow);

		DeviceCreationDesc deviceDesc = .()
			{
				graphicsAPI = graphicsAPI,
				enableAPIValidation = true,
				enableNRIValidation = true,
				D3D11CommandBufferEmulation = D3D11_COMMANDBUFFER_EMULATION,
				spirvBindingOffsets = SPIRV_BINDING_OFFSETS
			};

		Result result = .SUCCESS;

		result = CreateDevice(deviceDesc, var device);
		if (result != .SUCCESS)
		{
			return;
		}

		var graphicsPlugin = scope GraphicsPlugin(primaryWindow);

		defer { DestroyDevice(device); }
		{
			var engine = scope Engine(mLogger);

			engine.Configure(scope (config) =>
				{
					config.AddPlugin(graphicsPlugin);
				});

			engine.Initialize();

			OnInitialized(engine);

			windowSystem.RunMainLoop(scope => engine.Update);

			engine.Shutdown();
		}
	}
}