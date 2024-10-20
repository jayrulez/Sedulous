using System.Collections;
using Sedulous.RHI;
namespace Sedulous.Graphics.FrameGraph;

class FrameGraph
{
	private readonly GraphicsContext mGraphicsContext;

	private List<RenderPass> mRenderPasses = new .() ~ delete _;
	private List<FrameGraphResource> mResources = new .() ~ delete _;

	public this(GraphicsContext graphicsContext)
	{
		mGraphicsContext = graphicsContext;
	}

	public ~this()
	{
		for (var resource in mResources)
		{
			delete resource;
		}
	}

	// Register a new render pass in the graph
	public void AddPass(RenderPass pass)
	{
		mRenderPasses.Add(pass);
	}

	// Add a resource (e.g., texture, buffer) to the graph
	public void AddResource(Buffer resource)
	{
		mResources.Add(new FrameGraphBuffer(resource));
	}

	// Add a resource (e.g., texture, buffer) to the graph
	public void AddResource(Texture resource)
	{
		mResources.Add(new FrameGraphTexture(resource));
	}

	// Add a resource (e.g., texture, buffer) to the graph
	public void AddResource(FrameBuffer resource)
	{
		mResources.Add(new FrameGraphFrameBuffer(resource));
	}

	// Build the graph (resolve pass dependencies)
	public void Build()
	{
		for (var pass in mRenderPasses)
		{
			pass.Setup();
		}
	}

	// Execute the render graph by iterating over passes in the right order
	public void Execute(CommandBuffer commandBuffer)
	{
		for (var pass in mRenderPasses)
		{
			pass.Execute(commandBuffer);
		}
	}
}