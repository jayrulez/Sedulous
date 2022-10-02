using System;
namespace Sedulous.Core.Abstractions;

/// <summary>
/// Represents an interface which provides the logic for a Context host's core timing loop.
/// </summary>
interface IApplicationTimingLogic : IContextComponent
{
	/// <summary>
	/// Resets the timers used to determine how much time has passed since the last calls
	/// to <see cref="Context.Update"/> and <see cref="Context.PostUpdate"/>.
	/// </summary>
	void ResetElapsed();

	/// <summary>
	/// Advances the application state while the application is suspended.
	/// </summary>
	void RunOneTickSuspended();

	/// <summary>
	/// Advances the application state by one tick.
	/// </summary>
	void RunOneTick();

	/// <summary>
	/// Cleans up any state after the application has finished its run loop.
	/// </summary>
	void Cleanup();

	/// <summary>
	/// Gets or sets the target time between frames when the application is running on a fixed time step.
	/// </summary>
	TimeSpan TargetElapsedTime { get; set; }

	/// <summary>
	/// Gets or sets the amount of time to sleep every frame when
	/// the application's primary window is inactive.
	/// </summary>
	TimeSpan InactiveSleepTime { get; set; }

	/// <summary>
	/// Gets or sets a value indicating whether the application is running on a fixed time step.
	/// </summary>
	bool IsFixedTimeStep { get; set; }
}