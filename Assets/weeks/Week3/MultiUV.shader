Shader "Custom/MultiUV"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)

        // Q1: What is the purpose of [KeywordEnum(UV0, UV1)] _UVSET?
        // Dropdown to pick which UV set Base Map uses
        [KeywordEnum(UV0, UV1)] _UVSET ("UV Set", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "RenderPipeline"="UniversalRenderPipeline" }
        LOD 200

        Pass
        {
            Name "Unlit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Q2: What is the purpose of the following #pragma statement?
            //Creates keywords that match the [KeywordEnum] above
            #pragma shader_feature_local _UVSET_UV0 _UVSET_UV1

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;

                // Q3: What do uv0 : TEXCOORD0 and uv1 : TEXCOORD1 represent?
                
                float2 uv0 : TEXCOORD0; // Mesh UV channel 0
                float2 uv1 : TEXCOORD1; // Mesh UV channel 1
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;

                // Q4: Why does Varyings contain only one float2 uv even though Attributes contains uv0 and uv1?

                float2 uv : TEXCOORD0; // Because it only need to process one shader into the screen not both at the same time.
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                // Q5: When _UVSET_UV1 is defined, which mesh UV channel
                // is assigned to OUT.uv? uv1

                #if defined(_UVSET_UV1)
                    OUT.uv = TRANSFORM_TEX(IN.uv1, _BaseMap);

                // Q6: If _UVSET_UV1 is not defined, which UV coordinates
                // are used? uv0

                #else
                    OUT.uv = TRANSFORM_TEX(IN.uv0, _BaseMap);
                #endif

                // Q7: What does TRANSFORM_TEX apply to the selected
                // UV coordinates?  It add the tilling and ofset option in the inspector

                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // Q8: Which value determines where _BaseMap is sampled? IN.uv 

                half4 baseTex = SAMPLE_TEXTURE2D(
                    _BaseMap,
                    sampler_BaseMap,
                    IN.uv
                );

                // Q9: What does baseTex.rgb * _BaseColor.rgb do? Mutiplies the texture colors with the base color of the material
                
                // Q10: What alpha value does this shader return regardless
                // of baseTex.a and _BaseColor.a? 1?

                return half4(baseTex.rgb * _BaseColor.rgb, 1.0);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
