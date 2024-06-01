using System;
using System.Collections;
using Sedulous.Foundation;

namespace Sedulous.Platform
{
    /// <summary>
    /// Represents an event that occurs when the framework updates its window information.
    /// </summary>
    /// <param name="window">The window that was updated.</param>
    public delegate void WindowInfoEventHandler(IWindow window);

    /// <summary>
    /// Provides access to information concerning the context's attached windows.
    /// </summary>
    public interface IWindowInfo : IEnumerable<IWindow>
    {
        /// <summary>
        /// Gets the window with the specified identifier.
        /// </summary>
        /// <param name="id">The identifier of the window to retrieve.</param>
        /// <returns>The window with the specified identifier, or <see langword="null"/> if no such window exists.</returns>
        IWindow GetByID(int32 id);

        /// <summary>
        /// Gets the context's primary window.
        /// </summary>
        /// <returns>The context's primary window, or <see langword="null"/> if the context is headless.</returns>
        IWindow GetPrimary();

        /// <summary>
        /// Gets the context's current window.
        /// </summary>
        /// <returns>The context's current window.</returns>
        IWindow GetCurrent();
        
        /// <summary>
        /// Creates a new window and attaches it to the current context.
        /// </summary>
        /// <param name="caption">The window's caption text.</param>
        /// <param name="x">The x-coordinate at which to position the window's top-left corner.</param>
        /// <param name="y">The y-coordinate at which to position the window's top-left corner.</param>
        /// <param name="width">The width of the window's client area in pixels.</param>
        /// <param name="height">The height of the window's client area in pixels.</param>
        /// <param name="flags">A set of <see cref="WindowFlags"/> values indicating how to create the window.</param>
        /// <returns>The window that was created.</returns>
        IWindow Create(StringView caption, int32 x, int32 y, int32 width, int32 height, WindowFlags flags = WindowFlags.None);

        /// <summary>
        /// Destroys the specified window.
        /// </summary>
        /// <remarks>Windows which were created from native pointers are disassociated from the current context,
        /// but are not actually destroyed. To destroy such windows, use the native framework which created them.</remarks>
        /// <param name="window">The window to destroy.</param>
        /// <returns><see langword="true"/> if the window was destroyed; <see langword="false"/> if the window was closed.</returns>
        bool Destroy(IWindow window);

        /// <summary>
        /// Destroys the window with the specified identifier.
        /// </summary>
        /// <param name="id">The identifier of the window to destroy.</param>
        /// <returns><see langword="true"/> if the window was destroyed; <see langword="false"/> if the window was closed.</returns>
        bool DestroyByID(int32 id);

        /// <summary>
        /// Gets the collection's enumerator.
        /// </summary>
        /// <returns>The collection's enumerator.</returns>
        new List<IWindow>.Enumerator GetEnumerator();

        /// <summary>
        /// Occurs after a window has been created.
        /// </summary>
        EventAccessor<WindowInfoEventHandler> WindowCreated {get;}

        /// <summary>
        /// Occurs when a window is about to be destroyed.
        /// </summary>
        EventAccessor<WindowInfoEventHandler> WindowDestroyed {get;}
    }
}
