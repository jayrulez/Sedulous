using Sedulous.Core;
using System;
using Sedulous.Foundation.Logging.Abstractions;
using Sedulous.Foundation.Logging.Debug;
using System.Threading;
namespace Sedulous.Sandbox;

class SandboxApplication : Application
{
	private readonly ILogger mLogger = new DebugLogger(.Trace) ~ delete _;

	public this() : base("Sandbox")
	{
	}

	protected override Result<Context> OnCreatingContext()
	{
		ContextConfiguration configuration = scope .()
			{
				Logger = mLogger
			};
		return .Ok(new SandboxContext(this, configuration));
	}

	protected override void OnInitialized()
	{
		Context.Jobs.AddJob(new () =>
			{
				Thread.Sleep(1000);
				mLogger.LogInformation("Loading Task 1 finished.");
			}, "Load Task 1");

		Context.Jobs.AddJob(new () =>
			{
				Thread.Sleep(1000);
				mLogger.LogInformation("Loading Task 2 finished.");
			}, "Load Task 2");

		Context.Jobs.AddJob(new () =>
			{
				mLogger.LogInformation("Loading on main thread started.");
				Thread.Sleep(5000);
				mLogger.LogInformation("Loading on main thread finished.");
			}, "Load Content", .RunOnMainThread);
	}

	protected override void OnUpdate(Context context, ApplicationTime time)
	{
		//mLogger.LogInformation("Update time: {}", time.ElapsedTime);
	}

	protected override void OnPostUpdate(Context context, ApplicationTime time)
	{
		//mLogger.LogInformation("PostUpdate time: {}", time.ElapsedTime);
	}
}