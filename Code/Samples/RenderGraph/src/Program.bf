using Sedulous.Platform.Desktop;
using Sedulous.RHI;
using Sedulous.Core;
using Sedulous.Foundation.Mathematics;
using System;
using System.IO;
using System.Collections;
using Sedulous.Platform;
using Sedulous.RHI.DirectX12;
using Sedulous.RHI.Vulkan;
using Sedulous.Foundation.Logging.Abstractions;
using Sedulous.Foundation.Logging.Console;
using Sedulous.Graphics.FrameGraph;
using static Sedulous.Core.IContext;
namespace RenderGraph;

class GeometryPass : RenderPass
{
	public this(StringView name) : base(name)
	{

	}

	public override void Setup()
	{

	}

	public override void Execute(CommandBuffer commandBuffer)
	{

	}
}

class RHIApplication
{
	private const GraphicsBackend GraphicsBackend = .Vulkan;

	private IContext.RegisteredUpdateFunctionInfo? mUpdateFunctionRegistration;

	private readonly ILogger mLogger = new ConsoleLogger(.Trace) ~ delete _;
	private readonly ValidationLayer mValidationLayer = new .(mLogger) ~ delete _;
	private readonly GraphicsContext mGraphicsContext ~ delete _;
	private SwapChain mSwapChain = null;
	private CommandQueue mCommandQueue = null;
	private FrameGraph mFrameGraph = null;
	private GeometryPass mGeometryPass;
	//private Buffer mVertexBuffer;
	//private InputLayouts mVertexLayouts = null;
	//private GraphicsPipelineState mGraphicsPipelineState = null;
	//private Viewport[] mViewports = null;
	//private Rectangle[] mScissors = null;

	private readonly IPlatformBackend mHost;

	public this(IPlatformBackend host)
	{
		mHost = host;
		switch(GraphicsBackend)
		{
		case .DirectX12:
			mGraphicsContext = new DX12GraphicsContext();
			break;
		case .Vulkan:
			mGraphicsContext = new VKGraphicsContext();
			break;
		default:
			Runtime.FatalError("Backend not supported yet.");
		}
	}

	/*private static Vector4[] VertexData = new Vector4[]
		( // TriangleList
		Vector4(0f, 0.5f, 0.0f, 1.0f), Vector4(1.0f, 0.0f, 0.0f, 1.0f),
		Vector4(0.5f, -0.5f, 0.0f, 1.0f), Vector4(0.0f, 1.0f, 0.0f, 1.0f),
		Vector4(-0.5f, -0.5f, 0.0f, 1.0f), Vector4(0.0f, 0.0f, 1.0f, 1.0f)
		) ~ delete _;*/

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

	public Result<void> Initializing(ContextInitializer initializer)
	{
		return .Ok;
	}

	public void Initialized(IContext context)
	{
		mUpdateFunctionRegistration = context.RegisterUpdateFunction(.()
			{
				Priority = 1,
				Function = new  => Update,
				Stage = .FixedUpdate
			});

		var window = mHost.Windows.GetPrimary();

		mGraphicsContext.CreateDevice(mValidationLayer);

		SwapChainDescription swapChainDescription = CreateSwapChainDescription((.)window.ClientSize.Width, (.)window.ClientSize.Height, ref window.SurfaceInfo);
		mSwapChain = mGraphicsContext.CreateSwapChain(swapChainDescription);

		mCommandQueue = mGraphicsContext.Factory.CreateCommandQueue();

		mFrameGraph = new .(mGraphicsContext);

		mFrameGraph.AddResource(mSwapChain.FrameBuffer);

		mGeometryPass = new .("Geometry");

		mFrameGraph.AddPass(mGeometryPass);

		mFrameGraph.Build();

		window.Drawing.Subscribe(new (window, time) =>
			{
				mFrameGraph.Execute(mCommandQueue.CommandBuffer());
			});

		window.SizeChanged.Subscribe(new (window) =>
			{
				int32 width = window.ClientSize.Width;
				int32 height = window.ClientSize.Height;
				//mFrameGraph.Resize(); ??
				mSwapChain.ResizeSwapChain((.)width, (.)height);
			});
	}

	public void ShuttingDown(IContext context)
	{
		mCommandQueue.WaitIdle();

		mSwapChain.Dispose();
		mGraphicsContext.Dispose();

		delete mGeometryPass;
		delete mFrameGraph;

		mGraphicsContext.Factory.DestroyCommandQueue(ref mCommandQueue);
		delete mSwapChain;

		if (mUpdateFunctionRegistration.HasValue)
		{
			context.UnregisterUpdateFunction(mUpdateFunctionRegistration.Value);
			delete mUpdateFunctionRegistration.Value.Function;
			mUpdateFunctionRegistration = null;
		}
	}

	private void Update(UpdateInfo info)
	{
		info.Context.Logger.LogInformation(scope $"{info.Time.ElapsedTime} : Application Update");

		if (mHost.Input.GetKeyboard().IsKeyPressed(.Escape))
		{
			mHost.Exit();
		}
	}
}

class Program
{
	static void Main()
	{
		var host = scope DesktopPlatformBackend(.()
			{
				PrimaryWindowConfiguration = .()
					{
						Title = "RHI"
					}
			});

		var app = scope RHIApplication(host);

		host.Run(
			initializingCallback: scope => app.Initializing,
			initializedCallback: scope => app.Initialized,
			shuttingDownCallback: scope => app.ShuttingDown
			);
	}
}