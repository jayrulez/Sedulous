using System;
namespace NRI.Framework;

abstract class Surface
{
	/// <summary>
	/// Surface information.
	/// </summary>
	public SurfaceInfo SurfaceInfo;

	/// <summary>
	/// Surface Width.
	/// </summary>
	public uint32 Width;

	/// <summary>
	/// Surface Height.
	/// </summary>
	public uint32 Height;

	/// <summary>
	/// Occurs when surface size is changed.
	/// </summary>
	public EventAccessor<delegate void(uint32 width, uint32 height)> Resized = new .() ~ delete _;

	/// <summary>
	/// Occurs when surface is closing
	/// </summary>
	public EventAccessor<delegate void()> Closing = new .() ~ delete _;

	/// <summary>
	/// Occurs when surface get focus
	/// </summary>
	public EventAccessor<delegate void()> FocusGained = new .() ~ delete _;

	/// <summary>
	/// Occurs when surface lost focus
	/// </summary>
	public EventAccessor<delegate void()> FocusLost = new .() ~ delete _;

	/// <summary>
	/// Initializes a new instance of the Surface class.
	/// </summary>
	/// <param name="width">surface width.</param>
	/// <param name="height">surface height.</param>
	public this(uint32 width, uint32 height)
	{
		Width = width;
		Height = height;
	}

	/// <summary>
	/// Raise base window closing event.
	/// </summary>
	protected virtual void OnClosing()
	{
		if (this.Closing.[Friend]mEvent.HasListeners)
			this.Closing.[Friend]mEvent();
	}

	/// <summary>
	/// Raise base got focus event.
	/// </summary>
	protected virtual void OnFocusGained()
	{
		if (this.FocusGained.[Friend]mEvent.HasListeners)
			this.FocusGained.[Friend]mEvent();
	}

	/// <summary>
	/// Raise base lost focus event.
	/// </summary>
	protected virtual void OnFocusLost()
	{
		if (this.FocusLost.[Friend]mEvent.HasListeners)
			this.FocusLost.[Friend]mEvent();
	}

	/// <summary>
	/// Raise base size changed event.
	/// </summary>
	protected virtual void OnResized()
	{
		if (this.Resized.[Friend]mEvent.HasListeners)
			this.Resized.[Friend]mEvent(Width, Height);
	}
}