using NRI.Framework.SDL;
using System.Collections;
using System.Diagnostics;
using System;
using NRI;
using NRI.Framework;
namespace Samples.Clear;

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

class ClearApplication : NRIApplication
{
	private SwapChain mSwapChain = null;
	private CommandQueue mCommandQueue = null;
	private QueueSemaphore mAcquireSemaphore = null;
	private QueueSemaphore mReleaseSemaphore = null;

	private Frame[BUFFERED_FRAME_MAX_NUM] mFrames = .();
	private List<BackBuffer> mSwapChainBuffers = new .() ~ delete _;

	private uint32 mSwapInterval = 0;

	private uint32 mFrameNum = uint32.MaxValue;
	
	public this(Window window, GraphicsAPI graphicsAPI)
		: base(window, graphicsAPI)
	{
	}

	protected override Result<void> OnInitialize()
	{
		if (base.OnInitialize() case .Err)
			return .Err;

		var result = mDevice.GetCommandQueue(.GRAPHICS, out mCommandQueue);
		if (result != .SUCCESS)
			return .Err;

		// Swap chain
		Format swapChainFormat = default;
		{
			SwapChainDesc swapChainDesc = .();
			swapChainDesc.windowSystemType = .WINDOWS;
			swapChainDesc.window = .()
				{
					windows = WindowsWindow()
						{
							hwnd = Window.SurfaceInfo.windows.hwnd
						}
				};
			swapChainDesc.commandQueue = mCommandQueue;
			swapChainDesc.format = SwapChainFormat.BT709_G22_8BIT;
			swapChainDesc.verticalSyncInterval = mSwapInterval;
			swapChainDesc.width = (.)Window.Width;
			swapChainDesc.height = (.)Window.Height;
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

	protected override void OnFinalize()
	{
		mCommandQueue.WaitForIdle();

		for (ref Frame frame in ref mFrames)
		{
			mDevice.DestroyCommandBuffer(frame.commandBuffer);
			mDevice.DestroyCommandAllocator(frame.commandAllocator);
			mDevice.DestroyDeviceSemaphore(frame.deviceSemaphore);
		}

		for (ref BackBuffer backBuffer in ref mSwapChainBuffers)
		{
			mDevice.DestroyFrameBuffer(backBuffer.frameBuffer);
			mDevice.DestroyDescriptor(backBuffer.colorAttachment);
		}

		mDevice.DestroyQueueSemaphore(mAcquireSemaphore);
		mDevice.DestroyQueueSemaphore(mReleaseSemaphore);
		mDevice.DestroySwapChain(mSwapChain);

		base.OnFinalize();
	}

	private void PrepareFrame(uint32 frameIndex)
	{
	}

	private void RenderFrame(uint32 frameIndex)
	{
		readonly uint32 windowWidth = Window.Width;
		readonly uint32 windowHeight = Window.Height;
		readonly uint32 bufferedFrameIndex = frameIndex % BUFFERED_FRAME_MAX_NUM;
		readonly ref Frame frame = ref mFrames[bufferedFrameIndex];

		readonly uint32 backBufferIndex = mSwapChain.AcquireNextTexture(ref mAcquireSemaphore);
		readonly ref BackBuffer backBuffer = ref mSwapChainBuffers[backBufferIndex];

		mCommandQueue.WaitForSemaphore(frame.deviceSemaphore);
		frame.commandAllocator.Reset();

		CommandBuffer commandBuffer = frame.commandBuffer;
		commandBuffer.Begin(null, 0);
		{
			TextureTransitionBarrierDesc textureTransitionBarrierDesc = .();
			textureTransitionBarrierDesc.texture = backBuffer.texture;
			textureTransitionBarrierDesc.prevAccess = AccessBits.UNKNOWN;
			textureTransitionBarrierDesc.nextAccess = AccessBits.COLOR_ATTACHMENT;
			textureTransitionBarrierDesc.prevLayout = TextureLayout.UNKNOWN;
			textureTransitionBarrierDesc.nextLayout = TextureLayout.COLOR_ATTACHMENT;
			textureTransitionBarrierDesc.arraySize = 1;
			textureTransitionBarrierDesc.mipNum = 1;

			TransitionBarrierDesc transitionBarriers = .();
			transitionBarriers.textureNum = 1;
			transitionBarriers.textures = &textureTransitionBarrierDesc;
			commandBuffer.PipelineBarrier(&transitionBarriers, null, BarrierDependency.ALL_STAGES);

			commandBuffer.BeginRenderPass(backBuffer.frameBuffer, RenderPassBeginFlag.NONE);
			{
				commandBuffer.BeginAnnotation("Clear");

				ClearDesc clearDesc = .();
				clearDesc.colorAttachmentIndex = 0;

				clearDesc.value.rgba32f = .() { r = 1.0f, g = 0.0f, b = 0.0f, a = 1.0f };
				Rect rect1 = .() { left = 0, top = 0, width = windowWidth, height = windowHeight / 3 };
				commandBuffer.ClearAttachments(&clearDesc, 1, &rect1, 1);

				clearDesc.value.rgba32f = .() { r = 0.0f, g = 1.0f, b = 0.0f, a = 1.0f };
				Rect rect2 = .() { left = 0, top = (.)windowHeight / 3, width = windowWidth, height = windowHeight / 3 };
				commandBuffer.ClearAttachments(&clearDesc, 1, &rect2, 1);

				clearDesc.value.rgba32f = .() { r = 0.0f, g = 0.0f, b = 1.0f, a = 1.0f };
				Rect rect3 = .() { left = 0, top = (.)(windowHeight * 2) / 3, width = windowWidth, height = windowHeight / 3 };
				commandBuffer.ClearAttachments(&clearDesc, 1, &rect3, 1);
			}
			commandBuffer.EndRenderPass();

			textureTransitionBarrierDesc.prevAccess = textureTransitionBarrierDesc.nextAccess;
			textureTransitionBarrierDesc.nextAccess = AccessBits.UNKNOWN;
			textureTransitionBarrierDesc.prevLayout = textureTransitionBarrierDesc.nextLayout;
			textureTransitionBarrierDesc.nextLayout = TextureLayout.PRESENT;

			commandBuffer.PipelineBarrier(&transitionBarriers, null, BarrierDependency.ALL_STAGES);
		}
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

	protected override void OnFrame()
	{
		base.OnFrame();

		PrepareFrame(mFrameNum);
		RenderFrame(mFrameNum);
		mFrameNum++;
	}

}