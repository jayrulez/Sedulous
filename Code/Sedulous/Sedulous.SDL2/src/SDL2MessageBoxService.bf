using System;
using Sedulous.Platform;
using SDL2Native;
using static Sedulous.Platform.IPlatformBackend;
using static SDL2Native.SDL2Native;

namespace Sedulous.SDL2
{
    /// <summary>
    /// Represents the SDL2 implementation of the <see cref="MessageBoxService"/> class.
    /// </summary>
    public sealed class SDL2MessageBoxService : MessageBoxService
    {
        /// <inhertidoc/>
        public override void ShowMessageBox(MessageBoxType type, String title, String message, void* window)
        {
            var flags = GetSDLMessageBoxFlag(type);

            if (SDL_ShowSimpleMessageBox(flags, title, message, (SDL_Window*)window) < 0)
                Runtime.SDL2Error();
        }
        
        /// <summary>
        /// Converts a <see cref="MessageBoxType"/> value to the equivalent SDL2 flag.
        /// </summary>
        private static uint32 GetSDLMessageBoxFlag(MessageBoxType type)
        {
            switch (type)
            {
                case MessageBoxType.Information:
                    const uint32 SDL_MESSAGEBOX_INFORMATION = 0x00000040;
                    return SDL_MESSAGEBOX_INFORMATION;

                case MessageBoxType.Warning:
                    const uint32 SDL_MESSAGEBOX_WARNING = 0x00000020;
                    return SDL_MESSAGEBOX_WARNING;

                case MessageBoxType.Error:
                    const uint32 SDL_MESSAGEBOX_ERROR = 0x00000010;
                    return SDL_MESSAGEBOX_ERROR;

                default:
                    return 0;
            }
        }
    }
}
