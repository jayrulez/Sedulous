using System.Collections;
using System;
using Sedulous.Foundation.Logging.Abstractions;
namespace Sedulous.Core;

class ContextInitializer
{
	private List<Subsystem> mSubsystems = new .() ~ delete _;

	public Span<Subsystem> Subsystems => mSubsystems;

	public LogLevel LogLevel { get; set; }

	internal this()
	{

	}

	public Result<void> AddSystem(Subsystem subsystem)
	{
		if (mSubsystems.Contains(subsystem))
		{
			return .Err;
		}

		mSubsystems.Add(subsystem);

		return .Ok;
	}
}