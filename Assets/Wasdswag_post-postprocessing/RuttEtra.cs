using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace WasdswagPostProcess
{

    [System.Serializable]
    [PostProcess(typeof(RuttEtraRenderer), PostProcessEvent.AfterStack, "Wasdswag/Rutt Etra")]
    public class RuttEtra : PostProcessEffectSettings
    {

        [Tooltip("set it to one (1) by default")]
        [Range(0f, 1f)] public FloatParameter Intensity = new FloatParameter { value = 0f };
        [Space(15)]

        [Tooltip("lower is faster")]
        [Range(1f, 720f)] public FloatParameter ResolutionX = new FloatParameter { value = 200f };
        [Tooltip("lower is faster")]
        [Range(1f, 720f)] public FloatParameter  ResolutionY = new FloatParameter { value = 40f };
        [Tooltip("check it to draw lines vertically")]
        public BoolParameter VerticalLines = new BoolParameter { value = false };

        [Space(15)][Tooltip("Wave distortion gain")]
        [Range(-1f, 1f)] public FloatParameter Amplitude = new FloatParameter { value = 0.2f };

        [Space(15)][Tooltip("Source image adjustments. You could also add unity default bloom effect to achieve more smooth result")]
        [Range(0f, 1f)] public FloatParameter Contrast = new FloatParameter { value = 0.5f };
        [Range(-2f, 2f)] public FloatParameter Saturation = new FloatParameter { value = 0f };

        [Space(15)]
        public ColorParameter LineColor        = new ColorParameter { value = Color.white };
        public ColorParameter BackgroundColor  = new ColorParameter { value = Color.black };


        [Space(15)]
        [Range(0.0f, 0.01f)] public FloatParameter Width = new FloatParameter { value = 0.003f };
        [Tooltip("lower is faster")]
        [Range(1, 20)] public IntParameter MaxStrokesPerLine = new IntParameter { value = 10 };

        [Tooltip("check it if you want to make strokes wider depending on the amplitude of the waves")]
        public BoolParameter ExtendLineWidthByWaveAmplitude = new BoolParameter { value = false };

        [Space(15)]
        [Header ("External settings:")]
        [Range(0.0003f, 0.01f)] public FloatParameter DefaultStrokeWeight = new FloatParameter { value = 0.0005f };
        [Tooltip("extend line width by encreasing strokes leading")]
        [Range(-0.01f, 0.01f)] public FloatParameter StrokesLeading = new FloatParameter { value = 0f };







    }

    public sealed class RuttEtraRenderer : PostProcessEffectRenderer<RuttEtra>
    {
        private const string SHADERPATH = "Hidden/PostProcessing/RuttEtra";

        private Shader shader;
        private PropertySheet propertySheet;

        public override void Init() {

            shader = WasdswagFilters.GetShader(SHADERPATH);
            base.Init();
        }



        public override void Render(PostProcessRenderContext context)
        {
            if (shader.IsValid(context, ref propertySheet))
            {
                propertySheet.properties.SetFloat("_Intensity", settings.Intensity);

                propertySheet.properties.SetFloat("_Amplitude", settings.Amplitude);
                propertySheet.properties.SetFloat("_HorizontalResolution", settings.ResolutionX);
                propertySheet.properties.SetFloat("_VerticalResolution", settings.ResolutionY);
                propertySheet.properties.SetFloat("_LineWidth", settings.Width);
                propertySheet.properties.SetFloat("_IsVertical", settings.VerticalLines.value ? 1.0f : 0.0f);
                propertySheet.properties.SetFloat("_UseStrokesByAmp", settings.ExtendLineWidthByWaveAmplitude.value ? 1.0f : 0.0f);
                propertySheet.properties.SetFloat("_MaxStrokeWidthIteration", settings.MaxStrokesPerLine);
                propertySheet.properties.SetFloat("_DefaultStrokeWidth", settings.DefaultStrokeWeight);
                propertySheet.properties.SetFloat("_StrokesLeading", settings.StrokesLeading);


                propertySheet.properties.SetFloat("_Contrast", settings.Contrast);
                propertySheet.properties.SetFloat("_Saturation", settings.Saturation);

                propertySheet.properties.SetColor("_LineColor", settings.LineColor);
                propertySheet.properties.SetColor("_BackgroundColor", settings.BackgroundColor);

                context.command.BlitFullscreenTriangle(context.source, context.destination, propertySheet, 0);

            }

        }
    }
}
