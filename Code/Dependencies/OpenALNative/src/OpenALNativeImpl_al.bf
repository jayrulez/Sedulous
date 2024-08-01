namespace OpenALNative;

extension OpenALNativeImpl
{
	public abstract void alEnable(ALenum capability);
	public abstract void alDisable(ALenum capability);
	public abstract ALboolean alIsEnabled(ALenum capability);

	/* Context state setting. */
	public abstract void alDopplerFactor(ALfloat value);
	public abstract void alDopplerVelocity(ALfloat value);
	public abstract void alSpeedOfSound(ALfloat value);
	public abstract void alDistanceModel(ALenum distanceModel);

	/* Context state retrieval. */
	public abstract ALchar* alGetString(ALenum param);
	public abstract void alGetBooleanv(ALenum param, ALboolean *values);
	public abstract void alGetIntegerv(ALenum param, ALint *values);
	public abstract void alGetFloatv(ALenum param, ALfloat *values);
	public abstract void alGetDoublev(ALenum param, ALdouble *values);
	public abstract ALboolean alGetBoolean(ALenum param);
	public abstract ALint alGetInteger(ALenum param);
	public abstract ALfloat alGetFloat(ALenum param);
	public abstract ALdouble alGetDouble(ALenum param);

	/**
	 * Obtain the first error generated in the AL context since the last call to
	 * this function.
	 */
	public abstract ALenum alGetError();

	/** Query for the presence of an extension on the AL context. */
	public abstract ALboolean alIsExtensionPresent(ALchar *extname);
	/**
	 * Retrieve the address of a function. The returned function may be context-
	 * specific.
	 */
	public abstract void* alGetProcAddress(ALchar *fname);
	/**
	 * Retrieve the value of an enum. The returned value may be context-specific.
	 */
	public abstract ALenum alGetEnumValue(ALchar *ename);


	/* Set listener parameters. */
	public abstract void alListenerf(ALenum param, ALfloat value);
	public abstract void alListener3f(ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
	public abstract void alListenerfv(ALenum param, ALfloat *values);
	public abstract void alListeneri(ALenum param, ALint value);
	public abstract void alListener3i(ALenum param, ALint value1, ALint value2, ALint value3);
	public abstract void alListeneriv(ALenum param, ALint *values);

	/* Get listener parameters. */
	public abstract void alGetListenerf(ALenum param, ALfloat *value);
	public abstract void alGetListener3f(ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
	public abstract void alGetListenerfv(ALenum param, ALfloat *values);
	public abstract void alGetListeneri(ALenum param, ALint *value);
	public abstract void alGetListener3i(ALenum param, ALint *value1, ALint *value2, ALint *value3);
	public abstract void alGetListeneriv(ALenum param, ALint *values);


	/** Create source objects. */
	public abstract void alGenSources(ALsizei n, ALuint *sources);
	/** Delete source objects. */
	public abstract void alDeleteSources(ALsizei n, ALuint *sources);
	/** Verify an ID is for a valid source. */
	public abstract ALboolean alIsSource(ALuint source);

	/* Set source parameters. */
	public abstract void alSourcef(ALuint source, ALenum param, ALfloat value);
	public abstract void alSource3f(ALuint source, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
	public abstract void alSourcefv(ALuint source, ALenum param, ALfloat *values);
	public abstract void alSourcei(ALuint source, ALenum param, ALint value);
	public abstract void alSource3i(ALuint source, ALenum param, ALint value1, ALint value2, ALint value3);
	public abstract void alSourceiv(ALuint source, ALenum param, ALint *values);

	/* Get source parameters. */
	public abstract void alGetSourcef(ALuint source, ALenum param, ALfloat *value);
	public abstract void alGetSource3f(ALuint source, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
	public abstract void alGetSourcefv(ALuint source, ALenum param, ALfloat *values);
	public abstract void alGetSourcei(ALuint source,  ALenum param, ALint *value);
	public abstract void alGetSource3i(ALuint source, ALenum param, ALint *value1, ALint *value2, ALint *value3);
	public abstract void alGetSourceiv(ALuint source,  ALenum param, ALint *values);


	/** Play, restart, or resume a source, setting its state to AL_PLAYING. */
	public abstract void alSourcePlay(ALuint source);
	/** Stop a source, setting its state to AL_STOPPED if playing or paused. */
	public abstract void alSourceStop(ALuint source);
	/** Rewind a source, setting its state to AL_INITIAL. */
	public abstract void alSourceRewind(ALuint source);
	/** Pause a source, setting its state to AL_PAUSED if playing. */
	public abstract void alSourcePause(ALuint source);

	/** Play, restart, or resume a list of sources atomically. */
	public abstract void alSourcePlayv(ALsizei n, ALuint *sources);
	/** Stop a list of sources atomically. */
	public abstract void alSourceStopv(ALsizei n, ALuint *sources);
	/** Rewind a list of sources atomically. */
	public abstract void alSourceRewindv(ALsizei n, ALuint *sources);
	/** Pause a list of sources atomically. */
	public abstract void alSourcePausev(ALsizei n, ALuint *sources);

	/** Queue buffers onto a source */
	public abstract void alSourceQueueBuffers(ALuint source, ALsizei nb, ALuint *buffers);
	/** Unqueue processed buffers from a source */
	public abstract void alSourceUnqueueBuffers(ALuint source, ALsizei nb, ALuint *buffers);


	/** Create buffer objects */
	public abstract void alGenBuffers(ALsizei n, ALuint *buffers);
	/** Delete buffer objects */
	public abstract void alDeleteBuffers(ALsizei n, ALuint *buffers);
	/** Verify an ID is a valid buffer (including the NULL buffer) */
	public abstract ALboolean alIsBuffer(ALuint buffer);

	/**
	 * Copies data into the buffer, interpreting it using the specified format and
	 * samplerate.
	 */
	public abstract void alBufferData(ALuint buffer, ALenum format, ALvoid *data, ALsizei size, ALsizei samplerate);

	/* Set buffer parameters. */
	public abstract void alBufferf(ALuint buffer, ALenum param, ALfloat value);
	public abstract void alBuffer3f(ALuint buffer, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3);
	public abstract void alBufferfv(ALuint buffer, ALenum param, ALfloat *values);
	public abstract void alBufferi(ALuint buffer, ALenum param, ALint value);
	public abstract void alBuffer3i(ALuint buffer, ALenum param, ALint value1, ALint value2, ALint value3);
	public abstract void alBufferiv(ALuint buffer, ALenum param, ALint *values);

	/* Get buffer parameters. */
	public abstract void alGetBufferf(ALuint buffer, ALenum param, ALfloat *value);
	public abstract void alGetBuffer3f(ALuint buffer, ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3);
	public abstract void alGetBufferfv(ALuint buffer, ALenum param, ALfloat *values);
	public abstract void alGetBufferi(ALuint buffer, ALenum param, ALint *value);
	public abstract void alGetBuffer3i(ALuint buffer, ALenum param, ALint *value1, ALint *value2, ALint *value3);
	public abstract void alGetBufferiv(ALuint buffer, ALenum param, ALint *values);
}