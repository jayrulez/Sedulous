using System.Collections;
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

namespace Sedulous.Renderer;


class DefaultResource
{
	public this(Device device)
	{
		uint32 bufferSize = 64;
		List<uint8> buffer = scope .() { Count = bufferSize }..SetAll(255);
		/*readonly*/ uint8* bufferData = buffer.Ptr;
		if (device.getCapabilities().maxTextureSize >= 2)
		{
			_texture2D = device.createTexture(TextureInfo()
				{
					type = TextureType.TEX2D,
					usage = TextureUsageBit.STORAGE | TextureUsageBit.SAMPLED | TextureUsageBit.TRANSFER_DST,
					format = Format.RGBA8,
					width = 2,
					height = 2,
					flags = TextureFlagBit.NONE
				});
			BufferTextureCopy region = .()
				{
					buffOffset = 0,
					buffStride = 0,
					buffTexHeight = 0,
					texOffset = .() { x = 0, y = 0, z = 0 },
					texExtent = .() { width = 2, height = 2, depth = 1 },
					texSubres = .() { mipLevel = 0, baseArrayLayer = 0, layerCount = 1 }
				};
			device.copyBuffersToTexture(&bufferData, _texture2D, &region, 1);
		}
		if (device.getCapabilities().maxTextureSize >= 2)
		{
			_textureCube = device.createTexture(TextureInfo()
				{
					type = TextureType.CUBE,
					usage = TextureUsageBit.STORAGE | TextureUsageBit.SAMPLED | TextureUsageBit.TRANSFER_DST,
					format = Format.RGBA8,
					width = 2,
					height = 2,
					flags = TextureFlagBit.NONE,
					layerCount = 6
				});
			BufferTextureCopy region = .()
				{
					buffOffset = 0,
					buffStride = 0,
					buffTexHeight = 0,
					texOffset = .() { x = 0, y = 0, z = 0 },
					texExtent = .() { width = 2, height = 2, depth = 1 },
					texSubres = .() { mipLevel = 0, baseArrayLayer = 0, layerCount = 1 }
				};
			device.copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
			region.texSubres.baseArrayLayer = 1;
			device.copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
			region.texSubres.baseArrayLayer = 2;
			device.copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
			region.texSubres.baseArrayLayer = 3;
			device.copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
			region.texSubres.baseArrayLayer = 4;
			device.copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
			region.texSubres.baseArrayLayer = 5;
			device.copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
		}

		if (device.getCapabilities().max3DTextureSize >= 2)
		{
			_texture3D = device.createTexture(TextureInfo()
				{
					type = TextureType.TEX3D,
					usage = TextureUsageBit.STORAGE | TextureUsageBit.SAMPLED | TextureUsageBit.TRANSFER_DST,
					format = Format.RGBA8,
					width = 2,
					height = 2,
					flags = TextureFlagBit.NONE,
					layerCount = 1,
					levelCount = 1,
					samples = SampleCount.X1,
					depth = 2
				});
			BufferTextureCopy region = .()
				{
					buffOffset = 0,
					buffStride = 0,
					buffTexHeight = 0,
					texOffset = .() { x = 0, y = 0, z = 0 },
					texExtent = .() { width = 2, height = 2, depth = 2 },
					texSubres = .() { mipLevel = 0, baseArrayLayer = 0, layerCount = 1 }
				};
			device.copyBuffersToTexture(&bufferData, _texture3D, &region, 1);
		}
		if (device.getCapabilities().maxArrayTextureLayers >= 2)
		{
			_texture2DArray = device.createTexture(TextureInfo()
				{
					type = TextureType.TEX2D_ARRAY,
					usage = TextureUsageBit.STORAGE | TextureUsageBit.SAMPLED | TextureUsageBit.TRANSFER_DST,
					format = Format.RGBA8,
					width = 2,
					height = 2,
					flags = TextureFlagBit.NONE,
					layerCount = 2
				});
			BufferTextureCopy region = .()
				{
					buffOffset = 0,
					buffStride = 0,
					buffTexHeight = 0,
					texOffset = .() { x = 0, y = 0, z = 0 },
					texExtent = .() { width = 2, height = 2, depth = 1 },
					texSubres = .() { mipLevel = 0, baseArrayLayer = 0, layerCount = 1 }
				};
			device.copyBuffersToTexture(&bufferData, _texture2DArray, &region, 1);
			region.texSubres.baseArrayLayer = 1;
			device.copyBuffersToTexture(&bufferData, _texture2DArray, &region, 1);
		}
		{
			BufferInfo bufferInfo = .();
			bufferInfo.usage = BufferUsageBit.STORAGE | BufferUsageBit.TRANSFER_DST | BufferUsageBit.TRANSFER_SRC | BufferUsageBit.VERTEX | BufferUsageBit.INDIRECT;
			bufferInfo.memUsage = MemoryUsageBit.DEVICE | MemoryUsageBit.HOST;
			bufferInfo.size = 5 * sizeof(uint32); // for indirect command buffer
			bufferInfo.stride = bufferInfo.size;
			_buffer = device.createBuffer(bufferInfo);
		}
	}

	public Texture getTexture(TextureType type)
	{
		switch (type) {
		case TextureType.TEX2D:
			return _texture2D;
		case TextureType.CUBE:
			return _textureCube;
		case TextureType.TEX3D:
			return _texture3D;
		case TextureType.TEX2D_ARRAY:
			return _texture2DArray;
		default:
			Runtime.FatalError();
			//return null;
		}
	}
	public Buffer getBuffer()
	{
		return _buffer;
	}

	private Texture _texture2D;
	private Texture _texture2DArray;
	private Texture _textureCube;
	private Texture _texture3D;
	private Buffer _buffer;
}
