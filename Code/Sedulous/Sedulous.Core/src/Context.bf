using Sedulous.Core.Abstractions;
using System;
using System.Threading;
using Sedulous.Core.Jobs;
using Sedulous.Foundation.Logging.Abstractions;
using Sedulous.Foundation.Logging.Debug;
using Sedulous.Foundation;
using Sedulous.Foundation.Messaging;
namespace Sedulous.Core;

/// <summary>
/// Represents a callback that is invoked when the framework logs a debug message.
/// </summary>
/// <param name="context">The Context that logged the message.</param>
/// <param name="level">A <see cref="DebugLevels"/> value representing the debug level of the message.</param>
/// <param name="message">The debug message text.</param>
public delegate void DebugCallback(Context context, DebugLevels level, String message);

/// <summary>
/// Represents a method that is called in response to a context event.
/// </summary>
/// <param name="context">The context.</param>
public delegate void ContextEventHandler(Context context);

/// <summary>
/// Represents the method that is called when a context updates the application state.
/// </summary>
/// <param name="context">The context.</param>
/// <param name="time">Time elapsed since the last call to <see cref="Context.Update(ApplicationTime)"/>.</param>
public delegate void ContextUpdateEventHandler(Context context, ApplicationTime time);

/// <summary>
/// Represents the method that is called after a context updates the application state.
/// </summary>
/// <param name="context">The context.</param>
/// <param name="time">Time elapsed since the last call to <see cref="Context.PostUpdate(ApplicationTime)"/>.</param>
public delegate void ContextPostUpdateEventHandler(Context context, ApplicationTime time);

/// <summary>
/// Represents the method that is called when a context updates the application state.
/// </summary>
/// <param name="context">The context.</param>
/// <param name="time">Time elapsed since the last call to <see cref="Context.Update(ApplicationTime)"/>.</param>
public delegate void ApplicationContextUpdateEventHandler(Context context, ApplicationTime time);

abstract class Context : IMessageSubscriber<MessageID>, IDisposable
{
	private readonly IApplication mApplication;
	private readonly ContextFactory mFactory = new ContextFactory() ~ delete _;
	private readonly Thread mThread;
	private readonly JobSystem mJobs ~ delete _;
	private readonly ILogger mLogger ~ { if (mOwnLogger && _ != null) delete _; };
	private bool mOwnLogger = false;

	// The context event queue.
	public typealias MessageQueueType = LocalMessageQueue<MessageID>;
	private readonly MessageQueueType mMessages ~ delete _;

	public bool IsRunningOnContextThread => Thread.CurrentThread == mThread;

	public bool IsInitialized { get; private set; }

	public bool Disposing { get; private set; }

	public bool Disposed { get; private set; }

	public JobSystem Jobs => mJobs;

	public ILogger Logger => mLogger;

	/// <summary>
	/// Gets the object that is hosting the context.
	/// </summary>
	public IApplication Application => mApplication;

	/// <summary>
	/// Gets the context's message queue.
	/// </summary>
	public IMessageQueue<MessageID> Messages => mMessages;

	/// <summary>
	/// Occurs when a new frame is started.
	/// </summary>
	public readonly EventAccessor<ContextEventHandler> FrameStart { get; } = new .() ~ delete _;

	/// <summary>
	/// Occurs when a frame is completed.
	/// </summary>
	public readonly EventAccessor<ContextEventHandler> FrameEnd { get; } = new .() ~ delete _;

	/// <summary>
	/// Occurs when the context is updating the application's state.
	/// </summary>
	public readonly EventAccessor<ContextUpdateEventHandler> Updating { get; } = new .() ~ delete _;

	/// <summary>
	/// Occurs when the context is preparing to draw the current scene. This event is called
	/// before the context associates itself to any windows.
	/// </summary>
	public readonly EventAccessor<ContextPostUpdateEventHandler> PostUpdating { get; } = new .() ~ delete _;

	protected this(IApplication application, ContextConfiguration configuration)
	{
		mApplication = application;
		mThread = Thread.CurrentThread;

		if (configuration.Logger == null)
		{
			mOwnLogger = true;
			mLogger = new DebugLogger(.Information);
		} else
		{
			mLogger = configuration.Logger;
		}

		mJobs = new .(this);

		mMessages = new LocalMessageQueue<MessageID>();

		mMessages.Subscribe(this, CoreMessages.Quit);
	}

	public int GetHashCode()
	{
		return (int)(void*)Internal.UnsafeCastToPtr(this);
	}

	/// <summary>
	/// Initializes the context and marks it ready for use.
	/// </summary>
	public void Initialize()
	{
		IsInitialized = true;

		mJobs.Startup();
	}

	/// <summary>
	/// Receives a message that has been published to a queue.
	/// </summary>
	/// <param name="type">The type of message that was received.</param>
	/// <param name="data">The data for the message that was received.</param>
	void IMessageSubscriber<MessageID>.ReceiveMessage(MessageID type, MessageData data)
	{
		Contract.EnsureNotDisposed(this, Disposed);

		OnReceivedMessage(type, data);
	}

	/// <summary>
	/// Releases resources associated with the object.
	/// </summary>
	public void Dispose()
	{
		Dispose(true);
	}

	/// <summary>
	/// Processes the context's message queue.
	/// </summary>
	public void ProcessMessages()
	{
		Runtime.Assert(IsInitialized, CoreStrings.ContextNotInitialized);
		mMessages.Process();
	}

	/// <summary>
	/// Called when a new frame is started.
	/// </summary>
	public void HandleFrameStart()
	{
		Runtime.Assert(IsInitialized, CoreStrings.ContextNotInitialized);
		// todo: start profiling
		OnFrameStart();
	}

	/// <summary>
	/// Called when a frame is completed.
	/// </summary>
	public void HandleFrameEnd()
	{
		Runtime.Assert(IsInitialized, CoreStrings.ContextNotInitialized);
		OnFrameEnd();
		// todo: end profiling
	}

	public void ProcessJobs()
	{
		Runtime.Assert(IsInitialized, CoreStrings.ContextNotInitialized);
		if (IsRunningOnContextThread)
		{
			mJobs.Update();
		}
	}

	/// <summary>
	/// Updates the context state while the application is suspended.
	/// </summary>
	public virtual void UpdateSuspended()
	{
		Runtime.Assert(IsInitialized, CoreStrings.ContextNotInitialized);
	}

	/// <summary>
	/// Updates the context state.
	/// </summary>
	/// <param name="time">Time elapsed since the last call to <see cref="Context.Update(ApplicationTime)"/>.</param>
	public virtual void Update(ApplicationTime time)
	{
		Runtime.Assert(IsInitialized, CoreStrings.ContextNotInitialized);

		OnUpdate(time);
	}

	/// <summary>
	/// Runs after the context state has been updated.
	/// </summary>
	/// <param name="time">Time elapsed since the last call to <see cref="Context.PostUpdate(ApplicationTime)"/>.</param>
	public virtual void PostUpdate(ApplicationTime time)
	{
		Runtime.Assert(IsInitialized, CoreStrings.ContextNotInitialized);

		OnPostUpdate(time);
	}

	/// <summary>
	/// Gets the factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to retrieve.</typeparam>
	/// <returns>The default factory method of the specified delegate type, or <see langword="null"/> if no such factory method is registered.</returns>
	public T TryGetFactoryMethod<T>() where T : class
	{
		Contract.EnsureNotDisposed(this, Disposed);

		return mFactory.TryGetFactoryMethod<T>();
	}

	/// <summary>
	/// Attempts to retrieve a named factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to retrieve.</typeparam>
	/// <param name="name">The name of the factory method to retrieve.</param>
	/// <returns>The specified named factory method, or <see langword="null"/> if no such factory method is registered.</returns>
	public T TryGetFactoryMethod<T>(String name) where T : class
	{
		Contract.EnsureNotDisposed(this, Disposed);

		return mFactory.TryGetFactoryMethod<T>(name);
	}

	/// <summary>
	/// Gets the factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to retrieve.</typeparam>
	/// <returns>The default factory method of the specified delegate type.</returns>
	public T GetFactoryMethod<T>() where T : class
	{
		Contract.EnsureNotDisposed(this, Disposed);

		return mFactory.GetFactoryMethod<T>();
	}

	/// <summary>
	/// Gets a named factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to retrieve.</typeparam>
	/// <param name="name">The name of the factory method to retrieve.</param>
	/// <returns>The specified named factory method.</returns>
	public T GetFactoryMethod<T>(String name) where T : class
	{
		Contract.EnsureNotDisposed(this, Disposed);
		Contract.RequireNotEmpty(name, nameof(name));

		return mFactory.GetFactoryMethod<T>(name);
	}


	protected virtual void Dispose(bool disposing)
	{
		if (Disposed)
			return;

		if (disposing)
		{
			Disposing = true;
			mJobs.Shutdown();
		}

		Disposed = true;
		Disposing = false;
	}

	/// <summary>
	/// Occurs when the context receives a message from its queue.
	/// </summary>
	/// <param name="type">The message type.</param>
	/// <param name="data">The message data.</param>
	protected virtual void OnReceivedMessage(MessageID type, MessageData data)
	{
	}

	protected virtual void OnFrameStart()
	{
		FrameStart?.[Friend]Invoke(this);
	}

	protected virtual void OnFrameEnd()
	{
		FrameEnd?.[Friend]Invoke(this);
	}

	protected virtual void OnUpdate(ApplicationTime time)
	{
		Updating?.[Friend]Invoke(this, time);
	}

	protected virtual void OnPostUpdate(ApplicationTime time)
	{
		PostUpdating?.[Friend]Invoke(this, time);
	}
}