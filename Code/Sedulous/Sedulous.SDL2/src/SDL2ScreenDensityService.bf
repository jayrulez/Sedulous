using System;
using Sedulous.Platform;
using Sedulous.Foundation;

using static SDL2Native.SDL2Native;

namespace Sedulous.SDL2
{
    /// <summary>
    /// Represents an implentation of <see cref="ScreenDensityService"/> using the SDL2 library.
    /// </summary>
    public sealed class SDL2ScreenDensityService : ScreenDensityService
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SDL2ScreenDensityService"/> class.
        /// </summary>
        /// <param name="backend">The backend.</param>
        /// <param name="display">The <see cref="IDisplay"/> for which to retrieve density information.</param>
        public this(SDL2PlatformBackend backend, IDisplay display)
            : base(display)
        {
            Contract.Require(backend, nameof(backend));

            this.mBackend = backend;
            this.display = display;

            Refresh();
        }

        /// <inheritdoc/>
        public override bool Refresh()
        {
            var oldDensityX = densityX;
            var oldDensityY = densityY;
            var oldDensityScale = densityScale;
            var oldDensityBucket = densityBucket;

            float hdpi = 0, vdpi = 0;
            {
                if (SDL_GetDisplayDPI(display.Index, null, &hdpi, &vdpi) < 0)
                    Runtime.SDL2Error();                
            }

            this.densityX = hdpi;
            this.densityY = vdpi;
            this.densityScale = hdpi / 96f;
            this.densityBucket = GuessBucketFromDensityScale(densityScale);

            return oldDensityX != densityX || oldDensityY != densityY || oldDensityScale != densityScale || oldDensityBucket != densityBucket;
        }

        /// <inheritdoc/>
        public override float DeviceScale
        {
            get { return 1f; }
        }

        /// <inheritdoc/>
        public override float DensityScale
        {
            get { return densityScale; }
        }

        /// <inheritdoc/>
        public override float DensityX
        {
            get { return densityX; }
        }

        /// <inheritdoc/>
        public override float DensityY
        {
            get { return densityY; }
        }

        /// <inheritdoc/>
        public override ScreenDensityBucket DensityBucket
        {
            get { return densityBucket; }
        }

        // State values.
        private readonly SDL2PlatformBackend mBackend;
        private readonly IDisplay display;
        private float densityX;
        private float densityY;
        private float densityScale;
        private ScreenDensityBucket densityBucket;
    }
}
