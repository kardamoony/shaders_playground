Shader "Kardamoony/Instanced/InstancedGrass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorTop0("Color Top", Color) = (1, 1, 1, 1)
        _ColorTop1("Color Top Variation", Color) = (1, 1, 1, 1)
        _ColorBot0("Color Bottom", Color) = (1, 1, 1, 1)
        _ColorBot1("Color Bottom Variation", Color) = (1, 1, 1, 1)
        
        [Space]
        _WindDirection("Wind direction", Vector) = (1, 0, 0, 0)
        _WindStrength("Wind strength", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
        }

        Pass
        {
            Cull Off
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fog

            ///#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Assets/Content/Shaders/InstancedInputLit.hlsl"
            #include "Assets/Content/Shaders/InstancedPassLit.hlsl"
            
            ENDHLSL
        }
        
        /*Pass
        {
            Name "DepthOnly"
            
            Tags
            {
                "LightMode" = "DepthOnly"
            }
            
            Blend One Zero
            ZWrite On
            ColorMask 0
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "Assets/Content/Shaders/InstancedInputDepthOnly.hlsl"
            #include "Assets/Content/Shaders/InstancedPassDepthOnly.hlsl"
            
            ENDHLSL
        }*/
        
        /*Pass
        {
            Name "ShadowCaster"
            
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            
            Blend One Zero
            ZWrite On
            ColorMask 0
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "Assets/Content/Shaders/InstancedInputDepthOnly.hlsl"
            #include "Assets/Content/Shaders/InstancedPassDepthOnly.hlsl"
            
            ENDHLSL
        }*/
    }
}