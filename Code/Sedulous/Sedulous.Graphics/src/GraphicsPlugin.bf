using Sedulous.Core;
using Sedulous.Platform;
using Sedulous.NRI;
namespace Sedulous.Graphics;

class GraphicsPlugin : Plugin
{
	private readonly Window mWindow = null;
	private readonly Device mDevice = null;
	private Engine mEngine = null;
	private GraphicsSystem mGraphicsSystem = null;
	private uint32 mFrameCount = 0;

	private EngineUpdateDelegate mGraphicsSystemUpdateDelegate = new => this.Update ~ delete _;
	private EngineUpdateDelegateInfo mUpdateDelegateInfo;

	public GraphicsSystem Graphics { get => mGraphicsSystem; }

	public this(Window window, Device device)
	{
		mWindow = window;
		mDevice = device;
	}

	public ~this()
	{
	}

	public override void OnInitialize(Engine engine)
	{
		mEngine = engine;

		mGraphicsSystem = new .(mEngine, mWindow, mDevice);

		mWindow.Resized.Subscribe(new => mGraphicsSystem.Resize);
		mGraphicsSystem.Startup();

		mUpdateDelegateInfo = .()
			{
				UpdatePhase = .PostUpdate,
				UpdateDelegate = mGraphicsSystemUpdateDelegate
			};

		mEngine.RegisterUpdateDelegate(mUpdateDelegateInfo);
	}

	public override void OnShutdown()
	{
		mEngine.UnregisterUpdateDelegate(mUpdateDelegateInfo);

		mWindow.Resized.Unsubscribe(scope => mGraphicsSystem.Resize);
		mGraphicsSystem.Shutdown();

		delete mGraphicsSystem;

		mEngine = null;
	}

	private void Update(EngineTime engineTime)
	{
		mGraphicsSystem.PrepareFrame(mFrameCount);
		mGraphicsSystem.RenderFrame(mFrameCount);
		mFrameCount++;
	}
}