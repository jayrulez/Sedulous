using System;
using System.Collections;
namespace Sedulous.RAL;

abstract class CommandList : QueryInterface
{
	public abstract void Reset();
	public abstract void Close();
	public abstract void BindPipeline(Pipeline state);
	public abstract void BindBindingSet(BindingSet binding_set);
	public abstract void BeginRenderPass(RenderPass render_pass,
		Framebuffer framebuffer,
		in ClearDesc clear_desc);
	public abstract void EndRenderPass();
	public abstract void BeginEvent(String name);
	public abstract void EndEvent();
	public abstract void Draw(uint32 vertex_count,
		uint32 instance_count,
		uint32 first_vertex,
		uint32 first_instance);
	public abstract void DrawIndexed(uint32 index_count,
		uint32 instance_count,
		uint32 first_index,
		int32 vertex_offset,
		uint32 first_instance);
	public abstract void DrawIndirect(Resource argument_buffer, uint64 argument_buffer_offset);
	public abstract void DrawIndexedIndirect(Resource argument_buffer,
		uint64 argument_buffer_offset);
	public abstract void DrawIndirectCount(Resource argument_buffer,
		uint64 argument_buffer_offset,
		Resource count_buffer,
		uint64 count_buffer_offset,
		uint32 max_draw_count,
		uint32 stride);
	public abstract void DrawIndexedIndirectCount(Resource argument_buffer,
		uint64 argument_buffer_offset,
		Resource count_buffer,
		uint64 count_buffer_offset,
		uint32 max_draw_count,
		uint32 stride);
	public abstract void Dispatch(uint32 thread_group_count_x,
		uint32 thread_group_count_y,
		uint32 thread_group_count_z);
	public abstract void DispatchIndirect(Resource argument_buffer,
		uint64 argument_buffer_offset);
	public abstract void DispatchMesh(uint32 thread_group_count_x);
	public abstract void DispatchRays(in RayTracingShaderTables shader_tables,
		uint32 width,
		uint32 height,
		uint32 depth);
	public abstract void ResourceBarrier(Span<ResourceBarrierDesc> barriers);
	public abstract void UAVResourceBarrier(Resource resource);
	public abstract void SetViewport(float x, float y, float width, float height);
	public abstract void SetScissorRect(int32 left, int32 top, uint32 right, uint32 bottom);
	public abstract void IASetIndexBuffer(Resource resource, Format format);
	public abstract void IASetVertexBuffer(uint32 slot, Resource resource);
	public abstract void RSSetShadingRate(ShadingRate shading_rate, ShadingRateCombiner[2] combiners);
	public abstract void BuildBottomLevelAS(Resource src,
		Resource dst,
		Resource scratch,
		uint64 scratch_offset,
		Span<RaytracingGeometryDesc> descs,
		BuildAccelerationStructureFlags flags);
	public abstract void BuildTopLevelAS(Resource src,
		Resource dst,
		Resource scratch,
		uint64 scratch_offset,
		Resource instance_data,
		uint64 instance_offset,
		uint32 instance_count,
		BuildAccelerationStructureFlags flags);
	public abstract void CopyAccelerationStructure(Resource src,
		Resource dst,
		CopyAccelerationStructureMode mode);
	public abstract void CopyBuffer(Resource src_buffer,
		Resource dst_buffer,
		Span<BufferCopyRegion> regions);
	public abstract void CopyBufferToTexture(Resource src_buffer,
		Resource dst_texture,
		Span<BufferToTextureCopyRegion> regions);
	public abstract void CopyTexture(Resource src_texture,
		Resource dst_texture,
		Span<TextureCopyRegion> regions);
	public abstract void WriteAccelerationStructuresProperties(
		in List<Resource> acceleration_structures,
		QueryHeap query_heap,
		uint32 first_query);
	public abstract void ResolveQueryData(QueryHeap query_heap,
		uint32 first_query,
		uint32 query_count,
		Resource dst_buffer,
		uint64 dst_offset);
}