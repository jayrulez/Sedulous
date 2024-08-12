namespace Veldrid
{
    /// <summary>
    /// A structure describing the format expected by indirect dispatch commands contained in an indirect <see cref="DeviceBuffer"/>.
    /// </summary>
    public struct IndirectDispatchArguments
    {
        /// <summary>
        /// The X group count, as if passed to the <see cref="CommandList.Dispatch(uint32, uint32, uint32)"/> method.
        /// </summary>
        public uint32 GroupCountX;
        /// <summary>
        /// The Y group count, as if passed to the <see cref="CommandList.Dispatch(uint32, uint32, uint32)"/> method.
        /// </summary>
        public uint32 GroupCountY;
        /// <summary>
        /// The Z group count, as if passed to the <see cref="CommandList.Dispatch(uint32, uint32, uint32)"/> method.
        /// </summary>
        public uint32 GroupCountZ;
    }
}
