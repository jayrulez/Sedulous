using Sedulous.Foundation.Utilities;
using System.Collections;
using System;
using System.Threading;
namespace Sedulous.Core.Resources;

using internal Sedulous.Core.Resources;

class ResourceSystem
{
	private readonly IContext mContext;

	private readonly Monitor mResourceManagersByResourceTypesMonitor = new .() ~ delete _;
	private readonly Dictionary<Type, ResourceManager> mResourceManagersByResourceTypes = new .() ~ delete _;
	private readonly ResourceCache mCache = new .() ~ delete _;

	public this(IContext context)
	{
		mContext = context;
	}

	internal void Update(Time time)
	{
	}

	internal void Startup()
	{
	}

	internal void Shutdown()
	{
	}

	private ResourceManager GetResourceManagerByResourceType<T>() where T : Resource
	{
		using (mResourceManagersByResourceTypesMonitor.Enter())
		{
			var type = typeof(T);

			if (mResourceManagersByResourceTypes.ContainsKey(type))
			{
				return mResourceManagersByResourceTypes[type];
			}

			return null;
		}
	}

	private ResourceManager GetResourceManagerByResourceType(Type type)
	{
		using (mResourceManagersByResourceTypesMonitor.Enter())
		{
			if (mResourceManagersByResourceTypes.ContainsKey(type))
			{
				return mResourceManagersByResourceTypes[type];
			}

			return null;
		}
	}

	public void AddResourceManager(ResourceManager manager)
	{
		using (mResourceManagersByResourceTypesMonitor.Enter())
		{
			if(mResourceManagersByResourceTypes.ContainsKey(manager.ResourceType))
			{
				mContext.Logger?.LogWarning("A resource manager has already been registered for type '{0}'.", manager.ResourceType.GetName(.. scope .()));
				return;
			}
			mResourceManagersByResourceTypes.Add(manager.ResourceType, manager);
		}
	}

	public void RemoveResourceManager(ResourceManager manager)
	{
		using (mResourceManagersByResourceTypesMonitor.Enter())
		{
			if (mResourceManagersByResourceTypes.TryGet(manager.ResourceType, var resourceType, ?))
			{
				mResourceManagersByResourceTypes.Remove(resourceType);
			}
		}
	}

	public Result<T, ResourceLoadError> LoadResource<T>(StringView path, bool fromCache = true, bool cacheIfLoaded = true) where T : Resource
	{
		var cacheKey = ResourceCacheKey(path, typeof(T));
		if(fromCache)
		{
			var resource = mCache.Get(cacheKey);
			if(resource != null)
			{
				resource.AddRef();
				return resource;
			}
		}

		var resourceManager = GetResourceManagerByResourceType<T>();
		if(resourceManager == null)
			return .Err(.ManagerNotFound);

		var loadResult = resourceManager.Load(path);
		if(loadResult case .Err(let error))
		{
			return .Err(error);
		}

		var resource = (T)loadResult.Value;

		if(cacheIfLoaded)
		{
			mCache.AddIfNotExist(cacheKey, resource);
		}

		resource.AddRef();

		return .Ok(resource);
	}
}