using System;
using System.Reflection;
namespace Sedulous.Sandbox;

class Program
{
	public static void Main()
	{
		var app = scope SandboxApplication();
		app.Run();
	}
}