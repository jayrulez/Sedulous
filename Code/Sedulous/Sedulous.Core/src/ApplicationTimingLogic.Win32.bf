using Sedulous.Core.Abstractions;
using System;
using Sedulous.Foundation;
using System.Threading;
namespace Sedulous.Core;

#if BF_PLATFORM_WINDOWS

public static
{
	[Import("winmm.lib"), CLink, CallingConvention(.Stdcall)]
	public static extern uint32 timeBeginPeriod(uint32 period);

	[Import("winmm.lib"), CLink, CallingConvention(.Stdcall)]
	public static extern uint32 timeEndPeriod(uint32 period);
}

extension ApplicationTimingLogic
{
	public new void Cleanup()
	{
		if (mSystemTimerPeriod > 0)
			timeEndPeriod(mSystemTimerPeriod);

		mSystemTimerPeriod = 0;
	}

	private new bool UpdateSystemTimerResolution()
	{
		var requiredTimerPeriod = (uint32)Math.Max(1u, mApplication.IsActive ? (IsFixedTimeStep ? 1u : 15u) : (uint32)InactiveSleepTime.TotalMilliseconds);
		if (requiredTimerPeriod != mSystemTimerPeriod)
		{
			if (mSystemTimerPeriod > 0)
				timeEndPeriod(mSystemTimerPeriod);

			var result = timeBeginPeriod(requiredTimerPeriod);
			mSystemTimerPeriod = requiredTimerPeriod;
			return (result == 0);
		}

		return false;
	}
}
#endif