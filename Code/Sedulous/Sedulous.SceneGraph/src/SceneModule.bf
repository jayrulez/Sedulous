namespace Sedulous.SceneGraph;

typealias SceneModuleTypeId = uint16;

abstract class SceneModule
{
	public typealias CreateFunc = function SceneModule(Scene scene);
	public typealias DestroyFunc = function void(SceneModule module);

	public Scene Scene { get; private set; }

	public this(Scene scene)
	{
		this.Scene = scene;
	}
}