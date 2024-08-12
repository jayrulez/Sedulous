using System;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

    /// <summary>
    /// Describes the layout of vertex data in a single <see cref="DeviceBuffer"/> used as a vertex buffer.
    /// </summary>
    public struct VertexLayoutDescription : IEquatable<VertexLayoutDescription>, IHashable
    {
        /// <summary>
        /// The number of bytes in between successive elements in the <see cref="DeviceBuffer"/>.
        /// </summary>
        public uint32 Stride;
        /// <summary>
        /// An array of <see cref="VertexElementDescription"/> objects, each describing a single element of vertex data.
        /// </summary>
        public VertexElementDescription[] Elements;
        /// <summary>
        /// A value controlling how often data for instances is advanced for this layout. For per-vertex elements, this value
        /// should be 0.
        /// For example, an InstanceStepRate of 3 indicates that 3 instances will be drawn with the same value for this layout. The
        /// next 3 instances will be drawn with the next value, and so on.
        /// </summary>
        public uint32 InstanceStepRate;

        /// <summary>
        /// Constructs a new VertexLayoutDescription.
        /// </summary>
        /// <param name="stride">The number of bytes in between successive elements in the <see cref="DeviceBuffer"/>.</param>
        /// <param name="elements">An array of <see cref="VertexElementDescription"/> objects, each describing a single element
        /// of vertex data.</param>
        public this(uint32 stride, params VertexElementDescription[] elements)
        {
            Stride = stride;
            Elements = elements;
            InstanceStepRate = 0;
        }

        /// <summary>
        /// Constructs a new VertexLayoutDescription.
        /// </summary>
        /// <param name="stride">The number of bytes in between successive elements in the <see cref="DeviceBuffer"/>.</param>
        /// <param name="elements">An array of <see cref="VertexElementDescription"/> objects, each describing a single element
        /// of vertex data.</param>
        /// <param name="instanceStepRate">A value controlling how often data for instances is advanced for this element. For
        /// per-vertex elements, this value should be 0.
        /// For example, an InstanceStepRate of 3 indicates that 3 instances will be drawn with the same value for this element.
        /// The next 3 instances will be drawn with the next value for this element, and so on.</param>
        public this(uint32 stride, uint32 instanceStepRate, params VertexElementDescription[] elements)
        {
            Stride = stride;
            Elements = elements;
            InstanceStepRate = instanceStepRate;
        }

        /// <summary>
        /// Constructs a new VertexLayoutDescription. The stride is assumed to be the sum of the size of all elements.
        /// </summary>
        /// <param name="elements">An array of <see cref="VertexElementDescription"/> objects, each describing a single element
        /// of vertex data.</param>
        public this(params VertexElementDescription[] elements)
        {
            Elements = elements;
            uint32 computedStride = 0;
            for (int i = 0; i < elements.Count; i++)
            {
                uint32 elementSize = FormatSizeHelpers.GetSizeInBytes(elements[i].Format);
                if (elements[i].Offset != 0)
                {
                    computedStride = elements[i].Offset + elementSize;
                }
                else
                {
                    computedStride += elementSize;
                }
            }

            Stride = computedStride;
            InstanceStepRate = 0;
        }

        /// <summary>
        /// Element-wise equality.
        /// </summary>
        /// <param name="other">The instance to compare to.</param>
        /// <returns>True if all elements and all array elements are equal; false otherswise.</returns>
        public bool Equals(VertexLayoutDescription other)
        {
            return Stride == other.Stride
                && Util.ArrayEqualsEquatable(Elements, other.Elements)
                && InstanceStepRate == other.InstanceStepRate;
        }

        /// <summary>
        /// Returns the hash code for this instance.
        /// </summary>
        /// <returns>A 32-bit signed integer that is the hash code for this instance.</returns>
        public int GetHashCode()
        {
            return HashHelper.Combine(Stride.GetHashCode(), HashHelper.Array(Elements), InstanceStepRate.GetHashCode());
        }
    }
}
