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

abstract class GraphicsObject
{
	public this(ObjectType type)
	{
		_objectType = type;
		_objectID = generateObjectID<GraphicsObject>();
	}

	[Inline] public ObjectType getObjectType() { return _objectType; }
	[Inline] public uint32 getObjectID() { return _objectID; }
	[Inline] public uint32 getTypedID() { return _typedID; }

	[Inline] public static uint32 getObjectID(GraphicsObject obj)
	{
		return obj == null ? INVALID_OBJECT_ID : obj.getObjectID();
	}

	protected static uint32 generateObjectID<T>()
	{
		static uint32 generator = 1 << 16;
		return ++generator;
	}

	protected const uint32 INVALID_OBJECT_ID = 0;
	protected ObjectType _objectType = ObjectType.UNKNOWN;
	protected uint32 _objectID = 0;

	protected uint32 _typedID = 0; // inited by sub-classes
}
