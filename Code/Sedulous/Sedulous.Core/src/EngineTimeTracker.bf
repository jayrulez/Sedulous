using System;
namespace Sedulous.Core;

using internal Sedulous.Core;

/// <summary>
/// Contains methods for tracking the amount of time that has passed since a engine was created.
/// </summary>
class EngineTimeTracker
{
	/// <summary>
	/// Resets the time.
	/// </summary>
	/// <returns>The engine time value after the reset has been applied.</returns>
	public EngineTime Reset()
	{
	    mTime.ElapsedTime     = TimeSpan.Zero;
	    mTime.TotalTime       = TimeSpan.Zero;
	    mTime.IsRunningSlowly = false;
	    return mTime;
	}

	/// <summary>
	/// Increments the time.
	/// </summary>
	/// <param name="ts">The amount by which to increment the time.</param>
	/// <param name="isRunningSlowly">A value indicating whether the engine's main loop is taking longer than its target time.</param>
	/// <returns>The engine time value after the increment has been applied.</returns>
	public EngineTime Increment(TimeSpan ts, bool isRunningSlowly)
	{
	    mTime.ElapsedTime = ts;
	    mTime.TotalTime = mTime.TotalTime + ts;
	    mTime.IsRunningSlowly = isRunningSlowly;
	    return mTime;
	}

	/// <summary>
	/// Gets the current application time value.
	/// </summary>
	public EngineTime Time
	{
	    get { return mTime; }
	}

	// The application time value for the current engine.
	private readonly EngineTime mTime = new .() ~ delete _;
}