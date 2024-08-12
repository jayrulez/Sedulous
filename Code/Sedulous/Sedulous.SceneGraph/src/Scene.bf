using System;
using System.Collections;
using Sedulous.Foundation.Mathematics;
namespace Sedulous.SceneGraph;

using internal Sedulous.SceneGraph;

/*interface IScene
{
	public enum UpdateStage
	{
		PreTransform,
		PostTransform
	}

	public struct UpdateInfo
	{
		public IScene Scene;
		public TimeSpan DeltaTime;
	}

	public struct RegisteredUpdateFunctionInfo
	{
		public Guid Id;
		public UpdateStage Stage;
		public int Priority;
		public UpdateFunction Function;

		internal this(Guid id, UpdateStage stage, int priority, UpdateFunction @function)
		{
			this.Id = id;
			this.Stage = stage;
			this.Priority = priority;
			this.Function = @function;
		}
	}

	public typealias UpdateFunction = delegate void(UpdateInfo info);

	public struct UpdateFunctionInfo
	{
		public int Priority;
		public UpdateStage Stage;
		public UpdateFunction Function;
	}

	[NoDiscard] IScene.RegisteredUpdateFunctionInfo RegisterUpdateFunction(UpdateFunctionInfo info);

	void RegisterUpdateFunctions(Span<UpdateFunctionInfo> infos, List<IScene.RegisteredUpdateFunctionInfo> registrations);

	void UnregisterUpdateFunction(IScene.RegisteredUpdateFunctionInfo registration);

	void UnregisterUpdateFunctions(Span<IScene.RegisteredUpdateFunctionInfo> registrations);

	Result<T> GetModule<T>() where T : SceneModule;

	bool TryGetModule<T>(out T outModule) where T : SceneModule;
}

class Scene : IScene
{
	private List<SceneModule> mModules = new .() ~ delete _;

	private Dictionary<IScene.UpdateStage, List<IScene.RegisteredUpdateFunctionInfo>> mUpdateFunctions = new .() ~ delete _;
	private List<IScene.RegisteredUpdateFunctionInfo> mUpdateFunctionsToRegister = new .() ~ delete _;
	private List<IScene.RegisteredUpdateFunctionInfo> mUpdateFunctionsToUnregister = new .() ~ delete _;

	internal this()
	{
		Enum.MapValues<IScene.UpdateStage>(scope (member) =>
			{
				mUpdateFunctions.Add(member, new .());
			});
	}

	internal ~this()
	{
		Enum.MapValues<IScene.UpdateStage>(scope (member) =>
			{
				delete mUpdateFunctions[member];
			});
	}

	private void UpdateTransforms(TimeSpan deltaTime)
	{
	}

	internal void Update(TimeSpan deltaTime)
	{
		#region Update methods
		void SortUpdateFunctions()
		{
			Enum.MapValues<IScene.UpdateStage>(scope (member) =>
				{
					mUpdateFunctions[member].Sort(scope (lhs, rhs) =>
						{
							if (lhs.Priority == rhs.Priority)
							{
								return 0;
							}
							return lhs.Priority > rhs.Priority ? 1 : -1;
						});
				});
		}

		void RunUpdateFunctions(IScene.UpdateStage phase, IScene.UpdateInfo info)
		{
			for (var updateFunctionInfo in mUpdateFunctions[phase])
			{
				updateFunctionInfo.Function(info);
			}
		}

		void ProcessUpdateFunctionsToRegister()
		{
			if (mUpdateFunctionsToRegister.Count == 0)
				return;

			for (var info in mUpdateFunctionsToRegister)
			{
				mUpdateFunctions[info.Stage].Add(info);
			}
			mUpdateFunctionsToRegister.Clear();
			SortUpdateFunctions();
		}

		void ProcessUpdateFunctionsToUnregister()
		{
			if (mUpdateFunctionsToUnregister.Count == 0)
				return;

			for (var info in mUpdateFunctionsToUnregister)
			{
				var index = mUpdateFunctions[info.Stage].FindIndex(scope (registered) =>
					{
						return info.Id == registered.Id;
					});

				if (index >= 0)
				{
					mUpdateFunctions[info.Stage].RemoveAt(index);
				}
			}
			mUpdateFunctionsToUnregister.Clear();
			SortUpdateFunctions();
		}
		{
			ProcessUpdateFunctionsToRegister();
			ProcessUpdateFunctionsToUnregister();
		}


#endregion

		// Pre-Transform
		{
			RunUpdateFunctions(.PreTransform, .()
				{
					Scene = this,
					DeltaTime = deltaTime
				});
		}

		// Transforms
		UpdateTransforms(deltaTime);

		// Post-Transform
		{
			RunUpdateFunctions(.PostTransform, .()
				{
					Scene = this,
					DeltaTime = deltaTime
				});
		}
	}

	public IScene.RegisteredUpdateFunctionInfo RegisterUpdateFunction(IScene.UpdateFunctionInfo info)
	{
		IScene.RegisteredUpdateFunctionInfo registration = .(Guid.Create(), info.Stage, info.Priority, info.Function);
		mUpdateFunctionsToRegister.Add(registration);
		return registration;
	}

	public void RegisterUpdateFunctions(Span<IScene.UpdateFunctionInfo> infos, List<IScene.RegisteredUpdateFunctionInfo> registrations)
	{
		for (var info in infos)
		{
			registrations.Add(RegisterUpdateFunction(info));
		}
	}

	public void UnregisterUpdateFunction(IScene.RegisteredUpdateFunctionInfo registration)
	{
		mUpdateFunctionsToUnregister.Add(registration);
	}

	public void UnregisterUpdateFunctions(Span<IScene.RegisteredUpdateFunctionInfo> registrations)
	{
		for (var info in registrations)
		{
			mUpdateFunctionsToUnregister.Add(info);
		}
	}

	public Result<T> GetModule<T>() where T : SceneModule
	{
		for (var module in mModules)
		{
			if (typeof(T) == module.GetType())
			{
				return .Ok((T)module);
			}
		}
		return .Err;
	}

	public bool TryGetModule<T>(out T outModule) where T : SceneModule
	{
		for (var module in mModules)
		{
			if (typeof(T) == module.GetType())
			{
				outModule = (T)module;
				return true;
			}
		}
		outModule = null;
		return false;
	}
}*/

/*extension Scene
{
	private struct ComponentEntry
	{
		/*public Type ComponentType;
		public Component Component;
		public Entity Entity;*/
	}

	private Dictionary<Type, ComponentManager> mComponentManagersByType = new .() ~ delete _;
	private Dictionary<Type, ComponentEntry> mComponents = new .() ~ delete _;

	public T AddComponent<T>(ref Entity entity) where T : Component
	{
		// get or create component manager in scene
		// get or create component

		return null;
	}

	public T GetComponent<T>(ref Entity entity) where T : Component
	{
		return null;
	}

	public bool HasComponent<T>(ref Entity entity) where T : Component
	{
		return false;
	}

	public Result<void> RemoveComponent<T>(ref Entity entity) where T : Component
	{
		return .Err;
	}
}*/

/*extension Scene
{
	private List<Entity> mEntities = new .() ~ delete _;
	private List<Transform> mTransforms = new .() ~ delete _;

	public Result<Entity, void> CreateEntity(Vector3 position, Quaternion rotation)
	{
		return .Err;
	}

	public Result<void> DestroyEntity(ref Entity entity)
	{
		return .Ok;
	}
}*/

/// <summary>
/// Enum representing different stages of the update process.
/// </summary>
public enum UpdateStage
{
    PreTransform,
    PostTransform
}

/// <summary>
/// Struct containing information passed to update functions.
/// </summary>
public struct UpdateInfo
{
    /// <summary>
    /// The scene being updated.
    /// </summary>
    public Scene Scene { get; set mut; }

    /// <summary>
    /// The time elapsed since the last update.
    /// </summary>
    public TimeSpan DeltaTime { get; set mut; }
}

/// <summary>
/// Delegate for update functions.
/// </summary>
/// <param name="updateInfo">The update information.</param>
public delegate void UpdateFunction(UpdateInfo updateInfo);

/// <summary>
/// Struct containing information about an update function.
/// </summary>
public struct UpdateFunctionInfo
{
    /// <summary>
    /// The priority of the update function.
    /// </summary>
    public int Priority { get; set mut; }

    /// <summary>
    /// The stage at which the update function is executed.
    /// </summary>
    public UpdateStage Stage { get; set mut; }

    /// <summary>
    /// The update function delegate.
    /// </summary>
    public UpdateFunction Function { get; set mut; }
}

/// <summary>
/// Struct representing a registered update function.
/// </summary>
public struct RegisteredUpdateFunctionInfo
{
    public Guid Id { get; }
    public int Priority { get; }
    public UpdateStage Stage { get; }
    public UpdateFunction Function { get; }

    public this(Guid id, int priority, UpdateStage stage, UpdateFunction @function)
    {
        Id = id;
        Priority = priority;
        Stage = stage;
        Function = @function;
    }
}

/// <summary>
/// Struct representing a transformation (position, rotation, scale).
/// </summary>
public struct Transform
{
    public Vector3 Position { get; set mut; }
    public Quaternion Rotation { get; set mut; }
    public Vector3 Scale { get; set mut; }

    public this(Vector3 position, Quaternion rotation, Vector3 scale)
    {
        Position = position;
        Rotation = rotation;
        Scale = scale;
    }

    /// <summary>
    /// Applies the parent's transform to this transform.
    /// </summary>
    /// <param name="parentTransform">The parent's transform.</param>
    public void Apply(Transform parentTransform) mut
    {
        Position += parentTransform.Position;
        Rotation = parentTransform.Rotation * Rotation;
        Scale *= parentTransform.Scale;
    }

    /// <summary>
    /// Updates this transform with new values.
    /// </summary>
    /// <param name="update">The new transform values.</param>
    public void Update(Transform update) mut
    {
        Position = update.Position;
        Rotation = update.Rotation;
        Scale = update.Scale;
    }
}

/// <summary>
/// Struct representing an entity with an ID and version.
/// </summary>
public struct Entity : IEquatable<Entity>, IHashable
{
    public int Id { get; }
    public int Version { get; }

    public this(int id, int version)
    {
        Id = id;
        Version = version;
    }

    public bool Equals(Entity other)
    {
        return Id == other.Id && Version == other.Version;
    }

    public int GetHashCode()
    {
        return HashCode.Mix(Id, Version);
    }

    public static bool operator ==(Entity left, Entity right)
    {
        return left.Equals(right);
    }

    public static bool operator !=(Entity left, Entity right)
    {
        return !(left == right);
    }
}

/// <summary>
/// Result class to handle success and error scenarios.
/// </summary>
/// <typeparam name="T">The type of the success value.</typeparam>
/// <typeparam name="E">The type of the error value.</typeparam>
/*public class Result<T, E>
{
    public T Value { get; }
    public E Error { get; }
    public bool IsSuccess { get; }

    private Result(T value, E error, bool isSuccess)
    {
        Value = value;
        Error = error;
        IsSuccess = isSuccess;
    }

    public static Result<T, E> Ok(T value)
    {
        return new Result<T, E>(value, default(E), true);
    }

    public static Result<T, E> Err(E error)
    {
        return new Result<T, E>(default(T), error, false);
    }
}*/

/// <summary>
/// Enum representing possible errors in the Scene class.
/// </summary>
public enum SceneError
{
    LayerAlreadyExists,
    LayerDoesNotExist,
    EntityDoesNotExist,
    ComponentTypeNotRegistered,
    ComponentNotFound,
    DefaultLayerCannotBeRemoved
}

/// <summary>
/// Delegate for creating a component.
/// </summary>
/// <typeparam name="T">The type of the component.</typeparam>
/// <param name="module">The scene module.</param>
/// <param name="entity">The entity to create the component for.</param>
/// <returns>The created component.</returns>
public delegate T CreateComponentDelegate<T>(SceneModule module, Entity entity);

/// <summary>
/// Delegate for destroying a component.
/// </summary>
/// <typeparam name="T">The type of the component.</typeparam>
/// <param name="module">The scene module.</param>
/// <param name="entity">The entity the component belongs to.</param>
/// <param name="component">The component to destroy.</param>
public delegate void DestroyComponentDelegate<T>(SceneModule module, Entity entity, T component);

/// <summary>
/// Class representing an entry for a component type.
/// </summary>
public struct ComponentTypeEntry
{
    public Guid Guid { get; }
    public SceneModule Module { get; }
    public Delegate CreateComponent { get; }
    public Delegate DestroyComponent { get; }

    public this(Guid guid, SceneModule module, Delegate createComponent, Delegate destroyComponent)
    {
        Guid = guid;
        Module = module;
        CreateComponent = createComponent;
        DestroyComponent = destroyComponent;
    }
}

/// <summary>
/// Abstract class representing a scene module.
/// </summary>
/*public abstract class SceneModule
{
    public abstract void Initialize(Scene scene);
}*/

/// <summary>
/// Class representing a scene containing entities, components, and update functions.
/// </summary>
class Scene
{
    // Entity Management
    private List<Entity> entities = new List<Entity>() ~ delete _;
    private List<Transform> localTransforms = new List<Transform>() ~ delete _;
    private List<Transform> globalTransforms = new List<Transform>() ~ delete _;
    private Dictionary<int, int> entityToTransformIndex = new Dictionary<int, int>() ~ delete _;
    private Dictionary<int, int?> entityParent = new Dictionary<int, int?>() ~ delete _;
    private Dictionary<int, List<int>> entityChildren = new Dictionary<int, List<int>>() ~ DeleteDictionaryAndValues!(_);
    private Dictionary<int, Transform> queuedTransformUpdates = new Dictionary<int, Transform>() ~ delete _;
    private Dictionary<int, String> entityNames = new Dictionary<int, String>() ~ DeleteDictionaryAndValues!(_);
    private HashSet<int> queuedEntityRemovals = new HashSet<int>() ~ delete _;
    private Queue<int> freeEntityIds = new Queue<int>() ~ delete _;
    private Dictionary<int, int> entityVersions = new Dictionary<int, int>() ~ delete _;
    private Dictionary<int, HashSet<Entity>> layers = new Dictionary<int, HashSet<Entity>>() ~ DeleteDictionaryAndValues!(_);
    private Dictionary<int, String> layerIdToName = new Dictionary<int, String>() ~ delete _;
    private int nextEntityId = 0;
    private int nextLayerId = 0;
    private int defaultLayerId;

    public Event<delegate void(Entity)> EntityCreated;
    public Event<delegate void(Entity)> EntityRemoved;
    public Event<delegate void(String)> LayerCreated;
    public Event<delegate void(String, bool)> LayerRemoved;

    // Component Management
    private Dictionary<Type, ComponentTypeEntry> componentTypes = new Dictionary<Type, ComponentTypeEntry>() ~ delete _;
    private Dictionary<int, Dictionary<Type, Object>> entityComponents = new Dictionary<int, Dictionary<Type, Object>>() ~ DeleteDictionaryAndValues!(_);
    private List<(Entity, Type, Object)> queuedComponentRemovals = new List<(Entity, Type, Object)>() ~ delete _;
    private List<Type> componentTypeUnregistrationQueue = new List<Type>() ~ delete _;

    public Event<delegate void(Entity, Type, SceneModule)> ComponentAdded;
    public Event<delegate void(Entity, Type, SceneModule)> ComponentRemoved;

    // Update Function Management
    private Dictionary<UpdateStage, List<RegisteredUpdateFunctionInfo>> registeredUpdateFunctions = new Dictionary<UpdateStage, List<RegisteredUpdateFunctionInfo>>() ~ delete _;
    private List<RegisteredUpdateFunctionInfo> updateFunctionRegistrationQueue = new List<RegisteredUpdateFunctionInfo>() ~ delete _;
    private List<RegisteredUpdateFunctionInfo> updateFunctionUnregistrationQueue = new List<RegisteredUpdateFunctionInfo>() ~ delete _;

    /// <summary>
    /// Initializes a new instance of the <see cref="Scene"/> class.
    /// </summary>
    public this()
    {
        defaultLayerId = CreateLayer("Default").Value;

        // Initialize registeredUpdateFunctions for each UpdateStage value
        for (UpdateStage stage in Enum.GetValues(typeof(UpdateStage)))
        {
            registeredUpdateFunctions[stage] = new List<RegisteredUpdateFunctionInfo>();
        }
    }

	public ~this()
	{
		for (UpdateStage stage in Enum.GetValues(typeof(UpdateStage)))
		{
		    delete registeredUpdateFunctions[stage];
		}
	}

    // Entity Management Methods

    /// <summary>
    /// Creates a new layer with the specified name.
    /// </summary>
    /// <param name="layerName">The name of the layer.</param>
    /// <returns>The result containing the layer ID or an error.</returns>
    public Result<int, SceneError> CreateLayer(String layerName)
    {
        if (!layerIdToName.ContainsValue(layerName))
        {
            int layerId = nextLayerId++;
            layerIdToName[layerId] = layerName;
            layers[layerId] = new HashSet<Entity>();

            LayerCreated.Invoke(layerName);

            return Result<int, SceneError>.Ok(layerId);
        }
        else
        {
            return Result<int, SceneError>.Err(SceneError.LayerAlreadyExists);
        }
    }

    /// <summary>
    /// Removes a layer with the specified name.
    /// </summary>
    /// <param name="layerName">The name of the layer.</param>
    /// <param name="removeEntities">Whether to remove the entities in the layer.</param>
    /// <returns>The result indicating success or error.</returns>
    public Result<void, SceneError> RemoveLayer(String layerName, bool removeEntities = true)
    {
        int layerId = GetLayerIdByName(layerName);
        if (layerId == defaultLayerId)
        {
            return Result<void, SceneError>.Err(SceneError.DefaultLayerCannotBeRemoved);
        }
        if (layerId != -1)
        {
            if (removeEntities)
            {
                for (var entity in layers[layerId])
                {
                    DestroyEntity(entity);
                }
            }
            else
            {
                String defaultLayerName = layerIdToName[defaultLayerId];
                for (var entity in layers[layerId])
                {
                    AddEntityToLayer(entity, defaultLayerName);
                }
            }

			delete layerIdToName[layerId];
            layerIdToName.Remove(layerId);

			delete layers[layerId];
            layers.Remove(layerId);

            ApplyQueuedEntityRemovals();

            LayerRemoved.Invoke(layerName, removeEntities);

            return Result<void, SceneError>.Ok;
        }
        else
        {
            return Result<void, SceneError>.Err(SceneError.LayerDoesNotExist);
        }
    }

    /// <summary>
    /// Creates a new entity.
    /// </summary>
    /// <param name="name">The name of the entity.</param>
    /// <param name="parentEntityId">The ID of the parent entity.</param>
    /// <param name="layerName">The name of the layer.</param>
    /// <returns>The result containing the created entity or an error.</returns>
    public Result<Entity, SceneError> CreateEntity(String name = null, int? parentEntityId = null, String layerName = null)
    {
        int entityId = GenerateEntityId();
        int version = entityVersions[entityId];
        Entity entity = Entity(entityId, version);
        entityNames[entityId] = new .(name ?? entityId.ToString(.. scope .()));
        InitializeTransforms(entityId);

        entities.Add(entity);

        if (parentEntityId.HasValue)
        {
            entityChildren[parentEntityId.Value].Add(entityId);
        }

        int layerId = layerName != null ? GetLayerIdByName(layerName) : defaultLayerId;
        if (layerId == -1 && layerName != null)
        {
            return Result<Entity, SceneError>.Err(SceneError.LayerDoesNotExist);
        }
        layers[layerId].Add(entity);

        EntityCreated.Invoke(entity);

        return Result<Entity, SceneError>.Ok(entity);
    }

    /// <summary>
    /// Gets an entity by its name.
    /// </summary>
    /// <param name="name">The name of the entity.</param>
    /// <returns>The result containing the entity or an error.</returns>
    public Result<Entity, SceneError> GetEntityByName(String name)
    {
        for (var kvp in entityNames)
        {
            if (kvp.value == name)
            {
                int entityId = kvp.key;
                int version = entityVersions[entityId];
                return Result<Entity, SceneError>.Ok(Entity(entityId, version));
            }
        }
        return Result<Entity, SceneError>.Err(SceneError.EntityDoesNotExist);
    }

    /// <summary>
    /// Adds an entity to a layer.
    /// </summary>
    /// <param name="entity">The entity to add.</param>
    /// <param name="layerName">The name of the layer.</param>
    /// <returns>The result indicating success or error.</returns>
    public Result<void, SceneError> AddEntityToLayer(Entity entity, String layerName)
    {
        int newLayerId = GetLayerIdByName(layerName);
        if (newLayerId == -1)
        {
            return Result<void, SceneError>.Err(SceneError.LayerDoesNotExist);
        }

        for (var kvp in layers)
        {
            if (kvp.value.Contains(entity))
            {
                kvp.value.Remove(entity);
                break;
            }
        }

        layers[newLayerId].Add(entity);
        return Result<void, SceneError>.Ok;
    }

    /// <summary>
    /// Removes an entity from a layer.
    /// </summary>
    /// <param name="entity">The entity to remove.</param>
    /// <param name="layerName">The name of the layer.</param>
    /// <param name="removeFromSceneGraph">Whether to remove the entity from the scene graph.</param>
    /// <returns>The result indicating success or error.</returns>
    public Result<void, SceneError> RemoveEntityFromLayer(Entity entity, String layerName, bool removeFromSceneGraph = false)
    {
        int layerId = GetLayerIdByName(layerName);
        if (layerId != -1)
        {
            layers[layerId].Remove(entity);

            if (removeFromSceneGraph)
            {
                DestroyEntity(entity);
            }
            return Result<void, SceneError>.Ok;
        }
        else
        {
            return Result<void, SceneError>.Err(SceneError.LayerDoesNotExist);
        }
    }

    /// <summary>
    /// Gets the entities in a layer.
    /// </summary>
    /// <param name="layerName">The name of the layer.</param>
    /// <returns>The result containing the entities or an error.</returns>
    public Result<IEnumerable<Entity>, SceneError> GetEntitiesInLayer(String layerName)
    {
        int layerId = GetLayerIdByName(layerName);
        if (layerId != -1)
        {
            return Result<IEnumerable<Entity>, SceneError>.Ok(layers[layerId]);
        }
        else
        {
            return Result<IEnumerable<Entity>, SceneError>.Err(SceneError.LayerDoesNotExist);
        }
    }

    /// <summary>
    /// Destroys an entity.
    /// </summary>
    /// <param name="entity">The entity to destroy.</param>
    /// <returns>The result indicating success or error.</returns>
    public Result<void, SceneError> DestroyEntity(Entity entity)
    {
        if (!entityToTransformIndex.ContainsKey(entity.Id))
            return Result<void, SceneError>.Err(SceneError.EntityDoesNotExist);

        queuedEntityRemovals.Add(entity.Id);
        return Result<void, SceneError>.Ok;
    }

    /// <summary>
    /// Applies queued entity removals.
    /// </summary>
    private void ApplyQueuedEntityRemovals()
    {
        for (var entityId in queuedEntityRemovals)
        {
            RemoveEntity(entityId);
        }
        queuedEntityRemovals.Clear();
    }

    /// <summary>
    /// Removes an entity and its associated data.
    /// </summary>
    /// <param name="entityId">The ID of the entity to remove.</param>
    private void RemoveEntity(int entityId)
    {
        int transformIndex = entityToTransformIndex[entityId];
        localTransforms.RemoveAt(transformIndex);
        globalTransforms.RemoveAt(transformIndex);
        entityToTransformIndex.Remove(entityId);

        if (entityParent[entityId].HasValue)
        {
            entityChildren[entityParent[entityId].Value].Remove(entityId);
        }

        for (var key in entityToTransformIndex.Keys)
        {
            if (entityToTransformIndex[key] > transformIndex)
                entityToTransformIndex[key]--;
        }

        for (var childId in entityChildren[entityId])
        {
            RemoveEntity(childId);
        }
        entityChildren.Remove(entityId);
        entityParent.Remove(entityId);
        queuedTransformUpdates.Remove(entityId);
        entityNames.Remove(entityId);

        entities.RemoveAll(scope (e) => e.Id == entityId);

        for (var layer in layers.Values)
        {
            layer.Remove(Entity(entityId, entityVersions[entityId]));
        }

        freeEntityIds.Add(entityId);

        EntityRemoved.Invoke(Entity(entityId, entityVersions[entityId]));
    }

    /// <summary>
    /// Gets the local transform of an entity.
    /// </summary>
    /// <param name="entity">The entity.</param>
    /// <returns>The result containing the transform or an error.</returns>
    public Result<Transform, SceneError> GetLocalTransform(Entity entity)
    {
        if (entityToTransformIndex.ContainsKey(entity.Id))
        {
            int index = entityToTransformIndex[entity.Id];
            return Result<Transform, SceneError>.Ok(localTransforms[index]);
        }
        return Result<Transform, SceneError>.Err(SceneError.EntityDoesNotExist);
    }

    /// <summary>
    /// Gets the global transform of an entity.
    /// </summary>
    /// <param name="entity">The entity.</param>
    /// <returns>The result containing the transform or an error.</returns>
    public Result<Transform, SceneError> GetGlobalTransform(Entity entity)
    {
        if (entityToTransformIndex.ContainsKey(entity.Id))
        {
            int index = entityToTransformIndex[entity.Id];
            return Result<Transform, SceneError>.Ok(globalTransforms[index]);
        }
        return Result<Transform, SceneError>.Err(SceneError.EntityDoesNotExist);
    }

    /// <summary>
    /// Gets the name of an entity.
    /// </summary>
    /// <param name="entity">The entity.</param>
    /// <returns>The result containing the name or an error.</returns>
    public Result<String, SceneError> GetEntityName(Entity entity)
    {
        if (entityNames.ContainsKey(entity.Id))
        {
            return Result<String, SceneError>.Ok(entityNames[entity.Id]);
        }
        return Result<String, SceneError>.Err(SceneError.EntityDoesNotExist);
    }

    /// <summary>
    /// Sets the name of an entity.
    /// </summary>
    /// <param name="entity">The entity.</param>
    /// <param name="name">The new name.</param>
    /// <returns>The result indicating success or error.</returns>
    public Result<void, SceneError> SetEntityName(Entity entity, String name)
    {
        if (entityNames.ContainsKey(entity.Id))
        {
            entityNames[entity.Id] = name;
            return Result<void, SceneError>.Ok;
        }
        else
        {
            return Result<void, SceneError>.Err(SceneError.EntityDoesNotExist);
        }
    }

    /// <summary>
    /// Updates the local transform of an entity.
    /// </summary>
    /// <param name="entity">The entity.</param>
    /// <param name="newLocalTransform">The new local transform.</param>
    /// <returns>The result indicating success or error.</returns>
    public Result<void, SceneError> UpdateTransform(Entity entity, Transform newLocalTransform)
    {
        if (!entityToTransformIndex.ContainsKey(entity.Id))
            return Result<void, SceneError>.Err(SceneError.EntityDoesNotExist);

        if (queuedTransformUpdates.ContainsKey(entity.Id))
        {
            queuedTransformUpdates[entity.Id].Update(newLocalTransform);
        }
        else
        {
            queuedTransformUpdates[entity.Id] = newLocalTransform;
        }

        return Result<void, SceneError>.Ok;
    }

    /// <summary>
    /// Applies queued transform updates.
    /// </summary>
    private void ApplyQueuedTransformUpdates()
    {
        for (var kvp in queuedTransformUpdates)
        {
            int entityId = kvp.key;
            Transform newLocalTransform = kvp.value;
            int index = entityToTransformIndex[entityId];
            localTransforms[index] = newLocalTransform;

            UpdateGlobalTransform(entityId);
        }
        queuedTransformUpdates.Clear();
    }

    /// <summary>
    /// Updates the global transform of an entity and its children.
    /// </summary>
    /// <param name="entityId">The ID of the entity.</param>
    private void UpdateGlobalTransform(int entityId)
    {
        int index = entityToTransformIndex[entityId];
        Transform localTransform = localTransforms[index];

        if (entityParent[entityId].HasValue)
        {
            Transform parentGlobalTransform = GetGlobalTransform(Entity(entityParent[entityId].Value, entityVersions[entityParent[entityId].Value])).Value;
            localTransform.Apply(parentGlobalTransform);
        }

        globalTransforms[index] = localTransform;

        for (var childId in entityChildren[entityId])
        {
            UpdateGlobalTransform(childId);
        }
    }

    // Component Management Methods

    /// <summary>
    /// Registers a component type.
    /// </summary>
    /// <typeparam name="T">The type of the component.</typeparam>
    /// <param name="module">The scene module.</param>
    /// <param name="createComponent">The delegate to create the component.</param>
    /// <param name="destroyComponent">The delegate to destroy the component.</param>
    /// <returns>The result containing the component type entry or an error.</returns>
    public Result<ComponentTypeEntry, SceneError> RegisterComponentType<T>(SceneModule module, CreateComponentDelegate<T> createComponent, DestroyComponentDelegate<T> destroyComponent)
    {
        Type componentType = typeof(T);
        var entry = ComponentTypeEntry(Guid.Create(), module, createComponent, destroyComponent);
        componentTypes[componentType] = entry;
        return Result<ComponentTypeEntry, SceneError>.Ok(entry);
    }

    /// <summary>
    /// Unregisters a component type.
    /// </summary>
    /// <param name="componentTypeGuid">The GUID of the component type.</param>
    /// <returns>The result indicating success or error.</returns>
    public Result<void, SceneError> UnregisterComponentType(Guid componentTypeGuid)
    {
        for (var kvp in componentTypes)
        {
            if (kvp.value.Guid == componentTypeGuid)
            {
                componentTypeUnregistrationQueue.Add(kvp.key);
                return Result<void, SceneError>.Ok;
            }
        }
        return Result<void, SceneError>.Err(SceneError.ComponentTypeNotRegistered);
    }

    /// <summary>
    /// Applies queued component type unregistrations.
    /// </summary>
    private void ApplyQueuedComponentTypeUnregistrations()
    {
        for (var componentType in componentTypeUnregistrationQueue)
        {
            if (componentTypes.TryGetValue(componentType, var entry))
            {
                for (var entity in entityComponents.Keys)
                {
                    if (entityComponents[entity].TryGetValue(componentType, var component))
                    {
                        queuedComponentRemovals.Add((Entity(entity, entityVersions[entity]), componentType, component));
                    }
                }
                componentTypes.Remove(componentType);
            }
        }
        componentTypeUnregistrationQueue.Clear();
    }

    /// <summary>
    /// Adds a component to an entity.
    /// </summary>
    /// <typeparam name="T">The type of the component.</typeparam>
    /// <param name="entity">The entity.</param>
    /// <returns>The result containing the component or an error.</returns>
    public Result<T, SceneError> AddComponent<T>(Entity entity)
    {
        Type componentType = typeof(T);
        if (componentTypes.TryGetValue(componentType, var entry))
        {
            if (!entityComponents.ContainsKey(entity.Id))
            {
                entityComponents[entity.Id] = new Dictionary<Type, Object>();
            }
            T component = ((CreateComponentDelegate<T>)entry.CreateComponent)(entry.Module, entity);
            entityComponents[entity.Id][componentType] = component;

            ComponentAdded.Invoke(entity, componentType, entry.Module);
            return Result<T, SceneError>.Ok(component);
        }
        else
        {
            return Result<T, SceneError>.Err(SceneError.ComponentTypeNotRegistered);
        }
    }

    /// <summary>
    /// Removes a component from an entity.
    /// </summary>
    /// <typeparam name="T">The type of the component.</typeparam>
    /// <param name="entity">The entity.</param>
    /// <returns>The result indicating success or error.</returns>
    public Result<void, SceneError> RemoveComponent<T>(Entity entity)
    {
        Type componentType = typeof(T);
        if (componentTypes.TryGetValue(componentType, var entry))
        {
            if (entityComponents.TryGetValue(entity.Id, var components) && components.ContainsKey(componentType))
            {
                T component = (T)components[componentType];
                queuedComponentRemovals.Add((entity, componentType, component));
                return Result<void, SceneError>.Ok;
            }
            else
            {
                return Result<void, SceneError>.Err(SceneError.ComponentNotFound);
            }
        }
        else
        {
            return Result<void, SceneError>.Err(SceneError.ComponentTypeNotRegistered);
        }
    }

    /// <summary>
    /// Applies queued component removals.
    /// </summary>
    private void ApplyQueuedComponentRemovals()
    {
        for (var (entity, componentType, component) in queuedComponentRemovals)
        {
            if (componentTypes.TryGetValue(componentType, var entry))
            {
                if (entityComponents.TryGetValue(entity.Id, var components) && components.ContainsKey(componentType))
                {
                    components.Remove(componentType);
                    ((DestroyComponentDelegate<Object>)entry.DestroyComponent)(entry.Module, entity, component);
                    ComponentRemoved.Invoke(entity, componentType, entry.Module);
                }
            }
        }
        queuedComponentRemovals.Clear();
    }

    /// <summary>
    /// Gets a component from an entity.
    /// </summary>
    /// <typeparam name="T">The type of the component.</typeparam>
    /// <param name="entity">The entity.</param>
    /// <returns>The result containing the component or an error.</returns>
    public Result<T, SceneError> GetComponent<T>(Entity entity)
    {
        Type componentType = typeof(T);
        if (entityComponents.TryGetValue(entity.Id, var components) && components.TryGetValue(componentType, var component))
        {
            return Result<T, SceneError>.Ok((T)component);
        }
        else
        {
            return Result<T, SceneError>.Err(SceneError.ComponentNotFound);
        }
    }

    /// <summary>
    /// Checks if an entity has a component.
    /// </summary>
    /// <typeparam name="T">The type of the component.</typeparam>
    /// <param name="entity">The entity.</param>
    /// <returns>True if the entity has the component, otherwise false.</returns>
    public bool HasComponent<T>(Entity entity)
    {
        Type componentType = typeof(T);
        return entityComponents.TryGetValue(entity.Id, var components) && components.ContainsKey(componentType);
    }

    // Update Function Management Methods

    /// <summary>
    /// Registers an update function.
    /// </summary>
    /// <param name="updateFunctionInfo">The update function information.</param>
    /// <returns>The registered update function information.</returns>
    public RegisteredUpdateFunctionInfo RegisterUpdateFunction(UpdateFunctionInfo updateFunctionInfo)
    {
        var id = Guid.Create();
        var registeredInfo = RegisteredUpdateFunctionInfo(id, updateFunctionInfo.Priority, updateFunctionInfo.Stage, updateFunctionInfo.Function);
        updateFunctionRegistrationQueue.Add(registeredInfo);
        return registeredInfo;
    }

    /// <summary>
    /// Unregisters an update function.
    /// </summary>
    /// <param name="registeredInfo">The registered update function information.</param>
    /// <returns>The result indicating success or error.</returns>
    public Result<void, SceneError> UnregisterUpdateFunction(RegisteredUpdateFunctionInfo registeredInfo)
    {
        updateFunctionUnregistrationQueue.Add(registeredInfo);
        return Result<void, SceneError>.Ok;
    }

    /// <summary>
    /// Applies queued update function registrations and unregistrations.
    /// </summary>
    private void ApplyQueuedUpdateFunctions()
    {
        for (var info in updateFunctionRegistrationQueue)
        {
            registeredUpdateFunctions[info.Stage].Add(info);
        }
        updateFunctionRegistrationQueue.Clear();

        for (var info in updateFunctionUnregistrationQueue)
        {
            registeredUpdateFunctions[info.Stage].RemoveAll(scope (uf) => uf.Id == info.Id);
        }
        updateFunctionUnregistrationQueue.Clear();

        for (var updateFunctionList in registeredUpdateFunctions.Values)
        {
            updateFunctionList.Sort((a, b) => a.Priority <=> b.Priority);
        }
    }

    /// <summary>
    /// Runs the update functions for a specific stage.
    /// </summary>
    /// <param name="stage">The update stage.</param>
    /// <param name="updateInfo">The update information.</param>
    private void RunUpdateFunctions(UpdateStage stage, UpdateInfo updateInfo)
    {
        for (var updateFunction in registeredUpdateFunctions[stage])
        {
            updateFunction.Function(updateInfo);
        }
    }

    // General Methods

    /// <summary>
    /// Updates the scene.
    /// </summary>
    /// <param name="deltaTime">The time elapsed since the last update.</param>
    public void Update(TimeSpan deltaTime)
    {
        ApplyQueuedEntityRemovals();
        ApplyQueuedComponentTypeUnregistrations();
        ApplyQueuedComponentRemovals();
        ApplyQueuedUpdateFunctions();

        var updateInfo = UpdateInfo() { Scene = this, DeltaTime = deltaTime };
        RunUpdateFunctions(UpdateStage.PreTransform, updateInfo);
        ApplyQueuedTransformUpdates();
        RunUpdateFunctions(UpdateStage.PostTransform, updateInfo);
    }

    /// <summary>
    /// Adds a module to the scene.
    /// </summary>
    /// <param name="module">The module to add.</param>
    public void AddModule(SceneModule module)
    {
        //module.Initialize(this);
    }

    /// <summary>
    /// Removes a module from the scene.
    /// </summary>
    /// <param name="module">The module to remove.</param>
    public void RemoveModule(SceneModule module)
    {
        // Implement module removal if needed
    }

    /// <summary>
    /// Generates a new entity ID.
    /// </summary>
    /// <returns>The generated entity ID.</returns>
    private int GenerateEntityId()
    {
        if (freeEntityIds.Count > 0)
        {
            return freeEntityIds.PopFront();
        }
        else
        {
            int newId = nextEntityId++;
            entityVersions[newId] = 0;
            return newId;
        }
    }

    /// <summary>
    /// Initializes the transforms for an entity.
    /// </summary>
    /// <param name="entityId">The ID of the entity.</param>
    private void InitializeTransforms(int entityId)
    {
        Transform localTransform = Transform(Vector3.Zero, Quaternion.Identity, Vector3.One);
        Transform globalTransform = Transform(Vector3.Zero, Quaternion.Identity, Vector3.One);
        localTransforms.Add(localTransform);
        globalTransforms.Add(globalTransform);
        entityToTransformIndex[entityId] = localTransforms.Count - 1;
        entityChildren[entityId] = new List<int>();
    }

    /// <summary>
    /// Gets the layer ID by its name.
    /// </summary>
    /// <param name="layerName">The name of the layer.</param>
    /// <returns>The layer ID or -1 if not found.</returns>
    private int GetLayerIdByName(String layerName)
    {
        for (var kvp in layerIdToName)
        {
            if (kvp.value == layerName)
            {
                return kvp.key;
            }
        }
        return -1;
    }
}