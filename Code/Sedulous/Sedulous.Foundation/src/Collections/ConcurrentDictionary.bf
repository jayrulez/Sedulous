using System.Collections;
using System.Threading;
using System;
namespace Sedulous.Foundation.Collections;

public class ConcurrentDictionary<TKey, TValue> : IEnumerable<(TKey key, TValue value)> where TKey : IHashable
{
    private readonly Dictionary<TKey, TValue> _dictionary = new Dictionary<TKey, TValue>() ~ delete _;
    private readonly Monitor _monitor = new .() ~ delete _;

    public void Add(TKey key, TValue value)
    {
        using (_monitor.Enter())
        {
            if (!_dictionary.ContainsKey(key))
            {
                _dictionary.Add(key, value);
            }
            else
            {
                Runtime.FatalError("Key already exists in the dictionary.");
            }
        }
    }

    public bool TryAdd(TKey key, TValue value)
    {
        using (_monitor.Enter())
        {
            if (!_dictionary.ContainsKey(key))
            {
                _dictionary.Add(key, value);
                return true;
            }
            return false;
        }
    }

    public bool TryGetValue(TKey key, out TValue value)
    {
        using (_monitor.Enter())
        {
            return _dictionary.TryGetValue(key, out value);
        }
    }

    public bool Remove(TKey key)
    {
        using (_monitor.Enter())
        {
            return _dictionary.Remove(key);
        }
    }

    public void Clear()
    {
        using (_monitor.Enter())
        {
            _dictionary.Clear();
        }
    }

    public bool ContainsKey(TKey key)
    {
        using (_monitor.Enter())
        {
            return _dictionary.ContainsKey(key);
        }
    }

    /*public ICollection<TKey> Keys
    {
        get
        {
            using (_monitor.Enter())
            {
                return new List<TKey>(_dictionary.Keys);
            }
        }
    }

    public ICollection<TValue> Values
    {
        get
        {
            using (_monitor.Enter())
            {
                return new List<TValue>(_dictionary.Values);
            }
        }
    }*/

    public TValue this[TKey key]
    {
        get
        {
            using (_monitor.Enter())
            {
                return _dictionary[key];
            }
        }
        set
        {
            using (_monitor.Enter())
            {
                _dictionary[key] = value;
            }
        }
    }

    public int Count
    {
        get
        {
            using (_monitor.Enter())
            {
                return _dictionary.Count;
            }
        }
    }

	public Dictionary<TKey, TValue>.Enumerator GetEnumerator()
	{
		return _dictionary.GetEnumerator();
	}
}