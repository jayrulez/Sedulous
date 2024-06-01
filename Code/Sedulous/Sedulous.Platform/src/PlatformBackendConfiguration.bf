namespace Sedulous.Platform;

struct PlatformBackendConfiguration
{
	public IPlatformBackend.WindowConfiguration PrimaryWindowConfiguration { get; set mut; }
}