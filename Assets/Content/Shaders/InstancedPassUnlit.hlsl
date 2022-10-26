#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

half4 _Color;

fragmentInput vert(vertexInput IN)
{
    fragmentInput o;
    
    ObjectInstance obj = _Instances[IN.instanceId];
    float3 posWS = mul(obj.TRSMatrix, IN.positionOS).xyz;
    o.positionCS = TransformWorldToHClip(posWS);
    o.uv = IN.uv;

    return o;
}

half4 frag(fragmentInput IN) : SV_TARGET
{
    return _Color;
}