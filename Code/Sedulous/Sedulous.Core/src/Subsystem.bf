using System;
namespace Sedulous.Core;

abstract class Subsystem
{
	private IContext mContext = null;
	private bool mInitialized = false;

	public abstract StringView Name { get; }

	internal Result<void> Initialize(IContext context)
	{
		if (mInitialized)
			return .Ok;

		mContext = context;
		return OnInitializing(mContext);
	}

	internal void Initialized(Context context)
	{
		OnInitialized(context);
	}

	protected virtual Result<void> OnInitializing(IContext context)
	{
		return .Ok;
	}

	protected virtual void OnInitialized(Context context) {}

	internal void Uninitialize()
	{
		if (!mInitialized)
			return;

		OnUnitializing(mContext);

		mInitialized = false;
		mContext = null;
	}

	protected virtual void OnUnitializing(IContext context) { }
}