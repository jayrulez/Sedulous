using Win32.Foundation;
using System;
using Win32.System.WindowsProgramming;
namespace Win32;

class ManualResetEvent
{
	private HANDLE mEvent;

	public ref HANDLE Handle => ref mEvent;

	public static implicit operator int(Self self) => self.mEvent;

	public this(bool initialState)
	{
		mEvent = Win32.System.Threading.CreateEvent(null, FALSE, (.)(initialState ? TRUE : FALSE), null);
		if (mEvent == 0)
		{
			Runtime.FatalError("Unable to create event.");
		}
	}

	public ~this()
	{
		Dispose();
	}

	public void WaitOne()
	{
		Win32.System.Threading.WaitForSingleObject(mEvent, INFINITE);
	}

	public bool WaitOne(uint32 milliseconds)
	{
		return Win32.System.Threading.WaitForSingleObject(mEvent, milliseconds) == .NO_ERROR;
	}

	public void Set()
	{
		Win32.System.Threading.SetEvent(mEvent);
	}

	public void Reset()
	{
		WaitOne();
	}

	public void Dispose()
	{
		if (mEvent != 0)
		{
			CloseHandle(mEvent);
			mEvent = 0;
		}
	}
}