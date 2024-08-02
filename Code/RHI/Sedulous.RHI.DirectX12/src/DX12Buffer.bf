using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;
using Win32.Foundation;
using Win32;

namespace Sedulous.RHI.DirectX12;
using internal Sedulous.RHI.DirectX12;
using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// Represents a DirectX buffer object.
/// </summary>
public class DX12Buffer : Buffer
{
	internal uint32 alignedSize;

	private D3D12_RESOURCE_DESC nativeDescription;

	private D3D12_CPU_DESCRIPTOR_HANDLE? shaderResourceView;

	private D3D12_CPU_DESCRIPTOR_HANDLE? constantBufferView;

	private D3D12_CPU_DESCRIPTOR_HANDLE? unorderedAccessView;

	/// <summary>
	/// The DirectX texture instance.
	/// </summary>
	public ID3D12Resource* NativeBuffer;

	/// <summary>
	/// The DirectX resource state.
	/// </summary>
	public D3D12_RESOURCE_STATES nativeResourceState;

	private String name = new .() ~ delete _;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			if (!String.IsNullOrEmpty(value))
			{
				name.Set(value);
				SetDebugName(NativeBuffer, value);
			}
		}
	}

	/// <summary>
	/// Gets the shader resource view.
	/// </summary>
	public D3D12_CPU_DESCRIPTOR_HANDLE ShaderResourceView
	{
		get
		{
			if (!shaderResourceView.HasValue)
			{
				shaderResourceView = GetShaderResourceView();
			}
			return shaderResourceView.Value;
		}
	}

	/// <summary>
	/// Gets the constant buffer view.
	/// </summary>
	public D3D12_CPU_DESCRIPTOR_HANDLE ConstantBufferView
	{
		get
		{
			if (!constantBufferView.HasValue)
			{
				constantBufferView = GetConstantBufferView();
			}
			return constantBufferView.Value;
		}
	}

	/// <summary>
	/// Gets the unordered view.
	/// </summary>
	public D3D12_CPU_DESCRIPTOR_HANDLE UnorderedAccessView
	{
		get
		{
			if (!unorderedAccessView.HasValue)
			{
				unorderedAccessView = GetUnorderedAccessView();
			}
			return unorderedAccessView.Value;
		}
	}

	/// <inheritdoc />
	public override void* NativePointer
	{
		get
		{
			if (NativeBuffer != null)
			{
				return NativeBuffer;
			}
			return null;
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12Buffer" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="data">The data pointer.</param>
	/// <param name="description">A buffer description.</param>
	public this(DX12GraphicsContext context, void* data, ref BufferDescription description)
		: base(context, ref description)
	{
		D3D12_RESOURCE_FLAGS flags = .D3D12_RESOURCE_FLAG_NONE;
		if ((description.Flags & BufferFlags.UnorderedAccess) != 0)
		{
			flags |= .D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
		}
		alignedSize = Helpers.AlignUp(description.SizeInBytes);
		nativeDescription = D3D12_RESOURCE_DESC.Buffer(alignedSize, flags, 0UL);
		nativeResourceState = D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COMMON;
		D3D12_HEAP_TYPE heapType = .D3D12_HEAP_TYPE_DEFAULT;
		if (description.Usage == ResourceUsage.Staging)
		{
			heapType = .D3D12_HEAP_TYPE_READBACK;
			nativeResourceState = D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_DEST;
		}
		else if (description.Usage == ResourceUsage.Dynamic)
		{
			heapType = .D3D12_HEAP_TYPE_UPLOAD;
			nativeResourceState = D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_GENERIC_READ;
		}
		HRESULT result = context.DXDevice.CreateCommittedResource(scope D3D12_HEAP_PROPERTIES(heapType), .D3D12_HEAP_FLAG_NONE, &nativeDescription, nativeResourceState, null, ID3D12Resource.IID, (void**)&NativeBuffer);
		if (!SUCCEEDED(result))
		{
			Context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
		}
		if (data != null)
		{
			SetData(context.CopyCommandList, data, Description.SizeInBytes);
		}
	}

	/// <summary>
	/// Fill the buffer from a pointer.
	/// </summary>
	/// <param name="commandList">The commandlist where execute commands.</param>
	/// <param name="source">The data pointer.</param>
	/// <param name="sourceSizeInBytes">The size in bytes.</param>
	/// <param name="destinationOffsetInBytes">The offset in bytes.</param>
	public void SetData(ID3D12GraphicsCommandList* commandList, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0)
	{
		//IL_007c: Unknown result type (might be due to invalid IL or missing references)
		if (sourceSizeInBytes == 0 || Description.SizeInBytes < sourceSizeInBytes)
		{
			Context.ValidationLayer?.Notify("DX12", "invalid source size in bytes.");
		}
		DX12GraphicsContext context = Context as DX12GraphicsContext;
		if ((Description.Usage & ResourceUsage.Dynamic) == ResourceUsage.Dynamic || (Description.Usage & ResourceUsage.Staging) == ResourceUsage.Staging)
		{
			void* bufferPointer = null;
			NativeBuffer.Map(0, null, &bufferPointer);
			Internal.MemCpy((void*)((int)bufferPointer + destinationOffsetInBytes), (void*)source, sourceSizeInBytes);
			NativeBuffer.Unmap(0, null);
		}
		else
		{
			uint64 bufferPointer = context.BufferUploader.Allocate(sourceSizeInBytes);
			Internal.MemCpy((void*)(int)bufferPointer, (void*)source, sourceSizeInBytes);
			D3D12_RESOURCE_STATES resourceState = nativeResourceState;
			ResourceTransition(commandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_DEST);
			commandList.CopyBufferRegion(NativeBuffer, destinationOffsetInBytes, context.BufferUploader.nativeBuffer, context.BufferUploader.CalculateOffset(bufferPointer), sourceSizeInBytes);
			ResourceTransition(commandList, resourceState);
		}
	}

	/// <summary>
	/// Copy this buffer in the destionation buffer.
	/// </summary>
	/// <param name="commandList">The commandlist where execute commands.</param>
	/// <param name="destination">The destination buffer.</param>
	/// <param name="sizeInBytes">The data size in bytes to copy.</param>
	/// <param name="sourceOffset">The source buffer offset in bytes.</param>
	/// <param name="destinationOffset">The destionation buffer offset in bytes.</param>
	public void CopyTo(ID3D12GraphicsCommandList* commandList, Buffer destination, uint32 sizeInBytes, uint32 sourceOffset = 0, uint32 destinationOffset = 0)
	{
		DX12Buffer destinationBuffer = destination as DX12Buffer;
		D3D12_RESOURCE_STATES srcResourceState = nativeResourceState;
		D3D12_RESOURCE_STATES dstResourceState = destinationBuffer.nativeResourceState;
		ResourceTransition(commandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_SOURCE);
		destinationBuffer.ResourceTransition(commandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_COPY_DEST);
		commandList.CopyBufferRegion(destinationBuffer.NativeBuffer, destinationOffset, NativeBuffer, sourceOffset, sizeInBytes);
		ResourceTransition(commandList, srcResourceState);
		destinationBuffer.ResourceTransition(commandList, dstResourceState);
	}

	/// <summary>
	/// Transition this buffer to a new state.
	/// </summary>
	/// <param name="commandList">The commandlist used to execute the barrier transition.</param>
	/// <param name="newResourceState">The new state to set.</param>
	/// <param name="subResource">The subResource of this buffer.</param>
	public void ResourceTransition(ID3D12GraphicsCommandList* commandList, D3D12_RESOURCE_STATES newResourceState, int32 subResource = 0)
	{
		if (nativeResourceState != newResourceState && nativeResourceState != D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_GENERIC_READ)
		{
			commandList.ResourceBarrierTransition(NativeBuffer, nativeResourceState, newResourceState, subResource);
			nativeResourceState = newResourceState;
		}
	}

	/// <summary>
	/// Return a new Buffer with ResourceUsage set to staging.
	/// </summary>
	/// <returns>New staging Buffer.</returns>
	public DX12Buffer ToStaging()
	{
		BufferDescription stagingDescription = Description;
		stagingDescription.Flags = BufferFlags.None;
		stagingDescription.CpuAccess = ResourceCpuAccess.Write | ResourceCpuAccess.Read;
		stagingDescription.Usage = ResourceUsage.Staging;
		return new DX12Buffer(Context as DX12GraphicsContext, null, ref stagingDescription);
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	private D3D12_CPU_DESCRIPTOR_HANDLE GetConstantBufferView()
	{
		D3D12_CPU_DESCRIPTOR_HANDLE cbv = default(D3D12_CPU_DESCRIPTOR_HANDLE);
		D3D12_CONSTANT_BUFFER_VIEW_DESC  constantBufferViewDescription = default(D3D12_CONSTANT_BUFFER_VIEW_DESC );
		constantBufferViewDescription.SizeInBytes = Math.Min((uint32)alignedSize, 65536);
		constantBufferViewDescription.BufferLocation = NativeBuffer.GetGPUVirtualAddress();
		D3D12_CONSTANT_BUFFER_VIEW_DESC  description = constantBufferViewDescription;
		DX12GraphicsContext obj = Context as DX12GraphicsContext;
		cbv = obj.ShaderResourceViewAllocator.Allocate();
		obj.DXDevice.CreateConstantBufferView(&description, cbv);
		return cbv;
	}

	private D3D12_CPU_DESCRIPTOR_HANDLE GetShaderResourceView()
	{
		D3D12_CPU_DESCRIPTOR_HANDLE srv = default(D3D12_CPU_DESCRIPTOR_HANDLE);
		if ((Description.Flags & BufferFlags.ShaderResource) != 0)
		{
			D3D12_SHADER_RESOURCE_VIEW_DESC  shaderResourceViewDescription = default(D3D12_SHADER_RESOURCE_VIEW_DESC );
			shaderResourceViewDescription.Shader4ComponentMapping = (uint32)DX12GraphicsContext.DefaultShader4ComponentMapping;
			shaderResourceViewDescription.Format = .DXGI_FORMAT_UNKNOWN;
			shaderResourceViewDescription.ViewDimension = .D3D12_SRV_DIMENSION_BUFFER;
			shaderResourceViewDescription.Buffer.NumElements = (uint32)Description.SizeInBytes / (uint32)Description.StructureByteStride;
			shaderResourceViewDescription.Buffer.FirstElement = 0UL;
			shaderResourceViewDescription.Buffer.Flags = .D3D12_BUFFER_SRV_FLAG_NONE;
			shaderResourceViewDescription.Buffer.StructureByteStride = (uint32)Description.StructureByteStride;
			D3D12_SHADER_RESOURCE_VIEW_DESC  description = shaderResourceViewDescription;
			DX12GraphicsContext obj = Context as DX12GraphicsContext;
			srv = obj.ShaderResourceViewAllocator.Allocate();
			obj.DXDevice.CreateShaderResourceView(NativeBuffer, &description, srv);
		}
		return srv;
	}

	private D3D12_CPU_DESCRIPTOR_HANDLE GetUnorderedAccessView()
	{
		D3D12_CPU_DESCRIPTOR_HANDLE uav = default(D3D12_CPU_DESCRIPTOR_HANDLE);
		if ((Description.Flags & BufferFlags.UnorderedAccess) != 0)
		{
			D3D12_UNORDERED_ACCESS_VIEW_DESC  unorderedAccessViewDescription = default(D3D12_UNORDERED_ACCESS_VIEW_DESC );
			unorderedAccessViewDescription.Format = .DXGI_FORMAT_UNKNOWN;
			unorderedAccessViewDescription.ViewDimension = .D3D12_UAV_DIMENSION_BUFFER;
			unorderedAccessViewDescription.Buffer.NumElements = (uint32)Description.SizeInBytes / (uint32)Description.StructureByteStride;
			unorderedAccessViewDescription.Buffer.FirstElement = 0UL;
			unorderedAccessViewDescription.Buffer.Flags = .D3D12_BUFFER_UAV_FLAG_NONE;
			unorderedAccessViewDescription.Buffer.StructureByteStride = (uint32)Description.StructureByteStride;
			unorderedAccessViewDescription.Buffer.CounterOffsetInBytes = 0UL;
			D3D12_UNORDERED_ACCESS_VIEW_DESC  description = unorderedAccessViewDescription;
			DX12GraphicsContext obj = Context as DX12GraphicsContext;
			uav = obj.ShaderResourceViewAllocator.Allocate();
			obj.DXDevice.CreateUnorderedAccessView(NativeBuffer, null, &description, uav);
		}
		return uav;
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	private void Dispose(bool disposing)
	{
		if (disposed)
		{
			return;
		}
		if (disposing)
		{
			DX12GraphicsContext nativeContext = Context as DX12GraphicsContext;
			if (shaderResourceView.HasValue)
			{
				nativeContext.ShaderResourceViewAllocator.Free(shaderResourceView.Value);
			}
			if (unorderedAccessView.HasValue)
			{
				nativeContext.ShaderResourceViewAllocator.Free(unorderedAccessView.Value);
			}
			if (constantBufferView.HasValue)
			{
				nativeContext.ShaderResourceViewAllocator.Free(constantBufferView.Value);
			}
			ID3D12Resource* nativeBuffer = NativeBuffer;
			if (nativeBuffer != null)
			{
				nativeBuffer.Release();
			}
		}
		disposed = true;
	}
}
