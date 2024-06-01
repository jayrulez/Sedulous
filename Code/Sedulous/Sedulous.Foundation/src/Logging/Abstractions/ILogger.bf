using System;
namespace Sedulous.Foundation.Logging.Abstractions;

interface ILogger
{
	LogLevel MimimumLogLevel { get; set; }
	String Name { get; }

	void Log(LogLevel logLevel, StringView format, params Object[] args);
}