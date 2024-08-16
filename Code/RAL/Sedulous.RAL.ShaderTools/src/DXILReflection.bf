using System.Collections;
using Dxc_Beef;
using System;
namespace Sedulous.RAL.ShaderTools;

#region D3D12Support

typealias PSTR = uint8*;
typealias BOOL = int32;

[AllowDuplicates]
public enum D3D_PRIMITIVE_TOPOLOGY : int32
{
	D3D_PRIMITIVE_TOPOLOGY_UNDEFINED = 0,
	D3D_PRIMITIVE_TOPOLOGY_POINTLIST = 1,
	D3D_PRIMITIVE_TOPOLOGY_LINELIST = 2,
	D3D_PRIMITIVE_TOPOLOGY_LINESTRIP = 3,
	D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST = 4,
	D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP = 5,
	D3D_PRIMITIVE_TOPOLOGY_LINELIST_ADJ = 10,
	D3D_PRIMITIVE_TOPOLOGY_LINESTRIP_ADJ = 11,
	D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST_ADJ = 12,
	D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP_ADJ = 13,
	D3D_PRIMITIVE_TOPOLOGY_1_CONTROL_POINT_PATCHLIST = 33,
	D3D_PRIMITIVE_TOPOLOGY_2_CONTROL_POINT_PATCHLIST = 34,
	D3D_PRIMITIVE_TOPOLOGY_3_CONTROL_POINT_PATCHLIST = 35,
	D3D_PRIMITIVE_TOPOLOGY_4_CONTROL_POINT_PATCHLIST = 36,
	D3D_PRIMITIVE_TOPOLOGY_5_CONTROL_POINT_PATCHLIST = 37,
	D3D_PRIMITIVE_TOPOLOGY_6_CONTROL_POINT_PATCHLIST = 38,
	D3D_PRIMITIVE_TOPOLOGY_7_CONTROL_POINT_PATCHLIST = 39,
	D3D_PRIMITIVE_TOPOLOGY_8_CONTROL_POINT_PATCHLIST = 40,
	D3D_PRIMITIVE_TOPOLOGY_9_CONTROL_POINT_PATCHLIST = 41,
	D3D_PRIMITIVE_TOPOLOGY_10_CONTROL_POINT_PATCHLIST = 42,
	D3D_PRIMITIVE_TOPOLOGY_11_CONTROL_POINT_PATCHLIST = 43,
	D3D_PRIMITIVE_TOPOLOGY_12_CONTROL_POINT_PATCHLIST = 44,
	D3D_PRIMITIVE_TOPOLOGY_13_CONTROL_POINT_PATCHLIST = 45,
	D3D_PRIMITIVE_TOPOLOGY_14_CONTROL_POINT_PATCHLIST = 46,
	D3D_PRIMITIVE_TOPOLOGY_15_CONTROL_POINT_PATCHLIST = 47,
	D3D_PRIMITIVE_TOPOLOGY_16_CONTROL_POINT_PATCHLIST = 48,
	D3D_PRIMITIVE_TOPOLOGY_17_CONTROL_POINT_PATCHLIST = 49,
	D3D_PRIMITIVE_TOPOLOGY_18_CONTROL_POINT_PATCHLIST = 50,
	D3D_PRIMITIVE_TOPOLOGY_19_CONTROL_POINT_PATCHLIST = 51,
	D3D_PRIMITIVE_TOPOLOGY_20_CONTROL_POINT_PATCHLIST = 52,
	D3D_PRIMITIVE_TOPOLOGY_21_CONTROL_POINT_PATCHLIST = 53,
	D3D_PRIMITIVE_TOPOLOGY_22_CONTROL_POINT_PATCHLIST = 54,
	D3D_PRIMITIVE_TOPOLOGY_23_CONTROL_POINT_PATCHLIST = 55,
	D3D_PRIMITIVE_TOPOLOGY_24_CONTROL_POINT_PATCHLIST = 56,
	D3D_PRIMITIVE_TOPOLOGY_25_CONTROL_POINT_PATCHLIST = 57,
	D3D_PRIMITIVE_TOPOLOGY_26_CONTROL_POINT_PATCHLIST = 58,
	D3D_PRIMITIVE_TOPOLOGY_27_CONTROL_POINT_PATCHLIST = 59,
	D3D_PRIMITIVE_TOPOLOGY_28_CONTROL_POINT_PATCHLIST = 60,
	D3D_PRIMITIVE_TOPOLOGY_29_CONTROL_POINT_PATCHLIST = 61,
	D3D_PRIMITIVE_TOPOLOGY_30_CONTROL_POINT_PATCHLIST = 62,
	D3D_PRIMITIVE_TOPOLOGY_31_CONTROL_POINT_PATCHLIST = 63,
	D3D_PRIMITIVE_TOPOLOGY_32_CONTROL_POINT_PATCHLIST = 64,
}


[AllowDuplicates]
public enum D3D_PRIMITIVE : int32
{
	D3D_PRIMITIVE_UNDEFINED = 0,
	D3D_PRIMITIVE_POINT = 1,
	D3D_PRIMITIVE_LINE = 2,
	D3D_PRIMITIVE_TRIANGLE = 3,
	D3D_PRIMITIVE_LINE_ADJ = 6,
	D3D_PRIMITIVE_TRIANGLE_ADJ = 7,
	D3D_PRIMITIVE_1_CONTROL_POINT_PATCH = 8,
	D3D_PRIMITIVE_2_CONTROL_POINT_PATCH = 9,
	D3D_PRIMITIVE_3_CONTROL_POINT_PATCH = 10,
	D3D_PRIMITIVE_4_CONTROL_POINT_PATCH = 11,
	D3D_PRIMITIVE_5_CONTROL_POINT_PATCH = 12,
	D3D_PRIMITIVE_6_CONTROL_POINT_PATCH = 13,
	D3D_PRIMITIVE_7_CONTROL_POINT_PATCH = 14,
	D3D_PRIMITIVE_8_CONTROL_POINT_PATCH = 15,
	D3D_PRIMITIVE_9_CONTROL_POINT_PATCH = 16,
	D3D_PRIMITIVE_10_CONTROL_POINT_PATCH = 17,
	D3D_PRIMITIVE_11_CONTROL_POINT_PATCH = 18,
	D3D_PRIMITIVE_12_CONTROL_POINT_PATCH = 19,
	D3D_PRIMITIVE_13_CONTROL_POINT_PATCH = 20,
	D3D_PRIMITIVE_14_CONTROL_POINT_PATCH = 21,
	D3D_PRIMITIVE_15_CONTROL_POINT_PATCH = 22,
	D3D_PRIMITIVE_16_CONTROL_POINT_PATCH = 23,
	D3D_PRIMITIVE_17_CONTROL_POINT_PATCH = 24,
	D3D_PRIMITIVE_18_CONTROL_POINT_PATCH = 25,
	D3D_PRIMITIVE_19_CONTROL_POINT_PATCH = 26,
	D3D_PRIMITIVE_20_CONTROL_POINT_PATCH = 27,
	D3D_PRIMITIVE_21_CONTROL_POINT_PATCH = 28,
	D3D_PRIMITIVE_22_CONTROL_POINT_PATCH = 29,
	D3D_PRIMITIVE_23_CONTROL_POINT_PATCH = 30,
	D3D_PRIMITIVE_24_CONTROL_POINT_PATCH = 31,
	D3D_PRIMITIVE_25_CONTROL_POINT_PATCH = 32,
	D3D_PRIMITIVE_26_CONTROL_POINT_PATCH = 33,
	D3D_PRIMITIVE_27_CONTROL_POINT_PATCH = 34,
	D3D_PRIMITIVE_28_CONTROL_POINT_PATCH = 35,
	D3D_PRIMITIVE_29_CONTROL_POINT_PATCH = 36,
	D3D_PRIMITIVE_30_CONTROL_POINT_PATCH = 37,
	D3D_PRIMITIVE_31_CONTROL_POINT_PATCH = 38,
	D3D_PRIMITIVE_32_CONTROL_POINT_PATCH = 39,
}

[AllowDuplicates]
public enum D3D_CBUFFER_TYPE : int32
{
	D3D_CT_CBUFFER = 0,
	D3D_CT_TBUFFER = 1,
	D3D_CT_INTERFACE_POINTERS = 2,
	D3D_CT_RESOURCE_BIND_INFO = 3,
}

[AllowDuplicates]
public enum D3D_SHADER_VARIABLE_CLASS : int32
{
	D3D_SVC_SCALAR = 0,
	D3D_SVC_VECTOR = 1,
	D3D_SVC_MATRIX_ROWS = 2,
	D3D_SVC_MATRIX_COLUMNS = 3,
	D3D_SVC_OBJECT = 4,
	D3D_SVC_STRUCT = 5,
	D3D_SVC_INTERFACE_CLASS = 6,
	D3D_SVC_INTERFACE_POINTER = 7,
	D3D_SVC_FORCE_DWORD = 2147483647,
}


[AllowDuplicates]
public enum D3D_SHADER_VARIABLE_TYPE : int32
{
	D3D_SVT_VOID = 0,
	D3D_SVT_BOOL = 1,
	D3D_SVT_INT = 2,
	D3D_SVT_FLOAT = 3,
	D3D_SVT_STRING = 4,
	D3D_SVT_TEXTURE = 5,
	D3D_SVT_TEXTURE1D = 6,
	D3D_SVT_TEXTURE2D = 7,
	D3D_SVT_TEXTURE3D = 8,
	D3D_SVT_TEXTURECUBE = 9,
	D3D_SVT_SAMPLER = 10,
	D3D_SVT_SAMPLER1D = 11,
	D3D_SVT_SAMPLER2D = 12,
	D3D_SVT_SAMPLER3D = 13,
	D3D_SVT_SAMPLERCUBE = 14,
	D3D_SVT_PIXELSHADER = 15,
	D3D_SVT_VERTEXSHADER = 16,
	D3D_SVT_PIXELFRAGMENT = 17,
	D3D_SVT_VERTEXFRAGMENT = 18,
	D3D_SVT_UINT = 19,
	D3D_SVT_UINT8 = 20,
	D3D_SVT_GEOMETRYSHADER = 21,
	D3D_SVT_RASTERIZER = 22,
	D3D_SVT_DEPTHSTENCIL = 23,
	D3D_SVT_BLEND = 24,
	D3D_SVT_BUFFER = 25,
	D3D_SVT_CBUFFER = 26,
	D3D_SVT_TBUFFER = 27,
	D3D_SVT_TEXTURE1DARRAY = 28,
	D3D_SVT_TEXTURE2DARRAY = 29,
	D3D_SVT_RENDERTARGETVIEW = 30,
	D3D_SVT_DEPTHSTENCILVIEW = 31,
	D3D_SVT_TEXTURE2DMS = 32,
	D3D_SVT_TEXTURE2DMSARRAY = 33,
	D3D_SVT_TEXTURECUBEARRAY = 34,
	D3D_SVT_HULLSHADER = 35,
	D3D_SVT_DOMAINSHADER = 36,
	D3D_SVT_INTERFACE_POINTER = 37,
	D3D_SVT_COMPUTESHADER = 38,
	D3D_SVT_DOUBLE = 39,
	D3D_SVT_RWTEXTURE1D = 40,
	D3D_SVT_RWTEXTURE1DARRAY = 41,
	D3D_SVT_RWTEXTURE2D = 42,
	D3D_SVT_RWTEXTURE2DARRAY = 43,
	D3D_SVT_RWTEXTURE3D = 44,
	D3D_SVT_RWBUFFER = 45,
	D3D_SVT_BYTEADDRESS_BUFFER = 46,
	D3D_SVT_RWBYTEADDRESS_BUFFER = 47,
	D3D_SVT_STRUCTURED_BUFFER = 48,
	D3D_SVT_RWSTRUCTURED_BUFFER = 49,
	D3D_SVT_APPEND_STRUCTURED_BUFFER = 50,
	D3D_SVT_CONSUME_STRUCTURED_BUFFER = 51,
	D3D_SVT_MIN8FLOAT = 52,
	D3D_SVT_MIN10FLOAT = 53,
	D3D_SVT_MIN16FLOAT = 54,
	D3D_SVT_MIN12INT = 55,
	D3D_SVT_MIN16INT = 56,
	D3D_SVT_MIN16UINT = 57,
	D3D_SVT_INT16 = 58,
	D3D_SVT_UINT16 = 59,
	D3D_SVT_FLOAT16 = 60,
	D3D_SVT_INT64 = 61,
	D3D_SVT_UINT64 = 62,
	D3D_SVT_FORCE_DWORD = 2147483647,
}

[AllowDuplicates]
public enum D3D_TESSELLATOR_DOMAIN : int32
{
	D3D_TESSELLATOR_DOMAIN_UNDEFINED = 0,
	D3D_TESSELLATOR_DOMAIN_ISOLINE = 1,
	D3D_TESSELLATOR_DOMAIN_TRI = 2,
	D3D_TESSELLATOR_DOMAIN_QUAD = 3,
}


[AllowDuplicates]
public enum D3D_TESSELLATOR_PARTITIONING : int32
{
	D3D_TESSELLATOR_PARTITIONING_UNDEFINED = 0,
	D3D_TESSELLATOR_PARTITIONING_INTEGER = 1,
	D3D_TESSELLATOR_PARTITIONING_POW2 = 2,
	D3D_TESSELLATOR_PARTITIONING_FRACTIONAL_ODD = 3,
	D3D_TESSELLATOR_PARTITIONING_FRACTIONAL_EVEN = 4,
}


[AllowDuplicates]
public enum D3D_TESSELLATOR_OUTPUT_PRIMITIVE : int32
{
	D3D_TESSELLATOR_OUTPUT_UNDEFINED = 0,
	D3D_TESSELLATOR_OUTPUT_POINT = 1,
	D3D_TESSELLATOR_OUTPUT_LINE = 2,
	D3D_TESSELLATOR_OUTPUT_TRIANGLE_CW = 3,
	D3D_TESSELLATOR_OUTPUT_TRIANGLE_CCW = 4,
}

[AllowDuplicates]
public enum D3D_SHADER_INPUT_TYPE : int32
{
	D3D_SIT_CBUFFER = 0,
	D3D_SIT_TBUFFER = 1,
	D3D_SIT_TEXTURE = 2,
	D3D_SIT_SAMPLER = 3,
	D3D_SIT_UAV_RWTYPED = 4,
	D3D_SIT_STRUCTURED = 5,
	D3D_SIT_UAV_RWSTRUCTURED = 6,
	D3D_SIT_BYTEADDRESS = 7,
	D3D_SIT_UAV_RWBYTEADDRESS = 8,
	D3D_SIT_UAV_APPEND_STRUCTURED = 9,
	D3D_SIT_UAV_CONSUME_STRUCTURED = 10,
	D3D_SIT_UAV_RWSTRUCTURED_WITH_COUNTER = 11,
	D3D_SIT_RTACCELERATIONSTRUCTURE = 12,
	D3D_SIT_UAV_FEEDBACKTEXTURE = 13,
}

[AllowDuplicates]
public enum D3D_RESOURCE_RETURN_TYPE : int32
{
	D3D_RETURN_TYPE_UNORM = 1,
	D3D_RETURN_TYPE_SNORM = 2,
	D3D_RETURN_TYPE_SINT = 3,
	D3D_RETURN_TYPE_UINT = 4,
	D3D_RETURN_TYPE_FLOAT = 5,
	D3D_RETURN_TYPE_MIXED = 6,
	D3D_RETURN_TYPE_DOUBLE = 7,
	D3D_RETURN_TYPE_CONTINUED = 8,
}

[AllowDuplicates]
public enum D3D_SRV_DIMENSION : int32
{
	D3D_SRV_DIMENSION_UNKNOWN = 0,
	D3D_SRV_DIMENSION_BUFFER = 1,
	D3D_SRV_DIMENSION_TEXTURE1D = 2,
	D3D_SRV_DIMENSION_TEXTURE1DARRAY = 3,
	D3D_SRV_DIMENSION_TEXTURE2D = 4,
	D3D_SRV_DIMENSION_TEXTURE2DARRAY = 5,
	D3D_SRV_DIMENSION_TEXTURE2DMS = 6,
	D3D_SRV_DIMENSION_TEXTURE2DMSARRAY = 7,
	D3D_SRV_DIMENSION_TEXTURE3D = 8,
	D3D_SRV_DIMENSION_TEXTURECUBE = 9,
	D3D_SRV_DIMENSION_TEXTURECUBEARRAY = 10,
	D3D_SRV_DIMENSION_BUFFEREX = 11,
}

[AllowDuplicates]
public enum D3D_MIN_PRECISION : int32
{
	D3D_MIN_PRECISION_DEFAULT = 0,
	D3D_MIN_PRECISION_FLOAT_16 = 1,
	D3D_MIN_PRECISION_FLOAT_2_8 = 2,
	D3D_MIN_PRECISION_RESERVED = 3,
	D3D_MIN_PRECISION_SINT_16 = 4,
	D3D_MIN_PRECISION_UINT_16 = 5,
	D3D_MIN_PRECISION_ANY_16 = 240,
	D3D_MIN_PRECISION_ANY_10 = 241,
}

[AllowDuplicates]
public enum D3D_NAME : int32
{
	D3D_NAME_UNDEFINED = 0,
	D3D_NAME_POSITION = 1,
	D3D_NAME_CLIP_DISTANCE = 2,
	D3D_NAME_CULL_DISTANCE = 3,
	D3D_NAME_RENDER_TARGET_ARRAY_INDEX = 4,
	D3D_NAME_VIEWPORT_ARRAY_INDEX = 5,
	D3D_NAME_VERTEX_ID = 6,
	D3D_NAME_PRIMITIVE_ID = 7,
	D3D_NAME_INSTANCE_ID = 8,
	D3D_NAME_IS_FRONT_FACE = 9,
	D3D_NAME_SAMPLE_INDEX = 10,
	D3D_NAME_FINAL_QUAD_EDGE_TESSFACTOR = 11,
	D3D_NAME_FINAL_QUAD_INSIDE_TESSFACTOR = 12,
	D3D_NAME_FINAL_TRI_EDGE_TESSFACTOR = 13,
	D3D_NAME_FINAL_TRI_INSIDE_TESSFACTOR = 14,
	D3D_NAME_FINAL_LINE_DETAIL_TESSFACTOR = 15,
	D3D_NAME_FINAL_LINE_DENSITY_TESSFACTOR = 16,
	D3D_NAME_BARYCENTRICS = 23,
	D3D_NAME_SHADINGRATE = 24,
	D3D_NAME_CULLPRIMITIVE = 25,
	D3D_NAME_TARGET = 64,
	D3D_NAME_DEPTH = 65,
	D3D_NAME_COVERAGE = 66,
	D3D_NAME_DEPTH_GREATER_EQUAL = 67,
	D3D_NAME_DEPTH_LESS_EQUAL = 68,
	D3D_NAME_STENCIL_REF = 69,
	D3D_NAME_INNER_COVERAGE = 70,
}

[AllowDuplicates]
public enum D3D_FEATURE_LEVEL : int32
{
	D3D_FEATURE_LEVEL_1_0_CORE = 4096,
	D3D_FEATURE_LEVEL_9_1 = 37120,
	D3D_FEATURE_LEVEL_9_2 = 37376,
	D3D_FEATURE_LEVEL_9_3 = 37632,
	D3D_FEATURE_LEVEL_10_0 = 40960,
	D3D_FEATURE_LEVEL_10_1 = 41216,
	D3D_FEATURE_LEVEL_11_0 = 45056,
	D3D_FEATURE_LEVEL_11_1 = 45312,
	D3D_FEATURE_LEVEL_12_0 = 49152,
	D3D_FEATURE_LEVEL_12_1 = 49408,
	D3D_FEATURE_LEVEL_12_2 = 49664,
}

[AllowDuplicates]
public enum D3D_REGISTER_COMPONENT_TYPE : int32
{
	D3D_REGISTER_COMPONENT_UNKNOWN = 0,
	D3D_REGISTER_COMPONENT_UINT32 = 1,
	D3D_REGISTER_COMPONENT_SINT32 = 2,
	D3D_REGISTER_COMPONENT_FLOAT32 = 3,
}

[CRepr]
public struct D3D12_SHADER_BUFFER_DESC
{
	public PSTR Name;
	public D3D_CBUFFER_TYPE Type;
	public uint32 Variables;
	public uint32 Size;
	public uint32 uFlags;
}

[CRepr]
public struct D3D12_SHADER_TYPE_DESC
{
	public D3D_SHADER_VARIABLE_CLASS Class;
	public D3D_SHADER_VARIABLE_TYPE Type;
	public uint32 Rows;
	public uint32 Columns;
	public uint32 Elements;
	public uint32 Members;
	public uint32 Offset;
	public PSTR Name;
}

[CRepr]
public struct D3D12_SHADER_VARIABLE_DESC
{
	public PSTR Name;
	public uint32 StartOffset;
	public uint32 Size;
	public uint32 uFlags;
	public void* DefaultValue;
	public uint32 StartTexture;
	public uint32 TextureSize;
	public uint32 StartSampler;
	public uint32 SamplerSize;
}

[CRepr]
public struct D3D12_SHADER_DESC
{
	public uint32 Version;
	public PSTR Creator;
	public uint32 Flags;
	public uint32 ConstantBuffers;
	public uint32 BoundResources;
	public uint32 InputParameters;
	public uint32 OutputParameters;
	public uint32 InstructionCount;
	public uint32 TempRegisterCount;
	public uint32 TempArrayCount;
	public uint32 DefCount;
	public uint32 DclCount;
	public uint32 TextureNormalInstructions;
	public uint32 TextureLoadInstructions;
	public uint32 TextureCompInstructions;
	public uint32 TextureBiasInstructions;
	public uint32 TextureGradientInstructions;
	public uint32 FloatInstructionCount;
	public uint32 IntInstructionCount;
	public uint32 UintInstructionCount;
	public uint32 StaticFlowControlCount;
	public uint32 DynamicFlowControlCount;
	public uint32 MacroInstructionCount;
	public uint32 ArrayInstructionCount;
	public uint32 CutInstructionCount;
	public uint32 EmitInstructionCount;
	public D3D_PRIMITIVE_TOPOLOGY GSOutputTopology;
	public uint32 GSMaxOutputVertexCount;
	public D3D_PRIMITIVE InputPrimitive;
	public uint32 PatchConstantParameters;
	public uint32 cGSInstanceCount;
	public uint32 cControlPoints;
	public D3D_TESSELLATOR_OUTPUT_PRIMITIVE HSOutputPrimitive;
	public D3D_TESSELLATOR_PARTITIONING HSPartitioning;
	public D3D_TESSELLATOR_DOMAIN TessellatorDomain;
	public uint32 cBarrierInstructions;
	public uint32 cInterlockedInstructions;
	public uint32 cTextureStoreInstructions;
}

[CRepr]
public struct D3D12_SHADER_INPUT_BIND_DESC
{
	public PSTR Name;
	public D3D_SHADER_INPUT_TYPE Type;
	public uint32 BindPoint;
	public uint32 BindCount;
	public uint32 uFlags;
	public D3D_RESOURCE_RETURN_TYPE ReturnType;
	public D3D_SRV_DIMENSION Dimension;
	public uint32 NumSamples;
	public uint32 Space;
	public uint32 uID;
}


[CRepr] struct ID3D12ShaderReflectionType
{
	public new const Guid IID = .(0xe913c351, 0x783d, 0x48ca, 0xa1, 0xd1, 0x4f, 0x30, 0x62, 0x84, 0xad, 0x56);

	public VTable* VT { get => (.)mVT; }

	protected VTable* mVT;

	[CRepr] public struct VTable
	{
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, D3D12_SHADER_TYPE_DESC* pDesc) GetDesc;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionType*(SelfOuter* self, uint32 Index) GetMemberTypeByIndex;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionType*(SelfOuter* self, PSTR Name) GetMemberTypeByName;
		protected new function [CallingConvention(.Stdcall)] PSTR(SelfOuter* self, uint32 Index) GetMemberTypeName;
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, ID3D12ShaderReflectionType* pType) IsEqual;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionType*(SelfOuter* self) GetSubType;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionType*(SelfOuter* self) GetBaseClass;
		protected new function [CallingConvention(.Stdcall)] uint32(SelfOuter* self) GetNumInterfaces;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionType*(SelfOuter* self, uint32 uIndex) GetInterfaceByIndex;
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, ID3D12ShaderReflectionType* pType) IsOfType;
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, ID3D12ShaderReflectionType* pBase) ImplementsInterface;
	}


	public HRESULT GetDesc(D3D12_SHADER_TYPE_DESC* pDesc) mut => VT.[Friend]GetDesc(&this, pDesc);

	public ID3D12ShaderReflectionType* GetMemberTypeByIndex(uint32 Index) mut => VT.[Friend]GetMemberTypeByIndex(&this, Index);

	public ID3D12ShaderReflectionType* GetMemberTypeByName(PSTR Name) mut => VT.[Friend]GetMemberTypeByName(&this, Name);

	public PSTR GetMemberTypeName(uint32 Index) mut => VT.[Friend]GetMemberTypeName(&this, Index);

	public HRESULT IsEqual(ID3D12ShaderReflectionType* pType) mut => VT.[Friend]IsEqual(&this, pType);

	public ID3D12ShaderReflectionType* GetSubType() mut => VT.[Friend]GetSubType(&this);

	public ID3D12ShaderReflectionType* GetBaseClass() mut => VT.[Friend]GetBaseClass(&this);

	public uint32 GetNumInterfaces() mut => VT.[Friend]GetNumInterfaces(&this);

	public ID3D12ShaderReflectionType* GetInterfaceByIndex(uint32 uIndex) mut => VT.[Friend]GetInterfaceByIndex(&this, uIndex);

	public HRESULT IsOfType(ID3D12ShaderReflectionType* pType) mut => VT.[Friend]IsOfType(&this, pType);

	public HRESULT ImplementsInterface(ID3D12ShaderReflectionType* pBase) mut => VT.[Friend]ImplementsInterface(&this, pBase);

}

[CRepr]
public struct D3D12_SIGNATURE_PARAMETER_DESC
{
	public PSTR SemanticName;
	public uint32 SemanticIndex;
	public uint32 Register;
	public D3D_NAME SystemValueType;
	public D3D_REGISTER_COMPONENT_TYPE ComponentType;
	public uint8 Mask;
	public uint8 ReadWriteMask;
	public uint32 Stream;
	public D3D_MIN_PRECISION MinPrecision;
}

[CRepr] struct ID3D12ShaderReflectionVariable
{
	public new const Guid IID = .(0x8337a8a6, 0xa216, 0x444a, 0xb2, 0xf4, 0x31, 0x47, 0x33, 0xa7, 0x3a, 0xea);

	public VTable* VT { get => (.)mVT; }

	protected VTable* mVT;

	[CRepr] public struct VTable
	{
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, D3D12_SHADER_VARIABLE_DESC* pDesc) GetDesc;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionType*(SelfOuter* self) COM_GetType;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionConstantBuffer*(SelfOuter* self) GetBuffer;
		protected new function [CallingConvention(.Stdcall)] uint32(SelfOuter* self, uint32 uArrayIndex) GetInterfaceSlot;
	}


	public HRESULT GetDesc(D3D12_SHADER_VARIABLE_DESC* pDesc) mut => VT.[Friend]GetDesc(&this, pDesc);

	public ID3D12ShaderReflectionType* GetType() mut => VT.[Friend]COM_GetType(&this);

	public ID3D12ShaderReflectionConstantBuffer* GetBuffer() mut => VT.[Friend]GetBuffer(&this);

	public uint32 GetInterfaceSlot(uint32 uArrayIndex) mut => VT.[Friend]GetInterfaceSlot(&this, uArrayIndex);
}

[CRepr] struct ID3D12ShaderReflectionConstantBuffer
{
	public new const Guid IID = .(0xc59598b4, 0x48b3, 0x4869, 0xb9, 0xb1, 0xb1, 0x61, 0x8b, 0x14, 0xa8, 0xb7);

	public VTable* VT { get => (.)mVT; }

	protected VTable* mVT;

	[CRepr] public struct VTable
	{
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, D3D12_SHADER_BUFFER_DESC* pDesc) GetDesc;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionVariable*(SelfOuter* self, uint32 Index) GetVariableByIndex;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionVariable*(SelfOuter* self, PSTR Name) GetVariableByName;
	}


	public HRESULT GetDesc(D3D12_SHADER_BUFFER_DESC* pDesc) mut => VT.[Friend]GetDesc(&this, pDesc);

	public ID3D12ShaderReflectionVariable* GetVariableByIndex(uint32 Index) mut => VT.[Friend]GetVariableByIndex(&this, Index);

	public ID3D12ShaderReflectionVariable* GetVariableByName(PSTR Name) mut => VT.[Friend]GetVariableByName(&this, Name);
}

[CRepr] struct ID3D12ShaderReflection : IUnknown
{
	public new const Guid IID = .(0x5a58797d, 0xa72c, 0x478d, 0x8b, 0xa2, 0xef, 0xc6, 0xb0, 0xef, 0xe8, 0x8e);

	public new VTable* VT { get => (.)mVT; }

	[CRepr] public struct VTable : IUnknown.VTable
	{
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, D3D12_SHADER_DESC* pDesc) GetDesc;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionConstantBuffer*(SelfOuter* self, uint32 Index) GetConstantBufferByIndex;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionConstantBuffer*(SelfOuter* self, PSTR Name) GetConstantBufferByName;
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, uint32 ResourceIndex, D3D12_SHADER_INPUT_BIND_DESC* pDesc) GetResourceBindingDesc;
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, uint32 ParameterIndex, D3D12_SIGNATURE_PARAMETER_DESC* pDesc) GetInputParameterDesc;
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, uint32 ParameterIndex, D3D12_SIGNATURE_PARAMETER_DESC* pDesc) GetOutputParameterDesc;
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, uint32 ParameterIndex, D3D12_SIGNATURE_PARAMETER_DESC* pDesc) GetPatchConstantParameterDesc;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionVariable*(SelfOuter* self, PSTR Name) GetVariableByName;
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, PSTR Name, D3D12_SHADER_INPUT_BIND_DESC* pDesc) GetResourceBindingDescByName;
		protected new function [CallingConvention(.Stdcall)] uint32(SelfOuter* self) GetMovInstructionCount;
		protected new function [CallingConvention(.Stdcall)] uint32(SelfOuter* self) GetMovcInstructionCount;
		protected new function [CallingConvention(.Stdcall)] uint32(SelfOuter* self) GetConversionInstructionCount;
		protected new function [CallingConvention(.Stdcall)] uint32(SelfOuter* self) GetBitwiseInstructionCount;
		protected new function [CallingConvention(.Stdcall)] D3D_PRIMITIVE(SelfOuter* self) GetGSInputPrimitive;
		protected new function [CallingConvention(.Stdcall)] BOOL(SelfOuter* self) IsSampleFrequencyShader;
		protected new function [CallingConvention(.Stdcall)] uint32(SelfOuter* self) GetNumInterfaceSlots;
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, D3D_FEATURE_LEVEL* pLevel) GetMinFeatureLevel;
		protected new function [CallingConvention(.Stdcall)] uint32(SelfOuter* self, uint32* pSizeX, uint32* pSizeY, uint32* pSizeZ) GetThreadGroupSize;
		protected new function [CallingConvention(.Stdcall)] uint64(SelfOuter* self) GetRequiresFlags;
	}


	public HRESULT GetDesc(D3D12_SHADER_DESC* pDesc) mut => VT.[Friend]GetDesc(&this, pDesc);

	public ID3D12ShaderReflectionConstantBuffer* GetConstantBufferByIndex(uint32 Index) mut => VT.[Friend]GetConstantBufferByIndex(&this, Index);

	public ID3D12ShaderReflectionConstantBuffer* GetConstantBufferByName(PSTR Name) mut => VT.[Friend]GetConstantBufferByName(&this, Name);

	public HRESULT GetResourceBindingDesc(uint32 ResourceIndex, D3D12_SHADER_INPUT_BIND_DESC* pDesc) mut => VT.[Friend]GetResourceBindingDesc(&this, ResourceIndex, pDesc);

	public HRESULT GetInputParameterDesc(uint32 ParameterIndex, D3D12_SIGNATURE_PARAMETER_DESC* pDesc) mut => VT.[Friend]GetInputParameterDesc(&this, ParameterIndex, pDesc);

	public HRESULT GetOutputParameterDesc(uint32 ParameterIndex, D3D12_SIGNATURE_PARAMETER_DESC* pDesc) mut => VT.[Friend]GetOutputParameterDesc(&this, ParameterIndex, pDesc);

	public HRESULT GetPatchConstantParameterDesc(uint32 ParameterIndex, D3D12_SIGNATURE_PARAMETER_DESC* pDesc) mut => VT.[Friend]GetPatchConstantParameterDesc(&this, ParameterIndex, pDesc);

	public ID3D12ShaderReflectionVariable* GetVariableByName(PSTR Name) mut => VT.[Friend]GetVariableByName(&this, Name);

	public HRESULT GetResourceBindingDescByName(PSTR Name, D3D12_SHADER_INPUT_BIND_DESC* pDesc) mut => VT.[Friend]GetResourceBindingDescByName(&this, Name, pDesc);

	public uint32 GetMovInstructionCount() mut => VT.[Friend]GetMovInstructionCount(&this);

	public uint32 GetMovcInstructionCount() mut => VT.[Friend]GetMovcInstructionCount(&this);

	public uint32 GetConversionInstructionCount() mut => VT.[Friend]GetConversionInstructionCount(&this);

	public uint32 GetBitwiseInstructionCount() mut => VT.[Friend]GetBitwiseInstructionCount(&this);

	public D3D_PRIMITIVE GetGSInputPrimitive() mut => VT.[Friend]GetGSInputPrimitive(&this);

	public BOOL IsSampleFrequencyShader() mut => VT.[Friend]IsSampleFrequencyShader(&this);

	public uint32 GetNumInterfaceSlots() mut => VT.[Friend]GetNumInterfaceSlots(&this);

	public HRESULT GetMinFeatureLevel(D3D_FEATURE_LEVEL* pLevel) mut => VT.[Friend]GetMinFeatureLevel(&this, pLevel);

	public uint32 GetThreadGroupSize(uint32* pSizeX, uint32* pSizeY, uint32* pSizeZ) mut => VT.[Friend]GetThreadGroupSize(&this, pSizeX, pSizeY, pSizeZ);

	public uint64 GetRequiresFlags() mut => VT.[Friend]GetRequiresFlags(&this);
}

[CRepr]
public struct D3D12_LIBRARY_DESC
{
	public PSTR Creator;
	public uint32 Flags;
	public uint32 FunctionCount;
}

[CRepr]
public struct D3D12_FUNCTION_DESC
{
	public uint32 Version;
	public PSTR Creator;
	public uint32 Flags;
	public uint32 ConstantBuffers;
	public uint32 BoundResources;
	public uint32 InstructionCount;
	public uint32 TempRegisterCount;
	public uint32 TempArrayCount;
	public uint32 DefCount;
	public uint32 DclCount;
	public uint32 TextureNormalInstructions;
	public uint32 TextureLoadInstructions;
	public uint32 TextureCompInstructions;
	public uint32 TextureBiasInstructions;
	public uint32 TextureGradientInstructions;
	public uint32 FloatInstructionCount;
	public uint32 IntInstructionCount;
	public uint32 UintInstructionCount;
	public uint32 StaticFlowControlCount;
	public uint32 DynamicFlowControlCount;
	public uint32 MacroInstructionCount;
	public uint32 ArrayInstructionCount;
	public uint32 MovInstructionCount;
	public uint32 MovcInstructionCount;
	public uint32 ConversionInstructionCount;
	public uint32 BitwiseInstructionCount;
	public D3D_FEATURE_LEVEL MinFeatureLevel;
	public uint64 RequiredFeatureFlags;
	public PSTR Name;
	public int32 FunctionParameterCount;
	public BOOL HasReturn;
	public BOOL Has10Level9VertexShader;
	public BOOL Has10Level9PixelShader;
}

[AllowDuplicates]
public enum D3D_INTERPOLATION_MODE : int32
{
	D3D_INTERPOLATION_UNDEFINED = 0,
	D3D_INTERPOLATION_CONSTANT = 1,
	D3D_INTERPOLATION_LINEAR = 2,
	D3D_INTERPOLATION_LINEAR_CENTROID = 3,
	D3D_INTERPOLATION_LINEAR_NOPERSPECTIVE = 4,
	D3D_INTERPOLATION_LINEAR_NOPERSPECTIVE_CENTROID = 5,
	D3D_INTERPOLATION_LINEAR_SAMPLE = 6,
	D3D_INTERPOLATION_LINEAR_NOPERSPECTIVE_SAMPLE = 7,
}

[AllowDuplicates]
public enum D3D_PARAMETER_FLAGS : int32
{
	D3D_PF_NONE = 0,
	D3D_PF_IN = 1,
	D3D_PF_OUT = 2,
	D3D_PF_FORCE_DWORD = 2147483647,
}

[CRepr]
public struct D3D12_PARAMETER_DESC
{
	public PSTR Name;
	public PSTR SemanticName;
	public D3D_SHADER_VARIABLE_TYPE Type;
	public D3D_SHADER_VARIABLE_CLASS Class;
	public uint32 Rows;
	public uint32 Columns;
	public D3D_INTERPOLATION_MODE InterpolationMode;
	public D3D_PARAMETER_FLAGS Flags;
	public uint32 FirstInRegister;
	public uint32 FirstInComponent;
	public uint32 FirstOutRegister;
	public uint32 FirstOutComponent;
}

[CRepr] struct ID3D12FunctionParameterReflection
{
	public new const Guid IID = .(0xec25f42d, 0x7006, 0x4f2b, 0xb3, 0x3e, 0x02, 0xcc, 0x33, 0x75, 0x73, 0x3f);

	public VTable* VT { get => (.)mVT; }

	protected VTable* mVT;

	[CRepr] public struct VTable
	{
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, D3D12_PARAMETER_DESC* pDesc) GetDesc;
	}


	public HRESULT GetDesc(D3D12_PARAMETER_DESC* pDesc) mut => VT.[Friend]GetDesc(&this, pDesc);
}

[CRepr] struct ID3D12FunctionReflection
{
	public new const Guid IID = .(0x1108795c, 0x2772, 0x4ba9, 0xb2, 0xa8, 0xd4, 0x64, 0xdc, 0x7e, 0x27, 0x99);

	public VTable* VT { get => (.)mVT; }

	protected VTable* mVT;

	[CRepr] public struct VTable
	{
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, D3D12_FUNCTION_DESC* pDesc) GetDesc;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionConstantBuffer*(SelfOuter* self, uint32 BufferIndex) GetConstantBufferByIndex;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionConstantBuffer*(SelfOuter* self, PSTR Name) GetConstantBufferByName;
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, uint32 ResourceIndex, D3D12_SHADER_INPUT_BIND_DESC* pDesc) GetResourceBindingDesc;
		protected new function [CallingConvention(.Stdcall)] ID3D12ShaderReflectionVariable*(SelfOuter* self, PSTR Name) GetVariableByName;
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, PSTR Name, D3D12_SHADER_INPUT_BIND_DESC* pDesc) GetResourceBindingDescByName;
		protected new function [CallingConvention(.Stdcall)] ID3D12FunctionParameterReflection*(SelfOuter* self, int32 ParameterIndex) GetFunctionParameter;
	}


	public HRESULT GetDesc(D3D12_FUNCTION_DESC* pDesc) mut => VT.[Friend]GetDesc(&this, pDesc);

	public ID3D12ShaderReflectionConstantBuffer* GetConstantBufferByIndex(uint32 BufferIndex) mut => VT.[Friend]GetConstantBufferByIndex(&this, BufferIndex);

	public ID3D12ShaderReflectionConstantBuffer* GetConstantBufferByName(PSTR Name) mut => VT.[Friend]GetConstantBufferByName(&this, Name);

	public HRESULT GetResourceBindingDesc(uint32 ResourceIndex, D3D12_SHADER_INPUT_BIND_DESC* pDesc) mut => VT.[Friend]GetResourceBindingDesc(&this, ResourceIndex, pDesc);

	public ID3D12ShaderReflectionVariable* GetVariableByName(PSTR Name) mut => VT.[Friend]GetVariableByName(&this, Name);

	public HRESULT GetResourceBindingDescByName(PSTR Name, D3D12_SHADER_INPUT_BIND_DESC* pDesc) mut => VT.[Friend]GetResourceBindingDescByName(&this, Name, pDesc);

	public ID3D12FunctionParameterReflection* GetFunctionParameter(int32 ParameterIndex) mut => VT.[Friend]GetFunctionParameter(&this, ParameterIndex);
}

[CRepr] struct ID3D12LibraryReflection : IUnknown
{
	public new const Guid IID = .(0x8e349d19, 0x54db, 0x4a56, 0x9d, 0xc9, 0x11, 0x9d, 0x87, 0xbd, 0xb8, 0x04);

	public new VTable* VT { get => (.)mVT; }

	[CRepr] public struct VTable : IUnknown.VTable
	{
		protected new function [CallingConvention(.Stdcall)] HRESULT(SelfOuter* self, D3D12_LIBRARY_DESC* pDesc) GetDesc;
		protected new function [CallingConvention(.Stdcall)] ID3D12FunctionReflection*(SelfOuter* self, int32 FunctionIndex) GetFunctionByIndex;
	}


	public HRESULT GetDesc(D3D12_LIBRARY_DESC* pDesc) mut => VT.[Friend]GetDesc(&this, pDesc);

	public ID3D12FunctionReflection* GetFunctionByIndex(int32 FunctionIndex) mut => VT.[Friend]GetFunctionByIndex(&this, FunctionIndex);
}

#endregion

static
{
	public static ShaderKind ConvertShaderKind(Dxil.ShaderKind kind)
	{
	    switch (kind) {
	    case Dxil.ShaderKind.Pixel:
	        return ShaderKind.kPixel;
	    case Dxil.ShaderKind.Vertex:
	        return ShaderKind.kVertex;
	    case Dxil.ShaderKind.Geometry:
	        return ShaderKind.kGeometry;
	    case Dxil.ShaderKind.Compute:
	        return ShaderKind.kCompute;
	    case Dxil.ShaderKind.RayGeneration:
	        return ShaderKind.kRayGeneration;
	    case Dxil.ShaderKind.Intersection:
	        return ShaderKind.kIntersection;
	    case Dxil.ShaderKind.AnyHit:
	        return ShaderKind.kAnyHit;
	    case Dxil.ShaderKind.ClosestHit:
	        return ShaderKind.kClosestHit;
	    case Dxil.ShaderKind.Miss:
	        return ShaderKind.kMiss;
	    case Dxil.ShaderKind.Callable:
	        return ShaderKind.kCallable;
	    case Dxil.ShaderKind.Mesh:
	        return ShaderKind.kMesh;
	    case Dxil.ShaderKind.Amplification:
	        return ShaderKind.kAmplification;
	    default:
	        Runtime.Assert(false);
	        return ShaderKind.kUnknown;
	    }
	}

	public static bool IsBufferDimension(D3D_SRV_DIMENSION dimension)
	{
		switch (dimension) {
		case .D3D_SRV_DIMENSION_BUFFER:
			return true;
		case .D3D_SRV_DIMENSION_TEXTURE1D,
			.D3D_SRV_DIMENSION_TEXTURE1DARRAY,
			.D3D_SRV_DIMENSION_TEXTURE2D,
			.D3D_SRV_DIMENSION_TEXTURE2DARRAY,
			.D3D_SRV_DIMENSION_TEXTURE2DMS,
			.D3D_SRV_DIMENSION_TEXTURE2DMSARRAY,
			.D3D_SRV_DIMENSION_TEXTURE3D,
			.D3D_SRV_DIMENSION_TEXTURECUBE,
			.D3D_SRV_DIMENSION_TEXTURECUBEARRAY:
			return false;
		default:
			Runtime.Assert(false);
			return false;
		}
	}

	public static ViewType GetViewType(D3D12_SHADER_INPUT_BIND_DESC bind_desc)
	{
		switch (bind_desc.Type) {
		case .D3D_SIT_CBUFFER:
			return ViewType.kConstantBuffer;
		case .D3D_SIT_SAMPLER:
			return ViewType.kSampler;
		case .D3D_SIT_TEXTURE:
			{
				if (IsBufferDimension(bind_desc.Dimension))
				{
					return ViewType.kBuffer;
				} else
				{
					return ViewType.kTexture;
				}
			}
		case .D3D_SIT_STRUCTURED:
			return ViewType.kStructuredBuffer;
		case .D3D_SIT_RTACCELERATIONSTRUCTURE:
			return ViewType.kAccelerationStructure;
		case .D3D_SIT_UAV_RWSTRUCTURED:
			return ViewType.kRWStructuredBuffer;
		case .D3D_SIT_UAV_RWTYPED:
			{
				if (IsBufferDimension(bind_desc.Dimension))
				{
					return ViewType.kRWBuffer;
				} else
				{
					return ViewType.kRWTexture;
				}
			}
		default:
			Runtime.Assert(false);
			return ViewType.kUnknown;
		}
	}

	public static ViewDimension GetViewDimension(in D3D12_SHADER_INPUT_BIND_DESC bind_desc)
	{
		switch (bind_desc.Dimension) {
		case .D3D_SRV_DIMENSION_UNKNOWN:
			return ViewDimension.kUnknown;
		case .D3D_SRV_DIMENSION_BUFFER:
			return ViewDimension.kBuffer;
		case .D3D_SRV_DIMENSION_TEXTURE1D:
			return ViewDimension.kTexture1D;
		case .D3D_SRV_DIMENSION_TEXTURE1DARRAY:
			return ViewDimension.kTexture1DArray;
		case .D3D_SRV_DIMENSION_TEXTURE2D:
			return ViewDimension.kTexture2D;
		case .D3D_SRV_DIMENSION_TEXTURE2DARRAY:
			return ViewDimension.kTexture2DArray;
		case .D3D_SRV_DIMENSION_TEXTURE2DMS:
			return ViewDimension.kTexture2DMS;
		case .D3D_SRV_DIMENSION_TEXTURE2DMSARRAY:
			return ViewDimension.kTexture2DMSArray;
		case .D3D_SRV_DIMENSION_TEXTURE3D:
			return ViewDimension.kTexture3D;
		case .D3D_SRV_DIMENSION_TEXTURECUBE:
			return ViewDimension.kTextureCube;
		case .D3D_SRV_DIMENSION_TEXTURECUBEARRAY:
			return ViewDimension.kTextureCubeArray;
		default:
			Runtime.Assert(false);
			return ViewDimension.kUnknown;
		}
	}

	public static ReturnType GetReturnType(ViewType view_type, in D3D12_SHADER_INPUT_BIND_DESC bind_desc)
	{
		delegate ReturnType(ReturnType return_type) check_type = scope [&] (return_type) =>
			{
				switch (view_type) {
				case ViewType.kBuffer,
					ViewType.kRWBuffer,
					ViewType.kTexture,
					ViewType.kRWTexture:
					Runtime.Assert(return_type != ReturnType.kUnknown);
					break;
				case ViewType.kAccelerationStructure:
					return ReturnType.kUnknown;
				default:
					Runtime.Assert(return_type == ReturnType.kUnknown);
					break;
				}
				return return_type;
			};

		switch (bind_desc.ReturnType) {
		case .D3D_RETURN_TYPE_FLOAT:
			return check_type(ReturnType.kFloat);
		case .D3D_RETURN_TYPE_UINT:
			return check_type(ReturnType.kUint);
		case .D3D_RETURN_TYPE_SINT:
			return check_type(ReturnType.kInt);
		case .D3D_RETURN_TYPE_DOUBLE:
			return check_type(ReturnType.kDouble);
		default:
			return check_type(ReturnType.kUnknown);
		}
	}

	/*

	public static uint32 GetStructureStride<T>(ViewType view_type, const D3D12_SHADER_INPUT_BIND_DESC& bind_desc, T* reflection)
	{
	    switch (view_type) {
	    case ViewType::kStructuredBuffer:
	    case ViewType::kRWStructuredBuffer:
	        break;
	    default:
	        return 0;
	    }

	    auto get_buffer_stride = [&](const std::string& name) {
	        ID3D12ShaderReflectionConstantBuffer* cbuffer = reflection->GetConstantBufferByName(name.c_str());
	        if (cbuffer) {
	            D3D12_SHADER_BUFFER_DESC cbuffer_desc = {};
	            if (SUCCEEDED(cbuffer->GetDesc(&cbuffer_desc))) {
	                return cbuffer_desc.Size;
	            }
	        }
	        return 0u;
	    };
	    uint32 stride = get_buffer_stride(bind_desc.Name);
	    if (!stride) {
	        stride = get_buffer_stride(std::string(bind_desc.Name) + "[0]");
	    }
	    assert(stride);
	    return stride;
	}

	public static ResourceBindingDesc GetBindingDesc<T>(const D3D12_SHADER_INPUT_BIND_DESC& bind_desc, T* reflection)
	{
	    ResourceBindingDesc desc = {};
	    desc.name = bind_desc.Name;
	    desc.type = GetViewType(bind_desc);
	    desc.slot = bind_desc.BindPoint;
	    desc.space = bind_desc.Space;
	    desc.count = bind_desc.BindCount;
	    if (desc.count == 0) {
	        desc.count = std::numeric_limits<uint32>::max();
	    }
	    desc.dimension = GetViewDimension(bind_desc);
	    desc.return_type = GetReturnType(desc.type, bind_desc);
	    desc.structure_stride = GetStructureStride(desc.type, bind_desc, reflection);
	    return desc;
	}

	public static VariableLayout GetVariableLayout(const std::string& name,
	                                 uint32 offset,
	                                 uint32 size,
	                                 ID3D12ShaderReflectionType* variable_type)
	{
	    D3D12_SHADER_TYPE_DESC type_desc = {};
	    variable_type->GetDesc(&type_desc);

	    VariableLayout layout = {};
	    layout.name = name;
	    layout.offset = offset + type_desc.Offset;
	    layout.size = size;
	    layout.rows = type_desc.Rows;
	    layout.columns = type_desc.Columns;
	    layout.elements = type_desc.Elements;
	    switch (type_desc.Type) {
	    case D3D_SHADER_VARIABLE_TYPE::D3D_SVT_FLOAT:
	        layout.type = VariableType::kFloat;
	        break;
	    case D3D_SHADER_VARIABLE_TYPE::D3D_SVT_INT:
	        layout.type = VariableType::kInt;
	        break;
	    case D3D_SHADER_VARIABLE_TYPE::D3D_SVT_UINT:
	        layout.type = VariableType::kUint;
	        break;
	    case D3D_SHADER_VARIABLE_TYPE::D3D_SVT_BOOL:
	        layout.type = VariableType::kBool;
	        break;
	    default:
	        assert(false);
	        break;
	    }
	    return layout;
	}

	public static VariableLayout GetBufferLayout<ReflectionType>(const D3D12_SHADER_INPUT_BIND_DESC& bind_desc, ReflectionType* reflection)
	{
	    if (bind_desc.Type != D3D_SIT_CBUFFER) {
	        return {};
	    }
	    ID3D12ShaderReflectionConstantBuffer* cbuffer = reflection->GetConstantBufferByName(bind_desc.Name);
	    if (!cbuffer) {
	        assert(false);
	        return {};
	    }

	    D3D12_SHADER_BUFFER_DESC cbuffer_desc = {};
	    cbuffer->GetDesc(&cbuffer_desc);

	    VariableLayout layout = {};
	    layout.name = bind_desc.Name;
	    layout.type = VariableType::kStruct;
	    layout.offset = 0;
	    layout.size = cbuffer_desc.Size;
	    for (UINT i = 0; i < cbuffer_desc.Variables; ++i) {
	        ID3D12ShaderReflectionVariable* variable = cbuffer->GetVariableByIndex(i);
	        D3D12_SHADER_VARIABLE_DESC variable_desc = {};
	        variable->GetDesc(&variable_desc);
	        layout.members.emplace_back(
	            GetVariableLayout(variable_desc.Name, variable_desc.StartOffset, variable_desc.Size, variable->GetType()));
	    }
	    return layout;
	}

	public static std::vector<ResourceBindingDesc> ParseReflection<T, U>(const T& desc, U* reflection)
	{
	    std::vector<ResourceBindingDesc> res;
	    res.reserve(desc.BoundResources);
	    for (uint32 i = 0; i < desc.BoundResources; ++i) {
	        D3D12_SHADER_INPUT_BIND_DESC bind_desc = {};
	        ASSERT_SUCCEEDED(reflection->GetResourceBindingDesc(i, &bind_desc));
	        res.emplace_back(GetBindingDesc(bind_desc, reflection));
	    }
	    return res;
	}

	public static std::vector<VariableLayout> ParseLayout<T, U>(const T& desc, U* reflection)
	{
	    std::vector<VariableLayout> res;
	    res.reserve(desc.BoundResources);
	    for (uint32 i = 0; i < desc.BoundResources; ++i) {
	        D3D12_SHADER_INPUT_BIND_DESC bind_desc = {};
	        ASSERT_SUCCEEDED(reflection->GetResourceBindingDesc(i, &bind_desc));
	        res.emplace_back(GetBufferLayout(bind_desc, reflection));
	    }
	    return res;
	}

	public static std::vector<InputParameterDesc> ParseInputParameters(const D3D12_SHADER_DESC& desc,
	                                                     CComPtr<ID3D12ShaderReflection> shader_reflection)
	{
	    std::vector<InputParameterDesc> input_parameters;
	    D3D12_SHADER_VERSION_TYPE type = static_cast<D3D12_SHADER_VERSION_TYPE>((desc.Version & 0xFFFF0000) >> 16);
	    if (type != D3D12_SHADER_VERSION_TYPE::D3D12_SHVER_VERTEX_SHADER) {
	        return input_parameters;
	    }
	    for (uint32 i = 0; i < desc.InputParameters; ++i) {
	        D3D12_SIGNATURE_PARAMETER_DESC param_desc = {};
	        ASSERT_SUCCEEDED(shader_reflection->GetInputParameterDesc(i, &param_desc));
	        decltype(auto) input = input_parameters.emplace_back();
	        input.semantic_name = param_desc.SemanticName;
	        if (param_desc.SemanticIndex) {
	            input.semantic_name += std::to_string(param_desc.SemanticIndex);
	        }
	        input.location = i;
	        if (param_desc.Mask == 1) {
	            if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_UINT32) {
	                input.format = Format.FORMAT_R32_UINT_PACK32;
	            } else if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_SINT32) {
	                input.format = Format.FORMAT_R32_SINT_PACK32;
	            } else if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_FLOAT32) {
	                input.format = Format.FORMAT_R32_SFLOAT_PACK32;
	            }
	        } else if (param_desc.Mask <= 3) {
	            if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_UINT32) {
	                input.format = Format.FORMAT_RG32_UINT_PACK32;
	            } else if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_SINT32) {
	                input.format = Format.FORMAT_RG32_SINT_PACK32;
	            } else if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_FLOAT32) {
	                input.format = Format.FORMAT_RG32_SFLOAT_PACK32;
	            }
	        } else if (param_desc.Mask <= 7) {
	            if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_UINT32) {
	                input.format = Format.FORMAT_RGB32_UINT_PACK32;
	            } else if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_SINT32) {
	                input.format = Format.FORMAT_RGB32_SINT_PACK32;
	            } else if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_FLOAT32) {
	                input.format = Format.FORMAT_RGB32_SFLOAT_PACK32;
	            }
	        } else if (param_desc.Mask <= 15) {
	            if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_UINT32) {
	                input.format = Format.FORMAT_RGBA32_UINT_PACK32;
	            } else if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_SINT32) {
	                input.format = Format.FORMAT_RGBA32_SINT_PACK32;
	            } else if (param_desc.ComponentType == D3D_REGISTER_COMPONENT_FLOAT32) {
	                input.format = Format.FORMAT_RGBA32_SFLOAT_PACK32;
	            }
	        }
	    }
	    return input_parameters;
	}

	public static std::vector<OutputParameterDesc> ParseOutputParameters(const D3D12_SHADER_DESC& desc,
	                                                       CComPtr<ID3D12ShaderReflection> shader_reflection)
	{
	    std::vector<OutputParameterDesc> output_parameters;
	    D3D12_SHADER_VERSION_TYPE type = static_cast<D3D12_SHADER_VERSION_TYPE>((desc.Version & 0xFFFF0000) >> 16);
	    if (type != D3D12_SHADER_VERSION_TYPE::D3D12_SHVER_PIXEL_SHADER) {
	        return output_parameters;
	    }
	    for (uint32 i = 0; i < desc.OutputParameters; ++i) {
	        D3D12_SIGNATURE_PARAMETER_DESC param_desc = {};
	        ASSERT_SUCCEEDED(shader_reflection->GetOutputParameterDesc(i, &param_desc));
	        assert(param_desc.SemanticName == std::string("SV_TARGET"));
	        assert(param_desc.SystemValueType == D3D_NAME_TARGET);
	        assert(param_desc.SemanticIndex == param_desc.Register);
	        decltype(auto) output = output_parameters.emplace_back();
	        output.slot = param_desc.Register;
	    }
	    return output_parameters;
	}

	*/

}

class DXILReflection : ShaderReflection
{
	private bool m_is_library = false;
	private List<EntryPoint> m_entry_points;
	private List<ResourceBindingDesc> m_bindings;
	private List<VariableLayout> m_layouts;
	private List<InputParameterDesc> m_input_parameters;
	private List<OutputParameterDesc> m_output_parameters;
	private ShaderFeatureInfo m_shader_feature_info = .();

	public this(void* data, uint size)
	{

		//decltype(auto) dxc_support = GetDxcSupport(ShaderBlobType::kDXIL);
		IDxcLibrary* library = null;
		var result = Dxc.CreateInstance(out library);
		if (result != .S_OK)
			Runtime.FatalError();
		Runtime.Assert(library.CreateBlobWithEncodingOnHeapCopy(data, (uint32)size, DXC_CP_ACP, var source) == .S_OK);
		IDxcContainerReflection* reflection;
		Dxc.CreateInstance(out reflection);
		Runtime.Assert(reflection.Load(source) == .S_OK);

		IDxcBlob* pdb = null;
		uint32 part_count = 0;
		Runtime.Assert(reflection.GetPartCount(&part_count) == .S_OK);
		for (uint32 i = 0; i < part_count; ++i)
		{
			uint32 kind = 0;
			Runtime.Assert(reflection.GetPartKind(i, &kind) == .S_OK);
			if (kind == (uint32)Dxil.DxilFourCC.DFCC_RuntimeData)
			{
				ParseRuntimeData(reflection, i);
			} else if (kind == (uint32)Dxil.DxilFourCC.DFCC_DXIL)
			{
				ID3D12ShaderReflection* shader_reflection = null;
				ID3D12LibraryReflection* library_reflection = null;
				if (reflection.GetPartReflection(i, ID3D12ShaderReflection.IID, (void**)&shader_reflection) == .S_OK)
				{
					ParseShaderReflection(shader_reflection);
				} else if (reflection.GetPartReflection(i, ID3D12LibraryReflection.IID, (void**)&library_reflection) == .S_OK)
				{
					m_is_library = true;
					ParseLibraryReflection(library_reflection);
				}
			} else if (kind == (uint32)Dxil.DxilFourCC.DFCC_ShaderDebugInfoDXIL)
			{
				Runtime.Assert(reflection.GetPartContent(i, &pdb) == .S_OK);
			} else if (kind == (uint32)Dxil.DxilFourCC.DFCC_FeatureInfo)
			{
				IDxcBlob* part = null;
				Runtime.Assert(reflection.GetPartContent(i, &part) == .S_OK);
				Runtime.Assert(part.GetBufferSize() == sizeof(DxilShaderFeatureInfo));
				var feature_info = (DxilShaderFeatureInfo*)part.GetBufferPointer();
				if (feature_info.FeatureFlags & Dxil.ShaderFeatureInfo_ResourceDescriptorHeapIndexing != 0)
				{
					m_shader_feature_info.resource_descriptor_heap_indexing = true;
				}
				if (feature_info.FeatureFlags & Dxil.ShaderFeatureInfo_SamplerDescriptorHeapIndexing != 0)
				{
					m_shader_feature_info.sampler_descriptor_heap_indexing = true;
				}
			}
		}

		if (pdb != null && !m_is_library)
		{
			ParseDebugInfo( /*dxc_support,*/pdb);
		}
	}

	public override ref System.Collections.List<EntryPoint> GetEntryPoints()
	{
		return ref m_entry_points;
	}

	public override ref System.Collections.List<ResourceBindingDesc> GetBindings()
	{
		return ref m_bindings;
	}

	public override ref System.Collections.List<VariableLayout> GetVariableLayouts()
	{
		return ref m_layouts;
	}

	public override ref System.Collections.List<InputParameterDesc> GetInputParameters()
	{
		return ref m_input_parameters;
	}

	public override ref System.Collections.List<OutputParameterDesc> GetOutputParameters()
	{
		return ref m_output_parameters;
	}

	public override ref ShaderFeatureInfo GetShaderFeatureInfo()
	{
		return ref m_shader_feature_info;
	}

	private void ParseRuntimeData(IDxcContainerReflection* reflection, uint32 idx)
	{
		/*CComPtr<IDxcBlob> part_blob;
		reflection.GetPartContent(idx, &part_blob);
		hlsl::RDAT::DxilRuntimeData context;
		context.InitFromRDAT(part_blob.GetBufferPointer(), part_blob.GetBufferSize());
		decltype(auto) func_table_reader = context.GetFunctionTable();
		for (uint32 i = 0; i < func_table_reader.Count(); ++i) {
			decltype(auto) func_reader = func_table_reader[i];
			auto kind = func_reader.getShaderKind();
			m_entry_points.push_back({ func_reader.getUnmangledName(), ConvertShaderKind(kind),
									   func_reader.getPayloadSizeInBytes(), func_reader.getAttributeSizeInBytes() });
		}*/
	}

	private void ParseShaderReflection(ID3D12ShaderReflection* shader_reflection)
	{
		/*D3D12_SHADER_DESC desc = {};
		Runtime.Assert(shader_reflection.GetDesc(&desc));
		Dxil.ShaderKind kind = hlsl::GetVersionShaderType(desc.Version);
		m_entry_points.push_back({ "", ConvertShaderKind(kind) });
		m_bindings = ParseReflection(desc, shader_reflection.p);
		m_layouts = ParseLayout(desc, shader_reflection.p);
		assert(m_bindings.size() == m_layouts.size());
		m_input_parameters = ParseInputParameters(desc, shader_reflection);
		m_output_parameters = ParseOutputParameters(desc, shader_reflection);*/
	}

	private void ParseLibraryReflection(ID3D12LibraryReflection* library_reflection)
	{
		/*D3D12_LIBRARY_DESC library_desc = {};
		Runtime.Assert(library_reflection.GetDesc(&library_desc) == .S_OK);
		std::map<std::string, uint> exist;
		for (uint32 i = 0; i < library_desc.FunctionCount; ++i) {
			ID3D12FunctionReflection* function_reflection = library_reflection.GetFunctionByIndex(i);
			D3D12_FUNCTION_DESC function_desc = {};
			Runtime.Assert(function_reflection.GetDesc(&function_desc) == .S_OK);
			auto function_bindings = ParseReflection(function_desc, function_reflection);
			auto function_layouts = ParseLayout(function_desc, function_reflection);
			assert(function_bindings.size() == function_layouts.size());
			for (uint i = 0; i < function_bindings.size(); ++i) {
				auto it = exist.find(function_bindings[i].name);
				if (it == exist.end()) {
					exist[function_bindings[i].name] = m_bindings.size();
					m_bindings.emplace_back(function_bindings[i]);
					m_layouts.emplace_back(function_layouts[i]);
				} else {
					assert(function_bindings[i] == m_bindings[it.second]);
					assert(function_layouts[i] == m_layouts[it.second]);
				}
			}
		}*/
	}

	private void ParseDebugInfo( /*dxc::DxcDllSupport& dxc_support,*/IDxcBlob* pdb)
	{
		/*
		IDxcPdbUtils2* pdb_utils;
		Runtime.Assert(dxc_support.CreateInstance(CLSID_DxcPdbUtils, &pdb_utils) == .S_OK);
		Runtime.Assert(pdb_utils.Load(pdb) == .S_OK);
		CComPtr<IDxcBlobWide> entry_point;
		Runtime.Assert(pdb_utils.GetEntryPoint(&entry_point) == .S_OK);
		assert(m_entry_points.size() == 1);
		m_entry_points.front().name = nowide::narrow(entry_point.GetStringPointer());*/
	}
}