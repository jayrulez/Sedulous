using Sedulous.Platform.Desktop;
using Sedulous.Foundation.Utilities;
using Sedulous.Platform;
using Sedulous.Core;
using System;
using static Sedulous.Core.IContext;
namespace Sandbox;

class SandboxApplication
{
	private IContext.RegisteredUpdateFunctionInfo? mUpdateFunctionRegistration;

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
		mUpdateFunctionRegistration = context.RegisterUpdateFunction(.()
		{
			Priority = 1,
			Function = new  => Update,
			Stage = .FixedUpdate
		});
	}

	public void ShuttingDown(IContext context)
	{
		if(mUpdateFunctionRegistration.HasValue)
		{
			context.UnregisterUpdateFunction(mUpdateFunctionRegistration.Value);
			delete mUpdateFunctionRegistration.Value.Function;
			mUpdateFunctionRegistration = null;
		}
	}

	private void Update(UpdateInfo info)
	{
		info.Context.Logger.LogInformation(scope $"{info.Time.ElapsedTime} : Application Update");

		if(mHost.Input.GetKeyboard().IsKeyPressed(.Escape))
		{
			mHost.Exit();
		}
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
						Title = "Sandbox"
					}
			});
		/*
		host.Input.GetKeyboard().KeyPressed.Subscribe(new (window, kb, key, ctrl, alt, shift, @repeat) =>
			{
				if (key == .Escape)
					host.Exit();
			});
		*/

		var app = scope SandboxApplication(host);

		host.Run(
			initializingCallback: scope => app.Initializing,
			initializedCallback: scope => app.Initialized,
			shuttingDownCallback: scope => app.ShuttingDown
			);
	}
}