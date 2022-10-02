using System;
namespace Sedulous.Foundation.Logging.Abstractions;

interface ILogger
{
	LogLevel MimimumLogLevel { get; }
	String Name { get; }

	void Log(LogLevel logLevel, StringView format, params Object[] args);
}