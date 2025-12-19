using UnityEngine;

namespace ScreenPostProcess
{
    public class BrightnessSaturationContrast : PostProcessBase
    {
        [Range(0, 5)]
        public float brightness = 1;
        [Range(0, 5)]
        public float saturation = 1;
        [Range(0, 5)]
        public float contrast = 1;

        protected override void UpdateProperty()
        {
            if (Material is not null)
            {
                Material.SetFloat("_Brightness", brightness);
                Material.SetFloat("_Saturation", saturation);
                Material.SetFloat("_Contrast", contrast);
            }
        }
    }
}