using Sedulous.Core.Resources;
using System;
using System.IO;
namespace Sedulous.Graphics.Resources;

[CRepr]
struct ShaderResourceHeader : ResourceHeader
{
}

class ShaderResource : Resource
{
	public const ResourceTypeId ResourceTypeId = .('s', 's', 'h', 'd');
}

class ShaderResourceManager : ResourceManager<ShaderResource>
{
	protected override Result<ShaderResource, ResourceLoadError> LoadFromMemory(MemoryStream stream)
	{
		var headerResult = stream.Read<ShaderResourceHeader>();
		if (headerResult case .Err)
		{
			return .Err(.Unknown);
		}

		if (!headerResult.Value.CheckType(ShaderResource.ResourceTypeId))
			return .Err(.UnexpectedType);

		return LoadShader(stream);
	}

	private Result<ShaderResource, ResourceLoadError> LoadShader(MemoryStream memoryStream)
	{
		return .Err(.Unknown);
	}
}