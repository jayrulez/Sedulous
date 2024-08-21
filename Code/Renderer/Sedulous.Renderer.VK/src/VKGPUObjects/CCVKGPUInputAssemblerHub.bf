using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUInputAssemblerHub
{
	public this(CCVKGPUDevice device)
	{
		_gpuDevice = device;
	}

	public void connect(CCVKGPUInputAssembler ia, CCVKGPUBufferView buffer)
	{
		_ias[buffer].Add(ia);
	}

	public void update(CCVKGPUBufferView oldBuffer, CCVKGPUBufferView newBuffer)
	{
		if (_ias.ContainsKey(oldBuffer))
		{
			var iter = _ias[oldBuffer];
			for (var ia in iter)
			{
				ia.update(oldBuffer, newBuffer);
				_ias[newBuffer].Add(ia);
			}
			_ias.Remove(oldBuffer);
		}
	}

	public void disengage(CCVKGPUBufferView buffer)
	{
		if (_ias.ContainsKey(buffer))
		{
			_ias.Remove(buffer);
		}
	}

	public void disengage(CCVKGPUInputAssembler set, CCVKGPUBufferView buffer)
	{
		if (_ias.ContainsKey(buffer))
		{
			_ias[buffer].Remove(set);
		}
	}

	private CCVKGPUDevice _gpuDevice = null;
	private Dictionary<CCVKGPUBufferView, HashSet<CCVKGPUInputAssembler>> _ias;
}