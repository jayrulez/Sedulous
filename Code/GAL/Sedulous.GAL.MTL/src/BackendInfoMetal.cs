#if !EXCLUDE_METAL_BACKEND
using Sedulous.MetalBindings;
using Sedulous.GAL.MTL;
using System;
using System.Collections;

namespace Sedulous.GAL.MTL
{
	using internal Sedulous.GAL.MTL;

    /// <summary>
    /// Exposes Metal-specific functionality,
    /// useful for interoperating with native components which interface directly with Metal.
    /// Can only be used on <see cref="GraphicsBackend.Metal"/>.
    /// </summary>
    public class BackendInfoMetal
    {
        private readonly MTLGraphicsDevice _gd;
        private List<MTLFeatureSet> _featureSet;

        internal this(MTLGraphicsDevice gd)
        {
            _gd = gd;
            _featureSet = new List<MTLFeatureSet>(_gd.MetalFeatures._supportedFeatureSets.GetEnumerator());
        }

        public Span<MTLFeatureSet> FeatureSet => _featureSet;

        public MTLFeatureSet MaxFeatureSet => _gd.MetalFeatures.MaxFeatureSet;
    }
}
#endif
