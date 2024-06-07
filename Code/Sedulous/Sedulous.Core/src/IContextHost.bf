namespace Sedulous.Core;

interface IContextHost
{
	IContext Context { get; }

	bool IsRunning { get; }

	bool IsSuspended { get; }

	bool SupportsMultipleThreads { get; }

	void Exit();
}