using System;
using System.Threading;
using Sedulous.RHI;
using Win32;
using Win32.Graphics.Direct3D;
using Win32.Graphics.Direct3D12;
using Win32.Graphics.Dxgi;
using Win32.Foundation;

namespace Sedulous.RHI.DirectX12;

using internal Sedulous.RHI.DirectX12;

/// <summary>
/// Manages all graphical functionality.
/// </summary>
public class DX12GraphicsContext : GraphicsContext
{
	/// <summary>
	/// Native DX const used to set 4 components.
	/// </summary>
	public static readonly uint32 DefaultShader4ComponentMapping = 5768;

	/// <summary>
	/// The default heap size for constant buffer views.
	/// </summary>
	public static readonly uint32 GPU_RESOURCE_HEAP_CBV_COUNT = 12;

	/// <summary>
	/// The default heap size for shader resource views.
	/// </summary>
	public static readonly uint32 GPU_RESOURCE_HEAP_SRV_COUNT = 64;

	/// <summary>
	/// The default heap size for unordered access views.
	/// </summary>
	public static readonly uint32 GPU_RESOURCE_HEAP_UAV_COUNT = 8;

	/// <summary>
	/// The default heap size for samplers.
	/// </summary>
	public static readonly uint32 GPU_SAMPLER_HEAP_COUNT = 16;

	/// <summary>
	/// The DirectX device.
	/// </summary>
	public ID3D12Device* DXDevice;

	/// <summary>
	/// The DXGI factory.
	/// </summary>
	public IDXGIFactory4* DXFactory;

	private DX12Capabilities capabilities;

	internal DX12DescriptorAllocator RenderTargetViewAllocator;

	internal DX12DescriptorAllocator DepthStencilViewAllocator;

	internal DX12DescriptorAllocator ShaderResourceViewAllocator;

	internal DX12DescriptorAllocator SamplerAllocator;

	internal D3D12_CPU_DESCRIPTOR_HANDLE[] NullDescriptors;

	internal DX12CommandQueue DefaultGraphicsQueue;

	internal ID3D12RootSignature* DefaultGraphicsSignature;

	internal ID3D12RootSignature* DefaultComputeSignature;

	internal ID3D12RootSignature* DefaultRaytracingGlobalRootSignature;

	internal DX12UploadBuffer BufferUploader;

	internal DX12UploadBuffer TextureUploader;

	internal ID3D12CommandSignature* DispatchIndirectCommandSignature;

	internal ID3D12CommandSignature* DrawInstancedIndirectCommandSignature;

	internal ID3D12CommandSignature* DrawIndexedInstancedIndirectCommandSignature;

	internal ID3D12CommandQueue* CopyCommandQueue;

	internal ID3D12CommandAllocator* CopyCommandAlloc;

	internal ID3D12GraphicsCommandList* CopyCommandList;

	internal ID3D12Fence* CopyFence;

	internal AutoResetEvent CopyFenceEvent;

	internal uint64 CopyFenceValue;

	private bool disposed;

	/// <inheritdoc />
	public override GraphicsBackend BackendType => GraphicsBackend.DirectX12;

	/// <inheritdoc />
	public override GraphicsContextCapabilities Capabilities => capabilities;

	/// <inheritdoc />
	public override void* NativeDevicePointer
	{
		get
		{
			if (DXDevice != null)
			{
				return DXDevice;
			}
			return null;
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12GraphicsContext" /> class.
	/// </summary>
	public this()
	{
		base.Factory = new DX12ResourceFactory(this);
	}

	/// <inheritdoc />
	public override void CreateDeviceInternal()
	{
		DXDevice?.Release();
		if (base.IsValidationLayerEnabled)
		{
			ID3D12Debug* pDx12Debug = null;
			HRESULT result = D3D12GetDebugInterface(ID3D12Debug.IID, (void**)&pDx12Debug);
			if(SUCCEEDED(result))
			{
				pDx12Debug.EnableDebugLayer();
			}
		}
		CreateDXGIFactory1(IDXGIFactory4.IID, (void**)&DXFactory);
		ID3D12Device5* device5 = null;
		HRESULT result = D3D12CreateDevice(null, .D3D_FEATURE_LEVEL_12_1, ID3D12Device5.IID, (void**)&device5);
		if (SUCCEEDED(result))
		{
			DXDevice = device5;
		}
		else
		{
			ID3D12Device* device1 = null;
			D3D12CreateDevice(null, .D3D_FEATURE_LEVEL_12_0, ID3D12Device.IID, (void**)&device1);
			DXDevice = device1;
		}
		capabilities = new DX12Capabilities(this);
		if (base.IsValidationLayerEnabled)
		{
			ID3D12DebugDevice* debugDevice = DXDevice.QueryInterface<ID3D12DebugDevice>();
			if (debugDevice != null)
			{
				ID3D12InfoQueue* infoQueue = debugDevice.QueryInterface<ID3D12InfoQueue>();
				if (infoQueue != null)
				{
					D3D12_MESSAGE_ID[?] disabledMessages = .(
							.D3D12_MESSAGE_ID_CLEARDEPTHSTENCILVIEW_MISMATCHINGCLEARVALUE,
							.D3D12_MESSAGE_ID_CLEARRENDERTARGETVIEW_MISMATCHINGCLEARVALUE,
							.D3D12_MESSAGE_ID_INVALID_DESCRIPTOR_HANDLE,
							.D3D12_MESSAGE_ID_MAP_INVALID_NULLRANGE,
							.D3D12_MESSAGE_ID_UNMAP_INVALID_NULLRANGE 
						);
					D3D12_INFO_QUEUE_FILTER filter = D3D12_INFO_QUEUE_FILTER  ()
					{
						DenyList = .()
						{
							pIDList  = &disabledMessages,
							NumIDs = (uint32)disabledMessages.Count
						},
						AllowList = .()
					};
					infoQueue.AddStorageFilterEntries(&filter);
				}
				infoQueue.Release();
			}
			debugDevice.Release();
		}
		RenderTargetViewAllocator = new DX12DescriptorAllocator(this, D3D12_DESCRIPTOR_HEAP_TYPE.D3D12_DESCRIPTOR_HEAP_TYPE_RTV, 128);
		DepthStencilViewAllocator = new DX12DescriptorAllocator(this, D3D12_DESCRIPTOR_HEAP_TYPE.D3D12_DESCRIPTOR_HEAP_TYPE_DSV, 32);
		ShaderResourceViewAllocator = new DX12DescriptorAllocator(this, D3D12_DESCRIPTOR_HEAP_TYPE.D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV, 4096);
		SamplerAllocator = new DX12DescriptorAllocator(this, D3D12_DESCRIPTOR_HEAP_TYPE.D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER, 32);

		D3D12_SAMPLER_DESC   sampler_description = default(D3D12_SAMPLER_DESC  );
		sampler_description.AddressU = .D3D12_TEXTURE_ADDRESS_MODE_CLAMP;
		sampler_description.AddressV = .D3D12_TEXTURE_ADDRESS_MODE_CLAMP;
		sampler_description.AddressW = .D3D12_TEXTURE_ADDRESS_MODE_CLAMP;
		sampler_description.ComparisonFunc = .D3D12_COMPARISON_FUNC_NEVER;
		sampler_description.Filter = .D3D12_FILTER_MIN_MAG_MIP_LINEAR;
		D3D12_CPU_DESCRIPTOR_HANDLE nullSampler = SamplerAllocator.Allocate();
		DXDevice.CreateSampler(&sampler_description, nullSampler);

		D3D12_CONSTANT_BUFFER_VIEW_DESC cbv_description = default(D3D12_CONSTANT_BUFFER_VIEW_DESC);
		D3D12_CPU_DESCRIPTOR_HANDLE nullCBV = ShaderResourceViewAllocator.Allocate();
		DXDevice.CreateConstantBufferView(&cbv_description, nullCBV);

		D3D12_SHADER_RESOURCE_VIEW_DESC src_description = default(D3D12_SHADER_RESOURCE_VIEW_DESC);
		src_description.Shader4ComponentMapping = DefaultShader4ComponentMapping;
		src_description.Format = .DXGI_FORMAT_R32_UINT;
		src_description.ViewDimension = .D3D12_SRV_DIMENSION_BUFFER;
		D3D12_CPU_DESCRIPTOR_HANDLE nullSRV = ShaderResourceViewAllocator.Allocate();
		DXDevice.CreateShaderResourceView(null, &src_description, nullSRV);

		D3D12_UNORDERED_ACCESS_VIEW_DESC uav_description = default(D3D12_UNORDERED_ACCESS_VIEW_DESC);
		uav_description.Format = .DXGI_FORMAT_R32_UINT;
		uav_description.ViewDimension = .D3D12_UAV_DIMENSION_BUFFER;
		D3D12_CPU_DESCRIPTOR_HANDLE nullUAV = ShaderResourceViewAllocator.Allocate();
		DXDevice.CreateUnorderedAccessView(null, null, &uav_description, nullUAV);

		NullDescriptors = new .[4] ( nullSampler, nullCBV, nullSRV, nullUAV );

		D3D12_DESCRIPTOR_RANGE samplerRange = .(.D3D12_DESCRIPTOR_RANGE_TYPE_SAMPLER, GPU_SAMPLER_HEAP_COUNT, 0);
		D3D12_DESCRIPTOR_RANGE[] descriptorRanges = scope D3D12_DESCRIPTOR_RANGE[3]
		(
			D3D12_DESCRIPTOR_RANGE(.D3D12_DESCRIPTOR_RANGE_TYPE_CBV, GPU_RESOURCE_HEAP_CBV_COUNT, 0),
			D3D12_DESCRIPTOR_RANGE(.D3D12_DESCRIPTOR_RANGE_TYPE_SRV, GPU_RESOURCE_HEAP_SRV_COUNT, 0, 0, GPU_RESOURCE_HEAP_CBV_COUNT),
			D3D12_DESCRIPTOR_RANGE(.D3D12_DESCRIPTOR_RANGE_TYPE_UAV, GPU_RESOURCE_HEAP_UAV_COUNT, 0, 0, GPU_RESOURCE_HEAP_CBV_COUNT + GPU_RESOURCE_HEAP_SRV_COUNT)
		);

		D3D12_ROOT_PARAMETER[] graphicsParameters = scope D3D12_ROOT_PARAMETER[10]
		(
			D3D12_ROOT_PARAMETER(.(params descriptorRanges), .D3D12_SHADER_VISIBILITY_VERTEX),
			D3D12_ROOT_PARAMETER(.(samplerRange), .D3D12_SHADER_VISIBILITY_VERTEX),
			D3D12_ROOT_PARAMETER(.(params descriptorRanges), .D3D12_SHADER_VISIBILITY_HULL),
			D3D12_ROOT_PARAMETER(.(samplerRange), .D3D12_SHADER_VISIBILITY_HULL),
			D3D12_ROOT_PARAMETER(.(params descriptorRanges), .D3D12_SHADER_VISIBILITY_DOMAIN),
			D3D12_ROOT_PARAMETER(.(samplerRange), .D3D12_SHADER_VISIBILITY_DOMAIN),
			D3D12_ROOT_PARAMETER(.(params descriptorRanges), .D3D12_SHADER_VISIBILITY_GEOMETRY),
			D3D12_ROOT_PARAMETER(.(samplerRange), .D3D12_SHADER_VISIBILITY_GEOMETRY),
			D3D12_ROOT_PARAMETER(.(params descriptorRanges), .D3D12_SHADER_VISIBILITY_PIXEL),
			D3D12_ROOT_PARAMETER(.(samplerRange), .D3D12_SHADER_VISIBILITY_PIXEL)
		);

		ID3DBlob* pBlob = null;
		ID3DBlob* pErrorBlob = null;
		HRESULT hr = S_OK;

		D3D12_ROOT_SIGNATURE_DESC graphicsRootSignatureDescription = D3D12_ROOT_SIGNATURE_DESC(.D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT, graphicsParameters);
		hr = D3D12SerializeRootSignature(&graphicsRootSignatureDescription, D3D_ROOT_SIGNATURE_VERSION.D3D_ROOT_SIGNATURE_VERSION_1, &pBlob, &pErrorBlob);
		DXDevice.CreateRootSignature(0, pBlob.GetBufferPointer(), pBlob.GetBufferSize(), ID3D12RootSignature.IID, (void**)&DefaultGraphicsSignature);

		D3D12_ROOT_PARAMETER[] computeParameters = scope D3D12_ROOT_PARAMETER[2]
		(
			D3D12_ROOT_PARAMETER(.(params descriptorRanges), .D3D12_SHADER_VISIBILITY_ALL),
			D3D12_ROOT_PARAMETER(.(samplerRange), .D3D12_SHADER_VISIBILITY_ALL)
		);

		D3D12_ROOT_SIGNATURE_DESC computeRootSignatureDescription = D3D12_ROOT_SIGNATURE_DESC(.D3D12_ROOT_SIGNATURE_FLAG_NONE, computeParameters);
		hr = D3D12SerializeRootSignature(&computeRootSignatureDescription, D3D_ROOT_SIGNATURE_VERSION.D3D_ROOT_SIGNATURE_VERSION_1, &pBlob, &pErrorBlob);
		DXDevice.CreateRootSignature(0, pBlob.GetBufferPointer(), pBlob.GetBufferSize(), ID3D12RootSignature.IID, (void**)&DefaultComputeSignature);

		D3D12_ROOT_PARAMETER[] raytracingParameters = scope D3D12_ROOT_PARAMETER[2]
		(
			D3D12_ROOT_PARAMETER(.(params descriptorRanges), .D3D12_SHADER_VISIBILITY_ALL),
			D3D12_ROOT_PARAMETER(.(samplerRange), .D3D12_SHADER_VISIBILITY_ALL)
		);

		D3D12_ROOT_SIGNATURE_DESC raytracingRootSignatureDescription = D3D12_ROOT_SIGNATURE_DESC(.D3D12_ROOT_SIGNATURE_FLAG_NONE, raytracingParameters);
		hr = D3D12SerializeRootSignature(&raytracingRootSignatureDescription, D3D_ROOT_SIGNATURE_VERSION.D3D_ROOT_SIGNATURE_VERSION_1, &pBlob, &pErrorBlob);
		DXDevice.CreateRootSignature(0, pBlob.GetBufferPointer(), pBlob.GetBufferSize(), ID3D12RootSignature.IID, (void**)&DefaultRaytracingGlobalRootSignature);

		DefaultGraphicsQueue = new DX12CommandQueue(this, CommandQueueType.Graphics);
		DefaultGraphicsQueue.CommandQueue.GetTimestampFrequency(&TimestampFrequency);

		D3D12_COMMAND_QUEUE_DESC commandQueueDescription = default(D3D12_COMMAND_QUEUE_DESC);
		commandQueueDescription.Flags = .D3D12_COMMAND_QUEUE_FLAG_NONE;
		commandQueueDescription.NodeMask = 0;
		commandQueueDescription.Priority = 0;
		commandQueueDescription.Type = .D3D12_COMMAND_LIST_TYPE_COPY;
		D3D12_COMMAND_QUEUE_DESC copyQueueDescription = commandQueueDescription;
		DXDevice.CreateCommandQueue(&copyQueueDescription, ID3D12CommandQueue.IID, (void**)&CopyCommandQueue);
		DXDevice.CreateCommandAllocator(.D3D12_COMMAND_LIST_TYPE_COPY, ID3D12CommandAllocator.IID, (void**)&CopyCommandAlloc);
		DXDevice.CreateCommandList(0, .D3D12_COMMAND_LIST_TYPE_COPY, CopyCommandAlloc, null, ID3D12GraphicsCommandList.IID, (void**)&CopyCommandList);

		CopyFenceValue = 0UL;
		CopyFenceEvent = new AutoResetEvent(initialState: false);
		DXDevice.CreateFence(CopyFenceValue, .D3D12_FENCE_FLAG_NONE, ID3D12Fence.IID, (void**)&CopyFence);

		BufferUploader = new DX12UploadBuffer(this, base.DefaultBufferUploaderSize, 0);
		TextureUploader = new DX12UploadBuffer(this, base.DefaultTextureUploaderSize);

		D3D12_COMMAND_SIGNATURE_DESC cmd_description = D3D12_COMMAND_SIGNATURE_DESC();

		D3D12_INDIRECT_ARGUMENT_DESC indirectArgumentDescription = default(D3D12_INDIRECT_ARGUMENT_DESC);
		indirectArgumentDescription.Type = .D3D12_INDIRECT_ARGUMENT_TYPE_DISPATCH;
		D3D12_INDIRECT_ARGUMENT_DESC dispatchArgs = indirectArgumentDescription;

		indirectArgumentDescription = default(D3D12_INDIRECT_ARGUMENT_DESC);
		indirectArgumentDescription.Type = .D3D12_INDIRECT_ARGUMENT_TYPE_DRAW;
		D3D12_INDIRECT_ARGUMENT_DESC drawInstancedArgs = indirectArgumentDescription;

		indirectArgumentDescription = default(D3D12_INDIRECT_ARGUMENT_DESC);
		indirectArgumentDescription.Type = .D3D12_INDIRECT_ARGUMENT_TYPE_DRAW_INDEXED;
		D3D12_INDIRECT_ARGUMENT_DESC drawIndexedInstancedArgs = indirectArgumentDescription;

		cmd_description.ByteStride = sizeof(IndirectDispatchArgs);
		cmd_description.pArgumentDescs = scope D3D12_INDIRECT_ARGUMENT_DESC[1]*(dispatchArgs);
		cmd_description.NumArgumentDescs  = 1;
		DXDevice.CreateCommandSignature(&cmd_description, null, ID3D12CommandSignature.IID, (void**)&DispatchIndirectCommandSignature);

		cmd_description.ByteStride = sizeof(IndirectDrawArgsInstanced);
		cmd_description.pArgumentDescs = scope D3D12_INDIRECT_ARGUMENT_DESC[1]* ( drawInstancedArgs );
		cmd_description.NumArgumentDescs  = 1;
		DXDevice.CreateCommandSignature(&cmd_description, null, ID3D12CommandSignature.IID, (void**)&DrawInstancedIndirectCommandSignature);

		cmd_description.ByteStride = sizeof(IndirectDrawArgsIndexedInstanced);
		cmd_description.pArgumentDescs = scope D3D12_INDIRECT_ARGUMENT_DESC[1]* ( drawIndexedInstancedArgs );
		cmd_description.NumArgumentDescs  = 1;
		DXDevice.CreateCommandSignature(&cmd_description, null, ID3D12CommandSignature.IID, (void**)&DrawIndexedInstancedIndirectCommandSignature);
	}

	/// <inheritdoc />
	public override SwapChain CreateSwapChain(Sedulous.RHI.SwapChainDescription description)
	{
		if (DXDevice == null)
		{
			base.ValidationLayer?.Notify("DX12", "You need to call CreateDevice() before to create the SwapChain");
		}
		return new DX12SwapChain(this, description);
	}

	/// <inheritdoc />
	protected override void InternalUpdateBufferData(Sedulous.RHI.Buffer buffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0)
	{
		(buffer as DX12Buffer).SetData(CopyCommandList, source, sourceSizeInBytes, destinationOffsetInBytes);
	}

	/// <inheritdoc />
	public override void UpdateTextureData(Texture texture, void* source, uint32 sourceSizeInBytes, uint32 subResource = 0)
	{
		(texture as DX12Texture).SetData(CopyCommandList, source, sourceSizeInBytes, subResource);
	}

	/// <inheritdoc />
	public override MappedResource MapMemory(GraphicsResource resource, MapMode mode, uint32 subResource = 0)
	{
		if (resource is DX12Buffer)
		{
			DX12Buffer buffer = resource as DX12Buffer;
			D3D12_RANGE range2 = default(D3D12_RANGE);
			range2.Begin =uint(0);
			range2.End = uint((int64)buffer.Description.SizeInBytes);
			D3D12_RANGE range = range2;
			void* dataPointer = null;
			buffer.NativeBuffer.Map(0, &range, &dataPointer);
			return MappedResource(resource, mode, dataPointer, buffer.Description.SizeInBytes);
		}
		if (resource is DX12Texture)
		{
			DX12Texture texture = resource as DX12Texture;
			SubResourceInfo subResourceInfo = Helpers.GetSubResourceInfo(texture.Description, subResource);
			void* dataPointer = null;
			if (texture.Description.Usage == ResourceUsage.Staging)
			{
				D3D12_RANGE range2 = default(D3D12_RANGE);
				range2.Begin = uint((int64)subResourceInfo.Offset);
				range2.End = uint((int64)subResourceInfo.SizeInBytes);
				D3D12_RANGE range = range2;
				texture.NativeBuffer.Map(0, &range, &dataPointer);
			}
			else
			{
				D3D12_RANGE range2 = default(D3D12_RANGE);
				range2.Begin = uint(0);
				range2.End = uint((int64)subResourceInfo.SizeInBytes);
				D3D12_RANGE range = range2;
				texture.NativeTexture.Map((uint32)subResource, &range, &dataPointer);
			}
			return MappedResource(resource, mode, dataPointer, subResourceInfo.SizeInBytes, subResource, subResourceInfo.RowPitch, subResourceInfo.SlicePitch);
		}
		base.ValidationLayer?.Notify("DX12", "This operation is only supported to buffers and textures.");
		return default(MappedResource);
	}

	/// <inheritdoc />
	public override void UnmapMemory(GraphicsResource resource, uint32 subResource = 0)
	{
		if (resource is DX12Buffer)
		{
			(resource as DX12Buffer).NativeBuffer.Unmap(0, null);
		}
		else if (resource is DX12Texture)
		{
			DX12Texture texture = resource as DX12Texture;
			Helpers.GetSubResourceInfo(texture.Description, subResource);
			if (texture.Description.Usage == ResourceUsage.Staging)
			{
				texture.NativeBuffer.Unmap(0, null);
			}
			else
			{
				texture.NativeTexture.Unmap(subResource, null);
			}
		}
		else
		{
			base.ValidationLayer?.Notify("DX12", "This operation is only supported to buffers and textures.");
		}
	}

	/// <inheritdoc />
	public override CompilationResult ShaderCompile(String shaderSource, String entryPoint, ShaderStages stage, CompilerParameters parameters)
	{
		return DX12Shader.ShaderCompile(this, shaderSource, entryPoint, stage, parameters);
	}

	/// <inheritdoc />
	public override bool GenerateTextureMipmapping(Texture texture)
	{
		return false;
	}

	/// <inheritdoc />
	public override void SyncUpcopyQueue()
	{
		CopyCommandList.Close();
		CopyCommandQueue.ExecuteCommandLists(1, (ID3D12CommandList**)&CopyCommandList);
		CopyCommandQueue.Signal(CopyFence, CopyFenceValue);
		if (CopyFence.GetCompletedValue() < CopyFenceValue)
		{
			CopyFence.SetEventOnCompletion(CopyFenceValue, CopyFenceEvent.Handle);
			CopyFenceEvent.WaitOne();
		}
		CopyFenceValue++;
		CopyCommandAlloc.Reset();
		CopyCommandList.Reset(CopyCommandAlloc, null);
		BufferUploader.Clear();
		TextureUploader.Clear();
	}

	/// <inheritdoc />
	protected override void Dispose(bool disposing)
	{
		if (!disposed && disposing)
		{
			DXDevice?.Release();
			DXFactory?.Release();
			RenderTargetViewAllocator?.Dispose();
			DepthStencilViewAllocator?.Dispose();
			ShaderResourceViewAllocator?.Dispose();
			SamplerAllocator?.Dispose();
			DefaultGraphicsQueue?.Dispose();
			CopyCommandQueue?.Release();
			CopyCommandAlloc?.Release();
			CopyCommandList?.Release();
			BufferUploader?.Dispose();
			TextureUploader?.Dispose();
			disposed = true;
		}
	}
}
