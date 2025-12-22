using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{


    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            // 检查当前相机的深度纹理模式
            Debug.Log("Depth Texture Mode: " + Camera.main.depthTextureMode);
            // 检查是否有深度纹理
            var depthTexture = Shader.GetGlobalTexture("_CameraDepthTexture");
            Debug.Log("Depth Texture exists: " + (depthTexture != null));

            // 检查相机参数
            Debug.Log($"Camera - Near: {Camera.main.nearClipPlane}, Far: {Camera.main.farClipPlane}");
        }
    }
}
