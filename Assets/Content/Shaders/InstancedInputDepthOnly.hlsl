struct ObjectInstance
{
    float4x4 TRSMatrix;
    float variation;
};

StructuredBuffer<ObjectInstance> _Instances;

struct vertexInput
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    uint instanceId : SV_InstanceID;
    float color : COLOR;
};

struct fragmentInput
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
};