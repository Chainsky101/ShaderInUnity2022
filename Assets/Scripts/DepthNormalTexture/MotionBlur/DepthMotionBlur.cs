using System;
using ScreenPostProcess;
using UnityEngine;

namespace DepthNormalTexture.MotionBlur
{
    public class DepthMotionBlur : PostProcessBase
    {
        [Range(0, 4)]
        public float blurSize = 0.2f;

        private Matrix4x4 _frontWorldToClip;

        private void Start()
        {
            // set the depth texture type
            Camera.main.depthTextureMode = DepthTextureMode.Depth;
        }

        // initialize transformation matrix _frontWorldToClip
        private void OnEnable()
        {
            _frontWorldToClip = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
        }

        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (Material == null)
            {
                Graphics.Blit(source, destination);
                return;
            }
            
            Material.SetFloat("_BlurSize", blurSize);
            Material.SetMatrix("_FrontWorldToClipMatrix", _frontWorldToClip);
            _frontWorldToClip = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
            Material.SetMatrix("_ClipToWorldMatrix", _frontWorldToClip.inverse);
            Graphics.Blit(source, destination, Material);
        }
    }
}
