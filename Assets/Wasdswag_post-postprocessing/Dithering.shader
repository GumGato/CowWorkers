Shader "Hidden/PostProcessing/Dithering"
{
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
    TEXTURE2D_SAMPLER2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture);

    #if SOURCE_GBUFFER
        TEXTURE2D_SAMPLER2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2);
    #endif
    
    
    float _MaxPixelation;
    float _Width;
    float _Height;
    float _CellSize;
    float _Resolution;
    
    int _ColourDepth;
    float _DitherStrength;
    
    static const float4x4 ditherTable = float4x4(
    -4.0, 0.0, -3.0, 1.0,
    2.0, -2.0, 3.0, -1.0,
    -3.0, 1.0, -4.0, 0.0,
    3.0, -1.0, 2.0, -2.0
);
    
    
    
    float4 Frag(VaryingsDefault i) : SV_TARGET
    {
        float2 screenParams = float2(_Width, _Height) / _Resolution;
        float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
        
        uint2 pixelCoord = i.texcoord * screenParams.xy;
        col += ditherTable[pixelCoord.x % 4][pixelCoord.y % 4] * _DitherStrength;
        return round(col * _ColourDepth) / _ColourDepth;
    }

    ENDHLSL

   
     SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM

            #pragma vertex VertDefault
            #pragma fragment Frag
            
            ENDHLSL
        }
    }
}