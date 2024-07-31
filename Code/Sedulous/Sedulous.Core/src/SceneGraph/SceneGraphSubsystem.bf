using System;
using System.Collections;
namespace Sedulous.Core.SceneGraph;

using internal Sedulous.Core.SceneGraph;

class SceneGraphSubsystem : Subsystem
{
	public override System.StringView Name => "SceneGraph";

	private List<Scene> mScenes = new .() ~ delete _;
	private List<Scene> mActiveScenes = new .() ~ delete _;

	private IContext.RegisteredUpdateFunctionInfo? mUpdateFunctionRegistration;

	private void OnEngineUpdate(IContext.UpdateInfo info)
	{
		info.Context.Logger.LogInformation(nameof(SceneGraphSubsystem));

		for (var scene in mActiveScenes)
		{
			scene.Update(info.Time.ElapsedTime);
		}
	}

	protected override Result<void> OnInitializing(IContext context)
	{
		mUpdateFunctionRegistration = context.RegisterUpdateFunction(.()
		{
			Priority = 1,
			Stage = .VariableUpdate,
			Function = new => OnEngineUpdate
		});
		return .Ok;
	}

	protected override void OnUnitializing(IContext context)
	{
		if(mUpdateFunctionRegistration.HasValue)
		{
			context.UnregisterUpdateFunction(mUpdateFunctionRegistration.Value);
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