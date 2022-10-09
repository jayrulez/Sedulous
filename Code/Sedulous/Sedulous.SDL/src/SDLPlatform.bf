using Sedulous.Core.Abstractions;
using Sedulous.Foundation;
using Sedulous.Core;
namespace Sedulous.SDL;

class SDLPlatform : IPlatform
{


	public bool Disposed
	{
		get
		{
			return default;
		}
	}

	public EventAccessor<SubsystemUpdateEventHandler> Updating { get; } = new .() ~ delete _;

	public Context Context
	{
		get
		{
			return default;
		}
	}

	public void Update(ApplicationTime time)
	{
	}
}