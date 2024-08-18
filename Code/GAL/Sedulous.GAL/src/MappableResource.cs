﻿namespace Veldrid
{
    /// <summary>
    /// A marker interface designating a device resource which can be mapped into CPU-visible memory with
    /// <see cref="GraphicsDevice.Map(MappableResource, MapMode, uint32)"/>
    /// </summary>
    public interface MappableResource
    {
    }
}
