using System;
using Sedulous.Platform;

using SDL2Native;

using static SDL2Native.SDL2Native;

namespace Sedulous.SDL2
{
	/// <summary>
	/// Represents the SDL2 implementation of the <see cref="ClipboardService"/> class.
	/// </summary>
	public sealed class SDL2ClipboardService : ClipboardService
	{
		public override Result<void> GetText(out String str)
		{
			str = null;


			if (!SDL_HasClipboardText())
			{
				return .Err;
			}
			var ptr = SDL_GetClipboardText();
			if (ptr == null)
				return .Err;
			str = new .(ptr);
			SDL_free(ptr);

			return .Ok;
		}

		public override void SetText(StringView text)
		{
			SDL_SetClipboardText(text.Ptr);
		}
	}
}
