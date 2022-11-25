using System;
using Sedulous.NRI;
namespace Sedulous.Platform;

abstract class WindowSystem
{
	public abstract Window PrimaryWindow {get;}

	public abstract bool IsRunning {get; protected set; }

	public abstract Result<void> CreateWindow(StringView title, uint32 width, uint32 height, bool isVisible, GraphicsAPI graphicsAPI, out Window window);

	public abstract void DestroyWindow(Window window);

	public abstract Window GetWindowByID(uint32 windowId);

	public abstract void RunMainLoop(delegate void() updateCallback);
	public abstract void StopMainLoop();
}