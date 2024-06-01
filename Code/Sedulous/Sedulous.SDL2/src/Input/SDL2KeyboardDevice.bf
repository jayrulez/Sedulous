using System;
using System.Text;
using Sedulous.Platform.Input;
using SDL2Native;
using Sedulous.Foundation.Utilities;
using static SDL2Native.SDL2Native;
using internal Sedulous.SDL2.Input;

namespace Sedulous.SDL2.Input
{
    /// <summary>
    /// Represents the SDL2 implementation of the KeyboardDevice class.
    /// </summary>
    public sealed class SDL2KeyboardDevice : KeyboardDevice
    {
        /// <summary>
        /// Initializes a new instance of the SDL2KeyboardDevice class.
        /// </summary>
        /// <param name="inputSystem">The InputSystem.</param>
        public this(SDL2InputSystem inputSystem)
            : base(inputSystem)
        {
            int32 numkeys;
            SDL_GetKeyboardState(out numkeys);

            this.states = new InternalButtonState[numkeys];
        }

		public ~this()
		{
			delete states;
		}

        /// <inheritdoc/>
        internal bool HandleEvent(SDL_Event evt)
        {
            
                switch (evt.type)
                {
                    case .SDL_KEYDOWN:
                        {
                            if (!isRegistered)
                                Register();

                            OnKeyDown(evt.key);
                        }
                        return true;

                    case .SDL_KEYUP:
                        {
                            if (!isRegistered)
                                Register();

                            OnKeyUp(evt.key);
                        }
                        return true;

                    case .SDL_TEXTEDITING:
                        {
                            if (!isRegistered)
                                Register();

                            OnTextEditing(evt.edit);
                        }
                        return true;

                    case .SDL_TEXTINPUT:
                        {
                            if (isRegistered)
                                Register();

                            OnTextInput(evt.text);
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
            for (int i = 0; i < states.Count; i++)
            {
                states[i].Reset();
            }
        }

        /// <inheritdoc/>
        public override void Update(Time time)
        {

        }

        /// <inheritdoc/>
        public override void GetTextInput(String sb, bool @append = false)
        {
            if (!@append)
                sb.Length = 0;

            for (int i = 0; i < textInputLength; i++)
            {
                sb.Append(mText[i]);
            }
        }

        /// <inheritdoc/>
        public override bool IsButtonDown(Scancode button)
        {
            var scancode = (int)button;
            return states[scancode].Down;
        }

        /// <inheritdoc/>
        public override bool IsButtonUp(Scancode button)
        {
            var scancode = (int)button;
            return states[scancode].Up;
        }

        /// <inheritdoc/>
        public override bool IsButtonPressed(Scancode button, bool ignoreRepeats = true)
        {
            var scancode = (int)button;
            return states[scancode].Pressed || (!ignoreRepeats && states[scancode].Repeated);
        }

        /// <inheritdoc/>
        public override bool IsButtonReleased(Scancode button)
        {
            var scancode = (int)button;
            return states[scancode].Released;
        }

        /// <inheritdoc/>
        public override bool IsKeyDown(Key key)
        {
            var scancode = (int)SDL_GetScancodeFromKey((SDL_Keycode)key);
            return states[scancode].Down;
        }

        /// <inheritdoc/>
        public override bool IsKeyUp(Key key)
        {
            var scancode = (int)SDL_GetScancodeFromKey((SDL_Keycode)key);
            return states[scancode].Up;
        }

        /// <inheritdoc/>
        public override bool IsKeyPressed(Key key, bool ignoreRepeats = true)
        {
            var scancode = (int)SDL_GetScancodeFromKey((SDL_Keycode)key);
            return states[scancode].Pressed || (!ignoreRepeats && states[scancode].Repeated);
        }

        /// <inheritdoc/>
        public override bool IsKeyReleased(Key key)
        {
            var scancode = (int)SDL_GetScancodeFromKey((SDL_Keycode)key);
            return states[scancode].Released;
        }

        /// <inheritdoc/>
        public override ButtonState GetKeyState(Key key)
        {
            var state = IsKeyDown(key) ? ButtonState.Down : ButtonState.Up;

            if (IsKeyPressed(key))
                state |= ButtonState.Pressed;

            if (IsKeyReleased(key))
                state |= ButtonState.Released;

            return state;
        }

        /// <inheritdoc/>
        public override bool IsNumLockDown => (SDL_GetModState() & .KMOD_NUM) == .KMOD_NUM;

        /// <inheritdoc/>
        public override bool IsCapsLockDown => (SDL_GetModState() & .KMOD_CAPS) == .KMOD_CAPS;

        /// <inheritdoc/>
        public override bool IsRegistered => isRegistered;

        /// <summary>
        /// Handles SDL2's KEYDOWN event.
        /// </summary>
        private void OnKeyDown(in SDL_KeyboardEvent evt)
        {
            var window = InputSystem.Backend.Windows.GetByID((int32)evt.windowID);
            var mods   = evt.keysym.mod;
            var ctrl   = (mods & .KMOD_CTRL) != 0;
            var alt    = (mods & .KMOD_ALT) != 0;
            var shift  = (mods & .KMOD_SHIFT) != 0;
            var @repeat = evt.repeat > 0;

            states[(int)evt.keysym.scancode].OnDown(@repeat);

            if (!@repeat)
            {
                OnButtonPressed(window, (Scancode)evt.keysym.scancode);
            }
            OnKeyPressed(window, (Key)evt.keysym.keycode, ctrl, alt, shift, @repeat);
        }

        /// <summary>
        /// Handles SDL2's KEYUP event.
        /// </summary>
        private void OnKeyUp(in SDL_KeyboardEvent evt)
        {
            var window = InputSystem.Backend.Windows.GetByID((int32)evt.windowID);

            states[(int)evt.keysym.scancode].OnUp();

            OnButtonReleased(window, (Scancode)evt.keysym.scancode);
            OnKeyReleased(window, (Key)evt.keysym.keycode);
        }

        /// <summary>
        /// Handles SDL2's TEXTEDITING event.
        /// </summary>
        private void OnTextEditing(in SDL_TextEditingEvent evt)
        {
            var window = InputSystem.Backend.Windows.GetByID((int32)evt.windowID);
            if (GetText(evt.text))
                {
                    OnTextEditing(window);
                }
        }

        /// <summary>
        /// Handles SDL2's TEXTINPUT event.
        /// </summary>
        private void OnTextInput(in SDL_TextInputEvent evt)
        {
            var window = InputSystem.Backend.Windows.GetByID((int32)evt.windowID);
            if (GetText(evt.text))
                {
                    OnTextInput(window);
                }
        }

        /// <summary>
        /// Converts inputted text (which is in UTF-8 format) to UTF-16.
        /// </summary>
        /// <param name="input">A pointer to the inputted text.</param>
        /// <returns><see langword="true"/> if the input data was successfully converted; otherwise, <see langword="false"/>.</returns>
        private bool GetText(in char8[SDL_TextInputEvent.TEXT_SIZE] input)
        {
			//mText.Clear();
			var input;
			String text = scope .(&input);
			if(text.Length == 0)
				return false;

			mText.Set(text);

			return true;
        }

        /// <summary>
        /// Flags the device as registered.
        /// </summary>
        private void Register()
        {
            var input = (SDL2InputSystem)InputSystem;
            if (input.RegisterKeyboardDevice(this))
                isRegistered = true;
        }

        // State values.
        private readonly InternalButtonState[] states;
        private readonly String mText = new .() ~ delete _;
        private int32 textInputLength;
        private bool isRegistered;
    }
}
