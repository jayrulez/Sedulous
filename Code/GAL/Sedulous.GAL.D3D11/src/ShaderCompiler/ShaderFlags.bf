using System;
namespace Sedulous.GAL.D3D11.ShaderCompiler;

[AllowDuplicates]
enum ShaderFlags
{
    Debug = 0x1,
    SkipValidation = 0x2,
    SkipOptimization = 0x4,
    PackMatrixRowMajor = 0x8,
    PackMatrixColumnMajor = 0x10,
    PartialPrecision = 0x20,
    ForceVsSoftwareNoOpt = 0x40,
    ForcePsSoftwareNoOpt = 0x80,
    NoPreshader = 0x100,
    AvoidFlowControl = 0x200,
    PreferFlowControl = 0x400,
    EnableStrictness = 0x800,
    EnableBackwardsCompatibility = 0x1000,
    IeeeStrictness = 0x2000,
    OptimizationLevel0 = 0x4000,
    OptimizationLevel1 = 0x0,
    OptimizationLevel2 = 0xC000,
    OptimizationLevel3 = 0x8000,
    Reserved16 = 0x10000,
    Reserved17 = 0x20000,
    WarningsAreErrors = 0x40000,
    DebugNameForSource = 0x400000,
    DebugNameForBinary = 0x800000,
    //
    // Summary:
    //     Synthetic NONE value
    None = 0x0
}