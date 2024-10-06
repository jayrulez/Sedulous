using Sedulous.Platform.Desktop;
using Sedulous.Foundation.Utilities;
using Sedulous.Platform;
using Sedulous.Core;
using System;
using Sedulous.RHI;
using Sedulous.RHI.Vulkan;
using Sedulous.Foundation.Mathematics;
using System.Collections;
using Sedulous.Foundation.Logging.Abstractions;
using Sedulous.Foundation.Logging.Console;
using System.IO;
using Sedulous.RHI.DirectX12;
using static Sedulous.Core.IContext;
namespace RHI;

class RHIApplication
{
	private const GraphicsBackend GraphicsBackend = .Vulkan;

	private IContext.RegisteredUpdateFunctionInfo? mUpdateFunctionRegistration;

	private readonly ILogger mLogger = new ConsoleLogger(.Trace) ~ delete _;
	private readonly ValidationLayer mValidationLayer = new .(mLogger) ~ delete _;
	private readonly GraphicsContext mGraphicsContext ~ delete _;
	private SwapChain mSwapChain = null;
	private CommandQueue mCommandQueue = null;
	private Buffer mVertexBuffer;
	private InputLayouts mVertexLayouts = null;
	private GraphicsPipelineState mGraphicsPipelineState = null;
	private Viewport[] mViewports = null;
	private Rectangle[] mScissors = null;

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

	private static Vector4[] VertexData = new Vector4[]
		( // TriangleList
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

		// Compile Vertex and Pixel shaders
		uint8[] psBytes = null;
		uint8[] vsBytes = null;

		if (mGraphicsContext.BackendType == .Vulkan)
		{
			List<uint8> shaderBytes = scope .();
			if (File.ReadAll("Shaders/FragmentShader.spirv", shaderBytes) case .Err)
			{
				Runtime.FatalError("Failed to load pixel shader.");
			}
			psBytes = scope :: .[shaderBytes.Count];
			shaderBytes.CopyTo(psBytes);

			shaderBytes.Clear();
			if (File.ReadAll("Shaders/VertexShader.spirv", shaderBytes) case .Err)
			{
				Runtime.FatalError("Failed to load vertex shader.");
			}
			vsBytes = scope :: .[shaderBytes.Count];
			shaderBytes.CopyTo(vsBytes);
		}else if(mGraphicsContext.BackendType == .DirectX12)
		{
			String shaderSource = scope .();
			String shaderPath = "Shaders/HLSL.fx";
			if(File.ReadAllText(shaderPath, shaderSource) case .Err)
			{
				Runtime.FatalError(scope $"Failed to load shader source '{shaderPath}'.");
			}

			CompilationResult result = scope .();
			mGraphicsContext.ShaderCompile(shaderSource, "PS", .Pixel, ref result);
			if(result.HasErrors)
			{
				Runtime.FatalError("Failed to load pixel shader.");
			}
			psBytes = scope :: .[result.ByteCode.Count];
			result.ByteCode.CopyTo(psBytes);

			mGraphicsContext.ShaderCompile(shaderSource, "VS", .Vertex, ref result);
			if(result.HasErrors)
			{
				Runtime.FatalError("Failed to load vertex shader.");
			}
			vsBytes = scope :: .[result.ByteCode.Count];
			result.ByteCode.CopyTo(vsBytes);
		}

		ShaderDescription vertexShaderDescription = ShaderDescription(.Vertex, "VS", vsBytes);
		ShaderDescription pixelShaderDescription = ShaderDescription(.Pixel, "PS", psBytes);

		Shader vertexShader = mGraphicsContext.Factory.CreateShader(vertexShaderDescription);
		defer delete vertexShader;
		defer vertexShader.Dispose();

		Shader pixelShader = mGraphicsContext.Factory.CreateShader(pixelShaderDescription);
		defer delete pixelShader;
		defer pixelShader.Dispose();

		BufferDescription vertexBufferDescription = BufferDescription((.)sizeof(Vector4) * (.)VertexData.Count, BufferFlags.VertexBuffer, ResourceUsage.Default);
		mVertexBuffer = mGraphicsContext.Factory.CreateBuffer(VertexData, vertexBufferDescription);

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
				Shaders = GraphicsShaderStateDescription()
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

		mGraphicsPipelineState = mGraphicsContext.Factory.CreateGraphicsPipeline(pipelineDescription);

		mViewports = new Viewport[1](.(0, 0, window.ClientSize.Width, window.ClientSize.Height));
		mScissors = new Rectangle[1]();

		window.Drawing.Subscribe(new (window, time) =>
			{
				Render();
			});

		window.SizeChanged.Subscribe(new (window) =>
			{
				int32 width = window.ClientSize.Width;
				int32 height = window.ClientSize.Height;
				mViewports[0] = Viewport(0, 0, width, height);
				mScissors[0] = Rectangle(0, 0, (.)width, (.)height);
				mSwapChain.ResizeSwapChain((.)width, (.)height);
			});
	}

	public void ShuttingDown(IContext context)
	{
		delete mScissors;
		delete mViewports;
		mGraphicsPipelineState.Dispose();
		mVertexBuffer.Dispose();
		mCommandQueue.Dispose();
		mSwapChain.Dispose();
		mGraphicsContext.Dispose();

		delete mVertexLayouts;
		delete mGraphicsPipelineState;
		delete mVertexBuffer;
		//delete mCommandQueue; // Uncomment after making this work for DX12
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

	private void Render()
	{
		CommandBuffer commandBuffer = mCommandQueue.CommandBuffer();

		commandBuffer.Begin();

		ClearValue clearValue = .(ClearFlags.All, 1, 0);
		clearValue.ColorValues.Count = mSwapChain.FrameBuffer.ColorTargets.Count;
		for(int i = 0; i < clearValue.ColorValues.Count; i++)
			clearValue.ColorValues[i] = Color.CornflowerBlue.ToVector4();

		RenderPassDescription renderPassDescription = RenderPassDescription(mSwapChain.FrameBuffer, clearValue);
		commandBuffer.BeginRenderPass(renderPassDescription);

		commandBuffer.SetViewports(mViewports);
		commandBuffer.SetScissorRectangles(mScissors);
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