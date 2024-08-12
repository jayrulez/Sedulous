using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

namespace Sedulous.GAL.OpenGL.NoAllocEntryList
{
    internal class OpenGLNoAllocCommandEntryList : OpenGLCommandEntryList, IDisposable
    {
        private readonly StagingMemoryPool _memoryPool;
        private readonly List<EntryStorageBlock> _blocks = new List<EntryStorageBlock>();
        private EntryStorageBlock _currentBlock;
        private uint32 _totalEntries;
        private readonly List<object> _resourceList = new List<object>();
        private readonly List<StagingBlock> _stagingBlocks = new List<StagingBlock>();

        // Entry IDs
        private const uint8 BeginEntryID = 1;
        private static readonly uint32 BeginEntrySize = Util.USizeOf<NoAllocBeginEntry>();

        private const uint8 ClearColorTargetID = 2;
        private static readonly uint32 ClearColorTargetEntrySize = Util.USizeOf<NoAllocClearColorTargetEntry>();

        private const uint8 ClearDepthTargetID = 3;
        private static readonly uint32 ClearDepthTargetEntrySize = Util.USizeOf<NoAllocClearDepthTargetEntry>();

        private const uint8 DrawIndexedEntryID = 4;
        private static readonly uint32 DrawIndexedEntrySize = Util.USizeOf<NoAllocDrawIndexedEntry>();

        private const uint8 EndEntryID = 5;
        private static readonly uint32 EndEntrySize = Util.USizeOf<NoAllocEndEntry>();

        private const uint8 SetFramebufferEntryID = 6;
        private static readonly uint32 SetFramebufferEntrySize = Util.USizeOf<NoAllocSetFramebufferEntry>();

        private const uint8 SetIndexBufferEntryID = 7;
        private static readonly uint32 SetIndexBufferEntrySize = Util.USizeOf<NoAllocSetIndexBufferEntry>();

        private const uint8 SetPipelineEntryID = 8;
        private static readonly uint32 SetPipelineEntrySize = Util.USizeOf<NoAllocSetPipelineEntry>();

        private const uint8 SetResourceSetEntryID = 9;
        private static readonly uint32 SetResourceSetEntrySize = Util.USizeOf<NoAllocSetResourceSetEntry>();

        private const uint8 SetScissorRectEntryID = 10;
        private static readonly uint32 SetScissorRectEntrySize = Util.USizeOf<NoAllocSetScissorRectEntry>();

        private const uint8 SetVertexBufferEntryID = 11;
        private static readonly uint32 SetVertexBufferEntrySize = Util.USizeOf<NoAllocSetVertexBufferEntry>();

        private const uint8 SetViewportEntryID = 12;
        private static readonly uint32 SetViewportEntrySize = Util.USizeOf<NoAllocSetViewportEntry>();

        private const uint8 UpdateBufferEntryID = 13;
        private static readonly uint32 UpdateBufferEntrySize = Util.USizeOf<NoAllocUpdateBufferEntry>();

        private const uint8 CopyBufferEntryID = 14;
        private static readonly uint32 CopyBufferEntrySize = Util.USizeOf<NoAllocCopyBufferEntry>();

        private const uint8 CopyTextureEntryID = 15;
        private static readonly uint32 CopyTextureEntrySize = Util.USizeOf<NoAllocCopyTextureEntry>();

        private const uint8 ResolveTextureEntryID = 16;
        private static readonly uint32 ResolveTextureEntrySize = Util.USizeOf<NoAllocResolveTextureEntry>();

        private const uint8 DrawEntryID = 17;
        private static readonly uint32 DrawEntrySize = Util.USizeOf<NoAllocDrawEntry>();

        private const uint8 DispatchEntryID = 18;
        private static readonly uint32 DispatchEntrySize = Util.USizeOf<NoAllocDispatchEntry>();

        private const uint8 DrawIndirectEntryID = 20;
        private static readonly uint32 DrawIndirectEntrySize = Util.USizeOf<NoAllocDrawIndirectEntry>();

        private const uint8 DrawIndexedIndirectEntryID = 21;
        private static readonly uint32 DrawIndexedIndirectEntrySize = Util.USizeOf<NoAllocDrawIndexedIndirectEntry>();

        private const uint8 DispatchIndirectEntryID = 22;
        private static readonly uint32 DispatchIndirectEntrySize = Util.USizeOf<NoAllocDispatchIndirectEntry>();

        private const uint8 GenerateMipmapsEntryID = 23;
        private static readonly uint32 GenerateMipmapsEntrySize = Util.USizeOf<NoAllocGenerateMipmapsEntry>();

        private const uint8 PushDebugGroupEntryID = 24;
        private static readonly uint32 PushDebugGroupEntrySize = Util.USizeOf<NoAllocPushDebugGroupEntry>();

        private const uint8 PopDebugGroupEntryID = 25;
        private static readonly uint32 PopDebugGroupEntrySize = Util.USizeOf<NoAllocPopDebugGroupEntry>();

        private const uint8 InsertDebugMarkerEntryID = 26;
        private static readonly uint32 InsertDebugMarkerEntrySize = Util.USizeOf<NoAllocInsertDebugMarkerEntry>();

        public OpenGLCommandList Parent { get; }

        public OpenGLNoAllocCommandEntryList(OpenGLCommandList cl)
        {
            Parent = cl;
            _memoryPool = cl.Device.StagingMemoryPool;
            _currentBlock = EntryStorageBlock.New();
            _blocks.Add(_currentBlock);
        }

        public void Reset()
        {
            FlushStagingBlocks();
            _resourceList.Clear();
            _totalEntries = 0;
            _currentBlock = _blocks[0];
            for (EntryStorageBlock block in _blocks)
            {
                block.Clear();
            }
        }

        public void Dispose()
        {
            FlushStagingBlocks();
            _resourceList.Clear();
            _totalEntries = 0;
            _currentBlock = _blocks[0];
            for (EntryStorageBlock block in _blocks)
            {
                block.Clear();
                block.Free();
            }
        }

        private void FlushStagingBlocks()
        {
            StagingMemoryPool pool = _memoryPool;
            for (StagingBlock block in _stagingBlocks)
            {
                pool.Free(block);
            }

            _stagingBlocks.Clear();
        }

        public void* GetStorageChunk(uint32 size, out uint8* terminatorWritePtr)
        {
            terminatorWritePtr = null;
            if (!_currentBlock.Alloc(size, out void* ptr))
            {
                int32 currentBlockIndex = _blocks.IndexOf(_currentBlock);
                bool anyWorked = false;
                for (int32 i = currentBlockIndex + 1; i < _blocks.Count; i++)
                {
                    EntryStorageBlock nextBlock = _blocks[i];
                    if (nextBlock.Alloc(size, out ptr))
                    {
                        _currentBlock = nextBlock;
                        anyWorked = true;
                        break;
                    }
                }

                if (!anyWorked)
                {
                    _currentBlock = EntryStorageBlock.New();
                    _blocks.Add(_currentBlock);
                    bool result = _currentBlock.Alloc(size, out ptr);
                    Debug.Assert(result);
                }
            }
            if (_currentBlock.RemainingSize > size)
            {
                terminatorWritePtr = (uint8*)ptr + size;
            }

            return ptr;
        }

        public void AddEntry<T>(uint8 id, ref T entry) where T : struct
        {
            uint32 size = Util.USizeOf<T>();
            AddEntry(id, size, ref entry);
        }

        public void AddEntry<T>(uint8 id, uint32 sizeOfT, ref T entry) where T : struct
        {
            Debug.Assert(sizeOfT == Unsafe.SizeOf<T>());
            uint32 storageSize = sizeOfT + 1; // Include ID
            void* storagePtr = GetStorageChunk(storageSize, out uint8* terminatorWritePtr);
            Unsafe.Write(storagePtr, id);
            Unsafe.Write((uint8*)storagePtr + 1, entry);
            if (terminatorWritePtr != null)
            {
                *terminatorWritePtr = 0;
            }
            _totalEntries += 1;
        }

        public void ExecuteAll(OpenGLCommandExecutor executor)
        {
            int32 currentBlockIndex = 0;
            EntryStorageBlock block = _blocks[currentBlockIndex];
            uint32 currentOffset = 0;
            for (uint32 i = 0; i < _totalEntries; i++)
            {
                if (currentOffset == block.TotalSize)
                {
                    currentBlockIndex += 1;
                    block = _blocks[currentBlockIndex];
                    currentOffset = 0;
                }

                uint32 id = Unsafe.Read<uint8>(block.BasePtr + currentOffset);
                if (id == 0)
                {
                    currentBlockIndex += 1;
                    block = _blocks[currentBlockIndex];
                    currentOffset = 0;
                    id = Unsafe.Read<uint8>(block.BasePtr + currentOffset);
                }

                Debug.Assert(id != 0);
                currentOffset += 1;
                uint8* entryBasePtr = block.BasePtr + currentOffset;
                switch (id)
                {
                    case BeginEntryID:
                        executor.Begin();
                        currentOffset += BeginEntrySize;
                        break;
                    case ClearColorTargetID:
                        NoAllocClearColorTargetEntry ccte = Unsafe.ReadUnaligned<NoAllocClearColorTargetEntry>(entryBasePtr);
                        executor.ClearColorTarget(ccte.Index, ccte.ClearColor);
                        currentOffset += ClearColorTargetEntrySize;
                        break;
                    case ClearDepthTargetID:
                        NoAllocClearDepthTargetEntry cdte = Unsafe.ReadUnaligned<NoAllocClearDepthTargetEntry>(entryBasePtr);
                        executor.ClearDepthStencil(cdte.Depth, cdte.Stencil);
                        currentOffset += ClearDepthTargetEntrySize;
                        break;
                    case DrawEntryID:
                        NoAllocDrawEntry de = Unsafe.ReadUnaligned<NoAllocDrawEntry>(entryBasePtr);
                        executor.Draw(de.VertexCount, de.InstanceCount, de.VertexStart, de.InstanceStart);
                        currentOffset += DrawEntrySize;
                        break;
                    case DrawIndexedEntryID:
                        NoAllocDrawIndexedEntry die = Unsafe.ReadUnaligned<NoAllocDrawIndexedEntry>(entryBasePtr);
                        executor.DrawIndexed(die.IndexCount, die.InstanceCount, die.IndexStart, die.VertexOffset, die.InstanceStart);
                        currentOffset += DrawIndexedEntrySize;
                        break;
                    case DrawIndirectEntryID:
                        NoAllocDrawIndirectEntry drawIndirectEntry = Unsafe.ReadUnaligned<NoAllocDrawIndirectEntry>(entryBasePtr);
                        executor.DrawIndirect(
                            drawIndirectEntry.IndirectBuffer.Get(_resourceList),
                            drawIndirectEntry.Offset,
                            drawIndirectEntry.DrawCount,
                            drawIndirectEntry.Stride);
                        currentOffset += DrawIndirectEntrySize;
                        break;
                    case DrawIndexedIndirectEntryID:
                        NoAllocDrawIndexedIndirectEntry diie = Unsafe.ReadUnaligned<NoAllocDrawIndexedIndirectEntry>(entryBasePtr);
                        executor.DrawIndexedIndirect(diie.IndirectBuffer.Get(_resourceList), diie.Offset, diie.DrawCount, diie.Stride);
                        currentOffset += DrawIndexedIndirectEntrySize;
                        break;
                    case DispatchEntryID:
                        NoAllocDispatchEntry dispatchEntry = Unsafe.ReadUnaligned<NoAllocDispatchEntry>(entryBasePtr);
                        executor.Dispatch(dispatchEntry.GroupCountX, dispatchEntry.GroupCountY, dispatchEntry.GroupCountZ);
                        currentOffset += DispatchEntrySize;
                        break;
                    case DispatchIndirectEntryID:
                        NoAllocDispatchIndirectEntry dispatchIndir = Unsafe.ReadUnaligned<NoAllocDispatchIndirectEntry>(entryBasePtr);
                        executor.DispatchIndirect(dispatchIndir.IndirectBuffer.Get(_resourceList), dispatchIndir.Offset);
                        currentOffset += DispatchIndirectEntrySize;
                        break;
                    case EndEntryID:
                        executor.End();
                        currentOffset += EndEntrySize;
                        break;
                    case SetFramebufferEntryID:
                        NoAllocSetFramebufferEntry sfbe = Unsafe.ReadUnaligned<NoAllocSetFramebufferEntry>(entryBasePtr);
                        executor.SetFramebuffer(sfbe.Framebuffer.Get(_resourceList));
                        currentOffset += SetFramebufferEntrySize;
                        break;
                    case SetIndexBufferEntryID:
                        NoAllocSetIndexBufferEntry sibe = Unsafe.ReadUnaligned<NoAllocSetIndexBufferEntry>(entryBasePtr);
                        executor.SetIndexBuffer(sibe.Buffer.Get(_resourceList), sibe.Format, sibe.Offset);
                        currentOffset += SetIndexBufferEntrySize;
                        break;
                    case SetPipelineEntryID:
                        NoAllocSetPipelineEntry spe = Unsafe.ReadUnaligned<NoAllocSetPipelineEntry>(entryBasePtr);
                        executor.SetPipeline(spe.Pipeline.Get(_resourceList));
                        currentOffset += SetPipelineEntrySize;
                        break;
                    case SetResourceSetEntryID:
                        NoAllocSetResourceSetEntry srse = Unsafe.ReadUnaligned<NoAllocSetResourceSetEntry>(entryBasePtr);
                        ResourceSet rs = srse.ResourceSet.Get(_resourceList);
                        uint32* dynamicOffsetsPtr = srse.DynamicOffsetCount > NoAllocSetResourceSetEntry.MaxInlineDynamicOffsets
                            ? (uint32*)srse.DynamicOffsets_Block.Data
                            : srse.DynamicOffsets_Inline;
                        if (srse.IsGraphics)
                        {
                            executor.SetGraphicsResourceSet(
                                srse.Slot,
                                rs,
                                srse.DynamicOffsetCount,
                                ref Unsafe.AsRef<uint32>(dynamicOffsetsPtr));
                        }
                        else
                        {
                            executor.SetComputeResourceSet(
                                srse.Slot,
                                rs,
                                srse.DynamicOffsetCount,
                                ref Unsafe.AsRef<uint32>(dynamicOffsetsPtr));
                        }
                        currentOffset += SetResourceSetEntrySize;
                        break;
                    case SetScissorRectEntryID:
                        NoAllocSetScissorRectEntry ssre = Unsafe.ReadUnaligned<NoAllocSetScissorRectEntry>(entryBasePtr);
                        executor.SetScissorRect(ssre.Index, ssre.X, ssre.Y, ssre.Width, ssre.Height);
                        currentOffset += SetScissorRectEntrySize;
                        break;
                    case SetVertexBufferEntryID:
                        NoAllocSetVertexBufferEntry svbe = Unsafe.ReadUnaligned<NoAllocSetVertexBufferEntry>(entryBasePtr);
                        executor.SetVertexBuffer(svbe.Index, svbe.Buffer.Get(_resourceList), svbe.Offset);
                        currentOffset += SetVertexBufferEntrySize;
                        break;
                    case SetViewportEntryID:
                        NoAllocSetViewportEntry svpe = Unsafe.ReadUnaligned<NoAllocSetViewportEntry>(entryBasePtr);
                        executor.SetViewport(svpe.Index, ref svpe.Viewport);
                        currentOffset += SetViewportEntrySize;
                        break;
                    case UpdateBufferEntryID:
                        NoAllocUpdateBufferEntry ube = Unsafe.ReadUnaligned<NoAllocUpdateBufferEntry>(entryBasePtr);
                        uint8* dataPtr = (uint8*)ube.StagingBlock.Data;
                        executor.UpdateBuffer(
                            ube.Buffer.Get(_resourceList),
                            ube.BufferOffsetInBytes,
                            (IntPtr)dataPtr, ube.StagingBlockSize);
                        currentOffset += UpdateBufferEntrySize;
                        break;
                    case CopyBufferEntryID:
                        NoAllocCopyBufferEntry cbe = Unsafe.ReadUnaligned<NoAllocCopyBufferEntry>(entryBasePtr);
                        executor.CopyBuffer(
                            cbe.Source.Get(_resourceList),
                            cbe.SourceOffset,
                            cbe.Destination.Get(_resourceList),
                            cbe.DestinationOffset,
                            cbe.SizeInBytes);
                        currentOffset += CopyBufferEntrySize;
                        break;
                    case CopyTextureEntryID:
                        NoAllocCopyTextureEntry cte = Unsafe.ReadUnaligned<NoAllocCopyTextureEntry>(entryBasePtr);
                        executor.CopyTexture(
                            cte.Source.Get(_resourceList),
                            cte.SrcX, cte.SrcY, cte.SrcZ,
                            cte.SrcMipLevel,
                            cte.SrcBaseArrayLayer,
                            cte.Destination.Get(_resourceList),
                            cte.DstX, cte.DstY, cte.DstZ,
                            cte.DstMipLevel,
                            cte.DstBaseArrayLayer,
                            cte.Width, cte.Height, cte.Depth,
                            cte.LayerCount);
                        currentOffset += CopyTextureEntrySize;
                        break;
                    case ResolveTextureEntryID:
                        NoAllocResolveTextureEntry rte = Unsafe.ReadUnaligned<NoAllocResolveTextureEntry>(entryBasePtr);
                        executor.ResolveTexture(rte.Source.Get(_resourceList), rte.Destination.Get(_resourceList));
                        currentOffset += ResolveTextureEntrySize;
                        break;
                    case GenerateMipmapsEntryID:
                        NoAllocGenerateMipmapsEntry gme = Unsafe.ReadUnaligned<NoAllocGenerateMipmapsEntry>(entryBasePtr);
                        executor.GenerateMipmaps(gme.Texture.Get(_resourceList));
                        currentOffset += GenerateMipmapsEntrySize;
                        break;
                    case PushDebugGroupEntryID:
                        NoAllocPushDebugGroupEntry pdge = Unsafe.ReadUnaligned<NoAllocPushDebugGroupEntry>(entryBasePtr);
                        executor.PushDebugGroup(pdge.Name.Get(_resourceList));
                        currentOffset += PushDebugGroupEntrySize;
                        break;
                    case PopDebugGroupEntryID:
                        executor.PopDebugGroup();
                        currentOffset += PopDebugGroupEntrySize;
                        break;
                    case InsertDebugMarkerEntryID:
                        NoAllocInsertDebugMarkerEntry idme = Unsafe.ReadUnaligned<NoAllocInsertDebugMarkerEntry>(entryBasePtr);
                        executor.InsertDebugMarker(idme.Name.Get(_resourceList));
                        currentOffset += InsertDebugMarkerEntrySize;
                        break;
                    default:
                        throw new InvalidOperationException("Invalid entry ID: " + id);
                }
            }
        }

        public void Begin()
        {
            NoAllocBeginEntry entry = new NoAllocBeginEntry();
            AddEntry(BeginEntryID, ref entry);
        }

        public void ClearColorTarget(uint32 index, RgbaFloat clearColor)
        {
            NoAllocClearColorTargetEntry entry = new NoAllocClearColorTargetEntry(index, clearColor);
            AddEntry(ClearColorTargetID, ref entry);
        }

        public void ClearDepthTarget(float depth, uint8 stencil)
        {
            NoAllocClearDepthTargetEntry entry = new NoAllocClearDepthTargetEntry(depth, stencil);
            AddEntry(ClearDepthTargetID, ref entry);
        }

        public void Draw(uint32 vertexCount, uint32 instanceCount, uint32 vertexStart, uint32 instanceStart)
        {
            NoAllocDrawEntry entry = new NoAllocDrawEntry(vertexCount, instanceCount, vertexStart, instanceStart);
            AddEntry(DrawEntryID, ref entry);
        }

        public void DrawIndexed(uint32 indexCount, uint32 instanceCount, uint32 indexStart, int32 vertexOffset, uint32 instanceStart)
        {
            NoAllocDrawIndexedEntry entry = new NoAllocDrawIndexedEntry(indexCount, instanceCount, indexStart, vertexOffset, instanceStart);
            AddEntry(DrawIndexedEntryID, ref entry);
        }

        public void DrawIndirect(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            NoAllocDrawIndirectEntry entry = new NoAllocDrawIndirectEntry(Track(indirectBuffer), offset, drawCount, stride);
            AddEntry(DrawIndirectEntryID, ref entry);
        }

        public void DrawIndexedIndirect(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            NoAllocDrawIndexedIndirectEntry entry = new NoAllocDrawIndexedIndirectEntry(Track(indirectBuffer), offset, drawCount, stride);
            AddEntry(DrawIndexedIndirectEntryID, ref entry);
        }

        public void Dispatch(uint32 groupCountX, uint32 groupCountY, uint32 groupCountZ)
        {
            NoAllocDispatchEntry entry = new NoAllocDispatchEntry(groupCountX, groupCountY, groupCountZ);
            AddEntry(DispatchEntryID, ref entry);
        }

        public void DispatchIndirect(DeviceBuffer indirectBuffer, uint32 offset)
        {
            NoAllocDispatchIndirectEntry entry = new NoAllocDispatchIndirectEntry(Track(indirectBuffer), offset);
            AddEntry(DispatchIndirectEntryID, ref entry);
        }

        public void End()
        {
            NoAllocEndEntry entry = new NoAllocEndEntry();
            AddEntry(EndEntryID, ref entry);
        }

        public void SetFramebuffer(Framebuffer fb)
        {
            NoAllocSetFramebufferEntry entry = new NoAllocSetFramebufferEntry(Track(fb));
            AddEntry(SetFramebufferEntryID, ref entry);
        }

        public void SetIndexBuffer(DeviceBuffer buffer, IndexFormat format, uint32 offset)
        {
            NoAllocSetIndexBufferEntry entry = new NoAllocSetIndexBufferEntry(Track(buffer), format, offset);
            AddEntry(SetIndexBufferEntryID, ref entry);
        }

        public void SetPipeline(Pipeline pipeline)
        {
            NoAllocSetPipelineEntry entry = new NoAllocSetPipelineEntry(Track(pipeline));
            AddEntry(SetPipelineEntryID, ref entry);
        }

        public void SetGraphicsResourceSet(uint32 slot, ResourceSet rs, uint32 dynamicOffsetCount, ref uint32 dynamicOffsets)
        {
            SetResourceSet(slot, rs, dynamicOffsetCount, ref dynamicOffsets, isGraphics: true);
        }

        private void SetResourceSet(uint32 slot, ResourceSet rs, uint32 dynamicOffsetCount, ref uint32 dynamicOffsets, bool isGraphics)
        {
            NoAllocSetResourceSetEntry entry;

            if (dynamicOffsetCount > NoAllocSetResourceSetEntry.MaxInlineDynamicOffsets)
            {
                StagingBlock block = _memoryPool.GetStagingBlock(dynamicOffsetCount * sizeof(uint32));
                _stagingBlocks.Add(block);
                for (uint32 i = 0; i < dynamicOffsetCount; i++)
                {
                    *((uint32*)block.Data + i) = Unsafe.Add(ref dynamicOffsets, (int32)i);
                }

                entry = new NoAllocSetResourceSetEntry(slot, Track(rs), isGraphics, block);
            }
            else
            {
                entry = new NoAllocSetResourceSetEntry(slot, Track(rs), isGraphics, dynamicOffsetCount, ref dynamicOffsets);
            }

            AddEntry(SetResourceSetEntryID, ref entry);
        }

        public void SetComputeResourceSet(uint32 slot, ResourceSet rs, uint32 dynamicOffsetCount, ref uint32 dynamicOffsets)
        {
            SetResourceSet(slot, rs, dynamicOffsetCount, ref dynamicOffsets, isGraphics: false);
        }

        public void SetScissorRect(uint32 index, uint32 x, uint32 y, uint32 width, uint32 height)
        {
            NoAllocSetScissorRectEntry entry = new NoAllocSetScissorRectEntry(index, x, y, width, height);
            AddEntry(SetScissorRectEntryID, ref entry);
        }

        public void SetVertexBuffer(uint32 index, DeviceBuffer buffer, uint32 offset)
        {
            NoAllocSetVertexBufferEntry entry = new NoAllocSetVertexBufferEntry(index, Track(buffer), offset);
            AddEntry(SetVertexBufferEntryID, ref entry);
        }

        public void SetViewport(uint32 index, ref Viewport viewport)
        {
            NoAllocSetViewportEntry entry = new NoAllocSetViewportEntry(index, ref viewport);
            AddEntry(SetViewportEntryID, ref entry);
        }

        public void ResolveTexture(Texture source, Texture destination)
        {
            NoAllocResolveTextureEntry entry = new NoAllocResolveTextureEntry(Track(source), Track(destination));
            AddEntry(ResolveTextureEntryID, ref entry);
        }

        public void UpdateBuffer(DeviceBuffer buffer, uint32 bufferOffsetInBytes, IntPtr source, uint32 sizeInBytes)
        {
            StagingBlock stagingBlock = _memoryPool.Stage(source, sizeInBytes);
            _stagingBlocks.Add(stagingBlock);
            NoAllocUpdateBufferEntry entry = new NoAllocUpdateBufferEntry(Track(buffer), bufferOffsetInBytes, stagingBlock, sizeInBytes);
            AddEntry(UpdateBufferEntryID, ref entry);
        }

        public void CopyBuffer(DeviceBuffer source, uint32 sourceOffset, DeviceBuffer destination, uint32 destinationOffset, uint32 sizeInBytes)
        {
            NoAllocCopyBufferEntry entry = new NoAllocCopyBufferEntry(
                Track(source),
                sourceOffset,
                Track(destination),
                destinationOffset,
                sizeInBytes);
            AddEntry(CopyBufferEntryID, ref entry);
        }

        public void CopyTexture(
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
            NoAllocCopyTextureEntry entry = new NoAllocCopyTextureEntry(
                Track(source),
                srcX, srcY, srcZ,
                srcMipLevel,
                srcBaseArrayLayer,
                Track(destination),
                dstX, dstY, dstZ,
                dstMipLevel,
                dstBaseArrayLayer,
                width, height, depth,
                layerCount);
            AddEntry(CopyTextureEntryID, ref entry);
        }

        public void GenerateMipmaps(Texture texture)
        {
            NoAllocGenerateMipmapsEntry entry = new NoAllocGenerateMipmapsEntry(Track(texture));
            AddEntry(GenerateMipmapsEntryID, ref entry);
        }

        public void PushDebugGroup(string name)
        {
            NoAllocPushDebugGroupEntry entry = new NoAllocPushDebugGroupEntry(Track(name));
            AddEntry(PushDebugGroupEntryID, ref entry);
        }

        public void PopDebugGroup()
        {
            NoAllocPopDebugGroupEntry entry = new NoAllocPopDebugGroupEntry();
            AddEntry(PopDebugGroupEntryID, ref entry);
        }

        public void InsertDebugMarker(string name)
        {
            NoAllocInsertDebugMarkerEntry entry = new NoAllocInsertDebugMarkerEntry(Track(name));
            AddEntry(InsertDebugMarkerEntryID, ref entry);
        }

        private Tracked<T> Track<T>(T item) where T : class
        {
            return new Tracked<T>(_resourceList, item);
        }

        private struct EntryStorageBlock : IEquatable<EntryStorageBlock>
        {
            private const int32 DefaultStorageBlockSize = 40000;
            private readonly uint8[] _bytes;
            private readonly GCHandle _gcHandle;
            public readonly uint8* BasePtr;

            private uint32 _unusedStart;
            public uint32 RemainingSize => (uint32)_bytes.Length - _unusedStart;

            public uint32 TotalSize => (uint32)_bytes.Length;

            public bool Alloc(uint32 size, out void* ptr)
            {
                if (RemainingSize < size)
                {
                    ptr = null;
                    return false;
                }
                else
                {
                    ptr = (BasePtr + _unusedStart);
                    _unusedStart += size;
                    return true;
                }
            }

            private EntryStorageBlock(int32 storageBlockSize)
            {
                _bytes = new uint8[storageBlockSize];
                _gcHandle = GCHandle.Alloc(_bytes, GCHandleType.Pinned);
                BasePtr = (uint8*)_gcHandle.AddrOfPinnedObject().ToPointer();
                _unusedStart = 0;
            }

            public static EntryStorageBlock New()
            {
                return new EntryStorageBlock(DefaultStorageBlockSize);
            }

            public void Free()
            {
                _gcHandle.Free();
            }

            internal void Clear()
            {
                _unusedStart = 0;
                Util.ClearArray(_bytes);
            }

            public bool Equals(EntryStorageBlock other)
            {
                return _bytes == other._bytes;
            }
        }
    }

    /// <summary>
    /// A handle for an object stored in some List.
    /// </summary>
    /// <typeparam name="T">The type of object to track.</typeparam>
    internal struct Tracked<T> where T : class
    {
        private readonly int32 _index;

        public T Get(List<object> list) => (T)list[_index];

        public Tracked(List<object> list, T item)
        {
            _index = list.Count;
            list.Add(item);
        }
    }
}
