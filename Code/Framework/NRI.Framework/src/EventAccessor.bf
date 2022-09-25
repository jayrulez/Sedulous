using System;
namespace NRI.Framework;

class EventAccessor<T> where T : System.Delegate
{
	private Event<T> mEvent;

	public ~this()
	{
		mEvent.Dispose();
	}

	public void Subscribe(T handler)
	{
		mEvent.Add(handler);
	}

	public Result<void> Unsubscribe(T handler)
	{
		return mEvent.Remove(handler, true);
	}
}