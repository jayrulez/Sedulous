using System;
namespace Sedulous.Platform
{
    /// <summary>
    /// Represents the buckets into which the framework classifies the pixel density of a display device.
    /// </summary>
    public enum ScreenDensityBucket
    {
        /// <summary>
        /// Standard desktop DPI (72 dpi).
        /// </summary>
        Desktop,

        /// <summary>
        /// Low mobile DPI (~120 dpi).
        /// </summary>
        Low,

        /// <summary>
        /// macOS Retina DPI (~144 dpi).
        /// </summary>
        Retina,

        /// <summary>
        /// Medium mobile DPI (~160 dpi).
        /// </summary>
        Medium,

        /// <summary>
        /// macOS Retina HD DPI (~216 DPI).
        /// </summary>
        RetinaHD,

        /// <summary>
        /// High mobile DPI (~240 dpi).
        /// </summary>
        High,

        /// <summary>
        /// Extra high mobile DPI (~320 dpi).
        /// </summary>
        ExtraHigh,

        /// <summary>
        /// Extra extra high mobile DPI (~480 dpi).
        /// </summary>
        ExtraExtraHigh,

        /// <summary>
        /// Extra extra extra high mobile DPI (~640 dpi).
        /// </summary>
        ExtraExtraExtraHigh,
    }

	public extension ScreenDensityBucket
	{
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
		/// Attempts to guess at the appropriate <see cref="ScreenDensityBucket"/> for the specified density scale.
		/// </summary>
		/// <param name="scale">The density scale for which to guess a density bucket.</param>
		/// <returns>The <see cref="ScreenDensityBucket"/> which was guessed for the specified density scale.</returns>
		public static ScreenDensityBucket GuessBucketFromDensityScale(float scale)
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
