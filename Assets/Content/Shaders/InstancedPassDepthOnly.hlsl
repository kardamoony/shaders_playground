#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
float4 _MainTex_ST;

half4 _ColorTop0;
half4 _ColorTop1;
half4 _ColorBot0;
half4 _ColorBot1;

float3 _WindDirection;
float2 _WindStrength;

float3 Wind(in float3 pos, float rate)
{
    float t = pos.x + pos.y + pos.z;
    float3 offset = _WindDirection * (sin(_Time.y * _WindStrength.y + t) * sin(_Time.y * _WindStrength.y * 0.5)) * _WindStrength.x;
    return pos + offset * rate;
}

fragmentInput vert(vertexInput IN)
{
    fragmentInput o;
    
    ObjectInstance obj = _Instances[IN.instanceId];
    float3 posWS = mul(obj.TRSMatrix, IN.positionOS).xyz;

    posWS = Wind(posWS, IN.color);
    
    o.positionCS = TransformWorldToHClip(posWS);
    o.uv = TRANSFORM_TEX(IN.uv, _MainTex);

    return o;
}

half4 frag(fragmentInput IN) : SV_TARGET
{
    half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
    clip(color.a - 0.1);
    return 0;
}