using Sedulous.RHI;
using Win32.Graphics.Direct3D12;

namespace Sedulous.RHI.DirectX12;

/// <summary>
/// The DX12 capabilities.
/// </summary>
public class DX12Capabilities : GraphicsContextCapabilities
{
	private readonly DX12GraphicsContext context;

	/// <inheritdoc />
	public override bool IsComputeShaderSupported => true;

	/// <inheritdoc />
	public override bool FlipProjectionRequired => false;

	/// <inheritdoc />
	public override MatrixMajorness MatrixMajorness => /*MatrixMajorness*/.RowMajor;

	/// <inheritdoc />
	public override bool IsMRTSupported => true;

	/// <inheritdoc />
	public override bool IsShadowMapSupported => true;

	/// <inheritdoc />
	public override ClipDepth ClipDepth => /*ClipDepth*/.ZeroToOne;

	/// <inheritdoc />
	public override MultiviewStrategy MultiviewStrategy => /*MultiviewStrategy*/.Unsupported;

	/// <inheritdoc />
	public override bool IsRaytracingSupported => context.DXDevice.QueryInterface<ID3D12Device5>() != null;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12Capabilities" /> class.
	/// </summary>
	/// <param name="context">The current graphics context.</param>
	public this(DX12GraphicsContext context)
	{
		this.context = context;
	}
}
