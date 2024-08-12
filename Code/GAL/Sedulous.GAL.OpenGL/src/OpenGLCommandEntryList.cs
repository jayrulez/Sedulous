using System;

namespace Sedulous.GAL.OpenGL
{
    internal interface OpenGLCommandEntryList
    {
        OpenGLCommandList Parent { get; }
        void Begin();
        void ClearColorTarget(uint32 index, RgbaFloat clearColor);
        void ClearDepthTarget(float depth, uint8 stencil);
        void Draw(uint32 vertexCount, uint32 instanceCount, uint32 vertexStart, uint32 instanceStart);
        void DrawIndexed(uint32 indexCount, uint32 instanceCount, uint32 indexStart, int32 vertexOffset, uint32 instanceStart);
        void DrawIndirect(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride);
        void DrawIndexedIndirect(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride);
        void Dispatch(uint32 groupCountX, uint32 groupCountY, uint32 groupCountZ);
        void End();
        void SetFramebuffer(Framebuffer fb);
        void SetIndexBuffer(DeviceBuffer buffer, IndexFormat format, uint32 offset);
        void SetPipeline(Pipeline pipeline);
        void SetGraphicsResourceSet(uint32 slot, ResourceSet rs, uint32 dynamicOffsetCount, ref uint32 dynamicOffsets);
        void SetComputeResourceSet(uint32 slot, ResourceSet rs, uint32 dynamicOffsetCount, ref uint32 dynamicOffsets);
        void SetScissorRect(uint32 index, uint32 x, uint32 y, uint32 width, uint32 height);
        void SetVertexBuffer(uint32 index, DeviceBuffer buffer, uint32 offset);
        void SetViewport(uint32 index, ref Viewport viewport);
        void ResolveTexture(Texture source, Texture destination);
        void UpdateBuffer(DeviceBuffer buffer, uint32 bufferOffsetInBytes, IntPtr source, uint32 sizeInBytes);
        void ExecuteAll(OpenGLCommandExecutor executor);
        void DispatchIndirect(DeviceBuffer indirectBuffer, uint32 offset);
        void CopyBuffer(DeviceBuffer source, uint32 sourceOffset, DeviceBuffer destination, uint32 destinationOffset, uint32 sizeInBytes);
        void CopyTexture(
            Texture source,
            uint32 srcX, uint32 srcY, uint32 srcZ,
            uint32 srcMipLevel,
            uint32 srcBaseArrayLayer,
            Texture destination,
            uint32 dstX, uint32 dstY, uint32 dstZ,
            uint32 dstMipLevel,
            uint32 dstBaseArrayLayer,
            uint32 width, uint32 height, uint32 depth,
            uint32 layerCount);

        void GenerateMipmaps(Texture texture);
        void PushDebugGroup(string name);
        void PopDebugGroup();
        void InsertDebugMarker(string name);

        void Reset();
        void Dispose();
    }
}
