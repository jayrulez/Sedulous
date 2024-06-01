using System;
namespace SDL2Native;

[CRepr]
struct SDL_RWops
{
	/**
	 *  Return the size of the file in this rwops, or -1 if unknown
	 */
	public function int64(SDL_RWops* context) size;

	/**
	 *  Seek to `offset` relative to `whence`, one of stdio's whence values:
	 *  RW_SEEK_SET, RW_SEEK_CUR, RW_SEEK_END
	 *
	 *  \return the final offset in the data stream, or -1 on error.
	 */
	public function int64(SDL_RWops* context, int64 offset, int whence) seek;

	/**
	 *  Read up to `maxnum` objects each of size `size` from the data
	 *  stream to the area pointed at by `ptr`.
	 *
	 *  \return the number of objects read, or 0 at error or end of file.
	 */
	public function uint(SDL_RWops* context, void* ptr, uint size, uint maxnum) read;

	/**
	 *  Write exactly `num` objects each of size `size` from the area
	 *  pointed at by `ptr` to data stream.
	 *
	 *  \return the number of objects written, or 0 at error or end of file.
	 */
	public function uint(SDL_RWops* context,  void* ptr, uint size, uint num) write;

	/**
	 *  Close and free an allocated SDL_RWops structure.
	 *
	 *  \return 0 if successful or -1 on write error when flushing data.
	 */
	public function int32(SDL_RWops* context) close;

	public uint32 type;
	public void* data1;
	public void* data2;
}