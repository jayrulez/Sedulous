using System;
namespace Sedulous.SceneGraph;

abstract class ComponentManager : SceneModule
{
	public this(Scene scene) : base(scene)
	{
	}

	protected virtual void OnInitialized() { }
	protected virtual void OnDestroyed() { }
}

abstract class ComponentManager<T> : ComponentManager
	where T : Component
{
	public static Type ComponentType => typeof(T);

	public this(Scene scene) : base(scene)
	{
	}
}