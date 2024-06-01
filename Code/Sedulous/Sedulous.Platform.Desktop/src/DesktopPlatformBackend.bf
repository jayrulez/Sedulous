using Sedulous.SDL2;
using Sedulous.Core;
namespace Sedulous.Platform.Desktop;

class DesktopPlatformBackend : SDL2PlatformBackend
{
	public this(DesktopPlatformConfiguration configuration) : base(configuration)
	{
		var config = configuration.PrimaryWindowConfiguration;
		Windows.Create(config.Title, -1, -1, config.Width, config.Height, .ShownImmediately | .Resizable);
	}
	public override bool SupportsMultipleThreads => true;

	public override bool SupportsHighDensityDisplayModes => true;

	public void Run(
		ContextInitializingCallback initializingCallback = null,
		ContextInitializedCallback initializedCallback = null,
		ContextShuttingDownCallback shuttingDownCallback = null)
	{
		StartMainLoop(initializingCallback, initializedCallback);
		while(IsRunning)
		{
			RunOneFrame();
		}
		StopMainLoop(shuttingDownCallback);
	}
}