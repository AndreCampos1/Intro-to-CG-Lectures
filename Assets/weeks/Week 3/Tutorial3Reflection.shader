Shader "Custom/Tutorial3Reflection"
{
   Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        
        // Environment reflection
        _EnvCube     ("Reflection Cubemap", Cube) = "" {}
        _EnvIntensity("Reflection Intensity", Range(0,2)) = 1.0
        _EnvBlend    ("Reflection Blend (0=Base,1=Env)", Range(0,1)) = 1.0
        _FresnelPow  ("Fresnel Power", Range(0.1, 8)) = 5.0    // optional rim bias
        _FresnelBoost("Fresnel Boost", Range(0, 2)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes // From the mesh to the verted shader
            {
                float4 positionOS : POSITION; //Position in Object Space
                float2 uv0 : TEXCOORD0;
                float3 normalOS : NORMAL; //Normal in Object space
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION; 
                float3 positionWS : TEXCOORD0; //Position in world space
                float3 normalWS : TEXCOORD1; // Normal in world space
                float2 uv : TEXCOORD2; 
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            
            TEXTURECUBE(_EnvCube);
            SAMPLER(sampler_EnvCube);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float  _EnvIntensity;
                float  _EnvBlend;
                float  _FresnelPow;
                float  _FresnelBoost;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);
                float3 nrmWS = TransformObjectToWorldNormal(IN.normalOS);

                OUT.positionWS  = posWS;
                OUT.normalWS    = nrmWS;
                OUT.positionHCS = TransformWorldToHClip(posWS);
                OUT.uv          = TRANSFORM_TEX(IN.uv0, _BaseMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Base layer (optional)
                half3 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv).rgb * _BaseColor.rgb;

                // View direction (WS)
                float3 V = SafeNormalize(GetWorldSpaceViewDir(IN.positionWS));

                // Normal (WS)
                float3 N = SafeNormalize(IN.normalWS);

                // Reflection vector (WS) = reflect(incident, normal)
                // HLSL reflect() expects the INCIDENT vector (from surface toward eye), which is -V
                float3 R = reflect(-V, N);

                // Sample the cubemap with reflection vector
                half3 envCol = SAMPLE_TEXTURECUBE(_EnvCube, sampler_EnvCube, R).rgb * _EnvIntensity;

                // Optional Fresnel bias (stronger reflections at grazing angles)
                float  ndotv   = saturate(dot(N, V));
                float  fresnel = pow(1.0 - ndotv, _FresnelPow) * _FresnelBoost;
                envCol *= (1.0 + fresnel);

                // Blend env over base (unlit)
                half3 finalCol = lerp(baseCol, envCol, _EnvBlend);
                return half4(finalCol, 1.0);
            }
            ENDHLSL
        }
    }
}
