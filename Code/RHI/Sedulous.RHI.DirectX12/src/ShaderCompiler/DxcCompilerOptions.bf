namespace Sedulous.RHI.DirectX12;

struct DxcCompilerOptions
{
	public DxcShaderModel ShaderModel { get; set mut; } = DxcShaderModel.Model6_0;
	public bool EnableDebugInfo { get; set mut; }
	public bool EnableDebugInfoSlimFormat { get; set mut; }
	public bool SkipValidation { get; set mut; }
	public bool SkipOptimizations { get; set mut; }
	public bool PackMatrixRowMajor { get; set mut; }
	public bool PackMatrixColumnMajor { get; set mut; }
	public bool AvoidFlowControl { get; set mut; }
	public bool PreferFlowControl { get; set mut; }
	public bool EnableStrictness { get; set mut; }
	public bool EnableBackwardCompatibility { get; set mut; }
	public bool IEEEStrictness { get; set mut; }
	public bool Enable16bitTypes { get; set mut; }
	public int32 OptimizationLevel { get; set mut; } = 3;
	public bool WarningsAreErrors { get; set mut; }
	public bool ResourcesMayAlias { get; set mut; }
	public bool AllResourcesBound { get; set mut; }

	public int32 HLSLVersion { get; set mut; } = 2018;

	public bool StripReflectionIntoSeparateBlob { get; set mut; } = true;

	public int32 VkBufferShift { get; set mut; }
	public int32 VkBufferShiftSet { get; set mut; }
	public int32 VkTextureShift { get; set mut; }
	public int32 VkTextureShiftSet { get; set mut; }
	public int32 VkSamplerShift { get; set mut; }
	public int32 VkSamplerShiftSet { get; set mut; }
	public int32 VkUAVShift { get; set mut; }
	public int32 VkUAVShiftSet { get; set mut; }

	/// <summary>
	/// Generate SPIR-V code
	/// </summary>
	public bool GenerateSpirv { get; set mut; } = false;

	public bool VkUseGLLayout { get; set mut; } = false;
	public bool VkUseDXLayout { get; set mut; } = true;
	public bool VkUseScalarLayout { get; set mut; } = false;
	public bool VkUseDXPositionW { get; set mut; } = true;
	public bool SpvFlattenResourceArrays { get; set mut; } = false;
	public bool SpvReflect { get; set mut; } = false;
	public int32 SpvTargetEnvMajor { get; set mut; } = 1;
	public int32 SpirvTargetEnvMinor { get; set mut; } = 1;
}