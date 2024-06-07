using Sedulous.Core;
using System;
namespace Sedulous.Audio;

abstract class AudioSubsystem : Subsystem
{
	private readonly AudioClipResourceManager mAudioClipResourceManager = new .() ~ delete _;

	protected override Result<void> OnInitializing(IContext context)
	{
		context.ResourceSystem.AddResourceManager(mAudioClipResourceManager);

		return base.OnInitializing(context);
	}

	protected override void OnUnitializing(IContext context)
	{
		context.ResourceSystem.RemoveResourceManager(mAudioClipResourceManager);
		base.OnUnitializing(context);
	}
}