using System;

namespace OpenALNative;

using internal OpenALNative;

extension OpenALNativeImpl_Default
{
	/** Create and attach a context to the given device. */
	[CallingConvention(.Cdecl)]
	private function ALCcontext* alcCreateContext_Delegate(ALCdevice *device, ALCint *attrlist);
	private readonly alcCreateContext_Delegate p_alcCreateContext = lib.LoadFunction<alcCreateContext_Delegate>("alcCreateContext", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCcontext* alcCreateContext(ALCdevice *device, ALCint *attrlist) => p_alcCreateContext(device, attrlist);


	/**
	* Makes the given context the active process-wide context. Passing NULL clears
	* the active context.
	*/
	[CallingConvention(.Cdecl)]
	private function ALCboolean alcMakeContextCurrent_Delegate(ALCcontext *context);
	private readonly alcMakeContextCurrent_Delegate p_alcMakeContextCurrent = lib.LoadFunction<alcMakeContextCurrent_Delegate>("alcMakeContextCurrent", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCboolean alcMakeContextCurrent(ALCcontext *context) => p_alcMakeContextCurrent(context);


	/** Resumes processing updates for the given context. */
	[CallingConvention(.Cdecl)]
	private function void alcProcessContext_Delegate(ALCcontext *context);
	private readonly alcProcessContext_Delegate p_alcProcessContext = lib.LoadFunction<alcProcessContext_Delegate>("alcProcessContext", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alcProcessContext(ALCcontext *context) => p_alcProcessContext(context);


	/** Suspends updates for the given context. */
	[CallingConvention(.Cdecl)]
	private function void alcSuspendContext_Delegate(ALCcontext *context);
	private readonly alcSuspendContext_Delegate p_alcSuspendContext = lib.LoadFunction<alcSuspendContext_Delegate>("alcSuspendContext", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alcSuspendContext(ALCcontext *context) => p_alcSuspendContext(context);


	/** Remove a context from its device and destroys it. */
	[CallingConvention(.Cdecl)]
	private function void alcDestroyContext_Delegate(ALCcontext *context);
	private readonly alcDestroyContext_Delegate p_alcDestroyContext = lib.LoadFunction<alcDestroyContext_Delegate>("alcDestroyContext", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alcDestroyContext(ALCcontext *context) => p_alcDestroyContext(context);


	/** Returns the currently active context. */
	[CallingConvention(.Cdecl)]
	private function ALCcontext* alcGetCurrentContext_Delegate();
	private readonly alcGetCurrentContext_Delegate p_alcGetCurrentContext = lib.LoadFunction<alcGetCurrentContext_Delegate>("alcGetCurrentContext", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCcontext* alcGetCurrentContext() => p_alcGetCurrentContext();


	/** Returns the device that a particular context is attached to. */
	[CallingConvention(.Cdecl)]
	private function ALCdevice* alcGetContextsDevice_Delegate(ALCcontext *context);
	private readonly alcGetContextsDevice_Delegate p_alcGetContextsDevice = lib.LoadFunction<alcGetContextsDevice_Delegate>("alcGetContextsDevice", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCdevice* alcGetContextsDevice(ALCcontext *context) => p_alcGetContextsDevice(context);



	/* Device management. */

	/** Opens the named playback device. */
	[CallingConvention(.Cdecl)]
	private function ALCdevice* alcOpenDevice_Delegate(ALCchar *devicename);
	private readonly alcOpenDevice_Delegate p_alcOpenDevice = lib.LoadFunction<alcOpenDevice_Delegate>("alcOpenDevice", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCdevice* alcOpenDevice(ALCchar *devicename) => p_alcOpenDevice(devicename);


	/** Closes the given playback device. */
	[CallingConvention(.Cdecl)]
	private function ALCboolean alcCloseDevice_Delegate(ALCdevice *device);
	private readonly alcCloseDevice_Delegate p_alcCloseDevice = lib.LoadFunction<alcCloseDevice_Delegate>("alcCloseDevice", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCboolean alcCloseDevice(ALCdevice *device) => p_alcCloseDevice(device);



	/* Error support. */

	/** Obtain the most recent Device error. */
	[CallingConvention(.Cdecl)]
	private function ALCenum alcGetError_Delegate(ALCdevice *device);
	private readonly alcGetError_Delegate p_alcGetError = lib.LoadFunction<alcGetError_Delegate>("alcGetError", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCenum alcGetError(ALCdevice *device) => p_alcGetError(device);



	/* Extension support. */

	/**
	* Query for the presence of an extension on the device. Pass a NULL device to
	* query a device-inspecific extension.
	*/
	[CallingConvention(.Cdecl)]
	private function ALCboolean alcIsExtensionPresent_Delegate(ALCdevice *device, ALCchar *extname);
	private readonly alcIsExtensionPresent_Delegate p_alcIsExtensionPresent = lib.LoadFunction<alcIsExtensionPresent_Delegate>("alcIsExtensionPresent", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCboolean alcIsExtensionPresent(ALCdevice *device, ALCchar *extname) => p_alcIsExtensionPresent(device, extname);


	/**
	* Retrieve the address of a function. Given a non-NULL device, the returned
	* function may be device-specific.
	*/
	[CallingConvention(.Cdecl)]
	private function ALCvoid* alcGetProcAddress_Delegate(ALCdevice *device, ALCchar *funcname);
	private readonly alcGetProcAddress_Delegate p_alcGetProcAddress = lib.LoadFunction<alcGetProcAddress_Delegate>("alcGetProcAddress", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCvoid* alcGetProcAddress(ALCdevice *device, ALCchar *funcname) => p_alcGetProcAddress(device, funcname);


	/**
	* Retrieve the value of an enum. Given a non-NULL device, the returned value
	* may be device-specific.
	*/
	[CallingConvention(.Cdecl)]
	private function ALCenum alcGetEnumValue_Delegate(ALCdevice *device, ALCchar *enumname);
	private readonly alcGetEnumValue_Delegate p_alcGetEnumValue = lib.LoadFunction<alcGetEnumValue_Delegate>("alcGetEnumValue", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCenum alcGetEnumValue(ALCdevice *device, ALCchar *enumname) => p_alcGetEnumValue(device, enumname);



	/* Query functions. */

	/** Returns information about the device, and error strings. */
	[CallingConvention(.Cdecl)]
	private function ALCchar* alcGetString_Delegate(ALCdevice *device, ALCenum param);
	private readonly alcGetString_Delegate p_alcGetString = lib.LoadFunction<alcGetString_Delegate>("alcGetString", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCchar* alcGetString(ALCdevice *device, ALCenum param) => p_alcGetString(device, param);


	/** Returns information about the device and the version of OpenAL. */
	[CallingConvention(.Cdecl)]
	private function void alcGetIntegerv_Delegate(ALCdevice *device, ALCenum param, ALCsizei size, ALCint *values);
	private readonly alcGetIntegerv_Delegate p_alcGetIntegerv = lib.LoadFunction<alcGetIntegerv_Delegate>("alcGetIntegerv", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alcGetIntegerv(ALCdevice *device, ALCenum param, ALCsizei size, ALCint *values) => p_alcGetIntegerv(device, param, size, values);



	/* Capture functions. */

	/**
	* Opens the named capture device with the given frequency, format, and buffer
	* size.
	*/
	[CallingConvention(.Cdecl)]
	private function ALCdevice* alcCaptureOpenDevice_Delegate(ALCchar *devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize);
	private readonly alcCaptureOpenDevice_Delegate p_alcCaptureOpenDevice = lib.LoadFunction<alcCaptureOpenDevice_Delegate>("alcCaptureOpenDevice", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCdevice* alcCaptureOpenDevice(ALCchar *devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize) => p_alcCaptureOpenDevice(devicename, frequency, format, buffersize);


	/** Closes the given capture device. */
	[CallingConvention(.Cdecl)]
	private function ALCboolean alcCaptureCloseDevice_Delegate(ALCdevice *device);
	private readonly alcCaptureCloseDevice_Delegate p_alcCaptureCloseDevice = lib.LoadFunction<alcCaptureCloseDevice_Delegate>("alcCaptureCloseDevice", ..?, sInvokeErrorCallback);
	[Inline]
	public override ALCboolean alcCaptureCloseDevice(ALCdevice *device) => p_alcCaptureCloseDevice(device);


	/** Starts capturing samples into the device buffer. */
	[CallingConvention(.Cdecl)]
	private function void alcCaptureStart_Delegate(ALCdevice *device);
	private readonly alcCaptureStart_Delegate p_alcCaptureStart = lib.LoadFunction<alcCaptureStart_Delegate>("alcCaptureStart", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alcCaptureStart(ALCdevice *device) => p_alcCaptureStart(device);


	/** Stops capturing samples. Samples in the device buffer remain available. */
	[CallingConvention(.Cdecl)]
	private function void alcCaptureStop_Delegate(ALCdevice *device);
	private readonly alcCaptureStop_Delegate p_alcCaptureStop = lib.LoadFunction<alcCaptureStop_Delegate>("alcCaptureStop", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alcCaptureStop(ALCdevice *device) => p_alcCaptureStop(device);


	/** Reads samples from the device buffer. */
	[CallingConvention(.Cdecl)]
	private function void alcCaptureSamples_Delegate(ALCdevice *device, ALCvoid *buffer, ALCsizei samples);
	private readonly alcCaptureSamples_Delegate p_alcCaptureSamples = lib.LoadFunction<alcCaptureSamples_Delegate>("alcCaptureSamples", ..?, sInvokeErrorCallback);
	[Inline]
	public override void alcCaptureSamples(ALCdevice *device, ALCvoid *buffer, ALCsizei samples) => p_alcCaptureSamples(device, buffer, samples);
}