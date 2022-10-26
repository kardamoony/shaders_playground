#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;

half4 _ColorTop0;
half4 _ColorTop1;
half4 _ColorBot0;
half4 _ColorBot1;

float3 _WindDirection;
float2 _WindStrength;
CBUFFER_END

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
    o.normalWS = mul(obj.TRSMatrix, float4(IN.normalOS, 0)).xyz;
    
    o.uv = TRANSFORM_TEX(IN.uv, _MainTex);
    o.shadowCoord = TransformWorldToShadowCoord(posWS);

    half colorValue = IN.color + 0.05;

    half4 color0 = _ColorTop0 * colorValue + _ColorBot0 * (1 - colorValue);
    half4 color1 = _ColorTop1 * colorValue + _ColorBot1 * (1 - colorValue);
    
    o.color = lerp(color0, color1, obj.variation);
    o.fogCoord = ComputeFogFactor(o.positionCS.z);

    return o;
}

half4 frag(fragmentInput IN) : SV_TARGET
{
    half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * IN.color;

    clip(color.a - 0.1);

    Light mainLight = GetMainLight(IN.shadowCoord);
    
    /*#if defined(_SCREEN_SPACE_OCCLUSION)
    AmbientOcclusionFactor aoF = GetScreenSpaceAmbientOcclusion(GetNormalizedScreenSpaceUV(IN.positionCS));
    mainLight.color *= aoF.directAmbientOcclusion;
    mainLight.shadowAttenuation *= min(mainLight.shadowAttenuation, aoF.indirectAmbientOcclusion);
    #endif*/

    half3 attenColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
    half3 diffuse = LightingLambert(attenColor, mainLight.direction, IN.normalWS);
    diffuse = saturate(diffuse * 0.25);

    color.rgb *= diffuse;

    color.rgb = MixFog(color.rgb, IN.fogCoord);
    
    return color;
}