namespace NRI.Helpers;

struct TextureSubresourceUploadDesc
{
    public /*const*/ void* slices;
    public uint32 sliceNum;
    public uint32 rowPitch;
    public uint32 slicePitch;
}

struct TextureUploadDesc
{
    public /*const*/ TextureSubresourceUploadDesc* subresources;
    public Texture/***/ texture;
    public AccessBits nextAccess;
    public TextureLayout nextLayout;
    public uint16 mipNum;
    public uint16 arraySize;
}

struct BufferUploadDesc
{
    public /*const*/ void* data;
    public uint64 dataSize;
    public Buffer/***/ buffer;
    public uint64 bufferOffset;
    public AccessBits prevAccess;
    public AccessBits nextAccess;
}

struct ResourceGroupDesc
{
    public MemoryLocation memoryLocation;
    public Texture* /*const**/ textures;
    public uint32 textureNum;
    public Buffer* /*const**/ buffers;
    public uint32 bufferNum;
}