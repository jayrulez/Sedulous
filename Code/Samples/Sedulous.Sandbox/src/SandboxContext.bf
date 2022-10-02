using Sedulous.Core;
using Sedulous.Core.Abstractions;
using Sedulous.Foundation.Logging.Abstractions;
namespace Sedulous.Sandbox;

class SandboxContext : Context
{
	public this(IApplication application, ContextConfiguration configuration)
		: base(application, configuration)
	{
	}
}