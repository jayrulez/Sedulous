using System;
namespace Sedulous.Core.Resources;

typealias ResourceTypeId = char8[4];

[CRepr]
struct ResourceHeader
{
	public ResourceTypeId TypeId;
	public int32 Version;
	public int32 Size;

	public bool CheckType(ResourceTypeId type)
	{
		return TypeId == type;
	}
}