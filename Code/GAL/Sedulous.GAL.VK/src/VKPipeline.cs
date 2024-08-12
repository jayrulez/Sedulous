﻿using Vulkan;
using static Vulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using System;
using System.Diagnostics;
using System.Runtime.CompilerServices;

namespace Sedulous.GAL.VK
{
    internal unsafe class VKPipeline : Pipeline
    {
        private readonly VKGraphicsDevice _gd;
        private readonly Vulkan.VkPipeline _devicePipeline;
        private readonly VkPipelineLayout _pipelineLayout;
        private readonly VkRenderPass _renderPass;
        private bool _destroyed;
        private string _name;

        public Vulkan.VkPipeline DevicePipeline => _devicePipeline;

        public VkPipelineLayout PipelineLayout => _pipelineLayout;

        public uint ResourceSetCount { get; }
        public int DynamicOffsetsCount { get; }
        public bool ScissorTestEnabled { get; }

        public override bool IsComputePipeline { get; }

        public ResourceRefCount RefCount { get; }

        public override bool IsDisposed => _destroyed;

        public VKPipeline(VKGraphicsDevice gd, ref GraphicsPipelineDescription description)
            : base(ref description)
        {
            _gd = gd;
            IsComputePipeline = false;
            RefCount = new ResourceRefCount(DisposeCore);

            VkGraphicsPipelineCreateInfo pipelineCI = VkGraphicsPipelineCreateInfo.New();

            // Blend State
            VkPipelineColorBlendStateCreateInfo blendStateCI = VkPipelineColorBlendStateCreateInfo.New();
            int attachmentsCount = description.BlendState.AttachmentStates.Length;
            VkPipelineColorBlendAttachmentState* attachmentsPtr
                = stackalloc VkPipelineColorBlendAttachmentState[attachmentsCount];
            for (int i = 0; i < attachmentsCount; i++)
            {
                BlendAttachmentDescription vdDesc = description.BlendState.AttachmentStates[i];
                VkPipelineColorBlendAttachmentState attachmentState = new VkPipelineColorBlendAttachmentState();
                attachmentState.srcColorBlendFactor = VKFormats.VdToVkBlendFactor(vdDesc.SourceColorFactor);
                attachmentState.dstColorBlendFactor = VKFormats.VdToVkBlendFactor(vdDesc.DestinationColorFactor);
                attachmentState.colorBlendOp = VKFormats.VdToVkBlendOp(vdDesc.ColorFunction);
                attachmentState.srcAlphaBlendFactor = VKFormats.VdToVkBlendFactor(vdDesc.SourceAlphaFactor);
                attachmentState.dstAlphaBlendFactor = VKFormats.VdToVkBlendFactor(vdDesc.DestinationAlphaFactor);
                attachmentState.alphaBlendOp = VKFormats.VdToVkBlendOp(vdDesc.AlphaFunction);
                attachmentState.colorWriteMask = VKFormats.VdToVkColorWriteMask(vdDesc.ColorWriteMask.GetOrDefault());
                attachmentState.blendEnable = vdDesc.BlendEnabled;
                attachmentsPtr[i] = attachmentState;
            }

            blendStateCI.attachmentCount = (uint)attachmentsCount;
            blendStateCI.pAttachments = attachmentsPtr;
            RgbaFloat blendFactor = description.BlendState.BlendFactor;
            blendStateCI.blendConstants_0 = blendFactor.R;
            blendStateCI.blendConstants_1 = blendFactor.G;
            blendStateCI.blendConstants_2 = blendFactor.B;
            blendStateCI.blendConstants_3 = blendFactor.A;

            pipelineCI.pColorBlendState = &blendStateCI;

            // Rasterizer State
            RasterizerStateDescription rsDesc = description.RasterizerState;
            VkPipelineRasterizationStateCreateInfo rsCI = VkPipelineRasterizationStateCreateInfo.New();
            rsCI.cullMode = VKFormats.VdToVkCullMode(rsDesc.CullMode);
            rsCI.polygonMode = VKFormats.VdToVkPolygonMode(rsDesc.FillMode);
            rsCI.depthClampEnable = !rsDesc.DepthClipEnabled;
            rsCI.frontFace = rsDesc.FrontFace == FrontFace.Clockwise ? VkFrontFace.Clockwise : VkFrontFace.CounterClockwise;
            rsCI.lineWidth = 1f;

            pipelineCI.pRasterizationState = &rsCI;

            ScissorTestEnabled = rsDesc.ScissorTestEnabled;

            // Dynamic State
            VkPipelineDynamicStateCreateInfo dynamicStateCI = VkPipelineDynamicStateCreateInfo.New();
            VkDynamicState* dynamicStates = stackalloc VkDynamicState[2];
            dynamicStates[0] = VkDynamicState.Viewport;
            dynamicStates[1] = VkDynamicState.Scissor;
            dynamicStateCI.dynamicStateCount = 2;
            dynamicStateCI.pDynamicStates = dynamicStates;

            pipelineCI.pDynamicState = &dynamicStateCI;

            // Depth Stencil State
            DepthStencilStateDescription vdDssDesc = description.DepthStencilState;
            VkPipelineDepthStencilStateCreateInfo dssCI = VkPipelineDepthStencilStateCreateInfo.New();
            dssCI.depthWriteEnable = vdDssDesc.DepthWriteEnabled;
            dssCI.depthTestEnable = vdDssDesc.DepthTestEnabled;
            dssCI.depthCompareOp = VKFormats.VdToVkCompareOp(vdDssDesc.DepthComparison);
            dssCI.stencilTestEnable = vdDssDesc.StencilTestEnabled;

            dssCI.front.failOp = VKFormats.VdToVkStencilOp(vdDssDesc.StencilFront.Fail);
            dssCI.front.passOp = VKFormats.VdToVkStencilOp(vdDssDesc.StencilFront.Pass);
            dssCI.front.depthFailOp = VKFormats.VdToVkStencilOp(vdDssDesc.StencilFront.DepthFail);
            dssCI.front.compareOp = VKFormats.VdToVkCompareOp(vdDssDesc.StencilFront.Comparison);
            dssCI.front.compareMask = vdDssDesc.StencilReadMask;
            dssCI.front.writeMask = vdDssDesc.StencilWriteMask;
            dssCI.front.reference = vdDssDesc.StencilReference;

            dssCI.back.failOp = VKFormats.VdToVkStencilOp(vdDssDesc.StencilBack.Fail);
            dssCI.back.passOp = VKFormats.VdToVkStencilOp(vdDssDesc.StencilBack.Pass);
            dssCI.back.depthFailOp = VKFormats.VdToVkStencilOp(vdDssDesc.StencilBack.DepthFail);
            dssCI.back.compareOp = VKFormats.VdToVkCompareOp(vdDssDesc.StencilBack.Comparison);
            dssCI.back.compareMask = vdDssDesc.StencilReadMask;
            dssCI.back.writeMask = vdDssDesc.StencilWriteMask;
            dssCI.back.reference = vdDssDesc.StencilReference;

            pipelineCI.pDepthStencilState = &dssCI;

            // Multisample
            VkPipelineMultisampleStateCreateInfo multisampleCI = VkPipelineMultisampleStateCreateInfo.New();
            VkSampleCountFlags vkSampleCount = VKFormats.VdToVkSampleCount(description.Outputs.SampleCount);
            multisampleCI.rasterizationSamples = vkSampleCount;
            multisampleCI.alphaToCoverageEnable = description.BlendState.AlphaToCoverageEnabled;

            pipelineCI.pMultisampleState = &multisampleCI;

            // Input Assembly
            VkPipelineInputAssemblyStateCreateInfo inputAssemblyCI = VkPipelineInputAssemblyStateCreateInfo.New();
            inputAssemblyCI.topology = VKFormats.VdToVkPrimitiveTopology(description.PrimitiveTopology);

            pipelineCI.pInputAssemblyState = &inputAssemblyCI;

            // Vertex Input State
            VkPipelineVertexInputStateCreateInfo vertexInputCI = VkPipelineVertexInputStateCreateInfo.New();

            VertexLayoutDescription[] inputDescriptions = description.ShaderSet.VertexLayouts;
            uint bindingCount = (uint)inputDescriptions.Length;
            uint attributeCount = 0;
            for (int i = 0; i < inputDescriptions.Length; i++)
            {
                attributeCount += (uint)inputDescriptions[i].Elements.Length;
            }
            VkVertexInputBindingDescription* bindingDescs = stackalloc VkVertexInputBindingDescription[(int)bindingCount];
            VkVertexInputAttributeDescription* attributeDescs = stackalloc VkVertexInputAttributeDescription[(int)attributeCount];

            int targetIndex = 0;
            int targetLocation = 0;
            for (int binding = 0; binding < inputDescriptions.Length; binding++)
            {
                VertexLayoutDescription inputDesc = inputDescriptions[binding];
                bindingDescs[binding] = new VkVertexInputBindingDescription()
                {
                    binding = (uint)binding,
                    inputRate = (inputDesc.InstanceStepRate != 0) ? VkVertexInputRate.Instance : VkVertexInputRate.Vertex,
                    stride = inputDesc.Stride
                };

                uint currentOffset = 0;
                for (int location = 0; location < inputDesc.Elements.Length; location++)
                {
                    VertexElementDescription inputElement = inputDesc.Elements[location];

                    attributeDescs[targetIndex] = new VkVertexInputAttributeDescription()
                    {
                        format = VKFormats.VdToVkVertexElementFormat(inputElement.Format),
                        binding = (uint)binding,
                        location = (uint)(targetLocation + location),
                        offset = inputElement.Offset != 0 ? inputElement.Offset : currentOffset
                    };

                    targetIndex += 1;
                    currentOffset += FormatSizeHelpers.GetSizeInBytes(inputElement.Format);
                }

                targetLocation += inputDesc.Elements.Length;
            }

            vertexInputCI.vertexBindingDescriptionCount = bindingCount;
            vertexInputCI.pVertexBindingDescriptions = bindingDescs;
            vertexInputCI.vertexAttributeDescriptionCount = attributeCount;
            vertexInputCI.pVertexAttributeDescriptions = attributeDescs;

            pipelineCI.pVertexInputState = &vertexInputCI;

            // Shader Stage

            VkSpecializationInfo specializationInfo;
            SpecializationConstant[] specDescs = description.ShaderSet.Specializations;
            if (specDescs != null)
            {
                uint specDataSize = 0;
                foreach (SpecializationConstant spec in specDescs)
                {
                    specDataSize += VKFormats.GetSpecializationConstantSize(spec.Type);
                }
                byte* fullSpecData = stackalloc byte[(int)specDataSize];
                int specializationCount = specDescs.Length;
                VkSpecializationMapEntry* mapEntries = stackalloc VkSpecializationMapEntry[specializationCount];
                uint specOffset = 0;
                for (int i = 0; i < specializationCount; i++)
                {
                    ulong data = specDescs[i].Data;
                    byte* srcData = (byte*)&data;
                    uint dataSize = VKFormats.GetSpecializationConstantSize(specDescs[i].Type);
                    Unsafe.CopyBlock(fullSpecData + specOffset, srcData, dataSize);
                    mapEntries[i].constantID = specDescs[i].ID;
                    mapEntries[i].offset = specOffset;
                    mapEntries[i].size = (UIntPtr)dataSize;
                    specOffset += dataSize;
                }
                specializationInfo.dataSize = (UIntPtr)specDataSize;
                specializationInfo.pData = fullSpecData;
                specializationInfo.mapEntryCount = (uint)specializationCount;
                specializationInfo.pMapEntries = mapEntries;
            }

            Shader[] shaders = description.ShaderSet.Shaders;
            StackList<VkPipelineShaderStageCreateInfo> stages = new StackList<VkPipelineShaderStageCreateInfo>();
            foreach (Shader shader in shaders)
            {
                VKShader vkShader = Util.AssertSubtype<Shader, VKShader>(shader);
                VkPipelineShaderStageCreateInfo stageCI = VkPipelineShaderStageCreateInfo.New();
                stageCI.module = vkShader.ShaderModule;
                stageCI.stage = VKFormats.VdToVkShaderStages(shader.Stage);
                // stageCI.pName = CommonStrings.main; // Meh
                stageCI.pName = new FixedUtf8String(shader.EntryPoint); // TODO: DONT ALLOCATE HERE
                stageCI.pSpecializationInfo = &specializationInfo;
                stages.Add(stageCI);
            }

            pipelineCI.stageCount = stages.Count;
            pipelineCI.pStages = (VkPipelineShaderStageCreateInfo*)stages.Data;

            // ViewportState
            VkPipelineViewportStateCreateInfo viewportStateCI = VkPipelineViewportStateCreateInfo.New();
            viewportStateCI.viewportCount = 1;
            viewportStateCI.scissorCount = 1;

            pipelineCI.pViewportState = &viewportStateCI;

            // Pipeline Layout
            ResourceLayout[] resourceLayouts = description.ResourceLayouts;
            VkPipelineLayoutCreateInfo pipelineLayoutCI = VkPipelineLayoutCreateInfo.New();
            pipelineLayoutCI.setLayoutCount = (uint)resourceLayouts.Length;
            VkDescriptorSetLayout* dsls = stackalloc VkDescriptorSetLayout[resourceLayouts.Length];
            for (int i = 0; i < resourceLayouts.Length; i++)
            {
                dsls[i] = Util.AssertSubtype<ResourceLayout, VKResourceLayout>(resourceLayouts[i]).DescriptorSetLayout;
            }
            pipelineLayoutCI.pSetLayouts = dsls;

            vkCreatePipelineLayout(_gd.Device, ref pipelineLayoutCI, null, out _pipelineLayout);
            pipelineCI.layout = _pipelineLayout;

            // Create fake RenderPass for compatibility.

            VkRenderPassCreateInfo renderPassCI = VkRenderPassCreateInfo.New();
            OutputDescription outputDesc = description.Outputs;
            StackList<VkAttachmentDescription, Size512Bytes> attachments = new StackList<VkAttachmentDescription, Size512Bytes>();

            // TODO: A huge portion of this next part is duplicated in VkFramebuffer.cs.

            StackList<VkAttachmentDescription> colorAttachmentDescs = new StackList<VkAttachmentDescription>();
            StackList<VkAttachmentReference> colorAttachmentRefs = new StackList<VkAttachmentReference>();
            for (uint i = 0; i < outputDesc.ColorAttachments.Length; i++)
            {
                colorAttachmentDescs[i].format = VKFormats.VdToVkPixelFormat(outputDesc.ColorAttachments[i].Format);
                colorAttachmentDescs[i].samples = vkSampleCount;
                colorAttachmentDescs[i].loadOp = VkAttachmentLoadOp.DontCare;
                colorAttachmentDescs[i].storeOp = VkAttachmentStoreOp.Store;
                colorAttachmentDescs[i].stencilLoadOp = VkAttachmentLoadOp.DontCare;
                colorAttachmentDescs[i].stencilStoreOp = VkAttachmentStoreOp.DontCare;
                colorAttachmentDescs[i].initialLayout = VkImageLayout.Undefined;
                colorAttachmentDescs[i].finalLayout = VkImageLayout.ShaderReadOnlyOptimal;
                attachments.Add(colorAttachmentDescs[i]);

                colorAttachmentRefs[i].attachment = i;
                colorAttachmentRefs[i].layout = VkImageLayout.ColorAttachmentOptimal;
            }

            VkAttachmentDescription depthAttachmentDesc = new VkAttachmentDescription();
            VkAttachmentReference depthAttachmentRef = new VkAttachmentReference();
            if (outputDesc.DepthAttachment != null)
            {
                PixelFormat depthFormat = outputDesc.DepthAttachment.Value.Format;
                bool hasStencil = FormatHelpers.IsStencilFormat(depthFormat);
                depthAttachmentDesc.format = VKFormats.VdToVkPixelFormat(outputDesc.DepthAttachment.Value.Format, toDepthFormat: true);
                depthAttachmentDesc.samples = vkSampleCount;
                depthAttachmentDesc.loadOp = VkAttachmentLoadOp.DontCare;
                depthAttachmentDesc.storeOp = VkAttachmentStoreOp.Store;
                depthAttachmentDesc.stencilLoadOp = VkAttachmentLoadOp.DontCare;
                depthAttachmentDesc.stencilStoreOp = hasStencil ? VkAttachmentStoreOp.Store : VkAttachmentStoreOp.DontCare;
                depthAttachmentDesc.initialLayout = VkImageLayout.Undefined;
                depthAttachmentDesc.finalLayout = VkImageLayout.DepthStencilAttachmentOptimal;

                depthAttachmentRef.attachment = (uint)outputDesc.ColorAttachments.Length;
                depthAttachmentRef.layout = VkImageLayout.DepthStencilAttachmentOptimal;
            }

            VkSubpassDescription subpass = new VkSubpassDescription();
            subpass.pipelineBindPoint = VkPipelineBindPoint.Graphics;
            subpass.colorAttachmentCount = (uint)outputDesc.ColorAttachments.Length;
            subpass.pColorAttachments = (VkAttachmentReference*)colorAttachmentRefs.Data;
            for (int i = 0; i < colorAttachmentDescs.Count; i++)
            {
                attachments.Add(colorAttachmentDescs[i]);
            }

            if (outputDesc.DepthAttachment != null)
            {
                subpass.pDepthStencilAttachment = &depthAttachmentRef;
                attachments.Add(depthAttachmentDesc);
            }

            VkSubpassDependency subpassDependency = new VkSubpassDependency();
            subpassDependency.srcSubpass = SubpassExternal;
            subpassDependency.srcStageMask = VkPipelineStageFlags.ColorAttachmentOutput;
            subpassDependency.dstStageMask = VkPipelineStageFlags.ColorAttachmentOutput;
            subpassDependency.dstAccessMask = VkAccessFlags.ColorAttachmentRead | VkAccessFlags.ColorAttachmentWrite;

            renderPassCI.attachmentCount = attachments.Count;
            renderPassCI.pAttachments = (VkAttachmentDescription*)attachments.Data;
            renderPassCI.subpassCount = 1;
            renderPassCI.pSubpasses = &subpass;
            renderPassCI.dependencyCount = 1;
            renderPassCI.pDependencies = &subpassDependency;

            VkResult creationResult = vkCreateRenderPass(_gd.Device, ref renderPassCI, null, out _renderPass);
            CheckResult(creationResult);

            pipelineCI.renderPass = _renderPass;

            VkResult result = vkCreateGraphicsPipelines(_gd.Device, VkPipelineCache.Null, 1, ref pipelineCI, null, out _devicePipeline);
            CheckResult(result);

            ResourceSetCount = (uint)description.ResourceLayouts.Length;
            DynamicOffsetsCount = 0;
            foreach (VKResourceLayout layout in description.ResourceLayouts)
            {
                DynamicOffsetsCount += layout.DynamicBufferCount;
            }
        }

        public VKPipeline(VKGraphicsDevice gd, ref ComputePipelineDescription description)
            : base(ref description)
        {
            _gd = gd;
            IsComputePipeline = true;
            RefCount = new ResourceRefCount(DisposeCore);

            VkComputePipelineCreateInfo pipelineCI = VkComputePipelineCreateInfo.New();

            // Pipeline Layout
            ResourceLayout[] resourceLayouts = description.ResourceLayouts;
            VkPipelineLayoutCreateInfo pipelineLayoutCI = VkPipelineLayoutCreateInfo.New();
            pipelineLayoutCI.setLayoutCount = (uint)resourceLayouts.Length;
            VkDescriptorSetLayout* dsls = stackalloc VkDescriptorSetLayout[resourceLayouts.Length];
            for (int i = 0; i < resourceLayouts.Length; i++)
            {
                dsls[i] = Util.AssertSubtype<ResourceLayout, VKResourceLayout>(resourceLayouts[i]).DescriptorSetLayout;
            }
            pipelineLayoutCI.pSetLayouts = dsls;

            vkCreatePipelineLayout(_gd.Device, ref pipelineLayoutCI, null, out _pipelineLayout);
            pipelineCI.layout = _pipelineLayout;

            // Shader Stage

            VkSpecializationInfo specializationInfo;
            SpecializationConstant[] specDescs = description.Specializations;
            if (specDescs != null)
            {
                uint specDataSize = 0;
                foreach (SpecializationConstant spec in specDescs)
                {
                    specDataSize += VKFormats.GetSpecializationConstantSize(spec.Type);
                }
                byte* fullSpecData = stackalloc byte[(int)specDataSize];
                int specializationCount = specDescs.Length;
                VkSpecializationMapEntry* mapEntries = stackalloc VkSpecializationMapEntry[specializationCount];
                uint specOffset = 0;
                for (int i = 0; i < specializationCount; i++)
                {
                    ulong data = specDescs[i].Data;
                    byte* srcData = (byte*)&data;
                    uint dataSize = VKFormats.GetSpecializationConstantSize(specDescs[i].Type);
                    Unsafe.CopyBlock(fullSpecData + specOffset, srcData, dataSize);
                    mapEntries[i].constantID = specDescs[i].ID;
                    mapEntries[i].offset = specOffset;
                    mapEntries[i].size = (UIntPtr)dataSize;
                    specOffset += dataSize;
                }
                specializationInfo.dataSize = (UIntPtr)specDataSize;
                specializationInfo.pData = fullSpecData;
                specializationInfo.mapEntryCount = (uint)specializationCount;
                specializationInfo.pMapEntries = mapEntries;
            }

            Shader shader = description.ComputeShader;
            VKShader vkShader = Util.AssertSubtype<Shader, VKShader>(shader);
            VkPipelineShaderStageCreateInfo stageCI = VkPipelineShaderStageCreateInfo.New();
            stageCI.module = vkShader.ShaderModule;
            stageCI.stage = VKFormats.VdToVkShaderStages(shader.Stage);
            stageCI.pName = CommonStrings.main; // Meh
            stageCI.pSpecializationInfo = &specializationInfo;
            pipelineCI.stage = stageCI;

            VkResult result = vkCreateComputePipelines(
                _gd.Device,
                VkPipelineCache.Null,
                1,
                ref pipelineCI,
                null,
                out _devicePipeline);
            CheckResult(result);

            ResourceSetCount = (uint)description.ResourceLayouts.Length;
            DynamicOffsetsCount = 0;
            foreach (VKResourceLayout layout in description.ResourceLayouts)
            {
                DynamicOffsetsCount += layout.DynamicBufferCount;
            }
        }

        public override string Name
        {
            get => _name;
            set
            {
                _name = value;
                _gd.SetResourceName(this, value);
            }
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
                vkDestroyPipelineLayout(_gd.Device, _pipelineLayout, null);
                vkDestroyPipeline(_gd.Device, _devicePipeline, null);
                if (!IsComputePipeline)
                {
                    vkDestroyRenderPass(_gd.Device, _renderPass, null);
                }
            }
        }
    }
}
