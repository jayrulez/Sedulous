using Bulkan;
using static Bulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using System;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL.VK;

    internal class VKShader : Shader
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkShaderModule _shaderModule;
        private bool _disposed;
        private String _name;

        public VkShaderModule ShaderModule => _shaderModule;

        public override bool IsDisposed => _disposed;

        public this(VKGraphicsDevice gd, in ShaderDescription description)
            : base(description.Stage, description.EntryPoint)
        {
            _gd = gd;

            VkShaderModuleCreateInfo shaderModuleCI = VkShaderModuleCreateInfo(){sType = .VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO};

            shaderModuleCI.codeSize = (uint)description.ShaderBytes.Count;
            shaderModuleCI.pCode = (uint32*)description.ShaderBytes.Ptr;
            VkResult result = vkCreateShaderModule(gd.Device, &shaderModuleCI, null, &_shaderModule);
            CheckResult(result);
        }

        public override String Name
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
