using UnityEngine;

namespace ScreenPostProcess.BloomEffect
{
    public class BloomEffect : PostProcessBase
    {
        // 大于1的部分在HDR中有效果
        [Range(0, 5)] public float luminanceThreshold = 0;
        [Header("Gaussian Blur")]
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
            // set Property
            Material.SetFloat("_BlurSpread", blurSpread);
            Material.SetFloat("_LuminanceThreshold", luminanceThreshold);
            
            int texWeight = source.width / downSample;
            int texHeight = source.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(texWeight, texHeight);
            RenderTexture buffer1 = RenderTexture.GetTemporary(texWeight, texHeight);
            buffer0.filterMode = FilterMode.Bilinear;
            buffer1.filterMode = FilterMode.Bilinear;
            try
            {
                // extract brightness -- Pass 0
                Graphics.Blit(source, buffer0, Material, 0);
                // Gaussian Blur -- Pass 1 and 2
                for (int i = 0; i < sampleCount; i++)
                {
                    // blur spread solution 2:
                    Material.SetFloat("_BlurSpread", 1 + i * blurSpread);
                    Graphics.Blit(buffer0, buffer1, Material, 1);
                    Graphics.Blit(buffer1, buffer0, Material, 2);
                }
                // aggregation -- Pass 3
                Material.SetTexture("_Bloom", buffer0);
                Graphics.Blit(source, destination, Material, 3);
                // Graphics.Blit(buffer0, destination);
            }
            finally
            {
                RenderTexture.ReleaseTemporary(buffer0);
                RenderTexture.ReleaseTemporary(buffer1);
            }
        
        }
    }
}
