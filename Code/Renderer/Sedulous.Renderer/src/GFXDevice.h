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

namespace cc {
	namespace gfx {


		class DefaultResource {
		public:
			explicit DefaultResource(Device* device) {
				uint32 bufferSize = 64;
				List<uint8> buffer(bufferSize, 255);
				const uint8* bufferData = buffer.data();
				if (device->getCapabilities().maxTextureSize >= 2) {
					_texture2D = device->createTexture({ TextureType::TEX2D, TextureUsageBit::STORAGE | TextureUsageBit::SAMPLED | TextureUsageBit::TRANSFER_DST,
														Format::RGBA8, 2, 2, TextureFlagBit::NONE });
					BufferTextureCopy region = { 0, 0, 0, {0, 0, 0}, {2, 2, 1}, {0, 0, 1} };
					device->copyBuffersToTexture(&bufferData, _texture2D, &region, 1);
				}
				if (device->getCapabilities().maxTextureSize >= 2) {
					_textureCube = device->createTexture({ TextureType::CUBE, TextureUsageBit::STORAGE | TextureUsageBit::SAMPLED | TextureUsageBit::TRANSFER_DST,
														  Format::RGBA8, 2, 2, TextureFlagBit::NONE, 6 });
					BufferTextureCopy region = { 0, 0, 0, {0, 0, 0}, {2, 2, 1}, {0, 0, 1} };
					device->copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
					region.texSubres.baseArrayLayer = 1;
					device->copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
					region.texSubres.baseArrayLayer = 2;
					device->copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
					region.texSubres.baseArrayLayer = 3;
					device->copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
					region.texSubres.baseArrayLayer = 4;
					device->copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
					region.texSubres.baseArrayLayer = 5;
					device->copyBuffersToTexture(&bufferData, _textureCube, &region, 1);
				}

				if (device->getCapabilities().max3DTextureSize >= 2) {
					_texture3D = device->createTexture({ TextureType::TEX3D, TextureUsageBit::STORAGE | TextureUsageBit::SAMPLED | TextureUsageBit::TRANSFER_DST,
														Format::RGBA8, 2, 2, TextureFlagBit::NONE, 1, 1, SampleCount::X1, 2 });
					BufferTextureCopy region = { 0, 0, 0, {0, 0, 0}, {2, 2, 2}, {0, 0, 1} };
					device->copyBuffersToTexture(&bufferData, _texture3D, &region, 1);
				}
				if (device->getCapabilities().maxArrayTextureLayers >= 2) {
					_texture2DArray = device->createTexture({ TextureType::TEX2D_ARRAY, TextureUsageBit::STORAGE | TextureUsageBit::SAMPLED | TextureUsageBit::TRANSFER_DST,
															 Format::RGBA8, 2, 2, TextureFlagBit::NONE, 2 });
					BufferTextureCopy region = { 0, 0, 0, {0, 0, 0}, {2, 2, 1}, {0, 0, 1} };
					device->copyBuffersToTexture(&bufferData, _texture2DArray, &region, 1);
					region.texSubres.baseArrayLayer = 1;
					device->copyBuffersToTexture(&bufferData, _texture2DArray, &region, 1);
				}
				{
					BufferInfo bufferInfo = {};
					bufferInfo.usage = BufferUsageBit::STORAGE | BufferUsageBit::TRANSFER_DST | BufferUsageBit::TRANSFER_SRC | BufferUsageBit::VERTEX | BufferUsageBit::INDIRECT;
					bufferInfo.memUsage = MemoryUsageBit::DEVICE | MemoryUsageBit::HOST;
					bufferInfo.size = 5 * sizeof(uint32); // for indirect command buffer
					bufferInfo.stride = bufferInfo.size;
					_buffer = device->createBuffer(bufferInfo);
				}
			}

			~DefaultResource() = default;

			Texture* getTexture(TextureType type) {
				switch (type) {
				case TextureType::TEX2D:
					return _texture2D;
				case TextureType::CUBE:
					return _textureCube;
				case TextureType::TEX3D:
					return _texture3D;
				case TextureType::TEX2D_ARRAY:
					return _texture2DArray;
				default:
					CC_ABORT();
					return null;
				}
			}
			Buffer* getBuffer() {
				return _buffer;
			}

		private:
			IntrusivePtr<Texture> _texture2D;
			IntrusivePtr<Texture> _texture2DArray;
			IntrusivePtr<Texture> _textureCube;
			IntrusivePtr<Texture> _texture3D;
			IntrusivePtr<Buffer> _buffer;
		};

		//////////////////////////////////////////////////////////////////////////

		

	} // namespace gfx
} // namespace cc
