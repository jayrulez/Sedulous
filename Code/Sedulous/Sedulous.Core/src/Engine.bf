using Sedulous.Foundation.Logging.Abstractions;
using Sedulous.Core.Jobs;
using System.Collections;
using Sedulous.Core.Resources;
using Sedulous.Core.Scenes;
namespace Sedulous.Core;

class Engine
{
	private ILogger mLogger;

	private readonly JobSystem mJobSystem = null;
	private readonly ResourceSystem mResourceSystem = null;
	private readonly SceneSystem mSceneSystem = null;

	private readonly List<Plugin> mPlugins = new List<Plugin>() ~ delete _;
	private readonly EngineConfiguration mConfiguration = new EngineConfiguration() ~ delete _;

	public ILogger Logger { get => mLogger; }

	public JobSystem Jobs { get => mJobSystem; }
	public ResourceSystem Resources { get => mResourceSystem; }
	public SceneSystem Scenes { get => mSceneSystem; }

	public this(ILogger logger)
	{
		mLogger = logger;

		mJobSystem = new .(this, 16);
		mJobSystem.Startup();

		mResourceSystem = new .(this);
		mResourceSystem.Startup();

		mSceneSystem = new .(this);
		mSceneSystem.Startup();
	}

	public ~this()
	{
		delete mSceneSystem;
		delete mResourceSystem;
		delete mJobSystem;
	}

	public void Configure(delegate void(EngineConfiguration) configureDelegate)
	{
		if (configureDelegate != null)
		{
			configureDelegate(mConfiguration);

			mPlugins.AddRange(mConfiguration.Plugins);
		}
	}

	public virtual void Initialize()
	{
		for (var plugin in mPlugins)
		{
			plugin.OnInitialize(this);
		}
	}

	public virtual void Shutdown()
	{
		for (int i = mPlugins.Count - 1; i >= 0; i--)
		{
			mPlugins[i].OnShutdown();
		}

		mSceneSystem.Shutdown();
		mResourceSystem.Shutdown();
		mJobSystem.Shutdown();
	}

	public virtual void Update()
	{
		mJobSystem.Update();
		mResourceSystem.Update();
		mSceneSystem.Update();
	}
}