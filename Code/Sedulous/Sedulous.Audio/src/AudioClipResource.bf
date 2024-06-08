using Sedulous.Core.Resources;
using System;
using System.IO;
using System.Collections;
namespace Sedulous.Audio;

[CRepr]
struct AudioClipResourceHeader : ResourceHeader
{

}

enum AudioFormat : uint8
{
	PCM,
	Vorbis
}

class AudioClipResource : Resource
{
	public const ResourceTypeId ResourceTypeId = .('s','a','u','d');

	private uint32 mSamplesCount;
	private uint32 mStreamSize;
	private uint32 mStreamOffset;
	private float mLength;
	private List<uint8> mDataBuffer;
}

class AudioClipResourceManager : ResourceManager<AudioClipResource>
{
	private readonly AudioSubsystem mAudioSubsystem;

	public this(AudioSubsystem audioSubsystem)
	{
		mAudioSubsystem = audioSubsystem;
	}

	protected override Result<AudioClipResource, ResourceLoadError> LoadFromMemory(MemoryStream stream)
	{
		/*var headerResult = stream.Read<AudioClipResourceHeader>();
		if(headerResult case .Err)
		{
			return .Err(.Unknown);
		}

		var header = headerResult.Value;

		if(!header.CheckType(AudioClipResource.ResourceTypeId))
			return .Err(.UnexpectedType);*/

		return LoadAudio(stream);
	}

	private Result<AudioClipResource, ResourceLoadError> LoadAudio(MemoryStream stream)
	{
		return .Err(.NotSupported);
	}
}