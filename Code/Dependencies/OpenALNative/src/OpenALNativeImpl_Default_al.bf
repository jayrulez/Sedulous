using System;

namespace OpenALNative;

using internal OpenALNative;

extension OpenALNativeImpl_Default
{
	[CallingConvention(.Cdecl)]
	private function void alEnable_Delegate(ALenum capability);
	private readonly alEnable_Delegate p_alEnable = lib.LoadFunction<alEnable_Delegate>("alEnable", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alEnable(ALenum capability) => p_alEnable(capability);


	[CallingConvention(.Cdecl)]
	private function void alDisable_Delegate(ALenum capability);
	private readonly alDisable_Delegate p_alDisable = lib.LoadFunction<alDisable_Delegate>("alDisable", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alDisable(ALenum capability) => p_alDisable(capability);


	[CallingConvention(.Cdecl)]
	private function ALboolean alIsEnabled_Delegate(ALenum capability);
	private readonly alIsEnabled_Delegate p_alIsEnabled = lib.LoadFunction<alIsEnabled_Delegate>("alIsEnabled", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALboolean alIsEnabled(ALenum capability) => p_alIsEnabled(capability);



	/* Context state setting. */
	[CallingConvention(.Cdecl)]
	private function void alDopplerFactor_Delegate(ALfloat value);
	private readonly alDopplerFactor_Delegate p_alDopplerFactor = lib.LoadFunction<alDopplerFactor_Delegate>("alDopplerFactor", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alDopplerFactor(ALfloat value) => p_alDopplerFactor(value);


	[CallingConvention(.Cdecl)]
	private function void alDopplerVelocity_Delegate(ALfloat value);
	private readonly alDopplerVelocity_Delegate p_alDopplerVelocity = lib.LoadFunction<alDopplerVelocity_Delegate>("alDopplerVelocity", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alDopplerVelocity(ALfloat value) => p_alDopplerVelocity(value);


	[CallingConvention(.Cdecl)]
	private function void alSpeedOfSound_Delegate(ALfloat value);
	private readonly alSpeedOfSound_Delegate p_alSpeedOfSound = lib.LoadFunction<alSpeedOfSound_Delegate>("alSpeedOfSound", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSpeedOfSound(ALfloat value) => p_alSpeedOfSound(value);


	[CallingConvention(.Cdecl)]
	private function void alDistanceModel_Delegate(ALenum distanceModel);
	private readonly alDistanceModel_Delegate p_alDistanceModel = lib.LoadFunction<alDistanceModel_Delegate>("alDistanceModel", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alDistanceModel(ALenum distanceModel) => p_alDistanceModel(distanceModel);



	/* Context state retrieval. */
	[CallingConvention(.Cdecl)]
	private function ALchar* alGetString_Delegate(ALenum param);
	private readonly alGetString_Delegate p_alGetString = lib.LoadFunction<alGetString_Delegate>("alGetString", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALchar* alGetString(ALenum param) => p_alGetString(param);


	[CallingConvention(.Cdecl)]
	private function void alGetBooleanv_Delegate(ALenum param, ALboolean *values);
	private readonly alGetBooleanv_Delegate p_alGetBooleanv = lib.LoadFunction<alGetBooleanv_Delegate>("alGetBooleanv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetBooleanv(ALenum param, ALboolean *values) => p_alGetBooleanv(param, values);


	[CallingConvention(.Cdecl)]
	private function void alGetIntegerv_Delegate(ALenum param, ALint *values);
	private readonly alGetIntegerv_Delegate p_alGetIntegerv = lib.LoadFunction<alGetIntegerv_Delegate>("alGetIntegerv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetIntegerv(ALenum param, ALint *values) => p_alGetIntegerv(param, values);


	[CallingConvention(.Cdecl)]
	private function void alGetFloatv_Delegate(ALenum param, ALfloat *values);
	private readonly alGetFloatv_Delegate p_alGetFloatv = lib.LoadFunction<alGetFloatv_Delegate>("alGetFloatv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetFloatv(ALenum param, ALfloat *values) => p_alGetFloatv(param, values);


	[CallingConvention(.Cdecl)]
	private function void alGetDoublev_Delegate(ALenum param, ALdouble *values);
	private readonly alGetDoublev_Delegate p_alGetDoublev = lib.LoadFunction<alGetDoublev_Delegate>("alGetDoublev", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetDoublev(ALenum param, ALdouble *values) => p_alGetDoublev(param, values);


	[CallingConvention(.Cdecl)]
	private function ALboolean alGetBoolean_Delegate(ALenum param);
	private readonly alGetBoolean_Delegate p_alGetBoolean = lib.LoadFunction<alGetBoolean_Delegate>("alGetBoolean", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALboolean alGetBoolean(ALenum param) => p_alGetBoolean(param);


	[CallingConvention(.Cdecl)]
	private function ALint alGetInteger_Delegate(ALenum param);
	private readonly alGetInteger_Delegate p_alGetInteger = lib.LoadFunction<alGetInteger_Delegate>("alGetInteger", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALint alGetInteger(ALenum param) => p_alGetInteger(param);


	[CallingConvention(.Cdecl)]
	private function ALfloat alGetFloat_Delegate(ALenum param);
	private readonly alGetFloat_Delegate p_alGetFloat = lib.LoadFunction<alGetFloat_Delegate>("alGetFloat", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALfloat alGetFloat(ALenum param) => p_alGetFloat(param);


	[CallingConvention(.Cdecl)]
	private function ALdouble alGetDouble_Delegate(ALenum param);
	private readonly alGetDouble_Delegate p_alGetDouble = lib.LoadFunction<alGetDouble_Delegate>("alGetDouble", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALdouble alGetDouble(ALenum param) => p_alGetDouble(param);



	/**
	* Obtain the first error generated in the AL context since the last call to
	* this function.
	*/
	[CallingConvention(.Cdecl)]
	private function ALenum alGetError_Delegate();
	private readonly alGetError_Delegate p_alGetError = lib.LoadFunction<alGetError_Delegate>("alGetError", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALenum alGetError() => p_alGetError();



	/** Query for the presence of an extension on the AL context. */
	[CallingConvention(.Cdecl)]
	private function ALboolean alIsExtensionPresent_Delegate(ALchar *extname);
	private readonly alIsExtensionPresent_Delegate p_alIsExtensionPresent = lib.LoadFunction<alIsExtensionPresent_Delegate>("alIsExtensionPresent", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALboolean alIsExtensionPresent(ALchar *extname) => p_alIsExtensionPresent(extname);


	/**
	* Retrieve the address of a function. The returned function may be context-
	* specific.
	*/
	[CallingConvention(.Cdecl)]
	private function void* alGetProcAddress_Delegate(ALchar *fname);
	private readonly alGetProcAddress_Delegate p_alGetProcAddress = lib.LoadFunction<alGetProcAddress_Delegate>("alGetProcAddress", ..?, sInvokeErrorCallback);
	[Inline]
	public override void* alGetProcAddress(ALchar *fname) => p_alGetProcAddress(fname);


	/**
	* Retrieve the value of an enum. The returned value may be context-specific.
	*/
	[CallingConvention(.Cdecl)]
	private function ALenum alGetEnumValue_Delegate(ALchar *ename);
	private readonly alGetEnumValue_Delegate p_alGetEnumValue = lib.LoadFunction<alGetEnumValue_Delegate>("alGetEnumValue", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALenum alGetEnumValue(ALchar *ename) => p_alGetEnumValue(ename);




	/* Set listener parameters. */
	[CallingConvention(.Cdecl)]
	private function void alListenerf_Delegate(ALenum param, ALfloat value);
	private readonly alListenerf_Delegate p_alListenerf = lib.LoadFunction<alListenerf_Delegate>("alListenerf", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alListenerf(ALenum param, ALfloat value) => p_alListenerf(param, value);


	[CallingConvention(.Cdecl)]
	private function void alListener3f_Delegate(ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
	private readonly alListener3f_Delegate p_alListener3f = lib.LoadFunction<alListener3f_Delegate>("alListener3f", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alListener3f(ALenum param, ALfloat value1, ALfloat value2, ALfloat value3) => p_alListener3f(param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alListenerfv_Delegate(ALenum param, ALfloat *values);
	private readonly alListenerfv_Delegate p_alListenerfv = lib.LoadFunction<alListenerfv_Delegate>("alListenerfv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alListenerfv(ALenum param, ALfloat *values) => p_alListenerfv(param, values);


	[CallingConvention(.Cdecl)]
	private function void alListeneri_Delegate(ALenum param, ALint value);
	private readonly alListeneri_Delegate p_alListeneri = lib.LoadFunction<alListeneri_Delegate>("alListeneri", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alListeneri(ALenum param, ALint value) => p_alListeneri(param, value);


	[CallingConvention(.Cdecl)]
	private function void alListener3i_Delegate(ALenum param, ALint value1, ALint value2, ALint value3);
	private readonly alListener3i_Delegate p_alListener3i = lib.LoadFunction<alListener3i_Delegate>("alListener3i", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alListener3i(ALenum param, ALint value1, ALint value2, ALint value3) => p_alListener3i(param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alListeneriv_Delegate(ALenum param, ALint *values);
	private readonly alListeneriv_Delegate p_alListeneriv = lib.LoadFunction<alListeneriv_Delegate>("alListeneriv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alListeneriv(ALenum param, ALint *values) => p_alListeneriv(param, values);



	/* Get listener parameters. */
	[CallingConvention(.Cdecl)]
	private function void alGetListenerf_Delegate(ALenum param, ALfloat *value);
	private readonly alGetListenerf_Delegate p_alGetListenerf = lib.LoadFunction<alGetListenerf_Delegate>("alGetListenerf", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetListenerf(ALenum param, ALfloat *value) => p_alGetListenerf(param, value);


	[CallingConvention(.Cdecl)]
	private function void alGetListener3f_Delegate(ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
	private readonly alGetListener3f_Delegate p_alGetListener3f = lib.LoadFunction<alGetListener3f_Delegate>("alGetListener3f", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetListener3f(ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3) => p_alGetListener3f(param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alGetListenerfv_Delegate(ALenum param, ALfloat *values);
	private readonly alGetListenerfv_Delegate p_alGetListenerfv = lib.LoadFunction<alGetListenerfv_Delegate>("alGetListenerfv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetListenerfv(ALenum param, ALfloat *values) => p_alGetListenerfv(param, values);


	[CallingConvention(.Cdecl)]
	private function void alGetListeneri_Delegate(ALenum param, ALint *value);
	private readonly alGetListeneri_Delegate p_alGetListeneri = lib.LoadFunction<alGetListeneri_Delegate>("alGetListeneri", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetListeneri(ALenum param, ALint *value) => p_alGetListeneri(param, value);


	[CallingConvention(.Cdecl)]
	private function void alGetListener3i_Delegate(ALenum param, ALint *value1, ALint *value2, ALint *value3);
	private readonly alGetListener3i_Delegate p_alGetListener3i = lib.LoadFunction<alGetListener3i_Delegate>("alGetListener3i", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetListener3i(ALenum param, ALint *value1, ALint *value2, ALint *value3) => p_alGetListener3i(param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alGetListeneriv_Delegate(ALenum param, ALint *values);
	private readonly alGetListeneriv_Delegate p_alGetListeneriv = lib.LoadFunction<alGetListeneriv_Delegate>("alGetListeneriv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetListeneriv(ALenum param, ALint *values) => p_alGetListeneriv(param, values);




	/** Create source objects. */
	[CallingConvention(.Cdecl)]
	private function void alGenSources_Delegate(ALsizei n, ALuint *sources);
	private readonly alGenSources_Delegate p_alGenSources = lib.LoadFunction<alGenSources_Delegate>("alGenSources", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGenSources(ALsizei n, ALuint *sources) => p_alGenSources(n, sources);


	/** Delete source objects. */
	[CallingConvention(.Cdecl)]
	private function void alDeleteSources_Delegate(ALsizei n, ALuint *sources);
	private readonly alDeleteSources_Delegate p_alDeleteSources = lib.LoadFunction<alDeleteSources_Delegate>("alDeleteSources", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alDeleteSources(ALsizei n, ALuint *sources) => p_alDeleteSources(n, sources);


	/** Verify an ID is for a valid source. */
	[CallingConvention(.Cdecl)]
	private function ALboolean alIsSource_Delegate(ALuint source);
	private readonly alIsSource_Delegate p_alIsSource = lib.LoadFunction<alIsSource_Delegate>("alIsSource", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALboolean alIsSource(ALuint source) => p_alIsSource(source);



	/* Set source parameters. */
	[CallingConvention(.Cdecl)]
	private function void alSourcef_Delegate(ALuint source, ALenum param, ALfloat value);
	private readonly alSourcef_Delegate p_alSourcef = lib.LoadFunction<alSourcef_Delegate>("alSourcef", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourcef(ALuint source, ALenum param, ALfloat value) => p_alSourcef(source, param, value);


	[CallingConvention(.Cdecl)]
	private function void alSource3f_Delegate(ALuint source, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
	private readonly alSource3f_Delegate p_alSource3f = lib.LoadFunction<alSource3f_Delegate>("alSource3f", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSource3f(ALuint source, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3) => p_alSource3f(source, param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alSourcefv_Delegate(ALuint source, ALenum param, ALfloat *values);
	private readonly alSourcefv_Delegate p_alSourcefv = lib.LoadFunction<alSourcefv_Delegate>("alSourcefv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourcefv(ALuint source, ALenum param, ALfloat *values) => p_alSourcefv(source, param, values);


	[CallingConvention(.Cdecl)]
	private function void alSourcei_Delegate(ALuint source, ALenum param, ALint value);
	private readonly alSourcei_Delegate p_alSourcei = lib.LoadFunction<alSourcei_Delegate>("alSourcei", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourcei(ALuint source, ALenum param, ALint value) => p_alSourcei(source, param, value);


	[CallingConvention(.Cdecl)]
	private function void alSource3i_Delegate(ALuint source, ALenum param, ALint value1, ALint value2, ALint value3);
	private readonly alSource3i_Delegate p_alSource3i = lib.LoadFunction<alSource3i_Delegate>("alSource3i", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSource3i(ALuint source, ALenum param, ALint value1, ALint value2, ALint value3) => p_alSource3i(source, param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alSourceiv_Delegate(ALuint source, ALenum param, ALint *values);
	private readonly alSourceiv_Delegate p_alSourceiv = lib.LoadFunction<alSourceiv_Delegate>("alSourceiv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourceiv(ALuint source, ALenum param, ALint *values) => p_alSourceiv(source, param, values);



	/* Get source parameters. */
	[CallingConvention(.Cdecl)]
	private function void alGetSourcef_Delegate(ALuint source, ALenum param, ALfloat *value);
	private readonly alGetSourcef_Delegate p_alGetSourcef = lib.LoadFunction<alGetSourcef_Delegate>("alGetSourcef", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetSourcef(ALuint source, ALenum param, ALfloat *value) => p_alGetSourcef(source, param, value);


	[CallingConvention(.Cdecl)]
	private function void alGetSource3f_Delegate(ALuint source, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
	private readonly alGetSource3f_Delegate p_alGetSource3f = lib.LoadFunction<alGetSource3f_Delegate>("alGetSource3f", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetSource3f(ALuint source, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3) => p_alGetSource3f(source, param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alGetSourcefv_Delegate(ALuint source, ALenum param, ALfloat *values);
	private readonly alGetSourcefv_Delegate p_alGetSourcefv = lib.LoadFunction<alGetSourcefv_Delegate>("alGetSourcefv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetSourcefv(ALuint source, ALenum param, ALfloat *values) => p_alGetSourcefv(source, param, values);


	[CallingConvention(.Cdecl)]
	private function void alGetSourcei_Delegate(ALuint source,  ALenum param, ALint *value);
	private readonly alGetSourcei_Delegate p_alGetSourcei = lib.LoadFunction<alGetSourcei_Delegate>("alGetSourcei", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetSourcei(ALuint source,  ALenum param, ALint *value) => p_alGetSourcei(source,  param, value);


	[CallingConvention(.Cdecl)]
	private function void alGetSource3i_Delegate(ALuint source, ALenum param, ALint *value1, ALint *value2, ALint *value3);
	private readonly alGetSource3i_Delegate p_alGetSource3i = lib.LoadFunction<alGetSource3i_Delegate>("alGetSource3i", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetSource3i(ALuint source, ALenum param, ALint *value1, ALint *value2, ALint *value3) => p_alGetSource3i(source, param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alGetSourceiv_Delegate(ALuint source,  ALenum param, ALint *values);
	private readonly alGetSourceiv_Delegate p_alGetSourceiv = lib.LoadFunction<alGetSourceiv_Delegate>("alGetSourceiv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetSourceiv(ALuint source,  ALenum param, ALint *values) => p_alGetSourceiv(source,  param, values);




	/** Play, restart, or resume a source, setting its state to AL_PLAYING. */
	[CallingConvention(.Cdecl)]
	private function void alSourcePlay_Delegate(ALuint source);
	private readonly alSourcePlay_Delegate p_alSourcePlay = lib.LoadFunction<alSourcePlay_Delegate>("alSourcePlay", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourcePlay(ALuint source) => p_alSourcePlay(source);


	/** Stop a source, setting its state to AL_STOPPED if playing or paused. */
	[CallingConvention(.Cdecl)]
	private function void alSourceStop_Delegate(ALuint source);
	private readonly alSourceStop_Delegate p_alSourceStop = lib.LoadFunction<alSourceStop_Delegate>("alSourceStop", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourceStop(ALuint source) => p_alSourceStop(source);


	/** Rewind a source, setting its state to AL_INITIAL. */
	[CallingConvention(.Cdecl)]
	private function void alSourceRewind_Delegate(ALuint source);
	private readonly alSourceRewind_Delegate p_alSourceRewind = lib.LoadFunction<alSourceRewind_Delegate>("alSourceRewind", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourceRewind(ALuint source) => p_alSourceRewind(source);


	/** Pause a source, setting its state to AL_PAUSED if playing. */
	[CallingConvention(.Cdecl)]
	private function void alSourcePause_Delegate(ALuint source);
	private readonly alSourcePause_Delegate p_alSourcePause = lib.LoadFunction<alSourcePause_Delegate>("alSourcePause", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourcePause(ALuint source) => p_alSourcePause(source);



	/** Play, restart, or resume a list of sources atomically. */
	[CallingConvention(.Cdecl)]
	private function void alSourcePlayv_Delegate(ALsizei n, ALuint *sources);
	private readonly alSourcePlayv_Delegate p_alSourcePlayv = lib.LoadFunction<alSourcePlayv_Delegate>("alSourcePlayv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourcePlayv(ALsizei n, ALuint *sources) => p_alSourcePlayv(n, sources);


	/** Stop a list of sources atomically. */
	[CallingConvention(.Cdecl)]
	private function void alSourceStopv_Delegate(ALsizei n, ALuint *sources);
	private readonly alSourceStopv_Delegate p_alSourceStopv = lib.LoadFunction<alSourceStopv_Delegate>("alSourceStopv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourceStopv(ALsizei n, ALuint *sources) => p_alSourceStopv(n, sources);


	/** Rewind a list of sources atomically. */
	[CallingConvention(.Cdecl)]
	private function void alSourceRewindv_Delegate(ALsizei n, ALuint *sources);
	private readonly alSourceRewindv_Delegate p_alSourceRewindv = lib.LoadFunction<alSourceRewindv_Delegate>("alSourceRewindv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourceRewindv(ALsizei n, ALuint *sources) => p_alSourceRewindv(n, sources);


	/** Pause a list of sources atomically. */
	[CallingConvention(.Cdecl)]
	private function void alSourcePausev_Delegate(ALsizei n, ALuint *sources);
	private readonly alSourcePausev_Delegate p_alSourcePausev = lib.LoadFunction<alSourcePausev_Delegate>("alSourcePausev", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourcePausev(ALsizei n, ALuint *sources) => p_alSourcePausev(n, sources);



	/** Queue buffers onto a source */
	[CallingConvention(.Cdecl)]
	private function void alSourceQueueBuffers_Delegate(ALuint source, ALsizei nb, ALuint *buffers);
	private readonly alSourceQueueBuffers_Delegate p_alSourceQueueBuffers = lib.LoadFunction<alSourceQueueBuffers_Delegate>("alSourceQueueBuffers", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourceQueueBuffers(ALuint source, ALsizei nb, ALuint *buffers) => p_alSourceQueueBuffers(source, nb, buffers);


	/** Unqueue processed buffers from a source */
	[CallingConvention(.Cdecl)]
	private function void alSourceUnqueueBuffers_Delegate(ALuint source, ALsizei nb, ALuint *buffers);
	private readonly alSourceUnqueueBuffers_Delegate p_alSourceUnqueueBuffers = lib.LoadFunction<alSourceUnqueueBuffers_Delegate>("alSourceUnqueueBuffers", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alSourceUnqueueBuffers(ALuint source, ALsizei nb, ALuint *buffers) => p_alSourceUnqueueBuffers(source, nb, buffers);




	/** Create buffer objects */
	[CallingConvention(.Cdecl)]
	private function void alGenBuffers_Delegate(ALsizei n, ALuint *buffers);
	private readonly alGenBuffers_Delegate p_alGenBuffers = lib.LoadFunction<alGenBuffers_Delegate>("alGenBuffers", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGenBuffers(ALsizei n, ALuint *buffers) => p_alGenBuffers(n, buffers);


	/** Delete buffer objects */
	[CallingConvention(.Cdecl)]
	private function void alDeleteBuffers_Delegate(ALsizei n, ALuint *buffers);
	private readonly alDeleteBuffers_Delegate p_alDeleteBuffers = lib.LoadFunction<alDeleteBuffers_Delegate>("alDeleteBuffers", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alDeleteBuffers(ALsizei n, ALuint *buffers) => p_alDeleteBuffers(n, buffers);


	/** Verify an ID is a valid buffer (including the NULL buffer) */
	[CallingConvention(.Cdecl)]
	private function ALboolean alIsBuffer_Delegate(ALuint buffer);
	private readonly alIsBuffer_Delegate p_alIsBuffer = lib.LoadFunction<alIsBuffer_Delegate>("alIsBuffer", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALboolean alIsBuffer(ALuint buffer) => p_alIsBuffer(buffer);



	/**
	* Copies data into the buffer, interpreting it using the specified format and
	* samplerate.
	*/
	[CallingConvention(.Cdecl)]
	private function void alBufferData_Delegate(ALuint buffer, ALenum format, ALvoid *data, ALsizei size, ALsizei samplerate);
	private readonly alBufferData_Delegate p_alBufferData = lib.LoadFunction<alBufferData_Delegate>("alBufferData", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alBufferData(ALuint buffer, ALenum format, ALvoid *data, ALsizei size, ALsizei samplerate) => p_alBufferData(buffer, format, data, size, samplerate);



	/* Set buffer parameters. */
	[CallingConvention(.Cdecl)]
	private function void alBufferf_Delegate(ALuint buffer, ALenum param, ALfloat value);
	private readonly alBufferf_Delegate p_alBufferf = lib.LoadFunction<alBufferf_Delegate>("alBufferf", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alBufferf(ALuint buffer, ALenum param, ALfloat value) => p_alBufferf(buffer, param, value);


	[CallingConvention(.Cdecl)]
	private function void alBuffer3f_Delegate(ALuint buffer, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
	private readonly alBuffer3f_Delegate p_alBuffer3f = lib.LoadFunction<alBuffer3f_Delegate>("alBuffer3f", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alBuffer3f(ALuint buffer, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3) => p_alBuffer3f(buffer, param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alBufferfv_Delegate(ALuint buffer, ALenum param, ALfloat *values);
	private readonly alBufferfv_Delegate p_alBufferfv = lib.LoadFunction<alBufferfv_Delegate>("alBufferfv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alBufferfv(ALuint buffer, ALenum param, ALfloat *values) => p_alBufferfv(buffer, param, values);


	[CallingConvention(.Cdecl)]
	private function void alBufferi_Delegate(ALuint buffer, ALenum param, ALint value);
	private readonly alBufferi_Delegate p_alBufferi = lib.LoadFunction<alBufferi_Delegate>("alBufferi", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alBufferi(ALuint buffer, ALenum param, ALint value) => p_alBufferi(buffer, param, value);


	[CallingConvention(.Cdecl)]
	private function void alBuffer3i_Delegate(ALuint buffer, ALenum param, ALint value1, ALint value2, ALint value3);
	private readonly alBuffer3i_Delegate p_alBuffer3i = lib.LoadFunction<alBuffer3i_Delegate>("alBuffer3i", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alBuffer3i(ALuint buffer, ALenum param, ALint value1, ALint value2, ALint value3) => p_alBuffer3i(buffer, param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alBufferiv_Delegate(ALuint buffer, ALenum param, ALint *values);
	private readonly alBufferiv_Delegate p_alBufferiv = lib.LoadFunction<alBufferiv_Delegate>("alBufferiv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alBufferiv(ALuint buffer, ALenum param, ALint *values) => p_alBufferiv(buffer, param, values);



	/* Get buffer parameters. */
	[CallingConvention(.Cdecl)]
	private function void alGetBufferf_Delegate(ALuint buffer, ALenum param, ALfloat *value);
	private readonly alGetBufferf_Delegate p_alGetBufferf = lib.LoadFunction<alGetBufferf_Delegate>("alGetBufferf", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetBufferf(ALuint buffer, ALenum param, ALfloat *value) => p_alGetBufferf(buffer, param, value);


	[CallingConvention(.Cdecl)]
	private function void alGetBuffer3f_Delegate(ALuint buffer, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
	private readonly alGetBuffer3f_Delegate p_alGetBuffer3f = lib.LoadFunction<alGetBuffer3f_Delegate>("alGetBuffer3f", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetBuffer3f(ALuint buffer, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3) => p_alGetBuffer3f(buffer, param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alGetBufferfv_Delegate(ALuint buffer, ALenum param, ALfloat *values);
	private readonly alGetBufferfv_Delegate p_alGetBufferfv = lib.LoadFunction<alGetBufferfv_Delegate>("alGetBufferfv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetBufferfv(ALuint buffer, ALenum param, ALfloat *values) => p_alGetBufferfv(buffer, param, values);


	[CallingConvention(.Cdecl)]
	private function void alGetBufferi_Delegate(ALuint buffer, ALenum param, ALint *value);
	private readonly alGetBufferi_Delegate p_alGetBufferi = lib.LoadFunction<alGetBufferi_Delegate>("alGetBufferi", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetBufferi(ALuint buffer, ALenum param, ALint *value) => p_alGetBufferi(buffer, param, value);


	[CallingConvention(.Cdecl)]
	private function void alGetBuffer3i_Delegate(ALuint buffer, ALenum param, ALint *value1, ALint *value2, ALint *value3);
	private readonly alGetBuffer3i_Delegate p_alGetBuffer3i = lib.LoadFunction<alGetBuffer3i_Delegate>("alGetBuffer3i", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetBuffer3i(ALuint buffer, ALenum param, ALint *value1, ALint *value2, ALint *value3) => p_alGetBuffer3i(buffer, param, value1, value2, value3);


	[CallingConvention(.Cdecl)]
	private function void alGetBufferiv_Delegate(ALuint buffer, ALenum param, ALint *values);
	private readonly alGetBufferiv_Delegate p_alGetBufferiv = lib.LoadFunction<alGetBufferiv_Delegate>("alGetBufferiv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alGetBufferiv(ALuint buffer, ALenum param, ALint *values) => p_alGetBufferiv(buffer, param, values);
}