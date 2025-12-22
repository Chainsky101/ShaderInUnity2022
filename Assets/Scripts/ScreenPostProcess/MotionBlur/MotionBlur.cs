using System;
using UnityEngine;

namespace ScreenPostProcess.MotionBlur
{
    public class MotionBlur : PostProcessBase
    {
        [Range(0, 1)]
        public float blurIndex = 0.2f;
        // accumulated texture
        private RenderTexture _accumulatedTexture = null;
        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (Material is null)
            {
                Graphics.Blit(source, destination);
                return;
            }
            
            Material.SetFloat("_BlurIndex", 1-blurIndex);
            // generate new render texture
            if (_accumulatedTexture == null ||
                _accumulatedTexture.width != source.width ||
                _accumulatedTexture.height != source.height)
            {
                DestroyImmediate(_accumulatedTexture);
                _accumulatedTexture = new RenderTexture(source.width, source.height, 0);
                // copy source texture to _texture
                Graphics.Blit(source, _accumulatedTexture);
            }
            Graphics.Blit(source, _accumulatedTexture, Material);
            Graphics.Blit(_accumulatedTexture, destination);
        }

        /// <summary>
        /// 组件失活时，销毁堆积纹理
        /// </summary>
        private void OnDisable()
        {
            DestroyImmediate(_accumulatedTexture);
        }
    }
}
