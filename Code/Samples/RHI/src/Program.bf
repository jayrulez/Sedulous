using Sedulous.Platform.Desktop;
using Sedulous.Foundation.Utilities;
using Sedulous.Platform;
using Sedulous.Core;
using System;
using Sedulous.RHI;
using Sedulous.RHI.Vulkan;
using static Sedulous.Core.IContext;
namespace RHI;

class RHIApplication
{
	private readonly UpdateFunctionInfo mUpdateFunctionInfo = .()
		{
			Priority = 1,
			Function = new  => Update,
			Stage = .FixedUpdate
		} ~ delete _.Function;

	private readonly VKGraphicsContext mGraphicsContext = new .() ~ delete _;

	private readonly IPlatformBackend mHost;

	public this(IPlatformBackend host)
	{
		mHost = host;
	}

	public Result<void> Initializing(ContextInitializer initializer)
	{
		return .Ok;
	}

	public void Initialized(IContext context)
	{
		context.RegisterUpdateFunction(mUpdateFunctionInfo);

		mHost.Windows.GetPrimary().Drawing.Subscribe(new (window, time) =>
			{
				Render();
			});
	}

	public void ShuttingDown(IContext context)
	{
		context.UnregisterUpdateFunction(mUpdateFunctionInfo);
	}

	private void Update(UpdateInfo info)
	{
		info.Context.Logger.LogInformation(scope $"{info.Time.ElapsedTime} : Application Update");

		if (mHost.Input.GetKeyboard().IsKeyPressed(.Escape))
		{
			mHost.Exit();
		}
	}

	private void Render()
	{

	}
}

class Program
{
	static void Main()
	{
		var host = scope DesktopPlatformBackend(.()
			{
				PrimaryWindowConfiguration = .()
					{
						Title = "RHI"
					}
			});

		var app = scope RHIApplication(host);

		host.Run(
			initializingCallback: scope => app.Initializing,
			initializedCallback: scope => app.Initialized,
			shuttingDownCallback: scope => app.ShuttingDown
			);
	}
}