using System;
namespace Sedulous.Foundation.Jobs;

using internal Sedulous.Foundation.Jobs;

internal class MainThreadWorker : Worker
{
	public this(JobSystem jobSystem, StringView name)
		: base(jobSystem, name, .Persistent)
	{
	}

	public ~this()
	{
	}

	public override void Update()
	{
		ProcessJobs();
	}
}