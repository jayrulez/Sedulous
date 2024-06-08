using Sedulous.Platform.Desktop;
using Sedulous.Foundation.Utilities;
using Sedulous.Platform;
using Sedulous.Core;
using Sedulous.Audio.OpenAL;
using Sedulous.Audio;
using System;
using static Sedulous.Core.IContext;
namespace Audio;

class AudioApplication
{
	private readonly UpdateFunctionInfo mUpdateFunctionInfo = .()
		{
			Priority = 1,
			Function = new  => Update,
			Stage = .FixedUpdate
		} ~ delete _.Function;

	private readonly OpenALAudioSubsystem mAudio = new .() ~ delete _;

	private readonly IPlatformBackend mHost;

	public this(IPlatformBackend host)
	{
		mHost = host;
	}

	public Result<void> Initializing(ContextInitializer initializer)
	{
		initializer.AddSubsystem(mAudio);
		return .Ok;
	}

	public void Initialized(IContext context)
	{
		context.RegisterUpdateFunction(mUpdateFunctionInfo);
		var resourceSystem = context.ResourceSystem;

		if (((Context)context).GetSubsystem<AudioSubsystem>() case .Ok(let audioSubsystem))
		{
			/*var loadAudio = resourceSystem.LoadResource<AudioClipResource>("Assets/sample.wav");
			if (loadAudio case .Err(let error))
			{
				context.Logger.LogError(scope $"Failed to load audio clip: '{error}'.");
				return;
			}

			audioSubsystem.Play(loadAudio.Value);*/

			resourceSystem.LoadResourceAsync<AudioClipResource>("Assets/sample.wav", onCompleted: new (loadAudio) =>
				{
					if (loadAudio case .Err(let error))
					{
						context.Logger.LogError(scope $"Failed to load audio clip: '{error}'.");
						return;
					}

					audioSubsystem.Play(loadAudio.Value);
				});
		}
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
}

class Program
{
	static void Main()
	{
		var host = scope DesktopPlatformBackend(.()
			{
				PrimaryWindowConfiguration = .()
					{
						Title = "Audio"
					}
			});

		var app = scope AudioApplication(host);

		host.Run(
			initializingCallback: scope => app.Initializing,
			initializedCallback: scope => app.Initialized,
			shuttingDownCallback: scope => app.ShuttingDown
			);
	}
}