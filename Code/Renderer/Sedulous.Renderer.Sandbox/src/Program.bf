using System;
using Sedulous.Renderer.SPIRV;
using Bulkan;
using Sedulous.Core;
using Sedulous.Platform;
using Sedulous.Platform.Desktop;
using System.Collections;
using System;
using static Sedulous.Core.IContext;
namespace Sedulous.Renderer.Sandbox;

/*class Program
{
	struct MyStruct{
		public int X;
	}

	public static void TakeInStruct(in MyStruct s)
	{

	}

	public static void Main()
	{
		TakeInStruct(.() {X = 0});

		String source = """
			#version 450
			precision highp float;
			layout(location = 0) in vec2 a_position;
			layout(set = 0, binding = 1) uniform MVP { mat4 u_MVP; };

			void main() {
				gl_Position = u_MVP * vec4(a_position, 0.0, 1.0);
			}
			""";

		SPIRVUtils spvUtils = scope .();
		spvUtils.initialize((int32)VulkanNative.VK_API_VERSION_MINOR(0));

		spvUtils.compileGLSL(.VERTEX, source);
		VertexAttributeList attributes = scope .();
		spvUtils.compressInputLocations(ref attributes);

		Console.WriteLine("Hello");
	}
}*/

class SandboxApplication
{
	private IContext.RegisteredUpdateFunctionInfo? mUpdateFunctionRegistration;

	private readonly IPlatformBackend mHost;

	private Device device;
	private RenderPass renderPass;
	private List<CommandBuffer> commandBuffers = new .() ~ delete _;
	private List<Swapchain> swapchains = new .() ~ delete _;
	private List<Framebuffer> fbos = new .() ~ delete _;
	private List<GeneralBarrier> _generalBarriers = new .() ~ delete _;

	private Shader             _shader                 = null;
	private Buffer             _vertexBuffer           = null;
	private Buffer             _uniformBuffer          = null;
	private Buffer             _uniformBufferMVP       = null;
	private DescriptorSet      _descriptorSet          = null;
	private DescriptorSetLayout _descriptorSetLayout    = null;
	private PipelineLayout     _pipelineLayout         = null;
	private PipelineState      _pipelineState          = null;
	private PipelineState      _invisiblePipelineState = null;
	private InputAssembler     _inputAssembler         = null;
	private Buffer             _indirectBuffer         = null;
	private Buffer             _indexBuffer            = null;

	private const bool MANUAL_BARRIER = false;
	private uint32 _frameCount = 0;

	public this(IPlatformBackend host)
	{
		mHost = host;
	}


	private void createShader()
	{
		String vsCode = """
precision highp float;
layout(location = 0) in vec2 a_position;
layout(set = 0, binding = 1) uniform MVP { mat4 u_MVP; };

void main() {
    gl_Position = u_MVP * vec4(a_position, 0.0, 1.0);
}
""";

		String psCode = """
precision highp float;
layout(set = 0, binding = 0) uniform Color {
    vec4 u_color;
};
layout(location = 0) out vec4 o_color;

void main() {
    o_color = u_color;
}
""";

		ShaderInfo shaderInfo = .();
		shaderInfo.name = "Basic Triangle";
		shaderInfo.stages = new .()
			{
				.()
					{
						stage = .VERTEX,
						source = vsCode
					},
				.()
					{
						stage = .FRAGMENT,
						source = psCode
					}
			};
		shaderInfo.attributes = new .()
			{
				.()
					{
						name = "a_position",
						format = .RG32F,
						isNormalized = false,
						stream = 0,
						isInstanced = false,
						location = 0
					}
			};
		shaderInfo.blocks = new .()
			{
				.()
					{
						set = 0, binding = 0, name = "Color", members = new .()
							{
								.()
									{
										name = "u_color", type = .FLOAT4, count = 1
									}
							}, count = 1
					},
				.()
					{
						set = 0, binding = 1, name = "MVP", members = new .()
							{
								.()
									{
										name = "u_MVP", type = .MAT4, count = 1
									}
							}, count = 1
					}
			};

		_shader = device.createShader(shaderInfo);
	}

	private uint32 getUBOSize(uint32 stride)
	{
		uint32 alignment = device.getCapabilities().uboOffsetAlignment;
		return (stride + alignment - 1) / alignment * alignment;
	}

	private void createVertexBuffer()
	{
		float[?] vertexData = .(-0.5F, 0.5F,
			-0.5F, -0.5F,
			0.5F, -0.5F,
			0.0F, 0.5F,
			0.5F, 0.5F);

		BufferInfo vertexBufferInfo = .()
			{
				usage = BufferUsage.VERTEX,
				memUsage = MemoryUsage.DEVICE,
				size = sizeof(decltype(vertexData)),
				stride = 2 * sizeof(float),
				flags = BufferFlagBit.NONE
			};

		_vertexBuffer = device.createBuffer(vertexBufferInfo);
		_vertexBuffer.update(&vertexData, sizeof(decltype(vertexData)));

		BufferInfo uniformBufferInfo = .()
			{
				usage = BufferUsage.UNIFORM,
				memUsage = MemoryUsage.DEVICE | MemoryUsage.HOST,
				size = getUBOSize(sizeof(Color))
			};
		_uniformBuffer = device.createBuffer(uniformBufferInfo);

		BufferInfo uniformBufferMVPInfo = .()
			{
				usage = BufferUsage.UNIFORM,
				memUsage = MemoryUsage.DEVICE | MemoryUsage.HOST,
				size = getUBOSize(sizeof(Sedulous.Foundation.Mathematics.Matrix))
			};
		_uniformBufferMVP = device.createBuffer(uniformBufferMVPInfo);

		uint16[?]        indices       = .(1, 3, 0, 1, 2, 3, 2, 4, 3);
		BufferInfo indexBufferInfo = .()
			{
				usage = BufferUsageBit.INDEX,
				memUsage = MemoryUsage.DEVICE,
				size = sizeof(decltype(indices)),
				stride = sizeof(uint16)
			};
		_indexBuffer = device.createBuffer(indexBufferInfo);
		_indexBuffer.update(&indices, sizeof(decltype(indices)));

		DrawInfo drawInfo;
		drawInfo.firstIndex = 3;
		drawInfo.indexCount = 3;

		BufferInfo indirectBufferInfo = .()
			{
				usage = BufferUsageBit.INDIRECT,
				memUsage = MemoryUsage.DEVICE,
				size = sizeof(DrawInfo),
				stride = sizeof(DrawInfo)
			};
		_indirectBuffer = device.createBuffer(indirectBufferInfo);
		_indirectBuffer.update(&drawInfo, sizeof(DrawInfo));
	}

	private void createInputAssembler()
	{
		VertexAttribute          position = .() { name = "a_position", format = .RG32F, isNormalized = false, stream = 0, isInstanced = false };
		InputAssemblerInfo inputAssemblerInfo = .();
		inputAssemblerInfo.attributes.Add(position);
		inputAssemblerInfo.vertexBuffers.Add(_vertexBuffer);
		inputAssemblerInfo.indexBuffer    = _indexBuffer;
		inputAssemblerInfo.indirectBuffer = _indirectBuffer;
		_inputAssembler                   = device.createInputAssembler(inputAssemblerInfo);
	}

	private void createPipeline()
	{
		DescriptorSetLayoutInfo dslInfo = .();
		dslInfo.bindings.Add(.() { binding = 0, descriptorType = DescriptorType.UNIFORM_BUFFER, count = 1, stageFlags = ShaderStageFlagBit.FRAGMENT });
		dslInfo.bindings.Add(.() { binding = 1, descriptorType = DescriptorType.UNIFORM_BUFFER, count = 1, stageFlags = ShaderStageFlagBit.VERTEX });
		_descriptorSetLayout = device.createDescriptorSetLayout(dslInfo);

		_pipelineLayout = device.createPipelineLayout(.() { setLayouts = new .() { _descriptorSetLayout } });

		_descriptorSet = device.createDescriptorSet(.() { layout = _descriptorSetLayout });

		_descriptorSet.bindBuffer(0, _uniformBuffer);
		_descriptorSet.bindBuffer(1, _uniformBufferMVP);
		_descriptorSet.update();

		PipelineStateInfo pipelineInfo = .();
		pipelineInfo.primitive      = PrimitiveMode.TRIANGLE_LIST;
		pipelineInfo.shader         = _shader;
		pipelineInfo.inputState     = .() { attributes = _inputAssembler.getAttributes() };
		pipelineInfo.renderPass     = renderPass;
		pipelineInfo.pipelineLayout = _pipelineLayout;

		_pipelineState = device.createPipelineState(pipelineInfo);

		pipelineInfo.blendState.targets[0].blendColorMask = ColorMask.NONE;

		_invisiblePipelineState = device.createPipelineState(pipelineInfo);

		_generalBarriers.Add(device.getGeneralBarrier(.()
			{
				prevAccesses = AccessFlagBit.TRANSFER_WRITE,
				nextAccesses = AccessFlagBit.VERTEX_SHADER_READ_UNIFORM_BUFFER |
					AccessFlagBit.FRAGMENT_SHADER_READ_UNIFORM_BUFFER |
					AccessFlagBit.INDIRECT_BUFFER |
					AccessFlagBit.VERTEX_BUFFER |
					AccessFlagBit.INDEX_BUFFER
			}));

		_generalBarriers.Add(device.getGeneralBarrier(.()
			{
				prevAccesses = AccessFlagBit.TRANSFER_WRITE,
				nextAccesses = AccessFlagBit.VERTEX_SHADER_READ_UNIFORM_BUFFER |
					AccessFlagBit.FRAGMENT_SHADER_READ_UNIFORM_BUFFER
			}));
	}


	public Result<void> Initializing(ContextInitializer initializer)
	{
		return .Ok;
	}

	public void Initialized(IContext context)
	{
		mUpdateFunctionRegistration = context.RegisterUpdateFunction(.()
			{
				Priority = 1,
				Function = new  => Update,
				Stage = .FixedUpdate
			});


		createShader();
		createVertexBuffer();
		createInputAssembler();
		createPipeline();
	}

	public void ShuttingDown(IContext context)
	{
		if (mUpdateFunctionRegistration.HasValue)
		{
			context.UnregisterUpdateFunction(mUpdateFunctionRegistration.Value);
			delete mUpdateFunctionRegistration.Value.Function;
			mUpdateFunctionRegistration = null;
		}
	}

	private void Update(UpdateInfo info)
	{
		info.Context.Logger.LogInformation(scope $"{info.Time.ElapsedTime} : Application Update");

		if (mHost.Input.GetKeyboard().IsKeyPressed(.Escape))
		{
			mHost.Exit();
		}


		var swapchain = swapchains[0];
		var fbo       = fbos[0];

		uint32 generalBarrierIdx = _frameCount != 0 ? 1 : 0;

		Color clearColor = .() { x = 1.0F, y = 0, z = 0, w = 1.0F };

		Color uniformColor = .();
		uniformColor.x = Math.Abs(Math.Sin((float)info.Time.ElapsedTime.TotalSeconds));
		uniformColor.y = 1.0F;
		uniformColor.z = 0.0F;
		uniformColor.w = 1.0F;

		Sedulous.Foundation.Mathematics.Matrix mvp = .Identity;
		mvp = Sedulous.Foundation.Mathematics.Matrix.CreateOrthographicOffCenter(-1, 1, -1, 1, -1, 1);

		device.acquire(&swapchain, 1);

		_uniformBuffer.update(&uniformColor, sizeof(decltype(uniformColor)));
		_uniformBufferMVP.update(&mvp, sizeof(decltype(mvp)));

		Rect renderArea = .() { x = 0, y = 0, width = swapchain.getWidth(), height = swapchain.getHeight() };

		var commandBuffer = commandBuffers[0];
		commandBuffer.begin();

		if (MANUAL_BARRIER)
		{
			commandBuffer.pipelineBarrier(_generalBarriers[generalBarrierIdx]);
		}

		commandBuffer.beginRenderPass(fbo.getRenderPass(), fbo, renderArea, &clearColor, 1.0F, 0);
		commandBuffer.bindPipelineState(_pipelineState);
		commandBuffer.bindInputAssembler(_inputAssembler);
		commandBuffer.bindDescriptorSet(0, _descriptorSet);
		commandBuffer.draw(_inputAssembler);
		commandBuffer.endRenderPass();

		commandBuffer.end();

		device.flushCommands(commandBuffers);
		device.getQueue().submit(commandBuffers);
		device.present();

		_frameCount++;
	}
}

class Program
{
	static void Main()
	{
		var host = scope DesktopPlatformBackend(.()
			{
				PrimaryWindowConfiguration = .()
					{
						Title = "Sandbox"
					}
			});
		/*
		host.Input.GetKeyboard().KeyPressed.Subscribe(new (window, kb, key, ctrl, alt, shift, @repeat) =>
			{
				if (key == .Escape)
					host.Exit();
			});
		*/

		var app = scope SandboxApplication(host);

		host.Run(
			initializingCallback: scope => app.Initializing,
			initializedCallback: scope => app.Initialized,
			shuttingDownCallback: scope => app.ShuttingDown
			);
	}
}