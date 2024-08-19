/****************************************************************************
 Copyright (c) 2022-2023 Xiamen Yaji Software Co., Ltd.

 https://www.cocos.com/

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

#include "GFXBarrier.h"
#include <algorithm>
#include <array>

namespace cc {

namespace gfx {

namespace {






;



static AccessElem[?] ACCESS_MAP = .(
    {CARE_MEMACCESS,
     0x0,
     AccessFlags::NONE},

    {CARE_MEMUSAGE,
     0x0,
     AccessFlags::NONE},

    {CARE_RESTYPE | CARE_CMNUSAGE,
     RES_BUFFER | CMN_INDIRECT_OR_INPUT,
     AccessFlags::INDIRECT_BUFFER},

    {CARE_RESTYPE | CARE_CMNUSAGE,
     RES_BUFFER | CMN_IB_OR_CA,
     AccessFlags::INDEX_BUFFER}, // buffer usage indicates what it is, so shader stage ignored.

    {CARE_RESTYPE | CARE_CMNUSAGE,
     ACCESS_READ | RES_BUFFER | CMN_VB_OR_DS,
     AccessFlags::VERTEX_BUFFER}, // ditto

    {IGNORE_MEMUSAGE,
     ACCESS_READ | RES_BUFFER | SHADERSTAGE_VERT | CMN_ROM,
     AccessFlags::VERTEX_SHADER_READ_UNIFORM_BUFFER},

    {IGNORE_MEMUSAGE,
     ACCESS_READ | RES_TEXTURE | SHADERSTAGE_VERT | CMN_ROM,
     AccessFlags::VERTEX_SHADER_READ_TEXTURE},

    {IGNORE_MEMUSAGE & IGNORE_RESTYPE,
     ACCESS_READ | ACCESS_WRITE | SHADERSTAGE_VERT | CMN_STORAGE,
     AccessFlags::VERTEX_SHADER_READ_OTHER},

    {IGNORE_MEMUSAGE,
     ACCESS_READ | RES_BUFFER | SHADERSTAGE_FRAG | CMN_ROM,
     AccessFlags::FRAGMENT_SHADER_READ_UNIFORM_BUFFER},

    {CARE_MEMACCESS | CARE_RESTYPE | CARE_SHADERSTAGE | CARE_CMNUSAGE,
     ACCESS_READ | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_ROM,
     AccessFlags::FRAGMENT_SHADER_READ_TEXTURE,
     CMN_VB_OR_DS},

    {IGNORE_MEMUSAGE,
     ACCESS_READ | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_IB_OR_CA | CMN_INDIRECT_OR_INPUT,
     AccessFlags::FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT},

    {IGNORE_MEMUSAGE,
     ACCESS_READ | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_VB_OR_DS | CMN_INDIRECT_OR_INPUT,
     AccessFlags::FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT},

    {IGNORE_MEMUSAGE & IGNORE_RESTYPE,
     ACCESS_READ | ACCESS_WRITE | SHADERSTAGE_FRAG | CMN_STORAGE,
     AccessFlags::FRAGMENT_SHADER_READ_OTHER,
     CMN_SHADING_RATE},

    //{IGNORE_MEMUSAGE,
    // ACCESS_READ | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_IB_OR_CA,
    // AccessFlags::COLOR_ATTACHMENT_READ},

    {CARE_MEMACCESS | CARE_RESTYPE | CARE_CMNUSAGE | CARE_SHADERSTAGE,
     ACCESS_READ | RES_TEXTURE | CMN_VB_OR_DS | CMN_ROM,
     AccessFlags::DEPTH_STENCIL_ATTACHMENT_READ},

    {IGNORE_MEMUSAGE,
     ACCESS_READ | RES_BUFFER | SHADERSTAGE_COMP | CMN_ROM,
     AccessFlags::COMPUTE_SHADER_READ_UNIFORM_BUFFER},

    {IGNORE_MEMUSAGE,
     ACCESS_READ | RES_TEXTURE | SHADERSTAGE_COMP | CMN_ROM,
     AccessFlags::COMPUTE_SHADER_READ_TEXTURE,
     CMN_VB_OR_DS},

    // shading rate has its own flag
    {CARE_MEMACCESS | CARE_SHADERSTAGE | CARE_CMNUSAGE,
     ACCESS_READ | ACCESS_WRITE | SHADERSTAGE_COMP | CMN_STORAGE,
     AccessFlags::COMPUTE_SHADER_READ_OTHER,
     CMN_ROM},

    {CARE_MEMACCESS | CARE_CMNUSAGE,
     ACCESS_READ | CMN_COPY_SRC,
     AccessFlags::TRANSFER_READ},

    {CARE_MEMACCESS | CARE_MEMUSAGE,
     ACCESS_READ | MEM_HOST,
     AccessFlags::HOST_READ},

    {CARE_MEMACCESS | CARE_SHADERSTAGE | CARE_CMNUSAGE,
     ACCESS_READ | SHADERSTAGE_FRAG | CMN_SHADING_RATE,
     AccessFlags::SHADING_RATE},

    //{CARE_CMNUSAGE | CARE_RESTYPE,
    // RES_TEXTURE | CMN_NONE,
    // AccessFlags::PRESENT},

    {CARE_MEMACCESS | CARE_SHADERSTAGE | CARE_CMNUSAGE,
     ACCESS_WRITE | SHADERSTAGE_VERT | CMN_STORAGE,
     AccessFlags::VERTEX_SHADER_WRITE},

    {CARE_MEMACCESS | CARE_SHADERSTAGE | CARE_CMNUSAGE,
     ACCESS_WRITE | SHADERSTAGE_FRAG | CMN_STORAGE,
     AccessFlags::FRAGMENT_SHADER_WRITE},

    {IGNORE_MEMUSAGE,
     ACCESS_WRITE | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_IB_OR_CA,
     AccessFlags::COLOR_ATTACHMENT_WRITE},

    {IGNORE_NONE,
     ACCESS_WRITE | MEM_DEVICE | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_VB_OR_DS,
     AccessFlags::DEPTH_STENCIL_ATTACHMENT_WRITE},

    {CARE_MEMACCESS | CARE_SHADERSTAGE | CARE_CMNUSAGE,
     ACCESS_WRITE | SHADERSTAGE_COMP | CMN_STORAGE,
     AccessFlags::COMPUTE_SHADER_WRITE},

    {CARE_MEMACCESS | CARE_CMNUSAGE,
     ACCESS_WRITE | CMN_COPY_DST,
     AccessFlags::TRANSFER_WRITE},

    {CARE_MEMACCESS | CARE_MEMUSAGE,
     ACCESS_WRITE | MEM_HOST,
     AccessFlags::HOST_WRITE},
);

constexpr bool validateAccess(ResourceType type, CommonUsage usage, MemoryAccess access, ShaderStageFlags visibility) {
    bool res = true;
    if (type == ResourceType::BUFFER) {
        uint32 conflicts[] = {
            hasFlag(usage, CommonUsage::ROM) && hasFlag(access, MemoryAccess::WRITE_ONLY),                                       // uniform has write access.
            hasAnyFlags(usage, CommonUsage::IB_OR_CA | CommonUsage::VB_OR_DS) && !hasFlag(visibility, ShaderStageFlags::VERTEX), // color/ds/input not in fragment
            hasAllFlags(usage, CommonUsage::ROM | CommonUsage::STORAGE),                                                         // storage ^ sampled
            hasFlag(usage, CommonUsage::COPY_SRC) && hasAllFlags(MemoryAccess::READ_ONLY, access),                               // transfer src ==> read_only
            hasFlag(usage, CommonUsage::COPY_DST) && hasAllFlags(MemoryAccess::WRITE_ONLY, access),                              // transfer dst ==> write_only
            hasAllFlags(usage, CommonUsage::COPY_SRC | CommonUsage::COPY_DST),                                                   // both src and dst
            hasFlag(usage, CommonUsage::VB_OR_DS) && hasAnyFlags(usage, CommonUsage::IB_OR_CA | CommonUsage::INDIRECT_OR_INPUT),
            hasFlag(usage, CommonUsage::IB_OR_CA) && hasAnyFlags(usage, CommonUsage::VB_OR_DS | CommonUsage::INDIRECT_OR_INPUT),
            hasFlag(usage, CommonUsage::INDIRECT_OR_INPUT) && hasAnyFlags(usage, CommonUsage::IB_OR_CA | CommonUsage::VB_OR_DS),
            // exlusive
        };
        res = !(*std::max_element(std::begin(conflicts), std::end(conflicts)));
    } else if (type == ResourceType::TEXTURE) {
        uint32 conflicts[] = {
            // hasAnyFlags(usage, CommonUsage::IB_OR_CA | CommonUsage::VB_OR_DS | CommonUsage::INDIRECT_OR_INPUT) && !hasFlag(visibility, ShaderStageFlags::FRAGMENT), // color/ds/input not in fragment
            hasFlag(usage, CommonUsage::INDIRECT_OR_INPUT) && !hasFlag(access, MemoryAccess::READ_ONLY), // input needs read
            hasAllFlags(usage, CommonUsage::IB_OR_CA | CommonUsage::STORAGE),                            // storage ^ sampled
            hasFlag(usage, CommonUsage::COPY_SRC) && !hasAllFlags(MemoryAccess::READ_ONLY, access),      // transfer src ==> read_only
            hasFlag(usage, CommonUsage::COPY_DST) && !hasAllFlags(MemoryAccess::WRITE_ONLY, access),
            hasFlag(usage, CommonUsage::INDIRECT_OR_INPUT) && !hasAnyFlags(usage, CommonUsage::IB_OR_CA | CommonUsage::VB_OR_DS), // input needs to specify color or ds                                                                    // transfer dst ==> write_only
            hasAllFlags(usage, CommonUsage::COPY_SRC | CommonUsage::COPY_DST),                                                    // both src and dst
        };
        res = !(*std::max_element(std::begin(conflicts), std::end(conflicts)));
    }
    return res;
}

constexpr AccessFlags getAccessFlagsImpl(
    BufferUsage usage, MemoryUsage memUsage,
    MemoryAccess access,
    ShaderStageFlags visibility) noexcept {
    AccessFlags flags = AccessFlags::NONE;
    CommonUsage cmnUsage = bufferUsageToCommonUsage(usage);
    if (validateAccess(ResourceType::BUFFER, cmnUsage, access, visibility)) {
        uint32 info = 0xFFFFFFFF;
        info &= ((OPERABLE(access) << ACCESS_TYPE_BIT_POS) | IGNORE_MEMACCESS);
        info &= ((OPERABLE(memUsage) << MEM_TYPE_BIT_POS) | IGNORE_MEMUSAGE);
        info &= ((OPERABLE(ResourceType::TEXTURE) << RESOURCE_TYPE_BIT_POS) | IGNORE_RESTYPE);
        info &= ((OPERABLE(visibility) << SHADER_STAGE_BIT_POPS) | IGNORE_SHADERSTAGE);
        info &= OPERABLE(cmnUsage) | IGNORE_CMNUSAGE;

        for (const auto& elem : ACCESS_MAP) {
            auto testFlag = info & elem.mask;
            // hasKey
            if ((testFlag & elem.key) == elem.key) {
                flags |= elem.access;
            }
        }

    } else {
        flags = INVALID_ACCESS_FLAGS;
    }
    return flags;
}

constexpr AccessFlags getAccessFlagsImpl(
    TextureUsage usage,
    MemoryAccess access,
    ShaderStageFlags visibility) noexcept {
    AccessFlags flags = AccessFlags::NONE;
    CommonUsage cmnUsage = textureUsageToCommonUsage(usage);
    if (validateAccess(ResourceType::TEXTURE, cmnUsage, access, visibility)) {
        if (usage == gfx::TextureUsageBit::NONE) {
            return gfx::AccessFlagBit::PRESENT;
        }
        uint32 info = 0xFFFFFFFF;
        info &= ((OPERABLE(access) << ACCESS_TYPE_BIT_POS) | IGNORE_MEMACCESS);
        info &= ((OPERABLE(MemoryUsage::DEVICE) << MEM_TYPE_BIT_POS) | IGNORE_MEMUSAGE);
        info &= ((OPERABLE(ResourceType::TEXTURE) << RESOURCE_TYPE_BIT_POS) | IGNORE_RESTYPE);
        info &= ((OPERABLE(visibility) << (SHADER_STAGE_BIT_POPS)) | IGNORE_SHADERSTAGE);
        info &= OPERABLE(cmnUsage) | IGNORE_CMNUSAGE;

        for (const auto& elem : ACCESS_MAP) {
            auto testFlag = info & elem.mask;
            // hasKey && no mutex flag
            if (((testFlag & elem.key) == elem.key) && ((testFlag & elem.mutex) == 0)) {
                flags |= elem.access;
            }
        }
    } else {
        flags = INVALID_ACCESS_FLAGS;
    }

    // Runtime.Assert(flags != INVALID_ACCESS_FLAGS);
    return flags;
}

} // namespace

AccessFlags getAccessFlags(
    BufferUsage usage, MemoryUsage memUsage,
    MemoryAccess access,
    ShaderStageFlags visibility) noexcept 

AccessFlags getAccessFlags(
    TextureUsage usage,
    MemoryAccess access,
    ShaderStageFlags visibility) noexcept 

namespace {

constexpr 

static_assert(
    (AccessFlags::VERTEX_SHADER_WRITE | AccessFlags::VERTEX_SHADER_READ_OTHER) ==
    getAccessFlagsImpl(
        TextureUsage::STORAGE,
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::VERTEX));

static_assert(
    (AccessFlags::FRAGMENT_SHADER_WRITE | AccessFlags::FRAGMENT_SHADER_READ_OTHER) ==
    getAccessFlagsImpl(
        TextureUsage::STORAGE,
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::COMPUTE_SHADER_WRITE | AccessFlags::COMPUTE_SHADER_READ_OTHER) ==
    getAccessFlagsImpl(
        TextureUsage::STORAGE,
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::COMPUTE));

static_assert(
    INVALID_ACCESS_FLAGS ==
    getAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT | TextureUsage::STORAGE,
        MemoryAccess::READ_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    INVALID_ACCESS_FLAGS ==
    getAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT | TextureUsage::SAMPLED | TextureUsage::STORAGE,
        MemoryAccess::READ_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::TRANSFER_WRITE | AccessFlags::COLOR_ATTACHMENT_WRITE) ==
    getAccessFlagsImpl(
        TextureUsage::TRANSFER_DST | TextureUsage::COLOR_ATTACHMENT,
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::ALL));

////////////////////////////////////

// VERTEX_SHADER_WRITE
static_assert(
    AccessFlags::VERTEX_SHADER_WRITE ==
    getDeviceAccessFlagsImpl(
        TextureUsage::STORAGE,
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::VERTEX));

static_assert(
    (AccessFlags::VERTEX_SHADER_WRITE | AccessFlags::VERTEX_SHADER_READ_TEXTURE) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::STORAGE,
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::VERTEX));

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::STORAGE | TextureUsage::SAMPLED, // both storage write and sampling
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::VERTEX));

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::SAMPLED, // Sampled cannot be write
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::VERTEX));

// FRAGMENT_SHADER_WRITE
static_assert(
    AccessFlags::FRAGMENT_SHADER_WRITE ==
    getDeviceAccessFlagsImpl(
        TextureUsage::STORAGE,
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::FRAGMENT_SHADER_WRITE | AccessFlags::FRAGMENT_SHADER_READ_TEXTURE) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::STORAGE,
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::FRAGMENT));

// COLOR_ATTACHMENT_WRITE
static_assert(
    AccessFlags::COLOR_ATTACHMENT_WRITE ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT,
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT,
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::VERTEX)); // not fragment stage

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT | TextureUsage::SAMPLED, // both color attachment and sampled texture
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::COLOR_ATTACHMENT_WRITE | AccessFlags::COLOR_ATTACHMENT_READ) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT,
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::FRAGMENT));

static_assert(
    AccessFlags::COLOR_ATTACHMENT_READ ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT,
        MemoryAccess::READ_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::COLOR_ATTACHMENT_READ | AccessFlags::FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT,
        MemoryAccess::READ_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::COLOR_ATTACHMENT_WRITE | AccessFlags::COLOR_ATTACHMENT_READ | AccessFlags::FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT,
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::FRAGMENT));

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT,
        MemoryAccess::WRITE_ONLY, // INPUT_ATTACHMENT needs read access
        ShaderStageFlags::FRAGMENT));

// DEPTH_STENCIL_ATTACHMENT_WRITE
static_assert(
    AccessFlags::DEPTH_STENCIL_ATTACHMENT_WRITE ==
    getDeviceAccessFlagsImpl(
        TextureUsage::DEPTH_STENCIL_ATTACHMENT,
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::DEPTH_STENCIL_ATTACHMENT,
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::VERTEX)); // not fragment stage

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::DEPTH_STENCIL_ATTACHMENT | TextureUsage::SAMPLED, // both color attachment and sampled texture
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::DEPTH_STENCIL_ATTACHMENT_WRITE | AccessFlags::DEPTH_STENCIL_ATTACHMENT_READ) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::DEPTH_STENCIL_ATTACHMENT,
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::FRAGMENT));

static_assert(
    AccessFlags::DEPTH_STENCIL_ATTACHMENT_READ ==
    getDeviceAccessFlagsImpl(
        TextureUsage::DEPTH_STENCIL_ATTACHMENT,
        MemoryAccess::READ_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::DEPTH_STENCIL_ATTACHMENT_READ | AccessFlags::FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::DEPTH_STENCIL_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT,
        MemoryAccess::READ_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::DEPTH_STENCIL_ATTACHMENT_WRITE | AccessFlags::DEPTH_STENCIL_ATTACHMENT_READ | AccessFlags::FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::DEPTH_STENCIL_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT,
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::FRAGMENT));

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::DEPTH_STENCIL_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT,
        MemoryAccess::WRITE_ONLY, // INPUT_ATTACHMENT needs read access
        ShaderStageFlags::FRAGMENT));

// COMPUTE_SHADER_WRITE
static_assert(
    AccessFlags::COMPUTE_SHADER_WRITE ==
    getDeviceAccessFlagsImpl(
        TextureUsage::STORAGE,
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::COMPUTE));
static_assert(
    (AccessFlags::COMPUTE_SHADER_WRITE | AccessFlags::COMPUTE_SHADER_READ_TEXTURE) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::STORAGE,
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::COMPUTE));
static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::STORAGE | TextureUsage::SAMPLED, // cannot be sampled
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::COMPUTE));
static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::STORAGE | TextureUsage::SAMPLED, // cannot be sampled
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::COMPUTE));

// TRANSFER_WRITE
static_assert(
    AccessFlags::TRANSFER_WRITE ==
    getDeviceAccessFlagsImpl(
        TextureUsage::TRANSFER_DST,
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::ALL)); // ShaderStageFlags not used

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::TRANSFER_DST,
        MemoryAccess::READ_WRITE,
        ShaderStageFlags::ALL)); // ShaderStageFlags not used

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::TRANSFER_DST | TextureUsage::TRANSFER_SRC, // both source and target
        MemoryAccess::READ_WRITE,                                // both read and write
        ShaderStageFlags::ALL));

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::TRANSFER_DST | TextureUsage::TRANSFER_SRC, // both source and target
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::ALL));

static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::TRANSFER_DST | TextureUsage::COLOR_ATTACHMENT, // cannot be sampled
        MemoryAccess::WRITE_ONLY,
        ShaderStageFlags::ALL));

// Read
// COLOR_ATTACHMENT_READ
static_assert(
    INVALID_ACCESS_FLAGS ==
    getDeviceAccessFlagsImpl(
        TextureUsage::INPUT_ATTACHMENT, // INPUT_ATTACHMENT needs COLOR_ATTACHMENT or DEPTH_STENCIL_ATTACHMENT
        MemoryAccess::READ_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::COLOR_ATTACHMENT_READ | AccessFlags::FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT | AccessFlags::FRAGMENT_SHADER_READ_TEXTURE) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT | TextureUsage::SAMPLED,
        MemoryAccess::READ_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::COLOR_ATTACHMENT_READ | AccessFlags::FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT | AccessFlags::FRAGMENT_SHADER_READ_TEXTURE) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT | TextureUsage::STORAGE,
        MemoryAccess::READ_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::COLOR_ATTACHMENT_READ | AccessFlags::FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT | AccessFlags::FRAGMENT_SHADER_READ_TEXTURE) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT | TextureUsage::SAMPLED | TextureUsage::STORAGE,
        MemoryAccess::READ_ONLY,
        ShaderStageFlags::FRAGMENT));

static_assert(
    (AccessFlags::COLOR_ATTACHMENT_READ | AccessFlags::FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT | AccessFlags::TRANSFER_READ) ==
    getDeviceAccessFlagsImpl(
        TextureUsage::COLOR_ATTACHMENT | TextureUsage::INPUT_ATTACHMENT | TextureUsage::TRANSFER_SRC,
        MemoryAccess::READ_ONLY,
        ShaderStageFlags::FRAGMENT));

} // namespace

 // namespace gfx

} // namespace cc
