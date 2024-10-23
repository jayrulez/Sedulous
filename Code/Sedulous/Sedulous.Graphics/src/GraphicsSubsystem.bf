using Sedulous.Core;
using System;
using Sedulous.RHI;
using Sedulous.Platform;
using Sedulous.Graphics.FrameGraph;
using System.Collections;
using Sedulous.Graphics.SceneGraph;
namespace Sedulous.Graphics;

class GraphicsSubsystem : Subsystem
{
	public override StringView Name => "Graphics";

	private readonly GraphicsContext mGraphicsContext;
	private readonly IWindow mPrimaryWindow;

	private IContext.RegisteredUpdateFunctionInfo? mUpdateFunctionRegistration;
	private IContext.RegisteredUpdateFunctionInfo? mRenderFunctionRegistration;

	private CommandQueue mCommandQueue;
	private SwapChain mSwapChain;
	private readonly FrameGraph mFrameGraph;
	private readonly List<GraphicsSceneModule> mSceneModules = new .() ~ delete _;

	public this(GraphicsContext graphicsContext, IWindow primaryWindow)
	{
		mGraphicsContext = graphicsContext;
		mPrimaryWindow = primaryWindow;
		mFrameGraph = new .(mGraphicsContext);
	}

	public ~this()
	{
		delete mFrameGraph;
	}

	protected override Result<void> OnInitializing(IContext context)
	{
		mUpdateFunctionRegistration = context.RegisterUpdateFunction(.()
		{
			Priority = 1,
			Stage = .VariableUpdate,
			Function = new => OnUpdate
		});

		mRenderFunctionRegistration = context.RegisterUpdateFunction(.()
		{
			Priority = 1,
			Stage = .PostUpdate,
			Function = new => OnRender
		});

		SwapChainDescription swapChainDescription = CreateSwapChainDescription((.)mPrimaryWindow.ClientSize.Width, (.)mPrimaryWindow.ClientSize.Height, ref mPrimaryWindow.SurfaceInfo);
		mSwapChain = mGraphicsContext.CreateSwapChain(swapChainDescription);

		mCommandQueue = mGraphicsContext.Factory.CreateCommandQueue();

		mPrimaryWindow.SizeChanged.Subscribe(new (window) =>
			{
				int32 width = window.ClientSize.Width;
				int32 height = window.ClientSize.Height;
				mSwapChain.ResizeSwapChain((.)width, (.)height);
			});

		return base.OnInitializing(context);
	}

	protected override void OnUnitializing(IContext context)
	{
		mCommandQueue.WaitIdle();

		mCommandQueue.Dispose();
		mSwapChain.Dispose();

		mGraphicsContext.Factory.DestroyCommandQueue(ref mCommandQueue);
		delete mSwapChain;

		if(mUpdateFunctionRegistration.HasValue)
		{
			context.UnregisterUpdateFunction(mUpdateFunctionRegistration.Value);
			delete mUpdateFunctionRegistration.Value.Function;
			mUpdateFunctionRegistration = null;
		}

		base.OnUnitializing(context);
	}

	private void OnUpdate(IContext.UpdateInfo info)
	{
		
		for(var module in mSceneModules)
		{

		}

		mFrameGraph.Build();
		//info.Context.Logger.LogInformation("System: {0}, Update", nameof(GraphicsSubsystem));
	}

	private void OnRender(IContext.UpdateInfo info)
	{
		// begin frame

		mFrameGraph.Execute(mCommandQueue);

		mCommandQueue.Submit();
		mCommandQueue.WaitIdle();

		mSwapChain.Present();


		// end frame
	}

	private static TextureSampleCount SampleCount = TextureSampleCount.None;

	private static SwapChainDescription CreateSwapChainDescription(uint32 width, uint32 height, ref SurfaceInfo surfaceInfo)
	{
		return SwapChainDescription()
			{
				Width = width,
				Height = height,
				SurfaceInfo = surfaceInfo,
				ColorTargetFormat = PixelFormat.R8G8B8A8_UNorm,
				ColorTargetFlags = TextureFlags.RenderTarget | TextureFlags.ShaderResource,
				DepthStencilTargetFormat = PixelFormat.D24_UNorm_S8_UInt,
				DepthStencilTargetFlags = TextureFlags.DepthStencil,
				SampleCount = SampleCount,
				IsWindowed = true,
				RefreshRate = 60
			};
	}
}