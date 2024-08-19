using System;
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

namespace cc
{
	namespace gfx
	{
		static
		{
			enum ResourceType : uint32
			{
				UNKNOWN,
				BUFFER,
				TEXTURE,
			}

			[AllowDuplicates]
			enum CommonUsage : uint32
			{
				NONE = 0,
				COPY_SRC = 1 << 1,
				COPY_DST = 1 << 2,
				ROM = 1 << 3, // sampled or UNIFORM
				STORAGE = 1 << 4,
				IB_OR_CA = 1 << 5,
				VB_OR_DS = 1 << 6,
				INDIRECT_OR_INPUT = 1 << 7,
				SHADING_RATE = 1 << 8,

				LAST_ONE = SHADING_RATE,
			}
			// CC_ENUM_BITWISE_OPERATORS(CommonUsage);

			//[Comptime]
			private static CommonUsage textureUsageToCommonUsage(TextureUsage usage)
			{
				CommonUsage res = 0;
				if (usage.HasFlag(  TextureUsage.TRANSFER_SRC))
				{
					res |= CommonUsage.COPY_SRC;
				}
				if (usage.HasFlag(  TextureUsage.TRANSFER_DST))
				{
					res |= CommonUsage.COPY_DST;
				}
				if (usage.HasFlag(  TextureUsage.SAMPLED))
				{
					res |= CommonUsage.ROM;
				}
				if (usage.HasFlag(  TextureUsage.STORAGE))
				{
					res |= CommonUsage.STORAGE;
				}
				if (usage.HasFlag(  TextureUsage.COLOR_ATTACHMENT))
				{
					res |= CommonUsage.IB_OR_CA;
				}
				if (usage.HasFlag(  TextureUsage.DEPTH_STENCIL_ATTACHMENT))
				{
					res |= CommonUsage.VB_OR_DS;
				}
				if (usage.HasFlag(  TextureUsage.INPUT_ATTACHMENT))
				{
					res |= CommonUsage.INDIRECT_OR_INPUT;
				}
				if (usage.HasFlag(  TextureUsage.SHADING_RATE))
				{
					res |= CommonUsage.SHADING_RATE;
				}
				return res;
			}

			//[Comptime]
			private static CommonUsage bufferUsageToCommonUsage(BufferUsage usage)
			{
				CommonUsage res = 0;
				if (usage.HasFlag(  BufferUsage.NONE))
				{
					res |= CommonUsage.NONE;
				}
				if (usage.HasFlag(  BufferUsage.TRANSFER_SRC))
				{
					res |= CommonUsage.COPY_SRC;
				}
				if (usage.HasFlag(  BufferUsage.TRANSFER_DST))
				{
					res |= CommonUsage.COPY_DST;
				}
				if (usage.HasFlag(  BufferUsage.UNIFORM))
				{
					res |= CommonUsage.ROM;
				}
				if (usage.HasFlag(  BufferUsage.STORAGE))
				{
					res |= CommonUsage.STORAGE;
				}
				if (usage.HasFlag(  BufferUsage.INDEX))
				{
					res |= CommonUsage.IB_OR_CA;
				}
				if (usage.HasFlag(  BufferUsage.VERTEX))
				{
					res |= CommonUsage.VB_OR_DS;
				}
				if (usage.HasFlag(  BufferUsage.INDIRECT))
				{
					res |= CommonUsage.INDIRECT_OR_INPUT;
				}
				return res;
			}


			struct AccessElem
			{
				public uint32 mask = 0xFFFFFFFF;
				public uint32 key = 0xFFFFFFFF;
				public AccessFlags access = /*AccessFlags*/.NONE;
				public uint32 mutex = 0x0; // optional mutually exclusive flag

				public this(uint32 mask = 0xFFFFFFFF, uint32 key = 0xFFFFFFFF, AccessFlags access = /*AccessFlags*/.NONE, uint32 mutex = 0x0)
				{
					this.mask = mask;
					this.key = key;
					this.access = access;
					this.mutex = mutex;
				}
			}

			/*
			template <unsigned char... indices>
			constexpr uint64 setbit() {
			    return ((1ULL << indices) | ... | 0ULL);
			}

			template <typename T, uint... indices>
			constexpr uint64 setbits(const std::integer_sequence<T, indices...>& intSeq) {
			    std::ignore = intSeq;
			    return setbit<indices...>();
			}

			template <std::uint N>
			static uint64 setbits<N>() where N : uint {
			    typealias index_seq = std::make_index_sequence<N>;
			    return setbits(index_seq{});
			}

			static uint64 setbitBetween<first, end>() where first : uint8 where end : uint8 {
			    static_assert(first >= end);
			    return setbits<first>() ^ setbits<end>();
			}

			*/
			

			static uint32 setbitBetween2<TFirst, TEnd>(TFirst first, TEnd end) where TFirst : var where TEnd : var {
				Runtime.Assert(first >= end);
				uint64 result = 0;
				for(int i = end; i < first; i++)
				{
					result = result | (1UL << i);
				}

				return (.)result;
			}

			static uint8 highestBitPosOffset<N>() where N : const uint32 {
			    if (N == 0) {
			        return 0;
			    } else {
			        return highestBitPosOffset<const N/2>() + 1;
					// N>> 1
			    }
			}


			private static uint32 OPERABLE<T>(T value) where T : enum
			{
				return value.Underlying;
			}

			
			const uint8 COMMON_USAGE_COUNT = highestBitPosOffset<const OPERABLE(CommonUsage.LAST_ONE)>();
			const uint8 SHADER_STAGE_RESERVE_COUNT = 6;
			const uint8 RESOURCE_TYPE_COUNT = 2;
			const uint8 MEM_TYPE_COUNT = 2;
			const uint8 ACCESS_TYPE_COUNT = 2;

			const uint32 CMN_NONE = OPERABLE(CommonUsage.NONE);
			const uint32 CMN_COPY_SRC = OPERABLE(CommonUsage.COPY_SRC);
			const uint32 CMN_COPY_DST = OPERABLE(CommonUsage.COPY_DST);
			const uint32 CMN_ROM = OPERABLE(CommonUsage.ROM);
			const uint32 CMN_STORAGE = OPERABLE(CommonUsage.STORAGE);
			const uint32 CMN_IB_OR_CA = OPERABLE(CommonUsage.IB_OR_CA);
			const uint32 CMN_VB_OR_DS = OPERABLE(CommonUsage.VB_OR_DS);
			const uint32 CMN_INDIRECT_OR_INPUT = OPERABLE(CommonUsage.INDIRECT_OR_INPUT);
			const uint32 CMN_SHADING_RATE = OPERABLE(CommonUsage.SHADING_RATE);

			const uint8 SHADER_STAGE_BIT_POPS = COMMON_USAGE_COUNT;
			const int32 SHADERSTAGE_NONE = 0;
			const int32 SHADERSTAGE_VERT = 1 << (0 + SHADER_STAGE_BIT_POPS);
			const int32 SHADERSTAGE_CTRL = 1 << (1 + SHADER_STAGE_BIT_POPS);
			const int32 SHADERSTAGE_EVAL = 1 << (2 + SHADER_STAGE_BIT_POPS);
			const int32 SHADERSTAGE_GEOM = 1 << (3 + SHADER_STAGE_BIT_POPS);
			const int32 SHADERSTAGE_FRAG = 1 << (4 + SHADER_STAGE_BIT_POPS);
			const int32 SHADERSTAGE_COMP = 1 << (5 + SHADER_STAGE_BIT_POPS);

			const int32 RESOURCE_TYPE_BIT_POS = COMMON_USAGE_COUNT + SHADER_STAGE_RESERVE_COUNT;
			const uint32 RES_TEXTURE = OPERABLE(ResourceType.TEXTURE) << RESOURCE_TYPE_BIT_POS;
			const uint32 RES_BUFFER = OPERABLE(ResourceType.BUFFER) << RESOURCE_TYPE_BIT_POS;

			const int32 MEM_TYPE_BIT_POS = COMMON_USAGE_COUNT + SHADER_STAGE_RESERVE_COUNT + RESOURCE_TYPE_COUNT;
			const var MEM_HOST = OPERABLE(MemoryUsage.HOST) << MEM_TYPE_BIT_POS;
			const var MEM_DEVICE = OPERABLE(MemoryUsage.DEVICE) << MEM_TYPE_BIT_POS;

			const int32 ACCESS_TYPE_BIT_POS = COMMON_USAGE_COUNT + SHADER_STAGE_RESERVE_COUNT + RESOURCE_TYPE_COUNT + MEM_TYPE_COUNT;
			const var ACCESS_WRITE = OPERABLE(MemoryAccess.WRITE_ONLY) << ACCESS_TYPE_BIT_POS;
			const var ACCESS_READ = OPERABLE(MemoryAccess.READ_ONLY) << ACCESS_TYPE_BIT_POS;

			const uint8 USED_BIT_COUNT = COMMON_USAGE_COUNT + SHADER_STAGE_RESERVE_COUNT + RESOURCE_TYPE_COUNT + MEM_TYPE_COUNT + ACCESS_TYPE_COUNT;
			// 20 and above :reserved
			// 18 ~ 19: MemoryAccess
			// 16 ~ 17: MemoryUsage
			// 14 ~ 15: ResourceType
			// 8 ~ 13: ShaderStageFlags
			// 0 ~ 7: CommonUsage

			const uint32 CARE_NONE = 0x0;
			/*const uint32 CARE_CMNUSAGE = setbitBetween2<const SHADER_STAGE_BIT_POPS, const 0>();
			const uint32 CARE_SHADERSTAGE = setbitBetween2<const RESOURCE_TYPE_BIT_POS, const SHADER_STAGE_BIT_POPS>();
			const uint32 CARE_RESTYPE = setbitBetween2<const MEM_TYPE_BIT_POS, const RESOURCE_TYPE_BIT_POS>();
			const uint32 CARE_MEMUSAGE = setbitBetween2<const ACCESS_TYPE_BIT_POS, const MEM_TYPE_BIT_POS>();
			const uint32 CARE_MEMACCESS = setbitBetween2<const USED_BIT_COUNT, const ACCESS_TYPE_BIT_POS>();*/
			
			const uint32 CARE_CMNUSAGE = setbitBetween2( SHADER_STAGE_BIT_POPS, 0);
			const uint32 CARE_SHADERSTAGE = setbitBetween2( RESOURCE_TYPE_BIT_POS, SHADER_STAGE_BIT_POPS);
			const uint32 CARE_RESTYPE = setbitBetween2( MEM_TYPE_BIT_POS, RESOURCE_TYPE_BIT_POS);
			const uint32 CARE_MEMUSAGE = setbitBetween2( ACCESS_TYPE_BIT_POS, MEM_TYPE_BIT_POS);
			const uint32 CARE_MEMACCESS = setbitBetween2( USED_BIT_COUNT, ACCESS_TYPE_BIT_POS);

			const uint32 IGNORE_NONE = 0xFFFFFFFF;
			const uint32 IGNORE_CMNUSAGE = ~CARE_CMNUSAGE;
			const uint32 IGNORE_SHADERSTAGE = ~CARE_SHADERSTAGE;
			const uint32 IGNORE_RESTYPE = ~CARE_RESTYPE;
			const uint32 IGNORE_MEMUSAGE = ~CARE_MEMUSAGE;
			const uint32 IGNORE_MEMACCESS = ~CARE_MEMACCESS;

			static AccessElem[?] ACCESS_MAP = .(
			    .(CARE_MEMACCESS,
			     0x0,
			     AccessFlags.NONE),

			    .(CARE_MEMUSAGE,
			     0x0,
			     AccessFlags.NONE),

			    .(CARE_RESTYPE | CARE_CMNUSAGE,
			     RES_BUFFER | CMN_INDIRECT_OR_INPUT,
			     AccessFlags.INDIRECT_BUFFER),

			    .(CARE_RESTYPE | CARE_CMNUSAGE,
			     RES_BUFFER | CMN_IB_OR_CA,
			     AccessFlags.INDEX_BUFFER), // buffer usage indicates what it is, so shader stage ignored.

			    .(CARE_RESTYPE | CARE_CMNUSAGE,
			     ACCESS_READ | RES_BUFFER | CMN_VB_OR_DS,
			     AccessFlags.VERTEX_BUFFER), // ditto

			    .(IGNORE_MEMUSAGE,
			     ACCESS_READ | RES_BUFFER | SHADERSTAGE_VERT | CMN_ROM,
			     AccessFlags.VERTEX_SHADER_READ_UNIFORM_BUFFER),

			    .(IGNORE_MEMUSAGE,
			     ACCESS_READ | RES_TEXTURE | SHADERSTAGE_VERT | CMN_ROM,
			     AccessFlags.VERTEX_SHADER_READ_TEXTURE),

			    .(IGNORE_MEMUSAGE & IGNORE_RESTYPE,
			     ACCESS_READ | ACCESS_WRITE | SHADERSTAGE_VERT | CMN_STORAGE,
			     AccessFlags.VERTEX_SHADER_READ_OTHER),

			    .(IGNORE_MEMUSAGE,
			     ACCESS_READ | RES_BUFFER | SHADERSTAGE_FRAG | CMN_ROM,
			     AccessFlags.FRAGMENT_SHADER_READ_UNIFORM_BUFFER),

			    .(CARE_MEMACCESS | CARE_RESTYPE | CARE_SHADERSTAGE | CARE_CMNUSAGE,
			     ACCESS_READ | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_ROM,
			     AccessFlags.FRAGMENT_SHADER_READ_TEXTURE,
			     CMN_VB_OR_DS),

			    .(IGNORE_MEMUSAGE,
			     ACCESS_READ | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_IB_OR_CA | CMN_INDIRECT_OR_INPUT,
			     AccessFlags.FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT),

			    .(IGNORE_MEMUSAGE,
			     ACCESS_READ | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_VB_OR_DS | CMN_INDIRECT_OR_INPUT,
			     AccessFlags.FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT),

			    .(IGNORE_MEMUSAGE & IGNORE_RESTYPE,
			     ACCESS_READ | ACCESS_WRITE | SHADERSTAGE_FRAG | CMN_STORAGE,
			     AccessFlags.FRAGMENT_SHADER_READ_OTHER,
			     CMN_SHADING_RATE),

			    //.(IGNORE_MEMUSAGE,
			    // ACCESS_READ | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_IB_OR_CA,
			    // AccessFlags.COLOR_ATTACHMENT_READ),

			    .(CARE_MEMACCESS | CARE_RESTYPE | CARE_CMNUSAGE | CARE_SHADERSTAGE,
			     ACCESS_READ | RES_TEXTURE | CMN_VB_OR_DS | CMN_ROM,
			     AccessFlags.DEPTH_STENCIL_ATTACHMENT_READ),

			    .(IGNORE_MEMUSAGE,
			     ACCESS_READ | RES_BUFFER | SHADERSTAGE_COMP | CMN_ROM,
			     AccessFlags.COMPUTE_SHADER_READ_UNIFORM_BUFFER),

			    .(IGNORE_MEMUSAGE,
			     ACCESS_READ | RES_TEXTURE | SHADERSTAGE_COMP | CMN_ROM,
			     AccessFlags.COMPUTE_SHADER_READ_TEXTURE,
			     CMN_VB_OR_DS),

			    // shading rate has its own flag
			    .(CARE_MEMACCESS | CARE_SHADERSTAGE | CARE_CMNUSAGE,
			     ACCESS_READ | ACCESS_WRITE | SHADERSTAGE_COMP | CMN_STORAGE,
			     AccessFlags.COMPUTE_SHADER_READ_OTHER,
			     CMN_ROM),

			    .(CARE_MEMACCESS | CARE_CMNUSAGE,
			     ACCESS_READ | CMN_COPY_SRC,
			     AccessFlags.TRANSFER_READ),

			    .(CARE_MEMACCESS | CARE_MEMUSAGE,
			     ACCESS_READ | MEM_HOST,
			     AccessFlags.HOST_READ),

			    .(CARE_MEMACCESS | CARE_SHADERSTAGE | CARE_CMNUSAGE,
			     ACCESS_READ | SHADERSTAGE_FRAG | CMN_SHADING_RATE,
			     AccessFlags.SHADING_RATE),

			    //.(CARE_CMNUSAGE | CARE_RESTYPE,
			    // RES_TEXTURE | CMN_NONE,
			    // AccessFlags.PRESENT),

			    .(CARE_MEMACCESS | CARE_SHADERSTAGE | CARE_CMNUSAGE,
			     ACCESS_WRITE | SHADERSTAGE_VERT | CMN_STORAGE,
			     AccessFlags.VERTEX_SHADER_WRITE),

			    .(CARE_MEMACCESS | CARE_SHADERSTAGE | CARE_CMNUSAGE,
			     ACCESS_WRITE | SHADERSTAGE_FRAG | CMN_STORAGE,
			     AccessFlags.FRAGMENT_SHADER_WRITE),

			    .(IGNORE_MEMUSAGE,
			     ACCESS_WRITE | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_IB_OR_CA,
			     AccessFlags.COLOR_ATTACHMENT_WRITE),

			    .(IGNORE_NONE,
			     ACCESS_WRITE | MEM_DEVICE | RES_TEXTURE | SHADERSTAGE_FRAG | CMN_VB_OR_DS,
			     AccessFlags.DEPTH_STENCIL_ATTACHMENT_WRITE),

			    .(CARE_MEMACCESS | CARE_SHADERSTAGE | CARE_CMNUSAGE,
			     ACCESS_WRITE | SHADERSTAGE_COMP | CMN_STORAGE,
			     AccessFlags.COMPUTE_SHADER_WRITE),

			    .(CARE_MEMACCESS | CARE_CMNUSAGE,
			     ACCESS_WRITE | CMN_COPY_DST,
			     AccessFlags.TRANSFER_WRITE),

			    .(CARE_MEMACCESS | CARE_MEMUSAGE,
			     ACCESS_WRITE | MEM_HOST,
			     AccessFlags.HOST_WRITE),
			);

			public static AccessFlags getAccessFlags(
				BufferUsage usage, MemoryUsage memUsage,
				MemoryAccess access,
				ShaderStageFlags visibility)
			{
				return getAccessFlagsImpl(usage, memUsage, access, visibility);
			}

			public static AccessFlags getAccessFlags(
				TextureUsage usage,
				MemoryAccess access,
				ShaderStageFlags visibility)
			{
				return getAccessFlagsImpl(usage, access, visibility);
			}

			public const AccessFlags INVALID_ACCESS_FLAGS = (AccessFlags)0xFFFFFFFF;

			public static AccessFlags getDeviceAccessFlags(
				TextureUsage usage,
				MemoryAccess access,
				ShaderStageFlags visibility)
			{
				return getDeviceAccessFlagsImpl(usage, access, visibility);
			}

		}

		static
		{
			static bool hasFlag<T>(T flags, T flagToTest)
				where T : enum
				where T : operator T & T
			{
				return flags & flagToTest != 0;
			}

			static bool hasAnyFlags<T>(T flags, T flagsToTest)
				where T : enum
				where T : operator T & T
			{
				return flags & flagsToTest != 0;
			}

			static bool hasAllFlags<T>(T flags, T flagsToTest)
				where T : enum
				where T : operator T & T
			{
				return flags & flagsToTest == flagsToTest;
			}

			static bool validateAccess(ResourceType type, CommonUsage usage, MemoryAccess access, ShaderStageFlags visibility) {
				/*delegate uint32(uint32* elements, int count) getMaxElement = scope(elements, count) =>
					{
						uint32 max = elements[0];
						for(int i = 1; i < count; i++)
						{
							if(elements[i] > max)
								max = elements[i];
						}
						return max;
					};*/
			    bool res = true;
			    if (type == ResourceType.BUFFER) {
			        uint32[?] conflicts = .(
			            hasFlag(usage, CommonUsage.ROM) && hasFlag(access, MemoryAccess.WRITE_ONLY) ? 1 : 0,                                       // uniform has write access.
			            hasAnyFlags(usage, CommonUsage.IB_OR_CA | CommonUsage.VB_OR_DS) && !hasFlag(visibility, ShaderStageFlags.VERTEX) ? 1 : 0, // color/ds/input not in fragment
			            hasAllFlags(usage, CommonUsage.ROM | CommonUsage.STORAGE) ? 1 : 0,                                                         // storage ^ sampled
			            hasFlag(usage, CommonUsage.COPY_SRC) && hasAllFlags(MemoryAccess.READ_ONLY, access) ? 1 : 0,                               // transfer src ==> read_only
			            hasFlag(usage, CommonUsage.COPY_DST) && hasAllFlags(MemoryAccess.WRITE_ONLY, access) ? 1 : 0,                              // transfer dst ==> write_only
			            hasAllFlags(usage, CommonUsage.COPY_SRC | CommonUsage.COPY_DST) ? 1 : 0,                                                   // both src and dst
			            hasFlag(usage, CommonUsage.VB_OR_DS) && hasAnyFlags(usage, CommonUsage.IB_OR_CA | CommonUsage.INDIRECT_OR_INPUT) ? 1 : 0,
			            hasFlag(usage, CommonUsage.IB_OR_CA) && hasAnyFlags(usage, CommonUsage.VB_OR_DS | CommonUsage.INDIRECT_OR_INPUT) ? 1 : 0,
			            hasFlag(usage, CommonUsage.INDIRECT_OR_INPUT) && hasAnyFlags(usage, CommonUsage.IB_OR_CA | CommonUsage.VB_OR_DS) ? 1 : 0,
			            // exlusive
			        );
			        res = !conflicts.Contains(1);//!(*std.max_element(std.begin(conflicts), std.end(conflicts)));
			    } else if (type == ResourceType.TEXTURE) {
			        uint32[?] conflicts = .(
			            // hasAnyFlags(usage, CommonUsage.IB_OR_CA | CommonUsage.VB_OR_DS | CommonUsage.INDIRECT_OR_INPUT) && !hasFlag(visibility, ShaderStageFlags.FRAGMENT), // color/ds/input not in fragment
			            hasFlag(usage, CommonUsage.INDIRECT_OR_INPUT) && !hasFlag(access, MemoryAccess.READ_ONLY) ? 1 : 0, // input needs read
			            hasAllFlags(usage, CommonUsage.IB_OR_CA | CommonUsage.STORAGE) ? 1 : 0,                            // storage ^ sampled
			            hasFlag(usage, CommonUsage.COPY_SRC) && !hasAllFlags(MemoryAccess.READ_ONLY, access) ? 1 : 0,      // transfer src ==> read_only
			            hasFlag(usage, CommonUsage.COPY_DST) && !hasAllFlags(MemoryAccess.WRITE_ONLY, access) ? 1 : 0,
			            hasFlag(usage, CommonUsage.INDIRECT_OR_INPUT) && !hasAnyFlags(usage, CommonUsage.IB_OR_CA | CommonUsage.VB_OR_DS) ? 1 : 0, // input needs to specify color or ds                                                                    // transfer dst ==> write_only
			            hasAllFlags(usage, CommonUsage.COPY_SRC | CommonUsage.COPY_DST) ? 1 : 0,                                                    // both src and dst
			        );
			        res = !conflicts.Contains(1);//!(*std.max_element(std.begin(conflicts), std.end(conflicts)));
			    }
			    return res;
			}
			 static AccessFlags getAccessFlagsImpl(
			    BufferUsage usage, MemoryUsage memUsage,
			    MemoryAccess access,
			    ShaderStageFlags visibility) {
			    AccessFlags flags = AccessFlags.NONE;
			    CommonUsage cmnUsage = bufferUsageToCommonUsage(usage);
			    if (validateAccess(ResourceType.BUFFER, cmnUsage, access, visibility)) {
			        uint32 info = 0xFFFFFFFF;
			        info &= ((OPERABLE(access) << ACCESS_TYPE_BIT_POS) | IGNORE_MEMACCESS);
			        info &= ((OPERABLE(memUsage) << MEM_TYPE_BIT_POS) | IGNORE_MEMUSAGE);
			        info &= ((OPERABLE(ResourceType.TEXTURE) << RESOURCE_TYPE_BIT_POS) | IGNORE_RESTYPE);
			        info &= ((OPERABLE(visibility) << SHADER_STAGE_BIT_POPS) | IGNORE_SHADERSTAGE);
			        info &= OPERABLE(cmnUsage) | IGNORE_CMNUSAGE;

			        for (var elem in ACCESS_MAP) {
			            uint32 testFlag = info & elem.mask;
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
			 static AccessFlags getAccessFlagsImpl(
			    TextureUsage usage,
			    MemoryAccess access,
			    ShaderStageFlags visibility) {
			    AccessFlags flags = AccessFlags.NONE;
			    CommonUsage cmnUsage = textureUsageToCommonUsage(usage);
			    if (validateAccess(ResourceType.TEXTURE, cmnUsage, access, visibility)) {
			        if (usage == gfx.TextureUsageBit.NONE) {
			            return gfx.AccessFlagBit.PRESENT;
			        }
			        uint32 info = 0xFFFFFFFF;
			        info &= ((OPERABLE(access) << ACCESS_TYPE_BIT_POS) | IGNORE_MEMACCESS);
			        info &= ((OPERABLE(MemoryUsage.DEVICE) << MEM_TYPE_BIT_POS) | IGNORE_MEMUSAGE);
			        info &= ((OPERABLE(ResourceType.TEXTURE) << RESOURCE_TYPE_BIT_POS) | IGNORE_RESTYPE);
			        info &= ((OPERABLE(visibility) << (SHADER_STAGE_BIT_POPS)) | IGNORE_SHADERSTAGE);
			        info &= OPERABLE(cmnUsage) | IGNORE_CMNUSAGE;

			        for (var elem in ACCESS_MAP) {
			            uint32 testFlag = info & elem.mask;
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

			static AccessFlags getDeviceAccessFlagsImpl(
				TextureUsage usage,
				MemoryAccess access,
				ShaderStageFlags visibility)
			{
	// Special Present Usage
				if (usage == TextureUsage.NONE)
				{
					return AccessFlags.PRESENT;
				}

	// not read or write access
				if (access == MemoryAccess.NONE)
				{
					return INVALID_ACCESS_FLAGS;
				}

	// input attachment requires color or depth stencil
				if (hasAnyFlags(usage, TextureUsage.INPUT_ATTACHMENT) &&
					!hasAnyFlags(usage, TextureUsage.COLOR_ATTACHMENT | TextureUsage.DEPTH_STENCIL_ATTACHMENT))
				{
					return INVALID_ACCESS_FLAGS;
				}

				readonly bool bWrite = hasAnyFlags(access, MemoryAccess.WRITE_ONLY);
				readonly bool bRead = hasAnyFlags(access, MemoryAccess.READ_ONLY);

				if (bWrite)
				{ // single write
					const TextureUsage writeMask =
						TextureUsage.TRANSFER_DST |
						TextureUsage.STORAGE |
						TextureUsage.COLOR_ATTACHMENT |
						TextureUsage.DEPTH_STENCIL_ATTACHMENT;

					readonly TextureUsage usage1 = usage & writeMask;
		// see https://stackoverflow.com/questions/51094594/how-to-check-if-exactly-one-bit-is-set-in-an-int
					delegate bool(uint32 bits) hasOnebit = scope (bits) =>
						{
							return bits != 0 && !(bits & (bits - 1) != 0);
						};
					if (!hasOnebit(uint32(usage1)))
					{
						return INVALID_ACCESS_FLAGS;
					}

					readonly TextureUsage readMask =
						TextureUsage.SAMPLED |
						TextureUsage.TRANSFER_SRC;

					if (hasAnyFlags(usage, readMask))
					{
						return INVALID_ACCESS_FLAGS;
					}
				}

				AccessFlags flags = AccessFlags.NONE;

				if (hasAnyFlags(usage, TextureUsage.COLOR_ATTACHMENT))
				{
					if (hasAnyFlags(visibility, ShaderStageFlags.ALL & ~ShaderStageFlags.FRAGMENT))
					{
						return INVALID_ACCESS_FLAGS;
					}
					if (bWrite)
					{
						flags |= AccessFlags.COLOR_ATTACHMENT_WRITE;
					}
					if (bRead)
					{
						flags |= AccessFlags.COLOR_ATTACHMENT_READ;
					}
					if (hasAnyFlags(usage, TextureUsage.INPUT_ATTACHMENT))
					{
						if (!bRead)
						{
							return INVALID_ACCESS_FLAGS;
						}
						flags |= AccessFlags.FRAGMENT_SHADER_READ_COLOR_INPUT_ATTACHMENT;
					}
					if (bWrite)
					{
						return flags;
					}
				} else if (hasAnyFlags(usage, TextureUsage.DEPTH_STENCIL_ATTACHMENT))
				{
					if (hasAnyFlags(visibility, ShaderStageFlags.ALL & ~ShaderStageFlags.FRAGMENT))
					{
						return INVALID_ACCESS_FLAGS;
					}
					if (bWrite)
					{
						flags |= AccessFlags.DEPTH_STENCIL_ATTACHMENT_WRITE;
					}
					if (bRead)
					{
						flags |= AccessFlags.DEPTH_STENCIL_ATTACHMENT_READ;
					}
					if (hasAnyFlags(usage, TextureUsage.INPUT_ATTACHMENT))
					{
						if (!bRead)
						{
							return INVALID_ACCESS_FLAGS;
						}
						flags |= AccessFlags.FRAGMENT_SHADER_READ_DEPTH_STENCIL_INPUT_ATTACHMENT;
					}
					if (bWrite)
					{
						return flags;
					}
				} else if (bWrite)
				{
					if (hasAnyFlags(usage, TextureUsage.SAMPLED))
					{
						return INVALID_ACCESS_FLAGS;
					}
					readonly bool bUnorderedAccess = hasAnyFlags(usage, TextureUsage.STORAGE);
					readonly bool bCopyTarget = hasAnyFlags(usage, TextureUsage.TRANSFER_DST);
					if (!(bUnorderedAccess ^ bCopyTarget))
					{
						return INVALID_ACCESS_FLAGS;
					}
					if (bCopyTarget)
					{
						if (bRead || hasAnyFlags(usage, TextureUsage.TRANSFER_SRC))
						{
							return INVALID_ACCESS_FLAGS; // both copy source and target
						}
						flags |= AccessFlags.TRANSFER_WRITE;
					} else
					{
						if (hasAnyFlags(visibility, ShaderStageFlags.VERTEX))
						{
							flags |= AccessFlags.VERTEX_SHADER_WRITE;
							if (bRead)
							{
								flags |= AccessFlags.VERTEX_SHADER_READ_TEXTURE;
							}
						} else if (hasAnyFlags(visibility, ShaderStageFlags.FRAGMENT))
						{
							flags |= AccessFlags.FRAGMENT_SHADER_WRITE;
							if (bRead)
							{
								flags |= AccessFlags.FRAGMENT_SHADER_READ_TEXTURE;
							}
						} else if (hasAnyFlags(visibility, ShaderStageFlags.COMPUTE))
						{
							flags |= AccessFlags.COMPUTE_SHADER_WRITE;
							if (bRead)
							{
								flags |= AccessFlags.COMPUTE_SHADER_READ_TEXTURE;
							}
						}
					}
					return flags;
				}

				if (bWrite)
				{
					return INVALID_ACCESS_FLAGS;
				}

	// ReadOnly
				if (hasAnyFlags(usage, TextureUsage.TRANSFER_SRC))
				{
					flags |= AccessFlags.TRANSFER_READ;
				}

				if (hasAnyFlags(usage, TextureUsage.SAMPLED | TextureUsage.STORAGE))
				{
					if (hasAnyFlags(visibility, ShaderStageFlags.VERTEX))
					{
						flags |= AccessFlags.VERTEX_SHADER_READ_TEXTURE;
					}
					if (hasAnyFlags(visibility, ShaderStageFlags.FRAGMENT))
					{
						flags |= AccessFlags.FRAGMENT_SHADER_READ_TEXTURE;
					}
					if (hasAnyFlags(visibility, ShaderStageFlags.COMPUTE))
					{
						flags |= AccessFlags.COMPUTE_SHADER_READ_TEXTURE;
					}
				}

				return flags;
			}
		}
	} // namespace gfx
} // namespace cc
