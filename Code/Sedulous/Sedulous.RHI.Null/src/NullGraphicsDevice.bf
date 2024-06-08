namespace Sedulous.RHI.Null;

class NullGraphicsDevice : GraphicsDevice
{
	public override System.Result<void> CreateBuffer(in BufferDescription description, out Buffer buffer)
	{
		buffer = ?;
		return default;
	}

	public override void DestroyBuffer(ref Buffer buffer)
	{

	}

	public override System.Result<void> CreateTexture(in TextureDescription description, out Texture texture)
	{
		texture = ?;
		return default;
	}

	public override void DestroyTexture(ref Texture texture)
	{

	}

	public override System.Result<void> CreateSamplerState(in SamplerStateDescription description, out SamplerState samplerState)
	{
		samplerState = ?;
		return default;
	}

	public override void DestroySamplerState(ref SamplerState samplerState)
	{

	}
}