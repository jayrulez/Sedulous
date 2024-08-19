/****************************************************************************
 Copyright (c) 2020-2023 Xiamen Yaji Software Co., Ltd.

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

#pragma once

#include "VKStd.h"
#include "gfx-base/GFXBuffer.h"
#include "gfx-vulkan/VKGPUObjects.h"

namespace cc {
namespace gfx {

class CC_VULKAN_API CCVKBuffer final : public Buffer {
public:
    CCVKBuffer(){
    _typedID = generateObjectID<decltype(this)>();
}
    ~CCVKBuffer() {
    destroy();
}

    void update(const void *buffer, uint32_t size) {
    CC_PROFILE(CCVKBufferUpdate);
    cmdFuncCCVKUpdateBuffer(CCVKDevice::getInstance(), _gpuBuffer, buffer, size, nullptr);
}

    inline CCVKGPUBuffer *gpuBuffer() const { return _gpuBuffer; }
    inline CCVKGPUBufferView *gpuBufferView() const { return _gpuBufferView; }

protected:
    void doInit(const BufferInfo &info) {
    createBuffer(_size, _count);

    createBufferView(_size);
}

    void doInit(const BufferViewInfo &info) {
    auto *buffer = static_cast<CCVKBuffer *>(info.buffer);
    _gpuBuffer = buffer->gpuBuffer();

    createBufferView(_size);
}

    void doDestroy() {
    _gpuBufferView = nullptr;
    _gpuBuffer = nullptr;
}
    void doResize(uint32_t size, uint32_t count) {
    createBuffer(size, count);

    // Hold reference to keep the old bufferView alive during DescriptorHub::update and IAHub::update.
    IntrusivePtr<CCVKGPUBufferView> oldBufferView = _gpuBufferView;
    createBufferView(size);
    CCVKDevice::getInstance()->gpuDescriptorHub()->update(oldBufferView, _gpuBufferView);
    CCVKDevice::getInstance()->gpuIAHub()->update(oldBufferView, _gpuBufferView);
}

    void createBuffer(uint32_t size, uint32_t count){
    _gpuBuffer = ccnew CCVKGPUBuffer;
    _gpuBuffer->size = size;
    _gpuBuffer->count = count;

    _gpuBuffer->usage = _usage;
    _gpuBuffer->memUsage = _memUsage;
    _gpuBuffer->stride = _stride;
    _gpuBuffer->init();
}
    void createBufferView(uint32_t range){
    _gpuBufferView = ccnew CCVKGPUBufferView;
    _gpuBufferView->range = range;

    _gpuBufferView->gpuBuffer = _gpuBuffer;
    _gpuBufferView->offset = _offset;
}

    IntrusivePtr<CCVKGPUBuffer> _gpuBuffer;
    IntrusivePtr<CCVKGPUBufferView> _gpuBufferView;
};

} // namespace gfx
} // namespace cc
