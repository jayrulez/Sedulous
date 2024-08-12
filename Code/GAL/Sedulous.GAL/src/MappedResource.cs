using System;

namespace Sedulous.GAL
{
    /// <summary>
    /// A structure describing the layout of a mapped <see cref="MappableResource"/> object.
    /// </summary>
    public struct MappedResource
    {
        /// <summary>
        /// The resource which has been mapped.
        /// </summary>
        public readonly MappableResource Resource;
        /// <summary>
        /// Identifies the <see cref="MapMode"/> that was used to map the resource.
        /// </summary>
        public readonly MapMode Mode;
        /// <summary>
        /// A pointer to the start of the mapped data region.
        /// </summary>
        public readonly void* Data;
        /// <summary>
        /// The total size, in bytes, of the mapped data region.
        /// </summary>
        public readonly uint32 SizeInBytes;
        /// <summary>
        /// For mapped <see cref="Texture"/> resources, this is the subresource which is mapped.
        /// For <see cref="DeviceBuffer"/> resources, this field has no meaning.
        /// </summary>
        public readonly uint32 Subresource;
        /// <summary>
        /// For mapped <see cref="Texture"/> resources, this is the number of bytes between each row of texels.
        /// For <see cref="DeviceBuffer"/> resources, this field has no meaning.
        /// </summary>
        public readonly uint32 RowPitch;
        /// <summary>
        /// For mapped <see cref="Texture"/> resources, this is the number of bytes between each depth slice of a 3D Texture.
        /// For <see cref="DeviceBuffer"/> resources or 2D Textures, this field has no meaning.
        /// </summary>
        public readonly uint32 DepthPitch;

        internal this(
            MappableResource resource,
            MapMode mode,
            void* data,
            uint32 sizeInBytes,
            uint32 subresource,
            uint32 rowPitch,
            uint32 depthPitch)
        {
            Resource = resource;
            Mode = mode;
            Data = data;
            SizeInBytes = sizeInBytes;
            Subresource = subresource;
            RowPitch = rowPitch;
            DepthPitch = depthPitch;
        }

        internal this(MappableResource resource, MapMode mode, void* data, uint32 sizeInBytes)
        {
            Resource = resource;
            Mode = mode;
            Data = data;
            SizeInBytes = sizeInBytes;

            Subresource = 0;
            RowPitch = 0;
            DepthPitch = 0;
        }
    }

    /// <summary>
    /// A typed view of a <see cref="MappedResource"/>. Provides by-reference structured access to individual elements in the
    /// mapped resource.
    /// </summary>
    /// <typeparam name="T">The blittable value type which mapped data is viewed as.</typeparam>
    public struct MappedResourceView<T> where T : struct
    {
        private const int s_sizeofT = sizeof(T);

        /// <summary>
        /// The <see cref="MappedResource"/> that this instance views.
        /// </summary>
        public readonly MappedResource MappedResource;
        /// <summary>
        /// The total size in bytes of the mapped resource.
        /// </summary>
        public readonly uint32 SizeInBytes;
        /// <summary>
        /// The total number of structures that is contained in the resource. This is effectively the total number of bytes
        /// divided by the size of the structure type.
        /// </summary>
        public readonly int Count;

        /// <summary>
        /// Constructs a new MappedResourceView which wraps the given <see cref="MappedResource"/>.
        /// </summary>
        /// <param name="rawResource">The raw resource which has been mapped.</param>
        public this(MappedResource rawResource)
        {
            MappedResource = rawResource;
            SizeInBytes = rawResource.SizeInBytes;
            Count = (int)(SizeInBytes / s_sizeofT);
        }

        /// <summary>
        /// Gets a reference to the structure value at the given index.
        /// </summary>
        /// <param name="index">The index of the value.</param>
        /// <returns>A reference to the value at the given index.</returns>
        public ref T this[int index]
        {
            get
            {
                if (index >= Count || index < 0)
                {
                    Runtime.IndexOutOfRangeError(
                        scope $"Given index ({index}) must be non-negative and less than Count ({Count}).");
                }

                uint8* ptr = (uint8*)MappedResource.Data + (index * s_sizeofT);
                return ref *(T*)ptr;
            }
        }

        /// <summary>
        /// Gets a reference to the structure value at the given index.
        /// </summary>
        /// <param name="index">The index of the value.</param>
        /// <returns>A reference to the value at the given index.</returns>
        public ref T this[uint index]
        {
            get
            {
                if (index >= (uint)Count)
                {
                    Runtime.IndexOutOfRangeError(
                        scope $"Given index ({index}) must be less than Count ({Count}).");
                }

                uint8* ptr = (uint8*)MappedResource.Data + ((int)index * s_sizeofT);
                return ref *(T*)ptr;
            }
        }

        /// <summary>
        /// Gets a reference to the structure at the given 2-dimensional texture coordinates.
        /// </summary>
        /// <param name="x">The X coordinate.</param>
        /// <param name="y">The Y coordinate.</param>
        /// <returns>A reference to the value at the given coordinates.</returns>
        public ref T this[int x, int y]
        {
            get
            {
                uint8* ptr = (uint8*)MappedResource.Data + (y * MappedResource.RowPitch) + (x * s_sizeofT);
                return ref *(T*)ptr;
            }
        }

        /// <summary>
        /// Gets a reference to the structure at the given 2-dimensional texture coordinates.
        /// </summary>
        /// <param name="x">The X coordinate.</param>
        /// <param name="y">The Y coordinate.</param>
        /// <returns>A reference to the value at the given coordinates.</returns>
        public ref T this[uint x, uint y]
        {
            get
            {
                uint8* ptr = (uint8*)MappedResource.Data + (y * MappedResource.RowPitch) + ((int)x * s_sizeofT);
                return ref *(T*)ptr;
            }
        }

        /// <summary>
        /// Gets a reference to the structure at the given 3-dimensional texture coordinates.
        /// </summary>
        /// <param name="x">The X coordinate.</param>
        /// <param name="y">The Y coordinate.</param>
        /// <param name="z">The Z coordinate.</param>
        /// <returns>A reference to the value at the given coordinates.</returns>
        public ref T this[int x, int y, int z]
        {
            get
            {
                uint8* ptr = (uint8*)MappedResource.Data
                    + (z * MappedResource.DepthPitch)
                    + (y * MappedResource.RowPitch)
                    + (x * s_sizeofT);
                return ref *(T*)ptr;
            }
        }

        /// <summary>
        /// Gets a reference to the structure at the given 3-dimensional texture coordinates.
        /// </summary>
        /// <param name="x">The X coordinate.</param>
        /// <param name="y">The Y coordinate.</param>
        /// <param name="z">The Z coordinate.</param>
        /// <returns>A reference to the value at the given coordinates.</returns>
        public ref T this[uint x, uint y, uint z]
        {
            get
            {
                uint8* ptr = (uint8*)MappedResource.Data
                    + (z * MappedResource.DepthPitch)
                    + (y * MappedResource.RowPitch)
                    + ((int)x * s_sizeofT);
                return ref *(T*)ptr;
            }
        }
    }
}