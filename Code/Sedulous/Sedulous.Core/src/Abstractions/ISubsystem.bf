using Sedulous.Foundation;
namespace Sedulous.Core.Abstractions;

/// <summary>
/// Represents the method that is called when a subsystem updates its state.
/// </summary>
/// <param name="subsystem">The subsystem.</param>
/// <param name="time">Time elapsed since the last call to <see cref="Context.Update(ApplicationTime)"/>.</param>
public delegate void SubsystemUpdateEventHandler(ISubsystem subsystem, ApplicationTime time);

/// <summary>
/// Represents one of Ultraviolet's subsystems.
/// </summary>
public interface ISubsystem : IContextComponent
{
	/// <summary>
	/// Updates the subsystem's state.
	/// </summary>
	/// <param name="time">Time elapsed since the last call to <see cref="Context.Update(ApplicationTime)"/>.</param>
	void Update(ApplicationTime time);

	/// <summary>
	/// Gets a value indicating whether the object has been disposed.
	/// </summary>
	bool Disposed { get; }

	/// <summary>
	/// Occurs when the subsystem is updating its state.
	/// </summary>
	EventAccessor<SubsystemUpdateEventHandler> Updating { get; }
}