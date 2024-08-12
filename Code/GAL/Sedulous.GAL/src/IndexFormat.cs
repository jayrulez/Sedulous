namespace Sedulous.GAL
{
    /// <summary>
    /// The format of index data used in a <see cref="DeviceBuffer"/>.
    /// </summary>
    public enum IndexFormat : uint8
    {
        /// <summary>
        /// Each index is a 16-bit unsigned integer (System.UInt16).
        /// </summary>
        UInt16,
        /// <summary>
        /// Each index is a 32-bit unsigned integer (System.UInt32).
        /// </summary>
        UInt32,
    }
}