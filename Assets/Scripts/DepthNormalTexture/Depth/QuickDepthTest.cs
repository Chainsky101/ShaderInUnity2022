// 快速测试脚本
using UnityEngine;

public class QuickDepthTest : MonoBehaviour
{
    void Start()
    {
        Camera cam = Camera.main;
        
        // 1. 设置相机
        cam.depthTextureMode = DepthTextureMode.Depth;
        cam.farClipPlane = 100f;
        cam.nearClipPlane = 0.1f;
        
        // 2. 创建测试物体
        for (int i = 0; i < 5; i++)
        {
            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.transform.position = new Vector3(i * 2 - 4, 0, 10);
            cube.GetComponent<Renderer>().material.color = Color.red;
        }
        
        // 3. 创建地面
        GameObject plane = GameObject.CreatePrimitive(PrimitiveType.Plane);
        plane.transform.position = new Vector3(0, -1, 10);
        plane.transform.localScale = new Vector3(10, 1, 10);
        
        Debug.Log("测试场景已创建！");
    }
}
