using System.Collections;
using Sedulous.Foundation.Logging.Abstractions;
using System.Threading;
using System;
using static System.Platform;
namespace Sedulous.Core.Jobs;

using internal Sedulous.Core.Jobs;

class JobSystem
{
	private readonly Context mContext = null;

	private readonly List<BackgroundWorker> mWorkers = new .() ~ delete _;
	private readonly MainThreadWorker mMainThreadWorker = null;

	private readonly Monitor mJobsToRunMonitor = new .() ~ delete _;
	private readonly Queue<Job> mJobsToRun = new .() ~ delete _;

	private readonly Monitor mCompletedJobsMonitor = new .() ~ delete _;
	private readonly List<Job> mCompletedJobs = new .() ~ delete _;

	private readonly Monitor mCancelledJobsMonitor = new .() ~ delete _;
	private readonly List<Job> mCancelledJobs = new .() ~ delete _;

	private bool mIsRunning = false;

	public int WorkerCount => mWorkers?.Count ?? 0;

	public ILogger Logger => mContext.Logger;

	public this(Context context, int workerCount = 0)
	{
		var workerCount;

		mContext = context;

		workerCount = Math.Max(1, workerCount);

		BfpSystemResult result = .Ok;
		int coreCount = Platform.BfpSystem_GetNumLogicalCPUs(&result);
		if (result == .Ok)
		{
			workerCount = Math.Min(workerCount, coreCount - 1);
		}

		mMainThreadWorker = new .(this, "Main Thread Worker");

		for (int i = 0; i < workerCount; i++)
		{
			BackgroundWorker worker = new .(this, scope $"Worker {i}");

			mWorkers.Add(worker);
		}
	}

	public ~this()
	{
		for (Worker worker in mWorkers)
		{
			delete worker;
		}

		delete mMainThreadWorker;
	}

	private void OnJobCompleted(Job job, Worker worker)
	{
		using (mCompletedJobsMonitor.Enter())
		{
			job.AddRef();
			mCompletedJobs.Add(job);
		}
	}

	private void OnJobCancelled(Job job, Worker worker)
	{
		using (mCancelledJobsMonitor.Enter())
		{
			job.AddRef();
			mCancelledJobs.Add(job);
		}
	}

	internal void HandleProcessedJob(Job job, Worker worker)
	{
		if (job.State == .Completed)
			OnJobCompleted(job, worker);
		else if (job.State == .Canceled)
			OnJobCancelled(job, worker);
	}

	public void Startup()
	{
		Runtime.Assert(mContext.IsRunningOnContextThread);

		if (mIsRunning)
		{
			Logger.LogError("Startup called on JobSystem that is already running.");
			return;
		}

		mMainThreadWorker.Start();

		for (Worker worker in mWorkers)
		{
			worker.Start();
		}

		mIsRunning = true;
	}

	public void Shutdown()
	{
		Runtime.Assert(mContext.IsRunningOnContextThread);

		if (!mIsRunning)
		{
			Logger.LogError("Shutdown called on JobSystem that is not running.");
			return;
		}

		for (Worker worker in mWorkers)
		{
			worker.Stop();
		}

		mMainThreadWorker.Stop();

		while (mJobsToRun.Count > 0)
		{
			Job job = mJobsToRun.PopFront();
			defer job.ReleaseRef();
			job.Cancel();
			OnJobCancelled(job, null);
		}

		ClearCompletedJobs();

		ClearCancelledJobs();

		mIsRunning = false;
	}

	public void Update()
	{
		Runtime.Assert(mContext.IsRunningOnContextThread);

		if (!mIsRunning)
		{
			Logger.LogError("Update called on JobSystem that is not running.");
			return;
		}

		// todo: if there are no jobs for x frames then pause workers to save CPU

		using (mJobsToRunMonitor.Enter())
		{
			int numJobsToRun = mJobsToRun.Count;

			// while there are jobs to run
			while (numJobsToRun-- > 0)
			{
				// get the first job
				Job job = mJobsToRun.PopFront();

				// move job to the back of the queue if it is not ready
				if (!job.IsReady())
				{
					mJobsToRun.Add(job);
					continue;
				}

				// In all cases, we need to release the job
				defer job.ReleaseRef();

				// Queue the job on the main thread worker
				// if it has the RunOnMainThread flag
				if (job.Flags.HasFlag(.RunOnMainThread))
				{
					mMainThreadWorker.QueueJob(job);
					continue;
				}

				// Try to get a worker to queue the job on
				if (!GetAvailableWorker(var worker))
				{
					// We need to add a ref to the job to counter the previous release
					// We need to add the job back to the front of the queue
					// We need to break here if there are no available workers
					job.AddRef();
					mJobsToRun.AddFront(job);
					break;
				}

				switch (job.State) {
				case .Canceled:
					OnJobCancelled(job, null);
					break;
				case .Completed:
					OnJobCompleted(job, null);
					break;
				default:
					worker.QueueJob(job);
					break;
				}
			}
		}

		for (int i = 0; i < mWorkers.Count; i++)
		{
			if (mWorkers[i].State == .Idle)
			{
				mWorkers[i].Pause();
			}
		}

		// Process main thread jobs
		mMainThreadWorker.Update();

		ClearCompletedJobs();

		ClearCancelledJobs();
	}

	public void AddJob(Job job)
	{
		using (mJobsToRunMonitor.Enter())
		{
			job.AddRef();
			mJobsToRun.Add(job);
		}
	}

	public void AddJobs(Span<Job> jobs)
	{
		using (mJobsToRunMonitor.Enter())
		{
			for (Job job in jobs)
			{
				job.AddRef();
				mJobsToRun.Add(job);
			}
		}
	}

	public void AddJob(delegate void() jobDelegate, StringView? jobName = null, JobFlags flags = .None)
	{
		Job job = new DelegateJob(jobDelegate, jobName, flags | .AutoRelease);
		AddJob(job);
	}

	private bool GetAvailableWorker(out Worker worker)
	{
		for (int i = 0; i < mWorkers.Count; i++)
		{
			if (mWorkers[i].State == .Idle || mWorkers[i].State == .Paused)
			{
				worker = mWorkers[i];
				return true;
			}
		}

		worker = null;
		return false;
	}

	private void ClearCancelledJobs()
	{
		using (mCancelledJobsMonitor.Enter())
		{
			for (Job job in mCancelledJobs)
			{
				if (job.Flags.HasFlag(.AutoRelease))
				{
					job.ReleaseRef();
				}
				job.ReleaseRef();
			}
			mCancelledJobs.Clear();
		}
	}

	private void ClearCompletedJobs()
	{
		using (mCompletedJobsMonitor.Enter())
		{
			for (Job job in mCompletedJobs)
			{
				if (job.Flags.HasFlag(.AutoRelease))
				{
					job.ReleaseRef();
				}
				job.ReleaseRef();
			}
			mCompletedJobs.Clear();
		}
	}
}