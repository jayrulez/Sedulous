using System;
namespace Sedulous.GAL.MTL
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.MTL;

    public class MTLResourceSet : ResourceSet
    {
        private bool _disposed;
        public new BindableResource[] Resources { get; }
        public new MTLResourceLayout Layout { get; }

        public this(in ResourceSetDescription description, MTLGraphicsDevice gd) : base(description)
        {
			//Resources = Util.ShallowClone(description.BoundResources);
            Resources = new .() {Count = description.BoundResources.Count};
			for(int i = 0; i < description.BoundResources.Count; i++)
			{
				Resources[i] = description.BoundResources[i];
			}
            Layout = Util.AssertSubtype<ResourceLayout, MTLResourceLayout>(description.Layout);
        }

        public override String Name { get; set; }

        public override bool IsDisposed => _disposed;

        public override void Dispose()
        {
            _disposed = true;
        }
    }
}
