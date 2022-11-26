using System.Collections;
using System;
namespace Sedulous.Core.Scenes;

typealias CreateSceneModuleDelegate = delegate SceneModule(Scene scene);

class SceneModuleFactory
{
	public static SceneModuleFactory Instance = new .() ~ delete _;

	private Dictionary<Type, CreateSceneModuleDelegate> mCreateSceneModuleDelegates = new .() ~
		{
			DeleteDictionaryAndValues!(_);
		};

	public void RegisterSceneModule<T>(CreateSceneModuleDelegate createDelegate) where T : SceneModule
	{
		Type moduleType = typeof(T);
		if (!mCreateSceneModuleDelegates.ContainsKey(moduleType))
		{
			mCreateSceneModuleDelegates.Add(moduleType, createDelegate);
		}
	}

	public T CreateSceneModule<T>(Scene scene) where T : SceneModule
	{
		Type moduleType = typeof(T);
		if (!mCreateSceneModuleDelegates.ContainsKey(moduleType))
		{
			Runtime.FatalError(scope $"No CreateSceneModuleDelegate registered for type '{moduleType.GetName(.. scope .())}'.");
		}
		return mCreateSceneModuleDelegates[moduleType](scene);
	}
}