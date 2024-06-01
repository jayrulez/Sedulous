using System;
using SDL2Native;
using Sedulous.Foundation.Utilities;
using Sedulous.Foundation;
using Sedulous.Platform.Input;
using static SDL2Native.SDL2Native;

using internal Sedulous.Foundation;
using internal Sedulous.SDL2.Input;

namespace Sedulous.SDL2.Input
{
    /// <summary>
    /// Manages the context's connected game pad devices.
    /// </summary>
    internal sealed class GamePadDeviceInfo
    {
		private readonly SDL2InputSystem mInputSystem;

        /// <summary>
        /// Initializes a new instance of the <see cref="GamePadDeviceInfo"/> class.
        /// </summary>
        /// <param name="inputSystem">The InputSystem.</param>
        public this(SDL2InputSystem inputSystem)
        {
			mInputSystem = inputSystem;

            this.devicesByPlayer = new SDL2GamePadDevice[SDL_NumJoysticks()];

            for (int32 i = 0; i < this.devicesByPlayer.Count; i++)
            {
                if (SDL_IsGameController(i))
                {
                    OnControllerDeviceAdded(i);
                }
            }
        }

		public ~this()
        {
                for (var device in devicesByPlayer)
                {
                    if (device != null)
                    {
                        delete device;
                    }
                }
			delete devicesByPlayer;
        }

        /// <inheritdoc/>
        internal bool HandleEvent(SDL_Event evt)
        {
            switch (evt.type)
            {
                case .SDL_CONTROLLERDEVICEADDED:
                    OnControllerDeviceAdded(evt.cdevice.which);
                    return true;

                case .SDL_CONTROLLERDEVICEREMOVED:
                    OnControllerDeviceRemoved(evt.cdevice.which);
                    return true;

			default: return false;
            }
        }

        /// <summary>
        /// Resets the states of the connected devices in preparation for the next frame.
        /// </summary>
        public void ResetDeviceStates()
        {
            for (var device in devicesByPlayer)
            {
                if (device != null)
                {
                    device.ResetDeviceState();
                }
            }
        }

        /// <summary>
        /// Updates the state of the attached game pad devices.
        /// </summary>
        /// <param name="time">Time elapsed since the last call to <see cref="Context.Update(Time)"/>.</param>
        public void Update(Time time)
        {
            for (var device in devicesByPlayer)
            {
                if (device != null)
                {
                    device.Update(time);
                }
            }
        }

        /// <summary>
        /// Gets the game pad that belongs to the specified player.
        /// </summary>
        /// <param name="playerIndex">The index of the player for which to retrieve a game pad.</param>
        /// <returns>The game pad that belongs to the specified player, or <see langword="null"/> if no such game pad exists.</returns>
        public SDL2GamePadDevice GetGamePadForPlayer(int32 playerIndex)
        {
            Contract.EnsureRange(playerIndex >= 0, nameof(playerIndex));

            return (playerIndex >= devicesByPlayer.Count) ? null : devicesByPlayer[playerIndex];
        }

        /// <summary>
        /// Gets the first connected game pad device.
        /// </summary>
        /// <returns>The first connected game pad device, or <see langword="null"/> if no game pads are connected.</returns>
        public SDL2GamePadDevice GetFirstConnectedGamePad()
        {
            for (int i = 0; i < devicesByPlayer.Count; i++)
            {
                if (devicesByPlayer[i] != null)
                {
                    return devicesByPlayer[i];
                }
            }
            return null;
        }

        /// <summary>
        /// Gets the first registered game pad device.
        /// </summary>
        /// <returns>The first registered game pad device, or <see langword="null"/> if no game pads are registered.</returns>
        public SDL2GamePadDevice GetFirstRegisteredGamePad()
        {
            for (int i = 0; i < devicesByPlayer.Count; i++)
            {
                if (devicesByPlayer[i]?.IsRegistered ?? false)
                {
                    return devicesByPlayer[i];
                }
            }
            return null;
        }

        /// <summary>
        /// Gets the number of attached game pads.
        /// </summary>
        public int32 Count => count;

        /// <inheritdoc/>
        public readonly EventAccessor<GamePadConnectionEventHandler> GamePadConnected {get;} = new .() ~ delete _;

        /// <inheritdoc/>
        public readonly EventAccessor<GamePadConnectionEventHandler> GamePadDisconnected {get;} = new .() ~ delete _;

        /// <summary>
        /// Called when a controller device is added.
        /// </summary>
        /// <param name="joystickIndex">The index of the device to add.</param>
        private void OnControllerDeviceAdded(int32 joystickIndex)
        {
            var gamecontroller = SDL_GameControllerOpen(joystickIndex);
            var joystick       = SDL_GameControllerGetJoystick(gamecontroller);
            var joystickID     = SDL_JoystickInstanceID(joystick);

            for (int i = 0; i < devicesByPlayer.Count; i++)
            {
                if (devicesByPlayer[i] != null && devicesByPlayer[i].InstanceID == joystickID)
                {
                    return;
                }
            }

            var playerIndex = GetFirstAvailablePlayerIndex();
            var device = new SDL2GamePadDevice(mInputSystem, joystickIndex, playerIndex);

            devicesByPlayer[playerIndex] = device;
            count++;

            OnGamePadConnected(device, playerIndex);
        }

        /// <summary>
        /// Called when a controller device is removed.
        /// </summary>
        /// <param name="instanceID">The instance identifier of the device to remove.</param>
        private void OnControllerDeviceRemoved(int32 instanceID)
        {
            for (int32 i = 0; i < devicesByPlayer.Count; i++)
            {
                var device = devicesByPlayer[i];
                if (device != null && device.InstanceID == instanceID)
                {
                    OnGamePadDisconnected(device, i);

                    devicesByPlayer[i] = null;
                    count--;

                    return;
                }
            }
        }

        /// <summary>
        /// Raises the <see cref="GamePadConnected"/> event.
        /// </summary>
        /// <param name="device">The device that was connected.</param>
        /// <param name="playerIndex">The player index associated with the game pad.</param>
        private void OnGamePadConnected(GamePadDevice device, int32 playerIndex) =>
            GamePadConnected?.Invoke(device, playerIndex);

        /// <summary>
        /// Raises the <see cref="GamePadDisconnected"/> event.
        /// </summary>
        /// <param name="device">The device that was disconnected.</param>
        /// <param name="playerIndex">The player index associated with the game pad.</param>
        private void OnGamePadDisconnected(GamePadDevice device, int32 playerIndex) =>
            GamePadDisconnected?.Invoke(device, playerIndex);

        /// <summary>
        /// Gets the index of the first player which does not have an associated game pad.
        /// </summary>
        /// <returns>The index of the first player which does not have an associated game pad.</returns>
        private int32 GetFirstAvailablePlayerIndex()
        {
            for (int32 i = 0; i < devicesByPlayer.Count; i++)
            {
                if (devicesByPlayer[i] == null)
                {
                    return i;
                }
            }
        
            var devicesOld = devicesByPlayer;
            var devicesNew = new SDL2GamePadDevice[devicesOld.Count + 1];
            Array.Copy(devicesOld, devicesNew, devicesOld.Count);

            devicesByPlayer = devicesNew;

            return (int32)(devicesByPlayer.Count - 1);
        }

        // State values.
        private SDL2GamePadDevice[] devicesByPlayer;
        private int32 count;
    }
}
