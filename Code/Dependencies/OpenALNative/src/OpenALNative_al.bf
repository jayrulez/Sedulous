namespace OpenALNative;

/* Deprecated macros. */
#define OPENAL

/* Supported AL versions. */
#define AL_VERSION_1_0
#define AL_VERSION_1_1

static
{

//public const uint32 ALAPI                                    = AL_API;
//public const uint32 ALAPIENTRY                               = AL_APIENTRY;
public const uint32 AL_INVALID                               = (uint32)-1;
public const uint32 AL_ILLEGAL_ENUM                          = AL_INVALID_ENUM;
public const uint32 AL_ILLEGAL_COMMAND                       = AL_INVALID_OPERATION;
}

/** 8-bit boolean */
typealias ALboolean = int8;

/** character */
typealias ALchar = char8;

/** signed 8-bit integer */
typealias ALbyte = int8;

/** unsigned 8-bit integer */
typealias ALubyte = uint8;

/** signed 16-bit integer */
typealias ALshort = int16;

/** unsigned 16-bit integer */
typealias ALushort = uint16;

/** signed 32-bit integer */
typealias ALint = int32;

/** unsigned 32-bit integer */
typealias ALuint = uint32;

/** non-negative 32-bit integer size */
typealias ALsizei = int32;

/** 32-bit enumeration value */
typealias ALenum = int32;

/** 32-bit IEEE-754 floating-point */
typealias ALfloat = float;

/** 64-bit IEEE-754 floating-point */
typealias ALdouble = double;

/** void type (opaque pointers only) */
typealias ALvoid = void;

static
{
	/* Enumeration values begin at column 50. Do not use tabs. */

	/** No distance model or no buffer */
public const uint32 AL_NONE                                  = 0;

	/** Boolean False. */
public const uint32 AL_FALSE                                 = 0;

	/** Boolean True. */
public const uint32 AL_TRUE                                  = 1;


	/**
	 * Relative source.
	 * Type:    ALboolean
	 * Range:   [AL_FALSE, AL_TRUE]
	 * Default: AL_FALSE
	 *
	 * Specifies if the source uses relative coordinates.
	 */
public const uint32 AL_SOURCE_RELATIVE                       = 0x202;


	/**
	 * Inner cone angle, in degrees.
	 * Type:    ALint, ALfloat
	 * Range:   [0 - 360]
	 * Default: 360
	 *
	 * The angle covered by the inner cone, the area within which the source will
	 * not be attenuated by direction.
	 */
public const uint32 AL_CONE_INNER_ANGLE                      = 0x1001;

	/**
	 * Outer cone angle, in degrees.
	 * Range:   [0 - 360]
	 * Default: 360
	 *
	 * The angle covered by the outer cone, the area outside of which the source
	 * will be fully attenuated by direction.
	 */
public const uint32 AL_CONE_OUTER_ANGLE                      = 0x1002;

	/**
	 * Source pitch.
	 * Type:    ALfloat
	 * Range:   [0.5 - 2.0]
	 * Default: 1.0
	 *
	 * A multiplier for the sample rate of the source's buffer.
	 */
public const uint32 AL_PITCH                                 = 0x1003;

	/**
	 * Source or listener position.
	 * Type:    ALfloat[3], ALint[3]
	 * Default: {0, 0, 0}
	 *
	 * The source or listener location in three dimensional space.
	 *
	 * OpenAL uses a right handed coordinate system, like OpenGL, where with a
	 * default view, X points right (thumb), Y points up (index finger), and Z
	 * points towards the viewer/camera (middle finger).
	 *
	 * To change from or to a left handed coordinate system, negate the Z
	 * component.
	 */
public const uint32 AL_POSITION                              = 0x1004;

	/**
	 * Source direction.
	 * Type:    ALfloat[3], ALint[3]
	 * Default: {0, 0, 0}
	 *
	 * Specifies the current direction in local space. A zero-length vector
	 * specifies an omni-directional source (cone is ignored).
	 *
	 * To change from or to a left handed coordinate system, negate the Z
	 * component.
	 */
public const uint32 AL_DIRECTION                             = 0x1005;

	/**
	 * Source or listener velocity.
	 * Type:    ALfloat[3], ALint[3]
	 * Default: {0, 0, 0}
	 *
	 * Specifies the current velocity, relative to the position.
	 *
	 * To change from or to a left handed coordinate system, negate the Z
	 * component.
	 */
public const uint32 AL_VELOCITY                              = 0x1006;

	/**
	 * Source looping.
	 * Type:    ALboolean
	 * Range:   [AL_FALSE, AL_TRUE]
	 * Default: AL_FALSE
	 *
	 * Specifies whether source playback loops.
	 */
public const uint32 AL_LOOPING                               = 0x1007;

	/**
	 * Source buffer.
	 * Type:    ALuint
	 * Range:   any valid Buffer ID
	 * Default: AL_NONE
	 *
	 * Specifies the buffer to provide sound samples for a source.
	 */
public const uint32 AL_BUFFER                                = 0x1009;

	/**
	 * Source or listener gain.
	 * Type:  ALfloat
	 * Range: [0.0 - ]
	 *
	 * For sources, an initial linear gain value (before attenuation is applied).
	 * For the listener, an output linear gain adjustment.
	 *
	 * A value of 1.0 means unattenuated. Each division by 2 equals an attenuation
	 * of about -6dB. Each multiplication by 2 equals an amplification of about
	 * +6dB.
	 */
public const uint32 AL_GAIN                                  = 0x100A;

	/**
	 * Minimum source gain.
	 * Type:  ALfloat
	 * Range: [0.0 - 1.0]
	 *
	 * The minimum gain allowed for a source, after distance and cone attenuation
	 * are applied (if applicable).
	 */
public const uint32 AL_MIN_GAIN                              = 0x100D;

	/**
	 * Maximum source gain.
	 * Type:  ALfloat
	 * Range: [0.0 - 1.0]
	 *
	 * The maximum gain allowed for a source, after distance and cone attenuation
	 * are applied (if applicable).
	 */
public const uint32 AL_MAX_GAIN                              = 0x100E;

	/**
	 * Listener orientation.
	 * Type:    ALfloat[6]
	 * Default: {0.0, 0.0, -1.0, 0.0, 1.0, 0.0}
	 *
	 * Effectively two three dimensional vectors. The first vector is the front (or
	 * "at") and the second is the top (or "up"). Both vectors are relative to the
	 * listener position.
	 *
	 * To change from or to a left handed coordinate system, negate the Z
	 * component of both vectors.
	 */
public const uint32 AL_ORIENTATION                           = 0x100F;

	/**
	 * Source state (query only).
	 * Type:  ALenum
	 * Range: [AL_INITIAL, AL_PLAYING, AL_PAUSED, AL_STOPPED]
	 */
public const uint32 AL_SOURCE_STATE                          = 0x1010;

	/* Source state values. */
public const uint32 AL_INITIAL                               = 0x1011;
public const uint32 AL_PLAYING                               = 0x1012;
public const uint32 AL_PAUSED                                = 0x1013;
public const uint32 AL_STOPPED                               = 0x1014;

	/**
	 * Source Buffer Queue size (query only).
	 * Type: ALint
	 *
	 * The number of buffers queued using alSourceQueueBuffers, minus the buffers
	 * removed with alSourceUnqueueBuffers.
	 */
public const uint32 AL_BUFFERS_QUEUED                        = 0x1015;

	/**
	 * Source Buffer Queue processed count (query only).
	 * Type: ALint
	 *
	 * The number of queued buffers that have been fully processed, and can be
	 * removed with alSourceUnqueueBuffers.
	 *
	 * Looping sources will never fully process buffers because they will be set to
	 * play again for when the source loops.
	 */
public const uint32 AL_BUFFERS_PROCESSED                     = 0x1016;

	/**
	 * Source reference distance.
	 * Type:    ALfloat
	 * Range:   [0.0 - ]
	 * Default: 1.0
	 *
	 * The distance in units that no distance attenuation occurs.
	 *
	 * At 0.0, no distance attenuation occurs with non-linear attenuation models.
	 */
public const uint32 AL_REFERENCE_DISTANCE                    = 0x1020;

	/**
	 * Source rolloff factor.
	 * Type:    ALfloat
	 * Range:   [0.0 - ]
	 * Default: 1.0
	 *
	 * Multiplier to exaggerate or diminish distance attenuation.
	 *
	 * At 0.0, no distance attenuation ever occurs.
	 */
public const uint32 AL_ROLLOFF_FACTOR                        = 0x1021;

	/**
	 * Outer cone gain.
	 * Type:    ALfloat
	 * Range:   [0.0 - 1.0]
	 * Default: 0.0
	 *
	 * The gain attenuation applied when the listener is outside of the source's
	 * outer cone angle.
	 */
public const uint32 AL_CONE_OUTER_GAIN                       = 0x1022;

	/**
	 * Source maximum distance.
	 * Type:    ALfloat
	 * Range:   [0.0 - ]
	 * Default: FLT_MAX
	 *
	 * The distance above which the source is not attenuated any further with a
	 * clamped distance model, or where attenuation reaches 0.0 gain for linear
	 * distance models with a default rolloff factor.
	 */
public const uint32 AL_MAX_DISTANCE                          = 0x1023;

	/** Source buffer offset, in seconds */
public const uint32 AL_SEC_OFFSET                            = 0x1024;
	/** Source buffer offset, in sample frames */
public const uint32 AL_SAMPLE_OFFSET                         = 0x1025;
	/** Source buffer offset, in bytes */
public const uint32 AL_BYTE_OFFSET                           = 0x1026;

	/**
	 * Source type (query only).
	 * Type:  ALenum
	 * Range: [AL_STATIC, AL_STREAMING, AL_UNDETERMINED]
	 *
	 * A Source is Static if a Buffer has been attached using AL_BUFFER.
	 *
	 * A Source is Streaming if one or more Buffers have been attached using
	 * alSourceQueueBuffers.
	 *
	 * A Source is Undetermined when it has the NULL buffer attached using
	 * AL_BUFFER.
	 */
public const uint32 AL_SOURCE_TYPE                           = 0x1027;

	/* Source type values. */
public const uint32 AL_STATIC                                = 0x1028;
public const uint32 AL_STREAMING                             = 0x1029;
public const uint32 AL_UNDETERMINED                          = 0x1030;

	/** Unsigned 8-bit mono buffer format. */
public const uint32 AL_FORMAT_MONO8                          = 0x1100;
	/** Signed 16-bit mono buffer format. */
public const uint32 AL_FORMAT_MONO16                         = 0x1101;
	/** Unsigned 8-bit stereo buffer format. */
public const uint32 AL_FORMAT_STEREO8                        = 0x1102;
	/** Signed 16-bit stereo buffer format. */
public const uint32 AL_FORMAT_STEREO16                       = 0x1103;

	/** Buffer frequency/sample rate (query only). */
public const uint32 AL_FREQUENCY                             = 0x2001;
	/** Buffer bits per sample (query only). */
public const uint32 AL_BITS                                  = 0x2002;
	/** Buffer channel count (query only). */
public const uint32 AL_CHANNELS                              = 0x2003;
	/** Buffer data size in bytes (query only). */
public const uint32 AL_SIZE                                  = 0x2004;

	/* Buffer state. Not for public use. */
public const uint32 AL_UNUSED                                = 0x2010;
public const uint32 AL_PENDING                               = 0x2011;
public const uint32 AL_PROCESSED                             = 0x2012;


	/** No error. */
public const uint32 AL_NO_ERROR                              = 0;

	/** Invalid name (ID) passed to an AL call. */
public const uint32 AL_INVALID_NAME                          = 0xA001;

	/** Invalid enumeration passed to AL call. */
public const uint32 AL_INVALID_ENUM                          = 0xA002;

	/** Invalid value passed to AL call. */
public const uint32 AL_INVALID_VALUE                         = 0xA003;

	/** Illegal AL call. */
public const uint32 AL_INVALID_OPERATION                     = 0xA004;

	/** Not enough memory to execute the AL call. */
public const uint32 AL_OUT_OF_MEMORY                         = 0xA005;


	/** Context string: Vendor name. */
public const uint32 AL_VENDOR                                = 0xB001;
	/** Context string: Version. */
public const uint32 AL_VERSION                               = 0xB002;
	/** Context string: Renderer name. */
public const uint32 AL_RENDERER                              = 0xB003;
	/** Context string: Space-separated extension list. */
public const uint32 AL_EXTENSIONS                            = 0xB004;
}

extension OpenALNative
{
	public static void alEnable(ALenum capability) => impl.alEnable(capability);
	public static void alDisable(ALenum capability) => impl.alDisable(capability);
	public static ALboolean alIsEnabled(ALenum capability) => impl.alIsEnabled(capability);

	/* Context state setting. */
	public static void alDopplerFactor(ALfloat value) => impl.alDopplerFactor(value);
	public static void alDopplerVelocity(ALfloat value) => impl.alDopplerVelocity(value);
	public static void alSpeedOfSound(ALfloat value) => impl.alSpeedOfSound(value);
	public static void alDistanceModel(ALenum distanceModel) => impl.alDistanceModel(distanceModel);

	/* Context state retrieval. */
	public static ALchar* alGetString(ALenum param) => impl.alGetString(param);
	public static void alGetBooleanv(ALenum param, ALboolean *values) => impl.alGetBooleanv(param, values);
	public static void alGetIntegerv(ALenum param, ALint *values) => impl.alGetIntegerv(param, values);
	public static void alGetFloatv(ALenum param, ALfloat *values) => impl.alGetFloatv(param, values);
	public static void alGetDoublev(ALenum param, ALdouble *values) => impl.alGetDoublev(param, values);
	public static ALboolean alGetBoolean(ALenum param) => impl.alGetBoolean(param);
	public static ALint alGetInteger(ALenum param) => impl.alGetInteger(param);
	public static ALfloat alGetFloat(ALenum param) => impl.alGetFloat(param);
	public static ALdouble alGetDouble(ALenum param) => impl.alGetDouble(param);

	/**
	 * Obtain the first error generated in the AL context since the last call to
	 * this function.
	 */
	public static ALenum alGetError() => impl.alGetError();

	/** Query for the presence of an extension on the AL context. */
	public static ALboolean alIsExtensionPresent(ALchar *extname) => impl.alIsExtensionPresent(extname);
	/**
	 * Retrieve the address of a function. The returned function may be context-
	 * specific.
	 */
	public static void* alGetProcAddress(ALchar *fname) => impl.alGetProcAddress(fname);
	/**
	 * Retrieve the value of an enum. The returned value may be context-specific.
	 */
	public static ALenum alGetEnumValue(ALchar *ename) => impl.alGetEnumValue(ename);


	/* Set listener parameters. */
	public static void alListenerf(ALenum param, ALfloat value) => impl.alListenerf(param, value);
	public static void alListener3f(ALenum param, ALfloat value1, ALfloat value2, ALfloat value3) => impl.alListener3f(param, value1, value2, value3);
	public static void alListenerfv(ALenum param, ALfloat *values) => impl.alListenerfv(param, values);
	public static void alListeneri(ALenum param, ALint value) => impl.alListeneri(param, value);
	public static void alListener3i(ALenum param, ALint value1, ALint value2, ALint value3) => impl.alListener3i(param, value1, value2, value3);
	public static void alListeneriv(ALenum param, ALint *values) => impl.alListeneriv(param, values);

	/* Get listener parameters. */
	public static void alGetListenerf(ALenum param, ALfloat *value) => impl.alGetListenerf(param, value);
	public static void alGetListener3f(ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3) => impl.alGetListener3f(param, value1, value2, value3);
	public static void alGetListenerfv(ALenum param, ALfloat *values) => impl.alGetListenerfv(param, values);
	public static void alGetListeneri(ALenum param, ALint *value) => impl.alGetListeneri(param, value);
	public static void alGetListener3i(ALenum param, ALint *value1, ALint *value2, ALint *value3) => impl.alGetListener3i(param, value1, value2, value3);
	public static void alGetListeneriv(ALenum param, ALint *values) => impl.alGetListeneriv(param, values);


	/** Create source objects. */
	public static void alGenSources(ALsizei n, ALuint *sources) => impl.alGenSources(n, sources);
	/** Delete source objects. */
	public static void alDeleteSources(ALsizei n, ALuint *sources) => impl.alDeleteSources(n, sources);
	/** Verify an ID is for a valid source. */
	public static ALboolean alIsSource(ALuint source) => impl.alIsSource(source);

	/* Set source parameters. */
	public static void alSourcef(ALuint source, ALenum param, ALfloat value) => impl.alSourcef(source, param, value);
	public static void alSource3f(ALuint source, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3) => impl.alSource3f(source, param, value1, value2, value3);
	public static void alSourcefv(ALuint source, ALenum param, ALfloat *values) => impl.alSourcefv(source, param, values);
	public static void alSourcei(ALuint source, ALenum param, ALint value) => impl.alSourcei(source, param, value);
	public static void alSource3i(ALuint source, ALenum param, ALint value1, ALint value2, ALint value3) => impl.alSource3i(source, param, value1, value2, value3);
	public static void alSourceiv(ALuint source, ALenum param, ALint *values) => impl.alSourceiv(source, param, values);

	/* Get source parameters. */
	public static void alGetSourcef(ALuint source, ALenum param, ALfloat *value) => impl.alGetSourcef(source, param, value);
	public static void alGetSource3f(ALuint source, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3) => impl.alGetSource3f(source, param, value1, value2, value3);
	public static void alGetSourcefv(ALuint source, ALenum param, ALfloat *values) => impl.alGetSourcefv(source, param, values);
	public static void alGetSourcei(ALuint source,  ALenum param, ALint *value) => impl.alGetSourcei(source,  param, value);
	public static void alGetSource3i(ALuint source, ALenum param, ALint *value1, ALint *value2, ALint *value3) => impl.alGetSource3i(source, param, value1, value2, value3);
	public static void alGetSourceiv(ALuint source,  ALenum param, ALint *values) => impl.alGetSourceiv(source,  param, values);


	/** Play, restart, or resume a source, setting its state to AL_PLAYING. */
	public static void alSourcePlay(ALuint source) => impl.alSourcePlay(source);
	/** Stop a source, setting its state to AL_STOPPED if playing or paused. */
	public static void alSourceStop(ALuint source) => impl.alSourceStop(source);
	/** Rewind a source, setting its state to AL_INITIAL. */
	public static void alSourceRewind(ALuint source) => impl.alSourceRewind(source);
	/** Pause a source, setting its state to AL_PAUSED if playing. */
	public static void alSourcePause(ALuint source) => impl.alSourcePause(source);

	/** Play, restart, or resume a list of sources atomically. */
	public static void alSourcePlayv(ALsizei n, ALuint *sources) => impl.alSourcePlayv(n, sources);
	/** Stop a list of sources atomically. */
	public static void alSourceStopv(ALsizei n, ALuint *sources) => impl.alSourceStopv(n, sources);
	/** Rewind a list of sources atomically. */
	public static void alSourceRewindv(ALsizei n, ALuint *sources) => impl.alSourceRewindv(n, sources);
	/** Pause a list of sources atomically. */
	public static void alSourcePausev(ALsizei n, ALuint *sources) => impl.alSourcePausev(n, sources);

	/** Queue buffers onto a source */
	public static void alSourceQueueBuffers(ALuint source, ALsizei nb, ALuint *buffers) => impl.alSourceQueueBuffers(source, nb, buffers);
	/** Unqueue processed buffers from a source */
	public static void alSourceUnqueueBuffers(ALuint source, ALsizei nb, ALuint *buffers) => impl.alSourceUnqueueBuffers(source, nb, buffers);


	/** Create buffer objects */
	public static void alGenBuffers(ALsizei n, ALuint *buffers) => impl.alGenBuffers(n, buffers);
	/** Delete buffer objects */
	public static void alDeleteBuffers(ALsizei n, ALuint *buffers) => impl.alDeleteBuffers(n, buffers);
	/** Verify an ID is a valid buffer (including the NULL buffer) */
	public static ALboolean alIsBuffer(ALuint buffer) => impl.alIsBuffer(buffer);

	/**
	 * Copies data into the buffer, interpreting it using the specified format and
	 * samplerate.
	 */
	public static void alBufferData(ALuint buffer, ALenum format, ALvoid *data, ALsizei size, ALsizei samplerate) => impl.alBufferData(buffer, format, data, size, samplerate);

	/* Set buffer parameters. */
	public static void alBufferf(ALuint buffer, ALenum param, ALfloat value) => impl.alBufferf(buffer, param, value);
	public static void alBuffer3f(ALuint buffer, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3) => impl.alBuffer3f(buffer, param, value1, value2, value3);
	public static void alBufferfv(ALuint buffer, ALenum param, ALfloat *values) => impl.alBufferfv(buffer, param, values);
	public static void alBufferi(ALuint buffer, ALenum param, ALint value) => impl.alBufferi(buffer, param, value);
	public static void alBuffer3i(ALuint buffer, ALenum param, ALint value1, ALint value2, ALint value3) => impl.alBuffer3i(buffer, param, value1, value2, value3);
	public static void alBufferiv(ALuint buffer, ALenum param, ALint *values) => impl.alBufferiv(buffer, param, values);

	/* Get buffer parameters. */
	public static void alGetBufferf(ALuint buffer, ALenum param, ALfloat *value) => impl.alGetBufferf(buffer, param, value);
	public static void alGetBuffer3f(ALuint buffer, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3) => impl.alGetBuffer3f(buffer, param, value1, value2, value3);
	public static void alGetBufferfv(ALuint buffer, ALenum param, ALfloat *values) => impl.alGetBufferfv(buffer, param, values);
	public static void alGetBufferi(ALuint buffer, ALenum param, ALint *value) => impl.alGetBufferi(buffer, param, value);
	public static void alGetBuffer3i(ALuint buffer, ALenum param, ALint *value1, ALint *value2, ALint *value3) => impl.alGetBuffer3i(buffer, param, value1, value2, value3);
	public static void alGetBufferiv(ALuint buffer, ALenum param, ALint *values) => impl.alGetBufferiv(buffer, param, values);
}