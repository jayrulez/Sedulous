using System;
using Sedulous.Foundation.Utilities;
using Sedulous.Foundation.Logging.Abstractions;
using System.Threading;
using System.Collections;
using Sedulous.Foundation.Logging.Debug;
using Sedulous.Foundation.Jobs;
using Sedulous.Foundation;
using Sedulous.Core.Resources;
using Sedulous.Core.SceneGraph;

namespace Sedulous.Core;

using internal Sedulous.Foundation.Jobs;
using internal Sedulous.Core;

typealias ContextInitializingCallback = delegate Result<void>(ContextInitializer initializer);
typealias ContextInitializedCallback = delegate void(IContext context);
typealias ContextShuttingDownCallback = delegate void(IContext context);

interface IContext
{
	PlatformType Platform { get; }

	public enum UpdateStage
	{
		PreUpdate,
		PostUpdate,
		VariableUpdate,
		FixedUpdate,
	}

	public enum ContextState
	{
		Stopped,
		Running,
		Paused
	}

	public struct UpdateInfo
	{
		public IContext Context;
		public Time Time;
	}

	public struct RegisteredUpdateFunctionInfo
	{
		public Guid Id;
		public UpdateStage Stage;
		public int Priority;
		public UpdateFunction Function;

		internal this(Guid id, UpdateStage stage, int priority, UpdateFunction @function)
		{
			this.Id = id;
			this.Stage = stage;
			this.Priority = priority;
			this.Function = @function;
		}
	}

	public typealias UpdateFunction = delegate void(UpdateInfo info);

	public struct UpdateFunctionInfo
	{
		public int Priority;
		public UpdateStage Stage;
		public UpdateFunction Function;
	}

	ContextState State { get; }
	ILogger Logger { get; }
	JobSystem JobSystem { get; }
	ResourceSystem ResourceSystem { get; }

	[NoDiscard]IContext.RegisteredUpdateFunctionInfo RegisterUpdateFunction(UpdateFunctionInfo info);

	void RegisterUpdateFunctions(Span<UpdateFunctionInfo> infos, List<IContext.RegisteredUpdateFunctionInfo> registrations);

	void UnregisterUpdateFunction(IContext.RegisteredUpdateFunctionInfo registration);

	void UnregisterUpdateFunctions(Span<IContext.RegisteredUpdateFunctionInfo> registrations);

	Result<T> GetSubsystem<T>() where T : Subsystem;

	bool TryGetSubsystem<T>(out T outSubsystem) where T : Subsystem;
}

sealed class Context : IContext
{
	public PlatformType Platform
	{
		get
		{
			return OperatingSystemHelper.GetCurrentPlatfom();
		}
	}

	private List<Subsystem> mSubsystems = new .() ~ delete _;

	public IContext.ContextState State { get; private set; } = .Stopped;

	private bool mInitialized = false;

	private Dictionary<IContext.UpdateStage, List<IContext.RegisteredUpdateFunctionInfo>> mUpdateFunctions = new .() ~ delete _;
	private List<IContext.RegisteredUpdateFunctionInfo> mUpdateFunctionsToRegister = new .() ~ delete _;
	private List<IContext.RegisteredUpdateFunctionInfo> mUpdateFunctionsToUnregister = new .() ~ delete _;

	private readonly ILogger mLogger = null;
	private bool mOwnsLogger = false;

	public ILogger Logger => mLogger;

	private readonly JobSystem mJobSystem;

	public JobSystem JobSystem => mJobSystem;

	private readonly ResourceSystem mResourceSystem;

	public ResourceSystem ResourceSystem => mResourceSystem;

	// Current tick state.
	private static readonly TimeSpan MaxElapsedTime = TimeSpan.FromMilliseconds(500);
	private readonly TimeTracker mPreUpdateTimeTracker = new .() ~ delete _;
	private readonly TimeTracker mPostUpdateTimeTracker = new .() ~ delete _;
	private readonly TimeTracker mUpdateTimeTracker = new .() ~ delete _;
	private readonly TimeTracker mFixedUpdateTimeTracker = new .() ~ delete _;
	private int64 mAccumulatedElapsedTime = 0;
	private int32 mLagFrames = 0;
	private bool mRunningSlowly = false;

	/// Gets the default value for TargetElapsedTime.
	public static TimeSpan DefaultTargetElapsedTime { get; } = TimeSpan(TimeSpan.TicksPerSecond / 60);

	/// Gets the default value for InactiveSleepTime.
	public static TimeSpan DefaultInactiveSleepTime { get; } = TimeSpan.FromMilliseconds(20);

	public TimeSpan TargetElapsedTime { get; set; } = DefaultTargetElapsedTime;
	public TimeSpan InactiveSleepTime { get; set; } = DefaultInactiveSleepTime;

	private readonly IContextHost mHost;

	internal this(IContextHost host, ILogger logger = null)
	{
		mHost = host;
		if (logger == null)
		{
			mLogger = new DebugLogger(.Debug);
			mOwnsLogger = true;
		} else
		{
			mLogger = logger;
			mOwnsLogger = false;
		}

		mJobSystem = new .(mLogger, mHost.SupportsMultipleThreads ? 1 : 0);

		mResourceSystem = new .(this);

		Enum.MapValues<IContext.UpdateStage>(scope (member) =>
			{
				mUpdateFunctions.Add(member, new .());
			});
	}

	public ~this()
	{
		Enum.MapValues<IContext.UpdateStage>(scope (member) =>
			{
				delete mUpdateFunctions[member];
			});

		delete mResourceSystem;

		delete mJobSystem;

		if (mOwnsLogger)
		{
			delete mLogger;
		}
		mOwnsLogger = false;
	}

	public Result<void> Initialize(ContextInitializer initializer)
	{
		mLogger.MimimumLogLevel = initializer.LogLevel;

		if (mInitialized)
		{
			mLogger.LogWarning("Context already initialized.");
			return .Ok;
		}

		mLogger.LogInformation("Context initialization started.");

		List<Subsystem> initializedSubsystems = scope .();
		bool subsystemsInitialized = true;

		for (var subsystem in initializer.Subsystems)
		{
			if (subsystem.Initialize(this) case .Ok)
			{
				mLogger.LogInformation("Subsystem '{0}' initialized.", subsystem.Name);
				initializedSubsystems.Add(subsystem);
			} else
			{
				subsystemsInitialized = false;
				mLogger.LogError("Initialization failed for subsystem '{0}'.", subsystem.Name);
				break;
			}
		}

		if (!subsystemsInitialized)
		{
			for (var subsystem in initializedSubsystems)
			{
				subsystem.Uninitialize();
				mLogger.LogInformation("Subsystem '{0}' uninitialized.", subsystem.Name);
			}
			return .Err;
		}

		mSubsystems.AddRange(initializer.Subsystems);

		mInitialized = true;

		mLogger.LogInformation("Context initialization completed.");

		State = .Running;

		mJobSystem.Startup();

		mResourceSystem.Startup();

		//mResourceSystem.AddResourceManager<TextResource...>(mTextResourceManager);

		return .Ok;
	}

	public void Shutdown()
	{
		if (!mInitialized)
		{
			mLogger.LogWarning("Context was not previously initialized.");
			return;
		}

		//mResourceSystem.RemoveResourceManager(mTextResourceManager);

		mResourceSystem.Shutdown();

		mJobSystem.Shutdown();

		State = .Stopped;

		for (var subsystem in mSubsystems.Reversed)
		{
			subsystem.Uninitialize();
			mLogger.LogInformation("Subsystem '{0}' uninitialized.", subsystem.Name);
		}

		mSubsystems.Clear();

		mInitialized = false;
		mLogger.LogInformation("Context uninitialized.");
	}

	public void Update(Time time)
	{
		#region Update methods
		void SortUpdateFunctions()
		{
			Enum.MapValues<IContext.UpdateStage>(scope (member) =>
				{
					mUpdateFunctions[member].Sort(scope (lhs, rhs) =>
						{
							if (lhs.Priority == rhs.Priority)
							{
								return 0;
							}
							return lhs.Priority > rhs.Priority ? 1 : -1;
						});
				});
		}

		void RunUpdateFunctions(IContext.UpdateStage phase, IContext.UpdateInfo info)
		{
			for (ref IContext.RegisteredUpdateFunctionInfo updateFunctionInfo in ref mUpdateFunctions[phase])
			{
				updateFunctionInfo.Function(info);
			}
		}

		void ProcessUpdateFunctionsToRegister()
		{
			if (mUpdateFunctionsToRegister.Count == 0)
				return;

			for (var info in mUpdateFunctionsToRegister)
			{
				mUpdateFunctions[info.Stage].Add(info);
			}
			mUpdateFunctionsToRegister.Clear();
			SortUpdateFunctions();
		}

		void ProcessUpdateFunctionsToUnregister()
		{
			if (mUpdateFunctionsToUnregister.Count == 0)
				return;

			for (var info in mUpdateFunctionsToUnregister)
			{
				var index = mUpdateFunctions[info.Stage].FindIndex(scope (registered) =>
					{
						return info.Id == registered.Id;
					});

				if (index >= 0)
				{
					mUpdateFunctions[info.Stage].RemoveAt(index);
				}
			}
			mUpdateFunctionsToUnregister.Clear();
			SortUpdateFunctions();
		}
		{
			ProcessUpdateFunctionsToRegister();
			ProcessUpdateFunctionsToUnregister();
		}


#endregion

		mJobSystem.Update(time);
		mResourceSystem.Update(time);

		if (InactiveSleepTime.Ticks > 0 && mHost.IsSuspended)
			Thread.Sleep(InactiveSleepTime);

		mAccumulatedElapsedTime += time.ElapsedTime.Ticks;
		if (mAccumulatedElapsedTime > MaxElapsedTime.Ticks)
			mAccumulatedElapsedTime = MaxElapsedTime.Ticks;

		// Pre-Update
		{
			RunUpdateFunctions(.PreUpdate, .()
				{
					Context = this,
					Time = mPreUpdateTimeTracker.Increment(TimeSpan(time.ElapsedTime.Ticks))
				});
		}

		// Fixed-Update
		{
			var fixedTicksToRun = (int32)(mAccumulatedElapsedTime / TargetElapsedTime.Ticks);
			if (fixedTicksToRun > 0)
			{
				mLagFrames += (fixedTicksToRun == 1) ? -1 : Math.Max(0, fixedTicksToRun - 1);

				if (mLagFrames == 0)
					mRunningSlowly = false;
				if (mLagFrames > 5)
					mRunningSlowly = true;

				var timeDeltaFixedUpdate = TargetElapsedTime;
				mAccumulatedElapsedTime -= fixedTicksToRun * TargetElapsedTime.Ticks;

				for (var i = 0; i < fixedTicksToRun; i++)
				{
					RunUpdateFunctions(.FixedUpdate, .()
						{
							Context = this,
							Time = mFixedUpdateTimeTracker.Increment(timeDeltaFixedUpdate /*, mRunningSlowly*/)
						});
				}
			}
		}

		// Variable-Update
		{
			RunUpdateFunctions(.VariableUpdate, .()
				{
					Context = this,
					Time = mUpdateTimeTracker.Increment(TimeSpan(time.ElapsedTime.Ticks))
				});
		}

		// Post-Update
		{
			RunUpdateFunctions(.PostUpdate, .()
				{
					Context = this,
					Time = mPostUpdateTimeTracker.Increment(TimeSpan(time.ElapsedTime.Ticks))
				});
		}
	}

	public IContext.RegisteredUpdateFunctionInfo RegisterUpdateFunction(IContext.UpdateFunctionInfo info)
	{
		IContext.RegisteredUpdateFunctionInfo registration = .(Guid.Create(), info.Stage, info.Priority, info.Function);
		mUpdateFunctionsToRegister.Add(registration);
		return registration;
	}

	public void RegisterUpdateFunctions(Span<IContext.UpdateFunctionInfo> infos, List<IContext.RegisteredUpdateFunctionInfo> registrations)
	{
		for (var info in infos)
		{
			registrations.Add(RegisterUpdateFunction(info));
		}
	}

	public void UnregisterUpdateFunction(IContext.RegisteredUpdateFunctionInfo registration)
	{
		mUpdateFunctionsToUnregister.Add(registration);
	}

	public void UnregisterUpdateFunctions(Span<IContext.RegisteredUpdateFunctionInfo> registrations)
	{
		for (var registration in registrations)
		{
			mUpdateFunctionsToUnregister.Add(registration);
		}
	}

	public Result<T> GetSubsystem<T>() where T : Subsystem
	{
		for (var subsystem in mSubsystems)
		{
			if (typeof(T).IsAssignableFrom(subsystem.GetType()))
			{
				return .Ok((T)subsystem);
			}
		}
		return .Err;
	}

	public bool TryGetSubsystem<T>(out T outSubsystem) where T : Subsystem
	{
		for (var subsystem in mSubsystems)
		{
			if (typeof(T).IsAssignableFrom(subsystem.GetType()))
			{
				outSubsystem = (T)subsystem;
				return true;
			}
		}
		outSubsystem = null;
		return false;
	}
}