using ScreenPostProcess;
using Unity.Mathematics;
using UnityEngine;

namespace Practise.NoiseTexture
{
    public class NoiseFogEffect : PostProcessBase
    {
        [Range(-0.1f, 0.1f)]
        public float xMoveSpeed = 0.1f;
        [Range(-0.1f, 0.1f)]
        public float yMoveSpeed = 0.1f;

        public float noiseAmount = 2f;
        public Texture noiseTexture;
        public Color fogColor = Color.gray;
        [Range(0, 3)]
        public float fogDensity = 1f;
        public float start = 0f;
        public float end = 5f;
        private Matrix4x4 _vertexDirMatrix;
        private void Start()
        {
            Camera.main.depthTextureMode = DepthTextureMode.Depth;
        }

        protected override void UpdateProperty()
        {
            if( Material == null)
                return;
            
            // calculate four vertex in Near plane of Camera
            Camera camera = Camera.main;
            float nearDistance = camera.nearClipPlane;
            float degree = camera.fieldOfView / 2;
            float tanValue = math.tan(math.radians(degree));
            float halfWidth = nearDistance * tanValue;
            float halfHeight = halfWidth / camera.aspect;
            Vector3 leftDownDir = camera.transform.forward * nearDistance - camera.transform.up * halfHeight -
                                  camera.transform.right * halfWidth;
            Vector3 rightDownDir = camera.transform.forward * nearDistance - camera.transform.up * halfHeight +
                                   camera.transform.right * halfWidth;
            Vector3 rightUpDir = camera.transform.forward * nearDistance + camera.transform.up * halfHeight +
                                 camera.transform.right * halfWidth;
            Vector3 leftUpDir = camera.transform.forward * nearDistance + camera.transform.up * halfHeight -
                                camera.transform.right * halfWidth;
            // let the four dir multiply depth (calculated in depth texture) can get the position of vertex in World
            // realPointDistance = vertexCameraDistance / nearDistance * depth
            float scale = leftDownDir.magnitude / nearDistance; // 1 / cos(degree)
            leftDownDir = leftDownDir.normalized * scale;
            rightDownDir = rightDownDir.normalized * scale;
            rightUpDir = rightUpDir.normalized * scale;
            leftUpDir = leftUpDir.normalized * scale;
            _vertexDirMatrix.SetRow(0, leftDownDir);
            _vertexDirMatrix.SetRow(1, rightDownDir);
            _vertexDirMatrix.SetRow(2, rightUpDir);
            _vertexDirMatrix.SetRow(3, leftUpDir);
            
            // set property in shader
            Material.SetFloat("_FogDensity", fogDensity);
            Material.SetColor("_FogColor", fogColor);
            Material.SetFloat("_Start", start);
            Material.SetFloat("_End", end);
            Material.SetMatrix("_VertexDirMatrix", _vertexDirMatrix);
            Material.SetTexture("_NoiseTex", noiseTexture);
            Material.SetFloat("_XSpeed", xMoveSpeed);
            Material.SetFloat("_YSpeed", yMoveSpeed);
            Material.SetFloat("_NoiseAmount", noiseAmount);
            
        }
    }
}