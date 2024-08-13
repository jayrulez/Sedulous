using System;
using Bulkan;
using static Bulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using System.Diagnostics;
using System.Text;
using System.Collections;
using System.Threading;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.VK;

    internal class VKCommandList : CommandList
    {
        private readonly VKGraphicsDevice _gd;
        private VkCommandPool _pool;
        private VkCommandBuffer _cb;
        private bool _destroyed;

        private bool _commandBufferBegun;
        private bool _commandBufferEnded;
        private VkRect2D[] _scissorRects = new .[0];

        private VkClearValue[] _clearValues = new .[0];
        private bool[] _validColorClearValues = new .[0];
        private VkClearValue? _depthClearValue;
        private readonly List<VKTexture> _preDrawSampledImages = new .();

        // Graphics State
        private VKFramebufferBase _currentFramebuffer;
        private bool _currentFramebufferEverActive;
        private VkRenderPass _activeRenderPass;
        private VKPipeline _currentGraphicsPipeline;
        private BoundResourceSetInfo[] _currentGraphicsResourceSets = new .[0];
        private bool[] _graphicsResourceSetsChanged;

        private bool _newFramebuffer; // Render pass cycle state

        // Compute State
        private VKPipeline _currentComputePipeline;
        private BoundResourceSetInfo[] _currentComputeResourceSets = new .[0];
        private bool[] _computeResourceSetsChanged;
        private String _name;

        private readonly Monitor _commandBufferListLock = new .() ~ delete _;
        private readonly Queue<VkCommandBuffer> _availableCommandBuffers = new .();
        private readonly List<VkCommandBuffer> _submittedCommandBuffers = new .();

        private StagingResourceInfo _currentStagingInfo;
        private readonly Monitor _stagingLock = new .() ~ delete _;
        private readonly Dictionary<VkCommandBuffer, StagingResourceInfo> _submittedStagingInfos = new .();
        private readonly List<StagingResourceInfo> _availableStagingInfos = new .();
        private readonly List<VKBuffer> _availableStagingBuffers = new .();

        public VkCommandPool CommandPool => _pool;
        public VkCommandBuffer CommandBuffer => _cb;

        public ResourceRefCount RefCount { get; }

        public override bool IsDisposed => _destroyed;

        public this(VKGraphicsDevice gd, in CommandListDescription description)
            : base(description, gd.Features, gd.UniformBufferMinOffsetAlignment, gd.StructuredBufferMinOffsetAlignment)
        {
            _gd = gd;
            VkCommandPoolCreateInfo poolCI = VkCommandPoolCreateInfo(){sType = .VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO};
            poolCI.flags = VkCommandPoolCreateFlags.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
            poolCI.queueFamilyIndex = gd.GraphicsQueueIndex;
            VkResult result = vkCreateCommandPool(_gd.Device, &poolCI, null, &_pool);
            CheckResult(result);

            _cb = GetNextCommandBuffer();
            RefCount = new ResourceRefCount(new => DisposeCore);
        }

        private VkCommandBuffer GetNextCommandBuffer()
        {
            using (_commandBufferListLock.Enter())
            {
                if (_availableCommandBuffers.Count > 0)
                {
                    VkCommandBuffer cachedCB = _availableCommandBuffers.PopFront();
                    VkResult resetResult = vkResetCommandBuffer(cachedCB, VkCommandBufferResetFlags.None);
                    CheckResult(resetResult);
                    return cachedCB;
                }
            }

            VkCommandBufferAllocateInfo cbAI = VkCommandBufferAllocateInfo(){sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO};
            cbAI.commandPool = _pool;
            cbAI.commandBufferCount = 1;
            cbAI.level = VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_PRIMARY;
			VkCommandBuffer cb = .Null;
            VkResult result = vkAllocateCommandBuffers(_gd.Device, &cbAI, &cb);
            CheckResult(result);
            return cb;
        }

        public void CommandBufferSubmitted(VkCommandBuffer cb)
        {
            RefCount.Increment();
            for (ResourceRefCount rrc in _currentStagingInfo.Resources)
            {
                rrc.Increment();
            }

            _submittedStagingInfos.Add(cb, _currentStagingInfo);
            _currentStagingInfo = null;
        }

        public void CommandBufferCompleted(VkCommandBuffer completedCB)
        {

            using (_commandBufferListLock.Enter())
            {
                for (int i = 0; i < _submittedCommandBuffers.Count; i++)
                {
                    VkCommandBuffer submittedCB = _submittedCommandBuffers[i];
                    if (submittedCB == completedCB)
                    {
                        _availableCommandBuffers.Add(completedCB);
                        _submittedCommandBuffers.RemoveAt(i);
                        i -= 1;
                    }
                }
            }

            using (_stagingLock.Enter())
            {
                if (_submittedStagingInfos.TryGetValue(completedCB, var info))
                {
                    RecycleStagingInfo(info);
                    _submittedStagingInfos.Remove(completedCB);
                }
            }

            RefCount.Decrement();
        }

        public override void Begin()
        {
            if (_commandBufferBegun)
            {
                Runtime.GALError(
                    "CommandList must be in its initial state, or End() must have been called, for Begin() to be valid to call.");
            }
            if (_commandBufferEnded)
            {
                _commandBufferEnded = false;
                _cb = GetNextCommandBuffer();
                if (_currentStagingInfo != null)
                {
                    RecycleStagingInfo(_currentStagingInfo);
                }
            }

            _currentStagingInfo = GetStagingResourceInfo();

            VkCommandBufferBeginInfo beginInfo = VkCommandBufferBeginInfo() {sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO};
            beginInfo.flags = VkCommandBufferUsageFlags.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
            vkBeginCommandBuffer(_cb, &beginInfo);
            _commandBufferBegun = true;

            ClearCachedState();
            _currentFramebuffer = null;
            _currentGraphicsPipeline = null;
            ClearSets(_currentGraphicsResourceSets);
            Util.ClearArray(_scissorRects);

            _currentComputePipeline = null;
            ClearSets(_currentComputeResourceSets);
        }

        protected override void ClearColorTargetCore(uint32 index, RgbaFloat clearColor)
        {
            VkClearValue clearValue = VkClearValue()
            {
                color = VkClearColorValue(clearColor.R, clearColor.G, clearColor.B, clearColor.A)
            };

            if (_activeRenderPass != VkRenderPass.Null)
            {
                VkClearAttachment clearAttachment = VkClearAttachment()
                {
                    colorAttachment = index,
                    aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
                    clearValue = clearValue
                };

                Texture colorTex = _currentFramebuffer.ColorTargets[(int32)index].Target;
                VkClearRect clearRect = VkClearRect()
                {
                    baseArrayLayer = 0,
                    layerCount = 1,
                    rect = VkRect2D(0, 0, colorTex.Width, colorTex.Height)
                };

                vkCmdClearAttachments(_cb, 1, &clearAttachment, 1, &clearRect);
            }
            else
            {
                // Queue up the clear value for the next RenderPass.
                _clearValues[index] = clearValue;
                _validColorClearValues[index] = true;
            }
        }

        protected override void ClearDepthStencilCore(float depth, uint8 stencil)
        {
            VkClearValue clearValue = VkClearValue { depthStencil = VkClearDepthStencilValue(depth, stencil) };

            if (_activeRenderPass != VkRenderPass.Null)
            {
                VkImageAspectFlags aspect = FormatHelpers.IsStencilFormat(_currentFramebuffer.DepthTarget.Value.Target.Format)
                    ? VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT
                    : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT;
                VkClearAttachment clearAttachment = VkClearAttachment()
                {
                    aspectMask = aspect,
                    clearValue = clearValue
                };

                uint32 renderableWidth = _currentFramebuffer.RenderableWidth;
                uint32 renderableHeight = _currentFramebuffer.RenderableHeight;
                if (renderableWidth > 0 && renderableHeight > 0)
                {
                    VkClearRect clearRect = VkClearRect()
                    {
                        baseArrayLayer = 0,
                        layerCount = 1,
                        rect = VkRect2D(0, 0, renderableWidth, renderableHeight)
                    };

                    vkCmdClearAttachments(_cb, 1, &clearAttachment, 1, &clearRect);
                }
            }
            else
            {
                // Queue up the clear value for the next RenderPass.
                _depthClearValue = clearValue;
            }
        }

        protected override void DrawCore(uint32 vertexCount, uint32 instanceCount, uint32 vertexStart, uint32 instanceStart)
        {
            PreDrawCommand();
            vkCmdDraw(_cb, vertexCount, instanceCount, vertexStart, instanceStart);
        }

        protected override void DrawIndexedCore(uint32 indexCount, uint32 instanceCount, uint32 indexStart, int32 vertexOffset, uint32 instanceStart)
        {
            PreDrawCommand();
            vkCmdDrawIndexed(_cb, indexCount, instanceCount, indexStart, vertexOffset, instanceStart);
        }

        protected override void DrawIndirectCore(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            PreDrawCommand();
            VKBuffer vkBuffer = Util.AssertSubtype<DeviceBuffer, VKBuffer>(indirectBuffer);
            _currentStagingInfo.Resources.Add(vkBuffer.RefCount);
            vkCmdDrawIndirect(_cb, vkBuffer.DeviceBuffer, offset, drawCount, stride);
        }

        protected override void DrawIndexedIndirectCore(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            PreDrawCommand();
            VKBuffer vkBuffer = Util.AssertSubtype<DeviceBuffer, VKBuffer>(indirectBuffer);
            _currentStagingInfo.Resources.Add(vkBuffer.RefCount);
            vkCmdDrawIndexedIndirect(_cb, vkBuffer.DeviceBuffer, offset, drawCount, stride);
        }

        private void PreDrawCommand()
        {
            TransitionImages(_preDrawSampledImages, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
            _preDrawSampledImages.Clear();

            EnsureRenderPassActive();

            FlushNewResourceSets(
                _currentGraphicsResourceSets,
                _graphicsResourceSetsChanged,
                _currentGraphicsPipeline.ResourceSetCount,
                VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS,
                _currentGraphicsPipeline.PipelineLayout);
        }

        private void FlushNewResourceSets(
            BoundResourceSetInfo[] resourceSets,
            bool[] resourceSetsChanged,
            uint32 resourceSetCount,
            VkPipelineBindPoint bindPoint,
            VkPipelineLayout pipelineLayout)
        {
            VKPipeline pipeline = bindPoint == VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS ? _currentGraphicsPipeline : _currentComputePipeline;

            VkDescriptorSet* descriptorSets = scope VkDescriptorSet[(int32)resourceSetCount]*;
            uint32* dynamicOffsets = scope uint32[pipeline.DynamicOffsetsCount]*;
            uint32 currentBatchCount = 0;
            uint32 currentBatchFirstSet = 0;
            uint32 currentBatchDynamicOffsetCount = 0;

            for (uint32 currentSlot = 0; currentSlot < resourceSetCount; currentSlot++)
            {
                bool batchEnded = !resourceSetsChanged[currentSlot] || currentSlot == resourceSetCount - 1;

                if (resourceSetsChanged[currentSlot])
                {
                    resourceSetsChanged[currentSlot] = false;
                    VKResourceSet vkSet = Util.AssertSubtype<ResourceSet, VKResourceSet>(resourceSets[currentSlot].Set);
                    descriptorSets[currentBatchCount] = vkSet.DescriptorSet;
                    currentBatchCount += 1;

                    ref SmallFixedOrDynamicArray curSetOffsets = ref resourceSets[currentSlot].Offsets;
                    for (uint32 i = 0; i < curSetOffsets.Count; i++)
                    {
                        dynamicOffsets[currentBatchDynamicOffsetCount] = curSetOffsets.Get(i);
                        currentBatchDynamicOffsetCount += 1;
                    }

                    // Increment ref count on first use of a set.
                    _currentStagingInfo.Resources.Add(vkSet.RefCount);
                    for (int i = 0; i < vkSet.RefCounts.Count; i++)
                    {
                        _currentStagingInfo.Resources.Add(vkSet.RefCounts[i]);
                    }
                }

                if (batchEnded)
                {
                    if (currentBatchCount != 0)
                    {
                        // Flush current batch.
                        vkCmdBindDescriptorSets(
                            _cb,
                            bindPoint,
                            pipelineLayout,
                            currentBatchFirstSet,
                            currentBatchCount,
                            descriptorSets,
                            currentBatchDynamicOffsetCount,
                            dynamicOffsets);
                    }

                    currentBatchCount = 0;
                    currentBatchFirstSet = currentSlot + 1;
                }
            }
        }

        private void TransitionImages(List<VKTexture> sampledTextures, VkImageLayout layout)
        {
            for (int32 i = 0; i < sampledTextures.Count; i++)
            {
                VKTexture tex = sampledTextures[i];
                tex.TransitionImageLayout(_cb, 0, tex.MipLevels, 0, tex.ActualArrayLayers, layout);
            }
        }

        public override void Dispatch(uint32 groupCountX, uint32 groupCountY, uint32 groupCountZ)
        {
            PreDispatchCommand();

            vkCmdDispatch(_cb, groupCountX, groupCountY, groupCountZ);
        }

        private void PreDispatchCommand()
        {
            EnsureNoRenderPass();

            for (uint32 currentSlot = 0; currentSlot < _currentComputePipeline.ResourceSetCount; currentSlot++)
            {
                VKResourceSet vkSet = Util.AssertSubtype<ResourceSet, VKResourceSet>(
                    _currentComputeResourceSets[currentSlot].Set);

                TransitionImages(vkSet.SampledTextures, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
                TransitionImages(vkSet.StorageTextures, VkImageLayout.VK_IMAGE_LAYOUT_GENERAL);
                for (int32 texIdx = 0; texIdx < vkSet.StorageTextures.Count; texIdx++)
                {
                    VKTexture storageTex = vkSet.StorageTextures[texIdx];
                    if ((storageTex.Usage & TextureUsage.Sampled) != 0)
                    {
                        _preDrawSampledImages.Add(storageTex);
                    }
                }
            }

            FlushNewResourceSets(
                _currentComputeResourceSets,
                _computeResourceSetsChanged,
                _currentComputePipeline.ResourceSetCount,
                VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_COMPUTE,
                _currentComputePipeline.PipelineLayout);
        }

        protected override void DispatchIndirectCore(DeviceBuffer indirectBuffer, uint32 offset)
        {
            PreDispatchCommand();

            VKBuffer vkBuffer = Util.AssertSubtype<DeviceBuffer, VKBuffer>(indirectBuffer);
            _currentStagingInfo.Resources.Add(vkBuffer.RefCount);
            vkCmdDispatchIndirect(_cb, vkBuffer.DeviceBuffer, offset);
        }

        protected override void ResolveTextureCore(Texture source, Texture destination)
        {
            if (_activeRenderPass != VkRenderPass.Null)
            {
                EndCurrentRenderPass();
            }

            VKTexture vkSource = Util.AssertSubtype<Texture, VKTexture>(source);
            _currentStagingInfo.Resources.Add(vkSource.RefCount);
            VKTexture vkDestination = Util.AssertSubtype<Texture, VKTexture>(destination);
            _currentStagingInfo.Resources.Add(vkDestination.RefCount);
            VkImageAspectFlags aspectFlags = ((source.Usage & TextureUsage.DepthStencil) == TextureUsage.DepthStencil)
                ? VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT
                : VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
            VkImageResolve region = VkImageResolve()
            {
                extent = VkExtent3D() { width = source.Width, height = source.Height, depth = source.Depth },
                srcSubresource = VkImageSubresourceLayers() { layerCount = 1, aspectMask = aspectFlags },
                dstSubresource = VkImageSubresourceLayers() { layerCount = 1, aspectMask = aspectFlags }
            };

            vkSource.TransitionImageLayout(_cb, 0, 1, 0, 1, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);
            vkDestination.TransitionImageLayout(_cb, 0, 1, 0, 1, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);

            vkCmdResolveImage(
                _cb,
                vkSource.OptimalDeviceImage,
                 VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                vkDestination.OptimalDeviceImage,
                VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                1,
                &region);

            if ((vkDestination.Usage & TextureUsage.Sampled) != 0)
            {
                vkDestination.TransitionImageLayout(_cb, 0, 1, 0, 1, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
            }
        }

        public override void End()
        {
            if (!_commandBufferBegun)
            {
                Runtime.GALError("CommandBuffer must have been started before End() may be called.");
            }

            _commandBufferBegun = false;
            _commandBufferEnded = true;

            if (!_currentFramebufferEverActive && _currentFramebuffer != null)
            {
                BeginCurrentRenderPass();
            }
            if (_activeRenderPass != VkRenderPass.Null)
            {
                EndCurrentRenderPass();
                _currentFramebuffer.TransitionToFinalLayout(_cb);
            }

            vkEndCommandBuffer(_cb);
            _submittedCommandBuffers.Add(_cb);
        }

        protected override void SetFramebufferCore(Framebuffer fb)
        {
            if (_activeRenderPass.Handle != VkRenderPass.Null)
            {
                EndCurrentRenderPass();
            }
            else if (!_currentFramebufferEverActive && _currentFramebuffer != null)
            {
                // This forces any queued up texture clears to be emitted.
                BeginCurrentRenderPass();
                EndCurrentRenderPass();
            }

            if (_currentFramebuffer != null)
            {
                _currentFramebuffer.TransitionToFinalLayout(_cb);
            }

            VKFramebufferBase vkFB = Util.AssertSubtype<Framebuffer, VKFramebufferBase>(fb);
            _currentFramebuffer = vkFB;
            _currentFramebufferEverActive = false;
            _newFramebuffer = true;
            Util.EnsureArrayMinimumSize(ref _scissorRects, Math.Max(1, (uint32)vkFB.ColorTargets.Count));
            uint32 clearValueCount = (uint32)vkFB.ColorTargets.Count;
            Util.EnsureArrayMinimumSize(ref _clearValues, clearValueCount + 1); // Leave an extra space for the depth value (tracked separately).
            Util.ClearArray(_validColorClearValues);
            Util.EnsureArrayMinimumSize(ref _validColorClearValues, clearValueCount);
            _currentStagingInfo.Resources.Add(vkFB.RefCount);

            if (let scFB = fb as VKSwapchainFramebuffer)
            {
                _currentStagingInfo.Resources.Add(scFB.Swapchain.RefCount);
            }
        }

        private void EnsureRenderPassActive()
        {
            if (_activeRenderPass == VkRenderPass.Null)
            {
                BeginCurrentRenderPass();
            }
        }

        private void EnsureNoRenderPass()
        {
            if (_activeRenderPass != VkRenderPass.Null)
            {
                EndCurrentRenderPass();
            }
        }

        private void BeginCurrentRenderPass()
        {
            Debug.Assert(_activeRenderPass == VkRenderPass.Null);
            Debug.Assert(_currentFramebuffer != null);
            _currentFramebufferEverActive = true;

            uint32 attachmentCount = _currentFramebuffer.AttachmentCount;
            bool haveAnyAttachments = _currentFramebuffer.ColorTargets.Count > 0 || _currentFramebuffer.DepthTarget != null;
            bool haveAllClearValues = _depthClearValue.HasValue || _currentFramebuffer.DepthTarget == null;
            bool haveAnyClearValues = _depthClearValue.HasValue;
            for (int i = 0; i < _currentFramebuffer.ColorTargets.Count; i++)
            {
                if (!_validColorClearValues[i])
                {
                    haveAllClearValues = false;
                }
                else
                {
                    haveAnyClearValues = true;
                }
            }

            VkRenderPassBeginInfo renderPassBI = VkRenderPassBeginInfo() {sType = .VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO};
            renderPassBI.renderArea = VkRect2D(_currentFramebuffer.RenderableWidth, _currentFramebuffer.RenderableHeight);
            renderPassBI.framebuffer = _currentFramebuffer.CurrentFramebuffer;

            if (!haveAnyAttachments || !haveAllClearValues)
            {
                renderPassBI.renderPass = _newFramebuffer
                    ? _currentFramebuffer.RenderPassNoClear_Init
                    : _currentFramebuffer.RenderPassNoClear_Load;
                vkCmdBeginRenderPass(_cb, &renderPassBI, VkSubpassContents.VK_SUBPASS_CONTENTS_INLINE);
                _activeRenderPass = renderPassBI.renderPass;

                if (haveAnyClearValues)
                {
                    if (_depthClearValue.HasValue)
                    {
                        ClearDepthStencilCore(_depthClearValue.Value.depthStencil.depth, (uint8)_depthClearValue.Value.depthStencil.stencil);
                        _depthClearValue = null;
                    }

                    for (uint32 i = 0; i < _currentFramebuffer.ColorTargets.Count; i++)
                    {
                        if (_validColorClearValues[i])
                        {
                            _validColorClearValues[i] = false;
                            VkClearValue vkClearValue = _clearValues[i];
                            RgbaFloat clearColor = RgbaFloat(
                                vkClearValue.color.float32[0],
                                vkClearValue.color.float32[1],
                                vkClearValue.color.float32[2],
                                vkClearValue.color.float32[3]);
                            ClearColorTarget(i, clearColor);
                        }
                    }
                }
            }
            else
            {
                // We have clear values for every attachment.
                renderPassBI.renderPass = _currentFramebuffer.RenderPassClear;
                //fixed (VkClearValue* clearValuesPtr = &_clearValues[0])
                {
                    renderPassBI.clearValueCount = attachmentCount;
                    renderPassBI.pClearValues = _clearValues.Ptr;
                    if (_depthClearValue.HasValue)
                    {
                        _clearValues[_currentFramebuffer.ColorTargets.Count] = _depthClearValue.Value;
                        _depthClearValue = null;
                    }
                    vkCmdBeginRenderPass(_cb, &renderPassBI, VkSubpassContents.VK_SUBPASS_CONTENTS_INLINE);
                    _activeRenderPass = _currentFramebuffer.RenderPassClear;
                    Util.ClearArray(_validColorClearValues);
                }
            }

            _newFramebuffer = false;
        }

        private void EndCurrentRenderPass()
        {
            Debug.Assert(_activeRenderPass != VkRenderPass.Null);
            vkCmdEndRenderPass(_cb);
            _currentFramebuffer.TransitionToIntermediateLayout(_cb);
            _activeRenderPass = VkRenderPass.Null;

            // Place a barrier between RenderPasses, so that color / depth outputs
            // can be read in subsequent passes.
            vkCmdPipelineBarrier(
                _cb,
                VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
                VkPipelineStageFlags.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT,
                VkDependencyFlags.None,
                0,
                null,
                0,
                null,
                0,
                null);
        }

        protected override void SetVertexBufferCore(uint32 index, DeviceBuffer buffer, uint32 offset)
        {
            VKBuffer vkBuffer = Util.AssertSubtype<DeviceBuffer, VKBuffer>(buffer);
            VkBuffer deviceBuffer = vkBuffer.DeviceBuffer;
            uint64 offset64 = offset;
            vkCmdBindVertexBuffers(_cb, index, 1, &deviceBuffer, &offset64);
            _currentStagingInfo.Resources.Add(vkBuffer.RefCount);
        }

        protected override void SetIndexBufferCore(DeviceBuffer buffer, IndexFormat format, uint32 offset)
        {
            VKBuffer vkBuffer = Util.AssertSubtype<DeviceBuffer, VKBuffer>(buffer);
            vkCmdBindIndexBuffer(_cb, vkBuffer.DeviceBuffer, offset, VKFormats.VdToVkIndexFormat(format));
            _currentStagingInfo.Resources.Add(vkBuffer.RefCount);
        }

        protected override void SetPipelineCore(Pipeline pipeline)
        {
            VKPipeline vkPipeline = Util.AssertSubtype<Pipeline, VKPipeline>(pipeline);
            if (!pipeline.IsComputePipeline && _currentGraphicsPipeline != pipeline)
            {
                Util.EnsureArrayMinimumSize(ref _currentGraphicsResourceSets, vkPipeline.ResourceSetCount);
                ClearSets(_currentGraphicsResourceSets);
                Util.EnsureArrayMinimumSize(ref _graphicsResourceSetsChanged, vkPipeline.ResourceSetCount);
                vkCmdBindPipeline(_cb, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS, vkPipeline.DevicePipeline);
                _currentGraphicsPipeline = vkPipeline;
            }
            else if (pipeline.IsComputePipeline && _currentComputePipeline != pipeline)
            {
                Util.EnsureArrayMinimumSize(ref _currentComputeResourceSets, vkPipeline.ResourceSetCount);
                ClearSets(_currentComputeResourceSets);
                Util.EnsureArrayMinimumSize(ref _computeResourceSetsChanged, vkPipeline.ResourceSetCount);
                vkCmdBindPipeline(_cb, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_COMPUTE, vkPipeline.DevicePipeline);
                _currentComputePipeline = vkPipeline;
            }

            _currentStagingInfo.Resources.Add(vkPipeline.RefCount);
        }

        private void ClearSets(BoundResourceSetInfo[] boundSets)
        {
            for (BoundResourceSetInfo boundSetInfo in boundSets)
            {
                boundSetInfo.Offsets.Dispose();
            }
            Util.ClearArray(boundSets);
        }

        protected override void SetGraphicsResourceSetCore(uint32 slot, ResourceSet rs, uint32 dynamicOffsetsCount, uint32* dynamicOffsets)
        {
            if (!_currentGraphicsResourceSets[slot].Equals(rs, dynamicOffsetsCount, dynamicOffsets))
            {
                _currentGraphicsResourceSets[slot].Offsets.Dispose();
                _currentGraphicsResourceSets[slot] = BoundResourceSetInfo(rs, dynamicOffsetsCount, dynamicOffsets);
                _graphicsResourceSetsChanged[slot] = true;
                VKResourceSet vkRS = Util.AssertSubtype<ResourceSet, VKResourceSet>(rs);
            }
        }

        protected override void SetComputeResourceSetCore(uint32 slot, ResourceSet rs, uint32 dynamicOffsetsCount, uint32* dynamicOffsets)
        {
            if (!_currentComputeResourceSets[slot].Equals(rs, dynamicOffsetsCount, dynamicOffsets))
            {
                _currentComputeResourceSets[slot].Offsets.Dispose();
                _currentComputeResourceSets[slot] = BoundResourceSetInfo(rs, dynamicOffsetsCount, dynamicOffsets);
                _computeResourceSetsChanged[slot] = true;
                VKResourceSet vkRS = Util.AssertSubtype<ResourceSet, VKResourceSet>(rs);
            }
        }

        public override void SetScissorRect(uint32 index, uint32 x, uint32 y, uint32 width, uint32 height)
        {
            if (index == 0 || _gd.Features.MultipleViewports)
            {
                VkRect2D scissor = VkRect2D((int32)x, (int32)y, (int32)width, (int32)height);
                if (_scissorRects[index] != scissor)
                {
                    _scissorRects[index] = scissor;
                    vkCmdSetScissor(_cb, index, 1, &scissor);
                }
            }
        }

        public override void SetViewport(uint32 index, in Viewport viewport)
        {
            if (index == 0 || _gd.Features.MultipleViewports)
            {
                float vpY = _gd.IsClipSpaceYInverted
                    ? viewport.Y
                    : viewport.Height + viewport.Y;
                float vpHeight = _gd.IsClipSpaceYInverted
                    ? viewport.Height
                    : -viewport.Height;

                VkViewport vkViewport = VkViewport()
                {
                    x = viewport.X,
                    y = vpY,
                    width = viewport.Width,
                    height = vpHeight,
                    minDepth = viewport.MinDepth,
                    maxDepth = viewport.MaxDepth
                };

                vkCmdSetViewport(_cb, index, 1, &vkViewport);
            }
        }

        protected override void UpdateBufferCore(DeviceBuffer buffer, uint32 bufferOffsetInBytes, void* source, uint32 sizeInBytes)
        {
            VKBuffer stagingBuffer = GetStagingBuffer(sizeInBytes);
            _gd.UpdateBuffer(stagingBuffer, 0, source, sizeInBytes);
            CopyBuffer(stagingBuffer, 0, buffer, bufferOffsetInBytes, sizeInBytes);
        }

        protected override void CopyBufferCore(
            DeviceBuffer source,
            uint32 sourceOffset,
            DeviceBuffer destination,
            uint32 destinationOffset,
            uint32 sizeInBytes)
        {
            EnsureNoRenderPass();

            VKBuffer srcVkBuffer = Util.AssertSubtype<DeviceBuffer, VKBuffer>(source);
            _currentStagingInfo.Resources.Add(srcVkBuffer.RefCount);
            VKBuffer dstVkBuffer = Util.AssertSubtype<DeviceBuffer, VKBuffer>(destination);
            _currentStagingInfo.Resources.Add(dstVkBuffer.RefCount);

            VkBufferCopy region = VkBufferCopy()
            {
                srcOffset = sourceOffset,
                dstOffset = destinationOffset,
                size = sizeInBytes
            };

            vkCmdCopyBuffer(_cb, srcVkBuffer.DeviceBuffer, dstVkBuffer.DeviceBuffer, 1, &region);

            bool needToProtectUniform = destination.Usage.HasFlag(BufferUsage.UniformBuffer);

            VkMemoryBarrier barrier = .();
            barrier.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_BARRIER;
            barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
            barrier.dstAccessMask = needToProtectUniform ? VkAccessFlags.VK_ACCESS_UNIFORM_READ_BIT : VkAccessFlags.VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT;
            barrier.pNext = null;
            vkCmdPipelineBarrier(
                _cb,
                VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, needToProtectUniform ?
                    VkPipelineStageFlags.VK_PIPELINE_STAGE_VERTEX_SHADER_BIT | VkPipelineStageFlags.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT |
                    VkPipelineStageFlags.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT | VkPipelineStageFlags.VK_PIPELINE_STAGE_GEOMETRY_SHADER_BIT |
                    VkPipelineStageFlags.VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT | VkPipelineStageFlags.VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT
                    : VkPipelineStageFlags.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT,
                VkDependencyFlags.None,
                1, &barrier,
                0, null,
                0, null);
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
            EnsureNoRenderPass();
            CopyTextureCore_VkCommandBuffer(
                _cb,
                source, srcX, srcY, srcZ, srcMipLevel, srcBaseArrayLayer,
                destination, dstX, dstY, dstZ, dstMipLevel, dstBaseArrayLayer,
                width, height, depth, layerCount);

            VKTexture srcVkTexture = Util.AssertSubtype<Texture, VKTexture>(source);
            _currentStagingInfo.Resources.Add(srcVkTexture.RefCount);
            VKTexture dstVkTexture = Util.AssertSubtype<Texture, VKTexture>(destination);
            _currentStagingInfo.Resources.Add(dstVkTexture.RefCount);
        }

        internal static void CopyTextureCore_VkCommandBuffer(
            VkCommandBuffer cb,
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
            VKTexture srcVkTexture = Util.AssertSubtype<Texture, VKTexture>(source);
            VKTexture dstVkTexture = Util.AssertSubtype<Texture, VKTexture>(destination);

            bool sourceIsStaging = (source.Usage & TextureUsage.Staging) == TextureUsage.Staging;
            bool destIsStaging = (destination.Usage & TextureUsage.Staging) == TextureUsage.Staging;

            if (!sourceIsStaging && !destIsStaging)
            {
                VkImageSubresourceLayers srcSubresource = VkImageSubresourceLayers()
                {
                    aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
                    layerCount = layerCount,
                    mipLevel = srcMipLevel,
                    baseArrayLayer = srcBaseArrayLayer
                };

                VkImageSubresourceLayers dstSubresource = VkImageSubresourceLayers()
                {
                    aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
                    layerCount = layerCount,
                    mipLevel = dstMipLevel,
                    baseArrayLayer = dstBaseArrayLayer
                };

                VkImageCopy region = VkImageCopy()
                {
                    srcOffset = VkOffset3D() { x = (int32)srcX, y = (int32)srcY, z = (int32)srcZ },
                    dstOffset = VkOffset3D() { x = (int32)dstX, y = (int32)dstY, z = (int32)dstZ },
                    srcSubresource = srcSubresource,
                    dstSubresource = dstSubresource,
                    extent = VkExtent3D() { width = width, height = height, depth = depth }
                };

                srcVkTexture.TransitionImageLayout(
                    cb,
                    srcMipLevel,
                    1,
                    srcBaseArrayLayer,
                    layerCount,
                    VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);

                dstVkTexture.TransitionImageLayout(
                    cb,
                    dstMipLevel,
                    1,
                    dstBaseArrayLayer,
                    layerCount,
                    VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);

                vkCmdCopyImage(
                    cb,
                    srcVkTexture.OptimalDeviceImage,
                    VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                    dstVkTexture.OptimalDeviceImage,
                    VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                    1,
                    &region);

                if ((srcVkTexture.Usage & TextureUsage.Sampled) != 0)
                {
                    srcVkTexture.TransitionImageLayout(
                        cb,
                        srcMipLevel,
                        1,
                        srcBaseArrayLayer,
                        layerCount,
                        VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
                }

                if ((dstVkTexture.Usage & TextureUsage.Sampled) != 0)
                {
                    dstVkTexture.TransitionImageLayout(
                        cb,
                        dstMipLevel,
                        1,
                        dstBaseArrayLayer,
                        layerCount,
                        VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
                }
            }
            else if (sourceIsStaging && !destIsStaging)
            {
                VkBuffer srcBuffer = srcVkTexture.StagingBuffer;
                VkSubresourceLayout srcLayout = srcVkTexture.GetSubresourceLayout(
                    srcVkTexture.CalculateSubresource(srcMipLevel, srcBaseArrayLayer));
                VkImage dstImage = dstVkTexture.OptimalDeviceImage;
                dstVkTexture.TransitionImageLayout(
                    cb,
                    dstMipLevel,
                    1,
                    dstBaseArrayLayer,
                    layerCount,
                    VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);

                VkImageSubresourceLayers dstSubresource = VkImageSubresourceLayers()
                {
                    aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
                    layerCount = layerCount,
                    mipLevel = dstMipLevel,
                    baseArrayLayer = dstBaseArrayLayer
                };

                Util.GetMipDimensions(srcVkTexture, srcMipLevel, var mipWidth, var mipHeight, var mipDepth);
                uint32 blockSize = FormatHelpers.IsCompressedFormat(srcVkTexture.Format) ? 4 : 1;
                uint32 bufferRowLength = Math.Max(mipWidth, blockSize);
                uint32 bufferImageHeight = Math.Max(mipHeight, blockSize);
                uint32 compressedX = srcX / blockSize;
                uint32 compressedY = srcY / blockSize;
                uint32 blockSizeInBytes = blockSize == 1
                    ? FormatSizeHelpers.GetSizeInBytes(srcVkTexture.Format)
                    : FormatHelpers.GetBlockSizeInBytes(srcVkTexture.Format);
                uint32 rowPitch = FormatHelpers.GetRowPitch(bufferRowLength, srcVkTexture.Format);
                uint32 depthPitch = FormatHelpers.GetDepthPitch(rowPitch, bufferImageHeight, srcVkTexture.Format);

                uint32 copyWidth = Math.Min(width, mipWidth);
                uint32 copyheight = Math.Min(height, mipHeight);

                VkBufferImageCopy regions = VkBufferImageCopy()
                {
                    bufferOffset = srcLayout.offset
                        + (srcZ * depthPitch)
                        + (compressedY * rowPitch)
                        + (compressedX * blockSizeInBytes),
                    bufferRowLength = bufferRowLength,
                    bufferImageHeight = bufferImageHeight,
                    imageExtent = VkExtent3D() { width = copyWidth, height = copyheight, depth = depth },
                    imageOffset = VkOffset3D() { x = (int32)dstX, y = (int32)dstY, z = (int32)dstZ },
                    imageSubresource = dstSubresource
                };

                vkCmdCopyBufferToImage(cb, srcBuffer, dstImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &regions);

                if ((dstVkTexture.Usage & TextureUsage.Sampled) != 0)
                {
                    dstVkTexture.TransitionImageLayout(
                        cb,
                        dstMipLevel,
                        1,
                        dstBaseArrayLayer,
                        layerCount,
                        VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
                }
            }
            else if (!sourceIsStaging && destIsStaging)
            {
                VkImage srcImage = srcVkTexture.OptimalDeviceImage;
                srcVkTexture.TransitionImageLayout(
                    cb,
                    srcMipLevel,
                    1,
                    srcBaseArrayLayer,
                    layerCount,
                    VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);

                VkBuffer dstBuffer = dstVkTexture.StagingBuffer;

                VkImageAspectFlags aspect = (srcVkTexture.Usage & TextureUsage.DepthStencil) != 0
                    ? VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT
                    : VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;

                Util.GetMipDimensions(dstVkTexture, dstMipLevel, var mipWidth, var mipHeight, var mipDepth);
                uint32 blockSize = FormatHelpers.IsCompressedFormat(srcVkTexture.Format) ? 4 : 1;
                uint32 bufferRowLength = Math.Max(mipWidth, blockSize);
                uint32 bufferImageHeight = Math.Max(mipHeight, blockSize);
                uint32 compressedDstX = dstX / blockSize;
                uint32 compressedDstY = dstY / blockSize;
                uint32 blockSizeInBytes = blockSize == 1
                    ? FormatSizeHelpers.GetSizeInBytes(dstVkTexture.Format)
                    : FormatHelpers.GetBlockSizeInBytes(dstVkTexture.Format);
                uint32 rowPitch = FormatHelpers.GetRowPitch(bufferRowLength, dstVkTexture.Format);
                uint32 depthPitch = FormatHelpers.GetDepthPitch(rowPitch, bufferImageHeight, dstVkTexture.Format);

                var layers = scope VkBufferImageCopy[(int32)layerCount]*;
                for(uint32 layer = 0; layer < layerCount; layer++)
                {
                    VkSubresourceLayout dstLayout = dstVkTexture.GetSubresourceLayout(
                        dstVkTexture.CalculateSubresource(dstMipLevel, dstBaseArrayLayer + layer));

                    VkImageSubresourceLayers srcSubresource = VkImageSubresourceLayers()
                    {
                        aspectMask = aspect,
                        layerCount = 1,
                        mipLevel = srcMipLevel,
                        baseArrayLayer = srcBaseArrayLayer + layer
                    };

                    VkBufferImageCopy region = VkBufferImageCopy()
                    {
                        bufferRowLength = bufferRowLength,
                        bufferImageHeight = bufferImageHeight,
                        bufferOffset = dstLayout.offset
                            + (dstZ * depthPitch)
                            + (compressedDstY * rowPitch)
                            + (compressedDstX * blockSizeInBytes),
                        imageExtent = VkExtent3D() { width = width, height = height, depth = depth },
                        imageOffset = VkOffset3D() { x = (int32)srcX, y = (int32)srcY, z = (int32)srcZ },
                        imageSubresource = srcSubresource
                    };

                    layers[layer] = region;
                }

                vkCmdCopyImageToBuffer(cb, srcImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, dstBuffer, layerCount, layers);

                if ((srcVkTexture.Usage & TextureUsage.Sampled) != 0)
                {
                    srcVkTexture.TransitionImageLayout(
                        cb,
                        srcMipLevel,
                        1,
                        srcBaseArrayLayer,
                        layerCount,
                        VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
                }
            }
            else
            {
                Debug.Assert(sourceIsStaging && destIsStaging);
                VkBuffer srcBuffer = srcVkTexture.StagingBuffer;
                VkSubresourceLayout srcLayout = srcVkTexture.GetSubresourceLayout(
                    srcVkTexture.CalculateSubresource(srcMipLevel, srcBaseArrayLayer));
                VkBuffer dstBuffer = dstVkTexture.StagingBuffer;
                VkSubresourceLayout dstLayout = dstVkTexture.GetSubresourceLayout(
                    dstVkTexture.CalculateSubresource(dstMipLevel, dstBaseArrayLayer));

                uint32 zLimit = Math.Max(depth, layerCount);
                if (!FormatHelpers.IsCompressedFormat(source.Format))
                {
                    uint32 pixelSize = FormatSizeHelpers.GetSizeInBytes(srcVkTexture.Format);
                    for (uint32 zz = 0; zz < zLimit; zz++)
                    {
                        for (uint32 yy = 0; yy < height; yy++)
                        {
                            VkBufferCopy region = VkBufferCopy()
                            {
                                srcOffset = srcLayout.offset
                                    + srcLayout.depthPitch * (zz + srcZ)
                                    + srcLayout.rowPitch * (yy + srcY)
                                    + pixelSize * srcX,
                                dstOffset = dstLayout.offset
                                    + dstLayout.depthPitch * (zz + dstZ)
                                    + dstLayout.rowPitch * (yy + dstY)
                                    + pixelSize * dstX,
                                size = width * pixelSize,
                            };

                            vkCmdCopyBuffer(cb, srcBuffer, dstBuffer, 1, &region);
                        }
                    }
                }
                else // IsCompressedFormat
                {
                    uint32 denseRowSize = FormatHelpers.GetRowPitch(width, source.Format);
                    uint32 numRows = FormatHelpers.GetNumRows(height, source.Format);
                    uint32 compressedSrcX = srcX / 4;
                    uint32 compressedSrcY = srcY / 4;
                    uint32 compressedDstX = dstX / 4;
                    uint32 compressedDstY = dstY / 4;
                    uint32 blockSizeInBytes = FormatHelpers.GetBlockSizeInBytes(source.Format);

                    for (uint32 zz = 0; zz < zLimit; zz++)
                    {
                        for (uint32 row = 0; row < numRows; row++)
                        {
                            VkBufferCopy region = VkBufferCopy()
                            {
                                srcOffset = srcLayout.offset
                                    + srcLayout.depthPitch * (zz + srcZ)
                                    + srcLayout.rowPitch * (row + compressedSrcY)
                                    + blockSizeInBytes * compressedSrcX,
                                dstOffset = dstLayout.offset
                                    + dstLayout.depthPitch * (zz + dstZ)
                                    + dstLayout.rowPitch * (row + compressedDstY)
                                    + blockSizeInBytes * compressedDstX,
                                size = denseRowSize,
                            };

                            vkCmdCopyBuffer(cb, srcBuffer, dstBuffer, 1, &region);
                        }
                    }

                }
            }
        }

        protected override void GenerateMipmapsCore(Texture texture)
        {
            EnsureNoRenderPass();
            VKTexture vkTex = Util.AssertSubtype<Texture, VKTexture>(texture);
            _currentStagingInfo.Resources.Add(vkTex.RefCount);

            uint32 layerCount = vkTex.ArrayLayers;
            if ((vkTex.Usage & TextureUsage.Cubemap) != 0)
            {
                layerCount *= 6;
            }

            VkImageBlit region;

            uint32 width = vkTex.Width;
            uint32 height = vkTex.Height;
            uint32 depth = vkTex.Depth;
            for (uint32 level = 1; level < vkTex.MipLevels; level++)
            {
                vkTex.TransitionImageLayoutNonmatching(_cb, level - 1, 1, 0, layerCount, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);
                vkTex.TransitionImageLayoutNonmatching(_cb, level, 1, 0, layerCount, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);

                VkImage deviceImage = vkTex.OptimalDeviceImage;
                uint32 mipWidth = Math.Max(width >> 1, 1);
                uint32 mipHeight = Math.Max(height >> 1, 1);
                uint32 mipDepth = Math.Max(depth >> 1, 1);

                region.srcSubresource = VkImageSubresourceLayers()
                {
                    aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
                    baseArrayLayer = 0,
                    layerCount = layerCount,
                    mipLevel = level - 1
                };
                region.srcOffsets[0] = VkOffset3D();
                region.srcOffsets[1] = VkOffset3D() { x = (int32)width, y = (int32)height, z = (int32)depth };
                region.dstOffsets[0] = VkOffset3D();

                region.dstSubresource = VkImageSubresourceLayers()
                {
                    aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
                    baseArrayLayer = 0,
                    layerCount = layerCount,
                    mipLevel = level
                };

                region.dstOffsets[1] = VkOffset3D() { x = (int32)mipWidth, y = (int32)mipHeight, z = (int32)mipDepth };
                vkCmdBlitImage(
                    _cb,
                    deviceImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                    deviceImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                    1, &region,
                    _gd.GetFormatFilter(vkTex.VkFormat));

                width = mipWidth;
                height = mipHeight;
                depth = mipDepth;
            }

            if ((vkTex.Usage & TextureUsage.Sampled) != 0)
            {
                vkTex.TransitionImageLayoutNonmatching(_cb, 0, vkTex.MipLevels, 0, layerCount, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
            }
        }

#if !VALIDATE_USAGE
        [SkipCall]//[Conditional("VALIDATE_USAGE")]
#endif
        private void DebugFullPipelineBarrier()
        {
            VkMemoryBarrier memoryBarrier = VkMemoryBarrier() {sType = .VK_STRUCTURE_TYPE_MEMORY_BARRIER};
            memoryBarrier.srcAccessMask = .VK_ACCESS_INDIRECT_COMMAND_READ_BIT |
                   .VK_ACCESS_INDEX_READ_BIT |
                   .VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT |
                   .VK_ACCESS_UNIFORM_READ_BIT |
                   .VK_ACCESS_INPUT_ATTACHMENT_READ_BIT |
                   .VK_ACCESS_SHADER_READ_BIT |
                   .VK_ACCESS_SHADER_WRITE_BIT |
                   .VK_ACCESS_COLOR_ATTACHMENT_READ_BIT |
                   .VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT |
                   .VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT |
                   .VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT |
                   .VK_ACCESS_TRANSFER_READ_BIT |
                   .VK_ACCESS_TRANSFER_WRITE_BIT |
                   .VK_ACCESS_HOST_READ_BIT |
                   .VK_ACCESS_HOST_WRITE_BIT;
            memoryBarrier.dstAccessMask = .VK_ACCESS_INDIRECT_COMMAND_READ_BIT |
                   .VK_ACCESS_INDEX_READ_BIT |
                   .VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT |
                   .VK_ACCESS_UNIFORM_READ_BIT |
                   .VK_ACCESS_INPUT_ATTACHMENT_READ_BIT |
                   .VK_ACCESS_SHADER_READ_BIT |
                   .VK_ACCESS_SHADER_WRITE_BIT |
                   .VK_ACCESS_COLOR_ATTACHMENT_READ_BIT |
                   .VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT |
                   .VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT |
                   .VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT |
                   .VK_ACCESS_TRANSFER_READ_BIT |
                   .VK_ACCESS_TRANSFER_WRITE_BIT |
                   .VK_ACCESS_HOST_READ_BIT |
                   .VK_ACCESS_HOST_WRITE_BIT;

            vkCmdPipelineBarrier(
                _cb,
                .VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, // srcStageMask
                .VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, // dstStageMask
                VkDependencyFlags.None,
                1,                                  // memoryBarrierCount
                &memoryBarrier,                     // pMemoryBarriers
                0, null,
                0, null);
        }

        public override String Name
        {
            get => _name;
            set
            {
                _name = value;
                _gd.SetResourceName(this, value);
            }
        }

        private VKBuffer GetStagingBuffer(uint32 size)
        {
            using (_stagingLock.Enter())
            {
                VKBuffer ret = null;
                for (VKBuffer buffer in _availableStagingBuffers)
                {
                    if (buffer.SizeInBytes >= size)
                    {
                        ret = buffer;
                        _availableStagingBuffers.Remove(buffer);
                        break;
                    }
                }
                if (ret == null)
                {
                    ret = (VKBuffer)_gd.ResourceFactory.CreateBuffer(BufferDescription(size, BufferUsage.Staging));
                    ret.Name = scope $"Staging Buffer (CommandList {_name})";
                }

                _currentStagingInfo.BuffersUsed.Add(ret);
                return ret;
            }
        }

        protected override void PushDebugGroupCore(String name)
        {
            vkCmdDebugMarkerBeginEXT_t func = _gd.MarkerBegin;
            if (func == null) { return; }

            VkDebugMarkerMarkerInfoEXT markerInfo = VkDebugMarkerMarkerInfoEXT() {sType = .VK_STRUCTURE_TYPE_DEBUG_MARKER_MARKER_INFO_EXT};

            markerInfo.pMarkerName = scope String(name).CStr();

            func(_cb, &markerInfo);
        }

        protected override void PopDebugGroupCore()
        {
            vkCmdDebugMarkerEndEXT_t func = _gd.MarkerEnd;
            if (func == null) { return; }

            func(_cb);
        }

        protected override void InsertDebugMarkerCore(String name)
        {
            vkCmdDebugMarkerInsertEXT_t func = _gd.MarkerInsert;
            if (func == null) { return; }

            VkDebugMarkerMarkerInfoEXT markerInfo = VkDebugMarkerMarkerInfoEXT() {sType = .VK_STRUCTURE_TYPE_DEBUG_MARKER_MARKER_INFO_EXT};

            markerInfo.pMarkerName = scope String(name).CStr();

            func(_cb, &markerInfo);
        }

        public override void Dispose()
        {
            RefCount.Decrement();
        }

        private void DisposeCore()
        {
            if (!_destroyed)
            {
                _destroyed = true;
                vkDestroyCommandPool(_gd.Device, _pool, null);

                Debug.Assert(_submittedStagingInfos.Count == 0);

                for (VKBuffer buffer in _availableStagingBuffers)
                {
                    buffer.Dispose();
                }
            }
        }

        private class StagingResourceInfo
        {
            public List<VKBuffer> BuffersUsed { get; } = new List<VKBuffer>();
            public HashSet<ResourceRefCount> Resources { get; } = new HashSet<ResourceRefCount>();
            public void Clear()
            {
                BuffersUsed.Clear();
                Resources.Clear();
            }
        }

        private StagingResourceInfo GetStagingResourceInfo()
        {
            using (_stagingLock.Enter())
            {
                StagingResourceInfo ret;
                int availableCount = _availableStagingInfos.Count;
                if (availableCount > 0)
                {
                    ret = _availableStagingInfos[availableCount - 1];
                    _availableStagingInfos.RemoveAt(availableCount - 1);
                }
                else
                {
                    ret = new StagingResourceInfo();
                }

                return ret;
            }
        }

        private void RecycleStagingInfo(StagingResourceInfo info)
        {
            using (_stagingLock.Enter())
            {
                for (VKBuffer buffer in info.BuffersUsed)
                {
                    _availableStagingBuffers.Add(buffer);
                }

                for (ResourceRefCount rrc in info.Resources)
                {
                    rrc.Decrement();
                }

                info.Clear();

                _availableStagingInfos.Add(info);
            }
        }
    }
}
