namespace Sedulous.RHI.DirectX12;

enum DxcValidatorFlags : int32
{
    Default = 0,
    InPlaceEdit = 1,
    RootSignatureOnly = 2,
    ModuleOnly = 4,
    ValidMask = 0x7,
}