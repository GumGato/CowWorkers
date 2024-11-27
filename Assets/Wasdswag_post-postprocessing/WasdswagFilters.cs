using UnityEngine.Rendering.PostProcessing;
using UnityEngine;


namespace WasdswagPostProcess
{

    public static class WasdswagFilters 
    {
        public static Shader GetShader(string shaderpath)
        {
            Shader shader = Shader.Find(shaderpath);
            if (shader != null) return shader;

            // ERROR!
            Debug.LogError("Failed to find shader: " + shaderpath); 
            return null;
        }

        public static bool IsValid(this Shader shader, PostProcessRenderContext context, ref PropertySheet properties)
        {
            if (shader != null)
            {
                if(properties == null) properties = context.propertySheets.Get(shader);
                if (properties != null) return true;

                // ERROR!
                Debug.LogError("Failed to retrieve property sheet for shader");
                return false;
            }

            Debug.LogError("Shader is null");
            return false;
        }


    }
}
