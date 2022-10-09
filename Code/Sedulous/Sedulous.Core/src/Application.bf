using Sedulous.Core.Abstractions;
using System.Threading;
using System;
using Sedulous.Foundation;
using Sedulous.Foundation.Messaging;
namespace Sedulous.Core;

abstract class Application : IMessageSubscriber<MessageID>, IContextComponent, IApplication
{
	// Property values.
	private Context mContext;

	// State values.
	private readonly Monitor mStateSyncMonitor = new .() ~ delete _;
	private IApplicationTimingLogic mTimingLogic;
	private bool mContextCreated = false;
	private bool mIsRunning = false;
	private bool mSuspended;
	private String mName = new .() ~ delete _;

	// The application's tick state.
	private bool mIsFixedTimeStep = ApplicationTimingLogic.DefaultIsFixedTimeStep;
	private TimeSpan mTargetElapsedTime = ApplicationTimingLogic.DefaultTargetElapsedTime;
	private TimeSpan mInactiveSleepTime = ApplicationTimingLogic.DefaultInactiveSleepTime;

	public Context Context => mContext;

	public String ApplicationName => mName;

	public bool IsActive
	{
		get
		{
			/*if (mPrimaryWindow == null)
				return false;

			using (mStateSyncMonitor.Enter())
				return mPrimaryWindow.Active && !mSuspended;*/

			return !mSuspended;
		}
	}

	public bool IsSuspended
	{
		get
		{
			using (mStateSyncMonitor.Enter())
				return mSuspended;
		}
	}

	public bool IsFixedTimeStep
	{
		get
		{
			return mIsFixedTimeStep;
		}
		set
		{
			mIsFixedTimeStep = value;
			if (mTimingLogic != null)
			{
				mTimingLogic.IsFixedTimeStep = value;
			}
		}
	}

	public TimeSpan TargetElapsedTime
	{
		get
		{
			return mTargetElapsedTime;
		}
		set
		{
			Contract.EnsureRange(value.TotalMilliseconds >= 0, nameof(value));

			mTargetElapsedTime = value;
			if (mTimingLogic != null)
			{
				mTimingLogic.TargetElapsedTime = value;
			}
		}
	}

	public TimeSpan InactiveSleepTime
	{
		get
		{
			return mInactiveSleepTime;
		}
		set
		{
			mInactiveSleepTime = value;
			if (mTimingLogic != null)
			{
				mTimingLogic.InactiveSleepTime = value;
			}
		}
	}

	public this(StringView name)
	{
		mName.Set(name);
	}

	public int GetHashCode()
	{
		return (int)(void*)Internal.UnsafeCastToPtr(this);
	}

	public void Run()
	{
		if (mIsRunning)
			return;

		OnInitializing();

		CreateContext();

		OnInitialized();

		mIsRunning = true;

		while (mIsRunning)
		{
			if (IsSuspended)
			{
				mTimingLogic.RunOneTickSuspended();
			} else
			{
				mTimingLogic.RunOneTick();
			}
			Thread.Yield();
		}

		mTimingLogic.Cleanup();

		//mContext.WaitForPendingJobs();

		Shutdown();
	}

	public virtual void Exit()
	{
		mIsRunning = false;
	}

	void IMessageSubscriber<MessageID>.ReceiveMessage(MessageID type, MessageData data)
	{
		OnReceivedMessage(type, data);
	}

	/// <summary>
	/// Occurs when the context receives a message from its queue.
	/// </summary>
	/// <param name="type">The message type.</param>
	/// <param name="data">The message data.</param>
	protected virtual void OnReceivedMessage(MessageID type, MessageData data)
	{
		if (type == CoreMessages.ApplicationTerminating)
		{
			mIsRunning = false;
		}
		else if (type == CoreMessages.ApplicationSuspending)
		{
			//OnSuspending();

			using (mStateSyncMonitor.Enter())
				mSuspended = true;
		}
		else if (type == CoreMessages.ApplicationSuspended)
		{
			//OnSuspended();
		}
		else if (type == CoreMessages.ApplicationResuming)
		{
			//OnResuming();
		}
		else if (type == CoreMessages.ApplicationResumed)
		{
			mTimingLogic?.ResetElapsed();

			using (mStateSyncMonitor.Enter())
				mSuspended = false;

			//OnResumed();
		}
		else if (type == CoreMessages.LowMemory)
		{
			//OnReclaimingMemory();
		}
		else if (type == CoreMessages.Quit)
		{
			mIsRunning = false;
		}
	}

	/// <summary>
	/// Creates the timing logic for this host process.
	/// </summary>
	protected virtual IApplicationTimingLogic CreateTimingLogic()
	{
		var timingLogic = new ApplicationTimingLogic(this);
		timingLogic.IsFixedTimeStep = this.IsFixedTimeStep;
		timingLogic.TargetElapsedTime = this.TargetElapsedTime;
		timingLogic.InactiveSleepTime = this.InactiveSleepTime;
		return timingLogic;
	}

	protected abstract Result<Context> OnCreatingContext();

	protected virtual void OnInitializing()
	{
	}

	protected virtual void OnInitialized()
	{
	}

	protected virtual void OnShutdown()
	{
	}

	protected virtual void OnUpdate(Context context, ApplicationTime time)
	{
	}

	protected virtual void OnPostUpdate(Context context, ApplicationTime time)
	{
	}

	private Result<void> CreateContext()
	{
		mContext = OnCreatingContext();
		if (mContext == null)
		{
			return .Err;
		}

		mTimingLogic = CreateTimingLogic();
		if (mTimingLogic == null)
		{
			return .Err;
		}

		mContext.Messages.Subscribe(this,
			CoreMessages.ApplicationTerminating,
			CoreMessages.ApplicationSuspending,
			CoreMessages.ApplicationSuspended,
			CoreMessages.ApplicationResuming,
			CoreMessages.ApplicationResumed,
			CoreMessages.LowMemory,
			CoreMessages.Quit);

		mContext.Updating.Subscribe(new => this.OnUpdate);
		mContext.PostUpdating.Subscribe(new => this.OnPostUpdate);

		mContextCreated = true;

		mContext.Initialize();

		return .Ok;
	}

	private void Shutdown()
	{
		mContext.Updating.Unsubscribe(scope => this.OnUpdate);
		mContext.PostUpdating.Unsubscribe(scope => this.OnPostUpdate);

		OnShutdown();

		mContext.Dispose();

		delete mTimingLogic;
		delete mContext;
	}
}