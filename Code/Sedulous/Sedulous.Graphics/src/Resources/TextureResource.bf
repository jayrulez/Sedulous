using Sedulous.Core.Resources;
using System;
using System.IO;
namespace Sedulous.Graphics.Resources;

[CRepr]
struct TextureResourceHeader : ResourceHeader
{
}

class TextureResource : Resource
{
	public const ResourceTypeId ResourceTypeId = .('s', 't', 'e', 'x');
}

class TextureResourceManager : ResourceManager<TextureResource>
{
	protected override Result<TextureResource, ResourceLoadError> LoadFromMemory(MemoryStream stream)
	{
		var headerResult = stream.Read<TextureResourceHeader>();
		if (headerResult case .Err)
		{
			return .Err(.Unknown);
		}

		if (!headerResult.Value.CheckType(TextureResource.ResourceTypeId))
			return .Err(.UnexpectedType);

		return LoadTexture(stream);
	}

	private Result<TextureResource, ResourceLoadError> LoadTexture(MemoryStream memoryStream)
	{
		return .Err(.Unknown);
	}
}