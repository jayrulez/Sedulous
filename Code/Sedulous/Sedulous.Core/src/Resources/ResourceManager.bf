using System;
using System.Collections;
namespace Sedulous.Core.Resources;

abstract class ResourceManager
{
	public abstract Type ResourceType { get; }

	public abstract Result<Resource, ResourceLoadError> Load(StringView path);

	public abstract Result<Resource, ResourceLoadError> Load(List<uint8> memory);
}

public abstract class ResourceManager<T> : ResourceManager where T : Resource
{
	public override Type ResourceType => typeof(T);

	public override Result<Resource, ResourceLoadError> Load(StringView path)
	{
		var result = LoadFromFile(path);
		if (result case .Err(let error))
			return .Err(error);
		return .Ok(result.Value);
	}

	public override Result<Resource, ResourceLoadError> Load(List<uint8> memory)
	{
		var result = LoadFromMemory(memory);
		if (result case .Err(let error))
			return .Err(error);
		return .Ok(result.Value);
	}

	protected abstract Result<T, ResourceLoadError> LoadFromFile(StringView path);

	protected abstract Result<T, ResourceLoadError> LoadFromMemory(Span<uint8> memory);
}