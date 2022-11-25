using Sedulous.Foundation.Logging.Abstractions;
using Sedulous.Core.Jobs;
using System.Collections;
using Sedulous.Core.Resources;
using Sedulous.Core.Scenes;
using System.Threading;
using System;
using System.Diagnostics;
namespace Sedulous.Core;

typealias EngineUpdateDelegate = delegate void(EngineTime engineTime);

/// <summary>
/// Updates the resolution of the system timer on platforms which require it.
/// </summary>
typealias EngineSystemTimerUpdateDelegate = delegate void(Engine engine, ref uint32 systemTimerPeriod);


typealias EngineSystemTimerCleanupDelegate = delegate void(Engine engine, ref uint32 systemTimerPeriod);

enum EngineUpdatePhase
{
	PreUpdate,
	PreScenesUpdate,
	PostScenesUpdate,
	PostUpdate
}

struct EngineUpdateDelegateInfo
{
	public EngineUpdatePhase UpdatePhase;
	public EngineUpdateDelegate UpdateDelegate;
}

static
{
	public static void ForEachUpdatePhase(delegate void(EngineUpdatePhase) action)
	{
		for (var phase = Enum.GetMinValue<EngineUpdatePhase>(); phase <= Enum.GetMaxValue<EngineUpdatePhase>(); phase++)
		{
			action(phase);
		}
	}
}

class Engine
{
	private readonly Monitor mEngineMonitor = new .() ~ delete _;

	private ILogger mLogger;

	private readonly JobSystem mJobSystem = null;
	private readonly ResourceSystem mResourceSystem = null;
	private readonly SceneSystem mSceneSystem = null;

	private readonly List<Plugin> mPlugins = new List<Plugin>() ~ delete _;
	private readonly EngineConfiguration mConfiguration = new EngineConfiguration() ~ delete _;

	private Dictionary<EngineUpdatePhase, List<EngineUpdateDelegate>> mUpdateDelegates = new .() ~ delete _;
	private List<EngineUpdateDelegateInfo> mUpdateDelegatesToRegister = new .() ~ delete _;
	private List<EngineUpdateDelegateInfo> mUpdateDelegatesToUnregister = new .() ~ delete _;

	// Current tick state.
	private static readonly TimeSpan MaxElapsedTime = TimeSpan.FromMilliseconds(500);
	private readonly EngineTimeTracker mTimeTrackerPreUpdate = new .() ~ delete _;
	private readonly EngineTimeTracker mTimeTrackerScenesUpdate = new .() ~ delete _;
	private readonly EngineTimeTracker mTimeTrackerPostUpdate = new .() ~ delete _;
	private readonly Stopwatch mTickTimer = new .() ~ delete _;
	private int64 mAccumulatedElapsedTime;
	private int32 mLagFrames;
	private bool mRunningSlowly;
	private bool mForceElapsedTimeToZero;

	// Current system timer resolution.
	private uint32 mSystemTimerPeriod;

	private bool mIsActive = true;

	public EngineSystemTimerUpdateDelegate SystemTimerUpdateDelegate { get; set; }
	public EngineSystemTimerCleanupDelegate SystemTimerCleanupDelegate { get; set; }

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

	public TimeSpan TargetElapsedTime { get; set; } = DefaultTargetElapsedTime;
	public TimeSpan InactiveSleepTime { get; set; } = DefaultInactiveSleepTime;
	public bool IsFixedTimeStep { get; set; } = DefaultIsFixedTimeStep;

	public ILogger Logger { get => mLogger; }

	public JobSystem Jobs { get => mJobSystem; }
	public ResourceSystem Resources { get => mResourceSystem; }
	public SceneSystem Scenes { get => mSceneSystem; }

	private bool IsActive
	{
		get => mIsActive;
		set
		{
			using (mEngineMonitor.Enter())
			{
				mIsActive = value;
			}
		}
	}

	public this(ILogger logger)
	{
		mLogger = logger;

		ForEachUpdatePhase(scope (updatePhase) =>
			{
				mUpdateDelegates.Add(updatePhase, new .());
			});

		mTickTimer.Start();

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

		ForEachUpdatePhase(scope (updatePhase) =>
			{
				delete mUpdateDelegates[updatePhase];
			});
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
		CleanupSystemTimer();

		for (int i = mPlugins.Count - 1; i >= 0; i--)
		{
			mPlugins[i].OnShutdown();
		}

		mSceneSystem.Shutdown();
		mResourceSystem.Shutdown();
		mJobSystem.Shutdown();
	}

	public void UpdateSuspended()
	{
		UpdateSystemTimer();

		if (InactiveSleepTime.Ticks > 0)
		{
			Thread.Sleep(InactiveSleepTime);
		}
	}

	public void Update()
	{
		mJobSystem.Update();
		mResourceSystem.Update();

		RegisterUpdateDelegates();
		UnregisterUpdateDelegates();

		UpdateSystemTimer();

		if (InactiveSleepTime.Ticks > 0 && !this.IsActive)
			Thread.Sleep(InactiveSleepTime);

		var elapsedTicks = mTickTimer.Elapsed.Ticks;
		mTickTimer.Restart();

		mAccumulatedElapsedTime += elapsedTicks;
		if (mAccumulatedElapsedTime > MaxElapsedTime.Ticks)
			mAccumulatedElapsedTime = MaxElapsedTime.Ticks;

		int32 ticksToRun = 0;
		var timeDeltaPostUpdate = default(TimeSpan);
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
				timeDeltaPostUpdate = TimeSpan(ticksToRun * TargetElapsedTime.Ticks);
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
				timeDeltaPostUpdate = timeDeltaUpdate;
			}
			mAccumulatedElapsedTime = 0;
			mRunningSlowly = false;
		}

		if (ticksToRun == 0)
			return;

		// Run update delegates for update phases
		var preUpdateTime = mTimeTrackerPreUpdate.Increment(timeDeltaUpdate, mRunningSlowly);
		RunUpdateDelegates(.PreUpdate, preUpdateTime);

		for (var i = 0; i < ticksToRun; i++)
		{
			var scenesUpdateTime = mTimeTrackerScenesUpdate.Increment(timeDeltaUpdate, mRunningSlowly);

			// Scenes
			{
				RunUpdateDelegates(.PreScenesUpdate, scenesUpdateTime);
				mSceneSystem.Update();
				RunUpdateDelegates(.PostScenesUpdate, scenesUpdateTime);
			}
		}

		var postUpdateTime = mTimeTrackerPreUpdate.Increment(timeDeltaPostUpdate, mRunningSlowly);
		RunUpdateDelegates(.PostUpdate, postUpdateTime);
	}

	private void RegisterUpdateDelegates()
	{
		using (mEngineMonitor.Enter())
		{
			for (var updateDeletateInfo in mUpdateDelegatesToRegister)
			{
				mUpdateDelegates[updateDeletateInfo.UpdatePhase].Add(updateDeletateInfo.UpdateDelegate);
			}
			mUpdateDelegatesToRegister.Clear();
		}
	}

	private void UnregisterUpdateDelegates()
	{
		using (mEngineMonitor.Enter())
		{
			for (var updateDeletateInfo in mUpdateDelegatesToRegister)
			{
				mUpdateDelegates[updateDeletateInfo.UpdatePhase].Remove(updateDeletateInfo.UpdateDelegate);
			}
			mUpdateDelegatesToRegister.Clear();
		}
	}

	private void RunUpdateDelegates(EngineUpdatePhase updatePhase, EngineTime engineTime)
	{
		for (var updateDelegate in mUpdateDelegates[updatePhase])
		{
			updateDelegate(engineTime);
		}
	}

	public void RegisterUpdateDelegate(EngineUpdateDelegateInfo updateDeletateInfo)
	{
		mUpdateDelegatesToRegister.Add(updateDeletateInfo);
	}

	public void UnregisterUpdateDelegate(EngineUpdateDelegateInfo updateDeletateInfo)
	{
		mUpdateDelegatesToUnregister.Add(updateDeletateInfo);
	}

	private void UpdateSystemTimer()
	{
		if (SystemTimerUpdateDelegate != null)
			SystemTimerUpdateDelegate(this, ref mSystemTimerPeriod);
		else
		{
			mSystemTimerPeriod = 1;
		}
	}

	private void CleanupSystemTimer()
	{
		if (SystemTimerCleanupDelegate != null)
			SystemTimerCleanupDelegate(this, ref mSystemTimerPeriod);
		else
		{
			mSystemTimerPeriod = 0;
		}
	}
}