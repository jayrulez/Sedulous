using System;
using SDL2Native;
using Sedulous.Platform;
using System.Collections;
using Sedulous.Foundation.Mathematics;
using Sedulous.Foundation.Utilities;
using Sedulous.Foundation;
using static SDL2Native.SDL2Native;

namespace Sedulous.SDL2
{
	/// <summary>
	/// Represents the SDL2 implementation of the <see cref="IDisplay"/> interface.
	/// </summary>
	public class SDL2Display : IDisplay
	{
		/// <summary>
		/// Initializes a new instance of the SDL2Display class.
		/// </summary>
		/// <param name="backend">The backend.</param>
		/// <param name="displayIndex">The SDL2 display index that this object represents.</param>
		public this(SDL2PlatformBackend backend, int32 displayIndex)
		{
			Contract.Require(backend, nameof(backend));

			this.mBackend = backend;

			this.displayIndex = displayIndex;
			this.displayModes = new .() { Count = SDL_GetNumDisplayModes(displayIndex) };
			for (int modeIndex = 0; modeIndex < this.displayModes.Count; modeIndex++)
			{
				this.displayModes[modeIndex] =  CreateDisplayModeFromSDL(displayIndex, (int32)modeIndex);
			}

			this.name = new .(SDL_GetDisplayName(displayIndex));

			SDL_DisplayMode sdlDesktopDisplayMode = default;
			if (SDL_GetDesktopDisplayMode(displayIndex, &sdlDesktopDisplayMode) < 0)
				Runtime.SDL2Error();

			this.desktopDisplayMode = CreateDisplayModeFromSDL(sdlDesktopDisplayMode);

			this.screenRotationService = new SDL2ScreenRotationService(this);
			this.screenDensityService = new SDL2ScreenDensityService(backend, this);
		}

		public ~this()
		{
			delete screenRotationService;
			delete screenDensityService;
			delete name;
			delete displayModes;
		}

		/// <inheritdoc/>
		public IEnumerable<DisplayMode> GetSupportedDisplayModes()
		{
			return displayModes;
		}

		/// <inheritdoc/>
		public double InchesToPixels(double inches)
		{
			return DipsToPixels(96.0 * inches);
		}

		/// <inheritdoc/>
		public double PixelsToInches(double pixels)
		{
			return PixelsToDips(pixels) / 96.0;
		}

		/// <inheritdoc/>
		public double DipsToPixels(double dips)
		{
			if (double.IsPositiveInfinity(dips))
			{
				return int32.MaxValue;
			}
			if (double.IsNegativeInfinity(dips))
			{
				return int32.MinValue;
			}
			return dips * DensityScale;
		}

		/// <inheritdoc/>
		public double PixelsToDips(double pixels)
		{
			return pixels / DensityScale;
		}

		/// <inheritdoc/>
		public double InchesToDips(double inches)
		{
			return 96.0 * inches;
		}

		/// <inheritdoc/>
		public double DipsToInches(double dips)
		{
			return dips / 96.0;
		}

		/// <inheritdoc/>
		public Point2D InchesToPixels(Point2D inches)
		{
			var x = InchesToPixels(inches.X);
			var y = InchesToPixels(inches.Y);

			return Point2D(x, y);
		}

		/// <inheritdoc/>
		public Point2D PixelsToInches(Point2D pixels)
		{
			var x = PixelsToInches(pixels.X);
			var y = PixelsToInches(pixels.Y);

			return Point2D(x, y);
		}

		/// <inheritdoc/>
		public Point2D DipsToPixels(Point2D dips)
		{
			var x = DipsToPixels(dips.X);
			var y = DipsToPixels(dips.Y);

			return Point2D(x, y);
		}

		/// <inheritdoc/>
		public Point2D PixelsToDips(Point2D pixels)
		{
			var x = PixelsToDips(pixels.X);
			var y = PixelsToDips(pixels.Y);

			return Point2D(x, y);
		}

		/// <inheritdoc/>
		public Point2D InchesToDips(Point2D inches)
		{
			var x = InchesToDips(inches.X);
			var y = InchesToDips(inches.Y);

			return Point2D(x, y);
		}

		/// <inheritdoc/>
		public Point2D DipsToInches(Point2D dips)
		{
			var x = DipsToInches(dips.X);
			var y = DipsToInches(dips.Y);

			return Point2D(x, y);
		}

		/// <inheritdoc/>
		public Size2D InchesToPixels(Size2D inches)
		{
			var width = InchesToPixels(inches.Width);
			var height = InchesToPixels(inches.Height);

			return Size2D(width, height);
		}

		/// <inheritdoc/>
		public Size2D PixelsToInches(Size2D pixels)
		{
			var width = PixelsToInches(pixels.Width);
			var height = PixelsToInches(pixels.Height);

			return Size2D(width, height);
		}

		/// <inheritdoc/>
		public Size2D DipsToPixels(Size2D dips)
		{
			var width = DipsToPixels(dips.Width);
			var height = DipsToPixels(dips.Height);

			return Size2D(width, height);
		}

		/// <inheritdoc/>
		public Size2D PixelsToDips(Size2D pixels)
		{
			var width = PixelsToDips(pixels.Width);
			var height = PixelsToDips(pixels.Height);

			return Size2D(width, height);
		}

		/// <inheritdoc/>
		public Size2D InchesToDips(Size2D inches)
		{
			var width = InchesToDips(inches.Width);
			var height = InchesToDips(inches.Height);

			return Size2D(width, height);
		}

		/// <inheritdoc/>
		public Size2D DipsToInches(Size2D dips)
		{
			var width = DipsToInches(dips.Width);
			var height = DipsToInches(dips.Height);

			return Size2D(width, height);
		}

		/// <inheritdoc/>
		public RectangleD InchesToPixels(RectangleD inches)
		{
			var x = InchesToPixels(inches.X);
			var y = InchesToPixels(inches.Y);
			var width = InchesToPixels(inches.Width);
			var height = InchesToPixels(inches.Height);

			return RectangleD(x, y, width, height);
		}

		/// <inheritdoc/>
		public RectangleD PixelsToInches(RectangleD pixels)
		{
			var x = PixelsToInches(pixels.X);
			var y = PixelsToInches(pixels.Y);
			var width = PixelsToInches(pixels.Width);
			var height = PixelsToInches(pixels.Height);

			return RectangleD(x, y, width, height);
		}

		/// <inheritdoc/>
		public RectangleD DipsToPixels(RectangleD dips)
		{
			var x = DipsToPixels(dips.Left);
			var y = DipsToPixels(dips.Top);
			var width = DipsToPixels(dips.Width);
			var height = DipsToPixels(dips.Height);

			return RectangleD(x, y, width, height);
		}

		/// <inheritdoc/>
		public RectangleD PixelsToDips(RectangleD pixels)
		{
			var x = PixelsToDips(pixels.X);
			var y = PixelsToDips(pixels.Y);
			var width = PixelsToDips(pixels.Width);
			var height = PixelsToDips(pixels.Height);

			return RectangleD(x, y, width, height);
		}

		/// <inheritdoc/>
		public RectangleD InchesToDips(RectangleD inches)
		{
			var x = InchesToDips(inches.X);
			var y = InchesToDips(inches.Y);
			var width = InchesToDips(inches.Width);
			var height = InchesToDips(inches.Height);

			return RectangleD(x, y, width, height);
		}

		/// <inheritdoc/>
		public RectangleD DipsToInches(RectangleD dips)
		{
			var x = DipsToInches(dips.X);
			var y = DipsToInches(dips.Y);
			var width = DipsToInches(dips.Width);
			var height = DipsToInches(dips.Height);

			return RectangleD(x, y, width, height);
		}

		/// <inheritdoc/>
		public Vector2 InchesToPixels(Vector2 inches)
		{
			var x = (float)InchesToPixels(inches.X);
			var y = (float)InchesToPixels(inches.Y);

			return Vector2(x, y);
		}

		/// <inheritdoc/>
		public Vector2 PixelsToInches(Vector2 pixels)
		{
			var x = (float)PixelsToInches(pixels.X);
			var y = (float)PixelsToInches(pixels.Y);

			return Vector2(x, y);
		}

		/// <inheritdoc/>
		public Vector2 DipsToPixels(Vector2 dips)
		{
			var x = (float)DipsToPixels(dips.X);
			var y = (float)DipsToPixels(dips.Y);

			return Vector2(x, y);
		}

		/// <inheritdoc/>
		public Vector2 PixelsToDips(Vector2 pixels)
		{
			var x = (float)PixelsToDips(pixels.X);
			var y = (float)PixelsToDips(pixels.Y);

			return Vector2(x, y);
		}

		/// <inheritdoc/>
		public Vector2 InchesToDips(Vector2 inches)
		{
			var x = (float)InchesToDips(inches.X);
			var y = (float)InchesToDips(inches.Y);

			return Vector2(x, y);
		}

		/// <inheritdoc/>
		public Vector2 DipsToInches(Vector2 dips)
		{
			var x = (float)DipsToInches(dips.X);
			var y = (float)DipsToInches(dips.Y);

			return Vector2(x, y);
		}

		/// <summary>
		/// Updates the display's state.
		/// </summary>
		/// <param name="time">Time elapsed since the last call to <see cref="Context.Update(Time)"/>.</param>
		public void Update(Time time)
		{
		}

		/// <inheritdoc/>
		public int32 Index
		{
			get { return displayIndex; }
		}

		/// <inheritdoc/>
		public String Name
		{
			get
			{
				return name;
			}
		}

		/// <inheritdoc/>
		public Rectangle Bounds
		{
			get
			{
				SDL_Rect bounds = default;
				SDL_GetDisplayBounds(displayIndex, &bounds);

				return Rectangle(bounds.x, bounds.y, bounds.w, bounds.h);
			}
		}

		/// <inheritdoc/>
		public ScreenRotation Rotation
		{
			get
			{
				return screenRotationService.ScreenRotation;
			}
		}

		/// <inheritdoc/>
		public float DeviceScale
		{
			get
			{
				return screenDensityService.DeviceScale;
			}
		}

		/// <inheritdoc/>
		public float DensityScale
		{
			get
			{
				return screenDensityService.DensityScale;
			}
		}

		/// <inheritdoc/>
		public float DpiX
		{
			get
			{
				return screenDensityService.DensityX;
			}
		}

		/// <inheritdoc/>
		public float DpiY
		{
			get
			{
				return screenDensityService.DensityY;
			}
		}

		/// <inheritdoc/>
		public ScreenDensityBucket DensityBucket
		{
			get
			{
				return screenDensityService.DensityBucket;
			}
		}

		/// <inheritdoc/>
		public DisplayMode DesktopDisplayMode
		{
			get
			{
				return desktopDisplayMode;
			}
		}

		/// <summary>
		/// Instructs the display to re-query its density information.
		/// </summary>
		internal void RefreshDensityInformation()
		{
			//var oldDensityBucket = screenDensityService.DensityBucket;
			//var oldDensityScale = screenDensityService.DensityScale;
			//var oldDensityX = screenDensityService.DensityX;
			//var oldDensityY = screenDensityService.DensityY;
			//var oldDeviceScale = screenDensityService.DeviceScale;

			if (screenDensityService.Refresh())
			{
				// todo: Invoke a screen density changed event
			}
		}

		/// <summary>
		/// Creates a DisplayMode object from the specified SDL2 display mode.
		/// </summary>
		private DisplayMode CreateDisplayModeFromSDL(SDL_DisplayMode mode)
		{
			int32 bpp = 0;
			uint32 Rmask, Gmask, Bmask, Amask;
			SDL_PixelFormatEnumToMasks((uint32)mode.format, &bpp, &Rmask, &Gmask, &Bmask, &Amask);

			return DisplayMode(mode.w, mode.h, bpp, mode.refresh_rate, Index);
		}

		/// <summary>
		/// Creates a DisplayMode object from the specified SDL2 display mode.
		/// </summary>
		private DisplayMode CreateDisplayModeFromSDL(int32 displayIndex, int32 modeIndex)
		{
			SDL_DisplayMode mode = default;
			SDL_GetDisplayMode(displayIndex, modeIndex, &mode);

			return CreateDisplayModeFromSDL(mode);
		}

		// SDL2 display info.
		private readonly SDL2PlatformBackend mBackend;
		private readonly int32 displayIndex;
		private readonly String name;
		private readonly List<DisplayMode> displayModes;
		private readonly DisplayMode desktopDisplayMode;

		// Services.
		private readonly ScreenRotationService screenRotationService;
		private readonly ScreenDensityService screenDensityService;
	}
}
