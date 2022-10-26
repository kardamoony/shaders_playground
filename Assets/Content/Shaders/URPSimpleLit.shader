Shader "Kardamoony/URPSimpleLit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags 
        {
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma exclude_renderers nomrt

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                float4 shadowCoord : TEXCOORD1;
                float fogCoord : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
            };
  
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4 _Color;
            CBUFFER_END
            
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.pos = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.shadowCoord = TransformWorldToShadowCoord(posWS);
                OUT.fogCoord = ComputeFogFactor(OUT.pos.z);

                OUT.normalWS = TransformWorldToObjectNormal(IN.normalOS);
                
                return OUT;
            }
            
            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;

                Light mainLight = GetMainLight(IN.shadowCoord);

                half3 attenColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
                half3 diffuse = LightingLambert(attenColor, mainLight.direction, IN.normalWS);
                diffuse = saturate(diffuse * 0.25);

                color.rgb *= diffuse;
                color.rgb = MixFog(color.rgb, IN.fogCoord);
                
                return color;
            }

            ENDHLSL
        }
    }
}