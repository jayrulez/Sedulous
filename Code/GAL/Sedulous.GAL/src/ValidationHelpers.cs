using System.Diagnostics;
using System;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

    internal static class ValidationHelpers
    {
#if !VALIDATE_USAGE
        [SkipCall]//[Conditional("VALIDATE_USAGE")]
#endif
        internal static void ValidateResourceSet(GraphicsDevice gd, in ResourceSetDescription description)
        {
#if VALIDATE_USAGE
            ResourceLayoutElementDescription[] elements = description.Layout.Description.Elements;
            BindableResource[] resources = description.BoundResources;

            if (elements.Count != resources.Count)
            {
                Runtime.GALError(
                    scope $"The number of resources specified ({resources.Count}) must be equal to the number of resources in the {nameof(ResourceLayout)} ({elements.Count}).");
            }

            for (uint32 i = 0; i < elements.Count; i++)
            {
                ValidateResourceKind(elements[i].Kind, resources[i], i);
            }

            for (int i = 0; i < description.Layout.Description.Elements.Count; i++)
            {
                ResourceLayoutElementDescription element = description.Layout.Description.Elements[i];
                if (element.Kind == ResourceKind.UniformBuffer
                    || element.Kind == ResourceKind.StructuredBufferReadOnly
                    || element.Kind == ResourceKind.StructuredBufferReadWrite)
                {
                    DeviceBufferRange range = Util.GetBufferRange(description.BoundResources[i], 0);

                    if (!gd.Features.BufferRangeBinding && (range.Offset != 0 || range.SizeInBytes != range.Buffer.SizeInBytes))
                    {
                        Runtime.GALError(scope $"The {nameof(DeviceBufferRange)} in slot {i} uses a non-zero offset or less-than-full size, which requires {nameof(GraphicsDeviceFeatures)}.{nameof(GraphicsDeviceFeatures.BufferRangeBinding)}.");
                    }

                    uint32 alignment = element.Kind == ResourceKind.UniformBuffer
                       ? gd.UniformBufferMinOffsetAlignment
                       : gd.StructuredBufferMinOffsetAlignment;

                    if ((range.Offset % alignment) != 0)
                    {
                       Runtime.GALError(scope $"The {nameof(DeviceBufferRange)} in slot {i} has an invalid offset: {range.Offset}. The offset for this buffer must be a multiple of {alignment}.");
                    }
                }
            }
#endif
        }

#if !VALIDATE_USAGE
        [SkipCall]//[Conditional("VALIDATE_USAGE")]
#endif
        private static void ValidateResourceKind(ResourceKind kind, BindableResource resource, uint32 slot)
        {
            switch (kind)
            {
                case ResourceKind.UniformBuffer:
                {
                    if (!Util.GetDeviceBuffer(resource, var b)
                        || (b.Usage & BufferUsage.UniformBuffer) == 0)
                    {
                        Runtime.GALError(
                            scope $"Resource in slot {slot} does not match {nameof(ResourceKind)}.{kind} specified in the {nameof(ResourceLayout)}. It must be a {nameof(DeviceBuffer)} or {nameof(DeviceBufferRange)} with {nameof(BufferUsage)}.{nameof(BufferUsage.UniformBuffer)}.");
                    }
                    break;
                }
                case ResourceKind.StructuredBufferReadOnly:
                {
                    if (!Util.GetDeviceBuffer(resource, var b)
                        || (b.Usage & (BufferUsage.StructuredBufferReadOnly | BufferUsage.StructuredBufferReadWrite)) == 0)
                    {
                        Runtime.GALError(
                            scope $"Resource in slot {slot} does not match {nameof(ResourceKind)}.{kind} specified in the {nameof(ResourceLayout)}. It must be a {nameof(DeviceBuffer)} with {nameof(BufferUsage)}.{nameof(BufferUsage.StructuredBufferReadOnly)}.");
                    }
                    break;
                }
                case ResourceKind.StructuredBufferReadWrite:
                {
                    if (!Util.GetDeviceBuffer(resource, var b)
                        || (b.Usage & BufferUsage.StructuredBufferReadWrite) == 0)
                    {
                        Runtime.GALError(
                            scope $"Resource in slot {slot} does not match {nameof(ResourceKind)} specified in the {nameof(ResourceLayout)}. It must be a {nameof(DeviceBuffer)} with {nameof(BufferUsage)}.{nameof(BufferUsage.StructuredBufferReadWrite)}.");
                    }
                    break;
                }
                case ResourceKind.TextureReadOnly:
                {
                    if (!(let tv = resource as TextureView && (tv.Target.Usage & TextureUsage.Sampled) != 0)
                        && !(let t = resource as Texture && (t.Usage & TextureUsage.Sampled) != 0))
                    {
                        Runtime.GALError(
                            scope $"Resource in slot {slot} does not match {nameof(ResourceKind)}.{kind} specified in the {nameof(ResourceLayout)}. It must be a {nameof(Texture)} or {nameof(TextureView)} whose target has {nameof(TextureUsage)}.{nameof(TextureUsage.Sampled)}.");
                    }
                    break;
                }
                case ResourceKind.TextureReadWrite:
                {
                    if (!(let tv = resource as TextureView && (tv.Target.Usage & TextureUsage.Storage) != 0)
                        && !(let t = resource as Texture && (t.Usage & TextureUsage.Storage) != 0))
                    {
                        Runtime.GALError(
                            scope $"Resource in slot {slot} does not match {nameof(ResourceKind)}.{kind} specified in the {nameof(ResourceLayout)}. It must be a {nameof(Texture)} or {nameof(TextureView)} whose target has {nameof(TextureUsage)}.{nameof(TextureUsage.Storage)}.");
                    }
                    break;
                }
                case ResourceKind.Sampler:
                {
                    if (!(resource is Sampler))
                    {
                        Runtime.GALError(
                            scope $"Resource in slot {slot} does not match {nameof(ResourceKind)}.{kind} specified in the {nameof(ResourceLayout)}. It must be a {nameof(Sampler)}.");
                    }
                    break;
                }
                default:
                    Runtime.IllegalValue<ResourceKind>();
            }
        }
    }
}
