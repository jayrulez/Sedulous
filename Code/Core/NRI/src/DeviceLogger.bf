using System;
using System;
namespace NRI;

sealed class DeviceLogger
{
	private GraphicsAPI m_GraphicsAPI;
	private CallbackInterface m_CallbackInterface;

	private const char8*[uint32(Message.TYPE_ERROR) + 1] MESSAGE_TYPE_NAME = .(
		"INFO",
    	"WARNING",
    	"ERROR"
	);

	private const char8*[uint32(GraphicsAPI.VULKAN) + 1] GRAPHICS_API_NAME = .(
		"D3D11",
		"D3D12",
		"VULKAN"
	);

	public this(GraphicsAPI graphicsAPI, CallbackInterface callbackInterface)
	{
		m_GraphicsAPI = graphicsAPI;
		m_CallbackInterface = callbackInterface;
	}

	public void ReportMessage(Message message, StringView format, params Object[] args)
	{
		char8* messageTypeName = MESSAGE_TYPE_NAME[(uint)message];
		char8* graphicsAPIName = GRAPHICS_API_NAME[(uint)m_GraphicsAPI];

		String buffer = scope .();

		buffer.AppendF("[NRI({0}).{1}] -- ", graphicsAPIName, messageTypeName);

		buffer.AppendF(format, params args);

		if (m_CallbackInterface.MessageCallback != null)
			m_CallbackInterface.MessageCallback(m_CallbackInterface.userArg, buffer, message);

		if (message == Message.TYPE_ERROR && m_CallbackInterface.AbortExecution != null)
			m_CallbackInterface.AbortExecution(m_CallbackInterface.userArg);
	}
}