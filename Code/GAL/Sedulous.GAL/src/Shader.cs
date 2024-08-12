using System;

namespace Sedulous.GAL
{
    /// <summary>
    /// A device resource encapsulating a single shader module.
    /// See <see cref="ShaderDescription"/>.
    /// </summary>
    public abstract class Shader : DeviceResource, IDisposable
    {
        internal this(ShaderStages stage, String entryPoint)
        {
            Stage = stage;
            EntryPoint = entryPoint;
        }

        /// <summary>
        /// The shader stage this instance can be used in.
        /// </summary>
        public ShaderStages Stage { get; }

        /// <summary>
        /// The name of the entry point function.
        /// </summary>
        public String EntryPoint { get; }

        /// <summary>
        /// A string identifying this instance. Can be used to differentiate between objects in graphics debuggers and other
        /// tools.
        /// </summary>
        public abstract String Name { get; set; }

        /// <summary>
        /// A bool indicating whether this instance has been disposed.
        /// </summary>
        public abstract bool IsDisposed { get; }

        /// <summary>
        /// Frees unmanaged device resources controlled by this instance.
        /// </summary>
        public abstract void Dispose();
    }
}
