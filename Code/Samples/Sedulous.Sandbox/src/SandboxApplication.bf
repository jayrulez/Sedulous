using Sedulous.Core;
using System;
using Sedulous.Foundation.Logging.Abstractions;
using Sedulous.Foundation.Logging.Debug;
using System.Threading;
using Sedulous.Foundation.Mathematics;
using Sedulous.SDL;
namespace Sedulous.Sandbox;

class SandboxApplication
{
	private readonly ILogger mLogger = new DebugLogger(.Trace) ~ delete _;

	protected void OnInitialized(Engine engine)
	{
		engine.Jobs.AddJob(new () =>
			{
				Thread.Sleep(1000);
				mLogger.LogInformation("Loading Task 1 finished.");
			}, "Load Task 1");

		engine.Jobs.AddJob(new () =>
			{
				Thread.Sleep(1000);
				mLogger.LogInformation("Loading Task 2 finished.");
			}, "Load Task 2");

		engine.Jobs.AddJob(new () =>
			{
				mLogger.LogInformation("Loading on main thread started.");
				Thread.Sleep(5000);
				mLogger.LogInformation("Loading on main thread finished.");
			}, "Load Content", .RunOnMainThread);

		/*engine.Jobs.AddJob(new () =>
			{
				mLogger.LogInformation("Stop application.");
				Thread.Sleep(6000);
				this.Exit();
				mLogger.LogInformation("Stop application job completed.");
			}, "Stopping application", .RunOnMainThread);*/
	}

	public void Run()
	{
		var windowSystem = scope SDLWindowSystem();

		var primaryWindow = windowSystem.CreateWindow("Sandbox", 1280, 720, true, .VULKAN, .. ?);
		defer windowSystem.DestroyWindow(primaryWindow);
		{
			var engine = scope Engine(mLogger);

			engine.Configure(scope (config) =>
				{
				//config.AddPlugin();
				});

			engine.Initialize();

			OnInitialized(engine);

			windowSystem.RunMainLoop(scope => engine.Update);

			engine.Shutdown();
		}
	}
}