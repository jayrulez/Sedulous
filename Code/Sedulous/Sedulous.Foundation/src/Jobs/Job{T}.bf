using System;
using System.Collections;
namespace Sedulous.Foundation.Jobs;

abstract class Job<T> : JobBase
{
	private T mResult = default;
	public T Result { get => GetResult(); protected set; }

	private readonly delegate void(T result) mOnCompleted = null ~ { if (_ != null && mOwnsOnCompletedDelegate) delete _; };
	private bool mOwnsOnCompletedDelegate = true;

	public this(StringView? name,
		JobFlags flags,
		delegate void(T result) onCompleted = null,
		bool ownsOnCompletedDelegate = true)
		: base(name, flags)
	{
		mOnCompleted = onCompleted;
		mOwnsOnCompletedDelegate = ownsOnCompletedDelegate;
	}

	protected override void Execute()
	{
		mResult = OnExecute();
	}

	protected abstract T OnExecute();

	protected override void OnCompleted()
	{
		if (mOnCompleted != null)
		{
			mOnCompleted(mResult);
		}
	}

	private T GetResult()
	{
		while (!(mState == .Succeeded || mState == .Canceled))
		{
		}
		return mResult;
	}
}