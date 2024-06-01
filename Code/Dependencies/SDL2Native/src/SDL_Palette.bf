using System;
namespace SDL2Native;

[CRepr]
struct SDL_Palette
{
	//the number of colors in the palette
	public int32 ncolors;
	//an array of SDL_Color structures representing the palette
	public SDL_Color* colors;
	//incrementally tracks changes to the palette (internal use)
	public uint32 version;

	// reference count (internal use)
	public int32 refcount;
}