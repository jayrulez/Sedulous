using System;
namespace Sedulous.Core;

abstract class Plugin
{
	public virtual void OnInitialize(Engine engine) => void();
	public virtual void OnShutdown() => void();
}