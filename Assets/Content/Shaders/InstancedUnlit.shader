Shader "Kardamoony/Instanced/InstancedUnlit"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
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

            #include "Assets/Content/Shaders/InstancedInputUnlit.hlsl"
            #include "Assets/Content/Shaders/InstancedPassUnlit.hlsl"
            
            
            ENDHLSL
        }
    }
}