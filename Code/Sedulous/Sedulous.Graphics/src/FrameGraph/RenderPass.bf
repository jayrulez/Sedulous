using System;
using System.Collections;
using Sedulous.RHI;
namespace Sedulous.Graphics.FrameGraph;

abstract class RenderPass
{
	public String Name { get; private set; } = new .() ~ delete _;

	protected readonly List<FrameGraphResource> Inputs { get; private set; } = new .() ~ delete _;
	protected readonly List<FrameGraphResource> Outputs { get; private set; } = new .() ~ delete _;

	public this(StringView name)
	{
		Name.Set(name);
	}

	// Setup method to prepare resources and pass dependencies
	public abstract void Setup();

	// Each render pass must implement this method
	public abstract void Execute(CommandBuffer commandBuffer);
}