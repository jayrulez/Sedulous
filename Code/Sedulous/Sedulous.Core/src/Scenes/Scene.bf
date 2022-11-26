using System.Collections;
using System.Threading;
using System;
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
	private Monitor mSceneMonitor = new .() ~ delete _;

	private readonly List<SceneModule> mSceneModules = new .() ~ delete _;

	private Dictionary<SceneUpdatePhase, List<SceneUpdateDelegate>> mUpdateDelegates = new .() ~ delete _;
	private List<SceneUpdateDelegateInfo> mUpdateDelegatesToRegister = new .() ~ delete _;
	private List<SceneUpdateDelegateInfo> mUpdateDelegatesToUnregister = new .() ~ delete _;

	private readonly SceneSystem mSceneSystem;

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