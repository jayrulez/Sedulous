using Sedulous.Core;
using Sedulous.Platform;
namespace Sedulous.Graphics;

class GraphicsPlugin : Plugin
{
	private readonly Window mWindow = null;
	private Engine mEngine = null;

	public this(Window window)
	{
		mWindow = window;
	}

	public override void OnInitialize(Engine engine)
	{
		mEngine = engine;
	}

	public override void OnShutdown()
	{
		mEngine = null;
	}
}