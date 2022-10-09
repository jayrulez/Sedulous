using System;
using System.Reflection;
using System.Collections;

namespace Sedulous.Foundation.Mathematics
{
	/// <summary>
	/// Represents a custom interpolation function.
	/// </summary>
	/// <typeparam name="T">The type of value being interpolated.</typeparam>
	/// <param name="valueStart">The start value.</param>
	/// <param name="valueEnd">The end value.</param>
	/// <param name="fn">The easing function to apply.</param>
	/// <param name="t">A value between 0.0 and 1.0 indicating the current position in the tween.</param>
	/// <returns>A value which is interpolated from the specified start and end values.</returns>
	public delegate T Interpolator<T>(T valueStart, T valueEnd, EasingFunction fn, float t);

	/// <summary>
	/// Represents the registry of interpolation methods used by the framework tweening system.
	/// </summary>
	public sealed class TweeningInterpolationRegistry
	{
		/// <summary>
		/// Initializes a new instance of the <see cref="TweeningInterpolationRegistry"/> class.
		/// </summary>
		internal this()
		{
			// todo: Beef doesn't currently support reflection on generic methods
			// miRegisterNullable = GetType().GetMethod("RegisterNullable", BindingFlags.NonPublic | BindingFlags.Instance);
		}

		/// <summary>
		/// Registers a default interpolator for the specified type.
		/// </summary>
		/// <typeparam name="T">The type for which to register a default interpolator.</typeparam>
		public void RegisterDefault<T>()
		{
			var interpolator = default(Interpolator<T>);

			if (typeof(IInterpolatable<T>).IsAssignableFrom(typeof(T)))
			{
				// Invoke through interface
				interpolator = new (valueStart, valueEnd, fn, t) =>
					{
						return ((IInterpolatable<T>)(Object)valueStart).Interpolate(valueEnd, (fn ?? Easings.EaseInLinear)(t));
					};
			}
			else
			{
				// Invoke through pattern

				if (typeof(T).GetMethod("Interpolate", .Public | .NonPublic | .Instance) case .Ok(let interpolateMethod))
				{
					if (interpolateMethod.ParamCount == 2)
					{
						interpolator = new (valueStart, valueEnd, fn, t) =>
							{
								var result = interpolateMethod.Invoke(valueStart, valueEnd, fn, t);
								if(result case .Ok(let value)){
									return (T)value.GetBoxed();
								}

								return default;
							};
					}
				}
			}

			Register(interpolator);
		}

		/// <summary>
		/// Registers a custom interpolator function for the specified type.
		/// </summary>
		/// <typeparam name="T">The type of value for which to register a custom interpolator.</typeparam>
		/// <param name="interpolator">The custom interpolator function to register for the specified type.</param>
		public void Register<T>(Interpolator<T> interpolator)
		{
			mInterpolators[typeof(T)] = interpolator;

			if (typeof(T).IsValueType)
			{
				// todo: beef doesn't currently support reflection on generic methods
				// miRegisterNullable.Invoke(this, typeof(T), interpolator);

				// miRegisterNullable.MakeGenericMethod(typeof(T))
				//	.Invoke(this, new Object[] { interpolator });
			}
		}

		/// <summary>
		/// Unregisters any custom interpolation function for the specified type.
		/// </summary>
		/// <typeparam name="T">The type of value for which to unregister a custom interpolator.</typeparam>
		/// <returns><see langword="true"/> if the specified type had a function that was unregistered; otherwise, <see langword="false"/>.</returns>
		public bool Unregister<T>()
		{
			return mInterpolators.Remove(typeof(T));
		}

		/// <summary>
		/// Gets a value indicating whether the specified type has a custom interpolation function.
		/// </summary>
		/// <typeparam name="T">The type of value for which to determine whether a custom interpolator exists.</typeparam>
		/// <returns><see langword="true"/> if the specified type has a custom interpolation function; otherwise, <see langword="false"/>.</returns>
		public bool Contains<T>()
		{
			return mInterpolators.ContainsKey(typeof(T));
		}

		/// <summary>
		/// Attempts to retrieve the interpolator for the specified type.
		/// </summary>
		/// <typeparam name="T">The type of value for which to retrieve an interpolator.</typeparam>
		/// <param name="interpolator">The interpolator for the specified type, if one exists.</param>
		/// <returns><see langword="true"/> if an interpolator was registered for the specified type; otherwise, <see langword="false"/>.</returns>
		public bool TryGet<T>(out Interpolator<T> interpolator)
		{
			Object interpolatorObj;
			if (mInterpolators.TryGetValue(typeof(T), out interpolatorObj))
			{
				interpolator = (Interpolator<T>)interpolatorObj;
				return true;
			}
			else
			{
				RegisterDefault<T>();
				if (mInterpolators.TryGetValue(typeof(T), out interpolatorObj))
				{
					interpolator = (Interpolator<T>)interpolatorObj;
					return true;
				}
			}
			interpolator = null;
			return false;
		}

		/// <summary>
		/// Registers an interpolator for the nullable version of the specified type.
		/// </summary>
		/// <typeparam name="T">The type for which to register an interpolator.</typeparam>
		/// <param name="interpolator">The interpolator for the non-nullable type.</param>
		private void RegisterNullable<T>(Interpolator<T> interpolator) where T : struct
		{
			if (interpolator == null)
			{
				mInterpolators[typeof(T?)] = null;
			}
			else
			{
				Interpolator<T?> nullableInterpolator = new (valueStart, valueEnd, fn, t) =>
				{
					if (valueStart == null || valueEnd == null)
						return null;

					return interpolator(valueStart.GetValueOrDefault(), valueEnd.GetValueOrDefault(), fn, t);
				};
				mInterpolators[typeof(T?)] = nullableInterpolator;
			}
		}

		// State values.
		private readonly MethodInfo mRegisterNullableMethodInfo;
		private readonly Dictionary<Type, Object> mInterpolators =
			new Dictionary<Type, Object>() ~
			{
				for (var entry in _)
				{
					if (entry.value != null)
					{
						delete entry.value;
					}
				}
				delete _;
			};
	}
}
