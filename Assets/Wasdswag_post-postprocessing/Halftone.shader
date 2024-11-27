Shader "Hidden/PostProcessing/Halftone"
{
   HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
    TEXTURE2D_SAMPLER2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture);

    #if SOURCE_GBUFFER
        TEXTURE2D_SAMPLER2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2);
    #endif
    
    
                #define TAU 6.28318530718

    
    float _DotTransparency;
    float _BackgroundTransparency;
    
    float _CellSize;
    float _Width;
    float _Height;
    float _DotSize;
    float _DotSmoothness;
    
    float4 _DotColor;
    float4 _BackgroundColor;

    float _Intensity;
    
    float _R; float _G; float _B; 
    
    float _DotWidth;
    float _DotRotation;

    
      float2 rotatePoint(float2 pt, float2 center, float angle) {
      
                float sinAngle = sin(angle);
                float cosAngle = cos(angle);
                pt -= center;
                float2 r = float2( pt.x * cosAngle - pt.y * sinAngle,
                                   pt.x * sinAngle + pt.y * cosAngle);
                r += center;
                return r;
            }
          
            
    float4 Frag(VaryingsDefault i) : SV_TARGET
    {   
    
        float2 uv = i.texcoord;
        float2 dotUV = uv;
        dotUV = rotatePoint(dotUV, float2(0.5,0.5), _DotRotation * 2 * PI); // * _ST.xy + _ST.zw;
               
        //Create Cells
        float cellWidth =  _CellSize / _Width;
        float cellHeight = _CellSize / _Height;
        float2 grid_resolution = float2(round(dotUV.x / cellWidth) * cellWidth, round(dotUV.y / cellHeight) * cellHeight);//  * _ST.xy + _ST.zw;
       
        
        //Calculate Distance From Cell Center
        float2 distanceVector = dotUV - grid_resolution;
        distanceVector.x = (distanceVector.x / _Height / _DotWidth) * _Width;
        float distanceFromCenter = length(distanceVector);
        

        float4 originalColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

       
        //Calculate Dot Size
        float dotSize = cellWidth * _DotSize;
        float luma = dot(originalColor.rgb, float3(_R, _G, _B)); // float3(0.2126, 0.7152, 0.0722)); // 
        dotSize *= (1-luma);
        
        float4 dotColor =        lerp(float4(_DotColor.rgb, 1),        originalColor,  1 - _DotColor.a);
        float4 backgroundColor = lerp(float4(_BackgroundColor.rgb, 1), originalColor,  1 - _BackgroundColor.a);
        
        //Calculate Displayed Color
        float lerpAmount = smoothstep(dotSize, dotSize + _DotSmoothness, distanceFromCenter);
        float4 color = lerp(dotColor, backgroundColor, lerpAmount);
        
        float4 finalCol = lerp(color, originalColor, 1-_Intensity);
        return finalCol;
        
       
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

