using Sedulous.Core.Scenes;
namespace Sedulous.Graphics;

class RenderableComponentManager : TComponentManager<RenderableComponent>
{
	public this(Scene scene) : base(scene)
	{

	}
}