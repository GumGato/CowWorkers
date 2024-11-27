using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace WasdswagPostProcess
{

    [System.Serializable]
    [PostProcess(typeof(HalftoneRenderer), PostProcessEvent.AfterStack, "Wasdswag/Halftone")]
    public class Halftone : PostProcessEffectSettings
    {

        [Tooltip("It's better to set it up to maximum value (1)")]
        [Range(0f, 1f)] [HideInInspector] public FloatParameter Intensity = new FloatParameter { value = 0f };

        [Space(15)] [Tooltip("You could also adjust alpha-channel, if you want")]
        public ColorParameter DotColor = new ColorParameter { value = Color.black };
        public ColorParameter BackgroundColor = new ColorParameter { value = Color.white };

        [Space(15)]
        [Range(0.3f, 1f)] public FloatParameter CellSize = new FloatParameter { value = 0.83f };
        [Range(0f, 1f)] public FloatParameter DotSize = new FloatParameter { value = 0.3f };
        [Range(0f, 0.01f)] public FloatParameter DotSmoothness = new FloatParameter { value = 0.0001f };





        [Space(15)]
        [Range(0f, 1f)] public FloatParameter Highlights = new FloatParameter { value = 0.2126f };
        [Range(0f, 1f)] public FloatParameter Midtones = new FloatParameter { value = 0.7152f };
        [Range(0f, 1f)] public FloatParameter Shadows = new FloatParameter { value = 0.0722f };


        [Space(15)]
        [Range(1f, 10f)] public FloatParameter DotWidth = new FloatParameter { value = 1f };
        [Range(-1f, 1f)] public FloatParameter DotRotation = new FloatParameter { value = 0f };




    }

    public sealed class HalftoneRenderer : PostProcessEffectRenderer<Halftone>
    {
        private const string SHADERPATH = "Hidden/PostProcessing/Halftone";
        private Shader shader;
        private PropertySheet propertySheet;
        private float maxPesolution = 1024f;
     
        public override void Init() => shader = WasdswagFilters.GetShader(SHADERPATH);

        public override void Render(PostProcessRenderContext context)
        {
            if (shader.IsValid(context, ref propertySheet))
            {

                float power = (settings.CellSize * maxPesolution);
                float gain = context.screenWidth / (maxPesolution - power);
                float dotSize = (settings.DotSize * 5) + 0.005f;

                propertySheet.properties.SetFloat("_Intensity", settings.Intensity.value);

                // Colors:
                propertySheet.properties.SetColor("_DotColor", settings.DotColor);
                propertySheet.properties.SetColor("_BackgroundColor", settings.BackgroundColor);

                propertySheet.properties.SetFloat("_CellSize",gain);
                propertySheet.properties.SetFloat("_DotSize", dotSize);

                propertySheet.properties.SetFloat("_DotWidth", settings.DotWidth);

                propertySheet.properties.SetFloat("_DotSmoothness", settings.DotSmoothness);
                propertySheet.properties.SetFloat("_Width", context.screenWidth);
                propertySheet.properties.SetFloat("_Height", context.screenHeight);

                propertySheet.properties.SetFloat("_DotRotation", settings.DotRotation);

                propertySheet.properties.SetFloat("_R", settings.Highlights);
                propertySheet.properties.SetFloat("_G", settings.Midtones);
                propertySheet.properties.SetFloat("_B", settings.Shadows);



                context.command.BlitFullscreenTriangle(context.source, context.destination, propertySheet, 0);
            }

        }
    }
}
