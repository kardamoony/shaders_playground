#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

fragmentInput vert(vertexInput IN)
{
    fragmentInput o;
    
    ObjectInstance obj = _Instances[IN.instanceId];
    float3 posWS = mul(obj.TRSMatrix, IN.positionOS).xyz;
    o.positionCS = TransformWorldToHClip(posWS);
    o.color = obj.color;

    return o;
}

half4 frag(fragmentInput IN) : SV_TARGET
{
    half4 color = IN.color;
    color.a = 1;
    return color;
}