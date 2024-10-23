using Sedulous.RHI;
using Sedulous.Core;
using Sedulous.Foundation.Logging.Abstractions;
using Sedulous.Foundation.Logging.Console;
using Sedulous.Platform;
using Sedulous.RHI.DirectX12;
using Sedulous.RHI.Vulkan;
using System;
using Sedulous.Platform.Desktop;
using Sedulous.Graphics;
using Sedulous.Core.SceneGraph;
using Sedulous.Graphics.SceneGraph;
using Sedulous.Foundation.Mathematics;
using static Sedulous.Core.IContext;
namespace Graphics;

class GraphicsApplication
{
	private const GraphicsBackend GraphicsBackend = .Vulkan;

	private IContext.RegisteredUpdateFunctionInfo? mUpdateFunctionRegistration;

	private readonly ILogger mLogger = new ConsoleLogger(.Trace) ~ delete _;
	private readonly ValidationLayer mValidationLayer = new .(mLogger) ~ delete _;
	private readonly GraphicsContext mGraphicsContext ~ delete _;

	private readonly GraphicsSubsystem mGraphics;

	private readonly IPlatformBackend mHost;

	private Scene mTestScene;

	public this(IPlatformBackend host)
	{
		mHost = host;
		switch (GraphicsBackend)
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

		mGraphicsContext.CreateDevice(mValidationLayer);

		mGraphics = new .(mGraphicsContext, host.Windows.GetPrimary());
	}

	public ~this()
	{
		delete mGraphics;
		mGraphicsContext.Dispose();
	}

	public Result<void> Initializing(ContextInitializer initializer)
	{
		initializer.AddSubsystem(mGraphics);
		return .Ok;
	}

	public void Initialized(IContext context)
	{
		mUpdateFunctionRegistration = context.RegisterUpdateFunction(.()
			{
				Priority = 1,
				Function = new  => Update,
				Stage = .VariableUpdate
			});

		context.SceneGraphSystem.CreateScene(out mTestScene);

		var cube = mTestScene.CreateEntity("Cube");
		var mesh = mTestScene.AddComponent<MeshComponent>(cube).Value;
		//mesh.SetMaterial(0, "");

		var cameraEntity = mTestScene.CreateEntity("camera");
		mTestScene.AddComponent<CameraComponent>(cameraEntity);

		//mTestScene.SetPosition(cameraEntity, Vector3(0, 5, -5));

		//mTestScene.SetLookAt(cameraEntity, cube);

		var light = mTestScene.CreateEntity("DirectionalLight").Value;
		mTestScene.AddComponent<DirectionalLightComponent>(light);

		mTestScene.RegisterUpdateFunction(.() {

		});

		// todo: Add a scene
		//
		//       Add an entity to scene
		//       Add a mesh component to entity
		//
		//       Add an entity to scene
		//       Add a camera component to entity
		//       Position entity component away from mesh entity
		//       Make camera entity look at mesh entity
		//
		//       Add a directional light entity
		//
		//
		//       Register update function with scene to move camera
	}

	public void ShuttingDown(IContext context)
	{
		context.SceneGraphSystem.DestroyScene(mTestScene);

		if (mUpdateFunctionRegistration.HasValue)
		{
			context.UnregisterUpdateFunction(mUpdateFunctionRegistration.Value);
			delete mUpdateFunctionRegistration.Value.Function;
			mUpdateFunctionRegistration = null;
		}
	}

	private void Update(UpdateInfo info)
	{
		if (mHost.Input.GetKeyboard().IsKeyPressed(.Escape))
		{
			mHost.Exit();
		}
	}
}