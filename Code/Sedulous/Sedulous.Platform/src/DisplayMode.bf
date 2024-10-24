using System;
using Sedulous.Foundation;

namespace Sedulous.Platform
{
    /// <summary>
    /// <para>Represents a display mode.</para>
    /// <para>A display mode encapsulates all of the parameters of a display device, 
    /// include its resolution, bit depth, and refresh rate.</para>
    /// </summary>
    public sealed struct DisplayMode
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="DisplayMode"/> class.
        /// </summary>
        /// <param name="width">The display mode's width in pixels.</param>
        /// <param name="height">The display mode's height in pixels.</param>
        /// <param name="bpp">The display mode's bit depth.</param>
        /// <param name="refresh">The display mode's refresh rate in hertz.</param>
        /// <param name="displayIndex">The index of the display in which to place a window when it enters this display mode,
        /// or <see langword="null"/> if the window has no preferred display.</param>
        public this(int32 width, int32 height, int32 bpp, int32 refresh, int32? displayIndex = null)
        {
            Contract.EnsureRange(width > 0, nameof(width));
            Contract.EnsureRange(height > 0, nameof(height));
            Contract.EnsureRange(bpp > 0, nameof(bpp));

            this.Width = width;
            this.Height = height;
            this.BitsPerPixel = bpp;
            this.RefreshRate = refresh;
            this.DisplayIndex = displayIndex;
        }

        /// <summary>
        /// Converts the object to a human-readable string.
        /// </summary>
        /// <returns>A human-readable string that represents the object.</returns>
        public override void ToString(String str)
        {
            str.AppendF("{0}x{1}x{2} @{3}", Width, Height, BitsPerPixel, RefreshRate);
        }

        /// <summary>
        /// Determines whether the specified display mode is equivalent to this display mode by comparing
        /// their vertical and horizontal resolutions, as well as optionally comparing their bit depths
        /// and refresh rates.
        /// </summary>
        /// <param name="other">The <see cref="DisplayMode"/> instance to compare to this instance.</param>
        /// <param name="considerBitsPerPixel">A value indicating whether to compare the bit depths of the two display modes.</param>
        /// <param name="considerRefreshRate">A value indicating whether to compare the refresh rates of the two display modes.</param>
        /// <param name="considerDisplay">A value indicating whether to compare the preferred displays of the two display modes.</param>
        /// <returns><see langword="true"/> if the two display modes are equivalent; otherwise, <see langword="false"/>.</returns>
        public bool IsEquivalentTo(DisplayMode? other, 
            bool considerBitsPerPixel = true, 
            bool considerRefreshRate = true, 
            bool considerDisplay = false)
        {
            if (other == null)
                return false;

            if (other == this)
                return true;

            if (other.Value.Width != Width || other.Value.Height != Height)
                return false;

            if (considerBitsPerPixel && other.Value.BitsPerPixel != BitsPerPixel)
                return false;

            if (considerRefreshRate && other.Value.RefreshRate != RefreshRate)
                return false;

            if (considerDisplay && other.Value.DisplayIndex != DisplayIndex)
                return false;

            return true;
        }

        /// <summary>
        /// Gets the display's width in pixels.
        /// </summary>
        public int32 Width
        {
            get;
            private set mut;
        }

        /// <summary>
        /// Gets the display's height in pixels.
        /// </summary>
        public int32 Height
        {
            get;
            private set mut;
        }

        /// <summary>
        /// Gets the display's bit depth.
        /// </summary>
        public int32 BitsPerPixel
        {
            get;
            private set mut;
        }

        /// <summary>
        /// Gets the display's refresh rate in hertz.
        /// </summary>
        public int32 RefreshRate
        {
            get;
            private set mut;
        }
        
        /// <summary>
        /// Gets the index of the display in which to place a window when it enters this display mode,
        /// or <see langword="null"/> if the window has no preferred display.
        /// </summary>
        public int32? DisplayIndex
        {
            get;
            private set mut;
        }
    }
}
