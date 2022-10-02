using System.Threading;
using System;
using System.Collections;
namespace Sedulous.Core.Jobs;

using internal Sedulous.Core.Jobs;

internal class MainThreadWorker : Worker
{
	public this(JobSystem jobSystem, StringView name)
		: base(jobSystem, name)
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