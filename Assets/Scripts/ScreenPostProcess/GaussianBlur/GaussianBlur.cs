using System;
using UnityEngine;

namespace ScreenPostProcess.GaussianBlur
{
    public class GaussianBlur : PostProcessBase
    {
        [Range(1,10)]
        public int sampleCount = 1;

        [Range(0, 5)] 
        public float blurSpread = 1;
        [Range(1,8)]
        public int downSample = 1;
        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (Material is null)
            {
                Graphics.Blit(source, destination);
                return;
            }
            // blur spread solution 1:
            // Material.SetFloat("_BlurSpread", blurSpread);
            int texWeight = source.width / downSample;
            int texHeight = source.height / downSample;
            // Debug.Log(Material.GetFloat("_BlurSpread"));
            RenderTexture buffer1 = RenderTexture.GetTemporary(texWeight, texHeight, 0);
            RenderTexture buffer2 = RenderTexture.GetTemporary(texWeight, texHeight, 0);
            buffer1.filterMode = FilterMode.Bilinear;
            buffer2.filterMode = FilterMode.Bilinear;
            try
            {
                Graphics.Blit(source,buffer1);
                for (int i = 0; i < sampleCount; i++)
                {
                    // blur spread solution 2:
                    Material.SetFloat("_BlurSpread", 1 + i * blurSpread);
                    Graphics.Blit(buffer1, buffer2, Material, 0);
                    Graphics.Blit(buffer2, buffer1, Material, 1);
                }
                Graphics.Blit(buffer1, destination);
            }
            finally
            {
                RenderTexture.ReleaseTemporary(buffer1);
                RenderTexture.ReleaseTemporary(buffer2);
            }
        }

    }
}
