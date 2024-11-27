Shader "Hidden/PostProcessing/FancyGrainNoise"
{
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_NoiseTex, sampler_NoiseTex);


    float4 _MainTex_TexelSize;
    
 
    float2 _Speed;
    float _Resolution;
    float _Intencity;
    float _Width;
    float _Height;
	float _Contrast;
    float _Threshold;
    float _R, _G, _B;
    int _Mode;




	   float rand(float2 n) {
                return frac(sin(dot(n, float2(12.9898, 78.233))) * 43758.5453);
            }

            float voronoi(float2 x) {
                float2 n = floor(x);
                float2 f = frac(x);
                float md = 8.0;
                float2 m = float2(0.0, 0.0);
                for (int j = -1; j <= 1; j++) {
                    for (int i = -1; i <= 1; i++) {
                        float2 g = float2(float(i), float(j));
                        float2 o = rand(n + g);
                        o = 0.5 + 0.5 * sin(_Time.y * _Speed.x + o * 6.2832);
                        float2 r = g + o - f;
                        float d = dot(r, r);
                        if (d < md) {
                            md = d;
                            m = n + g + o;
                        }
                    }
                }
                return 1.0 - md * 130.0;
            }

    
    
    
    float4 Frag(VaryingsDefault i) : SV_TARGET
    {
        float4 image = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
        float luma;
        float4 noiseSample;

        if(_Mode == 0)
        {
            float2 direction = float2(_Time.y * _Speed.x, _Time.y * _Speed.y);
            float2 noiseUV = (i.texcoord + direction) * _Resolution;
            noiseSample =  SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV);
            luma = dot(noiseSample.rgb, float3(_R, _G, _B));
        }
        else
        {
            float r = _Width / _Resolution;
            float noise = pow(voronoi(i.texcoord * r), 2.0);
            float br = dot(image, float3(_R, _G, _B));
            noiseSample = float(noise * pow(_Threshold, 2.0)); 
            luma = lerp(noiseSample, image, br);
        }


        
    	float4 c1 = image / max((1.0 - luma) * 2.0,  _Contrast);
    	float4 c2 =  1.0 - (1.0 - image) * 0.5  / max(luma, _Contrast);
    	float4 final = luma > 0.5 ? c1 : c2;
        

    	float4 result = lerp(image, final, _Intencity);
        return result;
				
    	
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

