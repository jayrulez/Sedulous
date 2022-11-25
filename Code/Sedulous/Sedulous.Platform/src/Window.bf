using System;
using Sedulous.Foundation.Mathematics;
namespace Sedulous.Platform;

abstract class Window : Surface
{
	public abstract uint32 Id { get; }

	/// <summary>
	/// Gets or sets window title.
	/// </summary>
	public abstract String Title { get; set; }

	/// <summary>
	/// Gets or sets a value indicating whether the window is visible.
	/// </summary>
	public abstract bool Visible { get; set; }

	/// <summary>
	/// Initializes a new instance of the Window class.
	/// </summary>
	/// <param name="title">Window title.</param>
	/// <param name="width">Window width.</param>
	/// <param name="height">Window height.</param>
	public this(StringView title, uint32 width, uint32 height)
		: base(width, height)
	{
	}

	/// <summary>
	/// Warps the cursor to the specified position within this window.
	/// </summary>
	/// <param name="x">The x-coordinate within the window to which the mouse will be warped.</param>
	/// <param name="y">The y-coordinate within the window to which the mouse will be warped.</param>
	public abstract void WarpMouseWithinWindow(int32 x, int32 y);

	/// <summary>
	/// Gets or sets the window's client size.
	/// </summary>
	public Size2 ClientSize
	{
		get;
		set;
	}
}