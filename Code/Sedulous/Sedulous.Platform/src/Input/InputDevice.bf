using Sedulous.Foundation.Utilities;

namespace Sedulous.Platform.Input
{
	/// <summary>
	/// Represents any input device.
	/// </summary>
	public abstract class InputDevice
	{
		public readonly InputSystem InputSystem { get; private set; }

		/// <summary>
		/// Initializes a new instance of the <see cref="InputDevice"/> class.
		/// </summary>
		/// <param name="inputSystem">The InputSystem.</param>
		internal this(InputSystem inputSystem)
		{
			InputSystem = inputSystem;
		}

		/// <summary>
		/// Updates the device's state.
		/// </summary>
		/// <param name="time">Time elapsed since the last call to <see cref="Context.Update(Time)"/>.</param>
		public abstract void Update(Time time);

		/// <summary>
		/// Gets a value indicating whether the device has been registered with the context
		/// as a result of receiving user input.
		/// </summary>
		public abstract bool IsRegistered { get; }
	}
}
