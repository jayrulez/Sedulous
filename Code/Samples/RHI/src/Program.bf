using Sedulous.Platform.Desktop;
using Sedulous.Foundation.Utilities;
using Sedulous.Platform;
using Sedulous.Core;
using System;
using Sedulous.RHI;
using Sedulous.RHI.Vulkan;
using Sedulous.Foundation.Mathematics;
using static Sedulous.Core.IContext;
namespace RHI;

class RHIApplication
{
	private readonly UpdateFunctionInfo mUpdateFunctionInfo = .()
		{
			Priority = 1,
			Function = new  => Update,
			Stage = .FixedUpdate
		} ~ delete _.Function;

	private readonly ValidationLayer mValidationLayer = new .(.Trace) ~ delete _;
	private readonly VKGraphicsContext mGraphicsContext = new .() ~ delete _;
	private SwapChain mSwapChain = null;
	private CommandQueue mCommandQueue = null;
	private Buffer mVertexBuffer;
	private InputLayouts mVertexLayouts = null;
	private GraphicsPipelineState mGraphicsPipelineState = null;

	private readonly IPlatformBackend mHost;

	public this(IPlatformBackend host)
	{
		mHost = host;
	}

	private static Vector4[] VertexData = new Vector4[]
		(
		// TriangleList
		Vector4(0f, 0.5f, 0.0f, 1.0f), Vector4(1.0f, 0.0f, 0.0f, 1.0f),
		Vector4(0.5f, -0.5f, 0.0f, 1.0f), Vector4(0.0f, 1.0f, 0.0f, 1.0f),
		Vector4(-0.5f, -0.5f, 0.0f, 1.0f), Vector4(0.0f, 0.0f, 1.0f, 1.0f)
		) ~ delete _;

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
		context.RegisterUpdateFunction(mUpdateFunctionInfo);

		var window = mHost.Windows.GetPrimary();

		window.Drawing.Subscribe(new (window, time) =>
			{
				Render();
			});

		mGraphicsContext.CreateDevice(mValidationLayer);

		SwapChainDescription swapChainDescription = CreateSwapChainDescription((.)window.ClientSize.Width, (.)window.ClientSize.Height, ref window.SurfaceInfo);
		mSwapChain = mGraphicsContext.CreateSwapChain(swapChainDescription);

		mCommandQueue = mGraphicsContext.Factory.CreateCommandQueue();

		// Compile Vertex and Pixel shaders
		ShaderDescription vertexShaderDescription = ShaderDescription(.Vertex, "VS", vsBytes);
		ShaderDescription pixelShaderDescription = ShaderDescription(.Pixel, "PS", psBytes);

		Shader vertexShader = mGraphicsContext.Factory.CreateShader(ref vertexShaderDescription);
		defer delete vertexShader;
		defer vertexShader.Dispose();

		Shader pixelShader = mGraphicsContext.Factory.CreateShader(ref pixelShaderDescription);
		defer delete pixelShader;
		defer pixelShader.Dispose();

		BufferDescription vertexBufferDescription = BufferDescription((.)sizeof(Vector4) * (.)VertexData.Count, BufferFlags.VertexBuffer, ResourceUsage.Default);
		mVertexBuffer = mGraphicsContext.Factory.CreateBuffer(VertexData, ref vertexBufferDescription);

		// Prepare Pipeline
		mVertexLayouts = new InputLayouts()
			.Add(scope LayoutDescription()
				.Add(ElementDescription(ElementFormat.Float4, ElementSemanticType.Position))
				.Add(ElementDescription(ElementFormat.Float4, ElementSemanticType.Color))
			);

		GraphicsPipelineDescription pipelineDescription = GraphicsPipelineDescription
			{
				PrimitiveTopology = PrimitiveTopology.TriangleList,
				InputLayouts = mVertexLayouts,
				Shaders = scope GraphicsShaderStateDescription()
					{
						VertexShader = vertexShader,
						PixelShader = pixelShader
					},
				RenderStates = RenderStateDescription()
					{
						RasterizerState = RasterizerStates.CullBack,
						BlendState = BlendStates.Opaque,
						DepthStencilState = DepthStencilStates.ReadWrite
					},
				Outputs = mSwapChain.FrameBuffer.OutputDescription,
				ResourceLayouts = null
			};

		mGraphicsPipelineState = mGraphicsContext.Factory.CreateGraphicsPipeline(ref pipelineDescription);
	}

	public void ShuttingDown(IContext context)
	{
		mGraphicsPipelineState.Dispose();
		mVertexBuffer.Dispose();
		mSwapChain.Dispose();
		mGraphicsContext.Dispose();

		delete mVertexLayouts;
		delete mGraphicsPipelineState;
		delete mVertexBuffer;
		delete mCommandQueue;
		delete mSwapChain;

		context.UnregisterUpdateFunction(mUpdateFunctionInfo);
	}

	private void Update(UpdateInfo info)
	{
		info.Context.Logger.LogInformation(scope $"{info.Time.ElapsedTime} : Application Update");

		if (mHost.Input.GetKeyboard().IsKeyPressed(.Escape))
		{
			mHost.Exit();
		}
	}

	private void Render()
	{
		CommandBuffer commandBuffer = mCommandQueue.CommandBuffer();

		commandBuffer.Begin();

		RenderPassDescription renderPassDescription = RenderPassDescription(mSwapChain.FrameBuffer, ClearValue(ClearFlags.All, 1, 0, Color.CornflowerBlue.ToVector4()));
		commandBuffer.BeginRenderPass(ref renderPassDescription);

		commandBuffer.SetViewports(viewports);
		commandBuffer.SetScissorRectangles(scissors);
		commandBuffer.SetGraphicsPipelineState(mGraphicsPipelineState);
		commandBuffer.SetVertexBuffers(scope Buffer[1](mVertexBuffer));

		commandBuffer.Draw((.)VertexData.Count / 2);

		commandBuffer.EndRenderPass();
		commandBuffer.End();

		commandBuffer.Commit();

		mCommandQueue.Submit();
		mCommandQueue.WaitIdle();

		mSwapChain.Present();
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