using System;
using System.Collections;
using System.IO;
namespace Sedulous.Core.Resources;

abstract class ResourceManager
{
	public abstract Type ResourceType { get; }

	public abstract Result<Resource, ResourceLoadError> Load(StringView path);

	public abstract Result<Resource, ResourceLoadError> Load(MemoryStream stream);
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

	public override Result<Resource, ResourceLoadError> Load(MemoryStream stream)
	{
		var result = LoadFromMemory(stream);
		if (result case .Err(let error))
			return .Err(error);
		return .Ok(result.Value);
	}

	protected virtual Result<void, FileOpenError> ReadFile(StringView path, List<uint8> buffer)
	{
		var stream = scope UnbufferedFileStream();

		var fileOpenResult = stream.Open(path, .Read);
		if (fileOpenResult case .Err(let error))
		{
			return .Err(error);
		}

		var memory = scope List<uint8>() { Count = stream.Length };
		var readResult = stream.TryRead(memory);
		if (readResult case .Err)
			return .Err(.Unknown);

		buffer.AddRange(memory);
		return .Ok;
	}

	protected virtual Result<T, ResourceLoadError> LoadFromFile(StringView path)
	{
		var memory = scope List<uint8>();
		var readFile = ReadFile(path, memory);
		if (readFile case .Err(let error))
		{
			switch (error)
			{
			case .NotFound:
				return .Err(.NotFound);

			default:
				return .Err(.Unknown);
			}
		}

		return LoadFromMemory(scope MemoryStream(memory, false));
	}

	protected abstract Result<T, ResourceLoadError> LoadFromMemory(MemoryStream memory);
}