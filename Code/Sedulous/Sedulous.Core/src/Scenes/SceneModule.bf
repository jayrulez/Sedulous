namespace Sedulous.Core.Scenes;

class SceneModule
{
	public Scene Scene { get; private set; }

	public this(Scene scene)
	{
		Scene = scene;
	}

	public virtual void Initialize()
	{
	}

	public virtual void Shutdown()
	{
	}
}