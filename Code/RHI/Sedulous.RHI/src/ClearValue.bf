using Sedulous.Foundation.Mathematics;
using Sedulous.Foundation.Collections;

namespace Sedulous.RHI;

/// <summary>
/// Structure that specifies a clear value.
/// </summary>
public struct ClearValue
{
	/// <summary>
	/// The array of clear color values to use when clearing each color attachment.
	/// </summary>
	public FixedList<Vector4, const Constants.MaxAttachments> ColorValues = .();

	/// <summary>
	/// The depth clear value to use when clearing a depth/stencil attachment.
	/// </summary>
	public float Depth;

	/// <summary>
	/// The stencil clear value used when clearing a depth/stencil attachment.
	/// </summary>
	public uint8 Stencil;

	/// <summary>
	/// Used to perform <see cref="T:Sedulous.RHI.ClearValue" />.
	/// </summary>
	public ClearFlags Flags;

	/// <summary>
	/// Gets the default values for the None clear value.
	/// </summary>
	public static ClearValue None
	{
		get
		{
			ClearValue defaultInstance = default(ClearValue);
			defaultInstance.Flags = ClearFlags.None;
			return defaultInstance;
		}
	}

	/// <summary>
	/// Gets default values for clear value.
	/// </summary>
	/// <remarks>This means one ColorAttachment using CornFlowerBlue as the clear color, with depth = 1 and stencil = 0.</remarks>
	public static ClearValue Default
	{
		get
		{
			ClearValue defaultInstance = default(ClearValue);
			defaultInstance.Flags = ClearFlags.All;
			defaultInstance.ColorValues = .(Color.CornflowerBlue.ToVector4());
			defaultInstance.Depth = 1f;
			defaultInstance.Stencil = 0;
			return defaultInstance;
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ClearValue" /> struct.
	/// </summary>
	/// <param name="flags">Identifies the textures to clear <see cref="T:Sedulous.RHI.ClearFlags" />.</param>
	/// <param name="colorValues">The array of values to clear the color attachments.</param>
	public this(ClearFlags flags, params Color[] colorValues)
		: this(flags, 1f, 0, params colorValues)
	{
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ClearValue" /> struct.
	/// </summary>
	/// <param name="flags">Identifies the textures to clear <see cref="T:Sedulous.RHI.ClearFlags" />.</param>
	/// <param name="colorValue">The value to clear the color attachment.</param>
	public this(ClearFlags flags, Color colorValue)
		: this(flags, 1f, 0, colorValue)
	{
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ClearValue" /> struct.
	/// </summary>
	/// <param name="flags">Identifies the textures to clear <see cref="T:Sedulous.RHI.ClearFlags" />.</param>
	/// <param name="colorValues">The array of values to clear the color attachments.</param>
	public this(ClearFlags flags, params Vector4[] colorValues)
		: this(flags, 1f, 0, params colorValues)
	{
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ClearValue" /> struct.
	/// </summary>
	/// <param name="flags">Identifies the textures to clear <see cref="T:Sedulous.RHI.ClearFlags" />.</param>
	/// <param name="depth">The value to clear the depth buffer.</param>
	/// <param name="stencil">The value to clear the stencil buffer.</param>
	/// <param name="colorValues">The array of values to clear the color attachments.</param>
	public this(ClearFlags flags, float depth, uint8 stencil, params Color[] colorValues)
	{
		Flags = flags;
		Depth = depth;
		Stencil = stencil;
		ColorValues.Count = colorValues.Count;
		for (int32 i = 0; i < colorValues.Count; i++)
		{
			ColorValues[i] = colorValues[i].ToVector4();
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ClearValue" /> struct.
	/// </summary>
	/// <param name="flags">Identifies the textures to clear <see cref="T:Sedulous.RHI.ClearFlags" />.</param>
	/// <param name="depth">The value to clear the depth buffer.</param>
	/// <param name="stencil">The value to clear the stencil buffer.</param>
	/// <param name="colorValue">The value to clear the color attachment.</param>
	public this(ClearFlags flags, float depth, uint8 stencil, Color colorValue)
	{
		Flags = flags;
		Depth = depth;
		Stencil = stencil;
		ColorValues = .(colorValue.ToVector4());
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ClearValue" /> struct.
	/// </summary>
	/// <param name="flags">Identifies the textures to clear <see cref="T:Sedulous.RHI.ClearFlags" />.</param>
	/// <param name="depth">The value to clear the depth buffer.</param>
	/// <param name="stencil">The value to clear the stencil buffer.</param>
	/// <param name="colorValues">The array of values to clear the color attachments.</param>
	public this(ClearFlags flags, float depth, uint8 stencil, params Vector4[] colorValues)
	{
		Flags = flags;
		Depth = depth;
		Stencil = stencil;
		ColorValues = .(colorValues);
	}
}
