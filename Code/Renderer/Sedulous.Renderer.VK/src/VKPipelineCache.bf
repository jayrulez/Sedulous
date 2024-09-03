using Bulkan;
using System;
using System.Collections;

using static Bulkan.VulkanNative;
/****************************************************************************
 Copyright (c) 2023 Xiamen Yaji Software Co., Ltd.

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

static
{
	const String fileName = "/pipeline_cache_vk.bin";
	const uint32 MAGIC = 0x4343564B; // "CCVK"
	const uint32 VERSION = 1;

	internal static void loadData(String path, ref List<char8> data)
	{
		/*std::ifstream stream(path, std::ios::binary);
		if (!stream.is_open()) {
			CC_LOG_INFO("Load program cache, no cached files.");
			return;
		}

		uint32 magic = 0;
		uint32 version = 0;

		cc::BinaryInputArchive archive(stream);
		auto loadResult = archive.load(magic);
		loadResult &= archive.load(version);

		uint32 size = 0;
		if (loadResult && magic == MAGIC && version >= VERSION) {
			loadResult &= archive.load(size);
			data.resize(size);
			loadResult &= archive.load(data.data(), size);
		}
		if (loadResult) {
			CC_LOG_INFO("Load pipeline cache success.");
		}*/
	}
}

namespace Sedulous.Renderer.VK;

class CCVKPipelineCache
{
	public this()
	{
		//_savePath = getPipelineCacheFolder() + fileName;
	}

	public ~this()
	{
		if (_pipelineCache != .Null)
		{
#if CC_USE_PIPELINE_CACHE
			saveCache();
#endif
			vkDestroyPipelineCache(_device, _pipelineCache, null);
		}
	}

	public void init(VkDevice dev)
	{
		_device = dev;
		loadCache();
	}

	public void loadCache()
	{
		List<char8> data = scope .();
#if CC_USE_PIPELINE_CACHE
		loadData(_savePath, data);
#endif

		VkPipelineCacheCreateInfo cacheInfo = .();
		cacheInfo.sType = .VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO;
		cacheInfo.pNext = null;
		cacheInfo.initialDataSize = (uint32)data.Count;
		cacheInfo.pInitialData = data.Ptr;
		VK_CHECK!(vkCreatePipelineCache(_device, &cacheInfo, null, &_pipelineCache));
	}
	public void saveCache()
	{
		if (!_dirty)
		{
			return;
		}
		//std::ofstream stream(_savePath, std::ios::binary);
		//if (!stream.is_open()) {
		//	CC_LOG_INFO("Save program cache failed.");
		//	return;
		//}
		//BinaryOutputArchive archive(stream);
		//archive.save(MAGIC);
		//archive.save(VERSION);

		uint size = 0;
		vkGetPipelineCacheData(_device, _pipelineCache, &size, null);
		List<char8> data = scope .() { Count = (int)size };
		vkGetPipelineCacheData(_device, _pipelineCache, &size, data.Ptr);

		//archive.save((uint32)size);
		//archive.save(data.data(), (uint32)size);
		_dirty = false;
	}

	public void setDirty()
	{
		_dirty = true;
	}
	public VkPipelineCache getHandle()
	{
		return _pipelineCache;
	}

	private VkDevice _device = .Null;
	private VkPipelineCache _pipelineCache = .Null;
	private String _savePath;
	private bool _dirty = false;
}