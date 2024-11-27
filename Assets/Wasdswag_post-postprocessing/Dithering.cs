using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace WasdswagPostProcess
{

    [System.Serializable]
    [PostProcess(typeof(DitheringGBRenderer), PostProcessEvent.AfterStack, "Wasdswag/Dithering")]
    public class Dithering : PostProcessEffectSettings
    {

        [Tooltip("It's better to set it up to maximum value (1)")]
        [Range(0f, 1f)] [HideInInspector] public FloatParameter Intensity = new FloatParameter { value = 0f };

        [Range(1, 64)] public IntParameter ColourDepth = new IntParameter { value  = 8};
        [Range(0f, 1f)] public FloatParameter DitherStrength =  new FloatParameter { value = 0.1f };

        [Range(1, 20)]  public IntParameter Resolution = new IntParameter { value = 1 };



    }

    public sealed class DitheringGBRenderer : PostProcessEffectRenderer<Dithering>
    {
        private const string SHADERPATH = "Hidden/PostProcessing/Dithering";
        private Shader shader;
        private PropertySheet propertySheet;
        private int maxPixelation = 1024;

        public override void Init() => shader = WasdswagFilters.GetShader(SHADERPATH);

        public override void Render(PostProcessRenderContext context)
        {
            if (shader.IsValid(context, ref propertySheet))
            {

                propertySheet.properties.SetFloat("_Intensity", settings.Intensity.value);

                propertySheet.properties.SetInt("_ColourDepth", settings.ColourDepth);
                propertySheet.properties.SetFloat("_DitherStrength", settings.DitherStrength);
                propertySheet.properties.SetFloat("_Resolution", settings.Resolution);

                propertySheet.properties.SetFloat("_Width", context.screenWidth);
                propertySheet.properties.SetFloat("_Height", context.screenHeight);

                context.command.BlitFullscreenTriangle(context.source, context.destination, propertySheet, 0);
            }

        }
    }
}
