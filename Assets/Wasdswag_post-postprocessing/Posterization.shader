Shader "Hidden/PostProcessing/Posterization"
{
    
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
    TEXTURE2D_SAMPLER2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture);

    #if SOURCE_GBUFFER
        TEXTURE2D_SAMPLER2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2);
    #endif
    
    
    float _Steps;
    
    

    //float4 Frag(VaryingsDefault i) : SV_TARGET
    //{
     
    //    float px = 1024 / 10;
    //    float py = 768 / 10; 
    //    float2 uv = float2(floor(px * i.texcoord.x) / px, floor(py * i.texcoord.y) / py);
    //    float3 pixelColour = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rgb;
    //    return float4 (pixelColour, 1);
       
        
    //   //return float4 (r,r,b, 1);
    //}
    
   

    float4 Frag(VaryingsDefault i) : SV_TARGET
    {
        float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
        float numSteps = _Steps;
        float r = floor(col.r * numSteps) / numSteps;
        float g = floor(col.g * numSteps) / numSteps;
        float b = floor(col.b * numSteps) / numSteps;
        return float4(r, g, b, 1);
        
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