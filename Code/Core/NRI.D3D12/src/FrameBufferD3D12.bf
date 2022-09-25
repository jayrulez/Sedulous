using System.Collections;
using Win32.Graphics.Direct3D12;
using Win32;
namespace NRI.D3D12;

class FrameBufferD3D12 : FrameBuffer
{
	private DeviceD3D12 m_Device;
	private List<D3D12_CPU_DESCRIPTOR_HANDLE> m_RenderTargets;
	private D3D12_CPU_DESCRIPTOR_HANDLE m_DepthStencilTarget = .();
	private List<ClearDesc> m_ClearDescs;

	public this(DeviceD3D12 device)
	{
		m_Device = device;

		m_RenderTargets = Allocate!<List<D3D12_CPU_DESCRIPTOR_HANDLE>>(m_Device.GetAllocator());
		m_ClearDescs = Allocate!<List<ClearDesc>>(m_Device.GetAllocator());
	}

	public ~this()
	{
		Deallocate!(m_Device.GetAllocator(), m_ClearDescs);
		Deallocate!(m_Device.GetAllocator(), m_RenderTargets);
	}
	public DeviceD3D12 GetDevice() => m_Device;

	public Result Create(FrameBufferDesc frameBufferDesc)
	{
		if (frameBufferDesc.colorAttachmentNum > 0)
		{
			m_RenderTargets.Resize(frameBufferDesc.colorAttachmentNum);

			for (uint32 i = 0; i < frameBufferDesc.colorAttachmentNum; i++)
			{
				m_RenderTargets[i] = .() { ptr = ((DescriptorD3D12)frameBufferDesc.colorAttachments[i]).GetPointerCPU() };

				if (frameBufferDesc.colorClearValues != null)
				{
					ClearDesc clearDesc = .() { value = frameBufferDesc.colorClearValues[i], attachmentContentType = AttachmentContentType.COLOR, colorAttachmentIndex = i };
					m_ClearDescs.Add(clearDesc);
				}
			}
		}

		if (frameBufferDesc.depthStencilAttachment != null)
		{
			m_DepthStencilTarget = .(){ ptr = ((DescriptorD3D12)frameBufferDesc.depthStencilAttachment).GetPointerCPU() };

			if (frameBufferDesc.depthStencilClearValue != null)
			{
				ClearDesc clearDesc = .() { value = *frameBufferDesc.depthStencilClearValue, attachmentContentType = AttachmentContentType.DEPTH_STENCIL, colorAttachmentIndex = 0 };
				m_ClearDescs.Add(clearDesc);
			}
		}

		return Result.SUCCESS;
	}

	public void Bind(ID3D12GraphicsCommandList* graphicsCommandList, RenderPassBeginFlag renderPassBeginFlag)
	{
		graphicsCommandList.OMSetRenderTargets(
			(uint32)m_RenderTargets.Count,
			&m_RenderTargets[0], FALSE, m_DepthStencilTarget.ptr != 0 ? &m_DepthStencilTarget : null
			);

		if (renderPassBeginFlag == RenderPassBeginFlag.SKIP_FRAME_BUFFER_CLEAR || m_ClearDescs.IsEmpty)
			return;

		Clear(graphicsCommandList, &m_ClearDescs[0], (uint32)m_ClearDescs.Count, null, 0);
	}

	public void Clear(ID3D12GraphicsCommandList* graphicsCommandList, ClearDesc* clearDescs, uint32 clearDescNum, Rect* rects, uint32 rectNum)
	{
		D3D12_RECT* rectsD3D12 = STACK_ALLOC!<D3D12_RECT>(rectNum);
		ConvertRects(rectsD3D12, rects, rectNum);

		for (uint32 i = 0; i < clearDescNum; i++)
		{
			if (AttachmentContentType.COLOR == clearDescs[i].attachmentContentType)
			{
				if (clearDescs[i].colorAttachmentIndex < m_RenderTargets.Count)
					graphicsCommandList.ClearRenderTargetView(m_RenderTargets[clearDescs[i].colorAttachmentIndex], &clearDescs[i].value.rgba32f.r, rectNum, rectsD3D12);
			}
			else if (m_DepthStencilTarget.ptr != 0)
			{
				D3D12_CLEAR_FLAGS clearFlags = (D3D12_CLEAR_FLAGS)0;
				switch (clearDescs[i].attachmentContentType)
				{
				case AttachmentContentType.DEPTH:
					clearFlags = .D3D12_CLEAR_FLAG_DEPTH;
					break;
				case AttachmentContentType.STENCIL:
					clearFlags = .D3D12_CLEAR_FLAG_STENCIL;
					break;
				case AttachmentContentType.DEPTH_STENCIL:
					clearFlags = .D3D12_CLEAR_FLAG_DEPTH | .D3D12_CLEAR_FLAG_STENCIL;
					break;

				default: break;
				}

				if (clearFlags != 0)
					graphicsCommandList.ClearDepthStencilView(m_DepthStencilTarget, clearFlags, clearDescs[i].value.depthStencil.depth, clearDescs[i].value.depthStencil.stencil, rectNum, rectsD3D12);
			}
		}
	}


	public void SetDebugName(char8* name)
	{
	}
}