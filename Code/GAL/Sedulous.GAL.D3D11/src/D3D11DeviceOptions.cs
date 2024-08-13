using System;
using Win32.Graphics.Dxgi;

namespace Sedulous.GAL.D3D11
{
    /// <summary>
    /// A structure describing Direct3D11-specific device creation options.
    /// </summary>
    public struct D3D11DeviceOptions
    {
        /// <summary>
        /// Native pointer to an adapter.
        /// </summary>
        public IDXGIAdapter* AdapterPtr;

        /// <summary>
        /// Set of device specific flags.
        /// See <see cref="Win32.Graphics.Direct3D11.DeviceCreationFlags"/> for details.
        /// </summary>
        public uint32 DeviceCreationFlags;
    }
}
