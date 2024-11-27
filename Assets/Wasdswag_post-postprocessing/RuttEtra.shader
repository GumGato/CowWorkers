Shader "Hidden/PostProcessing/RuttEtra"
{

    
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    #define MAXRESOLUTION 518400
    
    float _Contrast;
    float _Saturation;   
 
    half _VerticalResolution; 
    half _HorizontalResolution;
    
    float _LineWidth;
    
    float _Amplitude;
    
    float4 _LineColor;
    float4 _BackgroundColor;
    
    half  _IsVertical;
    half  _UseStrokesByAmp;
    half  _MaxStrokeWidthIteration;
    float _StrokesLeading;
    
    float _DefaultStrokeWidth;
    float _Intensity;
    

   
    
    float DrawLine(float2 p1, float2 p2, float2 uv, float thickness) 
    {
    
              float a = abs(distance(p1, uv));
              float b = abs(distance(p2, uv));
              float c = abs(distance(p1, p2));
              
              if (a >= c || b >= c ) return 0.0;
              
              return 1.0;
              
              //float p = (a + b + c) * .5;
              //float h = 2 / c * sqrt(p * (p - a) * (p - b) * (p - c));
              //return lerp(1.0, 0.0, smoothstep(0.5 * thickness, 1.5 * thickness, h));
    }
    
    
    
    float3 GetPixelColor(float2 position)
    {
        float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, position);
       
        float contrast = _Contrast * 6;
        
        color.rgb = (color.rgb - 0.5f) * (contrast) + 0.5f;
        float3 grayScale = dot(color.rgb, float3(0.299, 0.587, 0.114));
        
        color.rgb = lerp(grayScale, color.rgb, _Saturation);
        return color.rgb;
    }
    

    
    float4 Frag(VaryingsDefault i) : SV_TARGET
    {
    
            float2 uv  = i.texcoord;
           //return float4(GetPixelColor(uv), 1);
            
            half xResolution = floor(_HorizontalResolution);
            half yResolution = floor(_VerticalResolution);
            
            float direction = _IsVertical == 0.0 ? uv.x : uv.y; 
              
            float xStep = floor(direction * xResolution) / xResolution;
            float x1 = xStep;
            float x2 = xStep + (1.0 / xResolution);
            
            float lines;
            float amp = _Amplitude * 0.05;
            
            half strokeWidthIterations = 0;
            half maxStrokes = floor((_LineWidth * 100) * _MaxStrokeWidthIteration) + 1;
            half pixels = yResolution * xResolution;
            half maxStrokesByAmp = lerp(maxStrokes * 2, 1, pixels / MAXRESOLUTION);
            

              
            for(half index = 0; index < yResolution; index++) {
            
                float leading = 1.0 / yResolution;
                float y = leading * index;
                
                float2 fromUV = _IsVertical == 0.0 ? float2(x1, y) : float2(y, x1); 
                float2 toUV =   _IsVertical == 0.0 ? float2(x2, y) : float2(y, x2); 
             
                float3 fromColor = GetPixelColor(fromUV); 
                float3 toColor   = GetPixelColor(toUV); 
                
                float fromBump = length(fromColor) * amp;
                float toBump   = length(toColor)   * amp;
                
                float2 fromPosition = _IsVertical == 0.0 ? float2(x1, y + fromBump - amp) : float2(y + fromBump - amp, x1);
                float2 toPosition =   _IsVertical == 0.0 ? float2(x2, y + toBump   - amp) : float2(y + toBump - amp,   x2);
               
               
                if(_UseStrokesByAmp == 1.0 && _LineWidth > 0)
                strokeWidthIterations = clamp(floor(abs(fromBump + toBump) * 500), 0, maxStrokesByAmp);
                else strokeWidthIterations = maxStrokes;
                
               // lines += DrawLine(fromPosition, toPosition, uv, _DefaultStrokeWidth);
               // lines += saturate(capsule(uv, fromPosition, toPosition, _DefaultStrokeWidth * 10));
              
                for(half w = -strokeWidthIterations * .5; w < strokeWidthIterations * .5; w++){
                
                float s =  (_DefaultStrokeWidth + _StrokesLeading) * w;
                float2 f = _IsVertical == 0.0 ? float2(fromPosition.x, fromPosition.y + s) : float2(fromPosition.x + s, fromPosition.y);
                float2 t = _IsVertical == 0.0 ? float2(toPosition.x,   toPosition.y + s)   : float2(toPosition.x + s, toPosition.y);
                lines += DrawLine(f, t, uv, _DefaultStrokeWidth);
                
                }
               
                
            }
          //lines /= (yResolution);
           //saturate(lines);
            
            float3 originalColor = GetPixelColor(uv);
            float4 backColor = lerp(float4(originalColor, 1),   _BackgroundColor,   _BackgroundColor.a);
            float4 lineColor = lerp(float4(originalColor, 1),   _LineColor,         _LineColor.a);
            
            
            float4 result = lerp(backColor, lineColor, lines); 
            
            return lerp(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv), result, _Intensity);
 
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