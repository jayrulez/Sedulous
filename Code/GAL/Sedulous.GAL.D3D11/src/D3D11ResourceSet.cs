using System;
namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL;

    public class D3D11ResourceSet : ResourceSet
    {
        private String _name;
        private bool _disposed;

        public new BindableResource[] Resources { get; }
        public new D3D11ResourceLayout Layout { get; }

        public this(in ResourceSetDescription description) : base(description)
        {
			//Util.ShallowClone(description.BoundResources);
            Resources = new .[description.BoundResources.Count];
			for(int i = 0; i < description.BoundResources.Count; i++)
			{
				Resources[i] = description.BoundResources[i];
			}
            Layout = Util.AssertSubtype<ResourceLayout, D3D11ResourceLayout>(description.Layout);
        }

        public override String Name
        {
            get => _name;
            set => _name = value;
        }

        public override bool IsDisposed => _disposed;

        public override void Dispose()
        {
            _disposed = true;
        }
    }
}
