using Sedulous.Platform.Desktop;
using Sedulous.Foundation.Utilities;
using Sedulous.Platform;
using Sedulous.Core;
using System;
using Sedulous.SceneGraph;
using static Sedulous.Core.IContext;
namespace SceneGraph;

class SandboxApplication
{
	private readonly SceneGraphSubsystem mSceneGraph = new .() ~ delete _;

	private readonly IPlatformBackend mHost;

	public this(IPlatformBackend host)
	{
		mHost = host;
	}

	public Result<void> Initializing(ContextInitializer initializer)
	{
		initializer.AddSubsystem(mSceneGraph);
		return .Ok;
	}

	public void Initialized(IContext context)
	{
	}

	public void ShuttingDown(IContext context)
	{
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
						Title = "SceneGraph"
					}
			});

		var app = scope SandboxApplication(host);

		host.Run(
			initializingCallback: scope => app.Initializing,
			initializedCallback: scope => app.Initialized,
			shuttingDownCallback: scope => app.ShuttingDown
			);
	}
}