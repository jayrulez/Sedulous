using System;
namespace Sedulous.RAL;

abstract class CommandQueue : QueryInterface
{
	public abstract void Wait(in Fence fence, uint64 value);
	public abstract void Signal(in Fence fence, uint64 value);
	public abstract void ExecuteCommandLists(Span<CommandList> command_lists);
}