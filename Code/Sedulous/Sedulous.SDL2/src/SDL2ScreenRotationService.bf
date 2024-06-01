using Sedulous.Platform;
namespace Sedulous.SDL2;

class SDL2ScreenRotationService : ScreenRotationService
{
	public this(IDisplay display) : base(display)
	{

	}
	public override ScreenRotation ScreenRotation
	{
		get => .Rotation0;
	}
}