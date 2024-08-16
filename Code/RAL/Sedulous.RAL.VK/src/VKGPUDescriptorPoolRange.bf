using Bulkan;
namespace Sedulous.RAL.VK;

class VKGPUDescriptorPoolRange
{
	private typealias OnDestroyRangeCallback = delegate void(VKGPUDescriptorPoolRange range);

	private VKGPUBindlessDescriptorPoolTyped m_pool;
	private uint32 m_offset;
	private uint32 m_size;
	//private std::unique_ptr<VKGPUDescriptorPoolRange, std::function<void(VKGPUDescriptorPoolRange*)>> m_callback;
	private OnDestroyRangeCallback m_callback;

	public this(VKGPUBindlessDescriptorPoolTyped pool, uint32 offset, uint32 size)
	{
		m_pool = pool;
		m_offset = offset;
		m_size = size;
		m_callback = new [ /*=m_offset,  =m_size, =m_poo*/=] (range) =>
			{
				m_pool.OnRangeDestroy(m_offset, m_size);
			};
	}

	public ~this()
	{
		m_callback(this);
		delete m_callback;
	}

	public VkDescriptorSet GetDescriptorSet()
	{
		return m_pool.GetDescriptorSet();
	}
	public uint32 GetOffset()
	{
		return m_offset;
	}
}