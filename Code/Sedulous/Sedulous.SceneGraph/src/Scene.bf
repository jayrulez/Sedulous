using System;
using System.Collections;
using Sedulous.Foundation.Mathematics;
namespace Sedulous.SceneGraph;

using internal Sedulous.SceneGraph;

interface IScene
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

	[NoDiscard]IScene.RegisteredUpdateFunctionInfo RegisterUpdateFunction(UpdateFunctionInfo info);

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
}

extension Scene
{
	private List<Entity> mEntities = new .() ~ delete _;
	private List<EntityTransform> mTransforms = new .() ~ delete _;

	private struct ComponentEntry
	{
		/*public Type ComponentType;
		public Component Component;
		public Entity Entity;*/
	}

	private Dictionary<Type, ComponentManager> mComponentManagersByType = new .() ~ delete _;
	private Dictionary<Type, ComponentEntry> mComponents = new .() ~ delete _;

	public Result<Entity, void> CreateEntity(Vector3 position, Quaternion rotation)
	{
		return .Err;
	}

	public Result<void> DestroyEntity(ref Entity entity)
	{
		return .Ok;
	}

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
}