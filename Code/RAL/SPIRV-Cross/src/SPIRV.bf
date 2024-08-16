namespace SPIRV_Cross
{
	public typealias spvc_msl_shader_input = spvc_msl_shader_interface_var_2;
	public typealias spvc_msl_vertex_format = spvc_msl_shader_variable_format;
	extension SPIRV
	{
		public static uint32 make_msl_version(uint32 major, uint32 minor = 0, uint32 patch = 0)
		{
			return (major * 10000) + (minor * 100) + patch;
		}
	}
}