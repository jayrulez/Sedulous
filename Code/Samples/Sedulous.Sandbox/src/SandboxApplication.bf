using Sedulous.Core;
using System;
using Sedulous.Foundation.Logging.Abstractions;
using Sedulous.Foundation.Logging.Debug;
using System.Threading;
using Sedulous.Foundation.Mathematics;
using Sedulous.SDL;
namespace Sedulous.Sandbox;

class SandboxApplication : Application
{
	private readonly ILogger mLogger = new DebugLogger(.Trace) ~ delete _;

	private float mProgress = 0.0f;
	private float mSpeed = 2;

	public this() : base("Sandbox")
	{
	}

	protected override Result<Context> OnCreatingContext()
	{
		ContextConfiguration configuration = scope .()
			{
				Logger = mLogger
			};

		configuration.FactoryInitializers.Add(new SDLFactoryInitializer());

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

		/*Context.Jobs.AddJob(new () =>
			{
				mLogger.LogInformation("Stop application.");
				Thread.Sleep(6000);
				this.Exit();
				mLogger.LogInformation("Stop application job completed.");
			}, "Stopping application", .RunOnMainThread);*/
	}

	protected override void OnUpdate(Context context, ApplicationTime time)
	{
		char8 char = Tweening.Lerp('a', 'z', mProgress);
		mLogger.LogInformation("Letter: {}", char);
		mLogger.LogInformation("Progress: {}", mProgress);


		float dt = (float)time.ElapsedTime.Milliseconds / 1000 * mSpeed;
		mProgress += dt;
		if (mProgress >= 1.0f)
		{
			mProgress = 0;
		}
	}

	protected override void OnPostUpdate(Context context, ApplicationTime time)
	{
		//mLogger.LogInformation("PostUpdate time: {}", time.ElapsedTime);
	}
}