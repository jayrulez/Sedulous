namespace OpenALNative;

static
{
/*
	/* Deprecated macros. */
#define ALCAPI                                   ALC_API
#define ALCAPIENTRY                              ALC_APIENTRY
#define ALC_INVALID                              0

	/** Supported ALC version? */
#define ALC_VERSION_0_1                          1
	*/
}

/** Opaque device handle */
struct ALCdevice;

/** Opaque context handle */
struct ALCcontext;

/** 8-bit boolean */
typealias ALCboolean = int8;

/** character */
typealias ALCchar = char8;

/** signed 8-bit integer */
typealias ALCbyte = int8;

/** unsigned 8-bit integer */
typealias ALCubyte = uint8;

/** signed 16-bit integer */
typealias ALCshort = int16;

/** unsigned 16-bit integer */
typealias ALCushort = uint16;

/** signed 32-bit integer */
typealias ALCint = int32;

/** unsigned 32-bit integer */
typealias ALCuint = uint32;

/** non-negative 32-bit integer size */
typealias ALCsizei = int32;

/** 32-bit enumeration value */
typealias ALCenum = int32;

/** 32-bit IEEE-754 floating-point */
typealias ALCfloat = float;

/** 64-bit IEEE-754 floating-point */
typealias ALCdouble = double;

/** void type (for opaque pointers only) */
typealias ALCvoid = void;


static
{
	/* Enumeration values begin at column 50. Do not use tabs. */

	/** Boolean False. */
public const uint32 ALC_FALSE                                = 0;

	/** Boolean True. */
public const uint32 ALC_TRUE                                 = 1;

	/** Context attribute: <int> Hz. */
public const uint32 ALC_FREQUENCY                            = 0x1007;

	/** Context attribute: <int> Hz. */
public const uint32 ALC_REFRESH                              = 0x1008;

	/** Context attribute: AL_TRUE or AL_FALSE synchronous context? */
public const uint32 ALC_SYNC                                 = 0x1009;

	/** Context attribute: <int> requested Mono (3D) Sources. */
public const uint32 ALC_MONO_SOURCES                         = 0x1010;

	/** Context attribute: <int> requested Stereo Sources. */
public const uint32 ALC_STEREO_SOURCES                       = 0x1011;

	/** No error. */
public const uint32 ALC_NO_ERROR                             = 0;

	/** Invalid device handle. */
public const uint32 ALC_INVALID_DEVICE                       = 0xA001;

	/** Invalid context handle. */
public const uint32 ALC_INVALID_CONTEXT                      = 0xA002;

	/** Invalid enumeration passed to an ALC call. */
public const uint32 ALC_INVALID_ENUM                         = 0xA003;

	/** Invalid value passed to an ALC call. */
public const uint32 ALC_INVALID_VALUE                        = 0xA004;

	/** Out of memory. */
public const uint32 ALC_OUT_OF_MEMORY                        = 0xA005;


	/** Runtime ALC major version. */
public const uint32 ALC_MAJOR_VERSION                        = 0x1000;
	/** Runtime ALC minor version. */
public const uint32 ALC_MINOR_VERSION                        = 0x1001;

	/** Context attribute list size. */
public const uint32 ALC_ATTRIBUTES_SIZE                      = 0x1002;
	/** Context attribute list properties. */
public const uint32 ALC_ALL_ATTRIBUTES                       = 0x1003;

	/** String for the default device specifier. */
public const uint32 ALC_DEFAULT_DEVICE_SPECIFIER             = 0x1004;
	/**
	 * Device specifier string.
	 *
	 * If device handle is NULL, it is instead a null-character separated list of
	 * strings of known device specifiers (list ends with an empty string).
	 */
public const uint32 ALC_DEVICE_SPECIFIER                     = 0x1005;
	/** String for space-separated list of ALC extensions. */
public const uint32 ALC_EXTENSIONS                           = 0x1006;


	/** Capture extension */
public const uint32 ALC_EXT_CAPTURE = 1;
	/**
	 * Capture device specifier string.
	 *
	 * If device handle is NULL, it is instead a null-character separated list of
	 * strings of known capture device specifiers (list ends with an empty string).
	 */
public const uint32 ALC_CAPTURE_DEVICE_SPECIFIER             = 0x310;
	/** String for the default capture device specifier. */
public const uint32 ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER     = 0x311;
	/** Number of sample frames available for capture. */
public const uint32 ALC_CAPTURE_SAMPLES                      = 0x312;


	/** Enumerate All extension */
public const uint32 ALC_ENUMERATE_ALL_EXT = 1;
	/** String for the default extended device specifier. */
public const uint32 ALC_DEFAULT_ALL_DEVICES_SPECIFIER        = 0x1012;
	/**
	 * Device's extended specifier string.
	 *
	 * If device handle is NULL, it is instead a null-character separated list of
	 * strings of known extended device specifiers (list ends with an empty string).
	 */
public const uint32 ALC_ALL_DEVICES_SPECIFIER                = 0x1013;
}

/* Context management. */
extension OpenALNative
{
	/** Create and attach a context to the given device. */
	public static ALCcontext* alcCreateContext(ALCdevice *device, ALCint *attrlist) => impl.alcCreateContext(device, attrlist);
	/**
	 * Makes the given context the active process-wide context. Passing NULL clears
	 * the active context.
	 */
	public static ALCboolean alcMakeContextCurrent(ALCcontext *context) => impl.alcMakeContextCurrent(context);
	/** Resumes processing updates for the given context. */
	public static void alcProcessContext(ALCcontext *context) => impl.alcProcessContext(context);
	/** Suspends updates for the given context. */
	public static void alcSuspendContext(ALCcontext *context) => impl.alcSuspendContext(context);
	/** Remove a context from its device and destroys it. */
	public static void alcDestroyContext(ALCcontext *context) => impl.alcDestroyContext(context);
	/** Returns the currently active context. */
	public static ALCcontext* alcGetCurrentContext() => impl.alcGetCurrentContext();
	/** Returns the device that a particular context is attached to. */
	public static ALCdevice* alcGetContextsDevice(ALCcontext *context) => impl.alcGetContextsDevice(context);

	/* Device management. */

	/** Opens the named playback device. */
	public static ALCdevice* alcOpenDevice(ALCchar *devicename) => impl.alcOpenDevice(devicename);
	/** Closes the given playback device. */
	public static ALCboolean alcCloseDevice(ALCdevice *device) => impl.alcCloseDevice(device);

	/* Error support. */

	/** Obtain the most recent Device error. */
	public static ALCenum alcGetError(ALCdevice *device) => impl.alcGetError(device);

	/* Extension support. */

	/**
	 * Query for the presence of an extension on the device. Pass a NULL device to
	 * query a device-inspecific extension.
	 */
	public static ALCboolean alcIsExtensionPresent(ALCdevice *device, ALCchar *extname) => impl.alcIsExtensionPresent(device, extname);
	/**
	 * Retrieve the address of a function. Given a non-NULL device, the returned
	 * function may be device-specific.
	 */
	public static ALCvoid* alcGetProcAddress(ALCdevice *device, ALCchar *funcname) => impl.alcGetProcAddress(device, funcname);
	/**
	 * Retrieve the value of an enum. Given a non-NULL device, the returned value
	 * may be device-specific.
	 */
	public static ALCenum alcGetEnumValue(ALCdevice *device, ALCchar *enumname) => impl.alcGetEnumValue(device, enumname);

	/* Query functions. */

	/** Returns information about the device, and error strings. */
	public static ALCchar* alcGetString(ALCdevice *device, ALCenum param) => impl.alcGetString(device, param);
	/** Returns information about the device and the version of OpenAL. */
	public static void alcGetIntegerv(ALCdevice *device, ALCenum param, ALCsizei size, ALCint *values) => impl.alcGetIntegerv(device, param, size, values);

	/* Capture functions. */

	/**
	 * Opens the named capture device with the given frequency, format, and buffer
	 * size.
	 */
	public static ALCdevice* alcCaptureOpenDevice(ALCchar *devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize) => impl.alcCaptureOpenDevice(devicename, frequency, format, buffersize);
	/** Closes the given capture device. */
	public static ALCboolean alcCaptureCloseDevice(ALCdevice *device) => impl.alcCaptureCloseDevice(device);
	/** Starts capturing samples into the device buffer. */
	public static void alcCaptureStart(ALCdevice *device) => impl.alcCaptureStart(device);
	/** Stops capturing samples. Samples in the device buffer remain available. */
	public static void alcCaptureStop(ALCdevice *device) => impl.alcCaptureStop(device);
	/** Reads samples from the device buffer. */
	public static void alcCaptureSamples(ALCdevice *device, ALCvoid *buffer, ALCsizei samples) => impl.alcCaptureSamples(device, buffer, samples);
}