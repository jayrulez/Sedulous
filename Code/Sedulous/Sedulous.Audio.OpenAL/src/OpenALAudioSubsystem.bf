using Sedulous.Audio.OpenAL.Bindings;
namespace Sedulous.Audio.OpenAL;

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