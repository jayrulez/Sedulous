using System.Collections;
using System;
namespace Sedulous.RAL;

abstract class Shader : QueryInterface
{
	public abstract ShaderType GetShaderType();
	public abstract readonly ref List<uint8> GetBlob();
	public abstract uint64 GetId(in String entry_point);
	public abstract readonly ref BindKey GetBindKey(in String name);
	public abstract readonly ref List<ResourceBindingDesc> GetResourceBindings();
	public abstract readonly ref ResourceBindingDesc GetResourceBinding(in BindKey bind_key);
	public abstract readonly ref List<InputLayoutDesc> GetInputLayouts();
	public abstract uint32 GetInputLayoutLocation(in String semantic_name);
	public abstract readonly ref List<BindKey> GetBindings();
	public abstract readonly ref ShaderReflection GetReflection();


	public static extern void Compile(in ShaderDesc shader, ShaderBlobType blob_type, List<uint8> byteCode);

	public static extern void GetMSLShader(Span<uint8> blob, Dictionary<String, uint32> mapping, String mslShader);
	public static extern void GetMSLShader(in ShaderDesc shader, Dictionary<String, uint32> mapping, String mslShader);

	public static extern void CreateShaderReflection(ShaderBlobType type, void* data, uint size, out ShaderReflection shaderReflection);
	public static extern void DestroyReflection(ref ShaderReflection shaderReflection);
}

public class ShaderBase : Shader
{
	private static uint64 GenerateId()
	{
		static uint64 id = 0;
		return ++id;
	}

	private List<uint8> m_blob = new .() ~ delete _;
	private ShaderBlobType m_blob_type;
	private ShaderType m_shader_type;
	private Dictionary<String, uint64> m_ids = new .() ~ delete _;
	private List<ResourceBindingDesc> m_bindings = null; //new .() ~ delete _;
	private List<BindKey> m_binding_keys = new .() ~ delete _;
	private Dictionary<BindKey, uint> m_mapping = new .() ~ delete _;
	private Dictionary<String, BindKey> m_bind_keys = new .() ~ delete _;
	private List<InputLayoutDesc> m_input_layout_descs = new .() ~ delete _;
	private Dictionary<String, uint32> m_locations = new .() ~ delete _;
	private ShaderReflection m_reflection = null;
	private Dictionary<String, uint32> m_slot_remapping = new .() ~ delete _;
	private String m_msl_source = new .() ~ delete _;

	public this(in ShaderDesc desc, ShaderBlobType blob_type, bool is_msl)
		: this(Shader.Compile(desc, blob_type, .. scope .()), blob_type, desc.type, is_msl)
	{
	}

	public this(Span<uint8> blob, ShaderBlobType blob_type, ShaderType shader_type, bool is_msl)
	{
		m_blob.AddRange(blob);
		m_blob_type = blob_type;
		m_shader_type = shader_type;

		if (is_msl)
		{
			m_msl_source.Set(Shader.GetMSLShader(m_blob, m_slot_remapping, .. scope .()));
		}
		m_reflection = Shader.CreateShaderReflection(blob_type, m_blob.Ptr, (uint)m_blob.Count, .. ?);
		m_bindings = m_reflection.GetBindings();
		for (uint32 i = 0; i < m_bindings.Count; ++i)
		{
			uint32 remapped_slot = ~0;
			if (is_msl)
			{
				remapped_slot = m_slot_remapping[m_bindings[i].name];
			}
			BindKey bind_key = .()
				{
					shader_type = m_shader_type,
					view_type = m_bindings[i].type,
					slot = m_bindings[i].slot,
					space = m_bindings[i].space,
					count = m_bindings[i].count,
					remapped_slot = remapped_slot
				};
			m_bind_keys[m_bindings[i].name] = bind_key;
			m_mapping[bind_key] = i;
			m_binding_keys.Add(bind_key);
		}

		readonly ref List<InputParameterDesc> input_parameters = ref m_reflection.GetInputParameters();
		for (uint32 i = 0; i < input_parameters.Count; ++i)
		{
			InputLayoutDesc layout = .()
				{
					slot = i,
					semantic_name = input_parameters[i].semantic_name,
					format = input_parameters[i].format,
					stride = input_parameters[i].format.GetBytesPerPixel()
				};
			m_input_layout_descs.Add(layout);
			m_locations[input_parameters[i].semantic_name] = input_parameters[i].location;
		}

		for (var entry_point in m_reflection.GetEntryPoints())
		{
			m_ids.Add(entry_point.name, GenerateId());
		}
	}

	public ~this()
	{
		Shader.DestroyReflection(ref m_reflection);
	}

	public override ShaderType GetShaderType()
	{
		return m_shader_type;
	}

	public override ref List<uint8> GetBlob()
	{
		return ref m_blob;
	}

	public override uint64 GetId(in String entry_point)
	{
		if (m_ids.ContainsKey(entry_point))
			return m_ids[entry_point];
		return default;
	}

	public override ref BindKey GetBindKey(in String name)
	{
		return ref m_bind_keys[name];
	}

	public override ref List<ResourceBindingDesc> GetResourceBindings()
	{
		return ref m_bindings;
	}

	public override ref ResourceBindingDesc GetResourceBinding(in BindKey bind_key)
	{
		return ref m_bindings[(int)m_mapping[bind_key]];
	}

	public override ref List<InputLayoutDesc> GetInputLayouts()
	{
		return ref m_input_layout_descs;
	}

	public override uint32 GetInputLayoutLocation(in String semantic_name)
	{
		return m_locations[semantic_name];
	}

	public override ref List<BindKey> GetBindings()
	{
		return ref m_binding_keys;
	}

	public override ref ShaderReflection GetReflection()
	{
		return ref m_reflection;
	}
}