using System;
namespace NRI.Framework;

abstract class WindowSystem
{
	public abstract bool IsRunning {get; protected set; }

	public abstract Result<void> CreateWindow(StringView title, uint32 width, uint32 height, bool isVisible, GraphicsAPI graphicsAPI, out Window window);

	public abstract void DestroyWindow(Window window);

	public abstract void CreateMainLoop(delegate void() frameAction);

	public void Run(delegate void() frameCallback)
	{
		CreateMainLoop(frameCallback);
	}
}