Shader "Hidden/PostProcessing/Pixelation"
{
    
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
  
    float _Width;
    float _Height;
    float _CellSize;
    
    
   
    float4 Frag(VaryingsDefault i) : SV_TARGET
    {
        float px = _Width  /  _CellSize;
        float py = _Height /  _CellSize; 
        
        float2 uv = float2(floor(px * i.texcoord.x) / px, floor(py * i.texcoord.y) / py);
        float3 pixelColour = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rgb;
        return float4 (pixelColour, 1);
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
