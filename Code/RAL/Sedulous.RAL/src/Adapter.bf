using System;
namespace Sedulous.RAL;

abstract class Adapter : QueryInterface
{
	public abstract void GetName(String name);

	public abstract Result<void> CreateDevice(out Device device);

	public abstract void DestroyDevice(ref Device device);
}