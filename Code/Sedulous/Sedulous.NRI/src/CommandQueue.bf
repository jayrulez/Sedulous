using System;
using Sedulous.NRI.Helpers;
namespace Sedulous.NRI;

interface CommandQueue
{
	public void SetDebugName(char8* name);

	public void SubmitWork(WorkSubmissionDesc workSubmissionDesc, DeviceSemaphore deviceSemaphore);
	public void WaitForSemaphore(DeviceSemaphore deviceSemaphore);

	public Result ChangeResourceStates(TransitionBarrierDesc transitionBarriers);
	public Result UploadData(TextureUploadDesc* textureUploadDescs, uint32 textureUploadDescNum,
		BufferUploadDesc* bufferUploadDescs, uint32 bufferUploadDescNum);
	public Result WaitForIdle();
}