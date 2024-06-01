using System;
using Sedulous.Platform.Input;
using Sedulous.Foundation.Utilities;
using Sedulous.Foundation;
using System.IO;
using SDL2Native;
using Sedulous.Platform;

using internal Sedulous.Foundation;
using internal Sedulous.SDL2.Input;
using static SDL2Native.SDL2Native;

namespace Sedulous.SDL2.Input
{
	/// <summary>
	/// Represents the SDL2 implementation of the Input subsystem.
	/// </summary>
	public sealed class SDL2InputSystem : InputSystem
	{
		/// <summary>
		/// Initializes a new instance of the SDL2Input class.
		/// </summary>
		/// <param name="backend">The backend.</param>
		public this(SDL2PlatformBackend backend)
		{
			mBackend = backend;
			this.keyboard = new SDL2KeyboardDevice(this);
			this.mouse = new SDL2MouseDevice(this);
			this.gamePadInfo = new GamePadDeviceInfo(this);
			this.gamePadInfo.GamePadConnected.Subscribe(new => OnGamePadConnected);
			this.gamePadInfo.GamePadDisconnected.Subscribe(new => OnGamePadDisconnected);
			this.touchInfo = new TouchDeviceInfo(this);

			LoadGameControllerMappingDatabase();
		}


		public ~this()
		{
			delete keyboard;
			delete mouse;
			delete gamePadInfo;
			delete touchInfo;
		}

		/// <inheritdoc/>
		internal bool HandleEvent(SDL_Event ev)
		{
			if (this.mouse.HandleEvent(ev))
				return true;

			if (this.keyboard.HandleEvent(ev))
				return true;

			if (this.gamePadInfo.HandleEvent(ev))
				return true;

			if (this.touchInfo.HandleEvent(ev))
				return true;

			return false;
		}

		/// <summary>
		/// Resets the device's state in preparation for the next frame.
		/// </summary>
		public void ResetDeviceStates()
		{
			this.keyboard.ResetDeviceState();
			this.mouse.ResetDeviceState();
			this.gamePadInfo.ResetDeviceStates();
			this.touchInfo.ResetDeviceStates();
		}

		/// <inheritdoc/>
		public void Update(Time time)
		{
			this.keyboard.Update(time);
			this.mouse.Update(time);
			this.gamePadInfo.Update(time);
			this.touchInfo.Update(time);
		}

		/// <inheritdoc/>
		public override bool IsKeyboardSupported()
		{
			return true;
		}

		/// <inheritdoc/>
		public override bool IsKeyboardRegistered()
		{
			return keyboard.IsRegistered;
		}

		/// <inheritdoc/>
		public override KeyboardDevice GetKeyboard()
		{
			return keyboard;
		}

		/// <inheritdoc/>
		public override bool IsMouseSupported()
		{
			return true;
		}

		/// <inheritdoc/>
		public override bool IsMouseRegistered()
		{
			return mouse.IsRegistered;
		}

		/// <inheritdoc/>
		public override MouseDevice GetMouse()
		{
			return mouse;
		}

		/// <inheritdoc/>
		public override int32 GetGamePadCount()
		{
			return gamePadInfo.Count;
		}

		/// <inheritdoc/>
		public override bool IsGamePadSupported()
		{
			return true;
		}

		/// <inheritdoc/>
		public override bool IsGamePadConnected()
		{
			return gamePadInfo.Count > 0;
		}

		/// <inheritdoc/>
		public override bool IsGamePadConnected(int32 playerIndex)
		{
			Contract.EnsureRange(playerIndex >= 0, nameof(playerIndex));

			return gamePadInfo.GetGamePadForPlayer(playerIndex) != null;
		}

		/// <inheritdoc/>
		public override bool IsGamePadRegistered()
		{
			for (int32 i = 0; i < gamePadInfo.Count; i++)
			{
				if (gamePadInfo.GetGamePadForPlayer(i)?.IsRegistered ?? false)
					return true;
			}

			return false;
		}

		/// <inheritdoc/>
		public override bool IsGamePadRegistered(int32 playerIndex)
		{
			Contract.EnsureRange(playerIndex >= 0, nameof(playerIndex));

			return gamePadInfo.GetGamePadForPlayer(playerIndex)?.IsRegistered ?? false;
		}

		/// <inheritdoc/>
		public override GamePadDevice GetGamePadForPlayer(int32 playerIndex)
		{
			return gamePadInfo.GetGamePadForPlayer(playerIndex);
		}

		/// <inheritdoc/>
		public override GamePadDevice GetFirstConnectedGamePad()
		{
			return gamePadInfo.GetFirstConnectedGamePad();
		}

		/// <inheritdoc/>
		public override GamePadDevice GetFirstRegisteredGamePad()
		{
			return gamePadInfo.GetFirstRegisteredGamePad();
		}

		/// <inheritdoc/>
		public override GamePadDevice GetPrimaryGamePad()
		{
			return primaryGamePad;
		}

		/// <inheritdoc/>
		public override bool IsTouchSupported()
		{
			return touchInfo.Count > 0;
		}

		/// <inheritdoc/>
		public override bool IsTouchDeviceConnected()
		{
			return touchInfo.Count > 0;
		}

		/// <inheritdoc/>
		public override bool IsTouchDeviceConnected(int32 index)
		{
			Contract.EnsureRange(index >= 0, nameof(index));

			return touchInfo.Count > index;
		}

		/// <inheritdoc/>
		public override bool IsTouchDeviceRegistered()
		{
			for (int32 i = 0; i < touchInfo.Count; i++)
			{
				if (touchInfo.GetTouchDeviceByIndex(i).IsRegistered)
					return true;
			}

			return false;
		}

		/// <inheritdoc/>
		public override bool IsTouchDeviceRegistered(int32 index)
		{
			Contract.EnsureRange(index >= 0, nameof(index));

			return touchInfo.GetTouchDeviceByIndex(index).IsRegistered;
		}

		/// <inheritdoc/>
		public override TouchDevice GetTouchDevice(int32 index)
		{
			Contract.EnsureRange(index >= 0, nameof(index));

			return index >= touchInfo.Count ? null : touchInfo.GetTouchDeviceByIndex(index);
		}

		/// <inheritdoc/>
		public override TouchDevice GetFirstConnectedTouchDevice()
		{
			return touchInfo.Count > 0 ? touchInfo.GetTouchDeviceByIndex(0) : null;
		}

		/// <inheritdoc/>
		public override TouchDevice GetFirstRegisteredTouchDevice()
		{
			for (int32 i = 0; i < touchInfo.Count; i++)
			{
				var device = touchInfo.GetTouchDeviceByIndex(i);
				if (device.IsRegistered)
					return device;
			}

			return null;
		}

		/// <inheritdoc/>
		public override TouchDevice GetPrimaryTouchDevice()
		{
			return primaryTouchDevice;
		}

		public override IPlatformBackend Backend => mBackend;

		/// <inheritdoc/>
		public override bool EmulateMouseWithTouchInput { get; set; } = true;

		/// <inheritdoc/>
		public override bool IsMouseCursorAvailable => mouse.IsRegistered || (EmulateMouseWithTouchInput && IsTouchDeviceRegistered());

		/// <inheritdoc/>
		public readonly override EventAccessor<KeyboardRegistrationEventHandler> KeyboardRegistered { get; } = new .() ~ delete _;

		/// <inheritdoc/>
		public readonly override EventAccessor<MouseRegistrationEventHandler> MouseRegistered { get; } = new .() ~ delete _;

		/// <inheritdoc/>
		public readonly override EventAccessor<GamePadConnectionEventHandler> GamePadConnected { get; } = new .() ~ delete _;

		/// <inheritdoc/>
		public readonly override EventAccessor<GamePadConnectionEventHandler> GamePadDisconnected { get; } = new .() ~ delete _;

		/// <inheritdoc/>
		public readonly override EventAccessor<GamePadRegistrationEventHandler> GamePadRegistered { get; } = new .() ~ delete _;

		/// <inheritdoc/>
		public readonly override EventAccessor<TouchDeviceRegistrationEventHandler> TouchDeviceRegistered { get; } = new .() ~ delete _;

		/// <summary>
		/// Registers the specified device as having received user input.
		/// </summary>
		/// <param name="device">The device to register.</param>
		/// <returns><see langword="true"/> if the device was registered; otherwise, <see langword="false"/>.</returns>
		internal bool RegisterKeyboardDevice(SDL2KeyboardDevice device)
		{
			if (device.IsRegistered)
				return false;

			KeyboardRegistered?.Invoke(device);
			return true;
		}

		/// <summary>
		/// Registers the specified device as having received user input.
		/// </summary>
		/// <param name="device">The device to register.</param>
		/// <returns><see langword="true"/> if the device was registered; otherwise, <see langword="false"/>.</returns>
		internal bool RegisterMouseDevice(SDL2MouseDevice device)
		{
			if (device.IsRegistered)
				return false;

			MouseRegistered?.Invoke(device);
			return true;
		}

		/// <summary>
		/// Registers the specified device as having received user input.
		/// </summary>
		/// <param name="device">The device to register.</param>
		/// <returns><see langword="true"/> if the device was registered; otherwise, <see langword="false"/>.</returns>
		internal bool RegisterGamePadDevice(SDL2GamePadDevice device)
		{
			if (primaryGamePad == null)
				primaryGamePad = device;

			if (device.IsRegistered)
				return false;

			GamePadRegistered?.Invoke(device, device.PlayerIndex);
			return true;
		}

		/// <summary>
		/// Registers the specified device as having received user input.
		/// </summary>
		/// <param name="device">The device to register.</param>
		/// <returns><see langword="true"/> if the device was registered; otherwise, <see langword="false"/>.</returns>
		internal bool RegisterTouchDevice(SDL2TouchDevice device)
		{
			if (primaryTouchDevice == null)
				primaryTouchDevice = device;

			if (device.IsRegistered)
				return false;

			TouchDeviceRegistered?.Invoke(device);
			return true;
		}

		/// <summary>
		/// Attempts to load gamecontrollerdb.txt, if it is located in the application's root directory. 
		/// </summary>
		private void LoadGameControllerMappingDatabase()
		{
			const String DatabasePath = "gamecontrollerdb.txt";

			if (File.Exists(DatabasePath))
			{
				var data = File.ReadAll(DatabasePath, .. scope .());

				var rw = SDL_RWFromMem(data.Ptr, (.)data.Count);
				if (SDL_GameControllerAddMappingsFromRW(rw, 0) < 0)
					Runtime.SDL2Error();
			}
		}

		/// <summary>
		/// Raises the <see cref="GamePadConnected"/> event.
		/// </summary>
		/// <param name="device">The device that was connected.</param>
		/// <param name="playerIndex">The player index associated with the game pad.</param>
		private void OnGamePadConnected(GamePadDevice device, int32 playerIndex)
		{
			GamePadConnected?.Invoke(device, playerIndex);
		}

		/// <summary>
		/// Raises the <see cref="GamePadDisconnected"/> event.
		/// </summary>
		/// <param name="device">The device that was disconnected.</param>
		/// <param name="playerIndex">The player index associated with the game pad.</param>
		private void OnGamePadDisconnected(GamePadDevice device, int32 playerIndex)
		{
			if (primaryGamePad == device)
				primaryGamePad = null;

			GamePadDisconnected?.Invoke(device, playerIndex);
		}

		// Input devices.
		private readonly SDL2PlatformBackend mBackend;
		private SDL2KeyboardDevice keyboard;
		private SDL2MouseDevice mouse;
		private GamePadDeviceInfo gamePadInfo;
		private SDL2GamePadDevice primaryGamePad;
		private TouchDeviceInfo touchInfo;
		private SDL2TouchDevice primaryTouchDevice;
	}
}
