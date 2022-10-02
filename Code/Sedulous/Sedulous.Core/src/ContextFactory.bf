using System.Collections;
using System;
using Sedulous.Foundation;
namespace Sedulous.Core;

/// <summary>
/// Represents an Application context's object factory.
/// </summary>
sealed class ContextFactory
{
	/// <summary>
	/// Attempts to retrieve the default factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to retrieve.</typeparam>
	/// <returns>The default factory method of the specified type, or <see langword="null"/> if no such factory method is registered..</returns>
	public T TryGetFactoryMethod<T>() where T : class
	{
		var value = default(Delegate);
		mDefaultFactoryMethods.TryGetValue(typeof(T), out value);

		if (value == null)
			return null;

		var typed = value as T;
		if (typed == null)
			Runtime.InvalidOperation("InvalidCast");

		return typed;
	}

	/// <summary>
	/// Attempts to retrieve a named factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to retrieve.</typeparam>
	/// <param name="name">The name of the factory method to retrieve.</param>
	/// <returns>The specified named factory method, or <see langword="null"/> if no such factory method is registered.</returns>
	public T TryGetFactoryMethod<T>(String name) where T : class
	{
		Contract.RequireNotEmpty(name, nameof(name));

		var registry = default(Dictionary<String, Delegate>);
		if (!mNamedFactoryMethods.TryGetValue(typeof(T), out registry))
			return null;

		var value = default(Delegate);
		registry.TryGetValue(name, out value);

		if (value == null)
			return null;

		var typed = value as T;
		if (typed == null)
			Runtime.FatalError("Invalid Cast");

		return typed;
	}

	/// <summary>
	/// Gets the default factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to retrieve.</typeparam>
	/// <returns>The default factory method of the specified type.</returns>
	public T GetFactoryMethod<T>() where T : class
	{
		var value = default(Delegate);
		mDefaultFactoryMethods.TryGetValue(typeof(T), out value);

		if (value == null)
			Runtime.FatalError(scope $"Invalid Operation: MissingFactoryMethod '{typeof(T).GetFullName(.. scope .())}'.");

		var typed = value as T;
		if (typed == null)
			Runtime.FatalError("Invalid Cast");

		return typed;
	}

	/// <summary>
	/// Gets a named factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to retrieve.</typeparam>
	/// <param name="name">The name of the factory method to retrieve.</param>
	/// <returns>The specified named factory method.</returns>
	public T GetFactoryMethod<T>(String name) where T : class
	{
		Contract.RequireNotEmpty(name, nameof(name));

		var registry = default(Dictionary<String, Delegate>);
		if (!mNamedFactoryMethods.TryGetValue(typeof(T), out registry))
			Runtime.FatalError(scope $"Invalid Operation: No Named Factory Methods '{typeof(T).GetFullName(.. scope .())}'.");

		var value = default(Delegate);
		registry.TryGetValue(name, out value);

		if (value == null)
			Runtime.FatalError(scope $"Invalid Operation: Missing  FactoryMethod '{name}'.");

		var typed = value as T;
		if (typed == null)
			Runtime.FatalError("Invalid Cast");

		return typed;
	}

	/// <summary>
	/// Registers the default factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to register.</typeparam>
	/// <param name="factory">A delegate representing the factory method to register.</param>
	public void SetFactoryMethod<T>(T factory) where T : class
	{
		Contract.Require(factory, nameof(factory));

		var key = typeof(T);
		var del = factory as Delegate;
		if (del == null)
			Runtime.FatalError("FactoryMethodInvalidDelegate");

		if (mDefaultFactoryMethods.ContainsKey(key))
			Runtime.FatalError("FactoryMethodAlreadyRegistered");

		mDefaultFactoryMethods[key] = del;
	}

	/// <summary>
	/// Registers a named factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to register.</typeparam>
	/// <param name="name">The name of the factory method to register.</param>
	/// <param name="factory">A delegate representing the factory method to register.</param>
	public void SetFactoryMethod<T>(String name, T factory) where T : class
	{
		Contract.RequireNotEmpty(name, nameof(name));
		Contract.Require(factory, nameof(factory));

		var key = typeof(T);
		var registry = default(Dictionary<String, Delegate>);
		if (!mNamedFactoryMethods.TryGetValue(key, out registry))
			mNamedFactoryMethods[key] = registry = new Dictionary<String, Delegate>();

		var del = factory as Delegate;
		if (del == null)
			Runtime.FatalError("FactoryMethodInvalidDelegate");

		if (registry.ContainsKey(name))
			Runtime.FatalError("NamedFactoryMethodAlreadyRegistered");

		registry[name] = del;
	}

	/// <summary>
	/// Unregisters the default factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to remove.</typeparam>
	/// <returns><see langword="true"/> if the factory method was unregistered; otherwise, <see langword="false"/>.</returns>
	public bool RemoveFactoryMethod<T>() where T : class
	{
		return mDefaultFactoryMethods.Remove(typeof(T));
	}

	/// <summary>
	/// Unregisters a named factory method of the specified delegate type.
	/// </summary>
	/// <typeparam name="T">The delegate type of the factory method to remove.</typeparam>
	/// <param name="name">The name of the factory method to unregister.</param>
	/// <returns><see langword="true"/> if the factory method was unregistered; otherwise, <see langword="false"/>.</returns>
	public bool RemoveFactoryMethod<T>(String name) where T : class
	{
		Contract.RequireNotEmpty(name, nameof(name));

		var key = typeof(T);
		var registry = default(Dictionary<String, Delegate>);
		if (!mNamedFactoryMethods.TryGetValue(key, out registry))
			return false;

		return registry.Remove(name);
	}

	// The factory method registry.
	private readonly Dictionary<Type, Delegate> mDefaultFactoryMethods =
		new Dictionary<Type, Delegate>() ~ DeleteDictionaryAndValues!(_);

	private readonly Dictionary<Type, Dictionary<String, Delegate>> mNamedFactoryMethods =
		new Dictionary<Type, Dictionary<String, Delegate>>() ~
		{
			for (var entry in _)
			{
				DeleteDictionaryAndValues!(entry.value);
			}
			DeleteDictionaryAndValues!(_);
		};
}