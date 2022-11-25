using Sedulous.NRI;
using Sedulous.Core;
using System.Collections;
using Sedulous.Platform;
namespace Sedulous.Graphics;

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
}

struct BackBuffer
{
	public FrameBuffer frameBuffer;
	public Descriptor colorAttachment;
	public Texture texture;
}

struct Frame
{
	public DeviceSemaphore deviceSemaphore;
	public CommandAllocator commandAllocator;
	public CommandBuffer commandBuffer;
}

class GraphicsSystem
{
	private readonly Engine mEngine;
	private readonly Window mWindow;
	private readonly Device mDevice;

	private SwapChain mSwapChain = null;
	private CommandQueue mCommandQueue = null;
	private QueueSemaphore mAcquireSemaphore = null;
	private QueueSemaphore mReleaseSemaphore = null;

	private Frame[BUFFERED_FRAME_MAX_NUM] mFrames = .();
	private List<BackBuffer> mSwapChainBuffers = new .() ~ delete _;

	private uint32 mSwapInterval = 0;

	private uint32 mCurrentBackBufferIndex = 0;

	public Window Window { get => mWindow; }

	public this(Engine engine, Window window, Device device)
	{
		mEngine = engine;
		mDevice = device;
		mWindow = window;
	}

	public void Startup()
	{
		CreateSwapChainResources();
	}

	public void Shutdown()
	{
		mCommandQueue.WaitForIdle();
		DestroySwapChainResources();
	}

	public ref BackBuffer GetCurrentBackBuffer()
	{
		return ref mSwapChainBuffers[mCurrentBackBufferIndex];
	}

	public ref Frame BeginFrame(uint32 frameIndex)
	{
		readonly uint32 bufferedFrameIndex = frameIndex % BUFFERED_FRAME_MAX_NUM;
		ref Frame frame = ref mFrames[bufferedFrameIndex];

		mCurrentBackBufferIndex = mSwapChain.AcquireNextTexture(ref mAcquireSemaphore);

		mCommandQueue.WaitForSemaphore(frame.deviceSemaphore);
		frame.commandAllocator.Reset();

		CommandBuffer commandBuffer = frame.commandBuffer;
		commandBuffer.Begin(null, 0);

		return ref frame;
	}

	public void EndFrame(ref Frame frame)
	{
		CommandBuffer commandBuffer = frame.commandBuffer;
		commandBuffer.End();

		readonly CommandBuffer[] commandBuffers = scope .(commandBuffer);

		WorkSubmissionDesc workSubmissionDesc = .()
			{
				commandBufferNum = (.)commandBuffers.Count,
				commandBuffers = commandBuffers.Ptr,
				wait = &mAcquireSemaphore,
				waitNum = 1,
				signal = &mReleaseSemaphore,
				signalNum = 1
			};

		mCommandQueue.SubmitWork(workSubmissionDesc, frame.deviceSemaphore);
		mSwapChain.Present(mReleaseSemaphore);
	}

	public void Resize(uint32 width, uint32 height)
	{
		mCommandQueue.WaitForIdle();
		DestroySwapChainResources();
		CreateSwapChainResources();
	}

	private System.Result<void> CreateSwapChainResources()
	{
		var result = mDevice.GetCommandQueue(.GRAPHICS, out mCommandQueue);
		if (result != .SUCCESS)
			return .Err;

		// Swap chain
		Format swapChainFormat = default;
		{
			SwapChainDesc swapChainDesc = .();
			swapChainDesc.windowSystemType = .WINDOWS;
			swapChainDesc.window = mWindow.SurfaceInfo.Handle;
			swapChainDesc.commandQueue = mCommandQueue;
			swapChainDesc.format = SwapChainFormat.BT709_G22_8BIT;
			swapChainDesc.verticalSyncInterval = mSwapInterval;
			swapChainDesc.width = (.)mWindow.Width;
			swapChainDesc.height = (.)mWindow.Height;
			swapChainDesc.textureNum = SWAP_CHAIN_TEXTURE_NUM;
			result = mDevice.CreateSwapChain(swapChainDesc, out mSwapChain);
			if (result != .SUCCESS)
				return .Err;

			uint32 swapChainTextureNum = 0;
			Texture* swapChainTextures = mSwapChain.GetTextures(ref swapChainTextureNum, ref swapChainFormat);

			for (uint32 i = 0; i < swapChainTextureNum; i++)
			{
				Texture2DViewDesc textureViewDesc = .() { texture = swapChainTextures[i], viewType = Texture2DViewType.COLOR_ATTACHMENT, format = swapChainFormat };

				Descriptor colorAttachment = null;
				result = mDevice.CreateTexture2DView(textureViewDesc, out colorAttachment);

				FrameBufferDesc frameBufferDesc = .()
					{
						colorAttachmentNum = 1,
						colorAttachments = &colorAttachment
					};
				FrameBuffer frameBuffer = null;
				result = mDevice.CreateFrameBuffer(frameBufferDesc, out frameBuffer);

				readonly BackBuffer backBuffer = .() { frameBuffer = frameBuffer, colorAttachment =  colorAttachment, texture = swapChainTextures[i] };
				mSwapChainBuffers.Add(backBuffer);
			}
		}

		result = mDevice.CreateQueueSemaphore(out mAcquireSemaphore);
		result = mDevice.CreateQueueSemaphore(out mReleaseSemaphore);

		// Buffered resources
		for (ref Frame frame in ref mFrames)
		{
			result = mDevice.CreateDeviceSemaphore(true, out frame.deviceSemaphore);
			result = mDevice.CreateCommandAllocator(mCommandQueue, WHOLE_DEVICE_GROUP, out frame.commandAllocator);
			result = frame.commandAllocator.CreateCommandBuffer(out frame.commandBuffer);
		}

		return .Ok;
	}

	private void DestroySwapChainResources()
	{
		for (ref Frame frame in ref mFrames)
		{
			mDevice.DestroyCommandBuffer(frame.commandBuffer);
			mDevice.DestroyCommandAllocator(frame.commandAllocator);
			mDevice.DestroyDeviceSemaphore(frame.deviceSemaphore);
			frame = .();
		}

		for (ref BackBuffer backBuffer in ref mSwapChainBuffers)
		{
			mDevice.DestroyFrameBuffer(backBuffer.frameBuffer);
			mDevice.DestroyDescriptor(backBuffer.colorAttachment);
		}
		mSwapChainBuffers.Clear();

		mDevice.DestroyQueueSemaphore(mAcquireSemaphore);
		mDevice.DestroyQueueSemaphore(mReleaseSemaphore);
		mDevice.DestroySwapChain(mSwapChain);
	}
}