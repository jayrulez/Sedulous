using System;
using Win32.Graphics.Direct3D;
using Win32.Graphics.Direct3D12;
namespace NRI.D3D12;


public static
{
	public const uint32 NRI_TEMP_NODE_MASK = 0x1;

	public static mixin SET_D3D_DEBUG_OBJECT_NAME(var object, StringView name)
	{
		if (object != null)
		{
			// todo sed: enable this when beef allows -> on var
			//object->SetPrivateData(WKPDID_D3DDebugObjectName, (.)name.Length, name.ToScopedNativeWChar!());
		}
	}
}