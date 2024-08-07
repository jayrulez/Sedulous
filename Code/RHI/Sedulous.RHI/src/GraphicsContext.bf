using System;
using System.Collections;

namespace Sedulous.RHI;

using internal Sedulous.RHI;

/// <summary>
/// Performs primitive-based rendering, creates resources, handles system-level variables, adjusts gamma ramp levels, and creates shaders.
/// </summary>
public abstract class GraphicsContext : IDisposable, IGetNativePointers
{
	/// <summary>
	/// the rate at which the GPU timestamp counter increments.
	/// </summary>
	public uint64 TimestampFrequency;

	private uint64 defaultTextureUploaderSize = 134217728uL;

	private uint64 defaultBufferUploaderSize = 33554432uL;

	private const String DevicePointerKey = "Device";

	/// <summary>
	/// Gets the default Sampler state used when there is a missing sampler in a resource set.
	/// </summary>
	public SamplerState DefaultSampler { get; private set; }

	/// <summary>
	/// Gets the graphics validation layer pointer.
	/// </summary>
	public ValidationLayer ValidationLayer { get; private set; }

	/// <summary>
	/// Gets a value indicating whether validationlayer is enable or disable.
	/// </summary>
	public bool IsValidationLayerEnabled => ValidationLayer != null;

	/// <summary>
	/// Gets or sets the resource factory.
	/// </summary>
	public ResourceFactory Factory { get; protected set; }

	/// <summary>
	/// Gets the native device pointer.
	/// </summary>
	public abstract void* NativeDevicePointer { get; }

	/// <summary>
	/// Gets the backend type (DirectX, OpenGL ...)
	/// </summary>
	public abstract GraphicsBackend BackendType { get; }

	/// <summary>
	/// Gets the capabilities of this graphics context.
	/// </summary>
	public abstract GraphicsContextCapabilities Capabilities { get; }

	/// <inheritdoc />
	public virtual void GetAvailablePointerKeys(List<String> pointerKeys)
	{
		pointerKeys.Add("Device");
	}

	/// <summary>
	/// Gets or sets a value indicating the size in bytes of the texture uploader.
	/// </summary>
	/// <remarks>
	/// To upload buffers and Texture efficiently to dedicate GPU memory first a big buffer is created on shared GPU memory,
	/// before to use this buffers and texture, a parallel copyqueue execute all the copy command at once.
	/// The initial size of this uploaders is defined by this property, The Default value is (256 * 1024 * 1024).
	/// </remarks>
	public uint64 DefaultTextureUploaderSize
	{
		get
		{
			return defaultTextureUploaderSize;
		}
		set
		{
			defaultTextureUploaderSize = value;
		}
	}

	/// <summary>
	/// Gets or sets a value indicating the size in bytes of the buffer uploader.
	/// </summary>
	/// <remarks>
	/// To upload buffers and Texture efficiently to dedicate GPU memory first a big buffer is created on shared GPU memory,
	/// before to use this buffers and texture, a parallel copyqueue execute all the copy command at once.
	/// The initial size of this uploaders is defined by this property, The Default value is (256 * 1024 * 1024).
	/// </remarks>
	public uint64 DefaultBufferUploaderSize
	{
		get
		{
			return defaultBufferUploaderSize;
		}
		set
		{
			defaultBufferUploaderSize = value;
		}
	}

	/// <summary>
	/// Initialize the graphics context to be used in a compute shader.
	/// </summary>
	/// <param name="validationLayer">Whether the validation layer is active or not.</param>
	public void CreateDevice(ValidationLayer validationLayer = null)
	{
		ValidationLayer = validationLayer;
		CreateDeviceInternal();
		CreateDefaultSampler();
	}

	/// <summary>
	/// Initialize the graphics context to be used in a compute shader.
	/// </summary>
	public abstract void CreateDeviceInternal();

	/// <summary>
	/// Initialize the swapchain.
	/// </summary>
	/// <param name="description">The swapchain descriptor.</param>
	/// <returns>Created Swapchain.</returns>
	public abstract SwapChain CreateSwapChain(SwapChainDescription description);

	/// <summary>
	/// Fill the buffer with a data array.
	/// </summary>
	/// <typeparam name="T">The data type.</typeparam>
	/// <param name="buffer">Buffer instance.</param>
	/// <param name="data">The data array.</param>
	/// <param name="destinationOffsetInBytes">The destination offset.</param>
	public void UpdateBufferData<T>(Buffer buffer, T[] data, uint32 destinationOffsetInBytes = 0) where T : struct
	{
		UpdateBufferData(buffer, data, (data != null) ? ((uint32)data.Count) : 0, destinationOffsetInBytes);
	}

	/// <summary>
	/// Fill the buffer with a data array.
	/// </summary>
	/// <typeparam name="T">The data type.</typeparam>
	/// <param name="buffer">Buffer instance.</param>
	/// <param name="data">The data array.</param>
	/// <param name="count">The number of elements.</param>
	/// <param name="destinationOffsetInBytes">The destination offset.</param>
	public void UpdateBufferData<T>(Buffer buffer, T[] data, uint32 count, uint32 destinationOffsetInBytes = 0) where T : struct
	{
		uint32 dataSizeInBytes = count * (uint32)sizeof(T);
		UpdateBufferData(buffer, data.Ptr, dataSizeInBytes, destinationOffsetInBytes);
	}

	/// <summary>
	/// Fill the buffer with a data array.
	/// </summary>
	/// <typeparam name="T">The data type.</typeparam>
	/// <param name="buffer">Buffer instance.</param>
	/// <param name="data">The data array.</param>
	/// <param name="destinationOffsetInBytes">The destination offset.</param>
	public void UpdateBufferData<T>(Buffer buffer, ref T data, uint32 destinationOffsetInBytes = 0) where T : struct
	{
		uint32 sizeInBytes = (uint32)sizeof(T);
		UpdateBufferData(buffer, &data, sizeInBytes, destinationOffsetInBytes);
	}

	/// <summary>
	/// Fill the buffer from a pointer.
	/// </summary>
	/// <param name="buffer">Buffer instance.</param>
	/// <param name="source">The data pointer.</param>
	/// <param name="sourceSizeInBytes">The size in bytes.</param>
	/// <param name="destinationOffsetInBytes">The offset in bytes.</param>
	public void UpdateBufferData(Buffer buffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0)
	{
		buffer.Touch();
		InternalUpdateBufferData(buffer, source, sourceSizeInBytes, destinationOffsetInBytes);
	}

	/// <summary>
	/// Fill the buffer from a pointer.
	/// </summary>
	/// <param name="buffer">Buffer instance.</param>
	/// <param name="source">The data pointer.</param>
	/// <param name="sourceSizeInBytes">The size in bytes.</param>
	/// <param name="destinationOffsetInBytes">The offset in bytes.</param>
	protected abstract void InternalUpdateBufferData(Buffer buffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0);

	/// <summary>
	/// Fill the buffer with a data array.
	/// </summary>
	/// <typeparam name="T">The data type.</typeparam>
	/// <param name="texture">Texture instance.</param>
	/// <param name="data">The data array.</param>
	/// <param name="destinationOffsetInBytes">The destination offset.</param>
	public void UpdateTextureData<T>(Texture texture, T[] data, uint32 destinationOffsetInBytes = 0) where T : struct
	{
		UpdateTextureData(texture, data, (data != null) ? ((uint32)data.Count) : 0, destinationOffsetInBytes);
	}

	/// <summary>
	/// Fill the buffer with a data array.
	/// </summary>
	/// <typeparam name="T">The data type.</typeparam>
	/// <param name="texture">Texture instance.</param>
	/// <param name="data">The data array.</param>
	/// <param name="count">The number of elements.</param>
	/// <param name="destinationOffsetInBytes">The destination offset.</param>
	public void UpdateTextureData<T>(Texture texture, T[] data, uint32 count, uint32 destinationOffsetInBytes = 0) where T : struct
	{
		uint32 dataSizeInBytes = count * (uint32)sizeof(T);
		UpdateTextureData(texture, data.Ptr, dataSizeInBytes, destinationOffsetInBytes);
	}

	/// <summary>
	/// Fill the buffer with a data array.
	/// </summary>
	/// <typeparam name="T">The data type.</typeparam>
	/// <param name="texture">Texture instance.</param>
	/// <param name="data">The data array.</param>
	/// <param name="destinationOffsetInBytes">The destination offset.</param>
	public void UpdateTextureData<T>(Texture texture, ref T data, uint32 destinationOffsetInBytes = 0) where T : struct
	{
		uint32 sizeInBytes = (uint32)sizeof(T);
		UpdateTextureData(texture, &data, sizeInBytes, destinationOffsetInBytes);
	}

	/// <summary>
	/// Fill the buffer from a pointer.
	/// </summary>
	/// <param name="texture">Texture instance.</param>
	/// <param name="source">The data pointer.</param>
	/// <param name="sourceSizeInBytes">The size in bytes.</param>
	/// <param name="subResource">The subResource index.</param>
	public abstract void UpdateTextureData(Texture texture, void* source, uint32 sourceSizeInBytes, uint32 subResource);

	/// <summary>
	/// Maps a <see cref="T:Sedulous.RHI.Buffer" /> or <see cref="T:Sedulous.RHI.Texture" /> into a CPU-accessible data region.
	/// </summary>
	/// <param name="resource">The graphics resource to map.</param>
	/// <param name="mode">The <see cref="T:Sedulous.RHI.MapMode" /> used to map the resource.</param>
	/// <param name="subResource">The subresource to map. Subresources are indexed first by mip slice and then by array layer. Only for Textures.</param>
	/// <returns>A <see cref="T:Sedulous.RHI.MappedResource" /> structure describing the mapped data region.</returns>
	public abstract MappedResource MapMemory(GraphicsResource resource, MapMode mode, uint32 subResource = 0);

	/// <summary>
	/// Invalidates a previously-mapped data region for the given <see cref="T:Sedulous.RHI.Buffer" /> or <see cref="T:Sedulous.RHI.Texture" />.
	/// </summary>
	/// <param name="resource">The graphics resource to map.</param>
	/// <param name="subResource">The subresource to map. Subresources are indexed first by mip slice and then by array layer. Only for Textures.</param>
	public abstract void UnmapMemory(GraphicsResource resource, uint32 subResource = 0);

	/// <summary>
	/// Converts the shader source into bytecode.
	/// </summary>
	/// <param name="shaderSource">The shader source text.</param>
	/// <param name="entryPoint">The entrypoint function name.</param>
	/// <param name="stage">The shader stage, <see cref="T:Sedulous.RHI.ShaderStages" />.</param>
	/// <returns>The shader bytecodes.</returns>
	public void ShaderCompile(String shaderSource, String entryPoint, ShaderStages stage, ref CompilationResult result)
	{
		ShaderCompile(shaderSource, entryPoint, stage, CompilerParameters.Default, ref result);
	}

	/// <summary>
	/// Converts the shader source into bytecode.
	/// </summary>
	/// <param name="shaderSource">The shader source text.</param>
	/// <param name="entryPoint">The entrypoint function name.</param>
	/// <param name="stage">The shader stage, <see cref="T:Sedulous.RHI.ShaderStages" />.</param>
	/// <param name="parameters">The compiler parameters.</param>
	/// <returns>The shader bytecodes.</returns>
	public abstract void ShaderCompile(String shaderSource, String entryPoint, ShaderStages stage, CompilerParameters parameters, ref CompilationResult result);

	/// <summary>
	/// Generate mipmapping texture levels.
	/// </summary>
	/// <param name="texture">The texture to generate mipmapping.</param>
	/// <returns>True if the mipmapping has been generated.</returns>
	public abstract bool GenerateTextureMipmapping(Texture texture);

	/// <inheritdoc />
	public virtual bool GetNativePointer(String pointerKey, out void* nativePointer)
	{
		if (pointerKey == "Device")
		{
			nativePointer = NativeDevicePointer;
			return true;
		}
		nativePointer = null;
		return false;
	}

	/// <summary>
	/// Sync the current buffer data in the copyQueue. Internal function used in the uploadbuffer strategy.
	/// </summary>
	public virtual void SyncUpcopyQueue()
	{
	}

	/// <summary>
	/// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
	/// </summary>
	public void Dispose()
	{
		DefaultSampler?.Dispose();
		if(DefaultSampler != null)
		{
			delete DefaultSampler;
		}
		Dispose(disposing: true);
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
	/// </summary>
	/// <param name="disposing">
	/// <c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.
	/// </param>
	protected abstract void Dispose(bool disposing);

	/// <summary>
	/// Create the default sampler.
	/// </summary>
	protected virtual void CreateDefaultSampler()
	{
		if (DefaultSampler == null)
		{
			SamplerStateDescription samplerStateDescription = SamplerStateDescription.Default;
			samplerStateDescription.AddressU = TextureAddressMode.Wrap;
			samplerStateDescription.AddressV = TextureAddressMode.Wrap;
			samplerStateDescription.AddressW = TextureAddressMode.Wrap;
			DefaultSampler = Factory.CreateSamplerState(samplerStateDescription);
		}
	}
}
