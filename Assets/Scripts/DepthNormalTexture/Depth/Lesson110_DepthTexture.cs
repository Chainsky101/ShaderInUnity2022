using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lesson110_DepthTexture : PostEffectBase
{
    // Start is called before the first frame update
    void OnEnable()
    {
        //可以在Shader中得到对应的深度纹理信息了
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }


}
