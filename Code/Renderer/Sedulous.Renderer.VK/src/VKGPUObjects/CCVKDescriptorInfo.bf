using Bulkan;
using System;
namespace Sedulous.Renderer.VK.Internal;

[CRepr, Union]
struct CCVKDescriptorInfo
{
	public VkDescriptorImageInfo image;
	public VkDescriptorBufferInfo buffer;
	public VkBufferView texelBufferView;
}