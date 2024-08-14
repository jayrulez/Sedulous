using System.Threading;
namespace Sedulous.GAL.MTL;

class ManualResetEvent
{
	private WaitEvent mEvent;

	//public ref HANDLE Handle => ref mEvent;

	//public static implicit operator int(Self self) => self.mEvent;

	public this(bool initialState)
	{
		mEvent = new .(initialState);
	}

	public ~this()
	{
		Dispose();
	}

	public void WaitOne()
	{
		mEvent.WaitFor();
	}

	public bool WaitOne(uint32 milliseconds)
	{
		return mEvent.WaitFor(milliseconds);
	}

	public void Set()
	{
		mEvent.Set(true);
	}

	public void Reset()
	{
		WaitOne();
	}

	public void Dispose()
	{
		if (mEvent != null)
		{
			delete mEvent;
			mEvent = null;
		}
	}
}