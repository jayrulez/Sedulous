using System;
namespace Sedulous.Core.SceneGraph;

struct Entity : uint64, IHashable
{
	public const uint64 InvalidId = 0;

	public static operator uint64(Self self)
	{
		return (uint64)self;
	}

	public int GetHashCode()
	{
		return (int)(uint64)this;
	}
}