namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal struct NoAllocInsertDebugMarkerEntry
    {
        public Tracked<string> Name;

        public NoAllocInsertDebugMarkerEntry(Tracked<string> name)
        {
            Name = name;
        }
    }
}
