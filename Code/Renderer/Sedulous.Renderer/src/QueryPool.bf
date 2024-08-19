using System;
using System.Collections;
using System.Threading;
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

		/**
		 * QueryPool usage:
		 * Update
		 * Render
		 *  getQueryPoolResults
		 *  resetQueryPool
		 *  for each renderObject
		 *      beginQuery
		 *          drawObject
		 *      endQuery
		 *  completeQueryPool
		 */

		abstract class QueryPool : GFXObject
		{
			public this()
				: base(ObjectType.QUERY_POOL)
			{
			}

			public void initialize(in QueryPoolInfo info)
			{
				_type = info.type;
				_maxQueryObjects = info.maxQueryObjects;
				_forceWait = info.forceWait;

				doInit(info);
			}
			public void destroy()
			{
				doDestroy();

				_type = QueryType.OCCLUSION;
				_maxQueryObjects = 0;
			}

			[Inline] public bool hasResult(uint32 id) { return _results.ContainsKey(id); }
			[Inline] public uint64 getResult(uint32 id) { return _results[id]; }
			[Inline] public QueryType getType() { return _type; }
			[Inline] public uint32 getMaxQueryObjects() { return _maxQueryObjects; }
			[Inline] public bool getForceWait() { return _forceWait; }

			protected abstract void doInit(in QueryPoolInfo info);
			protected abstract void doDestroy();

			protected QueryType _type =  QueryType.OCCLUSION;
			protected uint32 _maxQueryObjects =  0;
			protected bool _forceWait =  true;
			protected Monitor _mutex;
			protected Dictionary<uint32, uint64> _results;
		}
	} // namespace gfx
} // namespace cc
