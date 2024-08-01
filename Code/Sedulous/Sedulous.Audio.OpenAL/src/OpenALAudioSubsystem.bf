namespace Sedulous.Audio.OpenAL;

using OpenALNative;

class OpenALAudioSubsystem : AudioSubsystem
{
	static this()
	{

	}

	public this()
	{
		ALCdevice* device = OpenALNative.alcOpenDevice(null);

		int32 error = OpenALNative.alcGetError(device);
	}
}