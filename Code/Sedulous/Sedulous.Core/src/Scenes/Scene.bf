using System.Collections;
using System.Threading;
using System;
using Sedulous.Foundation.Mathematics;
namespace Sedulous.Core.Scenes;

typealias SceneUpdateDelegate = delegate void(EngineTime engineTime);

enum SceneUpdatePhase
{
	PreTransform,
	PostTransform
}

struct SceneUpdateDelegateInfo
{
	public SceneUpdatePhase UpdatePhase;
	public SceneUpdateDelegate UpdateDelegate;
}

static
{
	public static void ForEachSceneUpdatePhase(delegate void(SceneUpdatePhase) action)
	{
		for (var phase = Enum.GetMinValue<SceneUpdatePhase>(); phase <= Enum.GetMaxValue<SceneUpdatePhase>(); phase++)
		{
			action(phase);
		}
	}
}

class Scene
{
	struct EntityTransform
	{
		public Vector3 Position;
		public Quaternion Rotation;
		public Vector3 Scale;
	}

	struct EntityHierarchy
	{
		public Entity* Entity;
		public Entity* Parent;
	}

	struct EntityData
	{
		public EntityTransform* ParentTransform;
		public EntityTransform* Transform;
		public EntityHierarchy* Hierarchy;
		public String Name;
	}

	private Monitor mSceneMonitor = new .() ~ delete _;

	private readonly List<SceneModule> mSceneModules = new .() ~ delete _;

	private Dictionary<SceneUpdatePhase, List<SceneUpdateDelegate>> mUpdateDelegates = new .() ~ delete _;
	private List<SceneUpdateDelegateInfo> mUpdateDelegatesToRegister = new .() ~ delete _;
	private List<SceneUpdateDelegateInfo> mUpdateDelegatesToUnregister = new .() ~ delete _;

	private Dictionary<Entity, EntityData> mEntities = new .() ~ delete _;

	private readonly SceneSystem mSceneSystem;

	private uint64 mNextEntityId = 0;

	public this(SceneSystem sceneSystem)
	{
		this.mSceneSystem = sceneSystem;

		ForEachSceneUpdatePhase(scope (updatePhase) =>
			{
				mUpdateDelegates.Add(updatePhase, new .());
			});
	}

	public ~this()
	{
		ForEachSceneUpdatePhase(scope (updatePhase) =>
			{
				delete mUpdateDelegates[updatePhase];
			});
	}

	public void Update(EngineTime engineTime)
	{
		RegisterUpdateDelegates();
		UnregisterUpdateDelegates();

		RunUpdateDelegates(.PreTransform, engineTime);
		UpdateTransforms();
		RunUpdateDelegates(.PostTransform, engineTime);
	}

	public T GetOrCreateModule<T>() where T : SceneModule
	{
		using (mSceneMonitor.Enter())
		{
			for (var sceneModule in mSceneModules)
			{
				if (sceneModule.GetType() == typeof(T))
				{
					return sceneModule;
				}
			}

			var sceneModule = SceneModuleFactory.Instance.CreateSceneModule<T>(this);

			mSceneModules.Add(sceneModule);

			return sceneModule;
		}
	}

	public T GetOrCreateComponentManager<T>() where T : ComponentManager
	{
		return GetOrCreateModule<T>();
	}

	public Entity CreateEntity(Entity? parent = null)
	{
		mSceneMonitor.Enter();
		defer mSceneMonitor.Exit();

		/*var entity = Entity()
			{
				Id = ++mNextEntityId
			};

		EntityData entityData = .()
			{
				Transform = new .(),
				Hierarchy = new .(),
				Name = new .()
			};

		if (parent != null && parent.Value.IsValid())
		{
			ref EntityData parentData = ref mEntities[parent.Value];

			entityData.ParentTransform = parentData.Transform;
			entityData.Hierarchy.Parent = parent.Value;
			entityData.Hierarchy.Child = entity;
		}

		mEntities.Add(entity, entityData);

		return entity;*/

		return .();
	}

	public void DestroyEntity(Entity entity)
	{
		mSceneMonitor.Enter();
		defer mSceneMonitor.Exit();

		if (!mEntities.ContainsKey(entity))
		{
			return;
		}

		/*var entityData = ref mEntities[entity];

		if (entityData.Hierarchy.Parent.IsValid())
		{
			// todo: store hierarchy data in a list
			ref EntityData parentData = ref mEntities[entityData.Hierarchy.Parent];
			parentData.Hierarchy.Child = .();
		}

		delete entityData.Transform;
		delete entityData.Hierarchy;
		delete entityData.Name;*/

		mEntities.Remove(entity);
	}


	private void UpdateTransforms()
	{
	}

	private void RegisterUpdateDelegates()
	{
		using (mSceneMonitor.Enter())
		{
			for (var updateDeletateInfo in mUpdateDelegatesToRegister)
			{
				mUpdateDelegates[updateDeletateInfo.UpdatePhase].Add(updateDeletateInfo.UpdateDelegate);
			}
			mUpdateDelegatesToRegister.Clear();
		}
	}

	private void UnregisterUpdateDelegates()
	{
		using (mSceneMonitor.Enter())
		{
			for (var updateDeletateInfo in mUpdateDelegatesToRegister)
			{
				mUpdateDelegates[updateDeletateInfo.UpdatePhase].Remove(updateDeletateInfo.UpdateDelegate);
			}
			mUpdateDelegatesToRegister.Clear();
		}
	}

	private void RunUpdateDelegates(SceneUpdatePhase updatePhase, EngineTime engineTime)
	{
		for (var updateDelegate in mUpdateDelegates[updatePhase])
		{
			updateDelegate(engineTime);
		}
	}

	public void RegisterUpdateDelegate(SceneUpdateDelegateInfo updateDeletateInfo)
	{
		mUpdateDelegatesToRegister.Add(updateDeletateInfo);
	}

	public void UnregisterUpdateDelegate(SceneUpdateDelegateInfo updateDeletateInfo)
	{
		mUpdateDelegatesToUnregister.Add(updateDeletateInfo);
	}
}