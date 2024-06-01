using System;
using System.IO;
using Sedulous.Platform.Input;
using SDL2Native;
using Sedulous.Foundation.Utilities;
using Sedulous.Platform;
using Sedulous.Foundation;
using Sedulous.Foundation.Mathematics;
using System.Collections;
using static SDL2Native.SDL2Native;
using internal Sedulous.SDL2.Input;

namespace Sedulous.SDL2.Input
{
    /// <summary>
    /// Represents the SDL2 implementation of the <see cref="TouchDevice"/> class.
    /// </summary>
    public sealed class SDL2TouchDevice : TouchDevice
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SDL2TouchDevice"/> class.
        /// </summary>
        /// <param name="inputSystem">The InputSystem.</param>
        /// <param name="index">The index of the SDL2 touch device represented by this object.</param>
        public this(SDL2InputSystem inputSystem, int32 index)
            : base(inputSystem)
        {
            // HACK: Working around an Android emulator glitch here -- it will
            // return a touch ID of 0 even after saying that the device exists,
            // and yet not produce any kind of SDL error... I hate emulators.            
            var id = SDL_GetTouchDevice(index);
            if (id == 0 && SDL_GetError() != null)
                Runtime.SDL2Error();

            this.sdlTouchID = id;
        }

        /// <inheritdoc/>
        internal bool HandleEvent(SDL_Event evt)
        {
            switch (evt.type)
            {
                case .SDL_FINGERDOWN:
                    if (evt.tfinger.touchId == sdlTouchID)
                    {
                        if (!isRegistered)
                            Register();

                        BeginTouch(evt);
                    }
                    return true;

                case .SDL_FINGERUP:
                    if (evt.tfinger.touchId == sdlTouchID)
                    {
                        if (!isRegistered)
                            Register();

                        EndTouch(evt);
                    }
                    return true;

                case .SDL_FINGERMOTION:
                    if (evt.tfinger.touchId == sdlTouchID)
                    {
                        if (!isRegistered)
                            Register();

                        UpdateTouch(evt);
                    }
                    return true;

                case .SDL_MULTIGESTURE:
                    if (evt.mgesture.touchId == sdlTouchID)
                    {
                        if (!isRegistered)
                            Register();

                        OnMultiGesture(evt.mgesture.x, evt.mgesture.y, 
                            evt.mgesture.dTheta, evt.mgesture.dDist, evt.mgesture.numFingers);
                    }
                    return true;

                case .SDL_DOLLARRECORD:
                    if (evt.dgesture.touchId == sdlTouchID)
                    {
                        if (!isRegistered)
                            Register();

                        isRecordingDollarGesture = false;

                        /*if (dollarGestureTaskCompletionSource != null)
                        {
                            dollarGestureTaskCompletionSource.SetResult(evt.dgesture.gestureId);
                            dollarGestureTaskCompletionSource = null;
                        }*/

                        OnDollarGestureRecorded(evt.dgesture.gestureId);
                    }
                    return true;

                case .SDL_DOLLARGESTURE:
                    if (evt.dgesture.touchId == sdlTouchID)
                    {
                        if (!isRegistered)
                            Register();

                        OnDollarGesture(evt.dgesture.gestureId, 
                            evt.dgesture.x, evt.dgesture.y, evt.dgesture.error, (int32)evt.dgesture.numFingers);
                    }
                    return true;

			default: return false;
            }
        }
        
        /// <summary>
        /// Resets the device's state in preparation for the next frame.
        /// </summary>
        public void ResetDeviceState()
        {
            taps.Clear();
        }

        /// <inheritdoc/>
        public override void Update(Time time)
        {
            timestamp = time.TotalTime.Ticks;

            var window = BoundWindow;
            if (window == null)
                return;

            var longPressDelaySpan = TimeSpan.FromMilliseconds(LongPressDelay);
            var longPressDistanceDips = LongPressMaximumDistance;
            var longPressDistancePixs = window.Display.DipsToPixels(longPressDistanceDips);

            for (int i = 0; i < touches.Count; i++)
            {
                var touchInfo = touches[i];
                if (touchInfo.IsLongPress)
                    continue;
                
                var touchDistancePixs = touchInfo.Distance;
                var touchDistanceDips = window.Display.PixelsToDips(touchDistancePixs);

                var touchLifetime = TimeSpan(timestamp - touchInfo.Timestamp);
                if (touchLifetime > longPressDelaySpan && touchDistanceDips <= longPressDistancePixs)
                {
                    SetTouchIsLongPress(ref touchInfo, true);

                    touches[i] = touchInfo;

                    OnLongPress(touchInfo.TouchID, touchInfo.FingerID,
                        touchInfo.CurrentX, touchInfo.CurrentY, touchInfo.Pressure);
                }
            }
        }

        /// <inheritdoc/>
        public override void BindToWindow(IWindow window)
        {
            boundWindow = window;
        }

        /// <inheritdoc/>
        public override Point2F NormalizeCoordinates(Point2 coordinates)
        {
            var window = BoundWindow;
            if (window == null)
                Runtime.InvalidOperationError("TouchDeviceNotBoundToWindow");

            return Point2F(
                coordinates.X / (float)window.ClientSize.Width,
                coordinates.Y / (float)window.ClientSize.Height);
        }

        /// <inheritdoc/>
        public override Point2F NormalizeCoordinates(int32 x, int32 y)
        {
            var window = BoundWindow;
            if (window == null)
                Runtime.InvalidOperationError("TouchDeviceNotBoundToWindow");

            return Point2F(
                x / (float)window.ClientSize.Width,
                y / (float)window.ClientSize.Height);
        }

        /// <inheritdoc/>
        public override Point2 DenormalizeCoordinates(Point2F coordinates)
        {
            var window = BoundWindow;
            if (window == null)
                Runtime.InvalidOperationError("TouchDeviceNotBoundToWindow");

            return Point2(
                (int32)(coordinates.X * window.ClientSize.Width),
                (int32)(coordinates.Y * window.ClientSize.Height));
        }

        /// <inheritdoc/>
        public override Point2 DenormalizeCoordinates(float x, float y)
        {
            var window = BoundWindow;
            if (window == null)
                Runtime.InvalidOperationError("TouchDeviceNotBoundToWindow");

            return Point2(
                (int32)(x * window.ClientSize.Width),
                (int32)(y * window.ClientSize.Height));
        }

        /// <inheritdoc/>
        public override bool IsActive(int64 touchID)
        {
            for (int i = 0; i < touches.Count; i++)
            {
                if (touches[i].TouchID == touchID)
                    return true;
            }
            return false;
        }

        /// <inheritdoc/>
        public override bool TryGetTouch(int64 touchID, out TouchInfo touchInfo)
        {
            for (var touch in touches)
            {
                if (touch.TouchID == touchID)
                {
                    touchInfo = touch;
                    return true;
                }
            }

            touchInfo = default(TouchInfo);
            return false;
        }

        /// <inheritdoc/>
        public override TouchInfo GetTouch(int64 touchID)
        {
            for (var touch in touches)
            {
                if (touch.TouchID == touchID)
                    return touch;
            }

            Runtime.ArgumentError(nameof(touchID));
        }

        /// <inheritdoc/>
        public override TouchInfo GetTouchByIndex(int32 index)
        {
            return touches[index];
        }

        /// <inheritdoc/>
        public override bool WasTapped()
        {
            return taps.Count > 0;
        }

        /// <inheritdoc/>
        public override bool WasTappedWithin(RectangleF area)
        {
            for (var tap in taps)
            {
                if (area.Contains(tap.X, tap.Y))
                    return true;
            }

            return false;
        }

        /// <inheritdoc/>
        public override bool IsTouchWithin(RectangleF area)
        {
            for (var touch in touches)
            {
                if (area.Contains(touch.CurrentX, touch.CurrentY))
                    return true;
            }

            return false;
        }

        /// <inheritdoc/>
        public override bool IsTouchWithin(int64 touchID, RectangleF area)
        {
            for (var touch in touches)
            {
                if (touch.TouchID == touchID)
                    return area.Contains(touch.CurrentX, touch.CurrentY);
            }

            return false;
        }

        /// <inheritdoc/>
        public override bool IsFirstTouchInGesture(int64 touchID)
        {
            if (touches.Count == 0)
                return false;
            
            var first = touches[0];
            return first.TouchID == touchID && first.TouchIndex == 0;
        }

        /// <inheritdoc/>
        public override int32 GetTouchIndex(int64 touchID)
        {
            TouchInfo touchInfo;
            if (!TryGetTouch(touchID, out touchInfo))
                return -1;

            return touchInfo.TouchIndex;
        }

        /*/// <inheritdoc/>
        public override Task<int64> RecordDollarGestureAsync()
        {
            if (dollarGestureTaskCompletionSource != null)
                return dollarGestureTaskCompletionSource.Task;

            dollarGestureTaskCompletionSource = new TaskCompletionSource<int64>();

            if (!IsRecordingDollarGesture)
            {
                if (SDL_RecordGesture(sdlTouchID) == 0)
                    Runtime.SDL2Error();

                isRecordingDollarGesture = true;
            }

            return dollarGestureTaskCompletionSource.Task;
        }*/

        /// <inheritdoc/>
        public override bool RecordDollarGesture()
        {
            if (IsRecordingDollarGesture)
                return false;

            if (SDL_RecordGesture(sdlTouchID) == 0)
                Runtime.SDL2Error();

            isRecordingDollarGesture = true;
            return true;
        }

        /// <inheritdoc/>
        public override void LoadDollarGestures(Stream stream)
        {
            Contract.Require(stream, nameof(stream));

			var memory = scope List<uint8>(stream.Length);

			if(stream.TryRead(memory) case .Ok)
			{
				SDL_RWops* rwops = SDL_RWFromMem(memory.Ptr, (int32)memory.Count);

                if (SDL_LoadDollarTemplates(sdlTouchID, rwops) == 0)
                    Runtime.SDL2Error();
			}
        }

        /// <inheritdoc/>
        public override void SaveDollarGestures(Stream stream)
        {
            Contract.Require(stream, nameof(stream));
			
			var memory = scope List<uint8>(stream.Length);

			if(stream.TryRead(memory) case .Ok)
			{
				SDL_RWops* rwops = SDL_RWFromMem(memory.Ptr, (int32)memory.Count);

			    if (SDL_SaveAllDollarTemplates(rwops) == 0)
			        Runtime.SDL2Error();
			}
        }

        /// <inheritdoc/>
        public override IWindow BoundWindow => boundWindow != null ? boundWindow : InputSystem.Backend.Windows.GetPrimary();

        /// <inheritdoc/>
        public override bool IsRecordingDollarGesture => isRecordingDollarGesture;

        /// <inheritdoc/>
        public override int32 TouchCount => (int32)touches.Count;

        /// <inheritdoc/>
        public override int32 TapCount => (int32)taps.Count;

        /// <inheritdoc/>
        public override bool IsRegistered => isRegistered;

        /// <summary>
        /// Begins a new touch input.
        /// </summary>
        private void BeginTouch(in SDL_Event evt)
        {
            var touchID = nextTouchID++;
            var touchIndex = (int32)(touches.Count == 0 ? 0 : touches[touches.Count - 1].TouchIndex + 1);
            var touchInfo = TouchInfo(timestamp, touchID, touchIndex, evt.tfinger.fingerId, 
                evt.tfinger.x, evt.tfinger.y, evt.tfinger.x, evt.tfinger.y, evt.tfinger.pressure, false);

            touches.Add(touchInfo);

            OnTouchDown(touchID, touchInfo.FingerID, touchInfo.CurrentX, touchInfo.CurrentY, touchInfo.Pressure);        
        }

        /// <summary>
        /// Ends an active touch input.
        /// </summary>
        private void EndTouch(in SDL_Event evt)
        {
            for (int i = 0; i < touches.Count; i++)
            {
                var touch = touches[i];
                if (touch.FingerID == evt.tfinger.fingerId)
                {
                    if (timestamp - touch.Timestamp <= TimeSpan.FromMilliseconds(TapDelay).Value.Ticks)
                    {
                        var window = BoundWindow;
                        if (window != null)
                        {
                            var tapDistanceDips = TapMaximumDistance;
                            var tapDistancePixs = window.Display.DipsToPixels(tapDistanceDips);
                            if (tapDistancePixs >= touch.Distance)
                            {
                                EndTap(touch.TouchID, touch.FingerID, touch.OriginX, touch.OriginY);
                            }
                        }
                    }

                    OnTouchUp(touch.TouchID, touch.FingerID);

                    touches.RemoveAt(i);

                    break;
                }
            }
        }

        /// <summary>
        /// Ends a tap.
        /// </summary>
        private void EndTap(int64 touchID, int64 fingerID, float x, float y)
        {
            var tapInfo = TouchTapInfo(touchID, fingerID, x, y);
            taps.Add(tapInfo);

            OnTap(touchID, fingerID, x, y);
        }

        /// <summary>
        /// Updates an active touch input.
        /// </summary>
        private void UpdateTouch(in SDL_Event evt)
        {
            for (int i = 0; i < touches.Count; i++)
            {
                var touch = touches[i];
                if (touch.FingerID == evt.tfinger.fingerId)
                {
                    float dx, dy;
                    SetTouchPosition(ref touch, evt.tfinger.x, evt.tfinger.y, out dx, out dy, evt.tfinger.pressure);

                    touches[i] = touch;

                    OnTouchMotion(touch.TouchID, touch.FingerID, 
                        evt.tfinger.x, evt.tfinger.y, dx, dy, evt.tfinger.pressure);

                    break;
                }
            }
        }

        /// <summary>
        /// Flags the device as registered.
        /// </summary>
        private void Register()
        {
            var input = (SDL2InputSystem)InputSystem;
            if (input.RegisterTouchDevice(this))
                isRegistered = true;
        }

        // State values.
        private readonly List<TouchInfo> touches = new List<TouchInfo>(5) ~ delete _;
        private readonly List<TouchTapInfo> taps = new List<TouchTapInfo>(5) ~ delete _;
        private readonly int64 sdlTouchID;
        private int64 nextTouchID = 1;
        private int64 timestamp;
        private bool isRegistered;
        //private TaskCompletionSource<int64> dollarGestureTaskCompletionSource;

        // Property values.
        private IWindow boundWindow;
        private bool isRecordingDollarGesture;
    }
}
