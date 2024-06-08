using System;
namespace Sedulous.Foundation.Jobs;

class DelegateJob<T> : Job<T>
{
	private delegate T() mJob = null ~ delete _;

	public this(delegate T() job,
		StringView? name,
		JobFlags flags,
		delegate void(T result) onCompleted = null,
		bool ownsOnCompletedDelegate = true) : base(name, flags, onCompleted, ownsOnCompletedDelegate)
	{
		mJob = job;
	}

	protected override T OnExecute()
	{
		return mJob?.Invoke();
	}
}