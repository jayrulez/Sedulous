using System;
using System.Collections;
using Sedulous.Foundation.Utilities;
using System.Threading;
namespace Sedulous.Core.Resources;

using internal Sedulous.Core.Resources;

internal struct ResourceCacheKey : IHashable
{
	public int PathHash = 0;
	public Type ResourceType = null;

	public this(StringView path, Type resourceType)
	{
		PathHash = HashCode.Generate(path);
		ResourceType = resourceType;
	}

	public int GetHashCode()
	{
		int hashCode = 45;

		hashCode = HashHelper.CombineHash(hashCode, PathHash);
		hashCode = HashHelper.CombineHash(hashCode, ResourceType.GetTypeId());

		return hashCode;
	}
}

internal class ResourceCache
{
	private readonly Monitor mResourcesMonitor = new .() ~ delete _;
	private readonly Dictionary<ResourceCacheKey, Resource> mResources = new .() ~ delete _;

	public void Add(ResourceCacheKey key, Resource resource)
	{
		using (mResourcesMonitor.Enter())
		{
			mResources[key] = resource;
		}
	}

	public void AddIfNotExist(ResourceCacheKey key, Resource resource)
	{
		using (mResourcesMonitor.Enter())
		{
			if (!mResources.ContainsKey(key))
				mResources[key] = resource;
		}
	}

	public Resource Get(ResourceCacheKey key)
	{
		using (mResourcesMonitor.Enter())
		{
			if (mResources.ContainsKey(key))
				return mResources[key];

			return null;
		}
	}

	public void Remove(ResourceCacheKey key)
	{
		using (mResourcesMonitor.Enter())
		{
			if (mResources.ContainsKey(key))
				mResources.Remove(key);
		}
	}

	// Used by Resource to remove all cache entries referencing itself when resource is deleted
	internal void Remove(Resource resource)
	{
		using (mResourcesMonitor.Enter())
		{
			List<ResourceCacheKey> keysToRemove = scope .();
			for (var entry in mResources)
			{
				if (entry.value == resource)
					keysToRemove.Add(entry.key);
			}

			for (var key in keysToRemove)
				mResources.Remove(key);
		}
	}

	public void Clear()
	{
		using (mResourcesMonitor.Enter())
		{
			mResources.Clear();
		}
	}
}