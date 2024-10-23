using System;
using System.Collections;
using Sedulous.Core;
namespace Sedulous.Core.SceneGraph;

using internal Sedulous.Core.SceneGraph;

class SceneGraphSystem
{
	private readonly IContext mContext;

	private List<Scene> mScenes = new .() ~ delete _;
	private List<Scene> mActiveScenes = new .() ~ delete _;

	private IContext.RegisteredUpdateFunctionInfo? mUpdateFunctionRegistration;

	public this(IContext context)
	{
		mContext = context;
	}

	private void OnContextUpdate(IContext.UpdateInfo info)
	{
		for (var scene in mActiveScenes)
		{
			scene.Update(info.Time.ElapsedTime);
		}
	}

	internal Result<void> Startup()
	{
		mUpdateFunctionRegistration = mContext.RegisterUpdateFunction(.()
		{
			Priority = -1,
			Stage = .VariableUpdate,
			Function = new => OnContextUpdate
		});
		return .Ok;
	}

	internal void Shutdown()
	{
		if(mUpdateFunctionRegistration.HasValue)
		{
			mContext.UnregisterUpdateFunction(mUpdateFunctionRegistration.Value);
			delete mUpdateFunctionRegistration.Value.Function;
			mUpdateFunctionRegistration = null;
		}
	}

	public Result<void> CreateScene(out Scene scene)
	{
		scene = ?;
		return .Ok;
	}

	public void DestroyScene(Scene scene)
	{
	}
}