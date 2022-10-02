using System;
namespace Sedulous.Foundation.Collections;

using internal Sedulous.Foundation.Collections;

/// <summary>
/// Represents the base class for pools.
/// </summary>
/// <typeparam name="T">The type of item contained by the pool.</typeparam>
public abstract class Pool<T> : IPool<T>, IPool, IDisposable
{
	/// <inheritdoc/>
	public void Dispose()
	{
		Dispose(true);
	}

	public abstract T Retrieve();

	/// <inheritdoc/>
	T IPool<T>.Retrieve()
	{
		return Retrieve();
	}

	/// <inheritdoc/>
	Object IPool.Retrieve()
	{
		return Retrieve();
	}

	/// <inheritdoc/>
	public virtual PooledObjectScope<T> IPool<T>.RetrieveScoped()
	{
		return PooledObjectScope<T>(this, Retrieve());
	}

	/// <inheritdoc/>
	PooledObjectScope<Object> IPool.RetrieveScoped()
	{
		return PooledObjectScope<Object>(this, Retrieve());
	}

	/// <inheritdoc/>
	public abstract void Release(T instance);

	/// <inheritdoc/>
	void IPool.Release(Object instance)
	{
		Release((T)instance);
	}

	/// <inheritdoc/>
	public abstract void ReleaseRef(ref T instance);

	/// <inheritdoc/>
	void IPool.ReleaseRef(ref Object instance)
	{
		Release((T)instance);
		instance = null;
	}

	/// <inheritdoc/>
	public abstract int32 Count { get; }

	/// <inheritdoc/>
	public abstract int32 Capacity { get; }

	/// <summary>
	/// Creates a default allocator for the pooled type.
	/// </summary>
	/// <returns>The allocator that was created.</returns>
	protected static delegate T() CreateDefaultAllocator()
	{
		// todo: check if T has default constructor
		//var ctor = typeof(T).GetConstructor(Type.EmptyTypes);
		//if (ctor == null)
		//	Runtime.FatalError(scope $"Missing Default Constructor For Type '{typeof(T).GetFullName(.. scope .())}'.");

		return new () =>
			{
				var result = typeof(T).CreateObject();
				if (result case .Ok)
				{
					return (T)result.Get();
				}
				return default;
			};
	}

	/// <summary>
	/// Releases resources associated with the object.
	/// </summary>
	/// <param name="disposing"><see langword="true"/> if the object is being disposed; <see langword="false"/> if the object is being finalized.</param>
	protected virtual void Dispose(bool disposing)
	{
	}
}