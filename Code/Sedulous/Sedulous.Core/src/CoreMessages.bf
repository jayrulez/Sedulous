namespace Sedulous.Core;

/// <summary>
/// Represents the standard set of Framework events.
/// </summary>
static class CoreMessages
{
	/// <summary>
	/// An event indicating that the application should exit.
	/// </summary>
	public static readonly MessageID Quit = MessageID.Acquire(nameof(Quit));

	/// <summary>
	/// An event indicating that the application has been created by the operating system.
	/// </summary>
	public static readonly MessageID ApplicationCreated = MessageID.Acquire(nameof(ApplicationCreated));

	/// <summary>
	/// An event indicating that the application is being terminated by the operating system.
	/// </summary>
	public static readonly MessageID ApplicationTerminating = MessageID.Acquire(nameof(ApplicationTerminating));

	/// <summary>
	/// An event indicating that the application is about to be suspended.
	/// </summary>
	public static readonly MessageID ApplicationSuspending = MessageID.Acquire(nameof(ApplicationSuspending));

	/// <summary>
	/// An event indicating that the application was suspended.
	/// </summary>
	public static readonly MessageID ApplicationSuspended = MessageID.Acquire(nameof(ApplicationSuspended));

	/// <summary>
	/// An event indicating that the application is about to resume after being suspended.
	/// </summary>
	public static readonly MessageID ApplicationResuming = MessageID.Acquire(nameof(ApplicationResuming));

	/// <summary>
	/// An event indicating that the application was resumed after being suspended.
	/// </summary>
	public static readonly MessageID ApplicationResumed = MessageID.Acquire(nameof(ApplicationResumed));

	/// <summary>
	/// An event indicating that the operation system is low on memory.
	/// </summary>
	public static readonly MessageID LowMemory = MessageID.Acquire(nameof(LowMemory));

	/// <summary>
	/// An event indicating that the software keyboard was shown.
	/// </summary>
	public static readonly MessageID SoftwareKeyboardShown = MessageID.Acquire(nameof(SoftwareKeyboardShown));

	/// <summary>
	/// An event indicating that the software keyboard was hidden.
	/// </summary>
	public static readonly MessageID SoftwareKeyboardHidden = MessageID.Acquire(nameof(SoftwareKeyboardHidden));

	/// <summary>
	/// An event indicating that the text input region has been changed.
	/// </summary>
	public static readonly MessageID TextInputRegionChanged = MessageID.Acquire(nameof(TextInputRegionChanged));
}