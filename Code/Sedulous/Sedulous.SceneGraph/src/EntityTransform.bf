using Sedulous.Foundation.Mathematics;
namespace Sedulous.SceneGraph;

/// <summary>
/// Represents a 3D transformation, including position, rotation, and scale.
/// </summary>
/*public struct Transform
{
    public Vector3 Position { get; set mut; }
    public Quaternion Rotation { get; set mut; }
    public Vector3 Scale { get; set mut; }

    public this(Vector3 position, Quaternion rotation, Vector3 scale)
    {
        Position = position;
        Rotation = rotation;
        Scale = scale;
    }

    public void Apply(Transform parentTransform) mut
    {
        Position += parentTransform.Position;
        Rotation = parentTransform.Rotation * Rotation;
        Scale *= parentTransform.Scale;
    }

    public void Update(Transform update) mut
    {
        Position = update.Position;
        Rotation = update.Rotation;
        Scale = update.Scale;
    }
}*/