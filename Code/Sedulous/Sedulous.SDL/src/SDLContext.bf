using Sedulous.Core;
using Sedulous.Core.Abstractions;
namespace Sedulous.SDL;

class SDLContext : Context
{
	public this(IApplication application, SDLContextConfiguration configuration)
		: base(application, configuration)
	{
	}
}