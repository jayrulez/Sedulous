using Sedulous.Core;
using System;
using Sedulous.Platform.Input;
namespace Sedulous.Platform;

/// <summary>
/// Represents the framework's platform interop subsystem.
/// </summary>
interface IPlatformBackend : IContextHost
{
	public struct WindowConfiguration
	{
		public const int32 DefaultWindowPositionX = -1;
		public const int32 DefaultWindowPositionY = -1;
		public const int32 DefaultWindowClientWidth = 1280;
		public const int32 DefaultWindowClientHeight = 720;

		
		public StringView Title { get; set mut; } = "Sedulous";
		public uint16 Width { get; set mut; } = DefaultWindowClientWidth;
		public uint16 Height { get; set mut; } = DefaultWindowClientHeight;
	}

	/// <summary>
	/// Represents the types of message box which can be displayed by the <see cref="IPlatformBackend.ShowMessageBox"/> method.
	/// </summary>
	public enum MessageBoxType
	{
	    /// <summary>
	    /// An informational dialog.
	    /// </summary>
	    Information,

	    /// <summary>
	    /// A warning dialog.
	    /// </summary>
	    Warning,

	    /// <summary>
	    /// An error dialog.
	    /// </summary>
	    Error,
	}

	/// <summary>
	/// Displays a platform-specific message box with the specified text.
	/// </summary>
	/// <param name="type">A <see cref="MessageBoxType"/> value specifying the type of message box to display.</param>
	/// <param name="title">The message box's title text.</param>
	/// <param name="message">The message box's message text.</param>
	/// <param name="parent">The message box's parent window, or <see langword="null"/> to use the primary window.</param>
	void ShowMessageBox(MessageBoxType type, String title, String message, IWindow parent = null);

	/// <summary>
	/// Gets a value indicating whether the application's primary window has been initialized.
	/// </summary>
	bool IsPrimaryWindowInitialized { get; }

	/// <summary>
	/// Gets or sets a value indicating whether the mouse cursor is visible.
	/// </summary>
	bool IsCursorVisible { get; set; }

	/*/// <summary>
	/// Gets or sets the current cursor.
	/// </summary>
	/// <remarks>Setting this property to <see langword="null"/> will restore the default cursor.</remarks>
	Cursor Cursor { get; set; }*/

	/// <summary>
	/// Gets the system clipboard manager.
	/// </summary>
	ClipboardService Clipboard { get; }

	/// <summary>
	/// Gets the window information manager.
	/// </summary>
	IWindowInfo Windows { get; }

	/// <summary>
	/// Gets the display information manager.
	/// </summary>
	IDisplayInfo Displays { get; }

	InputSystem Input {get;}

	bool SupportsHighDensityDisplayModes {get;}
}