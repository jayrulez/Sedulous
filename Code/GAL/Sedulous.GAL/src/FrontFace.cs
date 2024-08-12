namespace Sedulous.GAL
{
    /// <summary>
    /// The winding order used to determine the front face of a primitive.
    /// </summary>
    public enum FrontFace : uint8
    {
        /// <summary>
        /// Clockwise winding order.
        /// </summary>
        Clockwise,
        /// <summary>
        /// Counter-clockwise winding order.
        /// </summary>
        CounterClockwise,
    }
}