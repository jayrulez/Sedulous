using System;
namespace Sedulous.Foundation.Utilities;

using internal Sedulous.Foundation.Utilities;

sealed class TimeTracker
{
	public Time Reset()
	{
		mTime.ElapsedTime     = TimeSpan.Zero;
		mTime.TotalTime       = TimeSpan.Zero;
		return mTime;
	}

	public Time Increment(TimeSpan ts)
	{
		mTime.ElapsedTime = ts;
		mTime.TotalTime = mTime.TotalTime + ts;
		return mTime;
	}

	public Time Time => mTime;

	private readonly Time mTime = new .() ~ delete _;
}