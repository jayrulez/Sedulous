using System.Collections;
using System;
namespace Sedulous.RAL;

class ResourceStateTracker
{
	private Resource m_resource;

	private struct SubresourceStateKey : IHashable
	{
		public uint32 MipLevel;
		public uint32 ArrayLayer;

		public int GetHashCode()
		{
			int hash = 0;
			hash = HashCode.Mix(hash, MipLevel);
			hash = HashCode.Mix(hash, ArrayLayer);
			return hash;
		}
	}

	private Dictionary<SubresourceStateKey, ResourceState> m_subresource_states = new .() ~ delete _;
	private Dictionary<ResourceState, uint> m_subresource_state_groups = new .() ~ delete _;
	private ResourceState m_resource_state = ResourceState.kUnknown;

	public this(Resource resource)
	{
		m_resource = resource;
	}

	public bool HasResourceState()
	{
		return m_subresource_states.IsEmpty;
	}

	public ResourceState GetResourceState()
	{
		return m_resource_state;
	}

	public void SetResourceState(ResourceState state)
	{
		m_subresource_states.Clear();
		m_resource_state = state;
		m_subresource_state_groups.Clear();
	}

	public ResourceState GetSubresourceState(uint32 mip_level, uint32 array_layer)
	{
		SubresourceStateKey key = .()
			{
				MipLevel = mip_level,
				ArrayLayer = array_layer
			};
		if (m_subresource_states.ContainsKey(key))
		{
			return m_subresource_states[key];
		}
		return m_resource_state;
	}

	public void SetSubresourceState(uint32 mip_level, uint32 array_layer, ResourceState state)
	{
		if (HasResourceState() && GetResourceState() == state)
		{
			return;
		}
		SubresourceStateKey key = .()
			{
				MipLevel = mip_level,
				ArrayLayer = array_layer
			};
		if (m_subresource_states.ContainsKey(key))
		{
			if (--m_subresource_state_groups[m_subresource_states[key]] == 0)
			{
				m_subresource_state_groups.Remove(m_subresource_states[key]);
			}
		}
		m_subresource_states[key] = state;
		++m_subresource_state_groups[state];
		if (m_subresource_state_groups.Count == 1 &&
			m_subresource_state_groups.GetEnumerator().Value == m_resource.GetLayerCount() * m_resource.GetLevelCount())
		{
			m_subresource_state_groups.Clear();
			m_subresource_states.Clear();
			m_resource_state = state;
		}
	}

	public void Merge(in ResourceStateTracker other)
	{
		if (other.HasResourceState())
		{
			ResourceState state = other.GetResourceState();
			if (state != ResourceState.kUnknown)
			{
				SetResourceState(state);
			}
		} else
		{
			for (uint32 i = 0; i < other.m_resource.GetLevelCount(); ++i)
			{
				for (uint32 j = 0; j < other.m_resource.GetLayerCount(); ++j)
				{
					ResourceState state = other.GetSubresourceState(i, j);
					if (state != ResourceState.kUnknown)
					{
						SetSubresourceState(i, j, state);
					}
				}
			}
		}
	}
}