using System.Collections;
using System;
namespace NRI.Validation;

class QueryPoolVal :QueryPool, DeviceObjectVal<QueryPool>
{
	private List<uint64> m_DeviceState;
	private uint32 m_QueryNum;
	private QueryType m_QueryType;

	public this(DeviceVal device, QueryPool queryPool, QueryType queryType, uint32 queryNum) : base(device, queryPool)
	{
		m_DeviceState = Allocate!<List<uint64>>(m_Device.GetAllocator());

		m_QueryNum = queryNum;

		if (queryNum != 0)
		{
			readonly int batchNum = Math.Max(queryNum >> 6, 1u);
			m_DeviceState.Resize(batchNum, 0);
		}
	}

	public ~this()
	{
		Deallocate!(m_Device.GetAllocator(), m_DeviceState);
	}

	public bool SetQueryState(uint32 offset, bool state)
	{
		readonly uint batchIndex = offset >> 6;
		readonly uint64 batchValue = m_DeviceState[(.)batchIndex];
		readonly uint bitIndex = 1uL << (offset & 63);
		readonly uint64 maskBitValue = ~bitIndex;
		readonly uint64 bitValue = state ? bitIndex : 0;
		m_DeviceState[(.)batchIndex] = (batchValue & maskBitValue) | bitValue;
		return batchValue & bitIndex != 0;
	}

	public void ResetQueries(uint32 offset, uint32 number)
	{
		for (uint32 i = 0; i < number; i++)
			SetQueryState(offset + i, false);
	}

	public  uint32 GetQueryNum()
		{ return m_QueryNum; }

	public  QueryType GetQueryType()
		{ return m_QueryType; }

	public  bool IsImported()
		{ return m_QueryNum == 0; }


	public void SetDebugName(char8* name)
	{
		m_Name.Set(scope .(name));
		m_ImplObject.SetDebugName(name);
	}

	public uint32 GetQuerySize()
	{
		return m_ImplObject.GetQuerySize();
	}
}