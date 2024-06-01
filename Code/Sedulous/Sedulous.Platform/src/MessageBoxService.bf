using System;
using static Sedulous.Platform.IPlatformBackend;

namespace Sedulous.Platform
{
    /// <summary>
    /// Contains methods for displaying platform message boxes.
    /// </summary>
    public abstract class MessageBoxService
    {
        /// <summary>
        /// Displays a platform-specific message box with the specified text.
        /// </summary>
        /// <param name="type">A <see cref="MessageBoxType"/> value specifying the type of message box to display.</param>
        /// <param name="title">The message box's title text.</param>
        /// <param name="message">The message box's message text.</param>
        /// <param name="window">The native handle of the message box's parent window.</param>
        public abstract void ShowMessageBox(MessageBoxType type, String title, String message, void* window);
    }
}
