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
	}

	public override void OnShutdown()
	{
		mWindow.Resized.Unsubscribe(scope => mGraphicsSystem.Resize);
		mGraphicsSystem.Shutdown();

		delete mGraphicsSystem;

		mEngine = null;
	}
}