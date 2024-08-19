using System;
/****************************************************************************
 Copyright (c) 2019-2023 Xiamen Yaji Software Co., Ltd.

 http://www.cocos.com

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
****************************************************************************/

namespace cc
{
	namespace gfx
	{
		abstract class Buffer : GFXObject
		{
			public this() : base(ObjectType.BUFFER)
				{ }

			public static HashType computeHash(in BufferInfo info)
			{
				return info.GetHashCode();
			}

			public void initialize(in BufferInfo info)
			{
				_usage = info.usage;
				_memUsage = info.memUsage;
				_size = info.size;
				_flags = info.flags;
				_stride = Math.Max(info.stride, 1);
				_count = _size / _stride;

				doInit(info);

				if (info.flags.HasFlag(BufferFlagBit.ENABLE_STAGING_WRITE) && getStagingAddress() == null)
				{
					_data = new uint8[_size];
				}
			}
			public void initialize(in BufferViewInfo info)
			{
				_usage = info.buffer.getUsage();
				_memUsage = info.buffer.getMemUsage();
				_flags = info.buffer.getFlags();
				_offset = info.offset;
				_size = _stride = info.range;
				_count = 1;
				_isBufferView = true;

				doInit(info);
			}
			public void resize(uint32 size)
			{
				if (size != _size)
				{
					uint32 count = size / _stride;
					doResize(size, count);

					_size = size;
					_count = count;
				}
			}
			public void destroy()
			{
				doDestroy();

				_offset = _size = _stride = _count = 0;
			}

			public void write<T>(in T value, uint32 offset) where T : ValueType
			{
				var value;
				write((uint8*)&value, offset, (uint32)sizeof(T));
			}

			public void write(uint8* value, uint32 offset, uint32 size)
			{
				Runtime.Assert(_flags.HasFlag(BufferFlagBit.ENABLE_STAGING_WRITE));
				uint8* dst = getStagingAddress();
				if (dst == null || offset + size > _size)
				{
					return;
				}
				Internal.MemCpy(dst + offset, value, size);
			}

			public abstract void update(void* buffer, uint32 size);

			[Inline] public void update(void* buffer) { update(buffer, _size); }

			public void update()
			{
				flush(getStagingAddress());
			}

			[Inline] public BufferUsage getUsage() { return _usage; }
			[Inline] public MemoryUsage getMemUsage() { return _memUsage; }
			[Inline] public uint32 getStride() { return _stride; }
			[Inline] public uint32 getCount() { return _count; }
			[Inline] public uint32 getSize() { return _size; }
			[Inline] public BufferFlags getFlags() { return _flags; }
			[Inline] public bool isBufferView() { return _isBufferView; }

			protected abstract  void doInit(in BufferInfo info);
			protected abstract  void doInit(in BufferViewInfo info);
			protected abstract  void doResize(uint32 size, uint32 count);
			protected abstract  void doDestroy();

			protected static uint8* getBufferStagingAddress(Buffer buffer)
			{
				return buffer.getStagingAddress();
			}
			protected static void flushBuffer(Buffer buffer, uint8* data)
			{
				buffer.flush(data);
			}

			protected virtual void flush(uint8* data) { update((void*)data, _size); }
			protected virtual uint8* getStagingAddress() { return _data.Ptr; }

			protected BufferUsage _usage = BufferUsageBit.NONE;
			protected MemoryUsage _memUsage = MemoryUsageBit.NONE;
			protected uint32 _stride = 0;
			protected uint32 _count = 0;
			protected uint32 _size = 0;
			protected uint32 _offset = 0;
			protected BufferFlags _flags = BufferFlagBit.NONE;
			protected bool _isBufferView = false;
			protected uint8[3] _rsv = .();
			protected uint8[] _data;
		}
	} // namespace gfx
} // namespace cc
