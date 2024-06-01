namespace Sedulous.Core;

interface IContextHost
{
	IContext Context { get; }

	ContextInitializingCallback OnContextInitializing { get; }

	ContextInitializedCallback OnContextInitialized { get; }

	ContextShuttingDownCallback OnContextShuttingDown { get; }

	bool IsRunning { get; }

	bool IsSuspended { get; }

	bool SupportsMultipleThreads { get; }

	void Exit();
}