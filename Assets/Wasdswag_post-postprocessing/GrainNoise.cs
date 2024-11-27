using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace WasdswagPostProcess
{

    [System.Serializable]
    [PostProcess(typeof(GrainNoiseRenderer), PostProcessEvent.AfterStack, "Wasdswag/Noise")]
    public class GrainNoise : PostProcessEffectSettings
    {
        public FloatParameter Intensity = new FloatParameter { value = 0.35f };
        public BoolParameter UseProceduralNoise = new BoolParameter { value = false };
        public TextureParameter NoiseTexture = new TextureParameter  { value = null };
        public FloatParameter Resolution = new FloatParameter { value = 3.5f };
        public Vector2Parameter Speed = new Vector2Parameter { value = Vector2.zero };
        
        
        [Space(15)]
        public FloatParameter Contrast = new FloatParameter { value = 0.00001f };
        [Range(0f, 1f)] public FloatParameter Threshold = new FloatParameter { value = 0.5f };

        
        [Range(0f, 1f)] public FloatParameter Highlights = new FloatParameter { value = 0.2126f };
        [Range(0f, 1f)] public FloatParameter Midtones = new FloatParameter { value = 0.7152f };
        [Range(0f, 1f)] public FloatParameter Shadows = new FloatParameter { value = 0.0722f };

        
       // [Tooltip("It's better to set it up to maximum value (1)")]
      //  [Range(0f, 1f)] [HideInInspector] public FloatParameter Intensity = new FloatParameter { value = 0f };
      
    }

    public sealed class GrainNoiseRenderer : PostProcessEffectRenderer<GrainNoise>
    {
        private const string SHADERPATH = "Hidden/PostProcessing/FancyGrainNoise";
        private Shader shader;
        private PropertySheet propertySheet;
        
        public override void Init() => shader = WasdswagFilters.GetShader(SHADERPATH);

        public override void Render(PostProcessRenderContext context)
        {
            if (shader.IsValid(context, ref propertySheet))
            {
                propertySheet.properties.SetFloat("_Width", context.screenWidth);
                propertySheet.properties.SetFloat("_Height", context.screenHeight);
                
                
                if(settings.NoiseTexture.value != null)
                    propertySheet.properties.SetTexture("_NoiseTex", settings.NoiseTexture);
                
                propertySheet.properties.SetFloat("_Intencity", settings.Intensity.value);
                propertySheet.properties.SetFloat("_Resolution", settings.Resolution.value);
                propertySheet.properties.SetVector("_Speed", settings.Speed.value);
                propertySheet.properties.SetFloat("_R", settings.Highlights);
                propertySheet.properties.SetFloat("_G", settings.Midtones);
                propertySheet.properties.SetFloat("_B", settings.Shadows);
                propertySheet.properties.SetFloat("_Contrast", settings.Contrast);
                propertySheet.properties.SetFloat("_Threshold", settings.Threshold);
                int useVNoise = settings.UseProceduralNoise.value ? 1 : 0;
                propertySheet.properties.SetInt("_Mode", useVNoise);


            
            
                context.command.BlitFullscreenTriangle(context.source, context.destination, propertySheet, 0);
            }

        }
    }
}
