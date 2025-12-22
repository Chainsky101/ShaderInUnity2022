using System;
using ScreenPostProcess;
using UnityEngine;

namespace DepthNormalTexture.Normal
{
    public class GetNormal : PostProcessBase
    {
        private void Start()
        {
            Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
        }
    }
}