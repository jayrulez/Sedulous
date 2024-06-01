using System;
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
	/// Manages the context's connected touch devices.
	/// </summary>
	internal sealed class TouchDeviceInfo
	{
		/// <summary>
		/// Initializes a new instance of the <see cref="TouchDeviceInfo"/> class.
		/// </summary>
		/// <param name="inputSystem">The InputSystem.</param>
		public this(SDL2InputSystem inputSystem)
		{
			var count = SDL_GetNumTouchDevices();
			devices = new SDL2TouchDevice[count];

			for (int32 i = 0; i < count; i++)
			{
				devices[i] = new SDL2TouchDevice(inputSystem, i);
			}
		}

		public ~this()
		{
			for (var device in devices)
			{
				delete device;
			}
			delete devices;
		}

		/// <summary>
		/// Resets the states of the connected devices in preparation for the next frame.
		/// </summary>
		public void ResetDeviceStates()
		{
			for (var device in devices)
			{
				device.ResetDeviceState();
			}
		}

		/// <summary>
		/// Updates the states of the connected touch devices.
		/// </summary>
		/// <param name="time">Time elapsed since the last call to <see cref="Context.Update(Time)"/>.</param>
		public void Update(Time time)
		{
			for (var device in devices)
			{
				device.Update(time);
			}
		}

		/// <summary>
		/// Gets the touch device with the specified device index.
		/// </summary>
		/// <param name="index">The index of the device to retrieve.</param>
		/// <returns>The touch device with the specified device index, or <see langword="null"/> if no such device exists.</returns>
		public TouchDevice GetTouchDeviceByIndex(int32 index)
		{
			return devices[index];
		}

		/// <summary>
		/// Gets the number of available touch devices.
		/// </summary>
		public int32 Count
		{
			get { return (int32)devices.Count; }
		}

		// Connected touch devices.
		private SDL2TouchDevice[] devices;


		internal bool HandleEvent(SDL_Event evt)
		{
			for (int i = 0; i < devices.Count; i++)
			{
				if (devices[i].HandleEvent(evt))
					return true;
			}

			return false;
		}
	}
}
