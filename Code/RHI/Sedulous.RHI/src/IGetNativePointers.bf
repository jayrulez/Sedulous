using System;
using System.Collections;

namespace Sedulous.RHI;

/// <summary>
/// Interface that represents an object that could provide some native pointers.
/// </summary>
public interface IGetNativePointers
{
	/// <summary>
	/// Gets a list of all available keys to obtain native pointers.
	/// </summary>
	void GetAvailablePointerKeys(List<String> pointerKeys);

	/// <summary>
	/// Obtain a native pointer of this graphics context using the given key.
	/// </summary>
	/// <param name="pointerKey">The pointer key.</param>
	/// <param name="nativePointer">The native pointer.</param>
	/// <returns>True if there are an available pointer with this key.</returns>
	bool GetNativePointer(String pointerKey, out void* nativePointer);
}
