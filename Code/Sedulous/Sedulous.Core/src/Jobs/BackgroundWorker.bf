using System.Threading;
using System;
using System.Collections;
namespace Sedulous.Core.Jobs;

using internal Sedulous.Core.Jobs;

internal class BackgroundWorker : Worker
{
	private readonly Thread mThread = null;

	public this(JobSystem jobSystem, StringView name)
		: base(jobSystem, name)
	{
		mThread = new Thread(new => this.ProcessJobsAsync);
		mThread.SetName(mName);
	}

	public ~this()
	{
		delete mThread;
	}

	protected override void OnStarting()
	{
		mThread.Start(false);
	}

	protected override void OnStopping()
	{
		mThread.Join();
	}

	protected override void OnPausing()
	{
		if (mThread.ThreadState == .Running)
			mThread.Suspend();
	}


	protected override void OnResuming()
	{
		if (mThread.ThreadState == .Suspended)
			mThread.Resume();
	}

	private void ProcessJobsAsync()
	{
		while (true)
		{
			if (!mIsRunning)
			{
				mState = .Dead;
				return;
			}

			ProcessJobs();
		}
	}
}