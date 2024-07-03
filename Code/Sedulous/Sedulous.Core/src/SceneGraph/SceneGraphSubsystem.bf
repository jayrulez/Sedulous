using System;
using System.Collections;
namespace Sedulous.Core.SceneGraph;

using internal Sedulous.Core.SceneGraph;

class SceneGraphSubsystem : Subsystem
{
	public override System.StringView Name => "SceneGraph";

	private List<Scene> mScenes = new .() ~ delete _;
	private List<Scene> mActiveScenes = new .() ~ delete _;

	private readonly IContext.UpdateFunctionInfo mOnEngineUpdateInfo = .()
		{
			Priority = 1,
			Stage = .VariableUpdate,
			Function = new => OnEngineUpdate
		} ~ delete _.Function;

	private void OnEngineUpdate(IContext.UpdateInfo info)
	{
		info.Context.Logger.LogInformation(nameof(SceneGraphSubsystem));

		for (var scene in mActiveScenes)
		{
			scene.Update(info.Time.ElapsedTime);
		}
	}

	protected override Result<void> OnInitializing(IContext engine)
	{
		engine.RegisterUpdateFunction(mOnEngineUpdateInfo);
		return .Ok;
	}

	protected override void OnUnitializing(IContext engine)
	{
		engine.UnregisterUpdateFunction(mOnEngineUpdateInfo);
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