using ScreenPostProcess;
using UnityEngine;

namespace DepthNormalTexture
{
    public class GetDepth : PostProcessBase
    {
        // [Range(0, 1)]
        // public float depthValue = 0;
        private void Start()
        {
            Camera.main.depthTextureMode = DepthTextureMode.Depth;
            print("123");
        }

        // private void Update()
        // {
        //     if (Material != null)
        //     {
        //         Texture tex = Material.GetTexture("_CameraDepthTexture");
        //         
        //     }
        // }
    }
}
