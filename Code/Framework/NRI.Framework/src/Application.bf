using System;
namespace NRI.Framework;

abstract class Application
{
	private bool mIsRunning = false;

	protected virtual Result<void> OnStartup() => .Ok;

	protected virtual Result<void> OnInitialize() => .Ok;

	protected virtual void OnFinalize() => void();

	protected virtual void OnShutdown() => void();

	protected virtual void OnFrame() => void();

	private Result<void> Startup()
	{
		if (OnStartup() case .Err)
			return .Err;

		return .Ok;
	}

	private Result<void> Initialize()
	{
		if (OnInitialize() case .Err)
			return .Err;

		return .Ok;
	}

	private void Shutdown()
	{
		OnShutdown();
	}

	private void RunFrame()
	{
		OnFrame();
	}

	public void Start()
	{
		if (mIsRunning)
		{
			return;
		}

		if (Startup() case .Err)
		{
			OnShutdown();
			return;
		}

		if (Initialize() case .Err)
		{
			OnFinalize();
			Shutdown();
			return;
		}

		mIsRunning = true;
	}

	public void Update()
	{
		if(!mIsRunning)
			return;

		RunFrame();
	}

	public void Stop()
	{
		mIsRunning = false;

		OnFinalize();
		Shutdown();
	}
}