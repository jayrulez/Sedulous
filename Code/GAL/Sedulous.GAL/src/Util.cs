using System;
using System.Diagnostics;
using System.Text;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

    internal static class Util
    {
        //[DebuggerNonUserCode]
        [Inline]
        internal static TDerived AssertSubtype<TBase, TDerived>(TBase value) where TDerived : class, TBase where TBase : class
        {
#if DEBUG
            if (value == null)
            {
                Runtime.GALError(scope $"Expected object of type {typeof(TDerived).GetFullName(.. scope .())} but received null instead.");
            }

			let derived = value as TDerived;
            if (derived == null)
            {
                Runtime.GALError(scope $"object {value} must be derived type {typeof(TDerived).GetFullName(.. scope .())} to be used in this context.");
            }

            return derived;

#else
            return (TDerived)value;
#endif
        }

        internal static void EnsureArrayMinimumSize<T>(ref T[] array, uint32 size)
        {
            if (array == null)
            {
                array = new T[size];
            }
            else if (array.Count < size)
            {
                Array.Resize(ref array, (int32)size);
            }
        }

        internal static uint32 USizeOf<T>() where T : struct
        {
            return (uint32)sizeof(T);
        }

        internal static String GetString(uint8* stringStart)
        {
            int32 characters = 0;
            while (stringStart[characters] != 0)
            {
                characters++;
            }

            return new String((char8*)stringStart, characters);
        }

        internal static bool NullableEquals<T>(T? left, T? right) where T : struct, IEquatable<T>
        {
            if (left.HasValue && right.HasValue)
            {
                return left.Value.Equals(right.Value);
            }

            return left.HasValue == right.HasValue;
        }

        internal static bool ArrayEquals<T>(T[] left, T[] right) where T : class
        {
            if (left == null || right == null)
            {
                return left == right;
            }

            if (left.Count != right.Count)
            {
                return false;
            }

            for (int i = 0; i < left.Count; i++)
            {
                if (!(left[i] === right[i]))
                {
                    return false;
                }
            }

            return true;
        }

        internal static bool ArrayEqualsEquatable<T>(T[] left, T[] right) where T : struct, IEquatable<T>
        {
            if (left == null || right == null)
            {
                return left == right;
            }

            if (left.Count != right.Count)
            {
                return false;
            }

            for (int i = 0; i < left.Count; i++)
            {
                if (!left[i].Equals(right[i]))
                {
                    return false;
                }
            }

            return true;
        }

        internal static void ClearArray<T>(T[] array)
        {
            if (array != null)
            {
                Array.Clear(array, 0, array.Count);
            }
        }

        public static uint32 Clamp(uint32 value, uint32 min, uint32 max)
        {
            if (value <= min)
            {
                return min;
            }
            else if (value >= max)
            {
                return max;
            }
            else
            {
                return value;
            }
        }

        internal static void GetMipLevelAndArrayLayer(Texture tex, uint32 subresource, out uint32 mipLevel, out uint32 arrayLayer)
        {
            arrayLayer = subresource / tex.MipLevels;
            mipLevel = subresource - (arrayLayer * tex.MipLevels);
        }

        internal static void GetMipDimensions(Texture tex, uint32 mipLevel, out uint32 width, out uint32 height, out uint32 depth)
        {
            width = GetDimension(tex.Width, mipLevel);
            height = GetDimension(tex.Height, mipLevel);
            depth = GetDimension(tex.Depth, mipLevel);
        }

        internal static uint32 GetDimension(uint32 largestLevelDimension, uint32 mipLevel)
        {
            uint32 ret = largestLevelDimension;
            for (uint32 i = 0; i < mipLevel; i++)
            {
                ret /= 2;
            }

            return Math.Max(1, ret);
        }

        internal static uint64 ComputeSubresourceOffset(Texture tex, uint32 mipLevel, uint32 arrayLayer)
        {
            Debug.Assert((tex.Usage & TextureUsage.Staging) == TextureUsage.Staging);
            return ComputeArrayLayerOffset(tex, arrayLayer) + ComputeMipOffset(tex, mipLevel);
        }

        internal static uint32 ComputeMipOffset(Texture tex, uint32 mipLevel)
        {
            uint32 blockSize = FormatHelpers.IsCompressedFormat(tex.Format) ? 4u : 1u;
            uint32 offset = 0;
            for (uint32 level = 0; level < mipLevel; level++)
            {
                GetMipDimensions(tex, level, var mipWidth, var mipHeight, var mipDepth);
                uint32 storageWidth = Math.Max(mipWidth, blockSize);
                uint32 storageHeight = Math.Max(mipHeight, blockSize);
                offset += FormatHelpers.GetRegionSize(storageWidth, storageHeight, mipDepth, tex.Format);
            }

            return offset;
        }

        internal static uint32 ComputeArrayLayerOffset(Texture tex, uint32 arrayLayer)
        {
            if (arrayLayer == 0)
            {
                return 0;
            }

            uint32 blockSize = FormatHelpers.IsCompressedFormat(tex.Format) ? 4u : 1u;
            uint32 layerPitch = 0;
            for (uint32 level = 0; level < tex.MipLevels; level++)
            {
                GetMipDimensions(tex, level, var mipWidth, var mipHeight, var mipDepth);
                uint32 storageWidth = Math.Max(mipWidth, blockSize);
                uint32 storageHeight = Math.Max(mipHeight, blockSize);
                layerPitch += FormatHelpers.GetRegionSize(storageWidth, storageHeight, mipDepth, tex.Format);
            }

            return layerPitch * arrayLayer;
        }

        public static void CopyTextureRegion(
            void* src,
            uint32 srcX, uint32 srcY, uint32 srcZ,
            uint32 srcRowPitch,
            uint32 srcDepthPitch,
            void* dst,
            uint32 dstX, uint32 dstY, uint32 dstZ,
            uint32 dstRowPitch,
            uint32 dstDepthPitch,
            uint32 width,
            uint32 height,
            uint32 depth,
            PixelFormat format)
        {
            uint32 blockSize = FormatHelpers.IsCompressedFormat(format) ? 4u : 1u;
            uint32 blockSizeInBytes = blockSize > 1 ? FormatHelpers.GetBlockSizeInBytes(format) : FormatSizeHelpers.GetSizeInBytes(format);
            uint32 compressedSrcX = srcX / blockSize;
            uint32 compressedSrcY = srcY / blockSize;
            uint32 compressedDstX = dstX / blockSize;
            uint32 compressedDstY = dstY / blockSize;
            uint32 numRows = FormatHelpers.GetNumRows(height, format);
            uint32 rowSize = width / blockSize * blockSizeInBytes;

            if (srcRowPitch == dstRowPitch && srcDepthPitch == dstDepthPitch)
            {
                uint32 totalCopySize = depth * srcDepthPitch;
                Internal.MemCpy(
                    dst,
                    src,
                    totalCopySize);
            }
            else
            {
                for (uint32 zz = 0; zz < depth; zz++)
                    for (uint32 yy = 0; yy < numRows; yy++)
                    {
                        uint8* rowCopyDst = (uint8*)dst
                            + dstDepthPitch * (zz + dstZ)
                            + dstRowPitch * (yy + compressedDstY)
                            + blockSizeInBytes * compressedDstX;

                        uint8* rowCopySrc = (uint8*)src
                            + srcDepthPitch * (zz + srcZ)
                            + srcRowPitch * (yy + compressedSrcY)
                            + blockSizeInBytes * compressedSrcX;

                        Internal.MemCpy(rowCopyDst, rowCopySrc, rowSize);
                    }
            }
        }

        /*internal static T[] ShallowClone<T>(T[] array)
        {
            return (T[])array.Clone();
        }*/

        public static DeviceBufferRange GetBufferRange(BindableResource resource, uint32 additionalOffset)
        {
            if (let range = resource as DeviceBufferRange?)
            {
                return DeviceBufferRange(range.Buffer, range.Offset + additionalOffset, range.SizeInBytes);
            }
            else
            {
                DeviceBuffer buffer = (DeviceBuffer)resource;
                return DeviceBufferRange(buffer, additionalOffset, buffer.SizeInBytes);
            }
        }

        public static bool GetDeviceBuffer(BindableResource resource, out DeviceBuffer buffer)
        {
            if (let db = resource as DeviceBuffer)
            {
                buffer = db;
                return true;
            }
            else if (let range = resource as DeviceBufferRange?)
            {
                buffer = range.Buffer;
                return true;
            }

            buffer = null;
            return false;
        }

        internal static TextureView GetTextureView(GraphicsDevice gd, BindableResource resource)
        {
            if (let view= resource as TextureView)
            {
                return view;
            }
            else if (let tex= resource as Texture)
            {
                return tex.GetFullTextureView(gd);
            }
            else
            {
                Runtime.GALError(
                    scope $"Unexpected resource type. Expected Texture or TextureView but found {resource.GetType().GetName(.. scope .())}");
            }
        }

        internal static void PackIntPtr(void* sourcePtr, out uint32 low, out uint32 high)
        {
            uint64 src64 = (uint64)(int)sourcePtr;
            low = (uint32)(src64 & 0x00000000FFFFFFFF);
            high = (uint32)((src64 & 0xFFFFFFFF00000000) >> 32);
        }

        internal static void* UnpackIntPtr(uint32 low, uint32 high)
        {
            uint64 src64 = low | ((uint64)high << 32);
            return (void*)(int)src64;
        }
    }
}
