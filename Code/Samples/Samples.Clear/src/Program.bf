using NRI.Framework.SDL;
using NRI;
namespace Samples.Clear;

class Program
{
	public static void Main()
	{
		const GraphicsAPI graphicsAPI = .D3D12;

		var windowSystem = scope SDLWindowSystem();

		var primaryWindow = windowSystem.CreateWindow(scope $"Clear @ {graphicsAPI}", 1280, 720, true, graphicsAPI, .. ?);

		defer windowSystem.DestroyWindow(primaryWindow);

		var app = scope ClearApplication(primaryWindow, graphicsAPI);

		app.Start();

		windowSystem.Run(scope => app.Update);

		app.Stop();
	}
}