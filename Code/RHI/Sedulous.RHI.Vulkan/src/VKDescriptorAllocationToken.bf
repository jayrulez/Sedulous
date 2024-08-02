using Bulkan;

namespace Sedulous.RHI.Vulkan;

/// <summary>
/// This struct represent a helper to allocate new descriptors.
/// </summary>
public struct VKDescriptorAllocationToken
{
	/// <summary>
	/// The descriptor set type.
	/// </summary>
	public readonly VkDescriptorSet DescriptorSet;

	/// <summary>
	/// The descriptor set pool.
	/// </summary>
	public readonly VkDescriptorPool DescriptorPool;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKDescriptorAllocationToken" /> struct.
	/// </summary>
	/// <param name="pool">The descriptor pool.</param>
	/// <param name="set">The descriptor set type.</param>
	public this(VkDescriptorPool pool, VkDescriptorSet set)
	{
		DescriptorPool = pool;
		DescriptorSet = set;
	}
}
