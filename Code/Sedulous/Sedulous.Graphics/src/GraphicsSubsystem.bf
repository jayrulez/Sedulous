using Sedulous.Core;
using System;
using Sedulous.RHI;
using Sedulous.Platform;
namespace Sedulous.Graphics;

class GraphicsSubsystem : Subsystem
{
	public override StringView Name => "Graphics";

	private readonly GraphicsDevice mGraphicsDevice;
	private readonly IWindow mPrimaryWindow;

	public this(GraphicsDevice graphicsDevice, IWindow primaryWindow)
	{
		mGraphicsDevice = graphicsDevice;
		mPrimaryWindow = primaryWindow;
	}

	protected override Result<void> OnInitializing(IContext context)
	{
		return base.OnInitializing(context);
	}

	protected override void OnUnitializing(IContext context)
	{
		base.OnUnitializing(context);
	}
}