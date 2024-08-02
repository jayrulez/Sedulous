using System;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI;

/// <summary>
/// Abstracts a viewport used for defining rendering regions.
/// </summary>
public struct Viewport : IEquatable<Viewport>
{
	/// <summary>
	/// Empty value for an undefined viewport.
	/// </summary>
	public static readonly Viewport Empty;

	/// <summary>
	/// The default viewport width.
	/// </summary>
	public static float DefaultWidth;

	/// <summary>
	/// The default viewport height.
	/// </summary>
	public static float DefaultHeight;

	/// <summary>
	/// Gets or sets the X origin of the viewport.
	/// </summary>
	public float X;

	/// <summary>
	/// Gets or sets the Y origin of the viewport.
	/// </summary>
	public float Y;

	/// <summary>
	/// Gets or sets the width of the viewport.
	/// </summary>
	public float Width;

	/// <summary>
	/// Gets or sets the height of the viewport.
	/// </summary>
	public float Height;

	/// <summary>
	/// Gets or sets the min depth range.
	/// </summary>
	public float MinDepth;

	/// <summary>
	/// Gets or sets the max depth range.
	/// </summary>
	public float MaxDepth;

	/// <summary>
	/// Gets the aspect ratio used of this viewport.
	/// </summary>
	public float AspectRatio
	{
		get
		{
			if (Width != 0f && Height != 0f)
			{
				return Width / Height;
			}
			return 0f;
		}
	}

	/// <summary>
	/// Gets the size of the viewport.
	/// </summary>
	public Vector2 Size => Vector2(Width, Height);

	/// <summary>
	/// Gets the rectangle of the viewport.
	/// </summary>
	public Rectangle Bounds => Rectangle((int32)X, (int32)Y, (int32)Width, (int32)Height);

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Viewport" /> struct.
	/// </summary>
	/// <param name="x">The x.</param>
	/// <param name="y">The y.</param>
	/// <param name="width">The width.</param>
	/// <param name="height">The height.</param>
	/// <param name="minDepth">The minimun depth range.</param>
	/// <param name="maxDepth">The maximun depth range.</param>
	public this(float x, float y, float width, float height, float minDepth = 0f, float maxDepth = 1f)
	{
		X = x;
		Y = y;
		Width = width;
		Height = height;
		MinDepth = minDepth;
		MaxDepth = maxDepth;
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Viewport" /> struct.
	/// </summary>
	/// <param name="rectangle">The viewport rectangle.</param>
	/// <param name="minDepth">The minimun depth range.</param>
	/// <param name="maxDepth">The maximun depth range.</param>
	public this(Rectangle rectangle, float minDepth = 0f, float maxDepth = 1f)
	{
		X = rectangle.X;
		Y = rectangle.Y;
		Width = rectangle.Width;
		Height = rectangle.Height;
		MinDepth = minDepth;
		MaxDepth = maxDepth;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(Viewport other)
	{
		if (X != other.X || Y != other.Y || Width != other.Width || Height != other.Height || MinDepth != other.MinDepth || MaxDepth != other.MaxDepth)
		{
			return false;
		}
		return true;
	}

	/// <summary>
	/// Determines whether the specified <see cref="T:System.Object" /> is equal to this instance.
	/// </summary>
	/// <param name="obj">The <see cref="T:System.Object" /> to compare with this instance.</param>
	/// <returns>
	///   <c>true</c> if the specified <see cref="T:System.Object" /> is equal to this instance; otherwise, <c>false</c>.
	/// </returns>
	public bool Equals(Object obj)
	{
		if (obj == null)
		{
			return false;
		}
		if (obj is Viewport)
		{
			return Equals((Viewport)obj);
		}
		return false;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public int GetHashCode()
	{
		return (((((((((X.GetHashCode() * 397) ^ Y.GetHashCode()) * 397) ^ Width.GetHashCode()) * 397) ^ Height.GetHashCode()) * 397) ^ MinDepth.GetHashCode()) * 397) ^ MaxDepth.GetHashCode();
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(Viewport value1, Viewport value2)
	{
		return value1.Equals(value2);
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator !=(Viewport value1, Viewport value2)
	{
		return !value1.Equals(value2);
	}
}
