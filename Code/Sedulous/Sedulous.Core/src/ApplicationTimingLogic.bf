using Sedulous.Core.Abstractions;
using System;
using Sedulous.Foundation;
using System.Threading;
namespace Sedulous.Core;

/// <summary>
/// Contains core functionality for a Context host processes.
/// </summary>
sealed class ApplicationTimingLogic : IApplicationTimingLogic
{
	// The Context host.
	private readonly IApplication mApplication;

	// Current tick state.
	private static readonly TimeSpan MaxElapsedTime = TimeSpan.FromMilliseconds(500);
	private readonly ApplicationTimeTracker mTimeTrackerUpdate = new .() ~ delete _;
	private readonly ApplicationTimeTracker mTimeTrackerPostUpdate = new .() ~ delete _;
	private readonly System.Diagnostics.Stopwatch mTickTimer = new .();
	private int64 mAccumulatedElapsedTime;
	private int32 mLagFrames;
	private bool mRunningSlowly;
	private bool mForceElapsedTimeToZero;

	// Current system timer resolution.
	private uint32 mSystemTimerPeriod;

	/// <summary>
	/// Gets the default value for TargetElapsedTime.
	/// </summary>
	public static TimeSpan DefaultTargetElapsedTime { get; } = TimeSpan(TimeSpan.TicksPerSecond / 60);

	/// <summary>
	/// Gets the default value for InactiveSleepTime.
	/// </summary>
	public static TimeSpan DefaultInactiveSleepTime { get; } = TimeSpan.FromMilliseconds(20);

	/// <summary>
	/// Gets the default value for IsFixedTimeStep.
	/// </summary>
	public static bool DefaultIsFixedTimeStep { get; } = true;

	/// <inheritdoc/>
	public Context Context
	{
		get { return mApplication.Context; }
	}

	/// <inheritdoc/>
	public TimeSpan TargetElapsedTime { get; set; } = DefaultTargetElapsedTime;

	/// <inheritdoc/>
	public TimeSpan InactiveSleepTime { get; set; } = DefaultInactiveSleepTime;

	/// <inheritdoc/>
	public bool IsFixedTimeStep { get; set; } = DefaultIsFixedTimeStep;

	/// <summary>
	/// Initializes a new instance of the <see cref="ApplicationTimingLogic"/> class.
	/// </summary>
	/// <param name="application">The Context host.</param>
	public this(IApplication application)
	{
		Contract.Require(application, nameof(application));

		mApplication = application;
		mTickTimer.Start();
	}

	/// <inheritdoc/>
	public void ResetElapsed()
	{
		mTickTimer.Restart();
		if (!IsFixedTimeStep)
		{
			mForceElapsedTimeToZero = true;
		}
	}

	/// <inheritdoc/>
	public void RunOneTickSuspended()
	{
		var context = mApplication.Context;

		UpdateSystemTimerResolution();

		context.UpdateSuspended();

		if (InactiveSleepTime.Ticks > 0)
		{
			Thread.Sleep(InactiveSleepTime);
		}
	}

	/// <inheritdoc/>
	public void RunOneTick()
	{
		var context = mApplication.Context;

		context.ProcessJobs();

		UpdateSystemTimerResolution();

		if (InactiveSleepTime.Ticks > 0 && !mApplication.IsActive)
			Thread.Sleep(InactiveSleepTime);

		var elapsedTicks = mTickTimer.Elapsed.Ticks;
		mTickTimer.Restart();

		mAccumulatedElapsedTime += elapsedTicks;
		if (mAccumulatedElapsedTime > MaxElapsedTime.Ticks)
			mAccumulatedElapsedTime = MaxElapsedTime.Ticks;

		int32 ticksToRun = 0;
		var timeDeltaDraw = default(TimeSpan);
		var timeDeltaUpdate = default(TimeSpan);

		if (IsFixedTimeStep)
		{
			ticksToRun = (int32)(mAccumulatedElapsedTime / TargetElapsedTime.Ticks);
			if (ticksToRun > 0)
			{
				mLagFrames += (ticksToRun == 1) ? -1 : Math.Max(0, ticksToRun - 1);

				if (mLagFrames == 0)
					mRunningSlowly = false;
				if (mLagFrames > 5)
					mRunningSlowly = true;

				timeDeltaUpdate = TargetElapsedTime;
				timeDeltaDraw = TimeSpan(ticksToRun * TargetElapsedTime.Ticks);
				mAccumulatedElapsedTime -= ticksToRun * TargetElapsedTime.Ticks;
			}
			else
			{
				var frameDelay = (int32)(TargetElapsedTime.TotalMilliseconds - mTickTimer.Elapsed.TotalMilliseconds);
				if (frameDelay >= 1 + (int32)mSystemTimerPeriod)
				{
					Thread.Sleep(frameDelay - 1);
				}
				return;
			}
		}
		else
		{
			ticksToRun = 1;
			if (mForceElapsedTimeToZero)
			{
				timeDeltaUpdate = TimeSpan.Zero;
				mForceElapsedTimeToZero = false;
			}
			else
			{
				timeDeltaUpdate = TimeSpan(elapsedTicks);
				timeDeltaDraw = timeDeltaUpdate;
			}
			mAccumulatedElapsedTime = 0;
			mRunningSlowly = false;
		}

		if (ticksToRun == 0)
			return;

		context.HandleFrameStart();

		for (var i = 0; i < ticksToRun; i++)
		{
			var updateTime = mTimeTrackerUpdate.Increment(timeDeltaUpdate, mRunningSlowly);
			if (!UpdateContext(context, updateTime))
			{
				return;
			}
		}

		if (!mApplication.IsSuspended)
		{
			var postUpdateTime = mTimeTrackerPostUpdate.Increment(timeDeltaDraw, mRunningSlowly);
			// todo: profile
			{
				context.PostUpdate(postUpdateTime);
			}
		}

		context.HandleFrameEnd();
	}

	public void Cleanup()
	{
		mSystemTimerPeriod = 0;
	}

	/// <summary>
	/// Updates the specified context.
	/// </summary>
	/// <param name="context">The ApplicationContext to update.</param>
	/// <param name="time">Time elapsed since the last update.</param>
	/// <returns><see langword="true"/> if the host should continue processing; otherwise, <see langword="false"/>.</returns>
	private bool UpdateContext(Context context, ApplicationTime time)
	{
		// todo: profile
		{
			context.Update(time);
		}
		return !context.Disposed;
	}

	/// <summary>
	/// Updates the resolution of the system timer on platforms which require it.
	/// </summary>
	private bool UpdateSystemTimerResolution()
	{
		mSystemTimerPeriod = 1;
		return false;
	}
}