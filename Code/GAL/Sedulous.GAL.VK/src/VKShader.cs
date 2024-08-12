using Vulkan;
using static Vulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using System;

namespace Sedulous.GAL.VK
{
    internal class VKShader : Shader
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkShaderModule _shaderModule;
        private bool _disposed;
        private string _name;

        public VkShaderModule ShaderModule => _shaderModule;

        public override bool IsDisposed => _disposed;

        public VKShader(VKGraphicsDevice gd, ref ShaderDescription description)
            : base(description.Stage, description.EntryPoint)
        {
            _gd = gd;

            VkShaderModuleCreateInfo shaderModuleCI = VkShaderModuleCreateInfo.New();
            fixed (uint8* codePtr = description.ShaderBytes)
            {
                shaderModuleCI.codeSize = (UIntPtr)description.ShaderBytes.Length;
                shaderModuleCI.pCode = (uint32*)codePtr;
                VkResult result = vkCreateShaderModule(gd.Device, ref shaderModuleCI, null, out _shaderModule);
                CheckResult(result);
            }
        }

        public override string Name
        {
            get => _name;
            set
            {
                _name = value;
                _gd.SetResourceName(this, value);
            }
        }

        public override void Dispose()
        {
            if (!_disposed)
            {
                _disposed = true;
                vkDestroyShaderModule(_gd.Device, ShaderModule, null);
            }
        }
    }
}
