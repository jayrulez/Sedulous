using System;
using System.Diagnostics;
using System.Text;
using Sedulous.MetalBindings;

namespace Sedulous.GAL.MTL
{
    internal class MTLShader : Shader
    {
        private readonly MTLGraphicsDevice _device;
        private bool _disposed;

        public MTLLibrary Library { get; private set; }
        public MTLFunction Function { get; private set; }
        public override String Name { get; set; }
        public bool HasFunctionConstants { get; }
        public override bool IsDisposed => _disposed;

        public this(in ShaderDescription description, MTLGraphicsDevice gd)
            : base(description.Stage, description.EntryPoint)
        {
            _device = gd;

            if (description.ShaderBytes.Count > 4
                && description.ShaderBytes[0] == 0x4d
                && description.ShaderBytes[1] == 0x54
                && description.ShaderBytes[2] == 0x4c
                && description.ShaderBytes[3] == 0x42)
            {
                DispatchQueue queue = Dispatch.dispatch_get_global_queue(QualityOfServiceLevel.QOS_CLASS_USER_INTERACTIVE, 0);
                DispatchData dispatchData = Dispatch.dispatch_data_create(
                    description.ShaderBytes.Ptr,
                    (uint)description.ShaderBytes.Count,
                    queue,
                    null);

				defer Dispatch.dispatch_release(dispatchData.NativePtr);
                Library = gd.Device.newLibraryWithData(dispatchData);
            }
            else
            {
                String source = scope .((char8*)description.ShaderBytes.Ptr);
                MTLCompileOptions compileOptions = MTLCompileOptions.New();
                Library = gd.Device.newLibraryWithSource(source, compileOptions);
                ObjectiveCRuntime.release(compileOptions);
            }

            Function = Library.newFunctionWithName(description.EntryPoint);
            if (Function.NativePtr == null)
            {
                Runtime.GALError(
                    scope $"Failed to create Metal {description.Stage} Shader. The given entry point \"{description.EntryPoint}\" was not found.");
            }

            HasFunctionConstants = Function.functionConstantsDictionary.count != 0;
        }

        public override void Dispose()
        {
            if (!_disposed)
            {
                _disposed = true;
                ObjectiveCRuntime.release(Function.NativePtr);
                ObjectiveCRuntime.release(Library.NativePtr);
            }
        }
    }
}
