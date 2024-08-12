using System;
using static Sedulous.OpenGLBindings.OpenGLNative;
using static Sedulous.GAL.OpenGL.OpenGLUtil;
using Sedulous.OpenGLBindings;
using System.Diagnostics;

namespace Sedulous.GAL.OpenGL
{
    internal class OpenGLBuffer : DeviceBuffer, OpenGLDeferredResource
    {
        private readonly OpenGLGraphicsDevice _gd;
        private uint32 _buffer;
        private bool _dynamic;
        private bool _disposeRequested;

        private string _name;
        private bool _nameChanged;

        public override string Name { get => _name; set { _name = value; _nameChanged = true; } }

        public override uint32 SizeInBytes { get; }
        public override BufferUsage Usage { get; }

        public uint32 Buffer => _buffer;

        public bool Created { get; private set; }

        public override bool IsDisposed => _disposeRequested;

        public OpenGLBuffer(OpenGLGraphicsDevice gd, uint32 sizeInBytes, BufferUsage usage)
        {
            _gd = gd;
            SizeInBytes = sizeInBytes;
            _dynamic = (usage & BufferUsage.Dynamic) == BufferUsage.Dynamic;
            Usage = usage;
        }

        public void EnsureResourcesCreated()
        {
            if (!Created)
            {
                CreateGLResources();
            }
            if (_nameChanged)
            {
                _nameChanged = false;
                if (_gd.Extensions.KHR_Debug)
                {
                    SetObjectLabel(ObjectLabelIdentifier.Buffer, _buffer, _name);
                }
            }
        }

        public void CreateGLResources()
        {
            Debug.Assert(!Created);

            if (_gd.Extensions.ARB_DirectStateAccess)
            {
                uint32 buffer;
                glCreateBuffers(1, &buffer);
                CheckLastError();
                _buffer = buffer;

                glNamedBufferData(
                    _buffer,
                    SizeInBytes,
                    null,
                    _dynamic ? BufferUsageHint.DynamicDraw : BufferUsageHint.StaticDraw);
                CheckLastError();
            }
            else
            {
                glGenBuffers(1, out _buffer);
                CheckLastError();

                glBindBuffer(BufferTarget.CopyReadBuffer, _buffer);
                CheckLastError();

                glBufferData(
                    BufferTarget.CopyReadBuffer,
                    (UIntPtr)SizeInBytes,
                    null,
                    _dynamic ? BufferUsageHint.DynamicDraw : BufferUsageHint.StaticDraw);
                CheckLastError();
            }

            Created = true;
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
            uint32 buffer = _buffer;
            glDeleteBuffers(1, ref buffer);
            CheckLastError();
        }
    }
}
