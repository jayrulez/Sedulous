using System;
namespace Sedulous.RAL;

abstract class Resource : QueryInterface
{
	public abstract void CommitMemory(MemoryType memory_type);
	public abstract void BindMemory(in Memory memory, uint64 offset);
	public abstract ResourceType GetResourceType();
	public abstract Format GetFormat();
	public abstract MemoryType GetMemoryType();
	public abstract uint64 GetWidth();
	public abstract uint32 GetHeight();
	public abstract uint16 GetLayerCount();
	public abstract uint16 GetLevelCount();
	public abstract uint32 GetSampleCount();
	public abstract uint64 GetAccelerationStructureHandle();
	public abstract void SetName(in String name);
	public abstract uint8* Map();
	public abstract void Unmap();
	public abstract void UpdateUploadBuffer(uint64 buffer_offset, void* data, uint64 num_bytes);
	public abstract void UpdateUploadBufferWithTextureData(uint64 buffer_offset,
		uint32 buffer_row_pitch,
		uint32 buffer_depth_pitch,
		void* src_data,
		uint32 src_row_pitch,
		uint32 src_depth_pitch,
		uint32 num_rows,
		uint32 num_slices);
	public abstract bool AllowCommonStatePromotion(ResourceState state_after);
	public abstract ResourceState GetInitialState();
	public abstract MemoryRequirements GetMemoryRequirements();
	public abstract bool IsBackBuffer();
}

abstract class ResourceBase : Resource
{
	private ResourceStateTracker m_resource_state_tracker;
	private ResourceState m_initial_state = ResourceState.kUnknown;

	protected Memory m_memory;
	protected MemoryType m_memory_type = MemoryType.kDefault;

	public Format format = .FORMAT_UNDEFINED;
	public ResourceType resource_type = ResourceType.kUnknown;
	public Resource acceleration_structures_memory;
	public bool is_back_buffer = false;

	public this()
	{
		m_resource_state_tracker = new .(this);
	}

	public ~this()
	{
		delete m_resource_state_tracker;
	}


	public override ResourceType GetResourceType()
	{
		return resource_type;
	}

	public override Format GetFormat()
	{
		return format;
	}

	public override MemoryType GetMemoryType()
	{
		return m_memory_type;
	}

	public override void UpdateUploadBuffer(uint64 buffer_offset, void* data, uint64 num_bytes)
	{
		void* dst_data = Map() + buffer_offset;
		Internal.MemCpy(dst_data, data, (int)num_bytes);
		Unmap();
	}

	public override void UpdateUploadBufferWithTextureData(uint64 buffer_offset,
		uint32 buffer_row_pitch,
		uint32 buffer_depth_pitch,
		void* src_data,
		uint32 src_row_pitch,
		uint32 src_depth_pitch,
		uint32 num_rows,
		uint32 num_slices)
	{
		void* dst_data = Map() + buffer_offset;
		for (uint32 z = 0; z < num_slices; ++z)
		{
			uint8* dest_slice = ((uint8*)dst_data) + buffer_depth_pitch * z;
			readonly uint8* src_slice = ((uint8*)src_data) + src_depth_pitch * z;
			for (uint32 y = 0; y < num_rows; ++y)
			{
				Internal.MemCpy(dest_slice + buffer_row_pitch * y, src_slice + src_row_pitch * y, src_row_pitch);
			}
		}
		Unmap();
	}

	public override ResourceState GetInitialState()
	{
		return m_initial_state;
	}

	public override bool IsBackBuffer()
	{
		return is_back_buffer;
	}

	public void SetInitialState(ResourceState state)
	{
		m_initial_state = state;
		m_resource_state_tracker.SetResourceState(m_initial_state);
	}
	public readonly ref ResourceStateTracker GetGlobalResourceStateTracker()
	{
		return ref m_resource_state_tracker;
	}
}