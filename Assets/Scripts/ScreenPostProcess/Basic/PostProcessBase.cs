using System;
using UnityEngine;

namespace ScreenPostProcess
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    public class PostProcessBase : MonoBehaviour
    {
        public Shader shader;
        private Material _material;

        protected Material Material
        {
            get
            {
                if (shader == null || !shader.isSupported)
                    return null;
                else
                {
                    if (_material != null && _material.shader == shader)
                        return _material;
                    
                    _material = new Material(shader);
                    _material.hideFlags = HideFlags.DontSave;
                    return _material;
                }
            }
        }

        protected virtual void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            // update the property override in subclass before transfer texture
            UpdateProperty();
            if(Material is not null)
                Graphics.Blit(source, destination, Material);
            else
            {
                Graphics.Blit(source, destination);
            }
        }
        /// <summary>
        /// update property of material
        /// </summary>
        protected virtual void UpdateProperty()
        {
            
        }
    }
}
