using Win32.Foundation;
using Win32.System.WindowsProgramming;
using System;
namespace Win32;

class AutoResetEvent
{
	private HANDLE mEvent;

	public HANDLE Handle => mEvent;

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
		if (mEvent != 0)
		{
			CloseHandle(mEvent);
			mEvent = 0;
		}
	}

	public void WaitOne()
	{
		Win32.System.Threading.WaitForSingleObject(mEvent, INFINITE);
	}

	public void WaitOne(uint32 milliseconds)
	{
		Win32.System.Threading.WaitForSingleObject(mEvent, milliseconds);
	}

	public void Signal()
	{
		Win32.System.Threading.SetEvent(mEvent);
	}
}