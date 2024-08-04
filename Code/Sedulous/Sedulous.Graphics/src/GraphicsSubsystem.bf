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

	private IContext.RegisteredUpdateFunctionInfo? mUpdateFunctionRegistration;
	private IContext.RegisteredUpdateFunctionInfo? mRenderFunctionRegistration;

	private CommandQueue mCommandQueue;
	private SwapChain mSwapChain;

	public this(GraphicsContext graphicsContext, IWindow primaryWindow)
	{
		mGraphicsContext = graphicsContext;
		mPrimaryWindow = primaryWindow;
	}

	protected override Result<void> OnInitializing(IContext context)
	{
		mUpdateFunctionRegistration = context.RegisterUpdateFunction(.()
		{
			Priority = 1,
			Stage = .VariableUpdate,
			Function = new => OnUpdate
		});

		mRenderFunctionRegistration = context.RegisterUpdateFunction(.()
		{
			Priority = 1,
			Stage = .PostUpdate,
			Function = new => OnRender
		});

		return base.OnInitializing(context);
	}

	protected override void OnUnitializing(IContext context)
	{
		if(mUpdateFunctionRegistration.HasValue)
		{
			context.UnregisterUpdateFunction(mUpdateFunctionRegistration.Value);
			delete mUpdateFunctionRegistration.Value.Function;
			mUpdateFunctionRegistration = null;
		}

		base.OnUnitializing(context);
	}

	private void OnUpdate(IContext.UpdateInfo info)
	{
		info.Context.Logger.LogInformation("System: {0}, Update", nameof(GraphicsSubsystem));
	}

	private void OnRender(IContext.UpdateInfo info)
	{
		info.Context.Logger.LogInformation("System: {0}, Render", nameof(GraphicsSubsystem));
	}
}