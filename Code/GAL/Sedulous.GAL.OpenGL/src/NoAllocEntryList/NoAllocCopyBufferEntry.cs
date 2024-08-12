namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocCopyBufferEntry
    {
        public readonly Tracked<DeviceBuffer> Source;
        public readonly uint32 SourceOffset;
        public readonly Tracked<DeviceBuffer> Destination;
        public readonly uint32 DestinationOffset;
        public readonly uint32 SizeInBytes;

        public NoAllocCopyBufferEntry(Tracked<DeviceBuffer> source, uint32 sourceOffset, Tracked<DeviceBuffer> destination, uint32 destinationOffset, uint32 sizeInBytes)
        {
            Source = source;
            SourceOffset = sourceOffset;
            Destination = destination;
            DestinationOffset = destinationOffset;
            SizeInBytes = sizeInBytes;
        }
    }
}