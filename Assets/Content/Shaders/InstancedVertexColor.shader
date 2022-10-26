Shader "Kardamoony/Instanced/InstancedUnlit_VertexColor"
{
    Properties
    {
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

            #include "Assets/Content/Shaders/InstancedInputVertexColor.hlsl"
            #include "Assets/Content/Shaders/InstancedPassVertexColor.hlsl"
            
            
            ENDHLSL
        }
    }
}