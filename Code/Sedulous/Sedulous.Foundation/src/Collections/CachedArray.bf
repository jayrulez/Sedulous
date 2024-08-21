using System;
namespace Sedulous.Foundation.Collections;

class CachedArray<T>
{
	private int _size;
	private int _capacity;
	private T[] _array;

	public this(uint size = 1U)
	{
	    _size = 0;
	    _capacity = Math.Max((int)size, 1);
	    _array = new T[_capacity];
	}

	// Destructor
	public ~this()
	{
	    delete _array;
	}

	// Copy constructor
	public this(CachedArray<T> other)
	{
	    _size = other._size;
	    _capacity = other._capacity;
	    _array = new T[other._capacity];
	    Array.Copy(other._array, _array, _size);
	}

	// Copy assignment operator
	public CachedArray<T> Assign(CachedArray<T> other)
	{
	    if (this != other)
	    {
	        delete _array;
			_array = null;
	        _size = other._size;
	        _capacity = other._capacity;
	        _array = new T[_capacity];
	        Array.Copy(other._array, _array, _size);
	    }
	    return this;
	}

	// Move constructor
	public this(CachedArray<T> other, bool move) // move flag indicates it's a move operation
	{
	    _size = other._size;
	    _capacity = other._capacity;
	    _array = other._array;

	    other._size = 0;
	    other._capacity = 0;
		delete other._array;
	    other._array = null;
	}

	// Move assignment operator
	public CachedArray<T> Assign(CachedArray<T> other, bool move)
	{
	    if (this != other)
	    {
			delete _array;
	        _array = null;
	        _size = other._size;
	        _capacity = other._capacity;
	        _array = other._array;

	        other._size = 0;
	        other._capacity = 0;
			delete other._array;
	        other._array = null;
	    }
	    return this;
	}

	// Indexer
	public T this[int index]
	{
	    get => _array[index];
	    set => _array[index] = value;
	}

	public void Clear() => _size = 0;

	public int Size() => (int)_size;

	public T Pop() => _array[--_size];

	public void Reserve(int size)
	{
	    if (size > _capacity)
	    {
	        T[] temp = _array;
	        _array = new T[size];
	        Array.Copy(temp, _array, _capacity);
			delete temp;
	        _capacity = (int)size;
	    }
	}

	public void Push(T item)
	{
	    if (_size >= _capacity)
	    {
	        T[] temp = _array;
	        _array = new T[_capacity * 2];
	        Array.Copy(temp, _array, _capacity);
			delete temp;
	        _capacity *= 2;
	    }
	    _array[_size++] = item;
	}

	public void Concat(CachedArray<T> array)
	{
	    if (_size + array._size > _capacity)
	    {
	        T[] temp = _array;
	        int size = Math.Max(_capacity * 2, _size + array._size);
	        _array = new T[size];
	        Array.Copy(temp, _array, _size);
			delete temp;
	        _capacity = size;
	    }
	    Array.Copy(array._array, 0, _array, _size, array._size);
	    _size += array._size;
	}

	public void Concat(T[] array, int count)
	{
	    if (_size + count > _capacity)
	    {
	        T[] temp = _array;
	        int size = Math.Max(_capacity * 2, _size + (int)count);
	        _array = new T[size];
	        Array.Copy(temp, _array, _size);
			delete temp;
	        _capacity = size;
	    }
	    Array.Copy(array, 0, _array, _size, (int)count);
	    _size += (int)count;
	}

	public void FastRemove(int idx)
	{
	    if (idx >= _size) return;
	    _array[idx] = _array[--_size];
	}

	public int IndexOf(T item)
	{
		return _array.IndexOf(item);
	}
}