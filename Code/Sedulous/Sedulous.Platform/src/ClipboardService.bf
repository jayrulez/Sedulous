using System;

namespace Sedulous.Platform
{
    /// <summary>
    /// Contains methods for interacting with the system clipboard.
    /// </summary>
    public abstract class ClipboardService
    {
		/// <summary>
		/// Gets the clipboard text.
		/// </summary>
		public abstract Result<void> GetText(out String str);
		
		/// <summary>
		/// Sets the clipboard text.
		/// </summary>
		public abstract void SetText(StringView text);
    }
}
