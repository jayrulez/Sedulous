using System.Collections;
namespace Sedulous.RAL;

abstract class ShaderReflection : QueryInterface
{
	public abstract readonly ref List<EntryPoint> GetEntryPoints();
	public abstract readonly ref List<ResourceBindingDesc> GetBindings();
	public abstract readonly ref List<VariableLayout> GetVariableLayouts();
	public abstract readonly ref List<InputParameterDesc> GetInputParameters();
	public abstract readonly ref List<OutputParameterDesc> GetOutputParameters();
	public abstract readonly ref ShaderFeatureInfo GetShaderFeatureInfo();
}