struct ObjectInstance
{
    float4x4 TRSMatrix;
    float variation;
    float4 color;
};

StructuredBuffer<ObjectInstance> _Instances;

struct vertexInput
{
    float4 positionOS : POSITION;
    uint instanceId : SV_InstanceID;
};

struct fragmentInput
{
    float4 positionCS : SV_POSITION;
    float4 color : COLOR0;
};