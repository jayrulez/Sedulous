using Sedulous.Platform.Desktop;
using Sedulous.Foundation.Utilities;
using Sedulous.Platform;
using Sedulous.Core;
using static Sedulous.Core.IContext;
namespace Sandbox;

class SandboxApplication
{
	private readonly UpdateFunctionInfo mUpdateFunctionInfo = .()
		{
			Priority = 1,
			Function = new  => Update,
			Stage = .FixedUpdate
		} ~ delete _.Function;

	private readonly IPlatformBackend mHost;

	public this(IPlatformBackend host)
	{
		mHost = host;
		((IContextHost)mHost).Context.RegisterUpdateFunction(mUpdateFunctionInfo);
	}

	public void Update(UpdateInfo info)
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
						Title = "Sample"
					}
			});

		scope SandboxApplication(host);

		/*
		host.Input.GetKeyboard().KeyPressed.Subscribe(new (window, kb, key, ctrl, alt, shift, @repeat) =>
			{
				if (key == .Escape)
					host.Exit();
			});
		*/

		host.Run();
	}
}