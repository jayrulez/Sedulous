using System.Collections;
using System;
namespace Sedulous.RAL;

abstract class ShaderProgram : QueryInterface
{
	public abstract bool HasShader(ShaderType type);
	public abstract Shader GetShader(ShaderType type);
	public abstract readonly ref List<Shader> GetShaders();
	public abstract readonly ref List<BindKey> GetBindings();
	public abstract readonly ref List<EntryPoint> GetEntryPoints();
}

public class ShaderProgramBase : ShaderProgram
{
	private Dictionary<ShaderType, Shader> m_shaders_by_type = new .() ~ delete _;
	private List<Shader> m_shaders = new .() ~ delete _;
	private List<BindKey> m_bindings = new .() ~ delete _;
	private List<EntryPoint> m_entry_points = new .() ~ delete _;

	public this(Span<Shader> shaders)
	{
		m_shaders.AddRange(shaders);

		for (var shader in m_shaders)
		{
			m_shaders_by_type[shader.GetShaderType()] = shader;
			readonly ref List<BindKey> bindings = ref shader.GetBindings();
			m_bindings.Insert(0, bindings);

			readonly ref ShaderReflection reflection = ref shader.GetReflection();
			readonly ref List<EntryPoint> shader_entry_points = ref reflection.GetEntryPoints();
			m_entry_points.AddRange(shader_entry_points);
		}
	}

	public override bool HasShader(ShaderType type)
	{
		return m_shaders_by_type.ContainsKey(type);
	}

	public override Shader GetShader(ShaderType type)
	{
		if (m_shaders_by_type.ContainsKey(type))
		{
			return m_shaders_by_type[type];
		}
		return null;
	}

	public override ref List<Shader> GetShaders()
	{
		return ref m_shaders;
	}

	public override ref List<BindKey> GetBindings()
	{
		return ref m_bindings;
	}

	public override ref List<EntryPoint> GetEntryPoints()
	{
		return ref m_entry_points;
	}
}