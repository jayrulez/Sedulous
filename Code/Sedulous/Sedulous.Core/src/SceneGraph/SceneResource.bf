using Sedulous.Core.Resources;
using System;
using System.IO;
namespace Sedulous.Core.SceneGraph;

class SceneResource : Resource
{
}

class SceneResourceManager : ResourceManager<SceneResource>
{
	protected override Result<SceneResource, ResourceLoadError> LoadFromMemory(MemoryStream memory)
	{
		return default;
	}
}