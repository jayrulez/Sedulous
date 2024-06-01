using System;
namespace SDL2Native;

[CRepr]
struct SDL_Color
{
	public uint8 r;
	public uint8 g;
	public uint8 b;
	public uint8 a;
}