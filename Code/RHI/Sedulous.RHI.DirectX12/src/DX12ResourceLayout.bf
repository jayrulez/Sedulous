using Sedulous.RHI;
using System;

namespace Sedulous.RHI.DirectX12;

/// <summary>
/// The DX12 implementation of the ResourceLayout object.
/// </summary>
public class DX12ResourceLayout : ResourceLayout
{
	private String name = new .() ~ delete _;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			name.Set(value);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12ResourceLayout" /> class.
	/// </summary>
	/// <param name="description">The layout description.</param>
	public this(in ResourceLayoutDescription description)
		: base(description)
	{
	}

	/// <inheritdoc />
	public override void Dispose()
	{
	}
}
