Shader "Custom/MyFirstShader"
{    
    Properties
    { 
        // Q1: Which two properties can be controlled through the Material
        // Inspector? What type of data does each property represent?
        // Both properties are controlled in the Inspector. First one is the color of the shader while the other one is the map
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _BaseMap("Base Map", 2D) = "white"
    }

    SubShader
    {        
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }

        Pass
        {            
            HLSLPROGRAM

            // Q2: Which shader stages do the following two directives define?
            // What functions are associated with each stage?

            #pragma vertex vert //The vertex processing
            #pragma fragment frag //Fragment processing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            

            //Structs are used to pass data in and out of vertex and fragment shader functions.

            struct Attributes //Attributes struct will be the input to the vertex shader
            {
                // Q3: What information do POSITION and TEXCOORD0 provide to the vertex shader?

                float4 positionOS : POSITION; //Vertext position from mesh
                float2 uv         : TEXCOORD0; //Texture coordination
            };

            struct Varyings 
            //The Varyings struct will be the input to the fragment shader, 
            //and the output of the vertex shader (if there is no geometry shader in-between)

            {
                // Q4: Why must positionHCS use SV_POSITION?
                // Why does uv use TEXCOORD0?

                float4 positionHCS : SV_POSITION;  //System value. Tells the GPU where the vertex exists on screen.
                float2 uv          : TEXCOORD0; //Tells the where to find teh primary set of texture coordinates in the mesh
            };

            // Q5: What is the purpose of declaring both a texture
            // and a sampler? What role does each one perform?
            // For each texture we have also define the sample state which contain info of filters and wrap in the texture
            TEXTURE2D(_BaseMap); 
            SAMPLER(sampler_BaseMap); 

            CBUFFER_START(UnityPerMaterial)

                // Q6: Why are these variables declared inside
                // the UnityPerMaterial constant buffer?
                // So that it moves the effort to the GPU (Aka SRP Batcher)
                //
                // What is the purpose of the _ST suffix in _BaseMap_ST? 
                // Stands for Scale and Transform (often referred to as Scale and Translation or Tiling and Offset).

                half4 _BaseColor;  
                float4 _BaseMap_ST;

            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                // Q7: What coordinate space does positionOS represent? Vertext position in object space
                // What coordinate space is produced by TransformObjectToHClip()? clip space position
                //
                // Why is this transformation necessary before the vertex
                // can be rendered? Its important so the 3D can become 2D in the screen.

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                // Q8: What happens to the UV coordinates here? 
                //
                // Predict what will happen to the texture if its Tiling 
                // is changed from (1,1) to (2,2) in the Material Inspector. It will tile from 1x1 to 2x2 set of tiles aka 4 tiles

                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Q9: Explain the purpose of each of the three arguments
                // passed to SAMPLE_TEXTURE2D().
                // First one grabs the base map. Second one is how the texture will be samples. Third one is the UV coordinate that we are sampling.
                //
                // Where do the UV coordinates used here originate? From the uv: TEXTCOORD0;

                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);

                // Q10: Predict the result if _BaseColor is set to
                // (1, 0, 0, 1). How would white, gray, and blue areas 
                // of the original texture be affected? It would turn the white into red, gray into dark red and blue into blacks
                //
                // Explain why multiplication is used here instead of addition. The origial colors to change with the new one

                half4 finalColor = color * _BaseColor;

                // Q11: Modify the shader so that it displays ONLY _BaseColor 
                // and ignores the texture. 
                //
                // Q12: Modify it again so that it displays ONLY the texture
                // and ignores _BaseColor.
                //  
                // What is the minimum code change required in each case?

                return finalColor;
            }

            ENDHLSL
        }
    }
}