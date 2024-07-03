using System;
using System.Collections;
using Sedulous.Foundation.Mathematics;
namespace Sedulous.Core.SceneGraph;

interface IScene
{
	void RegisterUpdateFunction(Scene.UpdateFunctionInfo info);

	void RegisterUpdateFunctions(Span<Scene.UpdateFunctionInfo> infos);

	void UnregisterUpdateFunction(Scene.UpdateFunctionInfo info);

	void UnregisterUpdateFunctions(Span<Scene.UpdateFunctionInfo> infos);

	Result<T> GetModule<T>() where T : SceneModule;

	bool TryGetModule<T>(out T outModule) where T : SceneModule;
}

class Scene : IScene
{
	private List<SceneModule> mModules = new .() ~ delete _;

	private struct RegisteredUpdateFunctionInfo
	{
		public int Priority;
		public UpdateFunction Function;
	}
	private Dictionary<UpdateStage, List<RegisteredUpdateFunctionInfo>> mUpdateFunctions = new .() ~ delete _;
	private List<UpdateFunctionInfo> mUpdateFunctionsToRegister = new .() ~ delete _;
	private List<UpdateFunctionInfo> mUpdateFunctionsToUnregister = new .() ~ delete _;

	internal this()
	{
		Enum.MapValues<UpdateStage>(scope (member) =>
			{
				mUpdateFunctions.Add(member, new .());
			});
	}

	internal ~this()
	{
		Enum.MapValues<UpdateStage>(scope (member) =>
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
			Enum.MapValues<UpdateStage>(scope (member) =>
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

		void RunUpdateFunctions(UpdateStage phase, UpdateInfo info)
		{
			for (ref RegisteredUpdateFunctionInfo updateFunctionInfo in ref mUpdateFunctions[phase])
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
				mUpdateFunctions[info.Stage].Add(.()
					{
						Priority = info.Priority,
						Function = info.Function
					});
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
						return info.Function == registered.Function;
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

	public void RegisterUpdateFunction(UpdateFunctionInfo info)
	{
		mUpdateFunctionsToRegister.Add(info);
	}

	public void RegisterUpdateFunctions(Span<UpdateFunctionInfo> infos)
	{
		for (var info in infos)
		{
			mUpdateFunctionsToRegister.Add(info);
		}
	}

	public void UnregisterUpdateFunction(UpdateFunctionInfo info)
	{
		mUpdateFunctionsToUnregister.Add(info);
	}

	public void UnregisterUpdateFunctions(Span<UpdateFunctionInfo> infos)
	{
		for (var info in infos)
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
	public enum UpdateStage
	{
		PreTransform,
		PostTransform
	}

	struct UpdateInfo
	{
		public IScene Scene;
		public TimeSpan DeltaTime;
	}

	public typealias UpdateFunction = delegate void(UpdateInfo info);

	public struct UpdateFunctionInfo
	{
		public int Priority;
		public UpdateStage Stage;
		public UpdateFunction Function;
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