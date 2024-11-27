using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace WasdswagPostProcess
{

    [System.Serializable]
    [PostProcess(typeof(PosterizationRenderer), PostProcessEvent.BeforeStack, "Wasdswag/Posterize")]
    public class Posterization : PostProcessEffectSettings
    {
        [Range(1f, 0f)] public FloatParameter Intensity = new FloatParameter { value = 1f };
    }

    public sealed class PosterizationRenderer : PostProcessEffectRenderer<Posterization>
    {
        private const string SHADERPATH = "Hidden/PostProcessing/Posterization";
        private Shader shader;
        private PropertySheet propertySheet;

        public override void Init() => shader = WasdswagFilters.GetShader(SHADERPATH);


        public override void Render(PostProcessRenderContext context)
        {
            if (shader.IsValid(context, ref propertySheet))
            {

                    var s = Mathf.Lerp(7f, 0f, 1 - settings.Intensity);
                    float numBins = Mathf.Pow(2f, Mathf.Round(s));
                    propertySheet.properties.SetFloat("_Steps", numBins);
                    context.command.BlitFullscreenTriangle(context.source, context.destination, propertySheet, 0);
            }
        }
    }
}

