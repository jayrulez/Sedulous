namespace OpenALNative;

extension OpenALNativeImpl
{
	/** Create and attach a context to the given device. */
	public abstract ALCcontext* alcCreateContext(ALCdevice *device, ALCint *attrlist);
	/**
	 * Makes the given context the active process-wide context. Passing NULL clears
	 * the active context.
	 */
	public abstract ALCboolean alcMakeContextCurrent(ALCcontext *context);
	/** Resumes processing updates for the given context. */
	public abstract void alcProcessContext(ALCcontext *context);
	/** Suspends updates for the given context. */
	public abstract void alcSuspendContext(ALCcontext *context);
	/** Remove a context from its device and destroys it. */
	public abstract void alcDestroyContext(ALCcontext *context);
	/** Returns the currently active context. */
	public abstract ALCcontext* alcGetCurrentContext();
	/** Returns the device that a particular context is attached to. */
	public abstract ALCdevice* alcGetContextsDevice(ALCcontext *context);

	/* Device management. */

	/** Opens the named playback device. */
	public abstract ALCdevice* alcOpenDevice(ALCchar *devicename);
	/** Closes the given playback device. */
	public abstract ALCboolean alcCloseDevice(ALCdevice *device);

	/* Error support. */

	/** Obtain the most recent Device error. */
	public abstract ALCenum alcGetError(ALCdevice *device);

	/* Extension support. */

	/**
	 * Query for the presence of an extension on the device. Pass a NULL device to
	 * query a device-inspecific extension.
	 */
	public abstract ALCboolean alcIsExtensionPresent(ALCdevice *device, ALCchar *extname);
	/**
	 * Retrieve the address of a function. Given a non-NULL device, the returned
	 * function may be device-specific.
	 */
	public abstract ALCvoid* alcGetProcAddress(ALCdevice *device, ALCchar *funcname);
	/**
	 * Retrieve the value of an enum. Given a non-NULL device, the returned value
	 * may be device-specific.
	 */
	public abstract ALCenum alcGetEnumValue(ALCdevice *device, ALCchar *enumname);

	/* Query functions. */

	/** Returns information about the device, and error strings. */
	public abstract ALCchar* alcGetString(ALCdevice *device, ALCenum param);
	/** Returns information about the device and the version of OpenAL. */
	public abstract void alcGetIntegerv(ALCdevice *device, ALCenum param, ALCsizei size, ALCint *values);

	/* Capture functions. */

	/**
	 * Opens the named capture device with the given frequency, format, and buffer
	 * size.
	 */
	public abstract ALCdevice* alcCaptureOpenDevice(ALCchar *devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize);
	/** Closes the given capture device. */
	public abstract ALCboolean alcCaptureCloseDevice(ALCdevice *device);
	/** Starts capturing samples into the device buffer. */
	public abstract void alcCaptureStart(ALCdevice *device);
	/** Stops capturing samples. Samples in the device buffer remain available. */
	public abstract void alcCaptureStop(ALCdevice *device);
	/** Reads samples from the device buffer. */
	public abstract void alcCaptureSamples(ALCdevice *device, ALCvoid *buffer, ALCsizei samples);
}