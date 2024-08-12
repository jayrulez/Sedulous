using static Sedulous.OpenGLBindings.OpenGLNative;
using static Sedulous.GAL.OpenGL.OpenGLUtil;
using Sedulous.OpenGLBindings;
using System.Text;
using System.Diagnostics;
using System.Collections.Generic;
using System;

namespace Sedulous.GAL.OpenGL
{
    internal class OpenGLPipeline : Pipeline, OpenGLDeferredResource
    {
        private const uint32 GL_INVALID_INDEX = 0xFFFFFFFF;
        private readonly OpenGLGraphicsDevice _gd;

#if !VALIDATE_USAGE
        public ResourceLayout[] ResourceLayouts { get; }
#endif

        // Graphics Pipeline
        public Shader[] GraphicsShaders { get; }
        public VertexLayoutDescription[] VertexLayouts { get; }
        public BlendStateDescription BlendState { get; }
        public DepthStencilStateDescription DepthStencilState { get; }
        public RasterizerStateDescription RasterizerState { get; }
        public PrimitiveTopology PrimitiveTopology { get; }

        // Compute Pipeline
        public override bool IsComputePipeline { get; }
        public Shader ComputeShader { get; }

        private uint32 _program;
        private bool _disposeRequested;
        private bool _disposed;

        private SetBindingsInfo[] _setInfos;

        public int32[] VertexStrides { get; }

        public uint32 Program => _program;

        public uint32 GetUniformBufferCount(uint32 setSlot) => _setInfos[setSlot].UniformBufferCount;
        public uint32 GetShaderStorageBufferCount(uint32 setSlot) => _setInfos[setSlot].ShaderStorageBufferCount;

        public override string Name { get; set; }

        public override bool IsDisposed => _disposeRequested;

        public OpenGLPipeline(OpenGLGraphicsDevice gd, ref GraphicsPipelineDescription description)
            : base(ref description)
        {
            _gd = gd;
            GraphicsShaders = Util.ShallowClone(description.ShaderSet.Shaders);
            VertexLayouts = Util.ShallowClone(description.ShaderSet.VertexLayouts);
            BlendState = description.BlendState.ShallowClone();
            DepthStencilState = description.DepthStencilState;
            RasterizerState = description.RasterizerState;
            PrimitiveTopology = description.PrimitiveTopology;

            int32 numVertexBuffers = description.ShaderSet.VertexLayouts.Length;
            VertexStrides = new int32[numVertexBuffers];
            for (int32 i = 0; i < numVertexBuffers; i++)
            {
                VertexStrides[i] = (int32)description.ShaderSet.VertexLayouts[i].Stride;
            }

#if !VALIDATE_USAGE
            ResourceLayouts = Util.ShallowClone(description.ResourceLayouts);
#endif
        }

        public OpenGLPipeline(OpenGLGraphicsDevice gd, ref ComputePipelineDescription description)
            : base(ref description)
        {
            _gd = gd;
            IsComputePipeline = true;
            ComputeShader = description.ComputeShader;
            VertexStrides = Array.Empty<int32>();
#if !VALIDATE_USAGE
            ResourceLayouts = Util.ShallowClone(description.ResourceLayouts);
#endif
        }

        public bool Created { get; private set; }

        public void EnsureResourcesCreated()
        {
            if (!Created)
            {
                CreateGLResources();
            }
        }

        private void CreateGLResources()
        {
            if (!IsComputePipeline)
            {
                CreateGraphicsGLResources();
            }
            else
            {
                CreateComputeGLResources();
            }

            Created = true;
        }

        private void CreateGraphicsGLResources()
        {
            _program = glCreateProgram();
            CheckLastError();
            for (Shader stage in GraphicsShaders)
            {
                OpenGLShader glShader = Util.AssertSubtype<Shader, OpenGLShader>(stage);
                glShader.EnsureResourcesCreated();
                glAttachShader(_program, glShader.Shader);
                CheckLastError();
            }

            uint32 slot = 0;
            for (VertexLayoutDescription layoutDesc in VertexLayouts)
            {
                for (int32 i = 0; i < layoutDesc.Elements.Length; i++)
                {
                    BindAttribLocation(slot, layoutDesc.Elements[i].Name);
                    slot += 1;
                }
            }

            glLinkProgram(_program);
            CheckLastError();

#if DEBUG && GL_VALIDATE_VERTEX_INPUT_ELEMENTS
            slot = 0;
            for (VertexLayoutDescription layoutDesc in VertexLayouts)
            {
                for (int32 i = 0; i < layoutDesc.Elements.Length; i++)
                {
                    int32 location = GetAttribLocation(layoutDesc.Elements[i].Name);
                    if (location == -1)
                    {
                        Runtime.GALError("There was no attribute variable with the name " + layoutDesc.Elements[i].Name);
                    }

                    slot += 1;
                }
            }
#endif

            int32 linkStatus;
            glGetProgramiv(_program, GetProgramParameterName.LinkStatus, &linkStatus);
            CheckLastError();
            if (linkStatus != 1)
            {
                uint8* infoLog = stackalloc uint8[4096];
                uint32 bytesWritten;
                glGetProgramInfoLog(_program, 4096, &bytesWritten, infoLog);
                CheckLastError();
                string log = Encoding.UTF8.GetString(infoLog, (int32)bytesWritten);
                Runtime.GALError($"Error linking GL program: {log}");
            }

            ProcessResourceSetLayouts(ResourceLayouts);
        }

        int32 GetAttribLocation(string elementName)
        {
            int32 byteCount = Encoding.UTF8.GetByteCount(elementName) + 1;
            uint8* elementNamePtr = stackalloc uint8[byteCount];
            fixed (char* charPtr = elementName)
            {
                int32 bytesWritten = Encoding.UTF8.GetBytes(charPtr, elementName.Length, elementNamePtr, byteCount);
                Debug.Assert(bytesWritten == byteCount - 1);
            }
            elementNamePtr[byteCount - 1] = 0; // Add null terminator.

            int32 location = glGetAttribLocation(_program, elementNamePtr);
            return location;
        }

        void BindAttribLocation(uint32 slot, string elementName)
        {
            int32 byteCount = Encoding.UTF8.GetByteCount(elementName) + 1;
            uint8* elementNamePtr = stackalloc uint8[byteCount];
            fixed (char* charPtr = elementName)
            {
                int32 bytesWritten = Encoding.UTF8.GetBytes(charPtr, elementName.Length, elementNamePtr, byteCount);
                Debug.Assert(bytesWritten == byteCount - 1);
            }
            elementNamePtr[byteCount - 1] = 0; // Add null terminator.

            glBindAttribLocation(_program, slot, elementNamePtr);
            CheckLastError();
        }

        private void ProcessResourceSetLayouts(ResourceLayout[] layouts)
        {
            int32 resourceLayoutCount = layouts.Length;
            _setInfos = new SetBindingsInfo[resourceLayoutCount];
            int32 lastTextureLocation = -1;
            int32 relativeTextureIndex = -1;
            int32 relativeImageIndex = -1;
            uint32 storageBlockIndex = 0; // Tracks OpenGL ES storage buffers.
            for (uint32 setSlot = 0; setSlot < resourceLayoutCount; setSlot++)
            {
                ResourceLayout setLayout = layouts[setSlot];
                OpenGLResourceLayout glSetLayout = Util.AssertSubtype<ResourceLayout, OpenGLResourceLayout>(setLayout);
                ResourceLayoutElementDescription[] resources = glSetLayout.Elements;

                Dictionary<uint32, OpenGLUniformBinding> uniformBindings = new Dictionary<uint32, OpenGLUniformBinding>();
                Dictionary<uint32, OpenGLTextureBindingSlotInfo> textureBindings = new Dictionary<uint32, OpenGLTextureBindingSlotInfo>();
                Dictionary<uint32, OpenGLSamplerBindingSlotInfo> samplerBindings = new Dictionary<uint32, OpenGLSamplerBindingSlotInfo>();
                Dictionary<uint32, OpenGLShaderStorageBinding> storageBufferBindings = new Dictionary<uint32, OpenGLShaderStorageBinding>();

                List<int32> samplerTrackedRelativeTextureIndices = new List<int32>();
                for (uint32 i = 0; i < resources.Length; i++)
                {
                    ResourceLayoutElementDescription resource = resources[i];
                    if (resource.Kind == ResourceKind.UniformBuffer)
                    {
                        uint32 blockIndex = GetUniformBlockIndex(resource.Name);
                        if (blockIndex != GL_INVALID_INDEX)
                        {
                            int32 blockSize;
                            glGetActiveUniformBlockiv(_program, blockIndex, ActiveUniformBlockParameter.UniformBlockDataSize, &blockSize);
                            CheckLastError();
                            uniformBindings[i] = new OpenGLUniformBinding(_program, blockIndex, (uint32)blockSize);
                        }
                    }
                    else if (resource.Kind == ResourceKind.TextureReadOnly)
                    {
                        int32 location = GetUniformLocation(resource.Name);
                        relativeTextureIndex += 1;
                        textureBindings[i] = new OpenGLTextureBindingSlotInfo() { RelativeIndex = relativeTextureIndex, UniformLocation = location };
                        lastTextureLocation = location;
                        samplerTrackedRelativeTextureIndices.Add(relativeTextureIndex);
                    }
                    else if (resource.Kind == ResourceKind.TextureReadWrite)
                    {
                        int32 location = GetUniformLocation(resource.Name);
                        relativeImageIndex += 1;
                        textureBindings[i] = new OpenGLTextureBindingSlotInfo() { RelativeIndex = relativeImageIndex, UniformLocation = location };
                    }
                    else if (resource.Kind == ResourceKind.StructuredBufferReadOnly
                        || resource.Kind == ResourceKind.StructuredBufferReadWrite)
                    {
                        uint32 storageBlockBinding;
                        if (_gd.BackendType == GraphicsBackend.OpenGL)
                        {
                            storageBlockBinding = GetProgramResourceIndex(resource.Name, ProgramInterface.ShaderStorageBlock);
                        }
                        else
                        {
                            storageBlockBinding = storageBlockIndex;
                            storageBlockIndex += 1;
                        }

                        storageBufferBindings[i] = new OpenGLShaderStorageBinding(storageBlockBinding);
                    }
                    else
                    {
                        Debug.Assert(resource.Kind == ResourceKind.Sampler);

                        int32[] relativeIndices = samplerTrackedRelativeTextureIndices.ToArray();
                        samplerTrackedRelativeTextureIndices.Clear();
                        samplerBindings[i] = new OpenGLSamplerBindingSlotInfo()
                        {
                            RelativeIndices = relativeIndices
                        };
                    }
                }

                _setInfos[setSlot] = new SetBindingsInfo(uniformBindings, textureBindings, samplerBindings, storageBufferBindings);
            }
        }

        uint32 GetUniformBlockIndex(string resourceName)
        {
            int32 byteCount = Encoding.UTF8.GetByteCount(resourceName) + 1;
            uint8* resourceNamePtr = stackalloc uint8[byteCount];
            fixed (char* charPtr = resourceName)
            {
                int32 bytesWritten = Encoding.UTF8.GetBytes(charPtr, resourceName.Length, resourceNamePtr, byteCount);
                Debug.Assert(bytesWritten == byteCount - 1);
            }
            resourceNamePtr[byteCount - 1] = 0; // Add null terminator.

            uint32 blockIndex = glGetUniformBlockIndex(_program, resourceNamePtr);
            CheckLastError();
#if DEBUG && GL_VALIDATE_SHADER_RESOURCE_NAMES
            if (blockIndex == GL_INVALID_INDEX)
            {
                uint32 uniformBufferIndex = 0;
                uint32 bufferNameByteCount = 64;
                uint8* bufferNamePtr = stackalloc uint8[(int32)bufferNameByteCount];
                var names = new List<string>();
                while (true)
                {
                    uint32 actualLength;
                    glGetActiveUniformBlockName(_program, uniformBufferIndex, bufferNameByteCount, &actualLength, bufferNamePtr);

                    if (glGetError() != 0)
                    {
                        break;
                    }

                    string name = Encoding.UTF8.GetString(bufferNamePtr, (int32)actualLength);
                    names.Add(name);
                    uniformBufferIndex++;
                }

                Runtime.GALError($"Unable to bind uniform buffer \"{resourceName}\" by name. Valid names for this pipeline are: {string.Join(", ", names)}");
            }
#endif
            return blockIndex;
        }

        int32 GetUniformLocation(string resourceName)
        {
            int32 byteCount = Encoding.UTF8.GetByteCount(resourceName) + 1;
            uint8* resourceNamePtr = stackalloc uint8[byteCount];
            fixed (char* charPtr = resourceName)
            {
                int32 bytesWritten = Encoding.UTF8.GetBytes(charPtr, resourceName.Length, resourceNamePtr, byteCount);
                Debug.Assert(bytesWritten == byteCount - 1);
            }
            resourceNamePtr[byteCount - 1] = 0; // Add null terminator.

            int32 location = glGetUniformLocation(_program, resourceNamePtr);
            CheckLastError();

#if DEBUG && GL_VALIDATE_SHADER_RESOURCE_NAMES
            if (location == -1)
            {
                ReportInvalidUniformName(resourceName);
            }
#endif
            return location;
        }

        uint32 GetProgramResourceIndex(string resourceName, ProgramInterface resourceType)
        {
            int32 byteCount = Encoding.UTF8.GetByteCount(resourceName) + 1;

            uint8* resourceNamePtr = stackalloc uint8[byteCount];
            fixed (char* charPtr = resourceName)
            {
                int32 bytesWritten = Encoding.UTF8.GetBytes(charPtr, resourceName.Length, resourceNamePtr, byteCount);
                Debug.Assert(bytesWritten == byteCount - 1);
            }
            resourceNamePtr[byteCount - 1] = 0; // Add null terminator.

            uint32 binding = glGetProgramResourceIndex(_program, resourceType, resourceNamePtr);
            CheckLastError();
#if DEBUG && GL_VALIDATE_SHADER_RESOURCE_NAMES
            if (binding == GL_INVALID_INDEX)
            {
                ReportInvalidResourceName(resourceName, resourceType);
            }
#endif
            return binding;
        }

#if DEBUG && GL_VALIDATE_SHADER_RESOURCE_NAMES
        void ReportInvalidUniformName(string uniformName)
        {
            uint32 uniformIndex = 0;
            uint32 resourceNameByteCount = 64;
            uint8* resourceNamePtr = stackalloc uint8[(int32)resourceNameByteCount];

            var names = new List<string>();
            while (true)
            {
                uint32 actualLength;
                int32 size;
                uint32 type;
                glGetActiveUniform(_program, uniformIndex, resourceNameByteCount,
                    &actualLength, &size, &type, resourceNamePtr);

                if (glGetError() != 0)
                {
                    break;
                }

                string name = Encoding.UTF8.GetString(resourceNamePtr, (int32)actualLength);
                names.Add(name);
                uniformIndex++;
            }

            Runtime.GALError($"Unable to bind uniform \"{uniformName}\" by name. Valid names for this pipeline are: {string.Join(", ", names)}");
        }

        void ReportInvalidResourceName(string resourceName, ProgramInterface resourceType)
        {
            // glGetProgramInterfaceiv and glGetProgramResourceName are only available in 4.3+
            if (_gd.ApiVersion.Major < 4 || (_gd.ApiVersion.Major == 4 && _gd.ApiVersion.Minor < 3))
            {
                return;
            }

            int32 maxLength = 0;
            int32 resourceCount = 0;
            glGetProgramInterfaceiv(_program, resourceType, ProgramInterfaceParameterName.MaxNameLength, &maxLength);
            glGetProgramInterfaceiv(_program, resourceType, ProgramInterfaceParameterName.ActiveResources, &resourceCount);
            uint8* resourceNamePtr = stackalloc uint8[maxLength];

            var names = new List<string>();
            for (uint32 resourceIndex = 0; resourceIndex < resourceCount; resourceIndex++)
            {
                uint32 actualLength;
                glGetProgramResourceName(_program, resourceType, resourceIndex, (uint32)maxLength, &actualLength, resourceNamePtr);

                if (glGetError() != 0)
                {
                    break;
                }

                string name = Encoding.UTF8.GetString(resourceNamePtr, (int32)actualLength);
                names.Add(name);
            }

            Runtime.GALError($"Unable to bind {resourceType} \"{resourceName}\" by name. Valid names for this pipeline are: {string.Join(", ", names)}");
        }
#endif

        private void CreateComputeGLResources()
        {
            _program = glCreateProgram();
            CheckLastError();
            OpenGLShader glShader = Util.AssertSubtype<Shader, OpenGLShader>(ComputeShader);
            glShader.EnsureResourcesCreated();
            glAttachShader(_program, glShader.Shader);
            CheckLastError();

            glLinkProgram(_program);
            CheckLastError();

            int32 linkStatus;
            glGetProgramiv(_program, GetProgramParameterName.LinkStatus, &linkStatus);
            CheckLastError();
            if (linkStatus != 1)
            {
                uint8* infoLog = stackalloc uint8[4096];
                uint32 bytesWritten;
                glGetProgramInfoLog(_program, 4096, &bytesWritten, infoLog);
                CheckLastError();
                string log = Encoding.UTF8.GetString(infoLog, (int32)bytesWritten);
                Runtime.GALError($"Error linking GL program: {log}");
            }

            ProcessResourceSetLayouts(ResourceLayouts);
        }

        public bool GetUniformBindingForSlot(uint32 set, uint32 slot, out OpenGLUniformBinding binding)
        {
            Debug.Assert(_setInfos != null, "EnsureResourcesCreated must be called before accessing resource set information.");
            SetBindingsInfo setInfo = _setInfos[set];
            return setInfo.GetUniformBindingForSlot(slot, out binding);
        }

        public bool GetTextureBindingInfo(uint32 set, uint32 slot, out OpenGLTextureBindingSlotInfo binding)
        {
            Debug.Assert(_setInfos != null, "EnsureResourcesCreated must be called before accessing resource set information.");
            SetBindingsInfo setInfo = _setInfos[set];
            return setInfo.GetTextureBindingInfo(slot, out binding);
        }

        public bool GetSamplerBindingInfo(uint32 set, uint32 slot, out OpenGLSamplerBindingSlotInfo binding)
        {
            Debug.Assert(_setInfos != null, "EnsureResourcesCreated must be called before accessing resource set information.");
            SetBindingsInfo setInfo = _setInfos[set];
            return setInfo.GetSamplerBindingInfo(slot, out binding);
        }

        public bool GetStorageBufferBindingForSlot(uint32 set, uint32 slot, out OpenGLShaderStorageBinding binding)
        {
            Debug.Assert(_setInfos != null, "EnsureResourcesCreated must be called before accessing resource set information.");
            SetBindingsInfo setInfo = _setInfos[set];
            return setInfo.GetStorageBufferBindingForSlot(slot, out binding);

        }

        public override void Dispose()
        {
            if (!_disposeRequested)
            {
                _disposeRequested = true;
                _gd.EnqueueDisposal(this);
            }
        }

        public void DestroyGLResources()
        {
            if (!_disposed)
            {
                _disposed = true;
                glDeleteProgram(_program);
                CheckLastError();
            }
        }
    }

    internal struct SetBindingsInfo
    {
        private readonly Dictionary<uint32, OpenGLUniformBinding> _uniformBindings;
        private readonly Dictionary<uint32, OpenGLTextureBindingSlotInfo> _textureBindings;
        private readonly Dictionary<uint32, OpenGLSamplerBindingSlotInfo> _samplerBindings;
        private readonly Dictionary<uint32, OpenGLShaderStorageBinding> _storageBufferBindings;

        public uint32 UniformBufferCount { get; }
        public uint32 ShaderStorageBufferCount { get; }

        public SetBindingsInfo(
            Dictionary<uint32, OpenGLUniformBinding> uniformBindings,
            Dictionary<uint32, OpenGLTextureBindingSlotInfo> textureBindings,
            Dictionary<uint32, OpenGLSamplerBindingSlotInfo> samplerBindings,
            Dictionary<uint32, OpenGLShaderStorageBinding> storageBufferBindings)
        {
            _uniformBindings = uniformBindings;
            UniformBufferCount = (uint32)uniformBindings.Count;
            _textureBindings = textureBindings;
            _samplerBindings = samplerBindings;
            _storageBufferBindings = storageBufferBindings;
            ShaderStorageBufferCount = (uint32)storageBufferBindings.Count;
        }

        public bool GetTextureBindingInfo(uint32 slot, out OpenGLTextureBindingSlotInfo binding)
        {
            return _textureBindings.TryGetValue(slot, out binding);
        }

        public bool GetSamplerBindingInfo(uint32 slot, out OpenGLSamplerBindingSlotInfo binding)
        {
            return _samplerBindings.TryGetValue(slot, out binding);
        }

        public bool GetUniformBindingForSlot(uint32 slot, out OpenGLUniformBinding binding)
        {
            return _uniformBindings.TryGetValue(slot, out binding);
        }

        public bool GetStorageBufferBindingForSlot(uint32 slot, out OpenGLShaderStorageBinding binding)
        {
            return _storageBufferBindings.TryGetValue(slot, out binding);
        }
    }

    internal struct OpenGLTextureBindingSlotInfo
    {
        /// <summary>
        /// The relative index of this binding with relation to the other textures used by a shader.
        /// Generally, this is the texture unit that the binding will be placed into.
        /// </summary>
        public int32 RelativeIndex;
        /// <summary>
        /// The uniform location of the binding in the shader program.
        /// </summary>
        public int32 UniformLocation;
    }

    internal struct OpenGLSamplerBindingSlotInfo
    {
        /// <summary>
        /// The relative indices of this binding with relation to the other textures used by a shader.
        /// Generally, these are the texture units that the sampler will be bound to.
        /// </summary>
        public int32[] RelativeIndices;
    }

    internal class OpenGLUniformBinding
    {
        public uint32 Program { get; }
        public uint32 BlockLocation { get; }
        public uint32 BlockSize { get; }

        public OpenGLUniformBinding(uint32 program, uint32 blockLocation, uint32 blockSize)
        {
            Program = program;
            BlockLocation = blockLocation;
            BlockSize = blockSize;
        }
    }

    internal class OpenGLShaderStorageBinding
    {
        public uint32 StorageBlockBinding { get; }

        public OpenGLShaderStorageBinding(uint32 storageBlockBinding)
        {
            StorageBlockBinding = storageBlockBinding;
        }
    }
}
