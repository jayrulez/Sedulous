using Sedulous.Core;
using System;
using Sedulous.RHI;
using Sedulous.Platform;
namespace Sedulous.Graphics;

class GraphicsSubsystem : Subsystem
{
	public override StringView Name => "Graphics";

	private readonly GraphicsContext mGraphicsContext;
	private readonly IWindow mPrimaryWindow;

	public this(GraphicsContext graphicsContext, IWindow primaryWindow)
	{
		mGraphicsContext = graphicsContext;
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