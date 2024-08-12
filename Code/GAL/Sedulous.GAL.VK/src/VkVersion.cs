namespace Sedulous.GAL.VK
{
    internal struct VkVersion
    {
        private readonly uint32 value;

        public VkVersion(uint32 major, uint32 minor, uint32 patch)
        {
            value = major << 22 | minor << 12 | patch;
        }

        public uint32 Major => value >> 22;

        public uint32 Minor => (value >> 12) & 0x3ff;

        public uint32 Patch => (value >> 22) & 0xfff;

        public static implicit operator uint32(VkVersion version)
        {
            return version.value;
        }
    }
}
