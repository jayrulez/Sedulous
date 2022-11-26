using System;
namespace Sedulous.Core.Scenes;

typealias EntityId = uint64;

struct Entity : IHashable
{
	public const EntityId InvalidId = EntityId.MaxValue;

	public EntityId Id;

	public bool IsValid()
	{
		return Id != InvalidId;
	}

	public int GetHashCode()
	{
		return (.)Id;
	}
}