using System;
using System.Collections;
using Sedulous.Foundation;
using Sedulous.Foundation.Utilities;
using Sedulous.Platform;
using static SDL2Native.SDL2Native;

namespace Sedulous.SDL2
{
    /// <summary>
    /// Represents the SDL2 implementation of the <see cref="IDisplayInfo"/> interface.
    /// </summary>
    public sealed class SDL2DisplayInfo : IDisplayInfo
    {
        /// <summary>
        /// Initializes a new instance of the SDL2DisplayInfo class.
        /// </summary>
        /// <param name="backend">The backend.</param>
        public this(SDL2PlatformBackend backend)
        {
            Contract.Require(backend, nameof(backend));

			this.displays = new .(){ Count = SDL_GetNumVideoDisplays()};
			for(int i = 0; i < this.displays.Count; i++)
			{
				this.displays[i] = new SDL2Display(backend, (int32)i);
			}
        }

		public ~this()
		{
			for(int i = 0; i < this.displays.Count; i++)
			{
				delete displays[i];
			}
			delete displays;
		}

        /// <summary>
        /// Updates the state of the application's displays.
        /// </summary>
        /// <param name="time">Time elapsed since the last call to <see cref="Context.Update(Time)"/>.</param>
        public void Update(Time time)
        {
            for (var display in displays)
                ((SDL2Display)display).Update(time);
        }

        /// <inheritdoc/>
        public IDisplay this[int ix]
        {
            get { return displays[ix]; }
        }

        /// <inheritdoc/>
        public IDisplay PrimaryDisplay
        {
            get { return displays.Count == 0 ? null : displays[0]; }
        }

        /// <inheritdoc/>
        public int Count
        {
            get { return displays.Count; }
        }

        /// <inheritdoc/>
        public List<IDisplay>.Enumerator GetEnumerator()
        {
            return displays.GetEnumerator();
        }

        /*/// <inheritdoc/>
        IEnumerator IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }

        /// <inheritdoc/>
        IEnumerator<IDisplay> IEnumerable<IDisplay>.GetEnumerator()
        {
            return GetEnumerator();
        }*/

        // The list of display devices.  SDL2 never updates its device info, even if
        // devices are added or removed, so we only need to create this once.
        private readonly List<IDisplay> displays;
    }
}
