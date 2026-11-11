Shader "Custom/LamberDiffuse"
{

    Properties
    {

        _Color ("Color", Color) = (1,1,1,1)

    }

 

    SubShader

    {

        Tags
        {

            "RenderType"="Opaque"
            "Queue"="Geometry"
            "RenderPipeline"="UniversalRenderPipeline"

        }

 

        Pass
        {

            Name "UniversalForward"
            Tags { "LightMode"="UniversalForward" }

 

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

 

            // Q1: What is the purpose of the #pragma vertex vert directive?
        //To tell the shader where the vertices are in unity

            // Q2: Which included URP library provides lighting-related functions such as GetMainLight()?
        // The Lighting one
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

 

            struct Attributes // Info from the mesh into the vertex shader
            {

                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;

            };

 

            // Q3: Why must positionHCS use the SV_POSITION semantic?

            struct Varyings // Info from vertext shader to the fragment shader
            {

                float4 positionHCS : SV_POSITION; //
                float3 normalWS    : TEXCOORD0;

            };

 

            // Q4: Why is _Color placed inside UnityPerMaterial?

            CBUFFER_START(UnityPerMaterial)

                float4 _Color;

            CBUFFER_END

 

            Varyings vert (Attributes IN)

            {

                Varyings OUT;

 

                // Q5: What coordinate-space conversion is performed by TransformObjectToWorld()?

                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);

 

                // Q6: Why is the world-space position transformed with TransformWorldToHClip()?

                OUT.positionHCS = TransformWorldToHClip(posWS);

 

                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);

 

                return OUT;

            }

 

            half4 frag (Varyings IN) : SV_Target
            {

                // Q7: Why should the interpolated world-space normal be normalized before lighting calculations?

                float3 N = SafeNormalize(IN.normalWS);

 

                Light mainLight = GetMainLight(); 

 

                // Q8: What does saturate(dot(N, mainLight.direction)) represent in Lambert diffuse lighting?

                float NdotL = saturate(dot(N, mainLight.direction));

 

                // Q9: Which three factors determine the diffuse term calculated below?

                half3 diffuse = _Color.rgb * mainLight.color.rgb * NdotL;

 

                // Q10: What lighting contribution is added by SampleSH(N)?

                half3 ambient = SampleSH(N) * _Color.rgb;

 

                return half4(diffuse + ambient, 1);

            }

 

            ENDHLSL

        }

    }

}