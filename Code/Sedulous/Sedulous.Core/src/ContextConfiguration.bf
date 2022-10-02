using Sedulous.Foundation.Logging.Abstractions;
using System.Collections;
using Sedulous.Core.Abstractions;
namespace Sedulous.Core;

class ContextConfiguration
{
	public ILogger Logger { get; set; }

	public readonly List<IContextFactoryInitializer> FactoryInitializers { get; } = new .() ~ DeleteContainerAndItems!(_);
}