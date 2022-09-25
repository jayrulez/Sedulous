namespace NRI;

enum Message
{
	TYPE_INFO,
	TYPE_WARNING,
	TYPE_ERROR,

	MAX_NUM,
}

enum PhysicalDeviceType
{
	UNKNOWN,
	INTEGRATED,
	DISCRETE,

	MAX_NUM
}

struct MemoryAllocatorInterface
{
	public function void*(void* userArg, uint size, uint alignment) Allocate;
	public function void*(void* userArg, void* memory, uint size, uint alignment) Reallocate;
	public function void(void* userArg, void* memory) Free;
	public void* userArg;
}

struct CallbackInterface
{
	public function void(void* userArg, char8* message, Message messageType) MessageCallback;
	public function void(void* userArg) AbortExecution;
	public void* userArg;
}

struct DisplayDesc
{
	public int32 originLeft;
	public int32 originTop;
	public uint32 width;
	public uint32 height;
}

struct PhysicalDeviceGroup
{
	public char8[128] description;
	public uint64 luid;
	public uint64 dedicatedVideoMemoryMB;
	public PhysicalDeviceType type;
	public Vendor vendor;
	public uint32 deviceID;
	public uint32 physicalDeviceGroupSize;
	public /*const*/ DisplayDesc* displays;
	public uint32 displayNum;
}

struct VulkanExtensions
{
	public /*const*/ char8** /*const**/ instanceExtensions;
	public uint32 instanceExtensionNum;
	public /*const*/ char8** /*const**/ deviceExtensions;
	public uint32 deviceExtensionNum;
}

struct DeviceCreationDesc
{
	public /*const*/ PhysicalDeviceGroup* physicalDeviceGroup;
	public CallbackInterface callbackInterface;
	public MemoryAllocatorInterface memoryAllocatorInterface;
	public GraphicsAPI graphicsAPI;
	public SPIRVBindingOffsets spirvBindingOffsets;
	public VulkanExtensions vulkanExtensions;
	public bool enableNRIValidation; // : 1;
	public bool enableAPIValidation; // : 1;
	public bool enableMGPU; // : 1;
	public bool D3D11CommandBufferEmulation; // : 1;
}