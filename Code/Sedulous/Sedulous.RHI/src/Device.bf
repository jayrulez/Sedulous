using System;
namespace Sedulous.RHI;

abstract class Device
{
	public abstract Result<void> CreateBuffer(in BufferDescription description, out Buffer buffer);
	public abstract void DestroyBuffer(ref Buffer buffer);
	
	public abstract Result<void> CreateTexture(in TextureDescription description, out Texture texture);
	public abstract void DestroyTexture(ref Texture texture);
	
	public abstract Result<void> CreateSamplerState(in SamplerStateDescription description, out SamplerState samplerState);
	public abstract void DestroySamplerState(ref SamplerState samplerState);
}