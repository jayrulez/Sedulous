using Sedulous.Core.Resources;
using System;
namespace Sedulous.Audio;

class AudioClipResource : Resource
{

}

class AudioClipResourceManager : ResourceManager<AudioClipResource>
{
	protected override Result<AudioClipResource, ResourceLoadError> LoadFromFile(StringView path)
	{
		return default;
	}

	protected override Result<AudioClipResource, ResourceLoadError> LoadFromMemory(Span<uint8> memory)
	{
		return default;
	}
}