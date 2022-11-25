using System.Collections;
namespace Sedulous.Core;

class EngineConfiguration
{
	public readonly List<Plugin> Plugins = new List<Plugin>() ~ delete _;

	public void AddPlugin(Plugin plugin)
	{
		Plugins.Add(plugin);
	}
}