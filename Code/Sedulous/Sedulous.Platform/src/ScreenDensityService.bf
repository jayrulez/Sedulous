using System;
using Sedulous.Foundation;

namespace Sedulous.Platform
{
    /// <summary>
    /// Represents a service which retrieve the pixel density (DPI) of the specified display device.
    /// </summary>
    public abstract class ScreenDensityService
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ScreenDensityService"/> class.
        /// </summary>
        /// <param name="display">The <see cref="IDisplay"/> for which to retrieve density information.</param>
        protected this(IDisplay display)
        {
            Contract.Require(display, nameof(display));
        }

        /// <summary>
        /// Gets the short name of the specified density bucket.
        /// </summary>
        /// <param name="bucket">The <see cref="ScreenDensityBucket"/> value for which to retrieve a short name.</param>
        /// <returns>The short name of the specified density bucket.</returns>
        public static String GetDensityBucketName(ScreenDensityBucket bucket)
        {
            switch (bucket)
            {
                case ScreenDensityBucket.Desktop:
                    return "pcdpi";
                case ScreenDensityBucket.Low:
                    return "ldpi";
                case ScreenDensityBucket.Retina:
                    return "retina";
                case ScreenDensityBucket.Medium:
                    return "mdpi";
                case ScreenDensityBucket.RetinaHD:
                    return "retinahd";
                case ScreenDensityBucket.High:
                    return "hdpi";
                case ScreenDensityBucket.ExtraHigh:
                    return "xhdpi";
                case ScreenDensityBucket.ExtraExtraHigh:
                    return "xxhdpi";
                case ScreenDensityBucket.ExtraExtraExtraHigh:
                    return "xxxhdpi";
            }

#unwarn			
            Runtime.ArgumentError("bucket");
        }

        /// <summary>
        /// Returns a probable DPI value which matches the specified density scale.
        /// </summary>
        /// <param name="scale">The density scale to evaluate.</param>
        /// <returns>A probable DPI value which matches the specified density scale.</returns>
        public static float GuessDensityFromDensityScale(float scale)
        {
            return GuessDensityFromBucket(GuessBucketFromDensityScale(scale));
        }

        /// <summary>
        /// Returns a probable DPI value which matches the specified density bucket.
        /// </summary>
        /// <param name="bucket">The density bucket to evaluate.</param>
        /// <returns>A probable DPI value which matches the specified density bucket.</returns>
        public static float GuessDensityFromBucket(ScreenDensityBucket bucket)
        {
            switch (bucket)
            {
                case ScreenDensityBucket.Low:
                    return 120f;

                case ScreenDensityBucket.Retina:
                    return 220f;

                case ScreenDensityBucket.Medium:
                    return 144f;

                case ScreenDensityBucket.RetinaHD:
                    return 330f;

                case ScreenDensityBucket.High:
                    return 240f;

                case ScreenDensityBucket.ExtraHigh:
                    return 288f;

                case ScreenDensityBucket.ExtraExtraHigh:
                    return 480f;

                case ScreenDensityBucket.ExtraExtraExtraHigh:
                    return 576f;

                default:
                    return 96f;
            }
        }

        /// <summary>
        /// Directs the service to refresh any cached values.
        /// </summary>
        /// <returns><see langword="true"/> if the display's density information changed; otherwise, <see langword="false"/>.</returns>
        public abstract bool Refresh();

        /// <summary>
        /// Gets the number of physical pixels per logical pixel on devices with high density display modes
        /// like Retina or Retina HD.
        /// </summary>
        public abstract float DeviceScale
        {
            get;
        }

        /// <summary>
        /// Gets the scaling factor for device independent pixels.
        /// </summary>
        public abstract float DensityScale
        {
            get;
        }

        /// <summary>
        /// Gets the screen's density in dots per inch along the horizontal axis.
        /// </summary>
        public abstract float DensityX
        {
            get;
        }

        /// <summary>
        /// Gets the screen's density in dots per inch along the vertical axis.
        /// </summary>
        public abstract float DensityY
        {
            get;
        }

        /// <summary>
        /// Gets the screen's density bucket.
        /// </summary>
        public abstract ScreenDensityBucket DensityBucket
        {
            get;
        }

        /// <summary>
        /// Attempts to guess at the appropriate <see cref="ScreenDensityBucket"/> for the specified density scale.
        /// </summary>
        /// <param name="scale">The density scale for which to guess a density bucket.</param>
        /// <returns>The <see cref="ScreenDensityBucket"/> which was guessed for the specified density scale.</returns>
        protected static ScreenDensityBucket GuessBucketFromDensityScale(float scale)
        {
            if (scale >= 6f)
                return ScreenDensityBucket.ExtraExtraExtraHigh;

            if (scale >= 5f)
                return ScreenDensityBucket.ExtraExtraHigh;

            if (scale >= 3f)
                return ScreenDensityBucket.ExtraHigh;

            if (scale >= 2.5f)
                return ScreenDensityBucket.High;

            if (scale >= 1.5f)
                return ScreenDensityBucket.Medium;

            if (scale >= 1.25f)
                return ScreenDensityBucket.Low;

            return ScreenDensityBucket.Desktop;
        }
    }
}
