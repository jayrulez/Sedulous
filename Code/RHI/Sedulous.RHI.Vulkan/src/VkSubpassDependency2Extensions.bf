using System;
namespace Bulkan;

// only the src/dst attributes differs
/*private struct DependencyHasher {
	ccstd.hash_t operator()(const VkSubpassDependency2& info) const {
		static_assert(std.is_trivially_copyable<VkSubpassDependency2>.value && sizeof(VkSubpassDependency2) % 8 == 0, "VkSubpassDependency2 must be 8 bytes aligned and trivially copyable");
		return ccstd.hash_range(reinterpret_cast<const uint64*>(&info.srcSubpass),
			reinterpret_cast<const uint64*>(&info.dependencyFlags));
	}
}
private struct DependencyComparer {
	size_t operator()(const VkSubpassDependency2& lhs, const VkSubpassDependency2& rhs) const {
		auto size = (size_t>(reinterpret_cast<const uint8*>(&lhs.dependencyFlags) - reinterpret_cast<const uint8*)&lhs.srcSubpass);
		return !memcmp(&lhs.srcSubpass, &rhs.srcSubpass, size);
	}
}*/

extension VkSubpassDependency2 : IHashable
{
	public int GetHashCode()
	{
		Compiler.Assert(sizeof(Self) % 8 == 0, "VkSubpassDependency2 must be 8 bytes aligned and trivially copyable");

		int hash = 0;
		/*

		sType = .VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2;
		public void* pNext = null;
		public uint32 srcSubpass;
		public uint32 dstSubpass;
		public VkPipelineStageFlags srcStageMask;
		public VkPipelineStageFlags dstStageMask;
		public VkAccessFlags srcAccessMask;
		public VkAccessFlags dstAccessMask;
		public VkDependencyFlags dependencyFlags;

		*/

		hash = HashCode.Mix(hash, sType.Underlying);
		hash = HashCode.Mix(hash, (int)pNext);
		hash = HashCode.Mix(hash, srcSubpass);
		hash = HashCode.Mix(hash, dstSubpass);
		hash = HashCode.Mix(hash, srcStageMask.Underlying);
		hash = HashCode.Mix(hash, dstStageMask.Underlying);
		hash = HashCode.Mix(hash, srcAccessMask.Underlying);
		hash = HashCode.Mix(hash, dstAccessMask.Underlying);
		hash = HashCode.Mix(hash, dependencyFlags.Underlying);

		return hash;
	}

	public static int operator<=>(Self lhs, Self rhs)
	{
		var lhs;
		var rhs;
		return Internal.MemCmp(&lhs, &rhs, sizeof(Self));
	}
}