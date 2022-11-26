using System.Collections;
using System.Threading;
namespace Sedulous.Core.Scenes;

class SceneSystem
{
	private readonly Engine mEngine = null;

	private List<Scene> mScenes = new .() ~ delete _;
	private List<Scene> mScenesToDestroy = new .() ~ delete _;

	private Monitor mScenesMonitor = new .() ~ delete _;

	public this(Engine engine)
	{
		mEngine = engine;
	}

	public void Startup()
	{
	}

	public void Shutdown()
	{
		RemoveDestroyedScenes();
	}

	public void Update(EngineTime engineTime)
	{
		for (var scene in mScenes)
		{
			scene.Update(engineTime);
		}

		RemoveDestroyedScenes();
	}

	public Scene CreateScene()
	{
		var scene = new Scene(this);

		mScenes.Add(scene);

		return scene;
	}

	public void DestroyScene(Scene scene)
	{
		using (mScenesMonitor.Enter())
			mScenesToDestroy.Add(scene);
	}

	private void RemoveDestroyedScenes()
	{
		using (mScenesMonitor.Enter())
		{
			for (var sceneToDestroy in mScenesToDestroy)
			{
				if (mScenes.Contains(sceneToDestroy))
				{
					mScenes.Remove(sceneToDestroy);

					delete sceneToDestroy;
				}
			}
			mScenesToDestroy.Clear();
		}
	}
}