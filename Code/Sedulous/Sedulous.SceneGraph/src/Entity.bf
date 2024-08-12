using System;
namespace Sedulous.SceneGraph;

/*struct Entity : uint64, IHashable
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
}*/

/// <summary>
/// Represents an entity with a unique identifier and version.
/// </summary>
/*public struct Entity : IEquatable<Entity>, IHashable
{
    public int Id { get; }
    public int Version { get; }

    public this(int id, int version)
    {
        Id = id;
        Version = version;
    }

    public bool Equals(Entity other)
    {
        return Id == other.Id && Version == other.Version;
    }

    public int GetHashCode()
    {
        return HashCode.Mix(Id, Version);
    }

    public static bool operator ==(Entity left, Entity right)
    {
        return left.Equals(right);
    }

    public static bool operator !=(Entity left, Entity right)
    {
        return !(left == right);
    }
}*/