using UnityEngine;

namespace ScreenPostProcess.EdgeDetect
{
    public class EdgeDetect : PostProcessBase
    {
        public Color edgeColor = Color.white;
        public Color backgroundColor = Color.white;
        [Range(0, 1)]
        public float backgroundExtent = 0;
        protected override void UpdateProperty()
        {
            if (Material is not null)
            {
                Material.SetColor("_EdgeColor", edgeColor);
                Material.SetColor("_BackgroundColor", backgroundColor);
                Material.SetFloat("_BackgroundExtent", backgroundExtent);
            }
        }
    }
}
