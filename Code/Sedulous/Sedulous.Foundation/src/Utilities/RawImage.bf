namespace Sedulous.Foundation.Utilities;

struct RawImage
{
	public readonly int Width { get; private set mut; }
	public readonly int Height { get; private set mut; }
	public readonly uint8* Pixels { get; private set mut; }

	public this(int width, int height, uint8* pixels)
	{
		Width = width;
		Height = height;
		Pixels = pixels;
	}
}