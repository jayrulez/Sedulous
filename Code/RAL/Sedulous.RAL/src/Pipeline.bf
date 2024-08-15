using System.Collections;
namespace Sedulous.RAL;

abstract class Pipeline : QueryInterface
{
	public abstract PipelineType GetPipelineType();
	public abstract void GetRayTracingShaderGroupHandles(uint32 first_group, uint32 group_count, List<uint8> handles);
}