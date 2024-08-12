using System;

namespace Sedulous.GAL
{
	/// <summary>
	/// A device resource encapsulating all state in a graphics pipeline. Used in 
	/// <see cref="CommandList.SetPipeline(Pipeline)"/> to prepare a <see cref="CommandList"/> for draw commands.
	/// See <see cref="GraphicsPipelineDescription"/>.
	/// </summary>
	public abstract class Pipeline : DeviceResource, IDisposable
	{
		internal this(ref GraphicsPipelineDescription graphicsDescription)
			: this(graphicsDescription.ResourceLayouts)
		{
#if VALIDATE_USAGE
			GraphicsOutputDescription = graphicsDescription.Outputs;
#endif
		}

		internal this(ref ComputePipelineDescription computeDescription)
			: this(computeDescription.ResourceLayouts)
			{ }

		internal this(ResourceLayout[] resourceLayouts)
		{
#if VALIDATE_USAGE
			//ResourceLayouts = Util.ShallowClone(resourceLayouts);
			ResourceLayouts = new .[resourceLayouts.Count];
			for(int i = 0; i < ResourceLayouts.Count; i++)
			{
				ResourceLayouts[i] = resourceLayouts[i];
			}
#endif
		}

		public ~this()
		{
#if VALIDATE_USAGE
			delete ResourceLayouts;
#endif
		}

		/// <summary>
		/// Gets a value indicating whether this instance represents a compute Pipeline.
		/// If false, this instance is a graphics pipeline.
		/// </summary>
		public abstract bool IsComputePipeline { get; }

		/// <summary>
		/// A string identifying this instance. Can be used to differentiate between objects in graphics debuggers and other
		/// tools.
		/// </summary>
		public abstract String Name { get; set; }

		/// <summary>
		/// A bool indicating whether this instance has been disposed.
		/// </summary>
		public abstract bool IsDisposed { get; }

		/// <summary>
		/// Frees unmanaged device resources controlled by this instance.
		/// </summary>
		public abstract void Dispose();

#if VALIDATE_USAGE
		internal OutputDescription GraphicsOutputDescription { get; }
		internal ResourceLayout[] ResourceLayouts { get; }
#endif
	}
}
