using Bulkan;
using static Bulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using System;
using System.Diagnostics;
using System.Collections;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.VK;

    public class VKPipeline : Pipeline
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkPipeline _devicePipeline;
        private readonly VkPipelineLayout _pipelineLayout;
        private readonly VkRenderPass _renderPass;
        private bool _destroyed;
        private String _name;

        public VkPipeline DevicePipeline => _devicePipeline;

        public VkPipelineLayout PipelineLayout => _pipelineLayout;

        public uint32 ResourceSetCount { get; }
        public int32 DynamicOffsetsCount { get; }
        public bool ScissorTestEnabled { get; }

        public override bool IsComputePipeline { get; protected set; }

        internal ResourceRefCount RefCount { get; }

        public override bool IsDisposed => _destroyed;

        public this(VKGraphicsDevice gd, in GraphicsPipelineDescription description)
            : base(description)
        {
            _gd = gd;
            IsComputePipeline = false;
            RefCount = new ResourceRefCount(new => DisposeCore);

            VkGraphicsPipelineCreateInfo pipelineCI = VkGraphicsPipelineCreateInfo(){sType = .VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO};

            // Blend State
            VkPipelineColorBlendStateCreateInfo blendStateCI = VkPipelineColorBlendStateCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO};
            int attachmentsCount = description.BlendState.AttachmentStates.Count;
            VkPipelineColorBlendAttachmentState* attachmentsPtr
                = scope VkPipelineColorBlendAttachmentState[attachmentsCount]*;
            for (int32 i = 0; i < attachmentsCount; i++)
            {
                BlendAttachmentDescription vdDesc = description.BlendState.AttachmentStates[i];
                VkPipelineColorBlendAttachmentState attachmentState = VkPipelineColorBlendAttachmentState();
                attachmentState.srcColorBlendFactor = VKFormats.VdToVkBlendFactor(vdDesc.SourceColorFactor);
                attachmentState.dstColorBlendFactor = VKFormats.VdToVkBlendFactor(vdDesc.DestinationColorFactor);
                attachmentState.colorBlendOp = VKFormats.VdToVkBlendOp(vdDesc.ColorFunction);
                attachmentState.srcAlphaBlendFactor = VKFormats.VdToVkBlendFactor(vdDesc.SourceAlphaFactor);
                attachmentState.dstAlphaBlendFactor = VKFormats.VdToVkBlendFactor(vdDesc.DestinationAlphaFactor);
                attachmentState.alphaBlendOp = VKFormats.VdToVkBlendOp(vdDesc.AlphaFunction);
                attachmentState.colorWriteMask = VKFormats.VdToVkColorWriteMask(vdDesc.ColorWriteMask.GetValueOrDefault());
                attachmentState.blendEnable = vdDesc.BlendEnabled;
                attachmentsPtr[i] = attachmentState;
            }

            blendStateCI.attachmentCount = (uint32)attachmentsCount;
            blendStateCI.pAttachments = attachmentsPtr;
            RgbaFloat blendFactor = description.BlendState.BlendFactor;
            blendStateCI.blendConstants[0] = blendFactor.R;
            blendStateCI.blendConstants[1] = blendFactor.G;
            blendStateCI.blendConstants[2] = blendFactor.B;
            blendStateCI.blendConstants[3] = blendFactor.A;

            pipelineCI.pColorBlendState = &blendStateCI;

            // Rasterizer State
            RasterizerStateDescription rsDesc = description.RasterizerState;
            VkPipelineRasterizationStateCreateInfo rsCI = VkPipelineRasterizationStateCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO};
            rsCI.cullMode = VKFormats.VdToVkCullMode(rsDesc.CullMode);
            rsCI.polygonMode = VKFormats.VdToVkPolygonMode(rsDesc.FillMode);
            rsCI.depthClampEnable = !rsDesc.DepthClipEnabled;
            rsCI.frontFace = rsDesc.FrontFace == FrontFace.Clockwise ? VkFrontFace.VK_FRONT_FACE_CLOCKWISE : VkFrontFace.VK_FRONT_FACE_COUNTER_CLOCKWISE;
            rsCI.lineWidth = 1f;

            pipelineCI.pRasterizationState = &rsCI;

            ScissorTestEnabled = rsDesc.ScissorTestEnabled;

            // Dynamic State
            VkPipelineDynamicStateCreateInfo dynamicStateCI = VkPipelineDynamicStateCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO};
            VkDynamicState* dynamicStates = scope VkDynamicState[2]*;
            dynamicStates[0] = VkDynamicState.VK_DYNAMIC_STATE_VIEWPORT;
            dynamicStates[1] = VkDynamicState.VK_DYNAMIC_STATE_SCISSOR;
            dynamicStateCI.dynamicStateCount = 2;
            dynamicStateCI.pDynamicStates = dynamicStates;

            pipelineCI.pDynamicState = &dynamicStateCI;

            // Depth Stencil State
            DepthStencilStateDescription vdDssDesc = description.DepthStencilState;
            VkPipelineDepthStencilStateCreateInfo dssCI = VkPipelineDepthStencilStateCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO};
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
            VkPipelineMultisampleStateCreateInfo multisampleCI = VkPipelineMultisampleStateCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO};
            VkSampleCountFlags vkSampleCount = VKFormats.VdToVkSampleCount(description.Outputs.SampleCount);
            multisampleCI.rasterizationSamples = vkSampleCount;
            multisampleCI.alphaToCoverageEnable = description.BlendState.AlphaToCoverageEnabled;

            pipelineCI.pMultisampleState = &multisampleCI;

            // Input Assembly
            VkPipelineInputAssemblyStateCreateInfo inputAssemblyCI = VkPipelineInputAssemblyStateCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO};
            inputAssemblyCI.topology = VKFormats.VdToVkPrimitiveTopology(description.PrimitiveTopology);

            pipelineCI.pInputAssemblyState = &inputAssemblyCI;

            // Vertex Input State
            VkPipelineVertexInputStateCreateInfo vertexInputCI = VkPipelineVertexInputStateCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO};

            VertexLayoutDescription[] inputDescriptions = description.ShaderSet.VertexLayouts;
            uint32 bindingCount = (uint32)inputDescriptions.Count;
            uint32 attributeCount = 0;
            for (int i = 0; i < inputDescriptions.Count; i++)
            {
                attributeCount += (uint32)inputDescriptions[i].Elements.Count;
            }
            VkVertexInputBindingDescription* bindingDescs = scope VkVertexInputBindingDescription[(int32)bindingCount]*;
            VkVertexInputAttributeDescription* attributeDescs = scope VkVertexInputAttributeDescription[(int32)attributeCount]*;

            int32 targetIndex = 0;
            int targetLocation = 0;
            for (int binding = 0; binding < inputDescriptions.Count; binding++)
            {
                VertexLayoutDescription inputDesc = inputDescriptions[binding];
                bindingDescs[binding] = VkVertexInputBindingDescription()
                {
                    binding = (uint32)binding,
                    inputRate = (inputDesc.InstanceStepRate != 0) ? VkVertexInputRate.VK_VERTEX_INPUT_RATE_INSTANCE : VkVertexInputRate.VK_VERTEX_INPUT_RATE_VERTEX,
                    stride = inputDesc.Stride
                };

                uint32 currentOffset = 0;
                for (int location = 0; location < inputDesc.Elements.Count; location++)
                {
                    VertexElementDescription inputElement = inputDesc.Elements[location];

                    attributeDescs[targetIndex] = VkVertexInputAttributeDescription()
                    {
                        format = VKFormats.VdToVkVertexElementFormat(inputElement.Format),
                        binding = (uint32)binding,
                        location = (uint32)(targetLocation + location),
                        offset = inputElement.Offset != 0 ? inputElement.Offset : currentOffset
                    };

                    targetIndex += 1;
                    currentOffset += FormatSizeHelpers.GetSizeInBytes(inputElement.Format);
                }

                targetLocation += inputDesc.Elements.Count;
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
                uint32 specDataSize = 0;
                for (SpecializationConstant spec in specDescs)
                {
                    specDataSize += VKFormats.GetSpecializationConstantSize(spec.Type);
                }
                uint8* fullSpecData = scope uint8[(int32)specDataSize]*;
                int specializationCount = specDescs.Count;
                VkSpecializationMapEntry* mapEntries = scope VkSpecializationMapEntry[specializationCount]*;
                uint32 specOffset = 0;
                for (int i = 0; i < specializationCount; i++)
                {
                    uint64 data = specDescs[i].Data;
                    uint8* srcData = (uint8*)&data;
                    uint32 dataSize = VKFormats.GetSpecializationConstantSize(specDescs[i].Type);
                    Internal.MemCpy(fullSpecData + specOffset, srcData, dataSize);
                    mapEntries[i].constantID = specDescs[i].ID;
                    mapEntries[i].offset = specOffset;
                    mapEntries[i].size = (uint)dataSize;
                    specOffset += dataSize;
                }
                specializationInfo.dataSize = (uint)specDataSize;
                specializationInfo.pData = fullSpecData;
                specializationInfo.mapEntryCount = (uint32)specializationCount;
                specializationInfo.pMapEntries = mapEntries;
            }

            Shader[] shaders = description.ShaderSet.Shaders;
            List<VkPipelineShaderStageCreateInfo> stages = scope .();
            for (Shader shader in shaders)
            {
                VKShader vkShader = Util.AssertSubtype<Shader, VKShader>(shader);
                VkPipelineShaderStageCreateInfo stageCI = VkPipelineShaderStageCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO};
                stageCI.module = vkShader.ShaderModule;
                stageCI.stage = VKFormats.VdToVkShaderStages(shader.Stage);
                stageCI.pName = scope :: String(shader.EntryPoint).CStr();
                stageCI.pSpecializationInfo = &specializationInfo;
                stages.Add(stageCI);
            }

            pipelineCI.stageCount = (uint32)stages.Count;
            pipelineCI.pStages = (VkPipelineShaderStageCreateInfo*)stages.Ptr;

            // ViewportState
            VkPipelineViewportStateCreateInfo viewportStateCI = VkPipelineViewportStateCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO};
            viewportStateCI.viewportCount = 1;
            viewportStateCI.scissorCount = 1;

            pipelineCI.pViewportState = &viewportStateCI;

            // Pipeline Layout
            ResourceLayout[] resourceLayouts = description.ResourceLayouts;
            VkPipelineLayoutCreateInfo pipelineLayoutCI = VkPipelineLayoutCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO};
            pipelineLayoutCI.setLayoutCount = (uint32)resourceLayouts.Count;
            VkDescriptorSetLayout* dsls = scope VkDescriptorSetLayout[resourceLayouts.Count]*;
            for (int i = 0; i < resourceLayouts.Count; i++)
            {
                dsls[i] = Util.AssertSubtype<ResourceLayout, VKResourceLayout>(resourceLayouts[i]).DescriptorSetLayout;
            }
            pipelineLayoutCI.pSetLayouts = dsls;

            vkCreatePipelineLayout(_gd.Device, &pipelineLayoutCI, null, &_pipelineLayout);
            pipelineCI.layout = _pipelineLayout;

            // Create fake RenderPass for compatibility.

            VkRenderPassCreateInfo renderPassCI = VkRenderPassCreateInfo(){sType = .VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO};
            OutputDescription outputDesc = description.Outputs;
            List<VkAttachmentDescription> attachments = scope .();

            // TODO: A huge portion of this next part is duplicated in VkFramebuffer.cs.

            List<VkAttachmentDescription> colorAttachmentDescs = scope .() { Count = outputDesc.ColorAttachments.Count};
            List<VkAttachmentReference> colorAttachmentRefs = scope .() { Count = outputDesc.ColorAttachments.Count };
            for (uint32 i = 0; i < outputDesc.ColorAttachments.Count; i++)
            {
                colorAttachmentDescs[i].format = VKFormats.VdToVkPixelFormat(outputDesc.ColorAttachments[i].Format);
                colorAttachmentDescs[i].samples = vkSampleCount;
                colorAttachmentDescs[i].loadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE;
                colorAttachmentDescs[i].storeOp = VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE;
                colorAttachmentDescs[i].stencilLoadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE;
                colorAttachmentDescs[i].stencilStoreOp = VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE;
                colorAttachmentDescs[i].initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
                colorAttachmentDescs[i].finalLayout = VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
                attachments.Add(colorAttachmentDescs[i]);

                colorAttachmentRefs[i].attachment = i;
                colorAttachmentRefs[i].layout = VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
            }

            VkAttachmentDescription depthAttachmentDesc = VkAttachmentDescription();
            VkAttachmentReference depthAttachmentRef = VkAttachmentReference();
            if (outputDesc.DepthAttachment != null)
            {
                PixelFormat depthFormat = outputDesc.DepthAttachment.Value.Format;
                bool hasStencil = FormatHelpers.IsStencilFormat(depthFormat);
                depthAttachmentDesc.format = VKFormats.VdToVkPixelFormat(outputDesc.DepthAttachment.Value.Format, toDepthFormat: true);
                depthAttachmentDesc.samples = vkSampleCount;
                depthAttachmentDesc.loadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE;
                depthAttachmentDesc.storeOp = VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE;
                depthAttachmentDesc.stencilLoadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE;
                depthAttachmentDesc.stencilStoreOp = hasStencil ? VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE : VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE;
                depthAttachmentDesc.initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
                depthAttachmentDesc.finalLayout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;

                depthAttachmentRef.attachment = (uint32)outputDesc.ColorAttachments.Count;
                depthAttachmentRef.layout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
            }

            VkSubpassDescription subpass = VkSubpassDescription();
            subpass.pipelineBindPoint = VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS;
            subpass.colorAttachmentCount = (uint32)outputDesc.ColorAttachments.Count;
            subpass.pColorAttachments = (VkAttachmentReference*)colorAttachmentRefs.Ptr;
            for (int i = 0; i < colorAttachmentDescs.Count; i++)
            {
                attachments.Add(colorAttachmentDescs[i]);
            }

            if (outputDesc.DepthAttachment != null)
            {
                subpass.pDepthStencilAttachment = &depthAttachmentRef;
                attachments.Add(depthAttachmentDesc);
            }

            VkSubpassDependency subpassDependency = VkSubpassDependency();
            subpassDependency.srcSubpass = VK_SUBPASS_EXTERNAL;
            subpassDependency.srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
            subpassDependency.dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
            subpassDependency.dstAccessMask = VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;

            renderPassCI.attachmentCount = (uint32)attachments.Count;
            renderPassCI.pAttachments = (VkAttachmentDescription*)attachments.Ptr;
            renderPassCI.subpassCount = 1;
            renderPassCI.pSubpasses = &subpass;
            renderPassCI.dependencyCount = 1;
            renderPassCI.pDependencies = &subpassDependency;

            VkResult creationResult = vkCreateRenderPass(_gd.Device, &renderPassCI, null, &_renderPass);
            CheckResult(creationResult);

            pipelineCI.renderPass = _renderPass;

            VkResult result = vkCreateGraphicsPipelines(_gd.Device, VkPipelineCache.Null, 1, &pipelineCI, null, &_devicePipeline);
            CheckResult(result);

            ResourceSetCount = (uint32)description.ResourceLayouts.Count;
            DynamicOffsetsCount = 0;
            for (VKResourceLayout layout in description.ResourceLayouts)
            {
                DynamicOffsetsCount += layout.DynamicBufferCount;
            }
        }

        public this(VKGraphicsDevice gd, in ComputePipelineDescription description)
            : base(description)
        {
            _gd = gd;
            IsComputePipeline = true;
            RefCount = new ResourceRefCount(new => DisposeCore);

            VkComputePipelineCreateInfo pipelineCI = VkComputePipelineCreateInfo(){sType = .VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO};

            // Pipeline Layout
            ResourceLayout[] resourceLayouts = description.ResourceLayouts;
            VkPipelineLayoutCreateInfo pipelineLayoutCI = VkPipelineLayoutCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO};
            pipelineLayoutCI.setLayoutCount = (uint32)resourceLayouts.Count;
            VkDescriptorSetLayout* dsls = scope VkDescriptorSetLayout[resourceLayouts.Count]*;
            for (int i = 0; i < resourceLayouts.Count; i++)
            {
                dsls[i] = Util.AssertSubtype<ResourceLayout, VKResourceLayout>(resourceLayouts[i]).DescriptorSetLayout;
            }
            pipelineLayoutCI.pSetLayouts = dsls;

            vkCreatePipelineLayout(_gd.Device, &pipelineLayoutCI, null, &_pipelineLayout);
            pipelineCI.layout = _pipelineLayout;

            // Shader Stage

            VkSpecializationInfo specializationInfo;
            SpecializationConstant[] specDescs = description.Specializations;
            if (specDescs != null)
            {
                uint32 specDataSize = 0;
                for (SpecializationConstant spec in specDescs)
                {
                    specDataSize += VKFormats.GetSpecializationConstantSize(spec.Type);
                }
                uint8* fullSpecData = scope uint8[(int32)specDataSize]*;
                int specializationCount = specDescs.Count;
                VkSpecializationMapEntry* mapEntries = scope VkSpecializationMapEntry[specializationCount]*;
                uint32 specOffset = 0;
                for (int i = 0; i < specializationCount; i++)
                {
                    uint64 data = specDescs[i].Data;
                    uint8* srcData = (uint8*)&data;
                    uint32 dataSize = VKFormats.GetSpecializationConstantSize(specDescs[i].Type);
                    Internal.MemCpy(fullSpecData + specOffset, srcData, dataSize);
                    mapEntries[i].constantID = specDescs[i].ID;
                    mapEntries[i].offset = specOffset;
                    mapEntries[i].size = (uint)dataSize;
                    specOffset += dataSize;
                }
                specializationInfo.dataSize = (uint)specDataSize;
                specializationInfo.pData = fullSpecData;
                specializationInfo.mapEntryCount = (uint32)specializationCount;
                specializationInfo.pMapEntries = mapEntries;
            }

            Shader shader = description.ComputeShader;
            VKShader vkShader = Util.AssertSubtype<Shader, VKShader>(shader);
            VkPipelineShaderStageCreateInfo stageCI = VkPipelineShaderStageCreateInfo(){sType = .VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO};
            stageCI.module = vkShader.ShaderModule;
            stageCI.stage = VKFormats.VdToVkShaderStages(shader.Stage);
            stageCI.pName = CommonStrings.main; // Meh
            stageCI.pSpecializationInfo = &specializationInfo;
            pipelineCI.stage = stageCI;

            VkResult result = vkCreateComputePipelines(
                _gd.Device,
                VkPipelineCache.Null,
                1,
                &pipelineCI,
                null,
                &_devicePipeline);
            CheckResult(result);

            ResourceSetCount = (uint32)description.ResourceLayouts.Count;
            DynamicOffsetsCount = 0;
            for (VKResourceLayout layout in description.ResourceLayouts)
            {
                DynamicOffsetsCount += layout.DynamicBufferCount;
            }
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
