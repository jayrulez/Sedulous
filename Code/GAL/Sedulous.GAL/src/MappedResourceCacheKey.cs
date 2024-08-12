using System;

namespace Sedulous.GAL
{
    internal struct MappedResourceCacheKey : IEquatable<MappedResourceCacheKey>, IHashable
    {
        public readonly MappableResource Resource;
        public readonly uint32 Subresource;

        public this(MappableResource resource, uint32 subresource)
        {
            Resource = resource;
            Subresource = subresource;
        }

        public bool Equals(MappedResourceCacheKey other)
        {
            return Resource === other.Resource
                && Subresource == other.Subresource;
        }

        public int GetHashCode()
        {
            return HashHelper.Combine(HashCode.Generate(Resource), Subresource.GetHashCode());
        }
    }
}
