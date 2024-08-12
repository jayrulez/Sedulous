using System;
using System.Collections.Generic;
using System.Diagnostics;
using Sedulous.GAL.OpenGL.NoAllocEntryList;

namespace Sedulous.GAL.OpenGL
{
    internal class OpenGLCommandList : CommandList
    {
        private readonly OpenGLGraphicsDevice _gd;
        private OpenGLCommandEntryList _currentCommands;
        private bool _disposed;

        internal OpenGLCommandEntryList CurrentCommands => _currentCommands;
        internal OpenGLGraphicsDevice Device => _gd;

        private readonly object _lock = new object();
        private readonly List<OpenGLCommandEntryList> _availableLists = new List<OpenGLCommandEntryList>();
        private readonly List<OpenGLCommandEntryList> _submittedLists = new List<OpenGLCommandEntryList>();

        public override string Name { get; set; }

        public override bool IsDisposed => _disposed;

        public OpenGLCommandList(OpenGLGraphicsDevice gd, ref CommandListDescription description)
            : base(ref description, gd.Features, gd.UniformBufferMinOffsetAlignment, gd.StructuredBufferMinOffsetAlignment)
        {
            _gd = gd;
        }

        public override void Begin()
        {
            ClearCachedState();
            if (_currentCommands != null)
            {
                _currentCommands.Dispose();
            }

            _currentCommands = GetFreeCommandList();
            _currentCommands.Begin();
        }

        private OpenGLCommandEntryList GetFreeCommandList()
        {
            lock (_lock)
            {
                if (_availableLists.Count > 0)
                {
                    OpenGLCommandEntryList ret = _availableLists[_availableLists.Count - 1];
                    _availableLists.RemoveAt(_availableLists.Count - 1);
                    return ret;
                }
                else
                {
                    return new OpenGLNoAllocCommandEntryList(this);
                }
            }
        }

        private protected override void ClearColorTargetCore(uint32 index, RgbaFloat clearColor)
        {
            _currentCommands.ClearColorTarget(index, clearColor);
        }

        private protected override void ClearDepthStencilCore(float depth, uint8 stencil)
        {
            _currentCommands.ClearDepthTarget(depth, stencil);
        }

        private protected override void DrawCore(uint32 vertexCount, uint32 instanceCount, uint32 vertexStart, uint32 instanceStart)
        {
            _currentCommands.Draw(vertexCount, instanceCount, vertexStart, instanceStart);
        }

        private protected override void DrawIndexedCore(uint32 indexCount, uint32 instanceCount, uint32 indexStart, int32 vertexOffset, uint32 instanceStart)
        {
            _currentCommands.DrawIndexed(indexCount, instanceCount, indexStart, vertexOffset, instanceStart);
        }

        protected override void DrawIndirectCore(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            _currentCommands.DrawIndirect(indirectBuffer, offset, drawCount, stride);
        }

        protected override void DrawIndexedIndirectCore(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            _currentCommands.DrawIndexedIndirect(indirectBuffer, offset, drawCount, stride);
        }

        public override void Dispatch(uint32 groupCountX, uint32 groupCountY, uint32 groupCountZ)
        {
            _currentCommands.Dispatch(groupCountX, groupCountY, groupCountZ);
        }

        protected override void DispatchIndirectCore(DeviceBuffer indirectBuffer, uint32 offset)
        {
            _currentCommands.DispatchIndirect(indirectBuffer, offset);
        }

        protected override void ResolveTextureCore(Texture source, Texture destination)
        {
            _currentCommands.ResolveTexture(source, destination);
        }

        public override void End()
        {
            _currentCommands.End();
        }

        protected override void SetFramebufferCore(Framebuffer fb)
        {
            _currentCommands.SetFramebuffer(fb);
        }

        private protected override void SetIndexBufferCore(DeviceBuffer buffer, IndexFormat format, uint32 offset)
        {
            _currentCommands.SetIndexBuffer(buffer, format, offset);
        }

        private protected override void SetPipelineCore(Pipeline pipeline)
        {
            _currentCommands.SetPipeline(pipeline);
        }

        protected override void SetGraphicsResourceSetCore(uint32 slot, ResourceSet rs, uint32 dynamicOffsetCount, ref uint32 dynamicOffsets)
        {
            _currentCommands.SetGraphicsResourceSet(slot, rs, dynamicOffsetCount, ref dynamicOffsets);
        }

        protected override void SetComputeResourceSetCore(uint32 slot, ResourceSet rs, uint32 dynamicOffsetCount, ref uint32 dynamicOffsets)
        {
            _currentCommands.SetComputeResourceSet(slot, rs, dynamicOffsetCount, ref dynamicOffsets);
        }

        public override void SetScissorRect(uint32 index, uint32 x, uint32 y, uint32 width, uint32 height)
        {
            _currentCommands.SetScissorRect(index, x, y, width, height);
        }

        private protected override void SetVertexBufferCore(uint32 index, DeviceBuffer buffer, uint32 offset)
        {
            _currentCommands.SetVertexBuffer(index, buffer, offset);
        }

        public override void SetViewport(uint32 index, ref Viewport viewport)
        {
            _currentCommands.SetViewport(index, ref viewport);
        }

        internal void Reset()
        {
            _currentCommands.Reset();
        }

        private protected override void UpdateBufferCore(DeviceBuffer buffer, uint32 bufferOffsetInBytes, IntPtr source, uint32 sizeInBytes)
        {
            _currentCommands.UpdateBuffer(buffer, bufferOffsetInBytes, source, sizeInBytes);
        }

        protected override void CopyBufferCore(
            DeviceBuffer source,
            uint32 sourceOffset,
            DeviceBuffer destination,
            uint32 destinationOffset,
            uint32 sizeInBytes)
        {
            _currentCommands.CopyBuffer(source, sourceOffset, destination, destinationOffset, sizeInBytes);
        }

        protected override void CopyTextureCore(
            Texture source,
            uint32 srcX, uint32 srcY, uint32 srcZ,
            uint32 srcMipLevel,
            uint32 srcBaseArrayLayer,
            Texture destination,
            uint32 dstX, uint32 dstY, uint32 dstZ,
            uint32 dstMipLevel,
            uint32 dstBaseArrayLayer,
            uint32 width, uint32 height, uint32 depth,
            uint32 layerCount)
        {
            _currentCommands.CopyTexture(
                source,
                srcX, srcY, srcZ,
                srcMipLevel,
                srcBaseArrayLayer,
                destination,
                dstX, dstY, dstZ,
                dstMipLevel,
                dstBaseArrayLayer,
                width, height, depth,
                layerCount);
        }

        private protected override void GenerateMipmapsCore(Texture texture)
        {
            _currentCommands.GenerateMipmaps(texture);
        }

        public void OnSubmitted(OpenGLCommandEntryList entryList)
        {
            _currentCommands = null;
            lock (_lock)
            {
                Debug.Assert(!_submittedLists.Contains(entryList));
                _submittedLists.Add(entryList);

                Debug.Assert(!_availableLists.Contains(entryList));
            }
        }

        public void OnCompleted(OpenGLCommandEntryList entryList)
        {
            lock (_lock)
            {
                entryList.Reset();

                Debug.Assert(!_availableLists.Contains(entryList));
                _availableLists.Add(entryList);

                Debug.Assert(_submittedLists.Contains(entryList));
                _submittedLists.Remove(entryList);
            }
        }

        private protected override void PushDebugGroupCore(string name)
        {
            _currentCommands.PushDebugGroup(name);
        }

        private protected override void PopDebugGroupCore()
        {
            _currentCommands.PopDebugGroup();
        }

        private protected override void InsertDebugMarkerCore(string name)
        {
            _currentCommands.InsertDebugMarker(name);
        }

        public override void Dispose()
        {
            _gd.EnqueueDisposal(this);
        }

        public void DestroyResources()
        {
            lock (_lock)
            {
                _currentCommands?.Dispose();
                for (OpenGLCommandEntryList list in _availableLists)
                {
                    list.Dispose();
                }
                for (OpenGLCommandEntryList list in _submittedLists)
                {
                    list.Dispose();
                }

                _disposed = true;
            }
        }
    }
}
