using System;
namespace Sedulous.Core.Abstractions;

/// <summary>
/// Represents an object which hosts instances of Context.
/// </summary>
interface IApplication
{
	/// <summary>
	/// Gets the context.
	/// </summary>
	Context Context { get; }

	/// <summary>
	/// Gets the name of the application.
	/// </summary>
	String ApplicationName { get; }

	/// <summary>
	/// Gets a value indicating whether the application's primary window is currently active.
	/// </summary>
	bool IsActive { get; }

	/// <summary>
	/// Gets a value indicating whether the application has been suspended.
	/// </summary>
	bool IsSuspended { get; }

	/// <summary>
	/// Gets or sets a value indicating whether the application is running on a fixed time step.
	/// </summary>
	bool IsFixedTimeStep { get; set; }

	/// <summary>
	/// Gets or sets the target time between frames when the application is running on a fixed time step.
	/// </summary>
	TimeSpan TargetElapsedTime { get; set; }

	/// <summary>
	/// Gets or sets the amount of time to sleep every frame when
	/// the application's primary window is inactive.
	/// </summary>
	TimeSpan InactiveSleepTime { get; set; }
}