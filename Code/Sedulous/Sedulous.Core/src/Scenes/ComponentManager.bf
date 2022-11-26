namespace Sedulous.Core.Scenes;

abstract class ComponentManager : SceneModule
{
	public this(Scene scene) : base(scene)
	{
	}
}

class TComponentManager<T> : ComponentManager where T : Component
{
	public this(Scene scene) : base(scene)
	{
	}
}