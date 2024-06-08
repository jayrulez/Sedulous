using Sedulous.Core;
using System;
namespace Sedulous.Audio;

abstract class AudioSubsystem : Subsystem
{
	private readonly AudioClipResourceManager mAudioClipResourceManager = new .(this) ~ delete _;

	public override StringView Name => "Audio";

	private IContext mContext;

	public this()
	{
	}

	protected override Result<void> OnInitializing(IContext context)
	{
		mContext = context;
		context.ResourceSystem.AddResourceManager(mAudioClipResourceManager);

		return base.OnInitializing(context);
	}

	protected override void OnUnitializing(IContext context)
	{
		context.ResourceSystem.RemoveResourceManager(mAudioClipResourceManager);
		base.OnUnitializing(context);
	}

	public void Play(AudioClipResource clip, float volume = 1.0f)
	{
		mContext.Logger.LogInformation("Playing clip: '{0}'", "");
	}
}